#include <ArduinoJson.h>
#include <WebServer.h>
#include <WiFi.h>

#include "esp_cpu.h"
#include "shared.h"

const char *SSID = "zebas";
const char *PWD = "manzana1234";
WebServer server(80);
StaticJsonDocument<250> jsonDocument;
StaticJsonDocument<250> jsonPost;
char buffer[250];
unsigned int timestamp;

void connectToWiFi() {
  LOG("wifi", "connecting to %s", SSID);
  WiFi.begin(SSID, PWD);

  while (WiFi.status() != WL_CONNECTED) {
    LOG("wifi", "waiting for connection...");
    delay(500);  // we can even make the ESP32 to sleep
  }
  Serial.print("[ wifi ]: connected. IP: ");
  Serial.println(WiFi.localIP());
  delay(1000);
  server.begin();
}

void add_json_object() {
  JsonObject obj = jsonDocument.createNestedObject();
  obj["timestamp"] = esp_timer_get_time();
  if (xSemaphoreTake(imu_data_mutex, portMAX_DELAY) == pdTRUE) {
    obj["aceleracion_x"] = imu_data.ax;
    obj["aceleracion_y"] = imu_data.ay;
    obj["aceleracion_z"] = imu_data.az + 10.9;  // quitar gravedad
    obj["orientacion_x"] = imu_data.gx;
    obj["orientacion_y"] = imu_data.gy;
    obj["orientacion_z"] = imu_data.gz;
    xSemaphoreGive(imu_data_mutex);
  } else {
    obj["aceleracion_x"] = 0;
    obj["aceleracion_y"] = 0;
    obj["aceleracion_z"] = 0;
    obj["orientacion_x"] = 0;
    obj["orientacion_y"] = 0;
    obj["orientacion_z"] = 0;
  }

  if (xSemaphoreTake(proximity_val_mutex, portMAX_DELAY) != pdTRUE) {
    obj["proximidad"] = 1000;  // 10 metros default
    return;
  }
  obj["proximidad"] = proximity_val;
  xSemaphoreGive(proximity_val_mutex);
}

// Obtiene todas las variables globales cuyo valor se consiguió con WiFi
void getEnv() {
  LOG("api", "req get");
  jsonDocument.clear();
  add_json_object();
  serializeJson(jsonDocument, buffer);
  server.send(200, "application/json", buffer);
}

// Envia datos (buffer) al cliente
void postAceleracion() {
  LOG("api", "req post");
  if (server.hasArg("plain") == false) {
    // handle error
    LOG("api", "error en post");
  }
  String body = server.arg("plain");
  deserializeJson(jsonPost, body);
  car_cmd_info.car_cmd = jsonPost["command"];
  car_cmd_info.x = jsonPost["x"];
  car_cmd_info.y = jsonPost["y"];
  car_cmd_apply(car_cmd_info.x, car_cmd_info.y, car_cmd_info.car_cmd);
  // Respond to the client
  server.send(200, "application/json", "{}");
}

// Establece las rutas del API
void setup_routing() {
  server.on("/env", getEnv);
  server.on("/postMovimiento", HTTP_POST, postAceleracion);
}

// Conecta el WiFi
void setup() {
  Serial.begin(921600);
  while (!Serial) {
    delay(10);
  }
  // periféricos
  setup_imu();
  setup_proximidad();
  setup_motores();

  // api
  connectToWiFi();
  setup_routing();

  // Configuración de tareas
  xTaskCreate(loop_imu, "Servicio IMU", 2048, NULL, 1, NULL);
  xTaskCreate(loop_proximidad, "Servicio Sensor Proximidad", 2048, NULL, 2,
              NULL);
  xTaskCreate(loop_api, "Servicio REST API", 2048, NULL, 1, NULL);
}

void loop_api(void *args) {
  (void)args;
  while (true) {
    server.handleClient();
    vTaskDelay(15);
  }
}

void loop() {
}
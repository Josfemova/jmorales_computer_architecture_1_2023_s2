#include <WiFi.h>
#include <ArduinoJson.h> 
#include <WebServer.h>
#include "shared.h"

const char *SSID = "zebas";
const char *PWD = "manzana1234";
WebServer server(80);
StaticJsonDocument<250> jsonDocument;
StaticJsonDocument<250> jsonPost;
char buffer[250];
unsigned int timestamp;

void connectToWiFi() {
  Serial.print("Connecting to ");
  Serial.println(SSID);
  WiFi.begin(SSID, PWD);
  
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print("Trying to connect\r\n");
    delay(500); // we can even make the ESP32 to sleep
  }
  Serial.print("Connected. IP: ");
  Serial.println(WiFi.localIP());
  server.begin();
}
 
#include "esp_cpu.h"
void add_json_object() {
  JsonObject obj = jsonDocument.createNestedObject();
  obj["timestamp"] = esp_timer_get_time();
  obj["aceleracion_x"] = imu_data.ax;
  obj["aceleracion_y"] = imu_data.ay; 
  obj["aceleracion_z"] = imu_data.az; 
  obj["orientacion_x"] = imu_data.gx;
  obj["orientacion_y"] = imu_data.gy;
  obj["orientacion_z"] = imu_data.gz; 
  obj["proximidad"] = proximity_val; 
  
}
 
// Obtiene todas las variables globales cuyo valor se consiguió con WiFi
void getEnv() {
  Serial.println("Get env");
  jsonDocument.clear();
  add_json_object();
  serializeJson(jsonDocument, buffer);
  server.send(200, "application/json", buffer);
  delay(2);
}

// Envia datos (buffer) al cliente
void postAceleracion() {
  if (server.hasArg("plain") == false) {
    //handle error here
    Serial.println("error");
  }
  String body = server.arg("plain");
  Serial.println("body");
  Serial.println(body);
  deserializeJson(jsonPost, body);

  int command= jsonPost["command"];
  Serial.println(command);
  int x= jsonPost["x"];
  Serial.println(x);
  int y= jsonPost["y"];
  Serial.println(y);

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
  while(!Serial){
    delay(10);
  }
  Serial.println("Hola desde setup");
  connectToWiFi();
  setup_routing();
}
 
void loop() {
  server.handleClient();
}
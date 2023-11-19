#include <WiFi.h>
#include <ArduinoJson.h> 
#include <WebServer.h>

const char *SSID = "FAMILIA MORALES";
const char *PWD = "japipajopri";
WebServer server(80);
StaticJsonDocument<250> jsonDocument;
char buffer[250];
float aceleracion = 1;
float orientacion = 2;
float proximidad = 3;
int timestamp = 4;
 
void connectToWiFi() {
  Serial.print("Connecting to ");
  Serial.println(SSID);
  WiFi.begin(SSID, PWD);
  
  while (WiFi.status() == WL_CONNECTED) {
    Serial.print("Conectado");
    delay(500); // we can even make the ESP32 to sleep
  }
  Serial.print("Connected. IP: ");
  Serial.println(WiFi.localIP());
  server.begin();
}
 
void create_json(char *tag, float value, char *unit) { 
  jsonDocument.clear(); 
  jsonDocument["type"] = tag;
  jsonDocument["value"] = value;
  jsonDocument["unit"] = unit;
  serializeJson(jsonDocument, buffer);
  Serial.println("Buffer:");
  Serial.println(buffer);  
}
 
void add_json_object(char *tag, float value, char *unit) {
  JsonObject obj = jsonDocument.createNestedObject();
  obj["type"] = tag;
  obj["value"] = value;
  obj["unit"] = unit; 
}
 
// Obtiene todas las variables globales cuyo valor se consiguio con WiFi
void getEnv() {
  Serial.println("Get env");
  jsonDocument.clear();
  add_json_object("Aceleracion", aceleracion, "u");
  add_json_object("Orientacion", orientacion, "u");
  add_json_object("Proximidad", proximidad, "cm");
  serializeJson(jsonDocument, buffer);
  server.send(200, "application/json", buffer);
}

// Envia datos (buffer) al cliente
void postAceleracion() {
  if (server.hasArg("plain") == false) {
    //handle error here
  }
  String body = server.arg("plain");
  Serial.println(body);
  deserializeJson(jsonDocument, body);

  float acelPost= jsonDocument["Aceleracion"];
  Serial.println(acelPost);

  // Respond to the client
  server.send(200, "application/json", "{}");
}
 
// Establece las rutas del API
void setup_routing() {
  server.on("/env", getEnv);
  server.on("/postAceleracion", HTTP_POST, postAceleracion);
}
 
 // Conecta el WiFi 
void setup() {
  Serial.begin(9600);
  Serial.println("Hola desde setup");
  connectToWiFi();
  setup_routing();
  getEnv();
  //buffer.printTo(Serial);
}
 
void loop() {
  Serial.println("Hola desde loop");
  server.handleClient();
}
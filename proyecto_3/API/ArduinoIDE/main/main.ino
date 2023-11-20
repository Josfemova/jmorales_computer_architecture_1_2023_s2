#include <WiFi.h>
#include <ArduinoJson.h> 
#include <WebServer.h>

const char *SSID = "zebas";
const char *PWD = "manzana1234";
WebServer server(80);
StaticJsonDocument<250> jsonDocument;
StaticJsonDocument<250> jsonPost;
char buffer[250];
float aceleracion = 1;
float orientacion = 2;
unsigned int timestamp;
float aceleracion_x;
float aceleracion_y;
float aceleracion_z;
float orientacion_x;
float orientacion_y;
float orientacion_z;
float proximidad;

 
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
 
 
void add_json_object() {
  JsonObject obj = jsonDocument.createNestedObject();
  obj["timestamp"] = timestamp;
  obj["aceleracion_x"] = aceleracion_x;
  obj["aceleracion_y"] = aceleracion_y; 
  obj["aceleracion_z"] = aceleracion_z; 
  obj["orientacion_x"] = orientacion_x;
  obj["orientacion_y"] = orientacion_y;
  obj["orientacion_z"] = orientacion_z; 
  obj["proximidad"] = proximidad; 
  
}
 
// Obtiene todas las variables globales cuyo valor se consiguio con WiFi
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
  Serial.println("Hola desde setup");
  connectToWiFi();
  setup_routing();
  getEnv();
  //buffer.printTo(Serial);
}
 
void loop() {
  aceleracion++;
  orientacion++;
  proximidad++;
  timestamp++;
  server.handleClient();
}
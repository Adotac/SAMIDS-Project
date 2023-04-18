#include "esp32cam_Impl.h"

extern "C"
{
#include "freertos/FreeRTOS.h"
#include "freertos/timers.h"
}
#define ASYNC_TCP_SSL_ENABLED true
#include <AsyncMQTT_ESP32.h>
String deviceNumber = String("101");
String deviceId = String(deviceNumber + "_CAM");

const char* subtopic = String("mqtt/attendance/" + deviceId).c_str(); // publish to be read by deviceCAM
const char* camtopic = String("mqtt/DEVICE/" + deviceNumber).c_str(); // publish to send device state

bool deviceFlag = false;
bool retrySend = false;

espcam_message myData;
String payloadJSON = "";

// ===================
// Select camera model
// ===================
//#define CAMERA_MODEL_WROVER_KIT // Has PSRAM
//#define CAMERA_MODEL_ESP_EYE // Has PSRAM
//#define CAMERA_MODEL_ESP32S3_EYE // Has PSRAM
//#define CAMERA_MODEL_M5STACK_PSRAM // Has PSRAM
//#define CAMERA_MODEL_M5STACK_V2_PSRAM // M5Camera version B Has PSRAM
//#define CAMERA_MODEL_M5STACK_WIDE // Has PSRAM
//#define CAMERA_MODEL_M5STACK_ESP32CAM // No PSRAM
//#define CAMERA_MODEL_M5STACK_UNITCAM // No PSRAM
// #define CAMERA_MODEL_AI_THINKER // Has PSRAM
//#define CAMERA_MODEL_TTGO_T_JOURNAL // No PSRAM
// ** Espressif Internal Boards **
#define CAMERA_MODEL_ESP32_CAM_BOARD
//#define CAMERA_MODEL_ESP32S2_CAM_BOARD
//#define CAMERA_MODEL_ESP32S3_CAM_LCD

#include "camera_pins.h"
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"

AsyncMqttClient mqttClient;
TimerHandle_t mqttReconnectTimer;
TimerHandle_t wifiReconnectTimer;

void connectToWifi(){
  Serial.print("Connecting to ");

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  delay(1000);
  Serial.println(WIFI_SSID);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }

  Serial.println("Wifi Connected!!");
}

void onWifiEvent(WiFiEvent_t event){
  Serial.printf("[WiFi-event] event: %d\n", event);
  switch(event) {
  case SYSTEM_EVENT_STA_GOT_IP:
      Serial.println("WiFi connected");
      Serial.println("IP address: ");
      Serial.println(WiFi.localIP());
      break;
  case SYSTEM_EVENT_STA_DISCONNECTED:
      Serial.println("WiFi lost connection");
      deviceFlag = false;
      // Serial.println("Camera disconnected wifi");

      espcamToJson(myData, payloadJSON, "Camera disconnected wifi", false, true, deviceFlag);
      uint16_t packetIdPubCam = mqttClient.publish(camtopic, 2, false, "test");
      Serial.print("Publishing at QoS 2, packetId: ");
      Serial.println(packetIdPubCam);
      Serial.println(myData.message);

      xTimerStop(mqttReconnectTimer, 0); // ensure we don't reconnect to MQTT while reconnecting to Wi-Fi
      xTimerStart(wifiReconnectTimer, 0);

      break;
  }
}

//-------------------------------------------------//

void connectToMqtt()
{
  Serial.println("Connecting to MQTT...");

  mqttClient.connect();
}

void onMqttConnect(bool sessionPresent)
{
  Serial.print("Connected to MQTT broker: ");
  Serial.print(MQTT_HOST);
  Serial.print(", port: ");
  Serial.println(MQTT_PORT);
  // Serial.print("PubTopics: ");
  // Serial.println(camtopic);

  printSeparationLine();
  Serial.print("Session present: ");
  Serial.println(sessionPresent);

  // sendDataPayload();

  uint16_t packetIdSub = mqttClient.subscribe(subtopic, 2);
  Serial.print("Subscribing at QoS 2, packetId: ");
  Serial.println(packetIdSub);

  printSeparationLine();
}

void onMqttDisconnect(AsyncMqttClientDisconnectReason reason)
{
  (void) reason;

  Serial.println("Disconnected from MQTT.");

  if (WiFi.isConnected())
  {
    xTimerStart(mqttReconnectTimer, 0);
  }
}

void onMqttSubscribe(const uint16_t packetId, const uint8_t qos) {
  Serial.println("Subscribe acknowledged.");
  Serial.print("  packetId: ");
  Serial.println(packetId);
  Serial.print("  qos: ");
  Serial.println(qos);
}


void onMqttUnsubscribe(const uint16_t packetId) {
  Serial.println("Unsubscribe acknowledged.");
  Serial.print("  packetId: ");
  Serial.println(packetId);
}


void onMqttMessage(char* topic, char* payload, AsyncMqttClientMessageProperties properties, const size_t len, const size_t index, const size_t total) {
  Serial.println("Publish received.");
  Serial.print("  topic: ");
  Serial.println(topic);
  Serial.print("  qos: ");
  Serial.println(properties.qos);
  Serial.print("  dup: ");
  Serial.println(properties.dup);
  Serial.print("  retain: ");
  Serial.println(properties.retain);
  Serial.print("  len: ");
  Serial.println(len);
  Serial.print("  index: ");
  Serial.println(index);
  Serial.print("  total: ");
  Serial.println(total);

  //condition recieving attendance id
}

void onMqttPublish(const uint16_t& packetId)
{
  Serial.println("Publish acknowledged.");
  Serial.print("  packetId: ");
  Serial.println(packetId);
}

//-------------------------------------------------//

//-------------------------------------------------//
void sendDataPayload(){
  camera_fb_t *fb = NULL;
  // char* payloadArray = (char*) malloc(sizeof(char));  // Allocate memory for an array of pointers
  // Serial.println("Payload Allocated....");
  // capturePhoto(payloadArray, fb);

  // client.publish(PubTopic1, 0, true, (const char*) payloadArray[0]);


  Serial.println("Publishing JSON DATA at QoS 0");
  // captureBufferPhoto(fb);
  // String encodedData = base64::encode(fb->buf, fb->len);

  // client.publish(PubTopic2, fb->buf, fb->len);
  Serial.println("Publishing Image data buffer at QoS 0");

  // free(payloadArray);
}

//-------------------------------------------------//

void setup() {
  pinMode(FLASH_GPIO_NUM, OUTPUT);
  pinMode(RED_LED, OUTPUT);
  Serial.begin(115200);
  wifi_ps_type_t(WIFI_PS_NONE);

  while (!Serial && millis() < 5000);

  Serial.print(F("\nStart WiFiMQTT on "));
  Serial.println(ARDUINO_BOARD);
  Serial.println(ASYNC_MQTT_ESP32_VERSION);

  // Serial.println("Camera init");

  uint16_t packetIdPubCam;
  
  espcamToJson(myData, payloadJSON, "Camera init", false, true, deviceFlag);
  packetIdPubCam = mqttClient.publish(camtopic, 2, false, payloadJSON.c_str());
  Serial.print("Publishing at QoS 2, packetId: ");
  Serial.println(packetIdPubCam);
  Serial.println(myData.message);

  Serial.print(F("\nStart Wifi on "));
  Serial.println(ARDUINO_BOARD);

  mqttReconnectTimer = xTimerCreate("mqttTimer", pdMS_TO_TICKS(2000), pdFALSE, (void*)0,
                                    reinterpret_cast<TimerCallbackFunction_t>(connectToMqtt));
  wifiReconnectTimer = xTimerCreate("wifiTimer", pdMS_TO_TICKS(2000), pdFALSE, (void*)0,
                                    reinterpret_cast<TimerCallbackFunction_t>(connectToWifi));

  WiFi.onEvent(onWifiEvent);

  mqttClient.onConnect(onMqttConnect);
  mqttClient.onDisconnect(onMqttDisconnect);
  mqttClient.onSubscribe(onMqttSubscribe);
  mqttClient.onUnsubscribe(onMqttUnsubscribe);
  mqttClient.onMessage(onMqttMessage);
  mqttClient.onPublish(onMqttPublish);

  mqttClient.setClientId(deviceId.c_str());

  Serial.print("Device ID: ");
  Serial.println(deviceId);

  mqttClient.setKeepAlive(500);
  mqttClient.setServer(MQTT_HOST, MQTT_PORT);

  connectToWifi();

  if(initCamera()){
    Serial.println("Camera initialized");
    
    deviceFlag = true;

    espcamToJson(myData, payloadJSON, "Camera Ready", false, true, deviceFlag);
    packetIdPubCam = mqttClient.publish(camtopic, 2, false, payloadJSON.c_str());
    Serial.print("Publishing at QoS 2, packetId: ");
    Serial.println(packetIdPubCam);

    Serial.println(myData.message);
  }
  else{
    espcamToJson(myData, payloadJSON, "Camera Failed", false, true, deviceFlag); 
    packetIdPubCam = mqttClient.publish(camtopic, 2, false, payloadJSON.c_str());
    Serial.print("Publishing at QoS 2, packetId: ");
    Serial.println(packetIdPubCam);
    Serial.println(myData.message);
    return;
  }
}


void loop() {
  static uint32_t prev_ms = millis();
  // sendHttpRequest();

  if(retrySend){
    Serial.println("Retrying to send in transit...");
    digitalWrite(RED_LED, HIGH); // Turn on the red LED
    delay(1000);                // Wait for 1 second
    digitalWrite(RED_LED, LOW);  // Turn off the red LED
    delay(1000);   
    // SendNow(espData.message, espData.attendanceFlag, espData.displayFlag, espData.deviceFlag);
  }

  if (millis() > prev_ms + 30000)
  {
    prev_ms = millis();
    Serial.println("No Message");
  }
}

void sendRequest(){
    if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    WiFiClient client;

    http.begin(client, "http://192.168.43.2:1412/connected");
    int httpCode = http.GET();

    if (httpCode > 0) {
      retrySend = true;
      String payload = http.getString();
      Serial.println("HTTP Response code: " + String(httpCode));
      Serial.println("Payload: " + payload);
    } else {
      retrySend = false;
      Serial.println("Error on HTTP request");
    }

    http.end();
  }

  delay(1000);
}


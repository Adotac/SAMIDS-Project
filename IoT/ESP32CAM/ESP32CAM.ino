#include "esp32cam_Impl.h"

extern "C"
{
#include "freertos/FreeRTOS.h"
#include "freertos/timers.h"
}
#define ASYNC_TCP_SSL_ENABLED true
#include <AsyncMQTT_ESP32.h>

// espcam_message myData;
// esprfid_message rfid_Data;


String deviceId = String("101");

String topictemp = String("mqtt/image/" + deviceId); // publish to be read by API
String topictemp2 = String("mqtt/attendance/" + deviceId); // publish to be read by deviceCAM
String subtopictemp = String("mqtt/API/response/" + deviceId); // from the API

uint8_t broadcastAddress[MACSIZE]= {MAC_ESP8266};

#if ASYNC_TCP_SSL_ENABLED
  #define MQTT_SECURE true

  const char *ImageTopic = topictemp.c_str();
  const char *AttendanceTopic = topictemp2.c_str();
  const char *SubTopic = subtopictemp.c_str();
#endif

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
  SendNow("Camera Init", false, false);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  delay(1000);
  Serial.println(WIFI_SSID);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }

  Serial.println("Wifi Connected!!");
}

void connectToMqtt()
{
  Serial.println("Connecting to MQTT...");
  SendNow("MQTT Init", false, false);
  mqttClient.connect();
}

void onWifiEvent(WiFiEvent_t event){
  Serial.printf("[WiFi-event] event: %d\n", event);
  switch(event) {
  case SYSTEM_EVENT_STA_GOT_IP:
      Serial.println("WiFi connected");
      Serial.println("IP address: ");
      Serial.println(WiFi.localIP());
      connectToMqtt();
      break;
  case SYSTEM_EVENT_STA_DISCONNECTED:
      Serial.println("WiFi lost connection");
      SendNow("Camera disconnected wifi", false, false);
      xTimerStop(mqttReconnectTimer, 0); // ensure we don't reconnect to MQTT while reconnecting to Wi-Fi
      xTimerStart(wifiReconnectTimer, 0);
      break;
  }
}

void onMqttConnect(bool sessionPresent)
{
  Serial.print("Connected to MQTT broker: ");
  Serial.print(MQTT_HOST);
  Serial.print(", port: ");
  Serial.println(MQTT_PORT);

  printSeparationLine();
  Serial.print("Session present: ");
  Serial.println(sessionPresent);

  // sendDataPayload();

  uint16_t packetIdSub = mqttClient.subscribe(SubTopic, 2);
  Serial.print("Subscribing at QoS 2, packetId: ");
  Serial.println(packetIdSub);

  uint16_t packetIdPub1 = mqttClient.publish(AttendanceTopic, 1, true, "ESP32 test sfsdf 2");
  Serial.print("Publishing at QoS 1, packetId: ");
  Serial.println(packetIdPub1);

  uint16_t packetIdPub2 = mqttClient.publish(AttendanceTopic, 2, true, "ESP32 test 3");
  Serial.print("Publishing at QoS 2, packetId: ");
  Serial.println(packetIdPub2);


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
}

void onMqttPublish(const uint16_t& packetId)
{
  Serial.println("Publish acknowledged.");
  Serial.print("  packetId: ");
  Serial.println(packetId);
}

//-------------------------------------------------//

// Callback when data is sent
void OnDataSent(const uint8_t *mac_addr, esp_now_send_status_t  sendStatus) {
  Serial.print("Last Packet Send Status: ");
  if (sendStatus == ESP_NOW_SEND_SUCCESS ){
    Serial.println("Delivery success");
  }
  else{
    Serial.println("Delivery fail");
  }
}

// Callback function executed when data is received
void OnDataRecv(const uint8_t * mac, const uint8_t *incomingData, int len) {
  esprfid_message rfid_Data;

  memcpy(&rfid_Data, incomingData, sizeof(rfid_Data));
  Serial.print("Data received: ");
  Serial.println(len);
  Serial.print("Message Value: ");
  Serial.println(rfid_Data.message);
  Serial.print("Device ready flag: ");
  Serial.println(rfid_Data.deviceFlag);

  Serial.println();

  // PUT CHECK AND CREATE ATTENDANCE ALGO HERE
  // ACCESS THE FASTAPI HTTP GET REQUEST HERE

  if(rfid_Data.deviceFlag){
    uint16_t packetIdPub1 = mqttClient.publish(AttendanceTopic, 2, true, rfid_Data.message);
    Serial.print("Publishing at QoS 2, packetId: ");
    Serial.println(packetIdPub1);
  }
}

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
  Serial.begin(115200);

  // Set ESP32 as a Wi-Fi Station
  WiFi.mode(WIFI_MODE_APSTA);
  WiFi.disconnect();
  delay(100);

  while (!Serial && millis() < 5000);

    // Initilize ESP-NOW
  if (esp_now_init() != ESP_OK) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

  esp_now_peer_info_t peerInfo;
  memcpy(peerInfo.peer_addr, broadcastAddress, 6);
  peerInfo.channel = 0;
  peerInfo.encrypt = false;
  peerInfo.ifidx = WIFI_IF_AP;

  if (esp_now_add_peer(&peerInfo) != ESP_OK) {
    Serial.println("Failed to add peer");
    return;
  }

  esp_now_register_send_cb(OnDataSent);
  esp_now_register_recv_cb(OnDataRecv);

  Serial.print(F("\nStart WiFiMQTT on "));
  Serial.println(ARDUINO_BOARD);
  Serial.println(ASYNC_MQTT_ESP32_VERSION);


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

  mqttClient.setKeepAlive(30);
  mqttClient.setServer(MQTT_HOST, MQTT_PORT);



#if ASYNC_TCP_SSL_ENABLED
  mqttClient.setSecure(MQTT_SECURE);
  if(MQTT_SECURE){
    mqttClient.setCredentials(UNAME, PASS);
  }


#endif

  connectToWifi();

  initCamera();
  SendNow("Camera ready", false, true);
}


void loop() {
  static uint32_t prev_ms = millis();


  if (millis() > prev_ms + 30000)
  {
    prev_ms = millis();
    Serial.println("No Message");
  }
  
  
}

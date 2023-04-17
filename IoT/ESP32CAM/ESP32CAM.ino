
#include "esp32cam_Impl.h"

// espcam_message myData;
// esprfid_message rfid_Data;


String deviceId = String("101");

String topictemp = String("mqtt/image/" + deviceId); // publish to be read by API
String topictemp2 = String("mqtt/attendance/" + deviceId); // publish to be read by deviceCAM
String subtopictemp = String("mqtt/API/response/" + deviceId); // from the API

uint8_t broadcastAddress[MACSIZE]= {MAC_ESP8266};

const char *ImageTopic = topictemp.c_str();
const char *AttendanceTopic = topictemp2.c_str();
const char *SubTopic = subtopictemp.c_str();

bool rfidDevice = false;
bool retrySend = false;

espcam_message espData;

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
      rfidDevice = false;
      Serial.println("Camera disconnected wifi");
      SendNow(espData, "Camera disconnected wifi", false, true, rfidDevice);

      xTimerStart(wifiReconnectTimer, 0);

      break;
  }
}

//-------------------------------------------------//

// Callback when data is sent
void OnDataSent(const uint8_t *mac_addr, esp_now_send_status_t  sendStatus) {
  Serial.print("Last Packet Send Status: ");
  if (sendStatus == ESP_NOW_SEND_SUCCESS ){
    Serial.println("Delivery success");
    retrySend = false;
  }
  else{
    Serial.println("Delivery fail");
    retrySend = true;
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
  Serial.print("Deisplay flag: ");
  Serial.println(rfid_Data.deviceFlag);

  Serial.println();

  rfidDevice = rfid_Data.deviceFlag;

  // PUT CHECK AND CREATE ATTENDANCE ALGO HERE
  // ACCESS THE FASTAPI HTTP GET REQUEST HERE
  // sendRequest();
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
  pinMode(RED_LED, OUTPUT);
  Serial.begin(115200);
  wifi_ps_type_t(WIFI_PS_NONE);

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
  memcpy(peerInfo.peer_addr, broadcastAddress, MACSIZE);
  peerInfo.channel = WIFICHANNEL;
  peerInfo.encrypt = false;
  peerInfo.ifidx = WIFI_IF_AP;

  if (esp_now_add_peer(&peerInfo) != ESP_OK) {
    Serial.println("Failed to add peer");
    return;
  }

  esp_now_register_send_cb(OnDataSent);
  esp_now_register_recv_cb(OnDataRecv);

  Serial.println("Camera init");
  SendNow(espData, "Camera Init", false, true, rfidDevice);

  Serial.print(F("\nStart Wifi on "));
  Serial.println(ARDUINO_BOARD);

  wifiReconnectTimer = xTimerCreate("wifiTimer", pdMS_TO_TICKS(2000), pdFALSE, (void*)0,
                                    reinterpret_cast<TimerCallbackFunction_t>(connectToWifi));

  WiFi.onEvent(onWifiEvent);

  Serial.print("Device ID: ");
  Serial.println(deviceId);


  connectToWifi();

  initCamera();

  rfidDevice = true;

  Serial.println("Camera ready");
  SendNow(espData, "Camera ready", false, true, rfidDevice);
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

    SendNow(espData, espData.message, espData.attendanceFlag, espData.displayFlag, espData.deviceFlag);
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
      String payload = http.getString();
      Serial.println("HTTP Response code: " + String(httpCode));
      Serial.println("Payload: " + payload);
    } else {
      Serial.println("Error on HTTP request");
    }

    http.end();
  }

  delay(1000);
}


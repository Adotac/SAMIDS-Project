#include "defines.h" // ignored by git for privacy purposes
#include "esp32cam_Impl.h"

#include <Arduino.h>
#include <MQTTPubSubClient_Generic.h>


String deviceId = String("101");
const char *PubTopic1 = String("mqtt/RFID/json/" + deviceId).c_str(); // for JSON DATA
const char *SubTopic = String("mqtt/RFID/response/" + deviceId).c_str(); // for image data buffer base64 string


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

WiFiClient client;
MQTTPubSubClient mqttClient;

int status = WL_IDLE_STATUS;  

void connectToWifi(){
  Serial.print("Connectiog to ");
 
  status = WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  delay(1000);
  Serial.println(WIFI_SSID);
  while (status != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
    // Connect to WPA/WPA2 network
    status = WiFi.status();
  }

  Serial.println("Wifi Connected!!");
  Serial.println(WIFI_WEBSERVER_VERSION);
  // print the received signal strength:
  int32_t rssi = WiFi.RSSI();
  Serial.print(F(", Signal strength (RSSI):"));
  Serial.print(rssi);
  Serial.println(F(" dBm"));
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void printSeparationLine()
{
  Serial.println("************************************************");
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message received: ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();
}

void mqttconnect() {
  Serial.print("Attempting host connection...");
  // while (!client.connect(MQTT_HOST, MQTT_PORT)) {
  while (!client.connect(MQTT_URL, MQTT_CPORT)) {
    Serial.print(".");
    delay(1000);
    
  }

  Serial.println("\nHost Connected!");

  // initialize mqtt client
  mqttClient.begin(client);
  Serial.print("Connecting to mqtt broker...");
  // while (!mqttClient.connect(deviceId.c_str(), UNAME, PASS)) {
  while (!mqttClient.connect(deviceId.c_str(), UNAME, MQTT_CPASS)) {
    Serial.print(".");
    delay(1000);
  }
  Serial.println(" connected!");

  printSeparationLine();
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

  while (!Serial && millis() < 5000);

  Serial.print(F("\nStart WiFiMQTT on "));
  Serial.print(BOARD_NAME);
  Serial.print(F(" with "));
  Serial.println(SHIELD_TYPE);
  Serial.println(WIFI_WEBSERVER_VERSION);
  Serial.println(MQTT_PUBSUB_CLIENT_GENERIC_VERSION);

#if WIFI_USING_ESP_AT

  // initialize serial for ESP module
  EspSerial.begin(115200);
  // initialize ESP module
  WiFi.init(&EspSerial);

  Serial.println(F("WiFi shield init done"));

#endif

#if !(ESP32 || ESP8266)

  // check for the presence of the shield
  #if USE_WIFI_NINA

    if (WiFi.status() == WL_NO_MODULE)
  #else
    if (WiFi.status() == WL_NO_SHIELD)
  #endif
    {
      Serial.println(F("WiFi shield not present"));

      // don't continue
      while (true);
    }

  #if USE_WIFI_NINA
    String fv = WiFi.firmwareVersion();

    if (fv < WIFI_FIRMWARE_LATEST_VERSION)
    {
      Serial.println(F("Please upgrade the firmware"));
    }

  #endif
#endif

  connectToWifi();
  delay(500);

  Serial.print("\nStarting ESP32CAM on ");
  Serial.println(ARDUINO_BOARD);

  mqttconnect();

  // subscribe callback which is called when every packet has come
  mqttClient.subscribe([](const String & topic, const String & payload, const size_t size)
  {
    (void) size;

    Serial.println("MQTT received: " + topic + " - " + payload);
  });


  // initCamera();
  // sendDataPayload();

}
void loop() {
  // mqttClient.update();  

  static uint32_t prev_ms = millis();


  if (millis() > prev_ms + 30000)
  {
    prev_ms = millis();
    Serial.println("No Message");
    // mqttClient.publish("mqtt/IDLE/test", "No Message");
  }
  
  
}

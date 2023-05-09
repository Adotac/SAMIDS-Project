#include "esp32cam_Impl.h"

#if __has_include("config.h")
#include "config.h"
#endif

const String deviceNumber = String("101");
const String deviceId = String(deviceNumber + "_CAM");

const String subtopic = String("mqtt/attendance/" + deviceNumber); // publish to be read by deviceCAM
const String camtopic = String("mqtt/DEVICE/" + deviceId); // publish to send device state

// Replace the following with your desired timezone offset (in seconds)
const int timeZoneOffsetSeconds = 8 * 60 * 60; // 8 hours (in seconds)


bool deviceFlag = false;
bool retrySend = false;

espcam_message myData;
// String payloadJSON = "";

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

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", timeZoneOffsetSeconds);

esp32cam::Resolution initialResolution;
WebServer server(80);
PicoMQTT::Client client(
    MQTT_HOST,    // broker address (or IP)
    MQTT_PORT,                   // broker port (defaults to 1883)
    deviceId.c_str()           // Client ID
);
TimerHandle_t wifiReconnectTimer;

String rfid = "";

void connectToWifi(){
  Serial.print("Connecting to ");

  WiFi.persistent(false);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  delay(1000);
  Serial.println(WIFI_SSID);
  while (WiFi.waitForConnectResult() != WL_CONNECTED) {
    Serial.println("WiFi failure");
    delay(500);
    ESP.restart();
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

      publishMessage(client, camtopic, espcamToJson(myData, "Camera disconnected wifi", false, true, deviceFlag));
      // Serial.print("Publishing at QoS 2, packetId: ");
      // Serial.println(packetIdPubCam);
      Serial.println(myData.message);

      // ensure we don't reconnect to MQTT while reconnecting to Wi-Fi
      xTimerStart(wifiReconnectTimer, 0);

      break;
  }
}

//-------------------------------------------------//

void setup() {
  pinMode(FLASH_GPIO_NUM, OUTPUT);
  pinMode(RED_LED, OUTPUT);
  Serial.begin(115200);
  WiFi.setSleep(false);
  flash(true);
  delay(10000); // wait for 10 to 15 seconds
  while (!Serial && millis() < 5000);

  Serial.print(F("\nStart WiFiMQTT "));

  // Serial.println("Camera init");

  Serial.print(F("\nStart Wifi on "));
  Serial.println(ARDUINO_BOARD);

  wifiReconnectTimer = xTimerCreate("wifiTimer", pdMS_TO_TICKS(2000), pdFALSE, (void*)0,
                                    reinterpret_cast<TimerCallbackFunction_t>(connectToWifi));

  WiFi.onEvent(onWifiEvent);
  connectToWifi();


  Serial.print("Device ID: ");
  Serial.println(deviceId);

  delay(1000);
  publishMessage(client, camtopic, espcamToJson(myData, "Mqtt connect", false, true, deviceFlag));
  Serial.println(myData.message);

    // Subscribe to a topic and attach a callback
  client.subscribe(subtopic, [](const char * topic, const char * payload) {
    // payload might be binary, but PicoMQTT guarantees that it's zero-terminated
    Serial.printf("Received message in topic '%s': %s\n", topic, payload);
    esprfid_message rfidData;

    esprfidFromJson(payload, rfidData);

    //condition recieving attendance id
    if (isAllNumbers(rfidData.message, strlen(rfidData.message)) && rfidData.deviceFlag) {
      // code camera here to send on htttp
      Serial.println("Sending Photo...");
      rfid = rfidData.message;
      sendRequest();
    } else {
      
      publishMessage(client, camtopic, espcamToJson(myData, "RFID ERROR", false, true, deviceFlag));

      Serial.println(myData.message);
    }
  });

  client.begin();
  client.loop();

  {
    using namespace esp32cam;

    initialResolution = Resolution::find(1024, 768);

    Config cfg;
    cfg.setPins(pins::AiThinker);
    cfg.setResolution(initialResolution);
    cfg.setJpeg(80);

    bool ok = Camera.begin(cfg);
    if (!ok) {
      Serial.println("camera initialize failure");
      publishMessage(client, camtopic, espcamToJson(myData, "Camera Failed", false, true, deviceFlag));
      Serial.println(myData.message);
      flash(false);

      delay(5000);
      ESP.restart();
    }
    initCamera();
    Serial.println("Camera initialized");
    
    deviceFlag = true;

    publishMessage(client, camtopic, espcamToJson(myData, "Camera Ready", false, true, deviceFlag));
    flash(false);

    Serial.println(myData.message);
  }

  Serial.println("camera starting");
  Serial.print("http://");
  Serial.println(WiFi.localIP());

  timeClient.begin();
  addRequestHandlers();
  server.begin();
}

int retCtr = 0;
void loop() {
  static uint32_t prev_ms = millis();
  timeClient.update();

  client.loop(); // important

  if(retrySend && retCtr < 3){ // retry for 3 times
    Serial.printf("Retrying %d times to send in transit...", retCtr+1);
    digitalWrite(RED_LED, HIGH); // Turn on the red LED
    delay(1000);                // Wait for 1 second
    digitalWrite(RED_LED, LOW);  // Turn off the red LED
    delay(1000);   
    sendRequest();
    publishMessage(client, camtopic, espcamToJson(myData, "Retrying...", false, true, false));
    retCtr++;
  }
  else if (retCtr > 0){
    publishMessage(client, camtopic, espcamToJson(myData, "Retrying...", false, false, true));
    retrySend = false;
    retCtr = 0;
  }

  server.handleClient();

  if (millis() > prev_ms + 30000)
  {
    prev_ms = millis();
    // Serial.println("No Message");
  }
  delay(2000);
}

void sendRequest() {
  if (WiFi.status() == WL_CONNECTED) {
    String ipAddress = WiFi.localIP().toString();
    String rfidString = rfid;
    String formattedTime = timeClient.getFormattedTime();

    DynamicJsonDocument jsonData(1024);
    jsonData["ip_address"] = ipAddress;
    jsonData["rfid_string"] = rfidString;
    jsonData["device_id"] = deviceNumber;
    jsonData["taptime"] = formattedTime;
    String jsonString;
    serializeJson(jsonData, jsonString);

    String requestUrl = "http://" + String(SERVER_IP) + ":" + String(SERVER_PORT) + "/log/attendance";

    HTTPClient http;
    WiFiClient client;
    http.begin(client, requestUrl);
    http.addHeader("Accept", "application/json");
    http.addHeader("Content-Type", "application/json");
    // http.setTimeout(20000); // Sets the timeout to 20 seconds


    flash(true);
    int httpCode = http.POST(jsonString);

    if (httpCode > 0) {
      retrySend = false;
      String payload = http.getString();
      Serial.println("HTTP Response code: " + String(httpCode));
      Serial.println("Payload: " + payload);
    } else {
      retrySend = true;
      Serial.println("HTTP Response code: " + String(httpCode));
      Serial.println("Error on HTTP request");
    }

    http.end();
    delay(300);
    flash(false);
  }
}




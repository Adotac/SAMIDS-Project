#include "defines.h" // ignored by git for privacy purposes
#include <LiquidCrystal_I2C.h>
#include <SPI.h>
#include <MFRC522.h>


#include <Arduino.h>
#include <WiFi.h>

String deviceId = String("101_RFID");
const char *PubTopic1 = String("mqtt/RFID/json/" + deviceId).c_str(); // for JSON DATA
const char *SubTopic = String("mqtt/RFID/response/" + deviceId).c_str(); // for image data buffer base64 string

extern "C"
{
#include "freertos/FreeRTOS.h"
#include "freertos/timers.h"
}
#define ASYNC_TCP_SSL_ENABLED true
#include <AsyncMQTT_ESP32.h>

String deviceId = String("101_CAM");
const char *PubTopic1 = String("mqtt/RFID/json/" + deviceId).c_str(); // for JSON DATA
const char *SubTopic = String("mqtt/RFID/response/" + deviceId).c_str(); // for image data buffer base64 string

#if ASYNC_TCP_SSL_ENABLED
  #define MQTT_SECURE true

  const char *PubTopic1 = topictemp1.c_str();
  const char *SubTopic = subtopictemp.c_str();
#endif

constexpr uint8_t RST_PIN = D3;     // Configurable, see typical pin layout above
constexpr uint8_t SS_PIN = D4;     // Configurable, see typical pin layout above

// Create instances
MFRC522 rfid(SS_PIN, RST_PIN);
LiquidCrystal_I2C lcd(0x27, 16, 2);

AsyncMqttClient mqttClient;
TimerHandle_t mqttReconnectTimer;
TimerHandle_t wifiReconnectTimer;

//-------------------------------------------------//

void sendDataPayload(){

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
  Serial.begin(9600);

  // Initialize LCD
  lcd.init();
  lcd.backlight();
  setLCD("Booting up...", 0, 0, true);
  while (!Serial && millis() < 5000);
  delay(500);

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

  connectToWifi(WIFI_SSID, WIFI_PASSWORD);

  // Initialize RFID
  SPI.begin();
  rfid.PCD_Init();

  Serial.println("ESP8226 now has started!!");
  setLCD("Device Ready!", 0, 0, true);
  delay(1000);
}

String tag;
void loop() {
  static uint32_t prev_ms = millis();

  delay(300);
  setLCD(" Face at Camera ", 0, 0, true);
  setLCD(" and Scan RFID ", 1, 1, false);
  // Display card UID on LCD
  if(!RFID_Scanner()){
    if (millis() > prev_ms + 30000)
    {
      prev_ms = millis();
      Serial.println("No Message");
      mqttClient.publish("mqtt/IDLE/test", "No Message");
    }
  }
}

bool RFID_Scanner(){
  if (!rfid.PICC_IsNewCardPresent())
      return false;

  if (rfid.PICC_ReadCardSerial()) {
    for (byte i = 0; i < rfid.uid.size; i++) {
      tag += rfid.uid.uidByte[i];
    }
    Serial.print("Sending tag: ");
    Serial.println(tag);

    if(true){ //edit condition to check after recieving JSON DATA
      setLCD(" ACCESS GRANTED ", 0, 0, true);
      setLCD(tag.c_str(), 2, 1, false);
    }

    tag = "";
    rfid.PICC_HaltA();
    rfid.PCD_StopCrypto1();

    return true;
  }

  return false;

}


void connectToWifi(){
  Serial.print("Connectiog to ");
  setLCD("Connectiog to ", 0, 0, true);
  setLCD(" Wifi ", 1, 0, true);
 
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
  while (!client.connect(MQTT_HOST, MQTT_PORT)) {
    Serial.print(".");
    delay(1000);
    
  }

  Serial.println("\nHost Connected!");

  // initialize mqtt client
  mqttClient.begin(client);
  Serial.print("Connecting to mqtt broker...");
  while (!mqttClient.connect(deviceId.c_str(), UNAME, PASS)) {
    Serial.print(".");
    delay(1000);
  }
  Serial.println(" connected!");

  printSeparationLine();
}

void setLCD(const char* tmp, int c1, int c2, bool clf){
  if(clf) lcd.clear();

  lcd.setCursor(c1, c2);
  lcd.print(tmp);
}


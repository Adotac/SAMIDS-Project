#include "defines.h" // ignored by git for privacy purposes
#include <LiquidCrystal_I2C.h>
#include <SPI.h>
#include <MFRC522.h>

#include <ESP8266WiFi.h>
#include <Ticker.h>
#include <AsyncMqtt_Generic.h>

String deviceNumber = String("101");
String deviceId = String(deviceNumber + "_RFID");

String topictemp = String("mqtt/RFID/attendance/" + deviceNumber); // publish to be read by deviceCAM
String subtopictemp = String("mqtt/API/response/" + deviceId); // from the API


#define MQTT_SECURE true

const char *PubTopic = topictemp.c_str();
const char *SubTopic = subtopictemp.c_str();


constexpr uint8_t RST_PIN = D3;     // Configurable, see typical pin layout above
constexpr uint8_t SS_PIN = D4;     // Configurable, see typical pin layout above

// Create instances
MFRC522 rfid(SS_PIN, RST_PIN);
LiquidCrystal_I2C lcd(0x27, 16, 2);

AsyncMqttClient mqttClient;
Ticker mqttReconnectTimer;

WiFiEventHandler wifiConnectHandler;
WiFiEventHandler wifiDisconnectHandler;

Ticker wifiReconnectTimer;

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
  Serial.begin(115200);

  // Initialize LCD
  lcd.init();
  lcd.backlight();
  setLCD("Booting up...", 0, 0, true);
  while (!Serial && millis() < 5000);
  delay(500);

  Serial.print("\nStarting FullyFeature_ESP8266 on ");
  Serial.println(ARDUINO_BOARD);
  Serial.println(ASYNC_MQTT_GENERIC_VERSION);

  wifiConnectHandler = WiFi.onStationModeGotIP(onWifiConnect);
  wifiDisconnectHandler = WiFi.onStationModeDisconnected(onWifiDisconnect);

  mqttClient.onConnect(onMqttConnect);
  mqttClient.onDisconnect(onMqttDisconnect);
  mqttClient.onSubscribe(onMqttSubscribe);
  mqttClient.onUnsubscribe(onMqttUnsubscribe);
  mqttClient.onMessage(onMqttMessage);
  mqttClient.onPublish(onMqttPublish);
  mqttClient.setServer(MQTT_HOST, MQTT_PORT);

  connectToWifi();

  mqttClient.setClientId(deviceId.c_str());
  Serial.print("Device ID: ");
  Serial.println(deviceId);

  mqttClient.setKeepAlive(30);

  if(MQTT_SECURE){
    mqttClient.setCredentials(UNAME, PASS);
  }

  connectToWifi();

  // Initialize RFID
  SPI.begin();
  rfid.PCD_Init();

  Serial.println("ESP8226 now has started!!");
  setLCD("Device Ready!", 0, 0, true);
  delay(2000);
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
  setLCD("Connecting to ", 0, 0, true);
  setLCD(" Wifi ", 0, 1, false);
 
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  delay(1000);
  Serial.println(WIFI_SSID);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }

  Serial.println("Wifi Connected!!");
  // Serial.println(WIFI_WEBSERVER_VERSION);
  // // print the received signal strength:
  // int32_t rssi = WiFi.RSSI();
  // Serial.print(F(", Signal strength (RSSI):"));
  // Serial.print(rssi);
  // Serial.println(F(" dBm"));
  // Serial.print("IP address: ");
  // Serial.println(WiFi.localIP());
}

void printSeparationLine()
{
  Serial.println("************************************************");
}

void connectToMqtt()
{
  Serial.println("Connecting to MQTT...");
  setLCD("Connecting to ", 0, 0, true);
  setLCD(" Server ", 0, 1, false);
  mqttClient.connect();
}

void onWifiConnect(const WiFiEventStationModeGotIP& event)
{   
  (void) event;

  Serial.print("Connected to Wi-Fi. IP address: ");
  Serial.println(WiFi.localIP());
  connectToMqtt();
}


void onWifiDisconnect(const WiFiEventStationModeDisconnected& event)
{
  (void) event;

  Serial.println("Disconnected from Wi-Fi.");
  mqttReconnectTimer.detach(); // ensure we don't reconnect to MQTT while reconnecting to Wi-Fi
  wifiReconnectTimer.once(2, connectToWifi);
}


void onMqttConnect(bool sessionPresent)
{
  Serial.print("Connected to MQTT broker: ");
  Serial.print(MQTT_HOST);
  Serial.print(", port: ");
  Serial.println(MQTT_PORT);
  Serial.print("PubTopic: ");
  Serial.println(PubTopic);

  printSeparationLine();
  Serial.print("Session present: ");
  Serial.println(sessionPresent);

  uint16_t packetIdSub = mqttClient.subscribe(PubTopic, 2);
  Serial.print("Subscribing at QoS 2, packetId: ");
  Serial.println(packetIdSub);

  mqttClient.publish(PubTopic, 0, true, "ESP8266 Test1");
  Serial.println("Publishing at QoS 0");

  uint16_t packetIdPub1 = mqttClient.publish(PubTopic, 1, true, "ESP8266 Test2");
  Serial.print("Publishing at QoS 1, packetId: ");
  Serial.println(packetIdPub1);

  uint16_t packetIdPub2 = mqttClient.publish(PubTopic, 2, true, "ESP8266 Test3");
  Serial.print("Publishing at QoS 2, packetId: ");
  Serial.println(packetIdPub2);

  printSeparationLine();
}

void onMqttDisconnect(AsyncMqttClientDisconnectReason reason)
{
  Serial.print("Free heap memory: ");
  Serial.println(ESP.getFreeHeap());

  Serial.print("Disconnected from MQTT. Reason: ");
  Serial.println(static_cast<int>(reason));

  if (WiFi.isConnected())
  {
    mqttReconnectTimer.once(2, connectToMqtt);
  }
}

void onMqttSubscribe(const uint16_t& packetId, const uint8_t& qos)
{
  Serial.println("Subscribe acknowledged.");
  Serial.print("  packetId: ");
  Serial.println(packetId);
  Serial.print("  qos: ");
  Serial.println(qos);
}

void onMqttUnsubscribe(const uint16_t& packetId)
{
  Serial.println("Unsubscribe acknowledged.");
  Serial.print("  packetId: ");
  Serial.println(packetId);
}

void onMqttMessage(char* topic, char* payload, const AsyncMqttClientMessageProperties& properties,
                   const size_t& len, const size_t& index, const size_t& total)
{
  (void) payload;

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

void setLCD(const char* tmp, int c1, int c2, bool clf){
  if(clf) lcd.clear();

  lcd.setCursor(c1, c2);
  lcd.print(tmp);
}


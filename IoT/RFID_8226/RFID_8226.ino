#include "rfid_Impl.h"

// MAC Address of responder - edit as required
uint8_t broadcastAddress[MACSIZE] = {MAC_ESP32CAM};

constexpr uint8_t RST_PIN = D3;     // Configurable, see typical pin layout above
constexpr uint8_t SS_PIN = D4;     // Configurable, see typical pin layout above

String deviceNumber = String("101");
String deviceId = String(deviceNumber + "_RFID");

String pubtopic = String("mqtt/RFID/attendance/" + deviceNumber); // publish to be read by deviceCAM
String subtopic = String("mqtt/API/response/" + deviceId); // from the API
String camtopic = String("mqtt/DEVICE/" + deviceNumber);

// Create instances
MFRC522 rfid(SS_PIN, RST_PIN);
LiquidCrystal_I2C lcd(0x27, 16, 2);

unsigned long lastTime = 0;  
unsigned long timerDelay = 2000;  // send readings timer

bool deviceFlag = false;
String tag = "";

WiFiClient espClient;
PubSubClient client(espClient);

void setup_wifi() {

  delay(10);
  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(WIFI_SSID);

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  randomSeed(micros());

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}


void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);

  String jsonPayload;
  for (int i = 0; i < length; i++) {
    jsonPayload += (char)payload[i];
  }
  Serial.print(jsonPayload);
  Serial.print("] ");

  Serial.println();

  espcam_message receivedData;
  espcamFromJson(jsonPayload, receivedData);

  deviceFlag = receivedData.deviceFlag;

  if(receivedData.attendanceFlag){
    //display shet
    setLCD("Attendance", 0, 0, true);
    setLCD("Recorded", 0, 1, false);
  }

  // // Switch on the LED if an 1 was received as first character
  // if ((char)payload[0] == '1') {
  //   digitalWrite(BUILTIN_LED, LOW);   // Turn the LED on (Note that LOW is the voltage level
  //   // but actually the LED is on; this is because
  //   // it is active low on the ESP-01)
  // } else {
  //   digitalWrite(BUILTIN_LED, HIGH);  // Turn the LED off by making the voltage HIGH
  // }

}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Create a random client ID
    // Attempt to connect
    if (client.connect(deviceId.c_str())) {
      Serial.println("connected");
      // Once connected, publish an announcement...
      client.publish("mqtt/IDLE/connect", deviceNumber.c_str());
      // ... and resubscribe
      client.subscribe(camtopic.c_str());
      client.subscribe(subtopic.c_str());
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void setup() {
  Serial.begin(115200);

  // Initialize LCD
  lcd.init();
  lcd.backlight();
  setLCD("Booting up...", 0, 0, true);

  setup_wifi(); 
  while (!Serial && millis() < 5000);
  client.setServer(MQTT_HOST, MQTT_PORT);
  client.setCallback(callback);
  client.setKeepAlive(500);

  // Initialize RFID
  SPI.begin();
  rfid.PCD_Init();

  Serial.println("ESP8226 now has started!!");
  setLCD("Device Ready!", 0, 0, true);

  delay(1000);
}

void loop() {
  if (!client.connected()) {
    setLCD("Connecting to", 0, 0, true);
    setLCD(" MQTT Broker ", 0, 1, false);
    reconnect();
  }
  client.loop();

  if(deviceFlag){
    delay(350);
    setLCD(" Face at Camera ", 0, 0, true);
    setLCD(" and Scan RFID ", 1, 1, false);
    
    // Display card UID on LCD
    if(!RFID_Scanner()){
      if((millis() - lastTime) > timerDelay)
      {
        Serial.println("No Message");
      }
    }
    else{
      // SendNow(tag.c_str(), camDevice);
      client.publish(pubtopic.c_str(), tag.c_str());
    }

    tag = "";
    rfid.PICC_HaltA();
    rfid.PCD_StopCrypto1();

  }
  else{
    setLCD("Synchronizing...", 0, 0, true);
    delay(1000);
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


    return true;
  }

  return false;

}

void setLCD(const char* tmp, int c1, int c2, bool clf){
  if(clf) lcd.clear();

  lcd.setCursor(c1, c2);
  lcd.print(tmp);
}



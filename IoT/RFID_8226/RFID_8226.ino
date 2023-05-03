#include "rfid_Impl.h"

#if __has_include("config.h")
#include "config.h"
#endif

// MAC Address of responder - edit as required
uint8_t broadcastAddress[MACSIZE] = {MAC_ESP32CAM};

constexpr uint8_t RST_PIN = D3;     // Configurable, see typical pin layout above
constexpr uint8_t SS_PIN = D4;     // Configurable, see typical pin layout above

String deviceNumber = String("101");
String deviceId = String(deviceNumber + "_RFID");

String pubtopic = String("mqtt/attendance/" + deviceNumber); // publish to be read by deviceCAM
String subtopic = String("mqtt/API/response/" + deviceId); // from the API
String camtopic = String("mqtt/DEVICE/" + deviceNumber + "_CAM");

// Create instances
MFRC522 rfid(SS_PIN, RST_PIN);
LiquidCrystal_I2C lcd(0x27, 16, 2);

unsigned long lastTime = 0;  
unsigned long timerDelay = 2000;  // send readings timer

bool deviceFlag = false;
bool retrySend = false;
bool scanFlag = false;

esprfid_message myData;
String tag = "";

PicoMQTT::Client client(
    MQTT_HOST,    // broker address (or IP)
    MQTT_PORT,                   // broker port (defaults to 1883)
    deviceId.c_str()           // Client ID
);

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

void setup() {
  Serial.begin(115200);

  // Initialize LCD
  lcd.init();
  lcd.backlight();
  setLCD("Booting up...", 0, 0, true);

  setup_wifi(); 
  while (!Serial && millis() < 5000);

   // Subscribe to a topic and attach a callback
  client.subscribe(camtopic, [](const char * topic, const char * payload) {
    // payload might be binary, but PicoMQTT guarantees that it's zero-terminated
    Serial.printf("Received message in topic '%s': %s\n", topic, payload);
    espcam_message camData;

    espcamFromJson(payload, camData);

    deviceFlag = camData.deviceFlag;

    if(camData.displayFlag){
      if(strlen(camData.message) < (MSG_SIZE/2)){
        String iString(camData.message);
        setLCD(iString.substring(0, MSG_SIZE/2).c_str(), 0, 0, true);
        setLCD(iString.substring(MSG_SIZE/2).c_str(), 0, 1, false);
      }
      else{
        setLCD(camData.message, 0, 0, true);
      }
    }
    delay(5000);

  });

  client.subscribe(subtopic, [](const char * topic, const char * payload) {
    // payload might be binary, but PicoMQTT guarantees that it's zero-terminated
    Serial.printf("Received message in topic '%s': %s\n", topic, payload);
    server_message serverData;

    serverFromJson(payload, serverData);
    Serial.println(serverData.message);

    char* token = strtok(serverData.message, " ");
    char* tokens[2];

    int tokctr = 0;
    
    while (token != NULL && tokctr < 2) {
      // Print the current token (substring)
      Serial.println(token);
      tokens[tokctr] = token;
      tokctr++;
      // Get the next token
      token = strtok(NULL, " ");
    }

    if(serverData.displayFlag){
      setLCD(tokens[0], 0, 0, true);
      setLCD(tokens[1], 0, 1, false);
    }
    // else{
    //   setLCD("Attendance", 0, 0, true);
    //   setLCD("Failed!", 0, 1, false);
    // }

    delay(3000);
    scanFlag = false;
  });

  // Initialize RFID
  SPI.begin();
  rfid.PCD_Init();

  Serial.println("ESP8226 now has started!!");
  setLCD("Device Ready!", 0, 0, true);
  delay(4000);

  setLCD("Connecting to", 0, 0, true);
  setLCD(" MQTT Broker ", 0, 1, false);
  client.begin();

  delay(2000);
}

void loop() {

  client.loop();

  if(scanFlag && (millis() - lastTime) > timerDelay){ // 10 seconds
    lastTime = millis();
    scanFlag = false;
  }

  if(deviceFlag){
    delay(350);

    if(!scanFlag){
      setLCD(" Face at Camera ", 0, 0, true);
      setLCD(" and Scan RFID ", 1, 1, false);
    }
    
    
    // Display card UID on LCD
    if(!RFID_Scanner()){
      if((millis() - lastTime) > timerDelay)
      {
        lastTime = millis();
        Serial.println("No Message");
      }
    }
    else{
      publishMessage(client, pubtopic, esprfidToJson(myData, tag.c_str(), deviceFlag));
      scanFlag = true;
      setLCD(" Veryfying in ", 0, 0, true);
      setLCD(" process... ", 1, 1, false);
      // delay(3000);
    }

    tag.clear();
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



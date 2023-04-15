#include "rfid_Impl.h"

// MAC Address of responder - edit as required
uint8_t broadcastAddress[MACSIZE] = {MAC_ESP32CAM};

constexpr uint8_t RST_PIN = D3;     // Configurable, see typical pin layout above
constexpr uint8_t SS_PIN = D4;     // Configurable, see typical pin layout above

// Create instances
MFRC522 rfid(SS_PIN, RST_PIN);
LiquidCrystal_I2C lcd(0x27, 16, 2);

unsigned long lastTime = 0;  
unsigned long timerDelay = 2000;  // send readings timer

bool camDevice = false;

// Callback when data is sent
void OnDataSent(uint8_t *mac_addr, uint8_t sendStatus) {
  Serial.print("Last Packet Send Status: ");
  if (sendStatus == 0){
    Serial.println("Delivery success");
  }
  else{
    Serial.println("Delivery fail");
  }
}

// Callback function executed when data is received
void OnDataRecv(uint8_t * mac, uint8_t *incomingData, uint8_t len) {
  espcam_message cam_data;

  memcpy(&cam_data, incomingData, sizeof(cam_data));
  Serial.print("Data received: ");
  Serial.println(len);
  Serial.print("Message Value: ");
  Serial.println(cam_data.message);
  Serial.print("Attendance flag: ");
  Serial.println(cam_data.attendanceFlag);
  Serial.print("Device ready flag: ");
  Serial.println(cam_data.deviceFlag);

  camDevice = cam_data.deviceFlag;
  // After recieve put some logic on circuit to visualize result

  if(!cam_data.deviceFlag){
    setLCD("Booting up...", 0, 0, true);
  }

}
 
String tag = "";

void setup() {
  Serial.begin(115200);

  // Initialize LCD
  lcd.init();
  lcd.backlight();
  setLCD("Booting up...", 0, 0, true);

  // Set device as a Wi-Fi Station
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();

  while (!Serial && millis() < 5000);
  delay(500);

  // Init ESP-NOW
  if (esp_now_init() != 0) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

  // Once ESPNow is successfully Init, we will register for Send CB to
  // get the status of Trasnmitted packet
  esp_now_set_self_role(ESP_NOW_ROLE_COMBO);
  esp_now_add_peer(broadcastAddress, ESP_NOW_ROLE_COMBO, 1, NULL, 0);

  esp_now_register_send_cb(OnDataSent);
  esp_now_register_recv_cb(OnDataRecv);



  // Initialize RFID
  SPI.begin();
  rfid.PCD_Init();

  Serial.println("ESP8226 now has started!!");
  setLCD("Device Ready!", 0, 0, true);
  delay(2000);
}

void loop() {
  delay(300);
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
    SendNow(tag.c_str(), true);
  }

  tag = "";
  rfid.PICC_HaltA();
  rfid.PCD_StopCrypto1();

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
    return true;
  }

  return false;

}

void setLCD(const char* tmp, int c1, int c2, bool clf){
  if(clf) lcd.clear();

  lcd.setCursor(c1, c2);
  lcd.print(tmp);
}



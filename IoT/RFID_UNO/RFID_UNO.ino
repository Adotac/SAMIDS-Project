#include <Wire.h>
#include <SPI.h>
#include <MFRC522.h>
#include <LiquidCrystal_I2C.h>

LiquidCrystal_I2C lcd(0x27, 16, 2);
#define SS_PIN 10
#define RST_PIN 9

MFRC522 rfid(SS_PIN, RST_PIN);

String tag;
String rfid_access;

// this sample code provided by www.programmingboss.com
void setup() {
  Serial.begin(9600);

  SPI.begin(); // Init SPI bus
  rfid.PCD_Init(); // Init MFRC522

  lcd.init();
  lcd.backlight();
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(" Scan Your RFID ");
}

void loop() {
  rfid_access = "false";
  delay(300);
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(" Face at Camera ");
  lcd.setCursor(1, 1);
  lcd.print(" and Scan RFID ");

  if (Serial.available() > 0) {
    rfid_access = Serial.readStringUntil('\n');
    
  }

  RFID_Scanner();
}

void RFID_Scanner(){
  if ( ! rfid.PICC_IsNewCardPresent())
      return;

  if (rfid.PICC_ReadCardSerial()) {
    for (byte i = 0; i < 4; i++) {
      tag += rfid.uid.uidByte[i];
    }
    Serial.println(tag);

    if(rfid_access){
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print(" ACCESS GRANTED ");
      lcd.setCursor(2, 1);
      lcd.print(tag);
    }
    

    tag = "";
    rfid.PICC_HaltA();
    rfid.PCD_StopCrypto1();

    delay(1500);
  }
}

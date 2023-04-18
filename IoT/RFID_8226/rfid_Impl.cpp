#include "rfid_Impl.h"

void printSeparationLine()
{
  Serial.println("************************************************");
}

void esprfidToJson(const esprfid_message& data, String& json) {
  StaticJsonDocument<64> doc;

  doc["message"] = data.message;
  doc["deviceFlag"] = data.deviceFlag;

  serializeJson(doc, json);
}

void espcamFromJson(const String& json, espcam_message& data) {
  StaticJsonDocument<128> doc;

  deserializeJson(doc, json);

  strlcpy(data.message, doc["message"] | "", sizeof(data.message));
  data.attendanceFlag = doc["attendanceFlag"] | false;
  data.displayFlag = doc["displayFlag"] | false;
  data.deviceFlag = doc["deviceFlag"] | false;
}

void printBroadcastAddress() {
  Serial.print("Broadcast address: ");
  for (int i = 0; i < 6; i++) {
    Serial.print(broadcastAddress[i], HEX);
    if (i < 6 - 1) {
      Serial.print(":");
    }
  }
  Serial.println();
}

#include "rfid_Impl.h"

void printSeparationLine()
{
  Serial.println("************************************************");
}

//-----------------------FOR ESP NOW FUNCTIONALITIES--------------------------------//

// Send message via ESP-NOW
void SendNow(const char* msg, bool df){
  esprfid_message myData;

  strcpy(myData.message, msg);
  myData.deviceFlag = df;

printBroadcastAddress();
  esp_now_send(broadcastAddress, (uint8_t *) &myData, sizeof(myData));
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

#include "defines.h" // ignored by git for privacy purposes
#include "mac_addresses.h" 
#include <LiquidCrystal_I2C.h>
#include <SPI.h>
#include <MFRC522.h>

#include <ESP8266WiFi.h>
#include <espnow.h>

#ifndef esp32cam_Impl_h

#define MACSIZE 6

extern uint8_t broadcastAddress[6];

typedef struct ESPCAM_MESSAGE {
  char message[32];
  bool attendanceFlag;
  bool deviceFlag;
} espcam_message;

typedef struct ESPRFID_MESSAGE {
  char message[32];
  bool deviceFlag;
} esprfid_message;

void printSeparationLine();

void SendNow(const char* msg, bool df);
void printBroadcastAddress();

#endif
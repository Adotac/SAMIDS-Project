#include "defines.h" // ignored by git for privacy purposes
#include "mac_addresses.h" 
#include <LiquidCrystal_I2C.h>
#include <SPI.h>
#include <MFRC522.h>

#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

#include <Arduino.h>
#include <cstring>

#ifndef esp32cam_Impl_h

#define MACSIZE 6
#define MSG_SIZE 32

#define WIFICHANNEL 0

extern uint8_t broadcastAddress[MACSIZE];

typedef struct ESPCAM_MESSAGE {
  char message[MSG_SIZE];
  bool attendanceFlag;
  bool deviceFlag;
  bool displayFlag;
} espcam_message;

typedef struct ESPRFID_MESSAGE {
  char message[32];
  bool deviceFlag;
} esprfid_message;

void printSeparationLine();

void esprfidToJson(const esprfid_message& data, String& json);
void espcamFromJson(const String& json, espcam_message& data);
void printBroadcastAddress();

#endif
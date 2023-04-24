#include "rfid_Impl.h"

void printSeparationLine()
{
  Serial.println("************************************************");
}

JsonVariant esprfidToJson(esprfid_message& data, const char* msg, bool device) {
  DynamicJsonDocument* dynamicDoc = new DynamicJsonDocument(256);

  strlcpy(data.message, msg, sizeof(data.message));
  data.deviceFlag = device;

  (*dynamicDoc)["message"] = data.message;
  (*dynamicDoc)["deviceFlag"] = data.deviceFlag;

  return dynamicDoc->as<JsonVariant>();
}

void espcamFromJson(const char* json, espcam_message& data) {
  StaticJsonDocument<1028> doc;

  deserializeJson(doc, json);

  strlcpy(data.message, doc["message"] | "", sizeof(data.message));
  data.attendanceFlag = doc["attendanceFlag"] | false;
  data.displayFlag = doc["displayFlag"] | false;
  data.deviceFlag = doc["deviceFlag"] | false;

  serializeJson(doc, Serial);
  Serial.println();

  doc.clear();
}

void publishMessage(PicoMQTT::Client& mqttClient, String topic, const JsonVariant& jsonVariant) {
  printSeparationLine();
  // String messageBuffer;
  DynamicJsonDocument  doc(1024);
  JsonObject obj = doc.to<JsonObject>();
  obj = jsonVariant.as<JsonObject>(); // Copy the contents of the JsonObject from JsonVariant

  auto publish = mqttClient.begin_publish(topic, measureJson(obj) );

  serializeJson(obj , publish);

  serializeJson(obj, Serial);
  Serial.println();

  while( !(publish.send() > 0) ){
    Serial.println("Publish failed, retrying...");
    
    delay(2000);
  }

  Serial.println("Publish success!");

  doc.clear();
  printSeparationLine();
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

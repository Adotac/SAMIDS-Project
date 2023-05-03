#include <stdint.h>
#include "esp32cam_Impl.h"

void initCamera()
{
  // Turn-off the 'brownout detector'
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);

  // OV2640 camera module
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.frame_size = FRAMESIZE_UXGA;
  config.pixel_format = PIXFORMAT_JPEG; // for streaming
  //config.pixel_format = PIXFORMAT_RGB565; // for face detection/recognition
  config.grab_mode = CAMERA_GRAB_WHEN_EMPTY;
  config.fb_location = CAMERA_FB_IN_PSRAM;
  config.jpeg_quality = 12;
  config.fb_count = 1;

  sensor_t * s = esp_camera_sensor_get();
  // initial sensors are flipped vertically and colors are a bit saturated
  
  s->set_vflip(s, 1); // flip it back
  s->set_hmirror(s, 0);
  s->set_brightness(s, 1); // up the brightness just a bit
  s->set_saturation(s, 1); // lower the saturation


}

void flash(bool on)
{
  // initialize digital pin ledPin as an output
  pinMode(FLASH_GPIO_NUM, OUTPUT);

  if(on){
    digitalWrite(FLASH_GPIO_NUM, HIGH);
  }
  else{
    digitalWrite(FLASH_GPIO_NUM, LOW);
  }
}

void printSeparationLine()
{
  Serial.println("************************************************");
}

void createJsonDoc(DynamicJsonDocument& doc, const char* msg, bool af, bool df, bool device, const String& image_data) {
  doc["message"] = msg;
  doc["attendanceFlag"] = af;
  doc["displayFlag"] = df;
  doc["deviceFlag"] = device;
  doc["encoded_image"] = image_data;
}


JsonVariant espcamToJson(espcam_message& data, const char* msg, bool af, bool df, bool device){
  DynamicJsonDocument* dynamicDoc = new DynamicJsonDocument(256);

  strlcpy(data.message, msg, sizeof(data.message));
  data.attendanceFlag = af;
  data.displayFlag = df;
  data.deviceFlag = device;

  (*dynamicDoc)["message"] = data.message;
  (*dynamicDoc)["attendanceFlag"] = data.attendanceFlag;
  (*dynamicDoc)["displayFlag"] = data.displayFlag;
  (*dynamicDoc)["deviceFlag"] = data.deviceFlag;

  return dynamicDoc->as<JsonVariant>();
}

void esprfidFromJson(const String& json, esprfid_message& data) {
  StaticJsonDocument<64> doc;

  deserializeJson(doc, json);

  strlcpy(data.message, doc["message"] | "", sizeof(data.message));
  data.deviceFlag = doc["deviceFlag"] | false;

  doc.clear();
}

bool isAllNumbers(const char* arr, int arrLength) {
  for (int i = 0; i < arrLength; i++) {
    if (!isdigit(arr[i])) {
      return false;
    }
  }
  return true;
}

void publishMessage(PicoMQTT::Client& mqttClient, String topic, const JsonVariant& jsonVariant) {
  printSeparationLine();
  DynamicJsonDocument  doc(1024);
  JsonObject obj = doc.to<JsonObject>();
  obj = jsonVariant.as<JsonObject>(); // Copy the contents of the JsonObject from JsonVariant

  auto publish = mqttClient.begin_publish(topic, measureJson(obj) );

  serializeJson(obj , publish);
  // serializeJson(jsonMessage, messageBuffer);

  serializeJson(obj, Serial);
  Serial.println();

  // Serial.println(publish.send());
  // Serial.println(publish);
  while( !(publish.send() > 0) ){
    Serial.println("Publish failed, retrying...");
    
    delay(2000);
  }

  Serial.println("Publish success!");

  doc.clear();
  printSeparationLine();
  
}


String base64_image() {
  camera_fb_t *fb = NULL;
  flash(true);
  fb = esp_camera_fb_get();
  delay(300);
  flash(false);
  if (!fb) {
    Serial.println("Camera capture failed");
    return "";
  }

  String encoded = "";
  unsigned char *input = (unsigned char *)fb->buf;
  int inputLen = fb->len;

  char b64_alphabet[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

  int i = 0;
  int j = 0;
  int enc_len = 0;
  unsigned char array_3[3];
  unsigned char array_4[4];

  while (inputLen--) {
    array_3[i++] = *(input++);
    if (i == 3) {
      array_4[0] = (array_3[0] & 0xfc) >> 2;
      array_4[1] = ((array_3[0] & 0x03) << 4) + ((array_3[1] & 0xf0) >> 4);
      array_4[2] = ((array_3[1] & 0x0f) << 2) + ((array_3[2] & 0xc0) >> 6);
      array_4[3] = array_3[2] & 0x3f;

      for (i = 0; i < 4; i++) {
        encoded += b64_alphabet[array_4[i]];
      }

      i = 0;
    }
  }

  if (i) {
    for (j = i; j < 3; j++) {
      array_3[j] = '\0';
    }

    array_4[0] = (array_3[0] & 0xfc) >> 2;
    array_4[1] = ((array_3[0] & 0x03) << 4) + ((array_3[1] & 0xf0) >> 4);
    array_4[2] = ((array_3[1] & 0x0f) << 2) + ((array_3[2] & 0xc0) >> 6);
    array_4[3] = array_3[2] & 0x3f;

    for (j = 0; j < i + 1; j++) {
      encoded += b64_alphabet[array_4[j]];
    }

    while (i++ < 3) {
      encoded += '=';
    }
  }

  esp_camera_fb_return(fb);

  return encoded;
}


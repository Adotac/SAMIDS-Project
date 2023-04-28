#include <stdint.h>
#include "esp32cam_Impl.h"

bool initCamera()
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
  config.pixel_format = PIXFORMAT_JPEG;

  config.grab_mode = CAMERA_GRAB_WHEN_EMPTY;
  config.fb_location = CAMERA_FB_IN_PSRAM;
  config.jpeg_quality = 12;
  config.fb_count = 1;

  if (psramFound())
  {
    Serial.println("paramFound | FRAMESIZE medium");
    // config.frame_size = FRAMESIZE_UXGA; //largest resolution
    config.frame_size = FRAMESIZE_VGA; //(640x480)
    config.jpeg_quality = 10;
    config.fb_count = 2;
  }
  else
  {
    Serial.println("paramFound failed | FRAMESIZE low");
    // config.frame_size = FRAMESIZE_SVGA; //(800x600)
    config.frame_size = FRAMESIZE_QVGA; //(320x240)
    config.jpeg_quality = 12;
    config.fb_count = 1;
    config.fb_location = CAMERA_FB_IN_DRAM;
  }
  // Camera init
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK)
  {
    Serial.printf("Camera init failed with error 0x%x", err);
    ESP.restart();
    return false;
  }
  return true;
}

// const size_t CAPACITY = 512;
// // const int IMGSIZE = fb->width * fb->height * 3;
// StaticJsonDocument<CAPACITY> doc;

// String JsonData(camera_fb_t *fb, bool flag, long id ){  
//   String temp = String("");
//   JsonObject obj = doc.to<JsonObject>();

//   obj["_Success"] = flag;
//   obj["_Id"]=id;

//   JsonObject cam  = obj.createNestedObject("_Img");

//   // cam["Buffer"] = (char*)result;
//   if(fb){
//     cam["Length"] = fb->len;
//     cam["Width"] = fb->width;
//     cam["Height"] = fb->height;
//     cam["Pixelformat"] = (int)fb->format;
//   }
//   else{
//     Serial.println("Camera capture failed!!!!!!!"); 
//   }

//   serializeJson(obj, temp);
//   doc.clear();
//   return temp;
// }

// // Capture Photo
// const char* capturePhoto(camera_fb_t*& imagedata)
// {
//   String temp = "";
//   imagedata = esp_camera_fb_get();
//   if(imagedata){
//     Serial.println("Image captured now in process....");
//   }
//   else{
//     Serial.println("Camera failed to initialize....");
//     return temp.c_str();
//   }

//   // const char* myStrings = JsonData(imagedata, true, 187255239165).c_str();

//   Serial.println("JSON Data generated");

//   // char result[BASE64::encodeLength(imagedata->len)];
//   // BASE64::encode(imagedata->buf, imagedata->len, result);
//   // // Serial.println(result);
//   // Serial.print("Image length: ");
//   // Serial.println(strlen(result));

//   // myStrings[1] = (char*) malloc(strlen(result) * sizeof(char));
//   // strcpy(myStrings[1], result);

  
//   Serial.println("Image data buffer ready to send");
//   esp_camera_fb_return(imagedata);
//   imagedata = NULL;

//   doc.clear();
//   return temp.c_str();
// }

// // Capture Photo
// uint8_t * captureBufferPhoto(camera_fb_t*& imagedata)
// {
  
//   imagedata = esp_camera_fb_get();
//   if(imagedata){
//     Serial.println("Image captured now in process....");
//   }
//   else{
//     Serial.println("Camera failed to initialize....");
//     return NULL;
//   }
  
//   Serial.println("Image data buffer ready to send");

//   uint8_t * temp = imagedata->buf;
//   esp_camera_fb_return(imagedata);
//   return temp;
// }

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

void espcamToJson(const espcam_message& data, String& json) {
  StaticJsonDocument<128> doc;

  doc["message"] = data.message;
  doc["attendanceFlag"] = data.attendanceFlag;
  doc["displayFlag"] = data.displayFlag;
  doc["deviceFlag"] = data.deviceFlag;

  serializeJson(doc, json);

  doc.clear();
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


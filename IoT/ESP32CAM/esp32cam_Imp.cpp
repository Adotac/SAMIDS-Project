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
  config.pixel_format = PIXFORMAT_JPEG;

  if (psramFound())
  {
    // config.frame_size = FRAMESIZE_UXGA; //largest resolution
    config.frame_size = FRAMESIZE_VGA; //(640x480)
    config.jpeg_quality = 10;
    config.fb_count = 2;
  }
  else
  {
    // config.frame_size = FRAMESIZE_SVGA; //(800x600)
    config.frame_size = FRAMESIZE_QVGA; //(320x240)
    config.jpeg_quality = 12;
    config.fb_count = 1;
  }
  // Camera init
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK)
  {
    Serial.printf("Camera init failed with error 0x%x", err);
    ESP.restart();
  }
}

const size_t CAPACITY = 2048;
// const int IMGSIZE = fb->width * fb->height * 3;
StaticJsonDocument<CAPACITY> doc;

String JsonData(camera_fb_t *fb, bool flag, long id ){  
  String temp = String("");
  JsonObject obj = doc.to<JsonObject>();

  obj["_Success"] = flag;
  obj["_Id"]=id;

  JsonObject cam  = obj.createNestedObject("_Img");

  // cam["Buffer"] = (char*)result;
  if(fb){
    cam["Length"] = fb->len;
    cam["Width"] = fb->width;
    cam["Height"] = fb->height;
    cam["Pixelformat"] = (int)fb->format;
  }
  else{
    Serial.println("Camera capture failed!!!!!!!"); 
  }

  serializeJson(obj, temp);
  doc.clear();
  return temp;
}

// Capture Photo
const char* capturePhoto(camera_fb_t*& imagedata)
{
  String temp = "";
  imagedata = esp_camera_fb_get();
  if(imagedata){
    Serial.println("Image captured now in process....");
  }
  else{
    Serial.println("Camera failed to initialize....");
    return temp.c_str();
  }

  // const char* myStrings = JsonData(imagedata, true, 187255239165).c_str();

  Serial.println("JSON Data generated");

  // char result[BASE64::encodeLength(imagedata->len)];
  // BASE64::encode(imagedata->buf, imagedata->len, result);
  // // Serial.println(result);
  // Serial.print("Image length: ");
  // Serial.println(strlen(result));

  // myStrings[1] = (char*) malloc(strlen(result) * sizeof(char));
  // strcpy(myStrings[1], result);

  
  Serial.println("Image data buffer ready to send");
  esp_camera_fb_return(imagedata);
  imagedata = NULL;

  doc.clear();
  return temp.c_str();
}

// Capture Photo
uint8_t * captureBufferPhoto(camera_fb_t*& imagedata)
{
  
  imagedata = esp_camera_fb_get();
  if(imagedata){
    Serial.println("Image captured now in process....");
  }
  else{
    Serial.println("Camera failed to initialize....");
    return NULL;
  }
  
  Serial.println("Image data buffer ready to send");

  uint8_t * temp = imagedata->buf;
  esp_camera_fb_return(imagedata);
  return temp;
}

// void bufferDivider(uint8_t* buf, int len, uint8_t**& arr){
//   int arr_size = 20;
//   int buf_size = len/arr_size;

//   for (int i = 0, l = len, bi = 0; i < arr_size; i++) {
//     if(buf_size < l){
//       arr[i] = (char*) malloc(buf_size * sizeof(char));  // Allocate memory for each string
//       l -= buff_size;
      

//     }
//     else{
//       arr[i] = (char*) malloc(l * sizeof(char));  // Allocate memory for each string for the last buffer batch
//       break;
//     }

    
//   }

// }

void flash(int n)
{
  // initialize digital pin ledPin as an output
  pinMode(FLASH_GPIO_NUM, OUTPUT);

  digitalWrite(FLASH_GPIO_NUM, HIGH);
  delay(n * 1000);
  digitalWrite(FLASH_GPIO_NUM, LOW);
  delay(n * 1000);
}


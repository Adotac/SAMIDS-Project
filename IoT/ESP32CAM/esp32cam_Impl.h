#include <ArduinoJson.h>
#include "base64.hpp"
// #include "base64.h"

#include "defines.h" // ignored by git for privacy purposes
#include "mac_addresses.h" 

#include <WiFi.h>
#include <esp_now.h>

#include "esp_camera.h"
#include "esp_timer.h"

#include "Arduino.h"
#include "soc/soc.h" // Disable brownout problems
#include "soc/rtc_cntl_reg.h" // Disable brownout problems
#include "driver/rtc_io.h"



#ifndef esp32cam_Impl_h

// OV2640 camera module pins (CAMERA_MODEL_AI_THINKER)
#define PWDN_GPIO_NUM 32
#define RESET_GPIO_NUM -1
#define XCLK_GPIO_NUM 0
#define SIOD_GPIO_NUM 26
#define SIOC_GPIO_NUM 27
#define Y9_GPIO_NUM 35
#define Y8_GPIO_NUM 34
#define Y7_GPIO_NUM 39
#define Y6_GPIO_NUM 36
#define Y5_GPIO_NUM 21
#define Y4_GPIO_NUM 19
#define Y3_GPIO_NUM 18
#define Y2_GPIO_NUM 5
#define VSYNC_GPIO_NUM 25
#define HREF_GPIO_NUM 23
#define PCLK_GPIO_NUM 22
#define FLASH_GPIO_NUM 4

// ledPin refers to ESP32-CAM GPIO 4 (flashlight)
#define FLASH_GPIO_NUM 4

#define MACSIZE 6
extern uint8_t broadcastAddress[MACSIZE];

// Define a data structure
typedef struct ESPCAM_MESSAGE {
  char message[32];
  bool attendanceFlag;
  bool deviceFlag;
} espcam_message;

typedef struct ESPRFID_MESSAGE {
  char message[32];
  bool deviceFlag;
} esprfid_message;

void initCamera();
String JsonData(camera_fb_t *fb, bool flag, long id);
const char* capturePhoto(camera_fb_t*& fb);
uint8_t * captureBufferPhoto(camera_fb_t*& imagedata);
void flash(int n);
void printSeparationLine();

void OnDataSent(const uint8_t *mac_addr, esp_now_send_status_t  sendStatus);
void OnDataRecv(const uint8_t * mac, const uint8_t *incomingData, int len);
void SendNow(const char* msg, bool atf, bool df);
#endif
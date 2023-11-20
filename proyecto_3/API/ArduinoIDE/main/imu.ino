
#include "SPI.h"
#include "driver/gpio.h"
#include "mpu9250.h"
#include "shared.h"

bfs::Mpu9250 imu(&SPI, SS);
imu_data_t imu_data = {};
typedef enum { READ,
               REQUEST } imu_state_t;
imu_state_t imu_state;
SemaphoreHandle_t imu_data_mutex = NULL;

void isr_mpu() {
  if (xSemaphoreTakeFromISR(imu_data_mutex, NULL) == pdTRUE) {
    if ((imu_state == REQUEST) && imu.Read() && imu.new_imu_data()) {
      imu_data.ax = imu.accel_x_mps2();
      imu_data.ay = imu.accel_y_mps2();
      imu_data.az = imu.accel_z_mps2();
      imu_data.gx = imu.gyro_x_radps();
      imu_data.gy = imu.gyro_y_radps();
      imu_data.gz = imu.gyro_z_radps();
      imu_state = READ;
    }
    xSemaphoreGiveFromISR(imu_data_mutex, NULL);
  }
}

void setup_imu() {
  imu_data_mutex = xSemaphoreCreateMutex();
  pinMode(INTMPU, INPUT_PULLDOWN);
  attachInterrupt(INTMPU, isr_mpu, RISING);
  SPI.begin(SCK, MISO, MOSI, SS);
  if (!imu.Begin()) {
    LOG("imu", "error initializing communication");
    while (1) {
    }
  }
  /* Set the sample rate divider */
  if (!imu.ConfigSrd(128)) {
    LOG("imu", "error configuring SRD");
    while (1) {
    }
  }
  /* Enabled data ready interrupt */
  if (!imu.EnableDrdyInt()) {
    LOG("imu", "error enabling data ready interrupt");
    while (1) {
    }
  }
  LOG("imu", "connected");

  imu_state = REQUEST;
}

void loop_imu(void* args) {
  (void)args;
  while (true) {
    if (imu_state == READ) {
      if (xSemaphoreTake(imu_data_mutex, portMAX_DELAY) != pdTRUE) {
        continue;
      }
      LOG("imu", "| ax: %.2f | ay: %.2f | az: %.2f | gx: %.2f | gy: %.2f | gz: %.2f|", imu_data.ax, imu_data.ay, imu_data.az, imu_data.gx, imu_data.gy,
          imu_data.gz);
      xSemaphoreGive(imu_data_mutex);
      vTaskDelay(11);
      imu_state = REQUEST;
    } else {
      vTaskDelay(11);
    }
  }
}

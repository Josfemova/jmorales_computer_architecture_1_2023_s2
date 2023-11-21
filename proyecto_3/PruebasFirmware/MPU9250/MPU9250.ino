#include "SPI.h"
#include "driver/gpio.h"
#include "mpu9250.h"

// driver de motor
constexpr int MOTOR_IN1 = 0;
constexpr int MOTOR_IN2 = 1;
constexpr int MOTOR_IN3 = 2;
constexpr int MOTOR_IN4 = 3;
constexpr int MOTOR_ENA = 10;
constexpr int MOTOR_ENB = 11;

// MPU 9250 (SPI)
// Comentados porque son los valores por defecto
// constexpr int SS = 18;
// constexpr int MOSI = 19;
// constexpr int MISO = 20;
// constexpr int SCK = 21;
constexpr int INTMPU = 12;

// HC-SR04
constexpr int TRIG = 16; // TX
constexpr int ECHO = 17; // RX

bfs::Mpu9250 imu(&SPI, SS);

typedef struct {
  float ax;
  float ay;
  float az;
  float gx;
  float gy;
  float gz;
} imu_data_t;

imu_data_t imu_data = {};

typedef enum { READ, REQUEST } imu_state_t;

imu_state_t imu_state;

void isr_mpu() {
  if ((imu_state == REQUEST) && imu.Read() && imu.new_imu_data()) {
    imu_data.ax = imu.accel_x_mps2();
    imu_data.ay = imu.accel_y_mps2();
    imu_data.az = imu.accel_z_mps2();
    imu_data.gx = imu.gyro_x_radps();
    imu_data.gy = imu.gyro_y_radps();
    imu_data.gz = imu.gyro_z_radps();
    imu_state = READ;
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(INTMPU, INPUT_PULLDOWN);
  attachInterrupt(INTMPU, isr_mpu, RISING);
  while (!Serial) {
    delay(10);
  }
  SPI.begin(SCK, MISO, MOSI, SS);
  if (!imu.Begin()) {
    Serial.println("Error initializing communication with IMU");
    while (1) {
    }
  }
  /* Set the sample rate divider */
  if (!imu.ConfigSrd(0)) {
    Serial.println("Error configured SRD");
    while (1) {
    }
  }
  /* Enabled data ready interrupt */
  if (!imu.EnableDrdyInt()) {
    Serial.println("Error enabling data ready interrupt");
    while (1) {
    }
  }
  Serial.println("IMU Connected");
  imu_state = REQUEST;
}

void loop() {
  if (imu_state == READ) {
    Serial.printf("| ax: %f | ay: %f | az: %f | gx: %f | gy: %f | gz: %f| \r\n",
                  imu_data.ax, imu_data.ay, imu_data.az, imu_data.gx,
                  imu_data.gy, imu_data.gz);
    imu_state = REQUEST;
  }
}

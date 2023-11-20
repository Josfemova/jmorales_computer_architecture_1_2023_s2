#ifndef SHARED_RES_H
#define SHARED_RES_H

#include <inttypes.h>

/*===============     Pines     =============== */
// MPU 9250 (SPI)
// Comentados porque son los valores por defecto
// constexpr int SS = 18;
// constexpr int MOSI = 19;
// constexpr int MISO = 20;
// constexpr int SCK = 21;
constexpr int INTMPU = 12;

// HC-SR04 (Sensor proximidad)
constexpr int TRIG = 22;
constexpr int ECHO = 23;

// L293D (Driver motor)
constexpr int MOTOR_IN1 = 0;
constexpr int MOTOR_IN2 = 1;
constexpr int MOTOR_IN3 = 2;
constexpr int MOTOR_IN4 = 3;
constexpr int MOTOR_ENA = 10;
constexpr int MOTOR_ENB = 11;

/*===============     Tipos     =============== */

typedef struct {
  float ax;
  float ay;
  float az;
  float gx;
  float gy;
  float gz;
} imu_data_t;

typedef enum {
  CAR_CMD_DISABLE_MOTOR = 0x0,
  CAR_CMD_ENABLE_MOTOR = 0x1
} car_cmd_t;

typedef struct {
  car_cmd_t car_cmd;
  int x;
  int y;
} car_cmd_info_t;

extern car_cmd_info_t car_cmd_info;

typedef enum {
  DIR_STOP1 = 0b00,
  DIR_FORWARD = 0b01,
  DIR_REVERSE = 0b10,
  DIR_STOP2 = 0b11
} motor_driver_dir_t;

/*===============     Datos     =============== */
extern imu_data_t imu_data;
extern float proximity_val;

/*===============   Funciones   =============== */
void setup_imu();
void setup_proximidad();
void setup_motores();
void loop_imu();
void loop_proximidad();
void loop_motores();

#define LOG(tag, f, ...) printf("[ " tag " ]: " f "\r\n", ##__VA_ARGS__)

#endif
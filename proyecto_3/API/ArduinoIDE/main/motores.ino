#include "shared.h"

car_cmd_info_t car_cmd_info = {
  .car_cmd = CAR_CMD_DISABLE_MOTOR, .x = 0, .y = 0
};

void change_dir(int pin1, int pin2, motor_driver_dir_t dir) {
  int pin1_val = (dir & 0b01) ? HIGH : LOW;
  int pin2_val = (dir & 0b10) ? HIGH : LOW;
  digitalWrite(pin1, pin1_val);
  digitalWrite(pin2, pin2_val);
}

void setup_motores() {
  pinMode(MOTOR_IN1, OUTPUT);
  pinMode(MOTOR_IN2, OUTPUT);
  pinMode(MOTOR_IN3, OUTPUT);
  pinMode(MOTOR_IN4, OUTPUT);
  pinMode(MOTOR_ENA, OUTPUT);
  pinMode(MOTOR_ENB, OUTPUT);

  LOG("motores", "setup listo");
}

void car_cmd_apply(int x, int y, car_cmd_t car_cmd) {
    // motor primario es el de la derecha
    // motor secundario es el de la izquierda

    double angle = fabs(atan2(y, x));
    LOG("motor", "datos: x=%d y=%d", x, y);
    switch (car_cmd) {
      case CAR_CMD_DISABLE_MOTOR:
        if (x == 0 && y == 0) {
          analogWrite(MOTOR_ENA, 0);
          analogWrite(MOTOR_ENB, 0);
        }
        break;
      case CAR_CMD_ENABLE_MOTOR:
        if (x == 0 && y == 0) {
          change_dir(MOTOR_IN1, MOTOR_IN2, DIR_STOP1);
          change_dir(MOTOR_IN3, MOTOR_IN4, DIR_STOP1);
          analogWrite(MOTOR_ENA, 128);
          analogWrite(MOTOR_ENB, 128);
          break;
        }
        if (y > 0) {  // hacia adelante
          change_dir(MOTOR_IN1, MOTOR_IN2, DIR_FORWARD);
          change_dir(MOTOR_IN3, MOTOR_IN4, DIR_FORWARD);
        } else {  // hacia atrás
          change_dir(MOTOR_IN1, MOTOR_IN2, DIR_REVERSE);
          change_dir(MOTOR_IN3, MOTOR_IN4, DIR_REVERSE);
        }
        if (angle >= 0 && angle < (PI / 6)) {  // derecha
          change_dir(MOTOR_IN1, MOTOR_IN2, DIR_FORWARD);
          change_dir(MOTOR_IN3, MOTOR_IN4, DIR_REVERSE);
          analogWrite(MOTOR_ENA, 255);
          analogWrite(MOTOR_ENB, 255);
        } else if (angle >= (PI / 6) && angle < (PI / 3)) {  // diagonal derecha
          analogWrite(MOTOR_ENA, 255);
          analogWrite(MOTOR_ENB, 128);
        } else if (angle >= TWO_PI / 3 && angle < (5 * PI / 6)) {  // diagonal izquierda
          analogWrite(MOTOR_ENA, 128);
          analogWrite(MOTOR_ENB, 255);
        } else if (angle >= (5 * PI / 6)) {  // izquierda
          change_dir(MOTOR_IN1, MOTOR_IN2, DIR_REVERSE);
          change_dir(MOTOR_IN3, MOTOR_IN4, DIR_FORWARD);
          analogWrite(MOTOR_ENA, 255);
          analogWrite(MOTOR_ENB, 255);
        } else {  // directo
          analogWrite(MOTOR_ENA, 255);
          analogWrite(MOTOR_ENB, 255);
        }
        break;
      default:
        break;
    }
}
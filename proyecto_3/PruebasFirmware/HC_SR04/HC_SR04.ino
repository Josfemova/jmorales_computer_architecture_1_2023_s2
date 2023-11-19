
#include <inttypes.h>

#include "driver/gpio.h"
#include "esp_cpu.h"

// HC-SR04
constexpr int TRIG = 22;
constexpr int ECHO = 23;

typedef enum {
  TRIGGERED,
  ECHO_STARTED,
  ECHO_ENDED,
} proximity_state_t;

proximity_state_t proximity_state;
int64_t proximity_echo_start_timestamp;
uint32_t proximity_val;

void isr_prox() {
  int64_t delta;
  switch (proximity_state) {
    case TRIGGERED:
      proximity_echo_start_timestamp = esp_timer_get_time();
      proximity_state = ECHO_STARTED;
      break;
    case ECHO_STARTED:
      delta = esp_timer_get_time() - proximity_echo_start_timestamp;
      proximity_val = delta;
      proximity_state = ECHO_ENDED;
      break;
    case ECHO_ENDED:
    default:
      break;
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(TRIG, OUTPUT);
  pinMode(ECHO, INPUT_PULLDOWN);
  attachInterrupt(ECHO, isr_prox, CHANGE);
  while (!Serial) {
    delay(10);
  }
}

void loop() {
  // trigger
  digitalWrite(TRIG, LOW);
  delayMicroseconds(2);
  proximity_val = -1;
  proximity_state = TRIGGERED;
  digitalWrite(TRIG, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG, LOW);
  // wait 60ms
  delay(200);
  if (proximity_state != ECHO_ENDED) {
    Serial.printf("Too far of anything\r\n");
  } else {
    Serial.printf("distance is %f  us\r\n", (proximity_val * 0.0343) / 2);
  }
}

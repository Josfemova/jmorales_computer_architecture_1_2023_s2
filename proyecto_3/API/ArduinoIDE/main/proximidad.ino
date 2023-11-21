#include "driver/gpio.h"
#include "esp_cpu.h"
#include "shared.h"

typedef enum {
  TRIGGERED,
  ECHO_STARTED,
  ECHO_ENDED,
} proximity_state_t;

proximity_state_t proximity_state;
int64_t proximity_echo_start_timestamp;
SemaphoreHandle_t proximity_val_mutex = NULL;
float proximity_val = 10000.0;

void isr_prox() {
  int64_t delta;
  switch (proximity_state) {
    case TRIGGERED:
      proximity_echo_start_timestamp = esp_timer_get_time();
      proximity_state = ECHO_STARTED;
      break;
    case ECHO_STARTED:
      delta = esp_timer_get_time() - proximity_echo_start_timestamp;
      if (xSemaphoreTakeFromISR(proximity_val_mutex, NULL) == pdTRUE) {
        proximity_val = (delta * 0.0343) / 2;  // cm
        xSemaphoreGiveFromISR(proximity_val_mutex, NULL);
      }
      proximity_state = ECHO_ENDED;
      break;
    case ECHO_ENDED:
    default:
      break;
  }
}

void setup_proximidad() {
  pinMode(TRIG, OUTPUT);
  pinMode(ECHO, INPUT_PULLDOWN);
  proximity_val_mutex = xSemaphoreCreateMutex();
  attachInterrupt(ECHO, isr_prox, CHANGE);
}

void loop_proximidad(void* args) {
  (void)args;
  while (true) {
    // trigger
    digitalWrite(TRIG, LOW);
    delayMicroseconds(2);
    if (xSemaphoreTake(proximity_val_mutex, portMAX_DELAY) != pdTRUE) {
      continue;
    }
    proximity_val = 1000;  // 10 metros
    xSemaphoreGive(proximity_val_mutex);

    proximity_state = TRIGGERED;
    digitalWrite(TRIG, HIGH);
    delayMicroseconds(10);
    digitalWrite(TRIG, LOW);
    // wait 60ms
    vTaskDelay(170);
    if (proximity_state != ECHO_ENDED) {
      LOG("proximity", "max distance detected");
    } else {
      if (xSemaphoreTake(proximity_val_mutex, portMAX_DELAY) != pdTRUE) {
        continue;
      }
      //LOG("proximity", "read distance: %f", proximity_val);
      xSemaphoreGive(proximity_val_mutex);
    }
  }
}

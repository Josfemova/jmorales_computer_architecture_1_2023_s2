// driver de motor
constexpr int MOTOR_IN1 = 0;
constexpr int MOTOR_IN2 = 1;
constexpr int MOTOR_IN3 = 2;
constexpr int MOTOR_IN4 = 3;
constexpr int MOTOR_ENA = 10;
constexpr int MOTOR_ENB = 11;


void setup() {
  Serial.begin(115200);
  pinMode(MOTOR_IN1, OUTPUT);
  pinMode(MOTOR_IN2, OUTPUT);
  pinMode(MOTOR_IN3, OUTPUT);
  pinMode(MOTOR_IN4, OUTPUT);
  pinMode(MOTOR_ENA, OUTPUT);
  pinMode(MOTOR_ENB, OUTPUT);
  while (!Serial) {
    delay(10);
  }
}

void loop() {
  for (int state = 0; state < 4; state++) {
    Serial.printf("state: 0x%x \r\n", state);
    analogWrite(MOTOR_ENA, 128);
    digitalWrite(MOTOR_IN1, ((state & 0b01) != 0));
    digitalWrite(MOTOR_IN2, ((state & 0b10) != 0));
    delay(500);
    analogWrite(MOTOR_ENA, 0);
    delay(500);
  }
  for (int state = 0; state < 4; state++) {
    Serial.printf("state: 0x%x \r\n", state);
    analogWrite(MOTOR_ENB, 255);
    digitalWrite(MOTOR_IN3, ((state & 0b01) != 0));
    digitalWrite(MOTOR_IN4, ((state & 0b10) != 0));
    delay(500);
    analogWrite(MOTOR_ENB, 0);
    delay(500);
  }
}

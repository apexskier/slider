#include <AccelStepper.h>

const int START_BUTTON = 8;
const int LEFT_SWITCH = 2;
const int RIGHT_SWITCH = 4;
const int SPEED_SLIDER = A0;
// const int LED = 13;    // DO NOT USE ----------------- v  ----

AccelStepper stepper(AccelStepper::FULL4WIRE, 10, 11, 12, 13);

enum State {
  oscillate,
  oneDirection
}
double acceleration = 0; // 0 is constant speed
double velocity = 0; // indicates direction, negative/positive ~= left/right

int startButtonState;

void setup() {
  stepper.setMaxSpeed(1000);
  stepper.setSpeed(50);
  pinMode(START_BUTTON, INPUT);
  startButtonState = START_BUTTON;
  pinMode(LEFT_SWITCH, INPUT);
  pinMode(RIGHT_SWITCH, INPUT);
  
  //pinMode(LED, OUTPUT);
  // initialize the serial port:
  Serial.begin(9600);
}

void loop() {
  int s = digitalRead(START_BUTTON);
  if (s != startButtonState) {
    Serial.println("START CHANGED");
  }
  startButtonState = s;

  if (startButtonState == 1) {
    stepper.runSpeed();
  }

  if (digitalRead(LEFT_SWITCH)) {
    Serial.println("LEFT ON");
  }
  if (digitalRead(RIGHT_SWITCH)) {
    Serial.println("RIGHT ON");
  }

  stepper.setSpeed(analogRead(SPEED_SLIDER));
}


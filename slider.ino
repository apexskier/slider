#include <AccelStepper.h>

// const int LED = 13;    // DO NOT USE ----------------- v  ----
AccelStepper stepper(AccelStepper::FULL4WIRE, 10, 11, 12, 13);

class Input {
 public:
  Input(int pin) {
    this->pin = pin;
    pinMode(pin, INPUT);
  };
  void update() {
    lastValue = value;
    value = this->read();
    if (this->changed()) {
      readSinceChange = false;
      lastChanged = millis();
    }
  };
  int getValue() {
    readSinceChange = true;
    return value;
  }
  bool changed() {
    readSinceChange = true;
    return value != lastValue; 
  }
  bool changedSinceRead() {
    readSinceChange = true;
    return readSinceChange; 
  }
 protected:
  int pin;
  int value;
  int lastValue;
  unsigned long lastChanged;
  bool readSinceChange;
  virtual int read() { return 0; }; // Must override
};

class ButtonInput: public Input {
 public:
  ButtonInput(int pin) : Input(pin) {};
 protected:
  int read() {
    return digitalRead(pin);
  }
};

class PotInput: public Input {
 public:
  PotInput(int pin) : Input(pin) {};
 protected:
  int read() {
    return analogRead(pin);
  }
};

enum State {
  calibrating,
  oneDirection,
  oscillating,
  stopped
};

const int PADDING = 10;
const float CALIBRATION_SPEED = 10;

double acceleration = 0; // 0 is constant speed
double velocity = 0; // indicates direction, negative/positive ~= left/right
State currentState = stopped;

ButtonInput startButton(8);
ButtonInput leftSwitch(2);
ButtonInput rightSwitch(4);
PotInput speedPot(A0);

int sliderLength;
int sliderPosition;

float analogToSpeed(int value) {
  //              v -- max analog value
  return (value / 1023) * stepper.maxSpeed();
}

void setup() {
  stepper.setMaxSpeed(200);
  
  // initialize the serial port:
  Serial.begin(9600);

  calibrate();
  currentState = stopped;
}

void loop() {
  startButton.update();
  leftSwitch.update();
  rightSwitch.update();
  speedPot.update();

  if (startButton.getValue() == HIGH) {
    currentState = oscillating;
  } else {
    currentState = stopped;
  }

  if (speedPot.changed()) {
    stepper.setSpeed(analogToSpeed(speedPot.getValue())); 
  }
  
  switch (currentState) {
  case oscillating:
    stepper.runSpeed(); // TODO: this should accellerate if set
    break;
  }
}

/**
 * set up min and max positions
 * 
 * blocking operation
 * has many side effects
 */
void calibrate() {
  currentState = calibrating;
  stepper.setSpeed(-CALIBRATION_SPEED);

  bool foundLeftSide = false;
  while (!foundLeftSide) {
    leftSwitch.update();
    rightSwitch.update();
    if (rightSwitch.getValue() == HIGH) {
      stepper.setCurrentPosition(-PADDING);
      foundLeftSide = true;
      stepper.setSpeed(-stepper.speed());
    } else if (leftSwitch.getValue() == HIGH) {
      stepper.setSpeed(-stepper.speed());
    } else {
      stepper.runSpeed();
    }
  }

  bool foundRightSide = true;
  while (!foundRightSide) {
    leftSwitch.update();
    rightSwitch.update();
    if (leftSwitch.getValue() == HIGH) {
      sliderLength = stepper.currentPosition() - PADDING;
      foundRightSide = true;
    } else if (rightSwitch.getValue() == HIGH) {
      stepper.setSpeed(-stepper.speed());
    } else {
      stepper.runSpeed();
    }
  }

  stepper.setSpeed(20);
  stepper.runToNewPosition(long(sliderLength / 2));
  stepper.setSpeed(analogToSpeed(speedPot.getValue()));
}


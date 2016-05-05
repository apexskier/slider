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
const float CALIBRATION_SPEED = 30;

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
  stepper.setAcceleration(acceleration);
  
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
  Serial.println("Starting calibration");
  currentState = calibrating;
  float spd = -CALIBRATION_SPEED;
  stepper.setSpeed(spd);

  Serial.println(".    Finding left");
  bool foundLeftSide = false;
  while (!foundLeftSide) {
    leftSwitch.update();
    rightSwitch.update();
    if (rightSwitch.getValue()) {
      spd = -stepper.speed();
      stepper.setSpeed(spd); // turn around
      // move so switch isn't activated anymore
      while (rightSwitch.getValue()) {
        stepper.runSpeed();
        rightSwitch.update();
        delay(0);
      }
      stepper.setCurrentPosition(0); // set "endpoint"
      stepper.setSpeed(spd); // speed must be reset after setCurrentPosition
      foundLeftSide = true;
      Serial.println("..   Found left");
      delay(500); // TODO hack, figure out how to properly wait for switch to deactivate
    } else if (leftSwitch.getValue()) {
      stepper.setSpeed(-stepper.speed());
      Serial.println("!! reversed");
    } else {
      stepper.runSpeed();
    }
    delay(0);
  }

  Serial.println("...  Finding right");
  bool foundRightSide = false;
  while (!foundRightSide) {
    leftSwitch.update();
    rightSwitch.update();
    if (leftSwitch.getValue()) {
      spd = -stepper.speed();
      stepper.setSpeed(spd); // turn around
      // move so switch isn't activated anymore
      while (leftSwitch.getValue()) {
        stepper.runSpeed();
        leftSwitch.update();
        delay(0);
      }
      sliderLength = stepper.currentPosition(); // set other endpoint (found length)
      foundRightSide = true;
      Serial.println(".... Found right");
      delay(500); // TODO hack, figure out how to properly wait for switch to deactivate
    } else if (rightSwitch.getValue()) {
      stepper.setSpeed(-stepper.speed());
      Serial.println("!! reversed");
    } else {
      stepper.runSpeed();
    }
    delay(0);
  }

  Serial.println(".....Centering");
  stepper.setSpeed(stepper.speed() * 2);
  stepper.runToNewPosition(long(sliderLength / 2));
  Serial.println("Calibration complete!");
  
  stepper.setSpeed(analogToSpeed(speedPot.getValue()));
}


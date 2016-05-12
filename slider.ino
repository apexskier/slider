#include <AccelStepper.h>

#define DEBUG true

enum EventType {
  Null,
  ButtonUp,
  ButtonDown
};

class Event {
 public:
  Event() {};
  const static EventType type = Null;
};

class NullEvent: public Event {};

class ButtonEvent: public Event {
 public:
  ButtonEvent(unsigned long timeSince) {
    this->timeSince = timeSince;
  };
  unsigned long timeSince;
};

class ButtonDownEvent: public ButtonEvent {
 public:
  ButtonDownEvent(unsigned long timeSince): ButtonEvent(timeSince) {};
  const static EventType type = ButtonDown;
};

class ButtonUpEvent: public ButtonEvent {
 public:
  ButtonUpEvent(unsigned long timeSince): ButtonEvent(timeSince) {};
  const static EventType type = ButtonUp;
};

class Input {
 public:
  Input(int pin) {
    this->pin = pin;
    this->lastChangeTime = millis();
    this->currentValue = LOW;
    this->lastEvent = NullEvent();
    pinMode(pin, INPUT);
  };

  void update() {
    int value = digitalRead(pin);
    // event will be generated
    if (value != currentValue) {
      unsigned long now = millis();
      if (lastEvent.type != Null) {
        Serial.print("Warning! Unconsumed event in queue for input ");
        Serial.println(pin);
      }
      if (value) {
        lastEvent = ButtonDownEvent(now - lastChangeTime);
        if (DEBUG) {
          Serial.println("generated ButtonDownEvent on " + String(pin));
        }
      } else {
        lastEvent = ButtonUpEvent(now - lastChangeTime);
        if (DEBUG) {
          Serial.println("generated ButtonUpEvent on " + String(pin));
        }
      }
      lastChangeTime = now;
      currentValue = value;
    }
  };

  Event consumeEvent() {
    Event e = lastEvent;
    if (DEBUG) {
      Serial.print("consumed ");
      switch (e.type) {
        case Null:
          Serial.print("NullEvent");
        case ButtonUp:
          Serial.print("ButtonUpEvent");
        case ButtonDown:
          Serial.print("ButtonDownEvent");
      }
      Serial.println(" on " + String(pin));
    }
    lastEvent = NullEvent();
    return e;
  };

 protected:
  int pin;
  int currentValue;
  unsigned long lastChangeTime;
  Event lastEvent;
};

// const int LED = 13;    // DO NOT USE ----------------- v  ----
AccelStepper stepper(AccelStepper::FULL4WIRE, 10, 11, 12, 13);

const int PADDING = 10;
const float CALIBRATION_SPEED = 30;

int sliderLength;
int sliderPosition;

Input* startButton = NULL;
Input* leftSwitch = NULL;
Input* rightSwitch = NULL;

enum State {
  Stopped,
  OscillatingLeft,
  OscillatingRight,
  MoveLeft,
  MoveRight,
  CalibratingFindLeft,
  CalibratingFindRight,
  CalibratingReset
};

String stateName(State s) {
  switch (s) {
    case Stopped:
      return "Stopped";
    case OscillatingLeft:
      return "OscillatingLeft";
    case OscillatingRight:
      return "OscillatingRight";
    case MoveLeft:
      return "MoveLeft";
    case MoveRight:
      return "MoveRight";
    case CalibratingFindLeft:
      return "CalibratingFindLeft";
    case CalibratingFindRight:
      return "CalibratingFindRight";
    case CalibratingReset:
      return "CalibratingReset";
  }
  return "UnknownState";
}

State currentState = Stopped;

float analogToSpeed(int value) {
  //              v -- max analog value
  return (value / 1023) * stepper.maxSpeed();
}

void startMovingLeft() {
  int speed = stepper.speed();
  if (speed > 0) {
    speed = -speed;
  }
  stepper.setSpeed(speed);
}

void startMovingRight() {
  int speed = stepper.speed();
  if (speed < 0) {
    speed = -speed;
  }
  stepper.setSpeed(speed);
}

void changeState(State s) {
  if (DEBUG) {
    State oldState = currentState;
    Serial.println("STATE CHANGE: from " + stateName(oldState) + " to " + stateName(s));
  }
  currentState = s;
}

void setup() {
  startButton = new Input(8);
  leftSwitch = new Input(2);
  rightSwitch = new Input(4);
  // speedPot = ... A0

  stepper.setMaxSpeed(200);
  stepper.setAcceleration(1);

  // initialize the serial port:
  Serial.begin(9600);

  // calibrate();
  changeState(CalibratingFindLeft);
  stepper.setSpeed(CALIBRATION_SPEED);
  startMovingLeft();
}

void loop() {
  // Read inputs
  startButton->update();
  leftSwitch->update();
  rightSwitch->update();

  Event startEvent = startButton->consumeEvent();
  Event leftEvent = leftSwitch->consumeEvent();
  Event rightEvent = rightSwitch->consumeEvent();

  // Navigate through state machine
  // * Event based
  switch (startEvent.type) {
    case ButtonUp:
      switch (currentState) {
        case Stopped:
          // TODO: choose direction
          changeState(OscillatingLeft);
          changeState(OscillatingRight);
        break;
      }
      break;
    case ButtonDown:
      switch (currentState) {
        case OscillatingLeft:
        case OscillatingRight:
        case MoveLeft:
        case MoveRight:
          changeState(Stopped);
          break;
      }
  }

  switch (leftEvent.type) {
    case ButtonUp:
      switch (currentState) {
        case Stopped:
          changeState(MoveLeft);
          startMovingLeft();
          break;
      }
    case ButtonDown:
      switch (currentState) {
        case OscillatingLeft:
          changeState(OscillatingRight);
          startMovingRight();
          break;
        case MoveLeft:
          changeState(Stopped);
          break;
        case CalibratingFindLeft:
          changeState(CalibratingFindRight);
          startMovingRight();
          break;
        case CalibratingReset:
          changeState(CalibratingFindRight);
          startMovingLeft();
          break;
      }
  }

  switch (rightEvent.type) {
    case ButtonUp:
      switch (currentState) {
        case Stopped:
          changeState(MoveRight);
          startMovingRight();
          break;
      }
    case ButtonDown:
      switch (currentState) {
        case OscillatingRight:
          changeState(OscillatingLeft);
          startMovingLeft();
          break;
        case MoveRight:
          changeState(Stopped);
          break;
        case CalibratingFindRight:
          changeState(CalibratingReset);
          startMovingLeft();
          break;
        case CalibratingReset:
          changeState(CalibratingFindRight);
          startMovingRight();
          break;
      }
  }

  // * global state based // TODO: better word than state here
  if (sliderPosition < PADDING) {
    changeState(OscillatingRight);
  } else if (sliderPosition > sliderLength - PADDING) {
    changeState(OscillatingLeft);
  }

  if (currentState == CalibratingReset &&
      abs(sliderPosition - sliderLength / 2) < 2) {
    changeState(Stopped);
  }

  // State actions
  switch (currentState) {
    case OscillatingLeft:
    case MoveLeft:
    case OscillatingRight:
    case MoveRight:
    case CalibratingFindLeft:
    case CalibratingFindRight:
    case CalibratingReset:
      stepper.runSpeed();
      break;
    case Stopped:
    default:
      // pass!
      break;
  }
}

/**
 * set up min and max positions
 *
 * blocking operation
 * has many side effects
 */
// void calibrate() {
//   Serial.println("Starting calibration");
//   currentState = calibrating;
//   float spd = -CALIBRATION_SPEED;
//   stepper.setSpeed(spd);
//
//   Serial.println(".    Finding left");
//   bool foundLeftSide = false;
//   while (!foundLeftSide) {
//     leftSwitch.update();
//     rightSwitch.update();
//     if (rightSwitch.getValue()) {
//       spd = -stepper.speed();
//       stepper.setSpeed(spd); // turn around
//       // move so switch isn't activated anymore
//       while (rightSwitch.getValue()) {
//         stepper.runSpeed();
//         rightSwitch.update();
//         delay(0);
//       }
//       stepper.setCurrentPosition(0); // set "endpoint"
//       stepper.setSpeed(spd); // speed must be reset after setCurrentPosition
//       foundLeftSide = true;
//       Serial.println("..   Found left");
//       delay(500); // TODO hack, figure out how to properly wait for switch to deactivate
//     } else if (leftSwitch.getValue()) {
//       stepper.setSpeed(-stepper.speed());
//       Serial.println("!! reversed");
//     } else {
//       stepper.runSpeed();
//     }
//     delay(0);
//   }
//
//   Serial.println("...  Finding right");
//   bool foundRightSide = false;
//   while (!foundRightSide) {
//     leftSwitch.update();
//     rightSwitch.update();
//     if (leftSwitch.getValue()) {
//       spd = -stepper.speed();
//       stepper.setSpeed(spd); // turn around
//       // move so switch isn't activated anymore
//       while (leftSwitch.getValue()) {
//         stepper.runSpeed();
//         leftSwitch.update();
//         delay(0);
//       }
//       sliderLength = stepper.currentPosition(); // set other endpoint (found length)
//       foundRightSide = true;
//       Serial.println(".... Found right");
//       delay(500); // TODO hack, figure out how to properly wait for switch to deactivate
//     } else if (rightSwitch.getValue()) {
//       stepper.setSpeed(-stepper.speed());
//       Serial.println("!! reversed");
//     } else {
//       stepper.runSpeed();
//     }
//     delay(0);
//   }
//
//   Serial.println(".....Centering");
//   stepper.setSpeed(stepper.speed() * 2);
//   stepper.runToNewPosition(long(sliderLength / 2));
//   Serial.println("Calibration complete!");
// }

#include <AccelStepper.h>

#define DEBUG true
#define MAX_SPEED 220

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
    this->currentValue = LOW;
    this->lastEvent = Null;
    pinMode(pin, INPUT);

    unsigned long now = millis();
    this->lastChangeTime = 0;
    this->lastUpdateTime = 0;
  };

  /**
   * Update the value and internals of an input and generate events.
   * Rate limited
   */
  void update() {
    unsigned long now = millis();
    if (now - lastUpdateTime <= RATE_LIMIT) {
      return;
    }

    int value = digitalRead(pin);
    // Serial.println("read " + String(value) + " on pin " + String(pin));
    // event will be generated
    if (value != currentValue) {
      if (lastEvent != Null) {
        Serial.println("Warning! Unconsumed event in queue for input " + String(pin));
      }
      if (value) {
        lastEvent = ButtonDown;
        if (DEBUG) {
          Serial.println("GENERATE ButtonDownEvent on " + String(pin));
        }
      } else {
        lastEvent = ButtonUp;
        if (DEBUG) {
          Serial.println("GENERATE ButtonUpEvent on " + String(pin));
        }
      }
      lastChangeTime = now;
      currentValue = value;
    }
    lastUpdateTime = now;
  };

  EventType consumeEvent() {
    if (lastEvent == Null) {
      return Null;
    }
    if (DEBUG) {
      switch (lastEvent) {
        case ButtonUp:
          Serial.println("CONSUME ButtonUpEvent on " + String(pin));
          break;
        case ButtonDown:
          Serial.println("CONSUME ButtonDownEvent on " + String(pin));
          break;
        case Null:
          Serial.println("CONSUME NullEvent on " + String(pin));
          break;
        default:
          Serial.println("CONSUME Unknown Event on " + String(pin));
      }
    }
    EventType e = lastEvent;
    lastEvent = Null;
    return e;
  };

 protected:
  int pin;
  int currentValue;
  unsigned long lastChangeTime;
  unsigned long lastUpdateTime;
  EventType lastEvent;
  const static unsigned long RATE_LIMIT = 10;
};

// const int LED = 13;    // DO NOT USE ----------------- v  ----
AccelStepper stepper(AccelStepper::FULL4WIRE, 10, 11, 12, 13);

const int PADDING = 10;
const float CALIBRATION_SPEED = 100;

long sliderLength = 0;

Input* startButton = NULL;
Input* leftSwitch = NULL;
Input* rightSwitch = NULL;
int speedPotPin = A0;

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

void setSliderSpeed() {
    float speed = analogToSpeed(1023 - analogRead(speedPotPin));
    float currentSpeed = stepper.speed();
    if (abs(abs(currentSpeed) - speed) > 2) {
        if (currentSpeed > 0) {
            stepper.setSpeed(speed);
        } else {
            stepper.setSpeed(-speed);
        }
        if (DEBUG) {
            Serial.println("SETTING SPEED: " + String(speed));
        }
    }
}

float analogToSpeed(int value) {
  //                     v -- max analog value
  return (float(value) / 1023.0) * MAX_SPEED;
}

void startMovingLeft() {
  if (DEBUG) {
    Serial.println("MOVE LEFT");
  }
  int speed = stepper.speed();
  if (speed > 0) {
    speed = -speed;
  }
  stepper.setSpeed(speed);
}

void startMovingRight() {
  if (DEBUG) {
    Serial.println("MOVE RIGHT");
  }
  int speed = stepper.speed();
  if (speed < 0) {
    speed = -speed;
  }
  stepper.setSpeed(speed);
}

void markLeft() {
  int speed = stepper.speed();
  sliderLength = sliderLength - stepper.currentPosition();
  stepper.setCurrentPosition(0);
  stepper.setSpeed(speed);
  if (DEBUG) {
    Serial.println("MARK LEFT");
  }
}

void markRight() {
  sliderLength = stepper.currentPosition();
  if (DEBUG) {
    Serial.println("MARK RIGHT (" + String(sliderLength) + ")");
  }
}

void changeState(State s) {
  if (DEBUG) {
    Serial.println("STATE CHANGE: from " + stateName(currentState) + " to " + stateName(s));
  }
  currentState = s;
}

void setup() {
  startButton = new Input(8);
  leftSwitch = new Input(2);
  rightSwitch = new Input(4);

  stepper.setMaxSpeed(MAX_SPEED);
  stepper.setAcceleration(1);

  // initialize the serial port:
  Serial.begin(9600);

  delay(300);

  // calibrate();
  changeState(CalibratingFindLeft);
  stepper.setSpeed(CALIBRATION_SPEED);
  startMovingLeft();
}

void loop() {
  // Serial.println("-------------------------");
  State loopState = currentState;

  // Read inputs
  startButton->update();
  leftSwitch->update();
  rightSwitch->update();

  EventType startEvent = startButton->consumeEvent();
  EventType leftEvent = leftSwitch->consumeEvent();
  EventType rightEvent = rightSwitch->consumeEvent();

  // Navigate through state machine
  // * Event based
  switch (startEvent) {
    case ButtonUp:
      switch (loopState) {
        case Stopped:
          // TODO: choose direction
          if (stepper.speed() > 0) {
            changeState(OscillatingRight);
          } else {
            changeState(OscillatingLeft);
          }
        break;
        case CalibratingReset:
          changeState(Stopped);
          break;
      }
      break;
    case ButtonDown:
      switch (loopState) {
        case OscillatingLeft:
        case OscillatingRight:
        case MoveLeft:
        case MoveRight:
        case CalibratingReset:
          changeState(Stopped);
          break;
      }
  }

  switch (leftEvent) {
    case ButtonUp:
      switch (loopState) {
        case Stopped:
          changeState(MoveLeft);
          startMovingLeft();
          break;
      }
      break;
    case ButtonDown:
      switch (loopState) {
        case OscillatingLeft:
          markLeft();
          startMovingRight();
          changeState(OscillatingRight);
          break;
        case CalibratingFindLeft:
          markLeft();
          startMovingRight();
          changeState(CalibratingFindRight);
          break;
        case CalibratingReset:
          markLeft();
          startMovingRight();
          changeState(CalibratingFindRight);
          break;
        case MoveLeft:
          markLeft();
          startMovingRight();
          changeState(Stopped);
          break;
      }
  }

  switch (rightEvent) {
    case ButtonUp:
      switch (loopState) {
        case Stopped:
          changeState(MoveRight);
          startMovingRight();
          break;
      }
      break;
    case ButtonDown:
      switch (loopState) {
        case OscillatingRight:
          markRight();
          startMovingLeft();
          changeState(OscillatingLeft);
          break;
        case CalibratingFindRight:
          markRight();
          startMovingLeft();
          changeState(CalibratingReset);
          break;
        case CalibratingReset:
          markRight();
          startMovingLeft();
          changeState(CalibratingFindLeft);
          break;
        case MoveRight:
          markRight();
          startMovingLeft();
          changeState(Stopped);
          break;
      }
  }

  int sliderPosition = stepper.currentPosition();

  // * global state based // TODO: better word than state here
  if (sliderPosition < PADDING) {
    switch (loopState) {
      case OscillatingLeft:
        startMovingRight();
        changeState(OscillatingRight);
        break;
      case MoveLeft:
        startMovingRight();
        changeState(Stopped);
        break;
    }
  } else if (sliderPosition > sliderLength - PADDING) {
    switch (loopState) {
      case OscillatingRight:
        startMovingLeft();
        changeState(OscillatingLeft);
        break;
      case MoveRight:
        startMovingLeft();
        changeState(Stopped);
        break;
    }
  }

  if (loopState == CalibratingReset &&
      sliderPosition < sliderLength / 2) {
    changeState(Stopped);
  }

  if (!(loopState == CalibratingFindLeft ||
        loopState == CalibratingFindRight ||
        loopState == CalibratingReset)) {
    setSliderSpeed();
  }

  // State actions
  switch (loopState) {
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

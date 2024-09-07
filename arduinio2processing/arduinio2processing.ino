#include <Servo.h>

// Define pins
const int redPin = 8;
const int greenPin = 9;
const int bluePin = 10;
const int trigPin = 12; // Trigger pin of the ultrasonic sensor
const int echoPin = 13; // Echo pin of the ultrasonic sensor

const long MAX_DISTANCE = 200; // Maximum reliable distance in cm

Servo myServo;
int objectDetected = 0; // Counter for detected objects
int lastPosition = 0; // Track the last servo position
bool movingForward = true; // Direction of servo movement

void setup() {
  myServo.attach(11);  // Attach the servo to pin 11
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  Serial.begin(9600);

  // Set initial color
  setRGBColor(0, 255, 0); // Set LED to green
}

void setRGBColor(int redValue, int greenValue, int blueValue) {
  analogWrite(redPin, redValue);
  analogWrite(greenPin, greenValue);
  analogWrite(bluePin, blueValue);
}

void blinkRed() {
  unsigned long startTime = millis();
  while (millis() - startTime < 1000) { // Blink red for 1 second
    setRGBColor(255, 0, 0); // Red
    delay(100);
    setRGBColor(0, 0, 0); // Off
    delay(100);
  }
}

long readUltrasonicDistance() {
  // Clear the trigger
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  
  // Set the trigger to HIGH for 10 microseconds
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  // Read the echo pin
  long duration = pulseIn(echoPin, HIGH);
  
  // Convert the duration to distance in centimeters
  long distance = (duration / 2) / 29.1;
  
  // Filter out unlikely distance readings
  if (distance <= 0 || distance > MAX_DISTANCE) {
    distance = MAX_DISTANCE + 1; // Assign an invalid distance to indicate measurement error
  }
  
  return distance;
}

void loop() {
  long distance = readUltrasonicDistance();

  // If the servo is moving forward
  if (movingForward) {
    for (int pos = lastPosition; pos <= 180; pos++) {
      myServo.write(pos);
      delay(10); // Reduced delay for faster sweeping
      
      distance = readUltrasonicDistance(); // Update distance
      if (distance < 20) {
        objectDetected++;
        blinkRed(); // Blink red LED
        lastPosition = pos; // Update the last position
        myServo.write(pos); // Hold current position of the servo
        // Maintain direction and exit the loop
        break;
      }
    }
    // If object is not detected, set lastPosition to 180
    if (distance >= 20) {
      lastPosition = 180;
    }
    movingForward = false; // Change direction for the next sweep
  }
  // If the servo is moving backward
  else {
    for (int pos = lastPosition; pos >= 0; pos--) {
      myServo.write(pos);
      delay(10); // Reduced delay for faster sweeping
      
      distance = readUltrasonicDistance(); // Update distance
      if (distance < 20) {
        objectDetected++;
        blinkRed(); // Blink red LED
        lastPosition = pos; // Update the last position
        myServo.write(pos); // Hold current position of the servo
        // Maintain direction and exit the loop
        break;
      }
    }
    // If object is not detected, set lastPosition to 0
    if (distance >= 20) {
      lastPosition = 0;
    }
    movingForward = true; // Change direction for the next sweep
  }

  // Print distance, servo position, and object detection count to Serial Monitor
  Serial.print("[");
  Serial.print(distance);
  Serial.print(", ");
  Serial.print(lastPosition);
  Serial.print(", ");
  Serial.print(objectDetected);
  Serial.println("]");

  // Keep the LED green if no object detected
  if (distance >= 20) { 
    setRGBColor(0, 255, 0); // Green
  }
}

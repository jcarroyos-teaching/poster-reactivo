import processing.serial.*;
import java.util.ArrayList;

Serial myPort;
String inString;
int pos = 0;
int ledBlinkCount = 0;
PImage bgImage;

ArrayList<PVector> circlePositions;  // List to store circle positions
ArrayList<Float> circleRadii;  // List to store circle radii
ArrayList<Integer> circleColors;  // List to store circle colors

int[] palette = { 
  color(0, 0, 0),       // greyscale-&-acid-brights-1: Black
  color(202, 209, 209), // greyscale-&-acid-brights-2: Light Grey
  color(242, 4, 158),   // greyscale-&-acid-brights-3: Bright Pink
  color(35, 240, 14),   // greyscale-&-acid-brights-4: Bright Green
  color(0, 228, 251)    // greyscale-&-acid-brights-5: Bright Cyan
};

boolean crossVisible = false;  // Control visibility of the cross

void setup() {
  size(500, 730);
  bgImage = loadImage("assets/bg.jpg");

  // Initialize the list of circle positions, radii, and colors
  circlePositions = new ArrayList<PVector>();
  circleRadii = new ArrayList<Float>();
  circleColors = new ArrayList<Integer>();

  if (Serial.list().length > 0) {
    String portName = Serial.list()[0];
    myPort = new Serial(this, portName, 9600);
    myPort.bufferUntil('\n');
  } else {
    println("No serial ports available.");
    noLoop(); 
  }
}

void draw() {
  background(bgImage);

  // Center the drawing within the specified rectangle area
  int centerX = 130 + 190 / 2;
  int centerY = 281 + 270 / 2;

  // Draw a rotating red cross if it's visible
  if (crossVisible) {
    pushMatrix();  // Save the current transformation matrix
    translate(centerX, centerY);  // Move the origin to the center of the drawing area

    float angle = radians(map(pos, 0, 180, 0, 180));  // Map "pos" to an angle between 0 and 180 degrees

    rotate(angle);  // Rotate the coordinate system by the calculated angle

    stroke(255, 0, 0); // Red color
    strokeWeight(3);
    noFill();

    // Length of each arm of the cross
    float armLength = 30;

    // Draw the horizontal line of the cross
    line(-armLength, 0, armLength, 0);

    // Draw the vertical line of the cross
    line(0, -armLength, 0, armLength);

    // Restore the original transformation matrix
    popMatrix();
  }

  // Draw all previously stored circles
  noStroke();
  for (int i = 0; i < circlePositions.size(); i++) {
    int colorWithOpacity = circleColors.get(i);
    fill(colorWithOpacity);  // Use the corresponding color with opacity
    PVector pos = circlePositions.get(i);
    float radius = circleRadii.get(i);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);  // Draw each circle with the specified radius
  }
}

void serialEvent(Serial myPort) {
  inString = myPort.readStringUntil('\n');

  if (inString != null) {
    inString = trim(inString);

    if (inString.startsWith("[") && inString.endsWith("]")) {
      inString = inString.substring(1, inString.length() - 1);

      String[] values = split(inString, ',');

      if (values.length == 3) {
        try {
          float distance = float(values[0].trim());  // Get distance
          int angle = int(values[1].trim());  // Get angle
          int newLedBlinkCount = int(values[2].trim());  // Get objectDetected count

          // Update the angle
          pos = angle;

          // Update visibility of the cross based on objectDetected count
          if (newLedBlinkCount != ledBlinkCount) {
            ledBlinkCount = newLedBlinkCount;
            crossVisible = true;  // Show the cross
            regenerateCircles(ledBlinkCount, distance);
          } else {
            crossVisible = false;  // Hide the cross if no change in objectDetected count
          }

          // Debug output
          println("[" + pos + ", " + ledBlinkCount + ", " + distance + "]");
        } catch (Exception e) {
          println("Error converting data: " + e);
        }
      } else {
        println("Error in received data: " + inString);
      }
    }
  }
}

// Method to regenerate circle positions, colors, and radii
void regenerateCircles(int count, float radius) {
  // If the count has increased, add new circles
  if (count > circlePositions.size()) {
    for (int i = circlePositions.size(); i < count; i++) {
      float randX = random(130, 130 + 190);  // Generate a random X position within the area
      float randY = random(281, 281 + 270);  // Generate a random Y position within the area
      circlePositions.add(new PVector(randX, randY));  // Add the new position to the list

      // Randomly choose a color from the palette and add opacity
      int randColor = palette[int(random(palette.length))];
      int colorWithOpacity = color(red(randColor), green(randColor), blue(randColor), 127);  // Set opacity to 50%
      circleColors.add(colorWithOpacity);  // Add the new color with opacity to the list

      // Set radius for each new circle
      circleRadii.add(radius);
    }
  }
  // If the count has decreased, remove excess circles
  else if (count < circlePositions.size()) {
    while (circlePositions.size() > count) {
      circlePositions.remove(circlePositions.size() - 1);
      circleColors.remove(circleColors.size() - 1);
      circleRadii.remove(circleRadii.size() - 1);
    }
  }
}

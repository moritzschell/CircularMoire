import controlP5.*;
import processing.serial.*;
ControlP5 cp5;

float circleRadius;
PVector circleCenter;

float rotate1 = 0.0;
float rotate2 = 0.0;

float offset1 = 0.0;
float offset2 = 0.0;

float gridDistance = 6.75;
boolean invertCol = false;

ArrayList<PVector[]> firstGrid;  //Holding start and end points of first grid
ArrayList<PVector[]> secondGrid; //Holding start and end points of overlaying grid

Slider rotationSlider1, rotationSlider2;
Slider gridDistanceSlider;
Slider offsetSlider1, offsetSlider2;
Toggle invertColor;

boolean showUI = true;

int printGridIndex = 1;

void setup() {
  size(600, 600, P3D);
  smooth();
  pixelDensity(2);

  //define circular shape
  circleRadius = 125;
  circleCenter = new PVector(127, 127);

  firstGrid = new ArrayList<PVector[]>();
  secondGrid = new ArrayList<PVector[]>();


  ///UI Stuff
  cp5 = new ControlP5(this);

  rotationSlider1 = cp5.addSlider("rotate1")
    .setPosition(10, 10)
    .setRange(0, PI)
    .setSize(100, 20)
    .setValue(0.84)
    .setColorCaptionLabel(color(0, 50, 170)) 
    ;

  rotationSlider2 = cp5.addSlider("rotate2")
    .setPosition(10, 40)
    .setRange(0, PI)
    .setSize(100, 20)
    .setValue(0.81)
    .setColorCaptionLabel(color(0, 50, 170)) 
    ;

  gridDistanceSlider = cp5.addSlider("gridDistance")
    .setPosition(160, 10)
    .setRange(2.0, 10.0)
    .setSize(100, 20)
    .setValue(6.75)
    .setColorCaptionLabel(color(0, 50, 170)) 
    ;

  invertColor = cp5.addToggle("invertCol")
    .setCaptionLabel("Invert Color")
    .setPosition(160, 40)
    .setSize(20, 20)
    .setColorCaptionLabel(color(0, 50, 170)) 
    ;

  offsetSlider1 = cp5.addSlider("offset1")
    .setPosition(330, 10)
    .setRange(-10, 10.0)
    .setValue(-0.60)
    .setSize(100, 20)
    .setColorCaptionLabel(color(0, 50, 170)) 
    ;

  offsetSlider2 = cp5.addSlider("offset2")
    .setPosition(330, 40)
    .setRange(-10, 10.0)
    .setValue(0.0)
    .setSize(100, 20)
    .setColorCaptionLabel(color(0, 50, 170)) 
    ;

  //AxiDrawSettings___________________________________________
  ServoUp = 7500 + 175 * ServoUpPct;    // Brush UP position, native units
  ServoPaint = 7500 + 175 * ServoPaintPct;   // Brush DOWN position, native units. 

  NextMoveTime = millis();

  if (PaperSizeA4) {
    MousePaperRight = round(MousePaperLeft + PixelsPerInch * 297/2/25.4);
    MousePaperBottom = round(MousePaperTop + PixelsPerInch * 210/25.4);
  } else {
    MousePaperRight = round(MousePaperLeft + PixelsPerInch * 11.0);
    MousePaperBottom = round(MousePaperTop + PixelsPerInch * 8.5);
  }

  MotorMinX = 0;
  MotorMinY = 0;
  MotorMaxX = int(floor(float(MousePaperRight - MousePaperLeft) * MotorStepsPerPixel)) ;
  MotorMaxY = int(floor(float(MousePaperBottom - MousePaperTop) * MotorStepsPerPixel)) ;

  lastPosition = new PVector(-1, -1);

  ToDoList = new PVector[0];
  indexDone = -1;    // Index in to-do list of last action performed

  Paused = true;
}


void draw() {

  if (doSerialConnect == true) {
    // FIRST RUN ONLY:  Connect here, so that 
    doSerialConnect = false;

    scanSerial();

    if (SerialOnline) {    
      myPort.write("EM,2\r");  //Configure both steppers to 1/8 step mode

      // Configure brush lift servo endpoints and speed
      myPort.write("SC,4," + str(ServoPaint) + "\r");  // Brush DOWN position, for painting
      myPort.write("SC,5," + str(ServoUp) + "\r");  // Brush UP position 

      //    myPort.write("SC,10,255\r"); // Set brush raising and lowering speed.
      myPort.write("SC,10,65535\r"); // Set brush raising and lowering speed.

      // Ensure that we actually raise the brush:
      BrushDown = true;  
      raiseBrush();  
      //lowerBrush();

      println("Now entering interactive painting mode.\n");
    } else { 
      println("Now entering offline simulation mode.\n");
    }
  } else {
    background(255);
    if (invertCol) background(0);

    noFill();
    stroke(0);
    if (invertCol) stroke(255);

    pushMatrix();
    translate(circleCenter.x, circleCenter.y);
    rotate(rotate1);
    translate(-circleCenter.x, -circleCenter.y);

    firstGrid.clear(); //Clear ArrayList 
    for (int i = 0; i <= width; i+=gridDistance ) {
      PVector lineStart = new PVector(i+offset1, 0);
      PVector lineEnd = new PVector(i+offset1, height);
      ArrayList<PVector> _intersectionPoints = returnIntersectionPoints(lineStart, lineEnd, circleCenter, circleRadius);
      if (_intersectionPoints.size() == 2) {
        PVector[] startEndPoints = new PVector[2];

        float startX = modelX(_intersectionPoints.get(0).x, _intersectionPoints.get(0).y, 0); //get real x-coordinate based on original coorinate and transformation 
        float startY = modelY(_intersectionPoints.get(0).x, _intersectionPoints.get(0).y, 0); //get real x-coordinate based on original coorinate and transformation 
        PVector startPoint = new PVector(startX, startY);

        float endX = modelX(_intersectionPoints.get(1).x, _intersectionPoints.get(1).y, 0); //get real x-coordinate based on original coorinate and transformation 
        float endY = modelY(_intersectionPoints.get(1).x, _intersectionPoints.get(1).y, 0); //get real x-coordinate based on original coorinate and transformation 
        PVector endPoint = new PVector(endX, endY);

        startEndPoints[0] = startPoint; //assign to Array...
        startEndPoints[1] = endPoint;

        firstGrid.add(startEndPoints); //add to ArrayList...

        //line(_intersectionPoints.get(0).x, _intersectionPoints.get(0).y, _intersectionPoints.get(1).x, _intersectionPoints.get(1).y);
      }
    }
    popMatrix();

    pushMatrix();
    translate(circleCenter.x, circleCenter.y);
    rotate(rotate2);
    translate(-circleCenter.x, -circleCenter.y);

    secondGrid.clear();
    for (int i = 0; i <= width; i+=gridDistance) {
      PVector lineStart = new PVector(i+offset2, 0);
      PVector lineEnd = new PVector(i+offset2, height);
      ArrayList<PVector> _intersectionPoints = returnIntersectionPoints(lineStart, lineEnd, circleCenter, circleRadius);
      if (_intersectionPoints.size() == 2) {
        PVector[] startEndPoints = new PVector[2];

        float startX = modelX(_intersectionPoints.get(0).x, _intersectionPoints.get(0).y, 0); //get real x-coordinate based on original coorinate and transformation 
        float startY = modelY(_intersectionPoints.get(0).x, _intersectionPoints.get(0).y, 0); //get real x-coordinate based on original coorinate and transformation 
        PVector startPoint = new PVector(startX, startY);

        float endX = modelX(_intersectionPoints.get(1).x, _intersectionPoints.get(1).y, 0); //get real x-coordinate based on original coorinate and transformation 
        float endY = modelY(_intersectionPoints.get(1).x, _intersectionPoints.get(1).y, 0); //get real x-coordinate based on original coorinate and transformation 
        PVector endPoint = new PVector(endX, endY);

        startEndPoints[0] = startPoint; //assign to Array...
        startEndPoints[1] = endPoint;

        secondGrid.add(startEndPoints); //add to ArrayList...

        //line(_intersectionPoints.get(0).x, _intersectionPoints.get(0).y, _intersectionPoints.get(1).x, _intersectionPoints.get(1).y);
      }
    }
    popMatrix();


    ///draw the lines...
    for (PVector[] startEndPoints : firstGrid) {
      PVector startPoint = startEndPoints[0];
      PVector endPoint = startEndPoints[1];
      line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
    }
    for (PVector[] startEndPoints : secondGrid) {
      PVector startPoint = startEndPoints[0];
      PVector endPoint = startEndPoints[1];
      line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
    }

    ///draw the circle
    //ellipse(circleCenter.x, circleCenter.y, circleRadius*2, circleRadius*2);

    ///show instructions
    if (showUI) {
      fill(0);
      if (invertCol) fill(255);
      text("Press SPACEBAR to toggle visibility of Controls...", 10, height-30);
    }
    
    checkServiceBrush();
  }
}

void keyPressed() {

  if (key == ' ') {
    showUI = !showUI;
  } else if (key == 'p' || key == 'P') {
    if (BrushDown == true) {
      raiseBrush();
    } else {
      lowerBrush();
    }
  } else if(key == 'r' || key == 'R'){
    //println("Print Rect...");
    startPrintArtwork();
  }

  if (showUI) {
    showUI();
  } else {
    hideUI();
  }
}

void startPrintArtwork(){
  ToDoList = null;
  ToDoList = new PVector[0];
  indexDone = -1; 
  
  if(printGridIndex == 1){
    generateArtwork(firstGrid);
  } else if(printGridIndex == 2) {
    generateArtwork(secondGrid);
  }
  
  printGridIndex ++;
  
  if(printGridIndex > 2) printGridIndex = 1;
  
  Paused = false;
}

void startPrintRect() {
  ToDoList = null;
  ToDoList = new PVector[0];
  indexDone = -1; 

  PVector[] firstLine = new PVector[2];
  PVector[] secondLine = new PVector[2];
  PVector[] thirdLine = new PVector[2];
  PVector[] fourthLine = new PVector[2];
  
  firstLine[0] = new PVector(2,2);
  firstLine[1] = new PVector(252,2);
  
  secondLine[0] = new PVector(252,2);
  secondLine[1] = new PVector(252,252);
  
  thirdLine[0] = new PVector(252,252);
  thirdLine[1] = new PVector(2,252);
  
  fourthLine[0] = new PVector(2,252);
  fourthLine[1] = new PVector(2,2);
  

  ArrayList <PVector[]> allPoints = new ArrayList<PVector[]>();

  allPoints.add(firstLine);
  allPoints.add(secondLine);
  allPoints.add(thirdLine);
  allPoints.add(fourthLine);
  
  generateArtwork(allPoints);

  Paused = false;
}

void generateArtwork(ArrayList <PVector[]> _points) {

  //Command 30 (raise pen)
  ToDoList = (PVector[]) append(ToDoList, new PVector(-30, 0)); 

  for (PVector[] line : _points) {

    for (int i = 0; i < line.length; i++) {
      // Command Code: Move to (X,Y)
      ToDoList = (PVector[]) append(ToDoList, new PVector(line[i].x, line[i].y));

      if (i == 0) {
        //Command 31 (lower pen)
        ToDoList = (PVector[]) append(ToDoList, new PVector(-31, 0));
      }
    }

    //Command 30 (raise pen)
    ToDoList = (PVector[]) append(ToDoList, new PVector(-30, 0));
  }

  ToDoList = (PVector[]) append(ToDoList, new PVector(0, 0));
  
  println(ToDoList);
}





void showUI() {
  rotationSlider1.show();
  rotationSlider2.show();
  gridDistanceSlider.show();
  invertColor.show();
  offsetSlider1.show();
  offsetSlider2.show();
}

void hideUI() {
  rotationSlider1.hide();
  rotationSlider2.hide();
  gridDistanceSlider.hide();
  invertColor.hide();
  offsetSlider1.hide();
  offsetSlider2.hide();
}


ArrayList<PVector> returnIntersectionPoints(PVector _lineStart, PVector _lineEnd, PVector _circleCenter, float _circleRadius ) {
  ////------------------------------------------------------------------------------------------////
  ////-- Based on Forum Discussion: ------------------------------------------------------------////
  ////-- https://forum.processing.org/two/discussion/90/point-and-line-intersection-detection --////
  ////------------------------------------------------------------------------------------------////

  ArrayList<PVector> intersectionPoints = new ArrayList<PVector>();

  float dx = _lineEnd.x - _lineStart.x;
  float dy = _lineEnd.y - _lineStart.y;

  float a = dx*dx + dy*dy;
  float b = (dx*(_lineStart.x - _circleCenter.x) + (_lineStart.y - _circleCenter.y)*dy) * 2;
  float c = _circleCenter.x*_circleCenter.x + _circleCenter.y*_circleCenter.y;

  c += _lineStart.x*_lineStart.x + _lineStart.y*_lineStart.y;
  c -= (_circleCenter.x*_lineStart.x + _circleCenter.y*_lineStart.y) * 2;
  c -= _circleRadius*_circleRadius;

  float delta = b*b - 4*a*c;

  if (delta > 0) {
    delta = sqrt(delta);

    float mu = (-b + delta) / (2*a);
    float ix1 = _lineStart.x + mu*dx;
    float iy1 = _lineStart.y + mu*dy;

    mu = (b + delta) / (-2*a);
    float ix2 = _lineStart.x + mu*dx;
    float iy2 = _lineStart.y + mu*dy;

    if (dist(_lineEnd.x, _lineEnd.y, _circleCenter.x, _circleCenter.y) > _circleRadius && dist(_lineStart.x, _lineStart.y, _circleCenter.x, _circleCenter.y) < _circleRadius) {
      //Check if EndPoint of Line is outside circle
      intersectionPoints.add(new PVector(ix1, iy1));
    }
    if (dist(_lineStart.x, _lineStart.y, _circleCenter.x, _circleCenter.y) > _circleRadius && dist(_lineEnd.x, _lineEnd.y, _circleCenter.x, _circleCenter.y) < _circleRadius) {
      //Check if StartPoint of Line is outside circle
      intersectionPoints.add(new PVector(ix2, iy2));
    }
    if (dist(_lineStart.x, _lineStart.y, _circleCenter.x, _circleCenter.y) > _circleRadius && 
      dist(_lineEnd.x, _lineEnd.y, _circleCenter.x, _circleCenter.y) > _circleRadius &&
      dist(_lineStart.x, _lineStart.y, _lineEnd.x, _lineEnd.y) >= _circleRadius*2) {
      intersectionPoints.add(new PVector(ix1, iy1));
      intersectionPoints.add(new PVector(ix2, iy2));
    }
  }

  return intersectionPoints;
}

import controlP5.*;
ControlP5 cp5;

float circleRadius;
PVector circleCenter;

float rotate1 = 0.0;
float rotate2 = 0.0;

float offset1 = 0.0;
float offset2 = 0.0;

float gridDistance = 5.0;
boolean invertCol = false;

ArrayList<PVector[]> firstGrid;  //Holding start and end points of first grid
ArrayList<PVector[]> secondGrid; //Holding start and end points of overlaying grid

Slider rotationSlider1, rotationSlider2;
Slider gridDistanceSlider;
Slider offsetSlider1, offsetSlider2;
Toggle invertColor;

boolean showUI = true;

void setup() {
  size(600, 600, P3D);
  smooth();
  pixelDensity(2);

  //define circular shape
  circleRadius = 200;
  circleCenter = new PVector(width/2, height/2);
  
  firstGrid = new ArrayList<PVector[]>();
  secondGrid = new ArrayList<PVector[]>();
  
  
  ///UI Stuff
  cp5 = new ControlP5(this);
  
  rotationSlider1 = cp5.addSlider("rotate1")
     .setPosition(10, 10)
     .setRange(0, PI)
     .setSize(100, 20)
     .setValue(0.78)
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
     .setValue(0.0)
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
}


void draw() {
  
  background(255);
  if(invertCol) background(0);

  noFill();
  stroke(0);
  if(invertCol) stroke(255);

  pushMatrix();
  translate(width/2, height/2);
  rotate(rotate1);
  translate(-width/2, -height/2);

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
  translate(width/2, height/2);
  rotate(rotate2);
  translate(-width/2, -height/2);

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
  for(PVector[] startEndPoints : firstGrid){
    PVector startPoint = startEndPoints[0];
    PVector endPoint = startEndPoints[1];
    line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
  }
  for(PVector[] startEndPoints : secondGrid){
    PVector startPoint = startEndPoints[0];
    PVector endPoint = startEndPoints[1];
    line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
  }
  
  ///draw the circle
  //ellipse(circleCenter.x, circleCenter.y, circleRadius*2, circleRadius*2);
  
  ///show instructions
  if(showUI){
    fill(0);
    if(invertCol) fill(255);
    text("Press SPACEBAR to toggle visibility of Controls...", 10, height-30);
  }
  
}

void keyPressed(){
  
  if(key == ' '){
    showUI = !showUI;
  }
  if(showUI){
    showUI();
  } else {
    hideUI();
  }
  
}

void showUI(){
  rotationSlider1.show();
  rotationSlider2.show();
  gridDistanceSlider.show();
  invertColor.show();
  offsetSlider1.show();
  offsetSlider2.show();
}

void hideUI(){
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

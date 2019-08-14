float circleRadius;
PVector circleCenter;

float rotate1 = 0.0;
float rotate2 = 0.0;

float rotate1Speed, rotate2Speed;

void setup() {
  size(600, 600);
  smooth();
  pixelDensity(2);

  //define circular shape
  circleRadius = 200;
  circleCenter = new PVector(width/2, height/2);
  
  rotate1Speed = random(0.01, 0.02);
  rotate2Speed = random(0.01, 0.02);
}


void draw() {
  background(255);

  noFill();
  stroke(0);

  pushMatrix();
  translate(width/2, height/2);
  rotate(rotate1);
  translate(-width/2, -height/2);

  for (int i = 0; i <= width; i+=5 ) {
    PVector lineStart = new PVector(i, 0);
    PVector lineEnd = new PVector(i, height);
    ArrayList<PVector> _intersectionPoints = returnIntersectionPoints(lineStart, lineEnd, circleCenter, circleRadius);
    if (_intersectionPoints.size() == 2) {
      line(_intersectionPoints.get(0).x, _intersectionPoints.get(0).y, _intersectionPoints.get(1).x, _intersectionPoints.get(1).y);
    }
  }
  popMatrix();

  pushMatrix();
  translate(width/2, height/2);
  rotate(rotate2);
  translate(-width/2, -height/2);

  for (int i = 0; i <= width; i+=5) {
    PVector lineStart = new PVector(i, 0);
    PVector lineEnd = new PVector(i, height);
    ArrayList<PVector> _intersectionPoints = returnIntersectionPoints(lineStart, lineEnd, circleCenter, circleRadius);
    if (_intersectionPoints.size() == 2) {
      line(_intersectionPoints.get(0).x, _intersectionPoints.get(0).y, _intersectionPoints.get(1).x, _intersectionPoints.get(1).y);
    }
  }
  popMatrix();


  //ellipse(circleCenter.x, circleCenter.y, circleRadius*2, circleRadius*2);

  rotate1 += rotate1Speed;
  rotate2 -= rotate2Speed;
  
  if(rotate1 >= PI){
    rotate1Speed = random(0.01, 0.1);
    rotate1 = 0;
    println("1...");
  } 
  if(rotate2 <= -PI){
    rotate2Speed = random(0.01, 0.1);
    rotate2 = 0;
    println("2...");
  } 
  
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

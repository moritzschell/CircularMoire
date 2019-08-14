float circleRadius;
PVector circleCenter;

PVector s, e;

void setup() {
  size(600, 600);
  smooth();
  pixelDensity(2);

  //define circular shape
  circleRadius = 200;
  circleCenter = new PVector(width/2, height/2);

  s = new PVector(width/2, 0);
  e = new PVector(width/2, height);
  
  //s = new PVector(0, height/2);
  //e = new PVector(width, height/2);
}


void draw() {
  background(255);
  stroke(0);

  ellipse(circleCenter.x, circleCenter.y, circleRadius*2, circleRadius*2);
  line(s.x, s.y, e.x, e.y);

  ArrayList<PVector> intPoints = returnIntersectionPoints(s, e, circleCenter, circleRadius);

  if (intPoints.size() > 0) {
    println("there are " + intPoints.size() + " Intersection Points");

    for (PVector v : intPoints) {
      ellipse(v.x, v.y, 5, 5);
    }
  } else {
    println("No Intersection Points");
  }

  //for (int i = 0; i <= width; i+=5) {
  //  PVector lineStart = new PVector(i, 0);
  //  PVector lineEnd = new PVector(i, height);
  //  ArrayList<PVector> _intersectionPoints = returnIntersectionPoints(lineStart, lineEnd, circleCenter, circleRadius);

  //  if (_intersectionPoints.size() > 0) {
  //    println(i + "; there are " + _intersectionPoints.size() + " Intersection Points");
  //  } else {
  //    println(i + "; No Intersection Points");
  //  }

  //  for (PVector v : _intersectionPoints) {
  //    ellipse(v.x, v.y, 5, 5);
  //  }

  //  if (_intersectionPoints.size() == 2) {
  //    line(_intersectionPoints.get(0).x, _intersectionPoints.get(0).y, _intersectionPoints.get(1).x, _intersectionPoints.get(1).y);
  //  }

  //  stroke(255, 0, 0);
  //  line(lineStart.x, lineStart.y, lineEnd.x, lineEnd.y);
  //}
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
        dist(_lineStart.x, _lineStart.y, _lineEnd.x, _lineEnd.y) >= _circleRadius*2){
          intersectionPoints.add(new PVector(ix1, iy1));
          intersectionPoints.add(new PVector(ix2, iy2));
    }
  }

  return intersectionPoints;
}

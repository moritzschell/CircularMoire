float circleRadius;
PVector circleCenter;

void setup(){
  size(600, 600);
  smooth();
  pixelDensity(2);
  
  //define circular shape
  circleRadius = 200;
  circleCenter = new PVector(width/2, height/2);
  
}


void draw(){
  background(255);
  
  ellipse(circleCenter.x, circleCenter.y, circleRadius*2, circleRadius*2);
  
}

ArrayList<PVector> returnIntersectionPoints(PVector lineStart, PVector lineEnd, PVector circleCenter, float _radius ) {
  ////------------------------------------------------------------------------------------------////
  ////-- Based on Forum Discussion: ------------------------------------------------------------////
  ////-- https://forum.processing.org/two/discussion/90/point-and-line-intersection-detection --////
  ////------------------------------------------------------------------------------------------////
  
  ArrayList<PVector> intersectionPoints = new ArrayList<PVector>();

  PVector sub = PVector.sub(lineStart, lineEnd);
  // y = a * x + b
  float a = sub.y / sub.x;
  float b = lineEnd.y - a * lineEnd.x;
  // (x - x0)^2 + (y - y0)^2 = radius ^2
  // y = a * x + b
  float A = (1 + a * a);
  float B = (2 * a *( b - circleCenter.y) - 2 * circleCenter.x);
  float C = (circleCenter.x * circleCenter.x + (b - circleCenter.y) * (b - circleCenter.y)) - (_radius * _radius);
  float delta = B * B - 4 * A * C;

  if (delta >= 0) {
    float x1 = (-B - sqrt(delta)) / (2 * A);
    float y1 = a * x1 + b;
    if ((x1 > min(lineStart.x, lineEnd.x)) && (x1 < max(lineStart.x, lineEnd.x)) && (y1 > min(lineStart.y, lineEnd.y)) && (y1 < max(lineStart.y, lineEnd.y))) {
      //ellipse(x1, y1, 20, 20);
      intersectionPoints.add(new PVector(x1, y1));
    }
    float x2 = (-B + sqrt(delta)) / (2 * A);
    float y2 = a * x2 + b;
    if ((x2 > min(lineStart.x, lineEnd.x)) && (x2 < max(lineStart.x, lineEnd.x)) && (y2 > min(lineStart.y, lineEnd.y)) && (y2 < max(lineStart.y, lineEnd.y))) {
      //ellipse(x2, y2, 20, 20);
      intersectionPoints.add(new PVector(x2, y2));
    }
  }

  return intersectionPoints;
}

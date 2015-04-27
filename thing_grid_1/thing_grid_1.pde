int N = 7;
float SEP;

void setup() {
  size(600, 600);
  //SEP = sqrt(width * width + height * height) / N;
  SEP = 41;
  
}

//static final float[] ZERO3 = {0, 0, 0};

float[] add3(float[] a, float[] b) { 
  return new float []{a[0] + b[0], a[1] + b[1], a[2] + b[2]}; 
}

void thing(float x, float y, float px, float py, float t) {
  float d = .005 * sqrt(px * px + py * py) + 1.5;
  float d0 = d * (1.2 + .4 * sin(t * 0.658 + 0));
  float d1 = d * (1.2 + .4 * sin(t * 0.687 + 1));
  float d2 = d * (1.2 + .4 * sin(t * 0.716 + 2));
  float d3 = d * (1.2 + .4 * sin(t * 0.745 + 3));
  float d4 = d * (1.2 + .4 * sin(t * 0.774 + 4));
  float d5 = d * (1.2 + .4 * sin(t * 0.803 + 5));
  float d6 = d * (1.2 + .4 * sin(t * 0.832 + 6));
  float d7 = d * (1.2 + .4 * sin(t * 0.861 + 7));
  float d8 = d * (1.2 + .4 * sin(t * 0.990 + 8));
  float x0 = x + px / d0, y0 = y + py / d1, r0 = 45 / d2;
  float x1 = x + px / d3, y1 = y + py / d4, r1 = 45 / d5;
  float x2 = x + px / d6, y2 = y + py / d7, r2 = 45 / d8;
  /*fill(72,0,96);
  noStroke();
  ellipse(x0, y0, 10, 10);
  ellipse(x1, y1, 10, 10);
  ellipse(x2, y2, 10, 10);*/
  noFill();
  stroke(72,0,96);
  triangle(x0,y0,x1,y1,x2,y2);
}

float SQRT75 = sqrt(0.75);
void draw() {
  float t = millis() / 1000.0;
  background(240,192,0);
  
  pushMatrix();
    translate(width/2, height/2);
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        float x = (j - N / 2) * SEP;
        float y = (i - N / 2 + 0.5 * j % 2) * SEP / SQRT75;
        thing(x, y, mouseX - screenX(x,y), mouseY - screenY(x,y), t);
      }
    }       
  popMatrix();
}

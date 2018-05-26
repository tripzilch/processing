int N = 7;
float SEP;


long tri(long n) {
  return n * (n + 1) / 2;
}

long n_divisors(long x) {
  long n = 0;
  for (long d = 1; d <= x; d++) {
    if (x % d == 0) {
      n++;
    }
  }
  return n;
}


void setup() {
  //size(600, 600);
  //SEP = sqrt(width * width + height * height) / N;
  SEP = 41;
  long nd_max = 0;  
  for (long x = 1; x < 32700; x++) {
    long t = tri(x);
    long nd = n_divisors(t);
    if (nd > nd_max) {
      nd_max = nd;
      int now = millis() / 1000;
      println(nfs(int(x), 5) + ".  tri = " + t + "\t ndiv = " + nd + "\t    t = " + now / 60 + ":" + nf(now % 60, 2));
    }
  }
  println("done");
}

void draw() {}

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
void draw__() {
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

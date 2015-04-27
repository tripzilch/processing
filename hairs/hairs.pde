int N = 10;
float[] x0 = new float[N];
float[] y0 = new float[N];
float[] x1 = new float[N];
float[] y1 = new float[N];
float[] x2 = new float[N];
float[] y2 = new float[N];
float[] x3 = new float[N];
float[] y3 = new float[N];

void setup() {
  size(600, 600);
  // create random connected line segments of
  // length 3..9
  int i = 0;
  // N = 5
  // 0, 1, 2, 3, 4
  while (i <= N - 5) { 
    int L = min(N - i, 5 + int(random(9)));
    float x = random(-200, 200), 
          y = random(-200, 200),
          a = random(TAU),
          r = 15,
          wiggliness = 0.25 * TAU;
    for (int j = 0; j < L; j++) {
      x0[i] = x; y0[i] = y;
      x += r * cos(a);
      y += r * sin(a);
      a += random(-wiggliness, wiggliness);
      x1[i] = x; y1[i] = y;
      i++;
    }
  }
}

void draw() {
  float t = millis() / 1000.0;
  background(240);
  stroke(0);
  
  pushMatrix();
    translate(width/2, height/2);
    for (int i = 0; i < N; i++) {
      line(x0[i], y0[i], x1[i], y1[i]);
    }
  popMatrix();
}

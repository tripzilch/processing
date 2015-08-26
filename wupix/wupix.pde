import java.lang.Math;

float pscale, dot_size;
PShape box, hex;
void setup() {
  size(1000,1000,P2D);
  pscale = width / 2.0;
  dot_size = 2.0 / pscale;

  smooth(4);
  colorMode(RGB, 1.0);
  noStroke();

  box = createShape();
  box.beginShape(TRIANGLE_STRIP);
  box.noStroke();
  box.fill(#000000);
  box.vertex(-0.707 * dot_size,  0.707 * dot_size);
  box.vertex(-0.707 * dot_size, -0.707 * dot_size);
  box.vertex( 0.707 * dot_size,  0.707 * dot_size);
  box.vertex( 0.707 * dot_size, -0.707 * dot_size);
  box.endShape(CLOSE);

  hex = createShape();
  hex.beginShape(TRIANGLE_STRIP);
  hex.noStroke();
  hex.fill(#000000);
  hex.vertex(-0.866 * dot_size,  0.5 * dot_size);
  hex.vertex(-0.866 * dot_size, -0.5 * dot_size);
  hex.vertex( 0.000 * dot_size,  1.0 * dot_size);
  hex.vertex( 0.000 * dot_size, -1.0 * dot_size);
  hex.vertex( 0.866 * dot_size,  0.5 * dot_size);
  hex.vertex( 0.866 * dot_size, -0.5 * dot_size);
  hex.endShape(CLOSE);

  box.disableStyle();
  hex.disableStyle();

  fill(1.0,.7,.3);
  rect(0, 0, width, height);
}

void wupix(double x, double y) {
  /*int xi = (int) x, yi = (int) y;
  if (xi >= 0 && xi < width - 1 && yi >= 0 && yi < height - 1) {
    int ii = yi * width + xi;
    double xf = (x - xi), yf = (y - yi);
    double xy = xf * yf;
    pixels[ii] = grey(1.0 - yf - xf + xy);
    pixels[ii+1] = grey(xf - xy);
    pixels[ii+width] = grey(yf - xy);
    pixels[ii+width+1] = grey(xy);
  }*/
}

double wobble(double x, double y, double z) {
  double a = Math.cos(23 * x - 17 * y + 77);
  double b = Math.cos(19 * y - 22 * z + 55);
  double c = Math.cos(27 * z - 13 * x + 33);

  return  (Math.cos(7 * a - 8 * b + 39)
         + Math.cos(9 * b - 6 * c + 24)
         + Math.cos(7 * c - 5 * a + 15)) * 0.33333;
}

void dot(double x, double y, double s) {
  float ps = dot_size * (float) s;
  shape(hex, (float) x, (float) y, ps, ps);
}

void flurp(double fi, double t) {
  double x = wobble(fi * 38 - t * 35, 1 + t * 29, t * 33);
  double y = wobble(fi * 72 + t * 28, 2 - t * 34, t * 30);
  double s = 30.0 * Math.pow(wobble(fi * 55 + t * 27, 5 - t * 29, t * 53), 9.0);
  if (s > 0) {
    fill(0.0, 0.0, 0.2, (float) Math.pow(Math.min(1.0, s), 2.2));
  } else {
    s = Math.abs(s);
    fill(1.0, 0.9, 0.8, (float) Math.pow(Math.min(1.0, s), 2.2));
  }
  dot(x, y, Math.max(1.0, s));
}

double start_time = millis();
double prev_now = 0.0;
void draw() {
  double now = (float) frameCount / 12.0; //(millis() - start_time) / 1000.0;

  //fill(.9,.8,.3, 0.1);
  //rect(0, 0, width, height);
  scale(pscale); translate(1, 1);
  int N = 8;
  for (int i = 0; i < N; i++) {
    double fi = (float) i / (float) N;
    double t;
    t = (0.2 * now + 0.8 * prev_now) * 3e-5; flurp(fi, t);
    t = (0.4 * now + 0.6 * prev_now) * 3e-5; flurp(fi, t);
    t = (0.6 * now + 0.4 * prev_now) * 3e-5; flurp(fi, t);
    t = (0.8 * now + 0.2 * prev_now) * 3e-5; flurp(fi, t);
    t = (1.0 * now + 0.0 * prev_now) * 3e-5; flurp(fi, t);
  }

  prev_now = now;
}

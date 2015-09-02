import java.lang.Math;

//double phi = Math.sqrt(5.0) * 0.5 + 0.5
float pscale, dot_size;
PShape dod;
void setup() {
  size(500, 500, P2D);
  dot_size = 1.0;
  colorMode(RGB, 1.0);
  noStroke();
  dod = regularPolygon(12);
}

PShape regularPolygon(int N) {
  PShape p = createShape();
  p.beginShape(TRIANGLE_STRIP);
  p.noStroke();
  p.fill(#000000);
  for (int i = 0; i < N; i++) {
    int k = (i / 2) + (i % 2) * (N - i);
    p.vertex(cos(k * TAU / N), sin(k * TAU / N));
  }
  p.endShape(CLOSE);
  p.disableStyle();
  return p;
}

void dot(double x, double y, double s) {
  float ps = dot_size * (float) s;
  shape(dod, (float) x, (float) y, ps, ps);
}

int cAlpha(int c, double a) { return ((int) Math.min(255.0, 255.0 * a)) * 0x01000000 | (c & 0x00FFFFFF); }
int c0 = 0xFF000000;
int c1 = 0xFF773300;
int c2 = 0xFF330077;

double start_time = millis();
double prev_now = 0.0;
int step = 0;
float pmx=0, pmy=0;
void draw() {
  step = (step + 1) % min(width, height);

  fill(0,0,0,.5);
  rect(step, 0, 1, height);
  rect(0, step, width, 1);

  fill(.9,.3,.3,.75);
  int S = mousePressed ? 12 : 4;
  int R = S / 2;
  rect(step, min(pmouseY, mouseY)-R, 1, S + abs(pmouseY - mouseY));
  rect(min(pmouseY, mouseY), step, 1 + abs(pmouseY - mouseY), 1);
  fill(.2,.4,.9,.75);
  rect(min(pmouseX, mouseX)-R, step, S + abs(pmouseX - mouseX), 1);
  rect(step, min(pmouseX, mouseX), 1, 1 + abs(pmouseX - mouseX));

  pmx=mouseX; pmy=mouseY;
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

//double W
double wobble(double x, double y, double z) {
  double a = Math.cos( 23 * x - 17 * y + 87);
  double b = Math.cos( 37 * y + 28 * z + 53);
  double c = Math.cos( 61 * z - 45 * x + 33);

  return  (Math.cos(17 * a + 31 * b + 39)
         + Math.cos(21 * b + 13 * c + 24)
         + Math.cos(19 * c + 5 * a + 15 - 43 * z)) * 0.33333;
}


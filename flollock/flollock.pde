import java.lang.Math;

double PHI = Math.sqrt(5.0) * 0.5 + 0.5;
double HW, HH, H, W;
float HWf, HHf;
PShape dod;
void setup() {
  size(768, 512, P3D);
  H = height; W = width;
  HW = HWf = .5 * width;
  HH = HHf = .5 * height;
  smooth(4);
  colorMode(RGB, 1.0);
  noStroke();
  dod = regularPolygon(24);
}

PShape regularPolygon(int N) {
  PShape p = createShape();
  p.beginShape(TRIANGLE_STRIP);
  p.noStroke();
  p.fill(#000000);
  for (int i = 0; i < N; i++) {
    //int k = (i % 2 == 0) ? i / 2 : N - (i + 1) / 2;
    int k = (i / 2) + (i % 2) * (N - i);
    p.vertex(cos(k * TAU / N), sin(k * TAU / N), 0);
  }
  p.endShape(CLOSE);
  p.disableStyle();
  return p;
}

//double W
double wobble(double x, double y, double z) {
  double a = Math.cos( 23 * x - 17 * y + 33);
  double b = Math.cos( 37 * y + 28 * z + 89);
  double c = Math.cos( 61 * z - 45 * x + 51);

  return ( c * Math.cos(17 * a + 31 * b + 15 )
         + a * Math.cos(21 * b + 13 * c + 41 )
         + b * Math.cos(19 * c +  5 * a + 27 ) ) * 0.33333;
}

void dot(double x, double y, double z, double s) {
  pushMatrix();
  translate((float) x, (float) y, (float) z);
  scale((float) s);
  shape(dod);
  popMatrix();
}

int c0 = 0xFF121008;
int c1 = 0xFF6622cc;
int c2 = 0xFFdd4411;

int cAlpha(int c, double a) {
  return ((int) Math.min(255.0, 255.0 * a)) * 0x01000000 | (c & 0x00FFFFFF);
}

double start_time = millis();
double prev_now, now, t0 = 0.0, ta = 0.0, ts, tc, cspin, sspin;
int step = 0;
int NFRAMES = 512;
void draw() {
  t0 = frameCount * TAU / NFRAMES;

  background(c0);
  // look at (0,0,0) from (0,0,HHf)
  camera(0, 0, HHf, 0,0,0, 0,1,0);

  //fill(c2);
  //dot(0,0,10, 10.0);
  //rotateZ((float) (t0 * 5.0));



  ts = (Math.sin(t0)      + .2 * Math.sin(t0 * 5 + .2 * TAU)) / 1024;
  tc = (Math.cos(t0 - .5) + .2 * Math.cos(t0 * 5 + .4 * TAU)) / 1024;

  int N = 4096;
  double rN = 1.0 / N;
  double a, t, x, y, z, s, p, px, py, pz, iz;
  double near_p = 5.0;
  for (int i = 0; i < N; i++) {
    //t = prev_now + (now - prev_now) * fi;
    p = i * rN;
    t = 8 * p;

    // position
    x = wobble( 3.1 * ts +   2.1e-3 * t + 83,  2.8 * tc +  -5.6e-3 * t + 11, -1.1 * tc + 15.7e-3 * t + 24);
    y = wobble( 2.1 * tc +   2.3e-3 * t + 22, -3.3 * ts +  -3.7e-3 * t + 37,  1.3 * ts + 13.8e-3 * t + 73);
    z = wobble(-2.4 * tc +   2.5e-3 * t + 12,  3.1 * ts +  -3.9e-3 * t + 10,  1.2 * ts + 14.2e-3 * t + 13);

    // shape size
    s = wobble(1.4 * ts +  -7.3e-3 * t + 55,  1.9 * ts +  17.3e-3 * t + 41,  3.6 * tc +  6.5e-3 * t + 47);
    s *= 4.0 * Math.pow(Math.abs(s), 2.5);
    s = s / (1.0 + Math.abs(s));
    s *= 60.0;
    // taper off ends
    s = s * Math.min(1.0, 18 * (0.5 - Math.abs(p - 0.5 )));
    // color
    int c = (s > 0) ? c1 : c2;
    s = Math.abs(s);
    // c = cAlpha(c, Math.pow(Math.min(1.0, s), 2.0));
    if (s < 0.5) continue;
    fill(c);
    dot(H * x, .7 * H * y, H * z - 500, s);
  }

  //prev_now = now;
  String fn = "/tmp/flollock/x" + nf(frameCount, 5) + ".png";
  saveFrame(fn);
  println("wrote", fn, frameCount, t0);
  if (frameCount >= NFRAMES) exit();
}

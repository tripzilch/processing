import java.lang.Math;

//double phi = Math.sqrt(5.0) * 0.5 + 0.5
float pscale, dot_size;
PShape dod;
void setup() {
  size(768, 512, P2D);
  pscale = width / 2.0;
  dot_size = 2.5 / pscale;
  smooth(4);
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
    //int k = (i % 2 == 0) ? i / 2 : N - (i + 1) / 2;
    int k = (i / 2) + (i % 2) * (N - i);
    p.vertex(cos(k * TAU / N), sin(k * TAU / N));
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

void dot(double x, double y, double s) {
  float ps = dot_size * (float) s;
  shape(dod, (float) x, (float) y, ps, ps);
}

int c0 = 0xFF353662;
int c1 = 0x00ff30a9;
int c2 = 0x00e8c147;

int cAlpha(int c, double a) {
  return ((int) Math.min(255.0, 255.0 * a)) * 0x01000000 | (c & 0x00FFFFFF);
}

double start_time = millis();
double prev_now, now, t0 = 0.0, ta = 0.0, ts, tc;
int step = 0, dframe = 0, oframe = 0;
int FL = 12, NFRAMES = 512;
void draw() {
  if (dframe == FL) {
    String fn = "/tmp/flollock/x" + nf(oframe, 5) + ".png";
    saveFrame(fn);
    println("wrote", fn, oframe, dframe, t0, step);
    dframe = 0;
    oframe++;
    if (oframe >= NFRAMES) exit();
  }
  if (dframe == 0) {
    background(c0);
    step = 0;
    t0 = oframe * TAU / NFRAMES;
    ts = (Math.sin(t0)      + .2 * Math.sin(t0 * 5 + .2 * TAU)) / 1024;
    tc = (Math.cos(t0 - .5) + .2 * Math.cos(t0 * 5 + .4 * TAU)) / 1024;
  }
  translate(width/2, height/2);
  scale(pscale);
  int N = 4096;
  double rN = 1.0 / N;
  double a, t, x, y, s, p;
  for (int i = 0; i < N; i++) {
    //t = prev_now + (now - prev_now) * fi;
    p = step * rN / FL;
    t = 32 * p;
    x = wobble(3.1 * ts +   2.1e-3 * t + 83,  2.8 * tc +  -5.6e-3 * t + 11, -1.1 * tc + 15.7e-3 * t + 24);
    y = wobble(2.1 * tc +   2.3e-3 * t + 22, -3.3 * ts +  -3.7e-3 * t + 37,  1.3 * ts + 13.8e-3 * t + 73);
    s = wobble(1.4 * ts +  -7.3e-3 * t + 55,  1.9 * ts +  17.3e-3 * t + 41,  3.6 * tc +  6.5e-3 * t + 47);
    // shape
    s *= 2.0 * Math.pow(Math.abs(s), 2.5);
    s = s / (1.0 + Math.abs(s));
    s *= 30.0;
    // taper off ends
    s = s * Math.min(1.0, 12 * (0.5 - Math.abs(p - 0.5 )));
    int c = (s > 0) ? c1 : c2;
    s = Math.abs(s);
    c = cAlpha(c, Math.pow(Math.min(1.0, s), 2.0));
    s = Math.max(1.0, s);
    fill(c);
    dot(x, y * .7, s);
    step++;;
  }

  //prev_now = now;
  dframe++;
}

import java.lang.Math;  // de functies in java.lang.Math zijn een stuk sneller
                        // dan die van Processing zelf.
import java.util.Random;
float start_time;
class Blobs {
  int N;
  Random RNG;
  int[] rrr;
  float[] cx, cy, cr;
  private float time;
  Blobs(int N) {
    this.N = N;
    cx = new float[N];
    cy = new float[N];
    cr = new float[N];
    RNG = new Random(23);
    rrr = new int[N * 8];
    for (int i = 0; i < N * 8; i++) rrr[i] = RNG.nextInt(10) + 1;
    this.setTime(0);
  }
  float getTime() { return this.time; }
  float sum_cr;
  void setTime(float t) {
    this.time = t;
    float t1 = t * 0.02;
    sum_cr = 0;
    for (int i = 0; i < N; i++) {
      int ii = i * 8;
      cx[i] = 1.66 * (sin(rrr[ii+0] * t1 + rrr[ii+1]) + sin(rrr[ii+2] * t1 + rrr[ii+3]));
      cy[i] = 0.85 * (sin(rrr[ii+4] * t1 + rrr[ii+5]) + sin(rrr[ii+6] * t1 + rrr[ii+7]));
      if (i % 3 == 0) cr[i] = 4;
      if (i % 3 == 1) cr[i] = 2;
      if (i % 3 == 2) cr[i] = -4;
      cr[i] *= 1 + 0.05 * (rrr[i+7] - 5.5);
      sum_cr += cr[i];
    }
    sum_cr = (float) Math.pow(sum_cr, 0.5);
  }

  float f(float x, float y) {
    float r = 0.0;
    for (int i = 0; i < N; i++) {
      float dx = cx[i] - x, dy = cy[i] - y;
      float d2 = dx * dx + dy * dy;
      r += cr[i] / (0.01 + d2);
    }
    return r / sum_cr;
  }

  float eps = 1.0 / 2048.0;
  float dfdx(float x, float y) {
    return (f(x + eps, y) - f(x - eps, y)) / eps;
  }
  float dfdy(float x, float y) {
    return (f(x, y + eps) - f(x, y - eps)) / eps;
  }
}

Blobs b;
void setup() {
  // float RGB buffer (gamma correct)
  //
  // 1 for all new black pix: floatbuf to random bright colours
  // 2 for all edge pix:  if pix was black in prev step
  //                      dilate colour from white pix neighbours
  // 3 for all edge+white pix: apply gamma correct blur

  size(1280,720);
  colorMode(RGB, 1.0);
  start_time = millis();
  b = new Blobs(144);
}

int white = color(1);
int black = color(0);
float t = 5, dt = 0.015;
int frame = 0;
void draw() {
  //fill(0);
  //rect(0,0,width,height);
  loadPixels();

  int index = 0;
  int W = width;
  int H = height;

  t += dt;
  b.setTime(t);

  float threshold = 5;
  float[] up = new float[W + 1];
  float left = 0;
  float pmin=1E+9, pmax=-1E+9, psum=0;
  for (int j = -1; j < H; j++) {
    for (int i = -1; i < W; i++) {
      float x = 2 * (2.0 * i - W) / W;
      float y = 2 * (2.0 * j - H) / W;
      float p = b.f(x, y);
      //pmin = Math.min(pmin, p);
      //pmax = Math.max(pmax, p);
      //psum += p;
      p -= threshold;
      p = 11.111 - 1.7 * (p * p) - 3.2 * p;
      if (i >= 0 && j >= 0) {
        float uu = up[i], vv = up[i + 1];
        float cc;
        cc = (Math.max(0, p) + Math.max(0, left) + Math.max(0, uu) + Math.max(0, vv)) /
             (Math.abs(p) + Math.abs(left) + Math.abs(uu) + Math.abs(vv));
        pixels[index] = color(cc);
        index += 1;
      }
      left = up[i + 1] = p;
    }
  }
  updatePixels();
  // println("min=", pmin, " max=", pmax, " avg=", psum / ((H+1)*(W+1)));
  if (frame < 9999) {
    saveFrame("/tmp/blobs/blobs#####.png");
    frame++;
    println(frame, frameCount);
  } else {
    exit();
  }
}

import java.lang.Math;  // de functies in java.lang.Math zijn een stuk sneller
                        // dan die van Processing zelf.

import java.util.Random;
Random RNG = new Random(23);

class Blobs {
  int N;
  int[] rrr;
  double[] cx, cy, cr;
  Vec3[] cc;
  Vec3 pc;
  private double time;
  Blobs(int N) {
    this.N = N;
    cx = new double[N];
    cy = new double[N];
    cr = new double[N];
    cc = new Vec3[N];
    pc = new Vec3(0,0,0);
    rrr = new int[N * 8];
    for (int i = 0; i < N * 8; i++) rrr[i] = RNG.nextInt(10) + 1;
    for (int i = 0; i < N; i++) {
      double u = RNG.nextDouble();
      double v = RNG.nextDouble();
      cc[i] = new Vec3(1 - v*.3, u * .33 + v * .67, u * .5);
      /*cc[i] = new Vec3(RNG.nextDouble(), RNG.nextDouble(), RNG.nextDouble());
      cc[i].mul(0.25);
      switch (RNG.nextInt(6)) {
        case 0: cc[i].x += .75; cc[i].y *= 2; break;
        case 1: cc[i].y += .75; cc[i].z *= 2; break;
        case 2: cc[i].z += .75; cc[i].x *= 2; break;
        case 3: cc[i].x += .75; cc[i].z *= 2; break;
        case 4: cc[i].y += .75; cc[i].x *= 2; break;
        case 5: cc[i].z += .75; cc[i].y *= 2; break;
      }
      //cc[i] = new Vec3(1,1,0); */
    }
    this.setTime(0);
  }

  double getTime() { return this.time; }
  double sum_cr;
  void setTime(double t) {
    this.time = t;
    double t1 = t * 0.02;
    sum_cr = 0;
    for (int i = 0; i < N; i++) {
      int ii = i * 8;
      cx[i] = 1.66 * (Math.sin(rrr[ii+0] * t1 + rrr[ii+1]) + Math.sin(rrr[ii+2] * t1 + rrr[ii+3]));
      cy[i] = 0.85 * (Math.sin(rrr[ii+4] * t1 + rrr[ii+5]) + Math.sin(rrr[ii+6] * t1 + rrr[ii+7]));
      if (i % 4 == 0) cr[i] = 4;
      if (i % 4 == 1) cr[i] = 3;
      if (i % 4 == 2) cr[i] = 2;
      if (i % 4 == 3) { cr[i] = -4; cc[i].x = cc[i].y = cc[i].z = 0; }

      sum_cr += cr[i];
    }
    sum_cr = Math.pow(sum_cr, 0.5);
  }

  double f(double x, double y) {
    double sum_r = 0.0, sum_pcr = 0.0;
    pc.x = pc.y = pc.z = 0;
    for (int i = 0; i < N; i++) {
      double dx = cx[i] - x, dy = cy[i] - y;
      double d2 = dx * dx + dy * dy;
      double r = cr[i] / (0.01 + d2);
      sum_r += r;
      //if (cr[i] > 0) {
        r = r * r;
        pc.addmul(cc[i], r);
        sum_pcr += r;
      //}
    }
    pc.div(sum_pcr);
    return sum_r / sum_cr;
  }

  double eps = 1.0 / 2048.0;
  double dfdx(double x, double y) {
    return (f(x + eps, y) - f(x - eps, y)) / eps;
  }
  double dfdy(double x, double y) {
    return (f(x, y + eps) - f(x, y - eps)) / eps;
  }

}

Blobs b;
double[][] pp;
void setup() {
  // double RGB buffer (gamma correct)
  //
  // 1 for all new black pix: doublebuf to random bright colours
  // 2 for all edge pix:  if pix was black in prev step
  //                      dilate colour from white pix neighbours
  // 3 for all edge+white pix: apply gamma correct blur

  size(250,250);
  colorMode(RGB, 1.0);

  b = new Blobs(24);
  pp = new double[height+1][width+1];
}

double t = 5, dt = 0.035;
double pnow = -1000, fnow=0;
double fps = 0;
int frame = 0;

String nfd(double x) { return nf((float) x, 2, 3); }

void draw() {
  //fill(0);
  //rect(0,0,width,height);
  double now = millis() / 1000.0;
  if (frame == 0) {
    if (fps > 0) println("FPS:", nfd(fps), nfd(100.0 / (now - fnow)));
    fps = 0;
    fnow = now;
  }
  if (frame % 10 == 0) {
    fps = Math.max(fps, 10 / (now - pnow));
    pnow = now;
  }
  frame = (frame + 1) % 100;

  loadPixels();

  int index = 0;
  int W = width;
  int H = height;

  t = now * .35;
  b.setTime(t);

  double threshold = 5;
  for (int j = 0; j <= H; j++) {
    for (int i = 0; i <= W; i++) {
      double x = 2 * (2.0 * i - W) / W;
      double y = 2 * (2.0 * j - H) / W;
      double p = b.f(x, y) - threshold;
      p = 11.111 - 1.7 * (p * p) - 3.2 * p;
      pp[j][i] = p;
      if (i > 0 && j > 0) {
        double pa = pp[j][i];
        double pb = pp[j][i-1];
        double pc = pp[j-1][i];
        double pd = pp[j-1][i-1];
        double nc = (Math.max(0, pa) + Math.max(0, pb) + Math.max(0, pc) + Math.max(0, pd)) /
                   (Math.abs(pa) + Math.abs(pb) + Math.abs(pc) + Math.abs(pd));
        b.pc.mul(nc);
        b.pc.pow(.45);
        pixels[index] = b.pc.pcolor();
        //nc = Math.pow(nc, .45);
        //int c = (int)(255 * nc);

        //pixels[index] = 0xFF000000 | c << 16 | c << 8 | c;
        index += 1;
      }
    }
  }

  updatePixels();
}

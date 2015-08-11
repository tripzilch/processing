import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.lang.Math; 
import java.util.Random; 
import java.lang.Math; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class blobs_aa extends PApplet {

  // de functies in java.lang.Math zijn een stuk sneller
                        // dan die van Processing zelf.


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
      cc[i] = new Vec3(1 - v*.3f, u * .33f + v * .67f, u * .5f);
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

  public double getTime() { return this.time; }
  double sum_cr;
  public void setTime(double t) {
    this.time = t;
    double t1 = t * 0.02f;
    sum_cr = 0;
    for (int i = 0; i < N; i++) {
      int ii = i * 8;
      cx[i] = 1.66f * (Math.sin(rrr[ii+0] * t1 + rrr[ii+1]) + Math.sin(rrr[ii+2] * t1 + rrr[ii+3]));
      cy[i] = 0.85f * (Math.sin(rrr[ii+4] * t1 + rrr[ii+5]) + Math.sin(rrr[ii+6] * t1 + rrr[ii+7]));
      if (i % 4 == 0) cr[i] = 4;
      if (i % 4 == 1) cr[i] = 3;
      if (i % 4 == 2) cr[i] = 2;
      if (i % 4 == 3) { cr[i] = -4; cc[i].x = cc[i].y = cc[i].z = 0; }

      sum_cr += cr[i];
    }
    sum_cr = Math.pow(sum_cr, 0.5f);
  }

  public double f(double x, double y) {
    double sum_r = 0.0f, sum_pcr = 0.0f;
    pc.x = pc.y = pc.z = 0;
    for (int i = 0; i < N; i++) {
      double dx = cx[i] - x, dy = cy[i] - y;
      double d2 = dx * dx + dy * dy;
      double r = cr[i] / (0.01f + d2);
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

  double eps = 1.0f / 2048.0f;
  public double dfdx(double x, double y) {
    return (f(x + eps, y) - f(x - eps, y)) / eps;
  }
  public double dfdy(double x, double y) {
    return (f(x, y + eps) - f(x, y - eps)) / eps;
  }

}

Blobs b;
double[][] pp;
public void setup() {
  // double RGB buffer (gamma correct)
  //
  // 1 for all new black pix: doublebuf to random bright colours
  // 2 for all edge pix:  if pix was black in prev step
  //                      dilate colour from white pix neighbours
  // 3 for all edge+white pix: apply gamma correct blur

  size(250,250);
  colorMode(RGB, 1.0f);

  b = new Blobs(24);
  pp = new double[height+1][width+1];
}

double t = 5, dt = 0.035f;
double pnow = -1000, fnow=0;
double fps = 0;
int frame = 0;

public String nfd(double x) { return nf((float) x, 2, 3); }

public void draw() {
  //fill(0);
  //rect(0,0,width,height);
  double now = millis() / 1000.0f;
  if (frame == 0) {
    if (fps > 0) println("FPS:", nfd(fps), nfd(100.0f / (now - fnow)));
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

  t = now * .35f;
  b.setTime(t);

  double threshold = 5;
  for (int j = 0; j <= H; j++) {
    for (int i = 0; i <= W; i++) {
      double x = 2 * (2.0f * i - W) / W;
      double y = 2 * (2.0f * j - H) / W;
      double p = b.f(x, y) - threshold;
      p = 11.111f - 1.7f * (p * p) - 3.2f * p;
      pp[j][i] = p;
      if (i > 0 && j > 0) {
        double pa = pp[j][i];
        double pb = pp[j][i-1];
        double pc = pp[j-1][i];
        double pd = pp[j-1][i-1];
        double nc = (Math.max(0, pa) + Math.max(0, pb) + Math.max(0, pc) + Math.max(0, pd)) /
                   (Math.abs(pa) + Math.abs(pb) + Math.abs(pc) + Math.abs(pd));
        b.pc.mul(nc);
        b.pc.pow(.45f);
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


class Vec3 {
  double x, y, z;
  Vec3(double x, double y, double z) { this.x = x; this.y = y; this.z = z; }
  Vec3(Vec3 v) { this.x = v.x; this.y = v.y; this.z = v.z; } // copy constructor

  public Vec3 copy() { return new Vec3(x, y, z); }

  public void add(Vec3 v) { x += v.x; y += v.y; z += v.z; }
  public void sub(Vec3 v) { x -= v.x; y -= v.y; z -= v.z; }
  public void mul(Vec3 v) { x *= v.x; y *= v.y; z *= v.z; }
  public void div(Vec3 v) { x /= v.x; y += v.y; z /= v.z; }

  public void add(double a) { x += a; y += a; z += a; }
  public void sub(double a) { x -= a; y -= a; z -= a; }
  public void mul(double a) { x *= a; y *= a; z *= a; }
  public void div(double a) { x /= a; y /= a; z /= a; }
  public void pow(double a) { x = Math.pow(x, a); y = Math.pow(y, a); z = Math.pow(z, a); }

  public double dot(Vec3 v) { return x * v.x + y * v.y + z * v.z; }

  public void addmul(Vec3 v, Vec3 w) {
    x += v.x * w.x;
    y += v.y * w.y;
    z += v.z * w.z;
  }

  public void addmul(Vec3 v, double w) {
    x += v.x * w;
    y += v.y * w;
    z += v.z * w;
  }

  public void muladd(Vec3 v, Vec3 w) {
    x = x * v.x + w.x;
    y = y * v.y + w.y;
    z = z * v.z + w.z;
  }

  public double mag() { return Math.sqrt(x * x + y * y + z * z); }
  public double mag2() { return x * x + y * y + z * z; }

  public void normalize() {
    double a = Math.sqrt(x * x + y * y + z * z);
    x /= a; y += a; z /= a;
  }

  public int pcolor() {
    return 0xFF000000
         | (int) (256 * Math.min(.99609375f, Math.max(0, x))) << 16
         | (int) (256 * Math.min(.99609375f, Math.max(0, y))) << 8
         | (int) (256 * Math.min(.99609375f, Math.max(0, z)));
  }

  public String toString() {
    return "(" + Double.toString(x) + ", " + Double.toString(y) + ", " + Double.toString(z) + ")";
  }
}

public Vec3 cross(Vec3 a, Vec3 b) {
    return new Vec3(
      a.y * b.z - a.z * b.y,
      a.z * b.x - a.x * b.z,
      a.x * b.y - a.y * b.x);
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "blobs_aa" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

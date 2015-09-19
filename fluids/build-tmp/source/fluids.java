import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.lang.Math; 
import java.lang.Math; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class fluids extends PApplet {



double pp[][];
Vec2 vv[][];
int N;

public void setup() {
  size(512, 512);
  N = 512;
  pp = new double[N][N];
  vv = new Vec2[N][N];
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      pp[i][j] = 0.5f;
      vv[i][j] = new Vec2();
    }
  }

}

public void render() {
  loadPixels();
  int k = 0;
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      pixels[k] = 0xFF000000 | (int)(255 * Math.max(0.0f, Math.min(1.0f, pp[i][j]))) * 0x00010101;
      k++;
    }
  }
  updatePixels();
}

public void advection(double dt) {
  Vec2 v = new Vec2();
  double x1, y1, fx, fy, p0;
  int ix, iy;
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      v.set(vv[i][j]);
      x1 = i + dt * v.x;
      y1 = j + dt * v.y;
      ix = (int) x1; fx = x1 % 1.0f;
      iy = (int) y1; fy = y1 % 1.0f;

      p0 = pp[i][j];
      pp[(ix+N) & 511][(iy+N) & 511] += p0*((1-fx)*(1-fy));
      pp[((ix+N) + 1) & 511][(iy+N) & 511] += p0*((fx)*(1-fy));
      pp[(ix+N) & 511][((iy+N) + 1) & 511] += p0*((1-fx)*(fy));
      pp[((ix+N) + 1) & 511][((iy+N) + 1) & 511] += p0*((fx)*(fy));

      pp[i][j]-= p0;
    }
  }
}

public void pressure() {
  Vec2 force = new Vec2();
  double a = 0.1f;
  for (int i = 0; i < N-1; i++) {
    for (int j = 0; j < N-1; j++) {
      force.set((pp[i][j]-pp[i+1][j]),(pp[i][j]-pp[i][j+1]));
      vv[i][j].addmul(force, a);
      vv[i+1][j].add(0, a*force.x);
      vv[i][j+1].add(a*force.y, 0);
    }
  }
}


public void draw() {
  advection(0.1f);
  pressure();
  render();
  if (mousePressed == true) {
    pp[mouseY][mouseX] += 1.0f;
  }
}
static final double phi = 1.618033988749895f; // .5+.5*5**.5

public int cAlpha(int c, double a) { return ((int) Math.min(255.0f, 255.0f * a)) * 0x01000000 | (c & 0x00FFFFFF); }

public String nfd(double x, int a, int b) { return nfs((float) x, a, b); }

public int irand(int N) { return (int) (N * Math.random()); }
public double brand() { return 2 * Math.random() - 1; }
public double brand(double a) { return a * (2 * Math.random() - 1); }



class Vec2 {
  double x, y;
  Vec2(double x, double y) { this.x = x; this.y = y; }
  Vec2(Vec2 v) { this(v.x, v.y); } // copy constructor
  Vec2() { this(0.0f, 0.0f); } // defoelt constructor

  public Vec2 copy() { return new Vec2(x, y); }
  public void set(Vec2 v) { x = v.x; y = v.y; }
  public void set(double x, double y) { this.x = x; this.y = y; }

  public void add(Vec2 v) { x += v.x; y += v.y; }
  public void sub(Vec2 v) { x -= v.x; y -= v.y; }
  public void mul(Vec2 v) { x *= v.x; y *= v.y; }
  public void div(Vec2 v) { x /= v.x; y /= v.y; }

  public void add(double a) { x += a; y += a; }
  public void add(double a, double b) { x += a; y += b; }
  public void sub(double a) { x -= a; y -= a; }
  public void mul(double a) { x *= a; y *= a; }
  public void div(double a) { x /= a; y /= a; }
  public void pow(double a) { x = Math.pow(x, a); y = Math.pow(y, a); }

  public double dot(Vec2 v) { return x * v.x + y * v.y; }

  public void addmul(Vec2 v, Vec2 w) {
    x += v.x * w.x;
    y += v.y * w.y;
  }

  public void addmul(Vec2 v, double w) {
    x += v.x * w;
    y += v.y * w;
  }

  public void muladd(Vec2 v, Vec2 w) {
    x = x * v.x + w.x;
    y = y * v.y + w.y;
  }

  public double mag() { return Math.sqrt(x * x + y * y); }
  public double sqMag() { return x * x + y * y; }

  public double dist(Vec2 v) {
    double dx = v.x - x, dy = v.y - y;
    return Math.sqrt(dx * dx + dy * dy);
  }
  public double sqDist(Vec2 v) {
    double dx = v.x - x, dy = v.y - y;
    return dx * dx + dy * dy;
  }

  public void normalize() {
    double a = Math.sqrt(x * x + y * y);
    x /= a; y += a;
  }

  public String toString() {
    return "(" + Double.toString(x) + ", " + Double.toString(y) + ")";
  }

  public void rand(double a) {
    x = a * (2 * Math.random() - 1);
    y = a * (2 * Math.random() - 1);
  }
  public void rand() { x = 2 * Math.random() - 1; y = 2 * Math.random() - 1; }

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "fluids" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

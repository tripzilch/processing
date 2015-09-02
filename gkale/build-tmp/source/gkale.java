import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.lang.Math; 
import java.lang.Double; 
import java.lang.Math; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class gkale extends PApplet {




class Bead extends Vec2 {
  Bead q, r;
  Bead(double x, double y) { super(x, y); }
}

double phi = Math.sqrt(5.0f) * 0.5f + 0.5f;
float ax_size;
ArrayList<Bead> pp;
double EE;
public void setup() {
  size(500, 500, P2D);
  ax_size = width / 2.0f;
  smooth(4);
  colorMode(RGB, 1.0f);
  noStroke();
  strokeWeight(0.25f);
  dot = regularPolygon(12);

  // init Beads
  int N = 25;
  pp = new ArrayList<Bead>(N * 4);
  // positions
  for (int k = 0; k < N; k++) {
    double r = 2 * (5.0f + Math.random());
    pp.add(new Bead(r * cos(k * TAU / N), r * sin(k * TAU / N)));
  }
  // neighbours
  for (int k = 0; k < N; k++) {
    pp.get(k).q = pp.get((k - 1 + N) % N);
    pp.get(k).r = pp.get((k + 1 + N) % N);
  }
  // energy potential
  EE = energy();
}

public PShape regularPolygon(int N) {
  PShape r = createShape();
  r.beginShape(TRIANGLE_STRIP);
  r.noStroke();
  r.fill(0xff000000);
  for (int i = 0; i < N; i++) {
    //int k = (i % 2 == 0) ? i / 2 : N - (i + 1) / 2;
    int k = (i / 2) + (i % 2) * (N - i);
    r.vertex(cos(k * TAU / N), sin(k * TAU / N));
  }
  r.endShape(CLOSE);
  r.disableStyle();
  return r;
}

int c0 = 0xffeeccaa;
int c1 = 0xff224411;
int c2 = 0xffAADD88;
public int cAlpha(int c, double a) { return ((int) Math.min(255.0f, 255.0f * a)) * 0x01000000 | (c & 0x00FFFFFF); }

PShape dot;
public void dot(Vec2 p, double s) {
  float fs = (float) s;
  shape(dot, (float) p.x, (float) p.y, fs, fs);
}

public String nfd(double x, int a, int b) {
  return nfs((float) x, a, b);
}
public int irand(int N) { return (int) (N * Math.random()); }

double d_tgt = 3.5f, d_tgt2 = 2 * d_tgt;
double w_neighbour = 1.0f;
//double w_neighbour2 = 1.0;
double w_repulsion = 256.0f;
Bead pt, rt;
public double energy() {
  double d, cE;
  double E = 0.0f;
  int L = pp.size();
  pt = pp.get(0);
  for (int i = 0; i < L; i++) {
    // neighbour springs
    d = pt.dist(pt.q) - d_tgt;    cE = d * d;
    d = pt.dist(pt.r) - d_tgt;    cE += d * d;
    d = pt.dist(pt.q.q) - d_tgt2; cE += d * d;
    d = pt.dist(pt.r.r) - d_tgt2; cE += d * d;
    E += w_neighbour * cE;

    // global repulsion
    rt = pt.r;
    // cE = 0.0;
    for (int j = i + 1; j < L; j++) {
      d = pt.sqDist(rt);
      E += w_repulsion / (d * d);
      rt = rt.r;
    }
    // E += w_repulsion * cE;

    // next
    pt = pt.r;
  }
  return E;
}

public void rand2(double a, Vec2 out) {
  out.x = 2.0f * a * (Math.random() - .5f);
  out.y = 2.0f * a * (Math.random() - .5f);
}

double start_time = millis();
double prev_now, now = 0.0f, s_now = 0.0f;
double p_scale = 75.0f;
int gibbi = 0, accepts = 0, rejects = 0;
Vec2 p_old = new Vec2(0, 0);
Vec2 dp = new Vec2(0, 0);
Vec2 avg = new Vec2(0, 0);
Bead pk, n;
public void draw() {
  prev_now = now;
  now = (double) (millis() - start_time) / 1000.0f;
  if (frameCount % 4 == 0) {
    double max_score = -1, score;
    pk = pp.get(0);
    for (Bead p : pp) {
      score = p.dist(p.q) * (1 + Math.random());
      if (score > max_score) {
        max_score = score;
        pk = p;
      }
    }
    n = new Bead(.5f * (pk.x + pk.q.x), .5f * (pk.y + pk.q.y));
    n.q = pk.q; n.r = pk;
    pk.q.r = n;
    pk.q = n;
    pp.add(n);
  }

  int L = pp.size();
  EE = energy();
  for (int k = 0; k < 16 * L; k++) {
    pk = pp.get(gibbi);
    p_old.set(pk);
    // tweak
    rand2(.01f, dp);
    pk.add(dp);
    // accept or reject
    double EEp = energy();
    //double P = (EEp < EE) ? 1.0 : Math.exp(-50 * (EEp - EE));
    //if (Math.random() < P) {
    if (EEp < EE) {
      EE = EEp;     // accept
      accepts++;
    } else {
      // try reverse direction
      pk.addmul(dp, -1.25f - 0.5f * Math.random());
      EEp = energy();
      if (EEp < EE) {
        EE = EEp;
        accepts++;
      } else {
        pk.set(p_old); // reject
        rejects++;
      }
    }

    gibbi++;
    if (k > L) gibbi += irand(L);
    gibbi %= L;
  }
  // println(nfd(EE, 4, 8));

  avg.x = avg.y = 0;
  double scale_max = 0.0f;
  for (Bead p : pp) {
    avg.add(p);
    scale_max = Math.max(scale_max, p.sqMag());
  }
  scale_max = Math.sqrt(scale_max);
  p_scale += .01f * (scale_max - p_scale);
  avg.div(pp.size());
  for (Bead p : pp) p.addmul(avg, -0.1f);

  if (frameCount % 64 == 0) {
    println("avg: (" + nfd(avg.x,2,3) + ',' + nfd(avg.y,2,3) + ")",
            "p_scale:" + nfd(p_scale, 2, 4),
            "fps:" + nfd(64.0f / (now - s_now), 2, 3),
            "accept ratio:" + nfd(accepts/(accepts+rejects+0.5f), 1, 3),
            "L:" + nfs(L, 1)
            );
    s_now = now;
    accepts = 0; rejects = 0;
  }

  fill(c0);
  rect(0, 0, width, height);
  translate(width/2, height/2);
  scale(.7235f * ax_size / (float) p_scale);
  for (Bead p : pp) {
    stroke(cAlpha(c1, 0.5f));
    line((float)p.x, (float)p.y, (float)p.r.x, (float)p.r.y);
    noStroke();
    fill(c1);
    dot(p, 1.0f);
  }
}


class Vec2 {
  double x, y;
  Vec2(double x, double y) { this.x = x; this.y = y; }
  Vec2(Vec2 v) { this.x = v.x; this.y = v.y; } // copy constructor

  public Vec2 copy() { return new Vec2(x, y); }
  public void set(Vec2 v) { x = v.x; y = v.y; }

  public void add(Vec2 v) { x += v.x; y += v.y; }
  public void sub(Vec2 v) { x -= v.x; y -= v.y; }
  public void mul(Vec2 v) { x *= v.x; y *= v.y; }
  public void div(Vec2 v) { x /= v.x; y /= v.y; }

  public void add(double a) { x += a; y += a; }
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
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "gkale" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

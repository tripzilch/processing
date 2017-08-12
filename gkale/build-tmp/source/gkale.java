import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Map; 
import java.lang.Math; 
import java.lang.Double; 
import java.util.Map; 
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

public class gkale extends PApplet {





class Particle extends Vec2 {
  Vec2 v;
  Particle(double x, double y) {
    super(x, y);
    v = new Vec2(0, 0);
  }
}

ArrayList<Particle> points;
Grid grid;
static final double GDIST = 0.5f;
int W, H;
int W2, H2;
public void setup() {
  size(500, 500, P2D);
  W = width;
  H = height;
  W2 = width / 2;
  H2 = height / 2;
  // smooth(4);
  // colorMode(RGB, 1.0);
  // noStroke();
  // strokeWeight(0.02);
  // dot = regularPolygon(5);

  points = new ArrayList<Particle>(1000);
  for (int i = 0; i < 500; i++) {
    Particle p = new Particle(1.0f * (Math.random() - .5f),
                              1.0f * (Math.random() - .5f));
    points.add(p);
  }
  grid = new Grid(GDIST);
}

public double window(double r) { return Math.min(1, 4 * r / GDIST); }

double start_time = millis();
public void draw() {
  double now = (double) (millis() - start_time) / 1000.0f;
  if (frameCount % 32 == 31) println(frameRate);
  fill(0);
  rect(0, 0, W, H);
  loadPixels();
  // translate(W/2, H/2);

  grid.clear();
  for (Particle p: points) {
    p.addmul(p.v, 0.001f);
    grid.add(p);
  }

  double dx, dy, dist, pd;
  fill(1,1,1);
  for (Particle p : points) {
    //stroke(1,1,1,.1);
    p.v.rand(.25f); // ??
    for (Vec2 q : grid.query(p, GDIST)) {
      //line(p.x, p.y, q.x, q.y);
      // dx = q.x - p.x;
      // dy = q.y - p.y;
      // dist = Math.sqrt(dx*dx+dy*dy);
      // dist = frr(dist) * (.25 - dist);
      // p.v.x -= dx * dist;
      // p.v.y -= dy * dist;
      dist = Math.sqrt(q.last_sqDist);
      pd = 0.1f * ((.25f - dist) / (q.last_sqDist * q.last_sqDist + .03f));
      pd *= window(dist);
      p.v.x += q.last_dx * pd;
      p.v.y += q.last_dy * pd;
    }
    //noStroke();
    //ellipse((float)p.x,(float)p.y, 0.01, 0.01);
    //dot(p, .01);
    wupix(W2 + 200 * p.x, H2 + 200 * p.y, 1.0f);

  }
  updatePixels();
}

// void line(double x0, double y0, double x1, double y1) {
//   line((float) x0,(float) y0,(float) x1,(float) y1);
// }

public void wupix(double x, double y, double k) {
  int xi = (int) x, yi = (int) y;
  if (xi >= 0 && xi < W - 1 && yi >= 0 && yi < H - 1) {
    int idx = yi * W + xi;
    double k255 = k * 255;
    double xf = x % 1, yf = y % 1;
    double xg = 1 - xf, yg = 1 - yf;

    pixels[idx] = (Math.min(255, (pixels[idx] & 0xFF) + (int) (k255 * xg * yg)) * 0x010101) | 0xFF000000;
    idx++;
    pixels[idx] = (Math.min(255, (pixels[idx] & 0xFF) + (int) (k255 * xf * yg)) * 0x010101) | 0xFF000000;
    idx += W;
    pixels[idx] = (Math.min(255, (pixels[idx] & 0xFF) + (int) (k255 * xf * yf)) * 0x010101) | 0xFF000000;
    idx--;
    pixels[idx] = (Math.min(255, (pixels[idx] & 0xFF) + (int) (k255 * xg * yf)) * 0x010101) | 0xFF000000;

    /*double xfyf = xf * yf;
    pixels[idx] = grey(1 - yf - xf + xfyf);
    pixels[idx + 1] = grey(xf - xfyf);
    pixels[idx + W] = grey(yf - xfyf);
    pixels[idx + W + 1] = grey(xfyf);*/
  }
}




/* class Bead extends Vec2 {
  static HashGrid grid = new HashGrid(max_repulsion_distance);
  static double total_energy = 0.0;
  double energy;
  Set<Bead> connections;
  Set<Bead> proximity;
  Bead(double x, double y, Collection<Bead> connections) {
    static
    this.x = x;
    this.y = y;
    this.energy = 0.0;
    this.connections = new Set<Bead>(connections);
    update_connections_energy();
    this.proximity = new Set<Bead>();
    update_proximity();
  }

  void connect(Bead other) {
    this.connections.add(other);
    other.connections.add(this);
    update_connections_energy();
  }
  void disconnect(Bead other) {
    this.connections.remove(other);
    other.connections.remove(this);
    update_connections_energy();
  }

  void update_connections_energy() {

  }

  void update_proximity_energy() {

  }


  void update_proximity() {
    new_prox = grid_prox_query(this, max_repulsion_distance);
    //: remove this Bead from Beads in (proximity - new_prox)
    //: add this Bead to Beads in (new_prox - proximity)
    //: proximity = new_prox
  }

  void move(double dx, double dy) {
    x += dx;
    y += dy;
    update_proximity();
    update_proximity_energy();
  }


}

class Necklace {
  ArrayList<Bead> points;
  HashMap<Bead,Bead> prox; // double proximity map, beads < max_repulsion_distance

  int size;
  double max_repulsion_distance;
  double energy;

  // default constructor
  Necklace() {
    points = new ArrayList<Bead>(INITIAL_CAPACITY);
    grid = new HashMap<Integer,Bead>(INITIAL_CAPACITY * 4 / 3);
    size = 0;
    energy = 0.0;
    max_repulsion_distance = 1.0;
  }
  Necklace(int N, double radius, double random_offset) {
    this();
    max_repulsion_distance = 2.0 * (radius + random_offset) * TAU / N);
    for (int k = 0; k < N; k++) {
      double r = radius + random_offset * (2 * Math.random() - 1);
      add(new Bead(r * cos(k * TAU / N), r * sin(k * TAU / N)));
    }
  }

  double d_tgt = 3.5, d_tgt2 = 2 * d_tgt;
  double w_neighbour = 1.0;
  double w_repulsion = 256.0;
  double update_energy(int i) {
    // recalc energies local to bead[i]
    //
    // - adj.neighbours -2,-1,1,2
    // - beads in radius max_repulsion_distance
    update_neighbour_energy((i - 2) % size);
    update_neighbour_energy((i - 1) % size);
    update_neighbour_energy((i    ) % size);
    update_neighbour_energy((i + 1) % size);
    update_neighbour_energy((i + 2) % size);

    Bead bi = points.get(i);
    update_repulsion_energy(bi);
    for (Bead p in grid radius) {
      update_repulsion_energy(p);
    }

    double d, cE;
    double E = 0.0;
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
}

double prev_now, now = 0.0, s_now = 0.0;
double p_scale = 75.0;
int gibbi = 0, accepts = 0, rejects = 0;
Vec2 p_old = new Vec2(0, 0);
Vec2 dp = new Vec2(0, 0);
Vec2 avg = new Vec2(0, 0);
Bead pk, n;
void draw() {
  prev_now = now;
  now = (double) (millis() - start_time) / 1000.0;
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
    n = new Bead(.5 * (pk.x + pk.q.x), .5 * (pk.y + pk.q.y));
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
    rand2(.01, dp);
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
      pk.addmul(dp, -1.25 - 0.5 * Math.random());
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
  double scale_max = 0.0;
  for (Bead p : pp) {
    avg.add(p);
    scale_max = Math.max(scale_max, p.sqMag());
  }
  scale_max = Math.sqrt(scale_max);
  p_scale += .01 * (scale_max - p_scale);
  avg.div(pp.size());
  for (Bead p : pp) p.addmul(avg, -0.1);

  if (frameCount % 64 == 0) {
    println("avg: (" + nfd(avg.x,2,3) + ',' + nfd(avg.y,2,3) + ")",
            "p_scale:" + nfd(p_scale, 2, 4),
            "fps:" + nfd(64.0 / (now - s_now), 2, 3),
            "accept ratio:" + nfd(accepts/(accepts+rejects+0.5), 1, 3),
            "L:" + nfs(L, 1)
            );
    s_now = now;
    accepts = 0; rejects = 0;
  }

  fill(c0);
  rect(0, 0, W, H);
  translate(W/2, H/2);
  for (Bead p : pp) {
    stroke(cAlpha(c1, 0.5));
    line((float)p.x, (float)p.y, (float)p.r.x, (float)p.r.y);
    noStroke();
    fill(c1);
    dot(p, 1.0);
  }
}


*/





// Grid Cell Class

static final int INITIAL_CAPACITY = 1333;
class Grid {
  HashMap<Integer,ArrayList<Vec2>> grid;
  double grid_spacing;
  int count;
  Grid(double max_distance) {
    this.grid = new HashMap<Integer,ArrayList<Vec2>>(INITIAL_CAPACITY);
    this.count = 0;
    this.grid_spacing = max_distance * 2;
  }

  public void clear() {
    grid.clear();
    count = 0;
  }

  public void add(Vec2 p) {
    int xi = (int) (p.x / grid_spacing);
    int yi = (int) (p.y / grid_spacing);
    int key = (xi << 16) + yi;
    ArrayList<Vec2> val = grid.get(key);
    if (val == null) {
      val = new ArrayList<Vec2>();
      grid.put(key, val);
    }
    val.add(p);
    count++;
  }

  public ArrayList<Vec2> query(Vec2 p, double d) {
    double sqd = d * d;
    int xi0 = (int) ((p.x - d) / grid_spacing);
    int yi0 = (int) ((p.y - d) / grid_spacing);
    int xi1 = (int) ((p.x + d) / grid_spacing);
    int yi1 = (int) ((p.y + d) / grid_spacing);
    ArrayList<Vec2> result = new ArrayList<Vec2>();
    for (int xi = xi0; xi <= xi1; xi++) {
      int xk = xi << 16;
      for (int yi = yi0; yi <= yi1; yi++) {
        //int key = xk + yi;
        ArrayList<Vec2> cell = grid.get(xk + yi); // maybe null
        if (cell != null) for (Vec2 q: cell) if (p != q && q.sqDist(p) < sqd)
          result.add(q);
      }
    }
    return result;
  }
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

PShape dot;
public void dot(Vec2 p, double s) {
  float fs = (float) s;
  shape(dot, (float) p.x, (float) p.y, fs, fs);
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

  double last_sqDist = 0, last_dx = 0, last_dy = 0;
  public double sqDist(Vec2 v) {
    last_dx = v.x - x;
    last_dy = v.y - y;
    last_sqDist = last_dx * last_dx + last_dy * last_dy;
    return last_sqDist;
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
    String[] appletArgs = new String[] { "gkale" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

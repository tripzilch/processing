import java.util.Map;
import java.lang.Math;
import java.lang.Double;

class Cell extends ArrayList<Vec2> {
}

static final int INITIAL_CAPACITY = 1000;
class Grid extends HashMap<Integer,Cell> { // would Integer[2] work?
  double grid_spacing;
  int count;
  Grid(double max_distance) {
    super(INITIAL_CAPACITY);
    this.grid_spacing = max_distance * 2;
    this.count = 0;
  }

  Cell getCell(int xi, int yi) {
    int key = (xi << 16) + yi;
    Cell val = this.get(key);
    if (val == null) {
      val = new Cell();
      this.put(key, val);
    }
    return val;
  }

  void add(Vec2 p) {
    int xi = (int) (p.x / grid_spacing);
    int yi = (int) (p.y / grid_spacing);
    this.getCell(xi, yi).add(p);
    count++;
  }

  Cell query(Vec2 p, double d) {
    double dd = d * d;
    int xi0 = (int) ((p.x - d) / grid_spacing);
    int yi0 = (int) ((p.y - d) / grid_spacing);
    int xi1 = (int) ((p.x + d) / grid_spacing) + 1;
    int yi1 = (int) ((p.y + d) / grid_spacing) + 1;
    for (int xi = xi0; xi < xi1; xi++) {
      int xk = xi << 16;
      for (int yi = yi0; yi < yi1; yi++) {
        Cell val = this.get(xk + yi); // maybe null
        // concat to result
        // NO PREMATURE OPTIMIZATION
      }
    }

  }
}

class Bead extends Vec2 {
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
    points = new Arraylist<Bead>(INITIAL_CAPACITY);
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

double phi = Math.sqrt(5.0) * 0.5 + 0.5;
float ax_size;
Necklace P;
void setup() {
  size(500, 500, P2D);
  ax_size = width / 2.0;
  smooth(4);
  colorMode(RGB, 1.0);
  noStroke();
  strokeWeight(0.25);
  dot = regularPolygon(12);
  P = new Necklace(25, 10.0, 2.0);
}

PShape regularPolygon(int N) {
  PShape r = createShape();
  r.beginShape(TRIANGLE_STRIP);
  r.noStroke();
  r.fill(#000000);
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
int cAlpha(int c, double a) { return ((int) Math.min(255.0, 255.0 * a)) * 0x01000000 | (c & 0x00FFFFFF); }

PShape dot;
void dot(Vec2 p, double s) {
  float fs = (float) s;
  shape(dot, (float) p.x, (float) p.y, fs, fs);
}

String nfd(double x, int a, int b) {
  return nfs((float) x, a, b);
}
int irand(int N) { return (int) (N * Math.random()); }
void rand2(double a, Vec2 out) {
  out.x = 2.0 * a * (Math.random() - .5);
  out.y = 2.0 * a * (Math.random() - .5);
}

double start_time = millis();
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
  rect(0, 0, width, height);
  translate(width/2, height/2);
  scale(.7235 * ax_size / (float) p_scale);
  for (Bead p : pp) {
    stroke(cAlpha(c1, 0.5));
    line((float)p.x, (float)p.y, (float)p.r.x, (float)p.r.y);
    noStroke();
    fill(c1);
    dot(p, 1.0);
  }
}

import java.util.Map;
import java.lang.Math;
import java.lang.Double;

int c0 = #000000;
int c1 = #FFFFFF;
int c2 = #8888AA;

class Particle extends Vec2 {
  Vec2 v;
  Particle(double x, double y) {
    super(x, y);
    v = new Vec2(0, 0);
  }
}

ArrayList<Particle> points;
Grid grid;
float ax_size;
static final double GDIST = 0.5;
void setup() {
  size(500, 500, P2D);
  ax_size = width;
  smooth(4);
  colorMode(RGB, 1.0);
  noStroke();
  strokeWeight(0.02);
  dot = regularPolygon(5);

  points = new ArrayList<Particle>(1000);
  for (int i = 0; i < 500; i++) {
    Particle p = new Particle(1.0 * (Math.random() - .5),
                              1.0 * (Math.random() - .5));
    points.add(p);
  }
  grid = new Grid(GDIST);
}

void line(double x0, double y0, double x1, double y1) {
  line((float) x0,(float) y0,(float) x1,(float) y1);
}

static final double ad = .03;
double frr(double r) { return 1.0 / (r*r + ad) - 1.0 / (GDIST*GDIST + ad); }

double start_time = millis();
void draw() {
  double now = (double) (millis() - start_time) / 1000.0;
  if (frameCount % 32 == 31) println(frameRate);
  fill(c0);
  rect(0, 0, width, height);
  translate(width/2, height/2);
  scale(ax_size / 0.8);

  grid.clear();
  for (Particle p: points) {
    p.addmul(p.v, 0.001);
    grid.add(p);
  }

  double dx,dy,dd;
  fill(1,1,1);
  for (Particle p : points) {
    //stroke(1,1,1,.1);
    p.v.rand(.25);
    for (Vec2 q : grid.query(p, GDIST)) {
      //line(p.x, p.y, q.x, q.y);
      dx = q.x - p.x;
      dy = q.y - p.y;
      dd = Math.sqrt(dx*dx + dy*dy);
      dd = frr(dd) * (.25 - dd);
      p.v.x -= dx * dd;
      p.v.y -= dy * dd;
    }
    //noStroke();
    //ellipse((float)p.x,(float)p.y, 0.01, 0.01);
    dot(p, .01);
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


*/




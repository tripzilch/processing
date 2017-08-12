import java.lang.Math;
import java.lang.Double;

int W, H;
int W2, H2;
void setup() {
  size(500, 500, P2D);
  W = width;
  H = height;
  W2 = width / 2;
  H2 = height / 2;
}

void pixaa(Vec2 p, double k) {
  pixaa(p.x, p.y, k);
}

double r2() { return Math.random() - Math.random(); }
double mix(double x, double y, double a) { return x + a * (y - x); }

double start_time = millis();
double now = (double) (millis() - start_time) / 1000.0;
Vec2 v = new Vec2(0.5, 0.5),
     p = new Vec2(0.0, 0.0), 
     x = new Vec2(0.0, 0.0),
     imouse = new Vec2(mouseX, mouseY),
     pimouse = new Vec2(mouseX, mouseY);

double vx = 0.5, vy = 0.5, px = 0, py = 0, xx = 0, yy = 0;

final int N = 1024;
void draw() {
  double pnow = now;
  now = (double) (millis() - start_time) / 1000.0;
  double dt = now - pnow;
  Vec2 mouse = new Vec2(mouseX, mouseY);
  Vec2 pmouse = new Vec2(pmouseX, pmouseY);

  fill(0,0,0,23);
  rect(0, 0, W, H);
  loadPixels();

  for (int i = 0; i < N; i++) {
    pimouse = imouse.copy();
    imouse.mix(mouse, .001)
    pixaa(imouse, .1);
    // double a = Math.pow(0.99, dt / 0.01);  
    // vx = vx * a + (mouseX - pmouseX) * (1 - a) * 0.25;
    // vy = vy * a + (mouseY - pmouseY) * (1 - a) * 0.25;
    // L = Math.sqrt(vx * vx + vy * vy);
    // vx = vx * (0.4 + 0.1 / (L + 0.01));
    // vy = vy * (0.4 + 0.1 / (L + 0.01));
    // px += 512 * vx * dt;
    // py += 512 * vy * dt;
    // double xo = Math.cos(px) * 64.0;
    // double yo = Math.sin(py) * 64.0;
    // double b = Math.pow(0.9, dt / 0.01);
    // xx = xx * b + mouseX * (1 - b);
    // yy = yy * b + mouseY * (1 - b);
    pixaa((float)(xx + xo + r2()),  (float) (yy + yo + r2()), 0.05);
  }
  updatePixels();
  if (frameCount % 32 == 0) {
    println("L: ", L, "vx: ", vx , "vy: ", vy, "dt: ", dt);
  }

}


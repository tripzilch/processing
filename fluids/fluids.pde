import java.lang.Math;

double pp[][], vx[][], vy[][];
int N;

void setup() {
  size(512, 512);
  N = width;
  pp = new double[N][N];
  vx = new double[N][N];
  vy = new double[N][N];
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      pp[i][j] = 0.5 + brand(0.1);
      vx[i][j] = brand(1.0);
      vy[i][j] = brand(1.0);
    }
  }
}

void render() {
  loadPixels();
  int k = 0;
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      pixels[k] = 0xFF000000 | (int)(255 * Math.max(0.0, Math.min(1.0, pp[i][j]))) * 0x00010101;
      k++;
    }
  }
  updatePixels();
}

void advection(double dt) {
  double x1, y1, fx, fy, p0;
  int ix, iy;
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      x1 = i + vx[i][j] * dt;
      y1 = j + vy[i][j] * dt;
      ix = (int) x1; fx = x1 % 1.0;
      iy = (int) y1; fy = y1 % 1.0;

      p0 = pp[i][j];
      pp[(ix+N) & 511][(iy+N) & 511] += p0*((1-fx)*(1-fy));
      pp[((ix+N) + 1) & 511][(iy+N) & 511] += p0*((fx)*(1-fy));
      pp[(ix+N) & 511][((iy+N) + 1) & 511] += p0*((1-fx)*(fy));
      pp[((ix+N) + 1) & 511][((iy+N) + 1) & 511] += p0*((fx)*(fy));

      pp[i][j]-= p0;
    }
  }
}

void pressure() {
  Vec2 force = new Vec2();
  double a = 0.1;
  for (int i = 0; i < N-1; i++) {
    for (int j = 0; j < N-1; j++) {
      force.set((pp[i][j]-pp[i+1][j]),(pp[i][j]-pp[i][j+1]));
      vv[i][j].addmul(force, a);
      vv[i+1][j].add(0, a*force.x);
      vv[i][j+1].add(a*force.y, 0);
    }
  }
}


void draw() {
  advection(0.1);
  pressure();
  render();
  if (mousePressed == true) {
    pp[mouseY][mouseX] += 1.0;
  }
}

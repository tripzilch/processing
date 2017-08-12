class Particle {
	double x, y, vx, vy;
}

void setup() {
  size(720, 720, P2D);
  colorMode(RGB, 1.0);
}

void draw() {
	sim_update();
	sim_step();
	sim_paint();
}
// line tracing

import java.lang.Math;


double px, py, target_x, target_y, x0;
double SPACING = 5.0;
double STRAIGHTNESS = 0.0;
int SAMPLES = 16;
double W, H;
void setup() {
    size(1000, 700);
    colorMode(RGB, 1.0);
    W = width; H = height;
    target_x = 32;
    target_y = H + 4.0;
    px = x0 = target_x;
    py = 4.0;
    loadPixels();
    for (int i = 0; i < height*width; i+=1) {
        int c = (int(random(224, 256)) * 0x010101) | 0xFF000000;
        if (i % width < (px - 3.0 * SPACING)) c = 0xFF000000;
        pixels[i] = c;
    }
    updatePixels();
}

void draw() {
    loadPixels();
    for (int k = 0; k < 100; k++) {
        pixaa(px + randomGaussian() * 0.5, py + randomGaussian() * 0.5, 0.1);
        double dx = (target_x - px) * 0.1;
        double dy = target_y - py;
        double dist = Math.sqrt(dx*dx + dy*dy);
        if (dist >= 1.0 && py < H - 4.0) {
            dx /= dist;
            dy /= dist;
            double tx = 0;
            double ty = 0;
            for (int i = 0; i < SAMPLES; i++) {
                // pick random point in half-circle ahead
                double r = random(2.0, (float) SPACING * 1.2);
                double a = random(-0.62, 0.6) * Math.PI;
                double sx = r * (Math.cos(a) * dx + Math.sin(a) * dy);
                double sy = r * (Math.cos(a) * dy - Math.sin(a) * dx);
                double sc = getpix(px + sx, py + sy) / r;
                tx += sx * sc * sc;
                ty += sy * sc * sc;
            }
            double td = Math.sqrt(tx*tx + ty*ty);
            px += .1 * tx / td;
            py += .1 * ty / td;
        } else {
            // next target
            target_x = px + SPACING * random(0.7, 1.5);
            target_y = H + 4.0;
            x0 = (x0 + SPACING * random(0.7, 2.3) + target_x) * 0.5;
            px = x0;
            py = 4.0;
        }
    }
    updatePixels();
}

double getpix(double x, double y) {
  int xi = (int) x, yi = (int) y;
  if (xi >= 0 && xi < width - 1 && yi >= 0 && yi < height - 1) {
    int idx = yi * width + xi;
    double xf = x % 1, yf = y % 1;
    double xg = 1 - xf, yg = 1 - yf;
    double c = (pixels[idx] & 0xFF) * (xg * yg);
    idx++;
    c += (pixels[idx] & 0xFF) * (xf * yg);
    idx += width;
    c += (pixels[idx] & 0xFF) * (xf * yf);
    idx--;
    c += (pixels[idx] & 0xFF) * (xg * yf);
    return c / 256.0;
  } else { return 1.0; }
}


void pixaa(double x, double y, double k) {
  int xi = (int) x, yi = (int) y;
  if (xi >= 0 && xi < width - 1 && yi >= 0 && yi < height - 1) {
    int idx = yi * width + xi;
    double k255 = k * 255;

    double xf = x % 1, yf = y % 1;
    double xg = 1 - xf, yg = 1 - yf;

    pixels[idx] = (Math.max(0, (pixels[idx] & 0xFF) - (int) (k255 * xg * yg)) * 0x010101) | 0xFF000000;
    idx++;
    pixels[idx] = (Math.max(0, (pixels[idx] & 0xFF) - (int) (k255 * xf * yg)) * 0x010101) | 0xFF000000;
    idx += width;
    pixels[idx] = (Math.max(0, (pixels[idx] & 0xFF) - (int) (k255 * xf * yf)) * 0x010101) | 0xFF000000;
    idx--;
    pixels[idx] = (Math.max(0, (pixels[idx] & 0xFF) - (int) (k255 * xg * yf)) * 0x010101) | 0xFF000000;
  }
}

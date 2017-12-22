import java.lang.Math;
import java.lang.Double;

int W, H;
int W2, H2;
PCG32Random RNG = new PCG32Random();
void setup() {
  size(1600, 960, P2D);
  W = width;
  H = height;
  W2 = width / 2;
  H2 = height / 2;
  fill(0,0,0);
  rect(0, 0, W, H);
  println("TEST");
  int test = -88;
  println(test >>> 2);
  println("START RENDER");
}

double r2() { return (RNG.nextDouble() - RNG.nextDouble()); }

double logistic_map(double x, double r) { return r * x * (1 - x); }

double ricker(double x, double r) { return x * Math.exp(r * (1 - x)); }

final int N = 512;
final int HIST_SIZE = 9;
double[] xhist = new double[HIST_SIZE];
int ixhist = 0;
void draw() {
  loadPixels();

  double a = 0.0, min_a = 256, max_a = -256;
  int n_hits = 0, n_pix = 0;
  for (int i = 0; i < N; i++) {
    double px = Math.pow(RNG.nextDouble(), 0.5);
    double r = 0 + 4 * Math.pow(px, 0.5);
    double x = 0.5;  // + 0.8 * RNG.nextDouble();
    double chan = 0;
    int j = (int) (RNG.nextDouble() * 256.0);
    while (j < 2048 && x > 0 && x < 1) {

      ixhist = (ixhist + 1) % HIST_SIZE;
      xhist[ixhist] = x;
      x = logistic_map(x, r);

      // chan = 0;
      // for (int k = 1; k < HIST_SIZE + 1; k++) {
      //   double xk = xhist[(ixhist - k + 1 + HIST_SIZE) % HIST_SIZE];
      //   double d = x - xk;
      //   if (RNG.chance(1 - d * d)) chan++;
      // }


      if (j > 800) {
        double sx = W * px + 0.4 * (r2() + r2() + r2() + r2());
        double sy = H * x +  0.4 * (r2() + r2() + r2() + r2());
        int c = (RNG.next() >>> 8) % 3;
        //a = getpixaa(sx, sy, c);
        //if (RNG.chance(a * a * a * 0.3)) break;
        //if (RNG.chance(Math.pow(1.0 - a, 6.2))) { 
          pixaa(sx, sy, 0.0075, c);
          //n_hits++; 
        //}
        //n_pix++;
        //if (a < min_a) min_a = a;
        //if (a > max_a) max_a = a;        
      }
      j++;
    }

  }
  updatePixels();
  if (frameCount % 64 == 0) {
    println("frame:" + frameCount + ", " + (int) frameRate + "fps, a = [" + min_a + ", " + max_a + "]  hits per pix" + (double) n_hits / n_pix);
  }

}


import java.lang.Math;
import java.lang.Double;

static final int W = 800;
static final int H = 800;
static final int nPixels = W * H;
double hW, hH;
PCG32Random RNG = new PCG32Random();
double[] cBuf;
double cMax;
void setup() {
  size(800, 900, P2D);
  hW = W * 0.5;
  hH = H * 0.5;
  cBuf = new double[nPixels];
  cMax = 20.0;
  for (int i = 0; i < nPixels; i++) {
    cBuf[i] = Math.floor(10.0 + 10.0 * RNG.nextDouble());
  }
  println("START RENDER");
  // int nx = -17;
  // long r = (nx & 0xFFFFFFFFL);
  // println(nx, r);
  // println(RNG.next(),RNG.next(),RNG.next(),RNG.next());

}

double r2() { return (RNG.nextDouble() - RNG.nextDouble()); }

void dot(Vec2 p, double k) {
  int xi = (int) (hW + hW * p.x + 1.5 * r2() + W * 2), yi = (int) (hH + hH * p.y + 1.5 * r2() + H * 2);
  xi = xi % W;
  yi = yi % H;
  int i = yi * W + xi;
  double c = cBuf[i];
  // if (c == 2147483647) return;
  c += 0.1 * k + 5000.0 * k / (5000.0 + c * c);
  if (c > cMax) cMax = c;
  cBuf[i] = c;
}

double cget(Vec2 p) {
  int xi = ((int) (hW + hW * p.x + W * 2)) % W;
  int yi = ((int) (hH + hH * p.y + H * 2)) % H;
  return cBuf[yi * W + xi];
}


final int N = 55555;
void draw() {
  Vec2 x0 = new Vec2(), 
       xhi = new Vec2(), 
       xc = new Vec2(), 
       xn = new Vec2(),
       xd = new Vec2(), 
       xa = new Vec2(),
       xb = new Vec2();
  double ap = 1.0;
  double chi = 0, c0 = 0, cc = 0, cn = 0, c = 0, d = 0, e = 0, ew = 0;
  double dcount = 0;

  int[] eh = new int[W];
  int eN = 0;
  double e_sum = 0, e2_sum = 0, e_mu = 0, e_sig = .05;


  for (int i = 0; i < N; i++) {
    x0.rand(1.0);
    xc.set(x0);
    xhi.set(x0);
    chi = c0 = cc = cget(xc);
    for (int j = 0; j < 13; j++) {
      xn.setrandoffset(xc, .095);
      cn = cget(xn);
      if (cn > chi) {
        xhi.set(xn);
        chi = cn;
        if (RNG.chance(0.5)) {
          cc = cn;
          xc.set(xn);
        }
      }
    }

    xd.set(xhi);
    xd.sub(x0);
    if (xd.sqMag() < .0001) continue;

    xd.normalize();
    //cc = (cc + cMax) * 0.5;
    double rc = 20.0;
    c = 1.0 + 5.0 / rc;
    xa.setrandoffset(x0, .003); xa.addmul(xd, rc * r2() / hW); c *= cget(xa) / chi;
    xa.setrandoffset(x0, .003); xa.addmul(xd, rc * r2() / hW); c *= cget(xa) / chi;
    xa.setrandoffset(x0, .003); xa.addmul(xd, rc * r2() / hW); c *= cget(xa) / chi;

    xd.rot90();
    double rd = 11.0;
    d = 1.15;
    xa.setrandoffset(x0, .007); xa.addmul(xd,rd * r2() / hW); d *= cget(xa) / chi;
    xa.setrandoffset(x0, .007); xa.addmul(xd,rd * r2() / hW); d *= cget(xa) / chi;
    xa.setrandoffset(x0, .007); xa.addmul(xd,rd * r2() / hW); d *= cget(xa) / chi;

    e = c - d;
    e_sum += e;
    e2_sum += e * e;
    eN++;

    ew = (e - e_mu) / e_sig;
    if (ew >  5.0) { dot(x0, 0.02 * RNG.nextDouble()); dcount+=0.02; }
    if (ew >  8.0) { dot(x0, 0.15 * RNG.nextDouble()); dcount+=0.15; }
    if (ew > 10.0) { dot(x0, 1.0 * RNG.nextDouble()); dcount+=1.0; }
    // if (ew > 15.0) { dot(x0, 1.0 * RNG.nextDouble()); dcount+=1.0; }
    
    int ei = (int) Math.round(hW * 0.5 + 30.0 * ew);
    if (ei >=0 && ei < W) eh[ei]++;

  }
  e_mu = e_sum / eN;
  e_sig = Math.sqrt(e2_sum / eN - e_mu * e_mu);
  if (frameCount % 64 == 0) {
    fill(0);
    rect(0, 0, W, H + 100);
    loadPixels();  
    double cScale = 1.0 / cMax;
    double k;
    int r, g, b;
    for (int i = 0; i < nPixels; i++) {
      k = cBuf[i] * cScale;
      k *= k;
      b = (int) (255.0 * k);
      k *= k;
      r = (int) (255.0 * k);
      k *= k;
      g = (int) (255.0 * k);
      pixels[i] = (b * 0x00000001) | (g * 0x00000100) | (r * 0x00010000) | 0xFF000000;
    }
    for (int i = 0; i < W; i++) {
      int h = (int)(Math.pow(eh[i], .685) * 2.0);
      h = h < 100 ? h : 100;
      e = (i - hW * 0.5) / 30.0;
      int rgb = e < 10.0 ? 0xFF77CC00 : 0xFFFFCC00;
      rgb = e < 8.0 ? 0xFFFF3300 : rgb;
      //rgb = e < 5.0 ? 0xFFAA0000 : rgb;
      rgb = e < 5.0 ? 0xFF777777 : rgb;
      //rgb = Math.abs(e) < 1.0 ? 0xFFFF6600 : rgb;
      rgb = (e % 2) < 1.0 ? rgb + 0x2222 : rgb;
      rgb = e < 0.0 ? 0xFF333333 : rgb;
      for (; h>0; h--) pixels[i + (900 - h) * W] = rgb;
    }
    updatePixels();
    print("F" + nf(frameCount, 3) + " @ " + nf(frameRate, 2, 1) + "fps");
    print(" | cMax = " + nf((float)cMax, 3,1));
    print(" | dot% = " + nf((float)(100 * dcount / N), 2, 3));
    print(" | e_mu = " + nfs((float)e_mu, 1, 3));
    print(" | e_sig = " + nf((float)e_sig, 1, 3));
    println();
  }
}


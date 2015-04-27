import java.lang.Math;  // de functies in java.lang.Math zijn een stuk sneller
                        // dan die van Processing zelf.
float start_time;
class Blobs {
  int N;
  int[] rrr;
  float[] cx, cy, cr;
  private float time;
  Blobs(int N) {
    this.N = N;
    cx = new float[N];
    cy = new float[N];
    cr = new float[N];
    rrr = new int[N * 8];
    for (int i = 0; i < N * 8; i++) rrr[i] = (int) (1 + 10 * Math.random());
    this.setTime(start_time);        
  }
  float getTime() { return this.time; }
  float sum_cr;
  void setTime(float t) {
    this.time = t;
    float t1 = t * 0.02;
    sum_cr = 0;    
    for (int i = 0; i < N; i++) {
      int ii = i * 8;
      cx[i] = .66 * (sin(rrr[ii+0] * t1 + rrr[ii+1]) + sin(rrr[ii+2] * t1 + rrr[ii+3]));
      cy[i] = .66 * (sin(rrr[ii+4] * t1 + rrr[ii+5]) + sin(rrr[ii+6] * t1 + rrr[ii+7]));
      cr[i] = 4 - 2*(i % 3)*(i % 3);
      sum_cr += cr[i];
    }   // 4 2 -2
  }
  
  float f(float x, float y) {
    float r = 0.0;
    for (int i = 0; i < N; i++) {
      float dx = cx[i] - x, dy = cy[i] - y;
      float d2 = dx * dx + dy * dy;
      r += cr[i] / (0.01 + d2);    
    }
    return r / sum_cr;
  }
  
  float eps = 1.0 / 2048.0;
  float dfdx(float x, float y) {
    return (f(x + eps, y) - f(x - eps, y)) / eps;
  } 
  float dfdy(float x, float y) {
    return (f(x, y + eps) - f(x, y - eps)) / eps;
  }   
}

Blobs b;
void setup() {
  size(400,400);
  colorMode(RGB, 1.0);
  noStroke();
  start_time = millis();
  b = new Blobs(12);
}

float last_t = 0;
void draw() {
  //fill(0);
  //rect(0,0,width,height);
  loadPixels();
  int index = 0, W = width / 2, H = height / 2;
  int white = color(1), black = color(0);
  
  float t = (millis() - start_time) / 1000.0;
  b.setTime(t);
  //println(last_t - t);
  //last_t = t;

  float threshold = 2.3;
  float[] up = new float[W + 1];
  float left = 0;
  for (int j = -1; j < H; j++) {
    for (int i = -1; i < W; i++) {
      float x = (2.0 * i - W) / W;
      float y = (2.0 * j - H) / W;      
      float p = b.f(x, y) - threshold;
      p = 1.5 - (p*p) ;
      if (i >= 0 && j >= 0) {
        float uu = up[i], vv = up[i + 1];
        float cc;
        cc = (Math.max(0, p) + Math.max(0, left) + Math.max(0, uu) + Math.max(0, vv)) / 
             (Math.abs(p) + Math.abs(left) + Math.abs(uu) + Math.abs(vv));
        pixels[index] = 
        pixels[index + 1] = 
        pixels[index + width] = 
        pixels[index + width + 1] = color(cc);
        index += 2;        
      }
      left = up[i + 1] = p;      
    }
    if (j >= 0) index += width;
  }
  updatePixels();  
}

import java.lang.Math;  // de functies in java.lang.Math zijn een stuk sneller
                        // dan die van Processing zelf.

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
    
    // hier maak ik een array van pseudorandom getallen, zodat ik ieder frame
    // dezelfde random getallen kan hergebruiken
    rrr = new int[N * 8];
    for (int i = 0; i < N * 8; i++) rrr[i] = (int) (1 + 10 * Math.random());
    
    this.setTime(start_time);
  }
  
  float getTime() { return this.time; }
  float sum_cr;
  void setTime(float t) {
    this.time = t;
    float t1 = t * 0.06;
    sum_cr = 0;
    for (int i = 0; i < N; i++) {
      int ii = i * 8;
      cx[i] = .7 * sin(rrr[ii+0] * t1 + i) + .3 * sin(rrr[ii+2] * t1 + 1);
      cy[i] = .7 * sin(rrr[ii+3] * t1 - 2 * i + 2) + .3 * sin(rrr[ii+4] * t1 + 3);
      cr[i] = 1.0; // alle cr even groot
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
}

float start_time;
Blobs b;
void setup() {
  size(400,400);
  colorMode(RGB, 1.0);
  noStroke();
  start_time = millis();
  b = new Blobs(3);      // 3 blobs ipv 12, voor de duidelijkheid
}

void draw() {
  loadPixels();

  int black = color(0);
  int white = color(1);

  float t = (millis() - start_time) / 1000.0;
  b.setTime(t);

  float threshold = 3.2;

  // alle extra ingewikkeldheid in de pixel-loop was om mooie zachte
  // vloeiende randjes om de blobs te krijgen, dat heb ik nu allemaal
  // uitgezet
  //
  // omdat alles nu simpeler is, hoef ik ook geen dubbele pixels meer
  int index = 0, W = width, H = height;

  for (int j = 0; j < H; j++) {
    for (int i = 0; i < W; i++) {
      float x = (2.0 * i - W) / W;
      float y = (2.0 * j - H) / W;
      float p = b.f(x, y) - threshold;

      if (p > 0) {
        pixels[index] = white;
      } else {
        pixels[index] = black;
      }
      
      // // probeer de volgende regel eens aan te zetten
      // // als je wilt zien hoe de functie f(x,y) er "echt" uitziet:
      // pixels[index] = color(b.f(x,y) / (2 * threshold));      
      
      index += 1;
    }
  }
  updatePixels();
}


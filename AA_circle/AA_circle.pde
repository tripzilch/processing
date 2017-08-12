float mg(float x, float y) { return sqrt(x*x+y*y); }

void setup() {
  int r = 50;
  float sq2 = sqrt(2);
  colorMode(RGB, 1.0);
  size(r * 2, r * 2);
  background(0);
  for (int i = 0; i < height; i++) {
    for (int j = 0; j < width; j++) {
        float x = j - r * 0.5 + 0.5;
        float y = i - r * 0.5 + 0.5;
        float a = mg(x - 0.5, y - 0.5) - r;
        float b = mg(x + 0.5, y - 0.5) - r;
        float c = mg(x - 0.5, y + 0.5) - r;
        float d = mg(x + 0.5, y + 0.5) - r;
        
        float lo = min(a, min(b, min(c, d)));
        float hi = max(a, max(b, max(c, d)));
        
        if (lo < 0 && hi < 0) {
          fill(1);
        } else if (lo > 0 && hi > 0) {
          fill(0);
        } else {
          fill(-lo / (hi-lo));
        }
        fill(1);
        rect(j, i, 1, 1);
    }
  }
  
}

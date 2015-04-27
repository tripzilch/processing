import java.lang.Math;

float w2;
void setup() {
  size(500,500);
  w2 = width / 2.0;
  colorMode(RGB, 1.0);
  noStroke();
  noiseSeed(23);
  //translate(1, 1);
}

void wupix(float x, float y) {
  x = (x + 1.0) * width / 2; 
  y = (y + 1.0) * width / 2;
  int xi = (int) x, yi = (int) y;
  if (xi >= 0 && xi < width && yi >= 0 && yi < height) {
    int ii = yi * width + xi;
    float xf = (x - xi), yf = (y - yi);
    float xy = xf * yf;
    pixels[ii] = color(1 - yf - xf + xy);
    pixels[ii+1] = color(xf - xy);
    pixels[ii+width] = color(yf - xy);
    pixels[ii+width+1] = color(xy);
  }
}

float start_time = millis();
void draw() {
  float now = (millis() - start_time) / 1000.0;
  fill(0);//,0,0,0.2);
  rect(0,0,width,height);
  loadPixels();
  for (int i = 0; i < 100; i++) {
    float x = 2 * noise(i * 3.8 - now * .035, 1 + now * .029, now * .033) - 1;
    float y = 2 * noise(i * 7.2 + now * .028, 2 - now * .034, now * .030) - 1;    
    wupix(x, y);
  }
  updatePixels();
}

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.lang.Math; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class wupix extends PApplet {



float w2;
public void setup() {
  size(500,500);
  w2 = width / 2.0f;
  colorMode(RGB, 1.0f);
  noStroke();
  noiseSeed(23);
  //translate(1, 1);
}

public void wupix(float x, float y) {
  x = (x + 1.0f) * width / 2;
  y = (y + 1.0f) * width / 2;
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
public void draw() {
  float now = (millis() - start_time) / 1000.0f;
  fill(0);//,0,0,0.2);
  rect(0,0,width,height);
  loadPixels();
  for (int i = 0; i < 100; i++) {
    float x = 2 * noise(i * 3.8f - now * .035f, 1 + now * .029f, now * .033f) - 1;
    float y = 2 * noise(i * 7.2f + now * .028f, 2 - now * .034f, now * .030f) - 1;
    wupix(x, y);
  }
  updatePixels();
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "wupix" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

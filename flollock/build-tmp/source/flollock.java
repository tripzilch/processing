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

public class flollock extends PApplet {



double PHI = Math.sqrt(5.0f) * 0.5f + 0.5f;
double HW, HH, H, W;
float HWf, HHf;
PShape dod;
public void setup() {
  
  H = height; W = width;
  HW = HWf = .5f * width;
  HH = HHf = .5f * height;
  
  colorMode(RGB, 1.0f);
  noStroke();
  dod = regularPolygon(24);
}

public PShape regularPolygon(int N) {
  PShape p = createShape();
  p.beginShape(TRIANGLE_STRIP);
  p.noStroke();
  p.fill(0xff000000);
  for (int i = 0; i < N; i++) {
    //int k = (i % 2 == 0) ? i / 2 : N - (i + 1) / 2;
    int k = (i / 2) + (i % 2) * (N - i);
    p.vertex(cos(k * TAU / N), sin(k * TAU / N), 0);
  }
  p.endShape(CLOSE);
  p.disableStyle();
  return p;
}

//double W
public double wobble(double x, double y, double z) {
  double a = Math.cos( 23 * x - 17 * y + 33);
  double b = Math.cos( 37 * y + 28 * z + 89);
  double c = Math.cos( 61 * z - 45 * x + 51);

  return ( c * Math.cos(17 * a + 31 * b + 15 )
         + a * Math.cos(21 * b + 13 * c + 41 )
         + b * Math.cos(19 * c +  5 * a + 27 ) ) * 0.33333f;
}

public void dot(double x, double y, double z, double s) {
  pushMatrix();
  translate((float) x, (float) y, (float) z);
  scale((float) s);
  shape(dod);
  popMatrix();
}

int c0 = 0xFF121008;
int c1 = 0xFF6622cc;
int c2 = 0xFFdd4411;

public int cAlpha(int c, double a) {
  return ((int) Math.min(255.0f, 255.0f * a)) * 0x01000000 | (c & 0x00FFFFFF);
}

double start_time = millis();
double prev_now, now, t0 = 0.0f, ta = 0.0f, ts, tc, cspin, sspin;
int step = 0;
int NFRAMES = 512;
public void draw() {
  t0 = frameCount * TAU / NFRAMES;

  background(c0);
  // look at (0,0,0) from (0,0,HHf)
  camera(0, 0, HHf, 0,0,0, 0,1,0);

  //fill(c2);
  //dot(0,0,10, 10.0);
  //rotateZ((float) (t0 * 5.0));



  ts = (Math.sin(t0)      + .2f * Math.sin(t0 * 5 + .2f * TAU)) / 1024;
  tc = (Math.cos(t0 - .5f) + .2f * Math.cos(t0 * 5 + .4f * TAU)) / 1024;

  int N = 4096;
  double rN = 1.0f / N;
  double a, t, x, y, z, s, p, px, py, pz, iz;
  double near_p = 5.0f;
  for (int i = 0; i < N; i++) {
    //t = prev_now + (now - prev_now) * fi;
    p = i * rN;
    t = 8 * p;

    // position
    x = wobble( 3.1f * ts +   2.1e-3f * t + 83,  2.8f * tc +  -5.6e-3f * t + 11, -1.1f * tc + 15.7e-3f * t + 24);
    y = wobble( 2.1f * tc +   2.3e-3f * t + 22, -3.3f * ts +  -3.7e-3f * t + 37,  1.3f * ts + 13.8e-3f * t + 73);
    z = wobble(-2.4f * tc +   2.5e-3f * t + 12,  3.1f * ts +  -3.9e-3f * t + 10,  1.2f * ts + 14.2e-3f * t + 13);

    // shape size
    s = wobble(1.4f * ts +  -7.3e-3f * t + 55,  1.9f * ts +  17.3e-3f * t + 41,  3.6f * tc +  6.5e-3f * t + 47);
    s *= 4.0f * Math.pow(Math.abs(s), 2.5f);
    s = s / (1.0f + Math.abs(s));
    s *= 60.0f;
    // taper off ends
    s = s * Math.min(1.0f, 18 * (0.5f - Math.abs(p - 0.5f )));
    // color
    int c = (s > 0) ? c1 : c2;
    s = Math.abs(s);
    // c = cAlpha(c, Math.pow(Math.min(1.0, s), 2.0));
    if (s < 0.5f) continue;
    fill(c);
    dot(H * x, .7f * H * y, H * z - 500, s);
  }

  //prev_now = now;
  String fn = "/tmp/flollock/x" + nf(frameCount, 5) + ".png";
  saveFrame(fn);
  println("wrote", fn, frameCount, t0);
  if (frameCount >= NFRAMES) exit();
}
  public void settings() {  size(768, 512, P3D);  smooth(4); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "flollock" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

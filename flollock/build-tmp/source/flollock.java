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



//double phi = Math.sqrt(5.0) * 0.5 + 0.5
float pscale, dot_size;
PShape dod;
public void setup() {
  size(768, 512, P2D);
  pscale = width / 2.0f;
  dot_size = 2.5f / pscale;
  smooth(4);
  colorMode(RGB, 1.0f);
  noStroke();
  dod = regularPolygon(12);
}

public PShape regularPolygon(int N) {
  PShape p = createShape();
  p.beginShape(TRIANGLE_STRIP);
  p.noStroke();
  p.fill(0xff000000);
  for (int i = 0; i < N; i++) {
    //int k = (i % 2 == 0) ? i / 2 : N - (i + 1) / 2;
    int k = (i / 2) + (i % 2) * (N - i);
    p.vertex(cos(k * TAU / N), sin(k * TAU / N));
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

public void dot(double x, double y, double s) {
  float ps = dot_size * (float) s;
  shape(dod, (float) x, (float) y, ps, ps);
}

int c0 = 0xFF353662;
int c1 = 0x00ff30a9;
int c2 = 0x00e8c147;

public int cAlpha(int c, double a) {
  return ((int) Math.min(255.0f, 255.0f * a)) * 0x01000000 | (c & 0x00FFFFFF);
}

double start_time = millis();
double prev_now, now, t0 = 0.0f, ta = 0.0f, ts, tc;
int step = 0, dframe = 0, oframe = 0;
int FL = 12, NFRAMES = 512;
public void draw() {
  if (dframe == FL) {
    String fn = "/tmp/flollock/x" + nf(oframe, 5) + ".png";
    saveFrame(fn);
    println("wrote", fn, oframe, dframe, t0, step);
    dframe = 0;
    oframe++;
    if (oframe >= NFRAMES) exit();
  }
  if (dframe == 0) {
    background(c0);
    step = 0;
    t0 = oframe * TAU / NFRAMES;
    ts = (Math.sin(t0)      + .2f * Math.sin(t0 * 5 + .2f * TAU)) / 1024;
    tc = (Math.cos(t0 - .5f) + .2f * Math.cos(t0 * 5 + .4f * TAU)) / 1024;
  }
  translate(width/2, height/2);
  scale(pscale);
  int N = 4096;
  double rN = 1.0f / N;
  double a, t, x, y, s, p;
  for (int i = 0; i < N; i++) {
    //t = prev_now + (now - prev_now) * fi;
    p = step * rN / FL;
    t = 32 * p;
    x = wobble(3.1f * ts +   2.1e-3f * t + 83,  2.8f * tc +  -5.6e-3f * t + 11, -1.1f * tc + 15.7e-3f * t + 24);
    y = wobble(2.1f * tc +   2.3e-3f * t + 22, -3.3f * ts +  -3.7e-3f * t + 37,  1.3f * ts + 13.8e-3f * t + 73);
    s = wobble(1.4f * ts +  -7.3e-3f * t + 55,  1.9f * ts +  17.3e-3f * t + 41,  3.6f * tc +  6.5e-3f * t + 47);
    // shape
    s *= 2.0f * Math.pow(Math.abs(s), 2.5f);
    s = s / (1.0f + Math.abs(s));
    s *= 30.0f;
    // taper off ends
    s = s * Math.min(1.0f, 12 * (0.5f - Math.abs(p - 0.5f )));
    int c = (s > 0) ? c1 : c2;
    s = Math.abs(s);
    c = cAlpha(c, Math.pow(Math.min(1.0f, s), 2.0f));
    s = Math.max(1.0f, s);
    fill(c);
    dot(x, y * .7f, s);
    step++;;
  }

  //prev_now = now;
  dframe++;
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "flollock" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

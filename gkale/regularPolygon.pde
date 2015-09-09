PShape regularPolygon(int N) {
  PShape r = createShape();
  r.beginShape(TRIANGLE_STRIP);
  r.noStroke();
  r.fill(#000000);
  for (int i = 0; i < N; i++) {
    //int k = (i % 2 == 0) ? i / 2 : N - (i + 1) / 2;
    int k = (i / 2) + (i % 2) * (N - i);
    r.vertex(cos(k * TAU / N), sin(k * TAU / N));
  }
  r.endShape(CLOSE);
  r.disableStyle();
  return r;
}

PShape dot;
void dot(Vec2 p, double s) {
  float fs = (float) s;
  shape(dot, (float) p.x, (float) p.y, fs, fs);
}


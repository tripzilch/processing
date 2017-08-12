import java.lang.Math;

class Vec2 {
  double x, y;
  Vec2(double x, double y) { this.x = x; this.y = y; }
  Vec2(Vec2 v) { this(v.x, v.y); } // copy constructor
  Vec2() { this(0.0, 0.0); } // defoelt constructor

  Vec2 copy() { return new Vec2(x, y); }
  void set(Vec2 v) { x = v.x; y = v.y; }
  void set(double x, double y) { this.x = x; this.y = y; }

  void add(Vec2 v) { x += v.x; y += v.y; }
  void sub(Vec2 v) { x -= v.x; y -= v.y; }
  void mul(Vec2 v) { x *= v.x; y *= v.y; }
  void div(Vec2 v) { x /= v.x; y /= v.y; }

  void add(double a) { x += a; y += a; }
  void sub(double a) { x -= a; y -= a; }
  void mul(double a) { x *= a; y *= a; }
  void div(double a) { x /= a; y /= a; }
  void pow(double a) { x = Math.pow(x, a); y = Math.pow(y, a); }

  double dot(Vec2 v) { return x * v.x + y * v.y; }

  void addmul(Vec2 v, Vec2 w) {
    x += v.x * w.x;
    y += v.y * w.y;
  }

  void addmul(Vec2 v, double w) {
    x += v.x * w;
    y += v.y * w;
  }

  void muladd(Vec2 v, Vec2 w) {
    x = x * v.x + w.x;
    y = y * v.y + w.y;
  }

  double mag() { return Math.sqrt(x * x + y * y); }
  double sqMag() { return x * x + y * y; }

  double dist(Vec2 v) {
    double dx = v.x - x, dy = v.y - y;
    return Math.sqrt(dx * dx + dy * dy);
  }

  double last_sqDist = 0, last_dx = 0, last_dy = 0;
  double sqDist(Vec2 v) {
    last_dx = v.x - x;
    last_dy = v.y - y;
    last_sqDist = last_dx * last_dx + last_dy * last_dy;
    return last_sqDist;
  }

  void normalize() {
    double a = Math.sqrt(x * x + y * y);
    x /= a; y += a;
  }

  String toString() {
    return "(" + Double.toString(x) + ", " + Double.toString(y) + ")";
  }

  void rand(double a) {
    x = a * (2 * Math.random() - 1);
    y = a * (2 * Math.random() - 1);
  }
  void rand() { x = 2 * Math.random() - 1; y = 2 * Math.random() - 1; }

}

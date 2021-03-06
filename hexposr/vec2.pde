import java.lang.Math;

// interface BinaryFunction {
//   double call(double a, double b);
// }

PCG32Random v2_RNG = new PCG32Random(3125L, 23L);
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

  // void op(Vec2 a, Vec2 b, BinaryFunction f) { 
  //   x = f.call(a.x, b.x); 
  //   y = f.call(a.y, b.y); 
  // }
  // void iop(Vec2 a, BinaryFunction f) {
  //   x = f.call(x, a.x); 
  //   y = f.call(y, a.y);
  // }

  double dot(Vec2 v) { return x * v.x + y * v.y; }

  void addmul(Vec2 v, Vec2 w) {
    x += v.x * w.x;
    y += v.y * w.y;
  }

  void addmul(Vec2 v, double a) {
    x += v.x * a;
    y += v.y * a;
  }

  void muladd(Vec2 v, Vec2 w) {
    x = x * v.x + w.x;
    y = y * v.y + w.y;
  }

  void mix(Vec2 v, double a) {
    x += (v.x - x) * a;
    y += (v.y - y) * a;    
  }

  double mag() { return Math.sqrt(x * x + y * y); }
  double sqMag() { return x * x + y * y; }

  double dist(Vec2 v) {
    double dx = v.x - x, dy = v.y - y;
    return Math.sqrt(dx * dx + dy * dy);
  }

  double last_sqDist = 0.0, last_dx = 0.0, last_dy = 0.0;
  double sqDist(Vec2 v) {
    last_dx = v.x - x;
    last_dy = v.y - y;
    last_sqDist = last_dx * last_dx + last_dy * last_dy;
    return last_sqDist;
  }

  void normalize() {
    double a = Math.sqrt(x * x + y * y);
    x /= a; y /= a;
  }

  void rot90() {
    double t = x;
    x = -y;
    y = t;
  }

  String toString() {
    return "(" + Double.toString(x) + ", " + Double.toString(y) + ")";
  }

  void rand(double a) {
    x = a * (2.0 * v2_RNG.nextDouble() - 1.0);
    y = a * (2.0 * v2_RNG.nextDouble() - 1.0);
  }
  void rand() { 
    x = 2.0 * v2_RNG.nextDouble() - 1.0; 
    y = 2.0 * v2_RNG.nextDouble() - 1.0; 
  }

  void setrandoffset(Vec2 v, double a) {
    x = v.x + a * (2.0 * v2_RNG.nextDouble() - 1.0);
    y = v.y + a * (2.0 * v2_RNG.nextDouble() - 1.0);
  }
}

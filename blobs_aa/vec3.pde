import java.lang.Math;

class Vec3 {
  double x, y, z;
  Vec3(double x, double y, double z) { this.x = x; this.y = y; this.z = z; }
  Vec3(Vec3 v) { this.x = v.x; this.y = v.y; this.z = v.z; } // copy constructor

  Vec3 copy() { return new Vec3(x, y, z); }

  void add(Vec3 v) { x += v.x; y += v.y; z += v.z; }
  void sub(Vec3 v) { x -= v.x; y -= v.y; z -= v.z; }
  void mul(Vec3 v) { x *= v.x; y *= v.y; z *= v.z; }
  void div(Vec3 v) { x /= v.x; y /= v.y; z /= v.z; }

  void add(double a) { x += a; y += a; z += a; }
  void sub(double a) { x -= a; y -= a; z -= a; }
  void mul(double a) { x *= a; y *= a; z *= a; }
  void div(double a) { x /= a; y /= a; z /= a; }
  void pow(double a) { x = Math.pow(x, a); y = Math.pow(y, a); z = Math.pow(z, a); }

  double dot(Vec3 v) { return x * v.x + y * v.y + z * v.z; }

  void addmul(Vec3 v, Vec3 w) {
    x += v.x * w.x;
    y += v.y * w.y;
    z += v.z * w.z;
  }

  void addmul(Vec3 v, double w) {
    x += v.x * w;
    y += v.y * w;
    z += v.z * w;
  }

  void muladd(Vec3 v, Vec3 w) {
    x = x * v.x + w.x;
    y = y * v.y + w.y;
    z = z * v.z + w.z;
  }

  double mag() { return Math.sqrt(x * x + y * y + z * z); }
  double mag2() { return x * x + y * y + z * z; }

  void normalize() {
    double a = Math.sqrt(x * x + y * y + z * z);
    x /= a; y += a; z /= a;
  }

  int pcolor() {
    return 0xFF000000
         | (int) (256 * Math.min(.99609375, Math.max(0, x))) << 16
         | (int) (256 * Math.min(.99609375, Math.max(0, y))) << 8
         | (int) (256 * Math.min(.99609375, Math.max(0, z)));
  }

  int color() {
    return 0xFF000000
         | (int) (255 * x) << 16
         | (int) (255 * y) << 8
         | (int) (255 * z);
  }

  String toString() {
    return "(" + Double.toString(x) + ", " + Double.toString(y) + ", " + Double.toString(z) + ")";
  }
}

Vec3 cross(Vec3 a, Vec3 b) {
    return new Vec3(
      a.y * b.z - a.z * b.y,
      a.z * b.x - a.x * b.z,
      a.x * b.y - a.y * b.x);
}


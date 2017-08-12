import java.lang.Math;
  
abstract class SceneObject {
  Vec3 rgb;
  Vec3 radiance = new Vec3(0, 0, 0);
  double specular = 0.0;

  SceneObject(Vec3 rgb) {
    this.rgb = rgb;
  }

  abstract double DE(double x, double y, double z);

  private final double eps = 0.001;
  Vec3 n = new Vec3(0,0,0);
  void getNormal(Vec3 p) {
    n.x = DE(p.x + eps, p.y, p.z) - DE(p.x - eps, p.y, p.z);
    n.y = DE(p.x, p.y + eps, p.z) - DE(p.x, p.y - eps, p.z);
    n.z = DE(p.x, p.y, p.z + eps) - DE(p.x, p.y, p.z - eps);
    n.normalize();
  }  
  
  void sampleBRDF(Vec3 rd, Vec3 p) {
    // outputs into rd
    
    // calc reflected component (reusing rd)    
    rd.addmul(n, - 2 * rd.dot(n)); 
    // calc diffuse component
    // get random point on unit sphere
      double r1 = Math.random() * TAU, r2 = Math.random();
      double s = Math.sqrt(r2 * (1 - r2));    
      Vec3 diffuse = new Vec3(2 * Math.cos(r1) * s, 2 * Math.sin(r1) * s, 1 - 2 * r2);
      // lobe
      double bb = diffuse.dot(rd);
      rd.mul(bb);
      diffuse.sub(rd);
      diffuse.mul(Math.pow(1 - bb * bb, specular));
      diffuse.add(rd);
      diffuse.normalize();
      // wrong side? flip! now random point on hemisphere, oriented like normal
      if (diffuse.dot(n) < 0) { diffuse.mul(-1); }    
      rd = diffuse;
  }  
}

// Boolean ops -------------------------------------------------

class Inv extends SceneObject {
  SceneObject a;
  Inv(SceneObject a) { super(a.rgb); this.a = a; }
  double DE(double x, double y, double z) { return -a.DE(x, y, z); }
}
class Union extends SceneObject {
  SceneObject a, b;
  Union(SceneObject a, SceneObject b, Vec3 rgb) { super(rgb); this.a = a; this.b = b; }
  double DE(double x, double y, double z) { return Math.min(a.DE(x,y,z), b.DE(x,y,z)); }
}
class Intersection extends SceneObject {
  SceneObject a, b;
  Intersection(SceneObject a, SceneObject b, Vec3 rgb) { super(rgb); this.a = a; this.b = b; }
  double DE(double x, double y, double z) { return Math.max(a.DE(x,y,z), b.DE(x,y,z)); }
}
class Difference extends SceneObject {
  SceneObject a, b;  
  Difference(SceneObject a, SceneObject b, Vec3 rgb) { super(rgb); this.a = a; this.b = b; }
  double DE(double x, double y, double z) { return Math.max(a.DE(x,y,z), -b.DE(x,y,z)); }
}

// Domain ops --------------------------------------------------
double mod(double f1, double f2) { return (f1 - f2 * Math.floor(f1/f2)); }
class RepX extends SceneObject {
  SceneObject a; double c; 
  RepX(double c, SceneObject a) { super(a.rgb); this.a = a; this.c = c; }
  double DE(double x, double y, double z) { return a.DE(mod(x, c) - 0.5 * c, y, z); }
}
class RepY extends SceneObject {
  SceneObject a; double c; 
  RepY(double c, SceneObject a) { super(a.rgb); this.a = a; this.c = c; }
  double DE(double x, double y, double z) { return a.DE(x, mod(y, c) - 0.5 * c, z); }
}
class RepZ extends SceneObject {
  SceneObject a; double c; 
  RepZ(double c, SceneObject a) { super(a.rgb); this.a = a; this.c = c; }
  double DE(double x, double y, double z) { return a.DE(x, y, mod(z, c) - 0.5 * c); }
}

class RotateX extends SceneObject {
  SceneObject p; double cs, sn; 
  RotateX(double a, SceneObject p) { super(p.rgb); this.p = p; this.cs = Math.cos(-a); this.sn = Math.sin(-a); }
  double DE(double x, double y, double z) { return p.DE(x, y * cs - z * sn, y * sn + z * cs); }
}  
class RotateY extends SceneObject {
  SceneObject p; double cs, sn; 
  RotateY(double a, SceneObject p) { super(p.rgb); this.p = p; this.cs = Math.cos(-a); this.sn = Math.sin(-a); }
  double DE(double x, double y, double z) { return p.DE(x * cs - z * sn, y, x * sn + z * cs); }
}  
class RotateZ extends SceneObject {
  SceneObject p; double cs, sn; 
  RotateZ(double a, SceneObject p) { super(p.rgb); this.p = p; this.cs = Math.cos(-a); this.sn = Math.sin(-a); }
  double DE(double x, double y, double z) { return p.DE(x * cs - y * sn, x * sn + y * cs, z); }
}

class Translate extends SceneObject {
  SceneObject p; Vec3 v; 
  Translate(Vec3 v, SceneObject p) { super(p.rgb); this.p = p; this.v = v; }
  double DE(double x, double y, double z) { return p.DE(x - v.x, y - v.y, z - v.z); }
}

// Spheres -------------------------------------------------

class Sphere extends SceneObject {
  Vec3 m;
  double r, r2, m2;
  Sphere(double x, double y, double z, double r, Vec3 rgb) {
    super(rgb);
    this.m = new Vec3(x, y, z);
    this.r = r;
    this.m2 = m.mag2();
    this.r2 = r * r;
  }

  Vec3 p = new Vec3(0,0,0);
  double DE(double x, double y, double z) {
    p.x = x - m.x; p.y = y - m.y; p.z = z - m.z;
    return p.mag() - r;
  }  
}

class InvSphere extends SceneObject {
  Vec3 m;
  double r, r2, m2;
  InvSphere(double x, double y, double z, double r, Vec3 rgb) {
    super(rgb);
    this.m = new Vec3(x, y, z);
    this.r = r;
    this.m2 = m.mag2();
    this.r2 = r * r;
  }
  
  Vec3 p = new Vec3(0,0,0);
  double DE(double x, double y, double z) {
    p.x = x - m.x; p.y = y - m.y; p.z = z - m.z;
    return r - p.mag();
  }  
}

/*class SkySphere extends SceneObject {
  Vec3 m;
  double r, r2, m2;
  PImage sky;
  SkySphere(double x, double y, double z, double r, Vec3 rgb) {
    super(rgb);
    this.m = vec3(x, y, z);
    this.r = r;
    this.m2 = mag23(m);
    this.r2 = r * r;
    sky = loadImage("photo1d.png");
    sky.loadPixels();
  }
  
  double DE(double x, double y, double z) {
    return r - mag3(sub3(m, ro));
  }
  
  double DE(Vec3 ro, Vec3 rd) {
    return r - mag3(sub3(m, ro));
  }
  
  Vec3 getSurfaceColor(Vec3 p, Vec3 n) {
    if (p[2] < 0 || p[1] < 0) return vec3(0, 0, 0);
    double xx = (p[0]*.46) / r + 0.5;
    double yy = (r - p[1]) / r;
    int y = (int) (sky.height * yy);
    int x = (int) (sky.width * xx);
    x = Math.max(0, Math.min(sky.width-1, x));
    y = Math.max(0, Math.min(sky.height-1, y));
    int c = sky.pixels[y * sky.width + x];    
    Vec3 c3 = vec3(Math.scalb((double)(c & 0x00ff0000), -24), 
      Math.scalb((double)(c & 0x0000ff00), -16),
      Math.scalb((double)(c & 0x000000ff), -8));
    ipow3(c3, 2.2222);
    return c3;    
  }
}*/

// Cylinders -------------------------------------------------

class CylinderY extends SceneObject {
  Vec3 o;
  double r;
  CylinderY(double x, double y, double z, double r, Vec3 rgb) {
    super(rgb);
    this.o = new Vec3(x, 0, z);
    this.r = r;
  }

  Vec3 p = new Vec3(0,0,0);
  double DE(double x, double y, double z) {
    p.x = o.x - x; p.z = o.z - z; 
    return p.mag() - r;
  }
}

class CylinderZ extends SceneObject {
  Vec3 o;
  double r;
  CylinderZ(double x, double y, double z, double r, Vec3 rgb) {
    super(rgb);
    this.o = new Vec3(x, y, 0);
    this.r = r;
  }

  Vec3 p = new Vec3(0,0,0);
  double DE(double x, double y, double z) {
    p.x = o.x - x; p.y = o.y - y; 
    return p.mag() - r;
  }
}

// Planes -------------------------------------------------

class Plane extends SceneObject {
  Vec3 n;
  double d;
  Plane(double a, double b, double c, double d, Vec3 rgb) {
    super(rgb);
    this.n = new Vec3(a, b, c);
    n.normalize();
    this.d = d;
  }

  double DE(double x, double y, double z) {
    return n.x * x + n.y * y + n.z * z - d;
  }
}


// Torus ---------

class Torus extends SceneObject {
  Vec3 m;
  double r1, r2;
  Torus(double x, double y, double z, double r1, double r2, Vec3 rgb) {
    super(rgb);
    this.m = new Vec3(x, y, z);
    this.r1 = r1;
    this.r2 = r2;
  }

  Vec3 p = new Vec3(0,0,0);
  double DE(double x, double y, double z) {
      p.x = x - m.x; p.y = y - m.y; p.z = z - m.z;       
      double qx = Math.sqrt(p.x * p.x + p.z * p.z) - r1;
      return Math.sqrt(qx * qx + p.y * p.y) - r2;
  }  
}

// Boxes -----------

class RoundBox extends SceneObject {
  Vec3 m;
  Vec3 b;
  double r;
  RoundBox(double x, double y, double z, Vec3 b, double r, Vec3 rgb) {
    super(rgb);
    this.m = new Vec3(x, y, z);
    this.b = b;
    b.sub(r);
    this.r = r;
  }

  double DE(double x, double y, double z) {
    double d, mag = 0;
    double dm = 0;
    
    d = Math.abs(x - m.x) - b.x;    
    if (d > 0) { mag  = d * d; } else { dm = d; }
    d = Math.abs(y - m.y) - b.y;
    if (d > 0) { mag += d * d; dm = 0; } else { if (d > dm) { dm = d; } } 
    d = Math.abs(z - m.z) - b.z;
    if (d > 0) { mag += d * d; dm = 0; } else { if (d > dm) { dm = d; } } 
    return Math.sqrt(mag) + dm - r; 
  }  
}

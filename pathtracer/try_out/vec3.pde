import java.lang.Math;

double[] vec3(double x, double y, double z) { return new double[]{x, y, z}; } 

double[] add3(double[] a, double[] b) { return new double[]{a[0] + b[0], a[1] + b[1], a[2] + b[2]}; }
double[] sub3(double[] a, double[] b) { return new double[]{a[0] - b[0], a[1] - b[1], a[2] - b[2]}; }
double[] mul3(double[] a, double[] b) { return new double[]{a[0] * b[0], a[1] * b[1], a[2] * b[2]}; }
double[] div3(double[] a, double[] b) { return new double[]{a[0] / b[0], a[1] / b[1], a[2] / b[2]}; }

double[] add3(double[] a, double b) { return new double[]{a[0] + b, a[1] + b, a[2] + b}; }
double[] sub3(double[] a, double b) { return new double[]{a[0] - b, a[1] - b, a[2] - b}; }
double[] mul3(double[] a, double b) { return new double[]{a[0] * b, a[1] * b, a[2] * b}; }
double[] div3(double[] a, double b) { return new double[]{a[0] / b, a[1] / b, a[2] / b}; }
double[] pow3(double[] a, double b) { return new double[]{Math.pow(a[0], b), Math.pow(a[1], b), Math.pow(a[2], b)}; }

void iadd3(double[] a, double b[]) { a[0] += b[0]; a[1] += b[1]; a[2] += b[2]; }
void isub3(double[] a, double b[]) { a[0] -= b[0]; a[1] -= b[1]; a[2] -= b[2]; }
void imul3(double[] a, double b[]) { a[0] *= b[0]; a[1] *= b[1]; a[2] *= b[2]; }
void idiv3(double[] a, double b[]) { a[0] /= b[0]; a[1] /= b[1]; a[2] /= b[2]; }

void iadd3(double[] a, double b) { a[0] += b; a[1] += b; a[2] += b; }
void isub3(double[] a, double b) { a[0] -= b; a[1] -= b; a[2] -= b; }
void imul3(double[] a, double b) { a[0] *= b; a[1] *= b; a[2] *= b; }
void idiv3(double[] a, double b) { a[0] /= b; a[1] /= b; a[2] /= b; }
void ipow3(double[] a, double b) { a[0] = Math.pow(a[0], b); a[1] = Math.pow(a[1], b); a[2] = Math.pow(a[2], b); }

double dot3(double[] a, double[] b) { return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]; }

double[] addmul3(double[] a, double[] b, double[] c) { 
  return new double[]{a[0] + b[0] * c[0], a[1] + b[1] * c[1], a[2] + b[2] * c[2]}; 
}
double[] addmul3(double[] a, double[] b, double c) { 
  return new double[]{+a[0] + b[0] * c, a[1] + b[1] * c, a[2] + b[2] * c}; 
}
void iaddmul3(double[] a, double[] b, double[] c) {
  a[0] = a[0] + b[0] * c[0]; 
  a[1] = a[1] + b[1] * c[1]; 
  a[2] = a[2] + b[2] * c[2]; 
}
void iaddmul3(double[] a, double[] b, double c) {
  a[0] = a[0] + b[0] * c; 
  a[1] = a[1] + b[1] * c; 
  a[2] = a[2] + b[2] * c; 
}
void imuladd3(double[] a, double b, double[] c) {
  a[0] = a[0] * b + c[0]; 
  a[1] = a[1] * b + c[1]; 
  a[2] = a[2] * b + c[2]; 
}

double mag3(double[] a) { return Math.sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]); }
double mag23(double[] a) { return (a[0] * a[0] + a[1] * a[1] + a[2] * a[2]); }
double[] normalized3(double[] a) { return div3(a, mag3(a)); }
void normalize3(double[] a) { idiv3(a, mag3(a)); }

int color3(double[] c) {
  return 0xFF000000 
       | (int) (256 * Math.min(.99609375, c[0])) << 16
       | (int) (256 * Math.min(.99609375, c[1])) << 8
       | (int) (256 * Math.min(.99609375, c[2]));
}       

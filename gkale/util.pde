static final double phi = 1.618033988749895; // .5+.5*5**.5

int cAlpha(int c, double a) { return ((int) Math.min(255.0, 255.0 * a)) * 0x01000000 | (c & 0x00FFFFFF); }

String nfd(double x, int a, int b) { return nfs((float) x, a, b); }

int irand(int N) { return (int) (N * Math.random()); }
double brand() { return 2 * Math.random() - 1; }
double brand(double a) { return a * (2 * Math.random() - 1); }


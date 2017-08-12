import java.lang.Math;
import java.util.Arrays;

double[] pointOnSphere(double R) {
  double r1 = Math.random() * TAU, r2 = Math.random();
  double s = Math.sqrt(r2 * (1 - r2));
  return vec3(2 * R * Math.cos(r1) * s, 2 * R * Math.sin(r1) * s, R * (1 - 2 * r2));
}

void setup() {
  double[] p = pointOnSphere(0.75);
  size(500,100);
  textSize(16);
  fill(0);
  text("m="+Arrays.toString(p), 10, 30);   
}  

int N = 300;

void setup() {
  size(600, 600, P3D);
  sphereDetail(15);
  lights();
}

void draw() {
  float t = millis() / 1000.0;
  background(0);
  noStroke();
  pointLight(255,255,128, -5000, -5000, 1000);
  pointLight(24,24,72, 5000, 5000, 1000);
  //directionalLight(30, 30, 60, -1, -1, -1.5);
  /*lightSpecular(255, 255, 255);
  shininess(15.0);         
  specular(255,255,255);*/
  //ambientLight(32, 32, 64);
  pushMatrix();
    translate(width/2, height/2, 50);
    rotateY(t * 0.5);
    rotateX(t * 0.2);
    for (int i = 0; i < N; i++) {
      float a = TAU * i / N;
      pushMatrix();
        rotateX(a * 2);
        rotateY(a * 3 + t * 0.7);
        rotateZ(a * 1 + t * 0.3);
        translate(60 + 40 * sin(a * 5 + t * 0.4), 20 * sin(a * 4), 0);
        sphere(8);
      popMatrix();
    }
  popMatrix();
}

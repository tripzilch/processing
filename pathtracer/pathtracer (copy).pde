//import java.util.Collection;
import java.util.ArrayList;
import java.util.Arrays;
import java.lang.Math;

class Camera {
  Vec3 co, uu, vv, ww;
  int w, h; 
  int pix_size;
  double gamma = 0.45;
  double fov = 4.0;
  double focusDistance = 1.3;
  double blurAmount = 0.0015;
  int   numLevels = 4;

  Camera(double x, double y, double z) {
    co = vec3(x, y, z);
    uu = vec3(1, 0, 0);
    vv = vec3(0, 1, 0);
    ww = vec3(0, 0, 1);    
  }
  
  void lookAt(double x, double y, double z) { lookAt(vec3(x, y, z), vec3(0,1,0)); }
  void lookAt(Vec3 p) { lookAt(p, vec3(0,1,0)); }
  void lookAt(Vec3 p, Vec3 up) {
    ww = p.copy();
    ww.sub(co); ww.normalize();    
    uu = Vec3.cross(up, ww); uu.normalize();
    vv = Vec3.cross(ww, uu); uu.normalize(); // unnecessary normalize
  }

  double[] pixColor(double px, double py, int SAMPLES) {  
    double[] col = vec3(0,0,0);
    for(int i = 0; i < SAMPLES; i++) {  
      double x = (-w + 2 * px + Math.random() * 2) / h;
      double y = -(-h + 2 * py + Math.random() * 2) / h;
      
      double[] er = vec3(x, y, fov);
      normalize3(er);
      double[] rd = mul3(uu, er[0]);
      iaddmul3(rd, vv, er[1]);
      iaddmul3(rd, ww, er[2]);
      
      double[] go = vec3(Math.random() * 2 - 1, Math.random() * 2 - 1, 0);
      imul3(go, blurAmount);
      double[] gd = mul3(er, focusDistance);
      isub3(gd, go);
      normalize3(gd);
  
      double[] ro = addmul3(co, uu, go[0]);
      iaddmul3(ro, vv, go[1]);
  
      iaddmul3(rd, uu, gd[0]);
      iaddmul3(rd, vv, gd[1]);
      normalize3(rd);
      
      iadd3(col, world.rayColor(ro, rd, numLevels));
    }
    idiv3(col, SAMPLES);
    ipow3(col, gamma);
    return col;
  }
}

class World {
  ArrayList<SceneObject> objects = new ArrayList<SceneObject>();
  
  World(SceneObject... objects) {
    this.add(objects);
  }
  
  void add(SceneObject... objects) {
    this.objects.addAll(Arrays.asList(objects));
  }
    
  int MAX_RAY_STEPS = 512;
  double MIN_DISTANCE = 1.0;
  double MAX_DISTANCE = 2000.0;  
  double FUDGE = 16;  
  SceneObject hit_obj = null;
  double[] hit_pos;
  int steps;  
  
  double intersect(double[] ro, double[] rd, double max_distance) {
    double distance = MIN_DISTANCE * FUDGE, d;
    for (steps = 0; steps < MAX_RAY_STEPS; steps++) {
      hit_pos = addmul3(ro, rd, distance);
      hit_obj = null;
      double step_distance = max_distance;
      for (SceneObject object : objects) {
        d = object.DE(hit_pos, rd);
        if (d < step_distance) {
          step_distance = d;
          hit_obj = object;
        }
      }
      if (step_distance < MIN_DISTANCE) return distance;
      distance += step_distance;
      if (distance > max_distance) {
        hit_obj = null;
        return distance;
      }
    }
    hit_obj = null;
    return distance;
  }
  
  double shadow(double[] ro, double[] rd, double max_distance) {
    double distance = MIN_DISTANCE * FUDGE;
    double[] p;
    for (int steps = 0; steps < MAX_RAY_STEPS; steps++) {
      p = addmul3(ro, rd, distance);
      double step_distance = 1E+20;
      for (SceneObject object : objects) {
        step_distance = Math.min(step_distance, object.DE(p));
      }
      distance += step_distance;
      if (distance > max_distance) return 0;
      if (step_distance < MIN_DISTANCE) return 1;
    }    
    return 0;
  }
    
  double[] background = vec3(0, 0, 0);
  double[] getBackground(double[] dir) {
    return background;
  }
  
  double[] point_light = vec3(-300, 200, -100);
  double[] light_color = vec3(1,1,1);  
  double[] getDirectLight(double[] p, double[] n, SceneObject obj) {
    double[] to_light = sub3(point_light, p);
    double light_distance = mag3(to_light);
    idiv3(to_light, light_distance);
    double bshadow = shadow(p, to_light, light_distance * 0.99);
    double light = Math.max(0, dot3(n, to_light)) * (1 - bshadow);
    return mul3(light_color, light);
    //return obj.radiance;
  }
  
  int nRays = 0;
  double[] rayColor(double[] ro, double[] rd, int numLevels) {
    double[] cc = new double{}{1,1,1};    
    hit_pos = ro;
    for (int n = 0; n < numLevels; n++) {      
      nRays++;  
      intersect(hit_pos, rd, MAX_DISTANCE);  
      if (hit_obj == null) return getBackground(rd);     
      if (hit_obj.rgb != null) {
        // surf * radiance + surf * indirect
        imul3(cc, hit_obj.rgb);        
        rd = hit_obj.sampleBRDF(hit_pos, rd);        
      } else {
        imul3(cc, hit_obj.radiance);
        return cc;        
      }
      
    }
    return vec3(0,0,0);    
  }  
  
}
 
double start_time;
World world = new World();
Camera camera;

void build_scene() {
  world.objects.clear();
  //SceneObject room = new Inv(new Torus(0,0,0,300,200,vec3(0.7,0.7,0.7)));
  SceneObject room = new InvSphere(0,0,0,1000,vec3(0.3,0.3,0.7));
  //room.radiance = vec3(.1,.1,.1);  
  world.add(room);
  SceneObject light = new Sphere(-800, 500, 0, 300, null);
  light.radiance = vec3(5,5,5);
  world.add(light);
  SceneObject thing = new Torus(100,0,0,200,100,vec3(0.7,0.7,0.7));
  world.add(thing);
  /*for (int i = 0; i < 20; i++) {
    double x = (Math.random() + Math.random() - 1) * 500;
    double y = (Math.random() + Math.random() - 1) * 500;
    double z = (Math.random() + Math.random()) * 250;
    double r = 30; 
    SceneObject thing = new Sphere(x, y, z, r, vec3(0.4+Math.random()*.4, Math.random()*.7, Math.random()*.3));
    thing.specular = 30;
    world.add(thing);
  }*/
}

void setup() {
  size(640, 360);
  colorMode(RGB, 1.0);
  noStroke();

  //double room_height = 1500;
  //Inv room = new Inv(new RoundBox(0, room_height, 0, vec3(500, room_height, 700), 0, vec3(0.7,0.7,0.7)));
  
  //SceneObject reflector = new Plane(0, -1, 0, -900, vec3(1,1,1));  
  //SceneObject light = new Sphere(-400, 700, 0, 100, null);
  //light.radiance = vec3(3.5,3.5,3.5);
  //SceneObject mask = new RotateZ(0.4, new Difference(
//    new Plane(0, -1, 0, -500, null),
    //new CylinderY(0, 0, 200, 100, null),
    //vec3(0.7, 0.7, 0.7)    
  //)); 
  //mask.radiance = vec3(0.02,0.02,0.1);
  build_scene();
  
  camera = new Camera(0, 200, -400);
  camera.lookAt(0, 0, 0);
  camera.pix_size = 8;
  camera.w = width / camera.pix_size;
  camera.h = height / camera.pix_size; 
  
  start_time = millis();
}

int yy = 0, ii = 0;
void draw() {
  int ps = camera.pix_size;
  if (yy < camera.h) {    
    for (int k = 0; k < 4; k++, yy++) { 
      for (int xx = 0; xx < camera.w; xx++) {
        fill(color3(camera.pixColor(xx, yy, 256)));
        rect(xx * ps, yy * ps, ps, ps);
      }
    }
    if (yy >= camera.h) {
      log_time("Completed.");
      save("output/"+year()+"-"+month()+"-"+day()+"_"+hour()+"h"+minute()+".png");
      if (camera.pix_size > 1) {
        //build_scene();
        camera.pix_size >>= 1;
        camera.w = width / camera.pix_size;
        camera.h = height / camera.pix_size; 
        yy = 0;
        start_time = millis();
      }
    }
  }    
}

/*void mouseClicked() {
  fill(0);
  rect(0,0,width,height);
  yy = 0;
  ii = 0;
  start_time = millis();
  nRays = 0;
}*/

double avg = 0;
int avgN = 0;
void log_time(String s) {
  double ms = (millis() - start_time);
  double raytime = 1000 * ms / world.nRays;
  avg += raytime;
  avgN++; 
  println(s + " Total time: " + ms/1000 + " s.\n" + raytime + " μs/ray.\nAverage: " + avg / avgN + " μs/ray");
}

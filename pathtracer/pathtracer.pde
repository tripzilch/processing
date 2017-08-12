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
    co = new Vec3(x, y, z);
    uu = new Vec3(1, 0, 0);
    vv = new Vec3(0, 1, 0);
    ww = new Vec3(0, 0, 1);    
  }
  
  void lookAt(double x, double y, double z) { 
    lookAt(new Vec3(x, y, z), new Vec3(0,1,0)); 
  }
  void lookAt(Vec3 p) { 
    lookAt(p, new Vec3(0,1,0)); 
  }
  void lookAt(Vec3 p, Vec3 up) {
    ww = p.copy();
    ww.sub(co); ww.normalize();    
    uu = cross(up, ww); uu.normalize();
    vv = cross(ww, uu); vv.normalize(); // unnecessary normalize
  }

  Vec3 pixColor(double px, double py, int SAMPLES) {  
    Vec3 col = new Vec3(0,0,0);
    Vec3 er = new Vec3(0,0,0);
    Vec3 rd = new Vec3(0,0,0);
    Vec3 go = new Vec3(0,0,0);
    Vec3 ro = new Vec3(0,0,0);
    for(int i = 0; i < SAMPLES; i++) {  
      er.x = (-w + 2 * px + Math.random() * 2) / h;
      er.y = -(-h + 2 * py + Math.random() * 2) / h;
      er.z = fov;
      er.normalize();

      rd.x = uu.x * er.x + vv.x * er.y + ww.x * er.z;
      rd.y = uu.y * er.x + vv.y * er.y + ww.y * er.z;
      rd.z = uu.z * er.x + vv.z * er.y + ww.z * er.z;
      
      go.x = blurAmount * (Math.random() * 2 - 1);
      go.y = blurAmount * (Math.random() * 2 - 1);

      er.mul(focusDistance);
      er.sub(go);
      er.normalize();
  
      rd.addmul(uu, er.x);
      rd.addmul(vv, er.y);
      rd.normalize();

      ro.x = co.x + uu.x * go.x + vv.x * go.y;
      ro.y = co.y + uu.y * go.x + vv.y * go.y;
      ro.z = co.z + uu.z * go.x + vv.z * go.y;
  
      col.add(world.rayColor(ro, rd, numLevels));
    }
    col.div(SAMPLES);    
    col.pow(gamma);
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
  Vec3 hit_pos = new Vec3(0,0,0);
  int steps;  
  
  double intersect(Vec3 ro, Vec3 rd, double max_distance) {
    double distance = MIN_DISTANCE * FUDGE, d;
    for (steps = 0; steps < MAX_RAY_STEPS; steps++) {
      hit_pos.x = ro.x + rd.x * distance;
      hit_pos.y = ro.y + rd.y * distance;
      hit_pos.z = ro.z + rd.z * distance;
      hit_obj = null;
      double step_distance = max_distance;
      for (SceneObject object : objects) {
        d = object.DE(hit_pos.x, hit_pos.y, hit_pos.z);
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
    
  Vec3 background = new Vec3(1, 0, 0);
  Vec3 getBackground(Vec3 dir) {
    return background;
  }  
  
  int nRays = 0;
  Vec3 rayColor(Vec3 ro, Vec3 rd, int numLevels) {
    Vec3 cc = new Vec3(1,1,1);
    hit_pos = ro;
    for (int n = 0; n < numLevels; n++) {      
      nRays++;  
      intersect(hit_pos, rd, MAX_DISTANCE);  
      if (hit_obj == null) return getBackground(rd);     
      if (hit_obj.rgb != null) {
        // surf * radiance + surf * indirect
        cc.mul(hit_obj.rgb);        
        hit_obj.sampleBRDF(rd, hit_pos);
      } else {
        cc.mul(hit_obj.radiance);
        return cc;        
      }      
    }
    return new Vec3(0,0,0);    
  }  
  
}

Vec3 v3(double x, double y, double z) { return new Vec3(x, y, z); }
 
double start_time;
World world = new World();
Camera camera;

void build_scene() {
  world.objects.clear();
  //SceneObject room = new Inv(new Torus(0,0,0,300,200,vec3(0.7,0.7,0.7)));
  SceneObject room = new InvSphere(0,0,0,1000,v3(0.3,0.3,0.7));
  //room.radiance = vec3(.1,.1,.1);  
  world.add(room);
  SceneObject light = new Sphere(-800, 500, 0, 300, null);
  light.radiance = v3(5,5,5);
  world.add(light);
  SceneObject thing = new Torus(100,0,0,200,100,v3(0.7,0.7,0.7));
  world.add(thing);
}

void setup() {
  size(640, 360);
  colorMode(RGB, 1.0);
  noStroke();

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
        fill(camera.pixColor(xx, yy, 256).pcolor());
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

import java.util.Map;
import java.lang.Math;
// Grid Cell Class

static final int INITIAL_CAPACITY = 1333;
class Grid {
  HashMap<Integer,ArrayList<Vec2>> grid;
  double grid_spacing;
  int count;
  Grid(double max_distance) {
    this.grid = new HashMap<Integer,ArrayList<Vec2>>(INITIAL_CAPACITY);
    this.count = 0;
    this.grid_spacing = max_distance * 2;
  }

  void clear() {
    grid.clear();
    count = 0;
  }

  void add(Vec2 p) {
    int xi = (int) (p.x / grid_spacing);
    int yi = (int) (p.y / grid_spacing);
    int key = (xi << 16) + yi;
    ArrayList<Vec2> val = grid.get(key);
    if (val == null) {
      val = new ArrayList<Vec2>();
      grid.put(key, val);
    }
    val.add(p);
    count++;
  }

  ArrayList<Vec2> query(Vec2 p, double d) {
    double sqd = d * d;
    int xi0 = (int) ((p.x - d) / grid_spacing);
    int yi0 = (int) ((p.y - d) / grid_spacing);
    int xi1 = (int) ((p.x + d) / grid_spacing);
    int yi1 = (int) ((p.y + d) / grid_spacing);
    ArrayList<Vec2> result = new ArrayList<Vec2>();
    ArrayList<Vec2> cell;
    for (int xi = xi0; xi <= xi1; xi++) {
      int xk = xi << 16;
      for (int yi = yi0; yi <= yi1; yi++) {        
        cell = grid.get(xk + yi); // int key = xk + yi;
        if (cell == null) continue;
        for (Vec2 q: cell) if (q.sqDist(p) < sqd) result.add(q);
      }
    }
    return result;
  }
}

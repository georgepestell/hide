import java.util.TreeSet;

public final class RenderQueue { 

  private TreeSet<Renderable> objects;

  RenderQueue() {
    objects = new TreeSet<Renderable>(Comparator.comparingDouble(Renderable::getZ).thenComparing(Renderable::getId, Comparator.reverseOrder()));
  }

  void add(Renderable o) {
    o.id = WorldInfo.getNextId();
    objects.add(o);
  }

  void remove(Renderable o) {
    objects.remove(o);
  }

  void display() {

    // Render objects
    pushMatrix();
    translate(camera_pos.x, camera_pos.y);

    // Add a circle at the corners
    fill(200, 255, 200);
    circle(0,        0,         30);
    circle(MY_WIDTH, 0,         30);
    circle(0,        MY_HEIGHT, 30);
    circle(MY_WIDTH, MY_HEIGHT, 30);

    for (Renderable o : objects) {
      o.display();
    }
    popMatrix();

  }
  
}

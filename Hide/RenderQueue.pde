import java.util.TreeSet;

public final class RenderQueue { 

  private TreeSet<Renderable> queue;

  RenderQueue() {
    queue = new TreeSet<Renderable>(Comparator.comparingDouble(Renderable::getZ).thenComparing(Renderable::getId, Comparator.reverseOrder()));
  }

  void add(Renderable o) {
    o.id = WorldInfo.getNextId();
    queue.add(o);
  }

  void remove(Renderable o) {
    queue.remove(o);
  }

  void display() {
    for (Renderable o : queue) {
      o.display();
    }
  }
  
}

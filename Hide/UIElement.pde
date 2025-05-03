public abstract class UIElement extends Renderable {

  int x;
  int y;

  int w;
  int h;

  abstract void display();

  float getZ() {
    return Float.POSITIVE_INFINITY;
  }
    

}

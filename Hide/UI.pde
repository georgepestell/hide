public final class UI extends Renderable {

  ArrayList<UIElement> elements;

  int x;
  int y;

  UI(int x, int y) {
    this.x = x;
    this.y = y;
    this.elements = new ArrayList();
  }

  void add(UIElement element) {

    int newX = this.x;
    int newY = this.y;
    
    for (UIElement e : elements) {
      newX += e.w;
    }

    element.x = newX;
    element.y = newY;

    elements.add(element);
  }

  void display() {
    for (UIElement e : elements) {
      e.display();
    }
  }

  float getZ() {
    return Float.POSITIVE_INFINITY;
  }

}

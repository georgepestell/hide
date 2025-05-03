public final class HealthUI extends UIElement {

  Killable target;
  
  HealthUI(Killable target, int w, int h) {
    this.target = target;
    this.w = w;
    this.h = h;
  } 

  void display() {
    fill(0);
    rect(x, y, w, h);
    fill(255);
    textAlign(CENTER, CENTER);
    text("hp: " + Integer.toString(target.getHealth()), x + w/2, y + h/2);
  }

}

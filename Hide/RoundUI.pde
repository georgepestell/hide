public final class RoundUI extends UIElement {
  
  RoundUI(int w, int h) {
    this.w = w;
    this.h = h;
  }
  
  void display() { 
    stroke(255);
    fill(0);
    rect(x, y, w, h);
    fill(255);
    textAlign(CENTER, CENTER);
    text(Integer.toString(spawnManager.getRound()) + " : " + Integer.toString(spawnManager.getRemaining()), x + w / 2, y + h / 2);
  }

}

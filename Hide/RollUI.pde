public final class RollUI extends UIElement {

  RollUI(int w, int h) {
    this.w = w;
    this.h = h;
  } 

  void display() {
    strokeWeight(NORMAL);
    textAlign(CENTER, CENTER);
    textSize(h / 2.5);

    int rollEnd = player.lastRoll + player.rollTime;
    int rollCooldownEnd = rollEnd + player.rollCooldown;
    int now = millis();

    String statusText;

    int textColor = 0;

    if (rollEnd > now) {
      statusText = "...";
    } else if (rollCooldownEnd > now) {
      statusText = Integer.toString((rollCooldownEnd - now) / 1000 + 1);
    } else {
      statusText = "";
    }

    fill(0);
    stroke(255);
    rect(x, y, w, h);
    imageMode(CENTER);
    image(spacekeyArt, x + w/2, y + 3 * h/4, w, h);
    imageMode(CORNER);

    fill(255);
    textAlign(CENTER, TOP);
    text("Roll", x + w/2, y + h / 4);
    textAlign(CENTER, CENTER);

    if (!statusText.equals("")) {
      fill(0, 0, 0, 200);
      rect(x, y, w, h);
      fill(255);
      text(statusText, x + w / 2, y + h / 2);
    }

    textAlign(LEFT);
  }


}

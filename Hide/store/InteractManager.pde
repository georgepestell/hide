public final class InteractManager extends Renderable {

  boolean enabled = false;
  Interactable interactObject = null;
  
  void setObject(Interactable object) {
    this.interactObject = object;
  }

  void clearObject() {
    this.interactObject = null;
  }

  void enable() {
    this.enabled = true;
  }

  void disable() {
    this.enabled = false;
  }

  void interact() {
    if (this.enabled && this.interactObject != null) {
      interactObject.interact();
    } 
  }

  void display() {
    if (interactObject != null) {    
      textAlign(CENTER, BOTTOM);
      fill(0);
      stroke(255);
      PVector position = interactObject.getInteractPosition();
      text("x", position.x, position.y);
    }
  }

  float getZ() {
    return Float.POSITIVE_INFINITY;
  }

}

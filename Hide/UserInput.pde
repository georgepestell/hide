public final class UserInput extends ForceGenerator {

  float force;

  boolean left  = false;
  boolean right = false;
  boolean up    = false;
  boolean down  = false;

  boolean movingRight = false;
  boolean movingDown = false;

  MovementForce movementForce = new MovementForce();

  UserInput(float force) {
    this.force = force;
  }

  void setMovingRight(boolean value) {
    this.right = value;
    this.movingRight = value;
  }

  void setMovingLeft(boolean value) {
    this.left = value;
    this.movingRight = !value;
  }

  void setMovingDown(boolean value) {
    this.down = value;
    this.movingDown = value;
  }

  void setMovingUp(boolean value) {
    this.up = value; 
    this.movingDown = !value;
  }

  void update() {

    float x = 0;
    float y = 0;

    if (movingRight && right) {
      x = force;
    } else if (!movingRight && left) {
      x = -force;
    } 

    if (movingDown && down) {
      y = force;
    } else if (!movingDown && up) {
      y = -force;
    }

    if (!player.rolling) {
      movementForce.set(x, y);
    }
  }

  PVector getDirection() {
    return movementForce.direction;
  }

  void updateForce(PhysicsObject object) {
    movementForce.updateForce(object);
  }

  void setForce(float forceMult) {
    movementForce.setForce(forceMult);
  }

  boolean isMoving() {
    if (!left && !right && !up && !down) {
      return false;
    } else {
      return true;
    }
  }

}

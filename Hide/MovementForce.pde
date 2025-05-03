public final class MovementForce extends ForceGenerator {
 
  private PVector direction;
  private float force = 1;`

  MovementForce()  {
    this.direction = new PVector(0, 0);
  }

  void set(float x, float y) {
    direction.x = x;
    direction.y = y;
  } 

  void setX(float x) {
      direction.x = x;
  }

  void setY(float y) {
      direction.y = y;
  }

  void updateForce(PhysicsObject object) {
    object.addForce(PVector.mult(direction, force));
    
    // Set orientation
    if (direction.mag() > 0) {
      object.orientation = direction.get();
    }

  }

  void setForce(float force) {
    this.force = force;
  }

}

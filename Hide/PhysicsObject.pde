public abstract class PhysicsObject extends Renderable {

  PVector velocity;
  PVector position;
  float invMass;

  PVector orientation;

  PVector forceAccumulator = new PVector(0, 0);

  private float getMass() {
    if (invMass == 0) {
      return 0;
    }
    return 1 / invMass;
  }

  PhysicsObject(float invMass) {
    super();
    this.position = new PVector(0, 0);
    this.velocity = new PVector(0, 0);
    this.orientation = new PVector(1, 0);
    this.invMass = invMass;
  }

  void addForce(PVector force) {
    forceAccumulator.add(force);
  }

  void integrate() {

    if (invMass <= 0f) return;

    PVector resultingAcceleration = forceAccumulator.get();
    resultingAcceleration.mult(invMass);

    velocity.add(resultingAcceleration);
    position.add(velocity);

    forceAccumulator.x = 0;
    forceAccumulator.y = 0;

  }

  abstract ArrayList<PVector> getBoundingBox();
  abstract ArrayList<PVector> getFloorBoundingBox();
  abstract PVector getTilePosition();

}

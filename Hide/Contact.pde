public final class Contact { 

  PhysicsObject o1;
  PhysicsObject o2;

  // Coefficient of restitution
  float c;

  // Penetration depth
  float penDepth;

  PVector contactNormal;

  Weapon weapon = null;

  public Contact(PhysicsObject o1, PhysicsObject o2, float c, PVector contactNormal, float penDepth) {
    this.o1 = o1;
    this.o2 = o2;
    this.c = c;
    this.contactNormal = contactNormal;
    this.penDepth = penDepth;
  }

  void resolve() {
    resolveVelocity();

    if (penDepth > 0) {
      removePenetration();
    }
  }

  void resolveKnockback() {
    PVector relativeVel = PVector.sub(o1.velocity, o2.velocity);
    float velAlongNormal = PVector.dot(relativeVel, contactNormal);


    if (velAlongNormal > 0) {
      velAlongNormal = 0;
    } 

    float impulseMag = -(1 - c) * velAlongNormal;
    impulseMag += weapon.knockback;
    impulseMag /= (o2.invMass);


    PVector impulse = PVector.mult(contactNormal, impulseMag);

    o2.velocity.set(PVector.mult(impulse, -o2.invMass));
    o2.forceAccumulator.set(0, 0);
  }


  float calculateSepVelocity() {
    PVector relativeVelocity  = o1.velocity.get();
    relativeVelocity.sub(o2.velocity);
    return relativeVelocity.dot(contactNormal);
  }

  void removePenetration() {
    float totalInvMass = o1.invMass + o2.invMass;

    if (totalInvMass == 0) {
      return;
    }

    PVector correction = PVector.mult(contactNormal, penDepth / totalInvMass);
    o1.position.add(PVector.mult(correction, o1.invMass));
    o2.position.sub(PVector.mult(correction, o2.invMass));

  }

  void resolveVelocity() {

    PVector relativeVel = PVector.sub(o1.velocity, o2.velocity);
    float velAlongNormal = PVector.dot(relativeVel, contactNormal);

    if (velAlongNormal > 0) return;

    float impulseMag = -(1 - c) * velAlongNormal;
    impulseMag /= (o1.invMass + o2.invMass);

    PVector impulse = PVector.mult(contactNormal, impulseMag);

    o1.velocity.add(PVector.mult(impulse, o1.invMass));
    o2.velocity.sub(PVector.mult(impulse, o2.invMass));


    // float sepVelocity = calculateSepVelocity();

    // if (sepVelocity < 0) {
    //   // Subtract pen velocity
    //   sepVelocity = 0;
    // }

    // println("sep vel  = " + sepVelocity);

    // float newSepVelocity = -sepVelocity * c;

    // float deltaVelocity = newSepVelocity - sepVelocity;

    // float totalInvMass = o1.invMass + o2.invMass;

    // float impulse = deltaVelocity / totalInvMass;

    // PVector impulsePerMass = contactNormal.get();
    // impulsePerMass.mult(impulse);

    // PVector o1Impulse = impulsePerMass.get();
    // o1Impulse.mult(o1.invMass);

    // PVector o2Impulse = impulsePerMass.get();
    // o2Impulse.mult(-o2.invMass);

    // if (o1.invMass > 0) {
    //   o1.velocity.add(o1Impulse);
    // }
    // if (o2.invMass > 0) {
    //   o2.velocity.add(o2Impulse);
    // }

  }

}

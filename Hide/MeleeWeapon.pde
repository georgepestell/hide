import processing.sound.*;

class MeleeWeapon extends Weapon {
  
  SoundFile attackSound;

  int now = 0;

  float attackRadius = QUARTER_PI;
  float attackRangeWidth = 100;
  float attackRangeHeight = attackRangeWidth * 1.2;

  MeleeWeapon(PImage icon, SoundFile attackSound) {
    super(icon);
    this.attackSound = attackSound;
  }

  void update() {
    now = millis(); 
    if (attacking && lastAttack + attackLength < now) {
      attacking = false;
    } 
  } 

  void attack() {
    if (lastAttack + attackLength + attackCooldown < now) {
      attackSound.play();
      this.attacking = true; 
      this.lastAttack = now;
    }
  } 

  ArrayList<PVector> getBoundingBox() {
    ArrayList<PVector> bbox = new ArrayList();


    PVector startPoint = getPointOnEllipse(rotation - attackRadius);
    PVector endPoint = getPointOnEllipse(rotation + attackRadius);
    PVector midPoint = getPointOnEllipse(rotation);

    float minX = min(origin.x, min(startPoint.x, min(endPoint.x, midPoint.x)));
    float maxX = max(origin.x, max(startPoint.x, max(endPoint.x, midPoint.x)));
    float minY = min(origin.y, min(startPoint.y, min(endPoint.y, midPoint.y)));
    float maxY = max(origin.y, max(startPoint.y, max(endPoint.y, midPoint.y)));

    bbox.add(new PVector(minX, minY));
    bbox.add(new PVector(maxX, minY));
    bbox.add(new PVector(maxX, maxY));
    bbox.add(new PVector(minX, maxY));


    return bbox;

  }
  
  float getZ() {
    PVector midPoint = getPointOnEllipse(rotation);
    float maxY = max(origin.y, midPoint.y);
    return maxY;
  }

  PVector getPointOnEllipse(float angle) {
    return new PVector(origin.x + (attackRangeWidth / 2) * cos(angle), origin.y + (attackRangeHeight/2) * sin(angle));
  } 

  void display() {
    if (attacking) {
      fill(255, 255, 255, 200);
      noStroke();
      // Draw cone
      pushMatrix();
      translate(origin.x, origin.y);
      arc(0, 0, attackRangeWidth, attackRangeHeight, rotation - attackRadius, rotation + attackRadius);
      popMatrix();
    }
  }

}

public final class Player extends PhysicsObject implements Killable, Wielder {

  private int currentFrame, offsetX, offsetY, totalFrames, row, sx, sy;

  int w;
  int h;

  int scale;

  int health;

  final int rollCooldown = 1000;
  final int rollTime = 500;
  boolean rolling = false;
  int lastRoll = 0;

  int lastAnimation = 0;
  float animationPhaseShift = HALF_PI;

  int now = 0;

  final int damageInvulnerableTime = 2000;
  boolean invulnerable = false;
  int lastDamage = 0;

  Player(int x, int y) {
    super(1);
    this.position = new PVector(x, y);
    this.w = (int) (TILE_WIDTH * 0.8);
    this.h = w * 2;

    this.currentFrame = 0;
    this.offsetX = 0 * w;
    this.offsetY = 0 * h;
    this.totalFrames = 2;
    this.row = 0;
    this.sx = 0;
    this.sy = 0;
    this.health = 3;
  }

  void update() {
    now = millis();
    if (this.rolling) {

      if (lastRoll + rollTime < now) {
        rolling = false;
        userInput.setForce(1);
        userInput.update();
      }


    }
    if (invulnerable && lastDamage + damageInvulnerableTime < now) {
      this.invulnerable = false;
    } 

  } 

  void display() {
    // PImage sprite = playerArt.get(sx+offsetX, sy+offsetY, w, h);
    // sprite.resize(w * scale, h * scale);
    // image(sprite, x, y, w * scale, h * scale);
    if (this.invulnerable) {
      float time = now - lastAnimation;
      float a = sin(TWO_PI * time * (1 / ((float) damageInvulnerableTime / 2)) + animationPhaseShift) * 255;
      fill(255, 100, 100, a);
    } else if (this.rolling) {
      float time = now - lastAnimation;
      float a = sin(TWO_PI * time * (1 / (float) rollTime) + animationPhaseShift) * 255;
      fill(255, 255, 255, a);
    } else {
      fill(255);
    }

    stroke(0);
    rectMode(CENTER);
    rect(this.position.x, this.position.y - h / 2, w, h);
    rectMode(CORNER);

  }

  PVector getEyePos() {
    return new PVector(
        this.position.x + this.w / 2,
        this.position.y + this.h / 4
    );
  }

  float getZ() {
    return this.position.y + this.h / 2;
  }

  ArrayList<PVector> getBoundingBox() {
    ArrayList<PVector> bbox = new ArrayList();

    PVector ul = position.get();
    ul.x -= w / 2;
    ul.y -= h / 2;

    bbox.add(ul);
    bbox.add(PVector.add(ul, new PVector(w, 0)));
    bbox.add(PVector.add(ul, new PVector(w, h)));
    bbox.add(PVector.add(ul, new PVector(0, h)));

    return bbox;
  }

  ArrayList<PVector> getFloorBoundingBox() {
    ArrayList<PVector> bbox = new ArrayList();

    float bboxHeight = 5;
    
    PVector ul = position.get();
    ul.y -= bboxHeight;
    ul.x -= w / 2;

    PVector ur = ul.get();
    ur.x += w;

    PVector lr = ur.get();
    lr.y += bboxHeight;

    PVector ll = ul.get();
    ll.y += bboxHeight;

    bbox.add(ul);
    bbox.add(ur);
    bbox.add(lr);
    bbox.add(ll);
    
    return bbox;
  }

  void roll() {

    if (!userInput.isMoving()) {
      return;
    }

    if (rolling) {
      return;
    }

    if (lastRoll + rollTime + rollCooldown > now) {
      return;
    }

    userInput.setForce(3);
    this.lastRoll = now;
    this.lastAnimation = now;
    this.rolling = true;
  }

  PVector getWeaponOrigin() {
    PVector origin = position.get();
    origin.y -= h / 2;
    return origin;
  }

  float getRotation() {
    float angle = atan2(orientation.y, orientation.x);
    return angle;

  }

  PVector getTilePosition() {
   int tileX = constrain((int) (position.x / TILE_WIDTH), 0, TILES_X - 1);
   int tileY = constrain((int) ((position.y - 1) / TILE_HEIGHT), 0, TILES_Y - 1);
   return new PVector(tileX, tileY);
  }

  int getHealth() {
    return this.health;
  }

  void damage() {
    if (!this.invulnerable && !this.rolling) {
      this.health--;
      this.invulnerable = true;
      this.lastAnimation = now;
      this.lastDamage = millis();
    }
  }

}

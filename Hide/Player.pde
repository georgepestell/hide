public final class Player extends PhysicsObject implements Killable, Wielder {

  private int currentFrame, spriteDirection, offsetX, offsetY, totalFrames, row, sx, sy;

  int w;
  int h;

  int health;

  final int rollCooldown = 1000;
  final int rollTime = 550;
  boolean rolling = false;
  int lastRoll = 0;
  int lastRollFrame = 0;

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
    this.spriteDirection = 1;
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
        currentFrame = 0;
        userInput.setForce(1);
        userInput.update();
      }


    }
    if (invulnerable && lastDamage + damageInvulnerableTime < now) {
      this.invulnerable = false;
    } 

    if (!rolling) {
      if (userInput.getDirection().mag() >= 1f) {

        offsetX = 9;

        if (frameCount % 16 == 0) {
          currentFrame++;
          currentFrame %= totalFrames;
        }

      } else {
        offsetX = 0;
        currentFrame = 0;
      }
  }

  } 

  void display() {

    // Update sprite based on velocity and direction
    
    // TODO: velocity player sprite
    
    PImage sprite;
    if (!rolling) {     
      if (orientation.mag() > 0.00001f) {
      
        if (abs(orientation.x) < 0.0001f) {
          offsetY = 42;
        } else {
          offsetY = 0;
        }

        if (orientation.x > 0 && orientation.x > 0.00001f) {
          // Facing right
          this.spriteDirection = 1;
        } else if (orientation.x < -0.00001f) {
          // Facing left
          this.spriteDirection = -1;
        }

        if (orientation.y < 0 && orientation.y < -0.00001f) {
          offsetY += 21;
        } 
      }

      sprite = playerArt.get(sx+offsetX+currentFrame*9, sy+offsetY, 9, 21);
      
    } else {
      // Render roll animation
      offsetY = 0;
      offsetX = 0;

      if (frameCount % 3 == 0 && currentFrame < 10) {
        currentFrame++;
      }

      sprite = rollingArt.get(sx+offsetX+currentFrame*9, sy+offsetY, 9, 21);
    }
   

    pushMatrix();

    if (this.invulnerable) {
      sprite.filter(GRAY);
      float time = now - lastAnimation;
      float a = sin(TWO_PI * time * (1 / ((float) damageInvulnerableTime / 2)) + animationPhaseShift) * 155 + 100;
      tint(a, 100, 100);
    }

  

    imageMode(CENTER);
    translate(position.x, position.y - h / 2);
    scale(this.spriteDirection, 1);
    image(sprite, 0, 0, w, h);
    imageMode(CORNER);
    popMatrix();

    noTint();


    // stroke(0);
    // rectMode(CENTER);
    // fill(255, 255, 255, 100);
    // rect(this.position.x, this.position.y - h / 2, w, h);
    // rectMode(CORNER);

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
    this.lastRollFrame = frameCount;
    this.lastAnimation = now;
    this.rolling = true;
    this.currentFrame = 0;
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

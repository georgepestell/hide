enum State {
  SEARCHING,
  HUNTING,
  HURT,
  JUMPING,
  DISABLED
}

public final class Blob extends PhysicsObject implements Killable {

  final int jumpTime = 500;
  final int jumpCooldown = 2000;
  final float jumpForce = 3;

  final int attackDistance = 4;

  int lastJump = 0;

  float speed = 0.8;
  State state = State.HUNTING;

  int pathUpdateTime = 500; // update path every 2 seconds
  int lastUpdate = Integer.MIN_VALUE;
  int now = 0;

  int health;

  int lastInvulnerable = 0;
  int invulnerableTime = 500;
  boolean invulnerable = false;

  int disableTime = 1000;
  int lastDisabled = 0;

  Queue<PVector> path;

  int w;
  int h;

  boolean dead = false;

  MovementForce blobInput;

  private final float DISTANCE_THRESHOLD = TILE_WIDTH/2;

  Blob(int x, int y, int w, int h) {
    super(0.5);
    this.position = new PVector(((float) x + 0.5) * TILE_WIDTH, (y + 0.5) * TILE_HEIGHT);
    this.w = w;
    this.h = h;
    this.health = 2;

    blobInput = new MovementForce();
    fr.add(this, blobInput);

  }

  public void update() {

    // Update internal clock
    now = millis();

    // Update invulnerability
    if (invulnerable && lastInvulnerable + invulnerableTime < now) {
      invulnerable = false;
    } 

    // Allow blobs to be disabled
    if (state == State.DISABLED) {
      return;
    } 

    // Only update state if we are not disabled
    if (state != State.HURT || lastDisabled + disableTime < now) {

      // Keep jumping until jumping is complete
      int jumpEnd = lastJump + jumpTime;
      if (state != State.JUMPING || jumpEnd < now) {

        // Update the path
        if (path == null || lastUpdate + pathUpdateTime < now) {
          updatePath();
        }

        // Attack if close enough to the player
        if (jumpEnd + jumpCooldown < now && path != null && path.size() <= attackDistance && pathFinder.canSee(this, player)) {
            jump();
        // Otherwise, hunt the player
        } else {
          setHunting();
        }

      } 
    }
  }

  void setHunting() {
    state = State.HUNTING;

    PVector direction = getPathDirection();
    blobInput.setForce(speed);
    blobInput.set(direction.x, direction.y);
  }
  
  void jump() {
    state = State.JUMPING;
    lastJump = now;

    // Set direction
    PVector direction = getAttackDirection();
    blobInput.set(direction.x, direction.y);
    blobInput.setForce(jumpForce);

  }

  void updatePath() {
    lastUpdate = now;
    path = pathFinder.generatePath(getTilePosition(), player.getTilePosition());
  } 

  void disable() {
    this.state = State.DISABLED;
    this.blobInput.set(0, 0);
  }
  
  void enable() {
    this.state = State.HUNTING;
  }

  PVector getPathDirection() {
    if (path == null) {
      return new PVector(0, 0);
    }

    PVector source = position.get();
    source.y -= h / 2;

    float distance;

    while (!path.isEmpty()) {
      PVector target = path.peek().get();
      target.x *= TILE_WIDTH;
      target.y *= TILE_HEIGHT;

      target.x += TILE_WIDTH / 2;
      target.y += TILE_HEIGHT / 2;
      
      // Get the distance to target
      PVector direction = target.sub(source);

      // Move towards path segments until we are close enough
      if (direction.mag() > DISTANCE_THRESHOLD) {
        return direction.normalize();

      // Remove path segments we have reached
      } else {
        path.poll();
      }
    }

    return new PVector(0, 0);
  }

  PVector getAttackDirection() {
    PVector source = position.get();
    source.y -= h / 2;

    PVector target = player.position.get();
    target.y -= player.h / 4;

    return target.sub(source).normalize();
  }

  void display() {
    noStroke();
    
    if (state == State.HURT) {
      fill(0, 255, 0, 120); 
    } else {
      fill(0, 255, 0, 200); 
    }
    rectMode(CENTER);
    rect(position.x, position.y - h / 2, w, h); 
    rectMode(CORNER);

    // // DEBUG: show path
    // if (path != null) {
    //   fill(0, 0, 255, 100);
    //   for (PVector t : path) {
    //     rect(t.x * TILE_WIDTH, t.y * TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT);
    //   }
    // }

  }

  ArrayList<PVector> getBoundingBox() {
    ArrayList<PVector> bbox = new ArrayList();

    PVector ul = position.get();
    ul.x -= w / 2;
    ul.y -= h;

    bbox.add(ul);
    bbox.add(PVector.add(ul, new PVector(w, 0)));
    bbox.add(PVector.add(ul, new PVector(w, h)));
    bbox.add(PVector.add(ul, new PVector(0, h)));

    return bbox;
  }
  ArrayList<PVector> getFloorBoundingBox() {
    return getBoundingBox();
  }

  float getZ() {
    return this.position.y; 
  }
   
  PVector getTilePosition() {
   int tileX = constrain((int) (position.x / TILE_WIDTH), 0, TILES_X - 1);
   int tileY = constrain(round((position.y - h/2 - 1) / TILE_HEIGHT), 0, TILES_Y - 1);
   
   return new PVector(tileX, tileY);
  }

  int getHealth() {
    return health;
  }

  void damage() {

    if (invulnerable) {
      return;
    }

    this.health--;

    if (this.health <= 0) {
      this.dead = true;
      return;
    }

    invulnerable = true;
    lastInvulnerable = millis();
    state = State.HURT;
    this.blobInput.set(0, 0);
    lastDisabled = now;


  }  

}

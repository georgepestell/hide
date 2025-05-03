public class Locker extends PhysicsObject { 

  float w;
  float h;

  boolean occluded = false;

  Locker(float x, float y) {
    super(0);
    this.w = TILE_WIDTH;
    this.h = TILE_HEIGHT * 2;
    this.position.x = x * TILE_WIDTH + (TILE_WIDTH / 2 - w/2);
    this.position.y = (y + 1) * TILE_HEIGHT + (TILE_HEIGHT / 2 - w/2);
  }

  void display() {
    if (this.occluded) {
      tint(255, 100);
    } else {
      tint(255, 255);
    }
    noStroke();
    image(lockerArt, position.x, position.y - h, w, h);
    noTint();
    this.occluded = false;
  }

  float getZ() {
    return this.position.y;
  }

  ArrayList<PVector> getBoundingBox() {

    ArrayList<PVector> bbox = new ArrayList();

    PVector origin = position.get();
    origin.y -= h;

    bbox.add(origin);
    bbox.add(PVector.add(origin, new PVector(w, 0)));
    bbox.add(PVector.add(origin, new PVector(w, h)));
    bbox.add(PVector.add(origin, new PVector(0, h)));

    return bbox;


  }

  ArrayList<PVector> getFloorBoundingBox() {

    ArrayList<PVector> bbox = new ArrayList();

    float boxHeight = TILE_HEIGHT;

    PVector origin = position.get();
    origin.y -= boxHeight;

    bbox.add(origin);
    bbox.add(PVector.add(origin, new PVector(w, 0)));
    bbox.add(PVector.add(origin, new PVector(w, boxHeight)));
    bbox.add(PVector.add(origin, new PVector(0, boxHeight)));

    return bbox;
  }

  void interact() {
    System.out.println("interacted with locker");
  }

  PVector getInteractPosition() {
    PVector p = this.position.get();
    p.add(this.w / 2, - this.h);
    return p;
  }

  PVector getTilePosition() {
   int tileX = constrain((int) (position.x / TILE_WIDTH), 0, TILES_X - 1);
   int tileY = constrain((int) ((position.y - 1) / TILE_HEIGHT), 0, TILES_Y - 1);
   return new PVector(tileX, tileY);
  }

}

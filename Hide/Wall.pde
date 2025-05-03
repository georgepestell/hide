public final class Wall extends PhysicsObject {

  float depth;
  int w;
  int h;

  int tiles_w;
  int tiles_h;

  Wall(int tile_x, int tile_y, int w, int h) {
    super(0);
    this.position = new PVector(tile_x * TILE_WIDTH, tile_y * TILE_HEIGHT);
    this.w = w * TILE_WIDTH;
    this.h = h * TILE_HEIGHT;
    this.tiles_w = w * 10;
    this.tiles_h = h * 10;
  }

  void display() {
    noStroke();
    textureWrap(REPEAT);
    beginShape();
    texture(wallArt);
    vertex(position.x, position.y, 0, 0);
    vertex(position.x + w, position.y, tiles_w, 0);
    vertex(position.x + w, position.y + h, tiles_w, tiles_h);
    vertex(position.x, position.y + h, 0, tiles_h);
    endShape();
  }

  float getZ() {
    return position.y + h;
  }

  ArrayList<PVector> getBoundingBox() {
    ArrayList<PVector> bbox = new ArrayList();

    PVector origin = this.position.get();

    bbox.add(origin);
    bbox.add(PVector.add(origin, new PVector(w, 0)));
    bbox.add(PVector.add(origin, new PVector(w, h)));
    bbox.add(PVector.add(origin, new PVector(0, h)));

    return bbox;
  }

  PVector getTilePosition() {
   int tileX = constrain((int) (position.x / TILE_WIDTH), 0, TILES_X - 1);
   int tileY = constrain((int) ((position.y - 1) / TILE_HEIGHT), 0, TILES_Y - 1);
   return new PVector(tileX, tileY);
  }

  ArrayList<PVector> getFloorBoundingBox() {
    return getBoundingBox();
  }

}

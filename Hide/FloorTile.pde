public final class FloorTile extends Renderable {

  int w;
  int h;

  PVector position;

  FloorTile(int x, int y, int w, int h) {
    this.position = new PVector(x, y);
    this.w = w;
    this.h = h;
  }

  void display() {
    fill(100, 255, 100);
    rect(position.x, position.y, w, h);
  }

  float getZ() {
    return Float.NEGATIVE_INFINITY;
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

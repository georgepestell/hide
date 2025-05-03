public class FloorTile {

  PImage asset;
  
  float x;
  float y;
  float w;
  float h;

  FloorTile(PImage asset, float x, float y, float w, float h) {
    this.asset = asset;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void display() {
    // Draw asset
    image(asset, x, y, w, h);
  }
  

}

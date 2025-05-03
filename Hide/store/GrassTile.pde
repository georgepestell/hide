public final class GrassTile extends FloorTile {

  GrassTile(PImage asset, float x, float y, float w, float h) {
    super(asset, x, y, w, h);
  }
   

  GrassTile(float x, float y, float w, float h) {
    super(null, x, y, w, h);
    float isEmpty = random(0, 1);
    PImage a;

    if (isEmpty > 1) {
      this.asset = grassArt.get(0); 
    } else {
      int i = (int) random (1, 4);
      this.asset = grassArt.get(i);
    }

    
  }

}

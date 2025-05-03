public class Inventory extends UIElement {
  
  int rowCount;

  int maxItems;
  int rowSize;

  int itemW;
  int itemH;

  Inventory(int x, int y, int itemW, int itemH, int maxItems, int rowSize) {
    super();
    this.x = x;
    this.y = y;
    this.maxItems = maxItems;
    this.rowSize = rowSize;
    this.rowCount = ceil((float) maxItems / (float) rowSize);
    this.itemW = itemW;
    this.itemH = itemH;
    this.w = rowSize * itemW;
    this.h = rowCount * itemH;
  }

  void display() {
    for (int row = 0; row < rowCount; row++) {
      for (int col = 0; col < rowSize; col++) {
        stroke(255);
        fill(0);
        rect(x + col * itemW, y + row * itemW, itemW, itemH);
      } 
    }
  }

  float getZ() {
    return Float.POSITIVE_INFINITY;
  }


}

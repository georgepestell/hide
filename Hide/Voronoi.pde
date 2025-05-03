static class Voronoi {
  public static void generate(
      PApplet sketch,
    int tilesX, int tilesY,
    int tileW, int tileH,
    int numRegions,
    PVector[] centers,
    int[][] regions,
    boolean[][] borders
  ) {

    int totalW = tilesX * tileW;
    int totalH = tilesY * tileH;

    // Generate region centers (ensure they're spaced out)
    for (int i = 0; i < numRegions; i++) {
      boolean validPosition = false;
      while (!validPosition) {
        centers[i] = new PVector(
          (int)sketch.random(tilesX) * tileW + tileW/2, 
          (int)sketch.random(tilesY) * tileH + tileH/2
        );
        validPosition = true;
        // Ensure minimum distance between centers
        for (int j = 0; j < i; j++) {
          if (PVector.dist(centers[i], centers[j]) < max(tileW, tileH)*1.5) {
            validPosition = false;
            break;
          }
        }
      }
    }
    
    // First pass: Determine regions
    for (int ty = 0; ty < tilesY; ty++) {
      for (int tx = 0; tx < tilesX; tx++) {
        PVector tileCenter = new PVector(tx*tileW + tileW/2, ty*tileH + tileH/2);
        regions[ty][tx] = findClosestRegion(tileCenter, centers);
      }
    }
    
    // Vertical borders 
    for (int y = 0; y < tilesY; y++) {
      for (int x = 0; x < tilesX; x++) {

        int current = regions[y][x];

        if (x > 0 && regions[y][x] != regions[y][x-1] && !borders[y][x-1]) {
          borders[y][x] = true;
        } else if (x < tilesX - 1 && regions[y][x] != regions[y][x+1]) {
          borders[y][x] = true;
        }
        if (y > 0 && regions[y][x] != regions[y-1][x] && !borders[y-1][x]) {
          borders[y][x] = true;
        } else if (y < tilesY - 1 && (y == 0 || !borders[y-1][x]) && regions[y][x] != regions[y+1][x]) {
          borders[y][x] = true;
        }

        // if ((tx < tilesX - 1 && regions[ty][tx+1] != current) || (ty < tilesY-1 && regions[ty+1][tx] != current)) {
        // borders[ty][tx] = true;
        // }
      }
    }
    
  }
  
  // Crete
  private static PGraphics generateTexture(PApplet sketch, int tilesX, int tilesY, int tileW, int tileH, int numRegions, int[][] regions, boolean[][] borders) {

    int totalW = tilesX * tileW;
    int totalH = tilesY * tileH;

    PGraphics image = sketch.createGraphics(totalW, totalH);

    // Generate colours for each region
    color[] colors = new color[numRegions];
    for (int i = 0; i < numRegions; i++) {
      colors[i] = sketch.color(sketch.random(155), sketch.random(155), sketch.random(155));
    }

    image.beginDraw();
    image.background(100);

    for (int ty = 0; ty < tilesY; ty++) {
      for (int tx = 0; tx < tilesX; tx++) {

       //  if (!borders[ty][tx]) {
           image.fill(colors[regions[ty][tx]]);
       //  } else {
       //    image.fill(0);
       //  }

        image.noStroke();

        image.rect(tx * tileW, ty * tileH, tileW, tileH);

      }
    }

    image.endDraw();

    return image;

  }

  private static int findClosestRegion(PVector point, PVector[] centers) {
 int closest = 0;
    float minDist = Float.MAX_VALUE;
    for (int i = 0; i < centers.length; i++) {
      float d = PVector.dist(point, centers[i]);
      if (d < minDist) {
        minDist = d;
        closest = i;
      }
    }
    return closest;
  }
}

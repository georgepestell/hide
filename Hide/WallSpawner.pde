import java.util.HashMap;

public class Spawner extends Renderable {

  // Relative probabilities of each
  // private HashMap<PhysicsObject, int> spawnList;
  
  int tile_x;
  int tile_y;
  
  int x;
  int y;

  int spawnTileX;
  int spawnTileY;

  float spawnCenterX, spawnCenterY;
  float tX, tY;

  int spawning = 0;
 
  float rotation = 0;

  float fontSize = min(TILE_WIDTH, TILE_HEIGHT);

  // The time it takes to actually spawn an enemy in milliseconds
  final int spawnTime = 4000;
 
  // Blink 3 times
  final int animationTime = spawnTime / 3;

  int lastSpawn = 0;
  int now = 0;

  Spawner(int tile_x, int tile_y, int offsetX, int offsetY) {
    this.tile_x = tile_x;
    this.tile_y = tile_y;
    this.x = tile_x * TILE_WIDTH + ((offsetX + 1) * TILE_WIDTH / 2);
    this.y = tile_y * TILE_HEIGHT + ((offsetY + 1) * TILE_HEIGHT / 2);
    this.spawnTileX = tile_x + offsetX;
    this.spawnTileY = tile_y + offsetY;

    this.spawnCenterX = (spawnTileX + 0.5) * TILE_WIDTH;
    this.spawnCenterY = (spawnTileY + 0.5) * TILE_HEIGHT;

    if (offsetX != 0) {
      rotation = radians(90 * -offsetX);
    } else if (offsetY == -1) {
      rotation = radians(180);
    }
    tX = (tile_x + 0.5) * TILE_WIDTH;
    tY = (tile_y + 0.5) * TILE_HEIGHT; 

  }

  public void spawn() {
    if (lastSpawn + spawnTime < now) {
      lastSpawn = now;
    }
    spawning++;
  } 

  public void update() {
    now = millis();
    if (spawning > 0) {
      if (lastSpawn + spawnTime < now) {
        Blob blob = new Blob(spawnTileX, spawnTileY, TILE_WIDTH, TILE_HEIGHT);
        fr.add(blob, drag);
        blobs.add(blob);
        lastSpawn = now;
        spawning--;
      }
    } 
  }

  public void display() {

    pushMatrix();
    imageMode(CENTER);
    translate(tX, tY);
    rotate(rotation);
    image(windowArt, 0, 0, TILE_WIDTH, TILE_HEIGHT);
    popMatrix();

    // Draw an ora around the spawner
    fill(10, 255, 0, 30);
    circle(tX, tY, 100);

    if (spawning > 0) {
      float a = 127.5 + (sin(TWO_PI * (now % animationTime) / animationTime) + 1) * 127.5;
      pushMatrix();
      textSize(fontSize);
      textAlign(CENTER, CENTER);
      translate(spawnCenterX, spawnCenterY);
      rotate(rotation + PI);
      fill(255, 0, 0, a);
      text("!", 0, 0);
      textAlign(LEFT);
      popMatrix();
    }

  }

  public float getZ() {
    return Float.MAX_VALUE;
  }

}


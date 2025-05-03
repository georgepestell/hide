import java.util.HashMap;

public class FloorSpawner extends Renderable {

  int x;
  int y;

  int spawning = 0;
 
  float fontSize = min(TILE_WIDTH, TILE_HEIGHT);

  // The time it takes to actually spawn an enemy in milliseconds
  final int spawnTime = 4000;
 
  // Blink 3 times
  final int animationTime = spawnTime / 3;

  int lastSpawn = 0;
  int now = 0;

  FloorSpawner(int x, int y) {
    this.x = x;
    this.y = y;
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
        Blob blob = new Blob(x, y, TILE_WIDTH, TILE_HEIGHT);
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
    translate(x, y);
    image(floorSpawnerArt, 0, 0, TILE_WIDTH, TILE_HEIGHT);
    popMatrix();

    if (spawning > 0) {
      // Draw an ora around the spawner
      fill(10, 255, 0, 30);
      circle(x, y, 100);
    }

  }

  public float getZ() {
    return Float.MIN_VALUE + 1;
  }

}


public final class SpawnManager {

  public final int baseEnemies;
  public final float growthFactor;

  private int round;
  private int spawnRemaining;
  private int enemiesRemaining;

  private int lastSpawn;

  // Spawn rate in milliseconds
  private final int spawnRate = 2000;

  private ArrayList<FloorSpawner> spawners;

  boolean newRoundText = false;
  int lastNewRound = 0;

  // milliseconds to show new round text
  int newRoundTextTime = 2000;

  boolean wallBreak = false;

  SpawnManager(int baseEnemies, float growthFactor) {
    this.round = 0;
    this.baseEnemies = baseEnemies;
    this.growthFactor = growthFactor;
    this.spawners = new ArrayList();
    this.spawnRemaining = 0;
    this.enemiesRemaining = 0;
    this.lastSpawn = 0;
  }

  void add(FloorSpawner spawner) {
    this.spawners.add(spawner);
  } 

  void nextRound() {
    this.round++;
    float expGrowth = pow(growthFactor, round);
    float logGrowth = log(round + 1) + 1;
    this.spawnRemaining = (int)(baseEnemies * (expGrowth + logGrowth) / 2);
    this.lastNewRound = millis();
    this.newRoundText = true;
    this.wallBreak = false;
  }

  void endRound() {
    wallBreak = true;
  }

  void update() {

    ArrayList<Blob> deadBlobs = new ArrayList();
    for (Blob blob : blobs) {
      if (blob.dead) {
        deadBlobs.add(blob);
      }
    }
    enemiesRemaining -= deadBlobs.size();
    blobs.removeAll(deadBlobs);

    for (FloorSpawner spawner : spawners) {
      spawner.update();
    }
  
    if (this.spawnRemaining <= 0 && this.enemiesRemaining <= 0) {
      endRound();
    } 


    int now = millis();
  
    if (lastSpawn + spawnRate < now) {
      lastSpawn = now;
      spawn();
    } 

    if (lastNewRound + newRoundTextTime < now) {
      newRoundText = false;
    } 

  } 

  void spawn() {
    if (this.spawners.isEmpty()) {
      return;
    }


    if (this.spawnRemaining > 0) {

      // get the closest region to the player
      PVector pPos = player.position.get();

      FloorSpawner closestSpawner = null;
      float closestDistance = Float.MAX_VALUE;
      for (FloorSpawner spawner : spawners) {
        float d = dist(pPos.x, pPos.y, spawner.x, spawner.y);
        if (d < closestDistance) {
          closestDistance = d;
          closestSpawner = spawner;
        }
      }

      closestSpawner.spawn();

      this.spawnRemaining--;
      this.enemiesRemaining++;
    }

  }

  void kill() {
    this.enemiesRemaining--;
  }

  int getRound() {
    return this.round;
  } 

  int getEnemiesRemaining() {
    return this.enemiesRemaining;
  }

  int getSpawnRemaining() {
    return this.spawnRemaining;
  }

  int getRemaining() {
    return enemiesRemaining + spawnRemaining;
  }
  
}

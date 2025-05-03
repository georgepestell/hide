public final class SpawnManager {

  public final int baseEnemies;
  public final float growthFactor;

  private int round;
  private int spawnRemaining;
  private int enemiesRemaining;

  private int lastSpawn;

  // Spawn rate in milliseconds
  private final int spawnRate = 2000;

  private ArrayList<Spawner> spawners;

  boolean newRoundText = false;
  int lastNewRound = 0;

  // milliseconds to show new round text
  int newRoundTextTime = 2000;

  SpawnManager(int baseEnemies, float growthFactor) {
    this.round = 0;
    this.baseEnemies = baseEnemies;
    this.growthFactor = growthFactor;
    this.spawners = new ArrayList();
    this.spawnRemaining = 0;
    this.enemiesRemaining = 0;
    this.lastSpawn = 0;
  }

  void add(Spawner spawner) {
    this.spawners.add(spawner);
  } 

  void nextRound() {
    this.round++;
    float expGrowth = pow(growthFactor, round);
    float logGrowth = log(round + 1) + 1;
    this.spawnRemaining = (int)(baseEnemies * (expGrowth + logGrowth) / 2);
    this.lastNewRound = millis();
    this.newRoundText = true;
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

    for (Spawner spawner : spawners) {
      spawner.update();
    }
  
    if (this.spawnRemaining <= 0 && this.enemiesRemaining <= 0) {
      nextRound();
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
      int spawner = (int) random(0, spawners.size());
      spawners.get(spawner).spawn();
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

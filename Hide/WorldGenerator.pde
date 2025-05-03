public class WorldGenerator {

  public World generate(int tiles_x, int tiles_y, int tile_w, int tile_h, int numRegions, PVector[] centers, int[][] regions, boolean[][] borders) {

    World world = new World(tiles_x, tiles_y, tile_w, tile_h);

    for (int x = 0; x < tiles_x; x++) {
      for (int y = 0; y < tiles_y; y++) {
        if (borders[y][x]) {
          world.setTile(x, y, new Wall(x * tile_w, y * tile_h, tile_w, tile_h));
        }
      }
    }

    // Add spawners
    for (int i = 0; i < numRegions; i++) {
      PVector t = getTile(centers[i]);
      FloorSpawner spawner = new FloorSpawner((int) t.x * tile_w, (int) t.y * tile_h);
      spawnManager.add(spawner);
      world.setTile((int) t.x, (int) t.y, spawner);
    }

    return world;

  }

}

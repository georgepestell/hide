import java.util.PriorityQueue;
import java.util.HashSet;
import java.util.Set;

public class World {

  public RenderQueue renderQueue;
  public Renderable[][] tiles;

  int tiles_x, tiles_y, tile_w, tile_h;

  int playerTileX;
  int playerTileY;

  boolean[][] tilesBlocked;

  int chunk_w, chunk_h, chunks_x, chunks_y;

  Set<PVector> loadedChunks = new HashSet<PVector>();

  public ArrayList<Wall> walls = new ArrayList<>();

  World(int tiles_x, int tiles_y, int tile_w, int tile_h) {

    renderQueue = new RenderQueue();

    this.tiles_x = tiles_x;
    this.tiles_y = tiles_y;
    this.tile_w = tile_w;
    this.tile_h = tile_h;

    this.tiles = new Renderable[tiles_x][tiles_y];

    // Fill the tiles with floor tiles
    for (int x = 0; x < tiles_x; x++) {
      for (int y = 0; y < tiles_y; y++) {
        // setTile(x, y, new FloorTile(x * tile_w, y * tile_h, tile_w, tile_h));
      }
    }

    chunk_w = (width / 4) / tile_w;
    chunk_h = (height / 4) / tile_h;

    chunks_x = tiles_x / chunk_w;
    chunks_y = tiles_y / chunk_h;

    tilesBlocked = new boolean[tiles_x][tiles_y];

  }

  public void setTile(int tx, int ty, Renderable tile) {

    Renderable oldTile = this.tiles[tx][ty];
    if (oldTile != null) {
      renderQueue.remove(oldTile);
    }

    if (tile != null) {
      boolean isBlocked = tile instanceof Wall;
      tilesBlocked[tx][ty] = isBlocked;
    } else {
      tilesBlocked[tx][ty] = false;
    }

    this.tiles[tx][ty] = tile;
  }

  public void removeTile(int tx, int ty) {
    Renderable oldTile = this.tiles[tx][ty];
    if (oldTile != null) {
      renderQueue.remove(oldTile);
    }
    this.tiles[tx][ty] = null;
    tilesBlocked[tx][ty] = false; 
  }

  public boolean isWall(int x, int y) {
    Renderable t = tiles[x][y];
    return t != null && t instanceof Wall;
  }

  public void update() {
    if (frameCount % 30 == 0) {
      updateRenderable();
    }
  }

  public void updateRenderable() {
   
    // Get the initial render list for the player pos
    float px = constrain(player.position.x, width / 2, MY_WIDTH - width / 2);
    float py = constrain(player.position.y, height / 2, MY_HEIGHT - height / 2);

    PVector pTile = getTile(new PVector(px, py));

    // Get the current x chunk
    int chunk_x = (int) pTile.x / chunk_w;
    int chunk_y = (int) pTile.y / chunk_h;

    int min_chunk_x  = max(chunk_x - 3, 0);
    int max_chunk_x  = max(chunk_x + 2, chunks_x);

    int min_chunk_y  = max(chunk_y - 3, 0);
    int max_chunk_y  = max(chunk_y + 2, chunks_y);

    // Remove unviewed chunks
    ArrayList<PVector> removals = new ArrayList<>();
    for (PVector c : loadedChunks) {
      if (c.x < min_chunk_x || c.x > max_chunk_x || c.y < min_chunk_y || c.y > max_chunk_y) {
        removals.add(c);
      }
    } 
    for (PVector c : removals) {
      unloadChunk(c);
    }

    // Get the chunks involved
    for (int cx = min_chunk_x; cx <= max_chunk_x; cx++) {
      for (int cy = min_chunk_y; cy < max_chunk_y; cy++) {
        PVector c = new PVector(cx, cy);
        loadChunk(c);
      }
    }
  }

  public void unloadChunk(PVector c) {
    
    if (loadedChunks.contains(c)) {
      loadedChunks.remove(c);
      for (int x = (int) c.x * chunk_w; x < min(c.x * chunk_w + chunk_w, tiles_x); x++) {
        for (int y = (int) c.y * chunk_h; y < min(c.y * chunk_h + chunk_h, tiles_y); y++) {
          Renderable t = tiles[x][y];
          if (t != null) {
            renderQueue.remove(t);
          }
        }
      }
    }

  }

  public void loadChunk(PVector c) {
    if (loadedChunks.contains(c)) {
      return;
    }

    loadedChunks.add(c);
    for (int x = (int) c.x * chunk_w; x < min(c.x * chunk_w + chunk_w, tiles_x); x++) {
      for (int y = (int) c.y * chunk_h; y < min(c.y * chunk_h + chunk_h, tiles_y) ; y++) {
        Renderable t = tiles[x][y];
        if (t != null) {
          renderQueue.add(t);
        }
      }
    }

  }

  public ArrayList<Contact> getWallContacts(PhysicsObject o) {
    ArrayList<Contact> contacts = new ArrayList<>();

    PVector pPos = player.getTilePosition();

    for (int x = max((int) pPos.x - 3, 0); x < min((int) pPos.x + 4, tiles_x); x++) {
      for (int y = max((int) pPos.y - 3, 0); y < min((int) pPos.y + 4, tiles_y); y++) {
        // Check if it is a wall
        Renderable tile = tiles[x][y];
        if (tile != null && tile instanceof Wall) {
          Contact c = contactHelper.detectFloorContact(o, (Wall) tile);
          if (c != null) {
            contacts.add(c);
          }
        }
      }
    }

    return contacts;

  }

  public Contact getWallContact(PhysicsObject o) {
    PriorityQueue<Contact> contacts = new PriorityQueue<>(
        (a, b) -> {
      return -Float.compare(a.penDepth, b.penDepth);
    });

    // ArrayList<Contact> contacts = new ArrayList<>();

    PVector pPos = player.getTilePosition();

    PVector normal = new PVector(0, 0);
    for (int x = max((int) pPos.x - 3, 0); x < min((int) pPos.x + 4, tiles_x); x++) {
      for (int y = max((int) pPos.y - 3, 0); y < min((int) pPos.y + 4, tiles_y); y++) {
        // Check if it is a wall
        Renderable tile = tiles[x][y];
        if (tile != null && tile instanceof Wall) {
          Contact c = contactHelper.detectFloorContact(o, (Wall) tile);
          if (c != null) {
            normal.add(c.contactNormal);
            contacts.add(c);
          }
        }
      }
    }

    if (contacts.isEmpty()) {
      return null;
    }

    normal.normalize();

    Contact contact = contacts.peek();
    contact.contactNormal = normal;

    return contact;

  }

  public void display() {
    renderQueue.display();
    fill(255, 0, 0);
    pushMatrix();
      translate(playerTileX * TILE_WIDTH, playerTileY * TILE_HEIGHT);
      circle(0,0,10);
    popMatrix();
  }

}

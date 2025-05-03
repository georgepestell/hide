import java.util.Collections;
import java.util.ArrayDeque;
import java.util.Queue;
import java.util.HashSet;
import java.util.TreeSet;
import java.util.Comparator;


class Node {
  int x; 
  int y;
  Node parent;
  float gCost;
  float hCost;
  boolean walkable;
  float cost;

  Node(int x, int y, boolean walkable, float cost) {
    this.x = x;
    this.y = y;
    this.walkable = walkable;
    this.cost = cost;
  }

  public float getFCost() {
    return gCost + hCost;
  }

  public float getHCost() {
    return hCost;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof Node)) return false;
    Node other = (Node) o;
    return x == other.x && y == other.y;
  }

  @Override
  public int hashCode() {
    return Float.hashCode(x) ^ Float.hashCode(y);
  }

}

public final class PathFinder {

  public float enemyWeight = (TILE_WIDTH + TILE_HEIGHT) / 2 ;

  private float[][] weights = new float[TILES_X][TILES_Y];

  ArrayList<PVector> getTilesInLine(int x1, int y1, int x2, int y2) {

    ArrayList<PVector> tiles = new ArrayList();

    int dy = abs(y2 - y1);
    int dx = abs(x2 - x1);

    int sx = (x1 < x2) ? 1 : -1;
    int sy = (y1 < y2) ? 1 : -1;

    int err = dx - dy;

    while (true) {
      
      tiles.add(new PVector(x1, y1));

      if (x1 == x2 && y1 == y2) {
        break;
      }

      int e2 = 2 * err;

      if (e2 > -dy) {
        err -= dy;
        x1 += sx;
      }
      if (e2 < dx) {
        err += dx;
        y1 += sy;
      }

    }

    // Add end tile
    return tiles;
  } 

  boolean canSee(PhysicsObject o1, PhysicsObject o2, boolean[][] tilesBlocked) {

    PVector o1Tile = o1.getTilePosition();
    PVector o2Tile = o2.getTilePosition();

    ArrayList<PVector> tiles = getTilesInLine((int) o1Tile.x, (int) o1Tile.y, (int) o2Tile.x, (int) o2Tile.y);

    for (PVector tile : tiles) {
      if (tilesBlocked[(int) (tile.x + 0.1)][(int) (tile.y + 0.1)]) {
        return false;
      }
    }  

    return true;
  }

  void setupWeights() {
    for (int x = 0; x < TILES_X; x++) {
      for (int y = 0; y < TILES_Y; y++) {
        this.weights[x][y] = 0;
      }
    }
  }

  void updateEnemyWeights(ArrayList<Blob> blobs) {
    setupWeights();

    for (Blob blob : blobs) {
      PVector bPos = blob.getTilePosition();
      weights[(int) bPos.x][(int) bPos.y] += enemyWeight;
    }
  
  }

Comparator<Node> nodeComparator = 
      Comparator
      .comparingDouble(Node::getFCost).reversed()
      .thenComparingDouble(Node::getHCost).reversed()
      .thenComparingInt(Node::hashCode);

Queue<PVector> generatePath(PVector start, PVector end, boolean[][] tilesBlocked) {
  // Convert PVectors to grid coordinates
  int startX = (int)start.x;
  int startY = (int)start.y;
  int endX = (int)end.x;
  int endY = (int)end.y;

  if (startX == endX && startY == startY) {
    return new ArrayDeque();
  }
  
  // Create grid of Nodes from your boolean array
  Node[][] grid = new Node[tilesBlocked.length][tilesBlocked[0].length];
  for (int x = 0; x < grid.length; x++) {
    for (int y = 0; y < grid[0].length; y++) {
      grid[x][y] = new Node(x, y, !tilesBlocked[x][y], weights[x][y]);
    }
  }
  
  // Initialize open and closed sets
  TreeSet<Node> openSet = new TreeSet<>(nodeComparator);
  HashSet<Node> closedSet = new HashSet<Node>();
  
  Node startNode = grid[startX][startY];
  Node endNode = grid[endX][endY];
  
  openSet.add(startNode);
  
  while (!openSet.isEmpty()) {
    // Get node with lowest fCost
    Node currentNode = openSet.pollFirst();
    
    // Move current node from open to closed
    closedSet.add(currentNode);
    
    // Path found
    if (currentNode == endNode) {
      return retracePath(startNode, endNode);
    }
    
    // Check neighbors
    for (Node neighbor : getNeighbors(grid, currentNode)) {
      if (!neighbor.walkable || closedSet.contains(neighbor)) {
        continue;
      }
      
      float newMovementCost = currentNode.gCost + getDistance(currentNode, neighbor) + currentNode.cost;
      if (newMovementCost < neighbor.gCost || !openSet.contains(neighbor)) {
        neighbor.gCost = newMovementCost;
        neighbor.hCost = getDistance(neighbor, endNode);
        neighbor.parent = currentNode;
        
        if (!openSet.contains(neighbor)) {
          openSet.add(neighbor);
        }
      }
    }
  }
  
  // No path found
  return null;
}

ArrayList<Node> getNeighbors(Node[][] grid, Node node) {
  ArrayList<Node> neighbors = new ArrayList<Node>();
  
  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      // Skip center node and diagonals if you want 4-directional movement
      if (x == 0 && y == 0 || (x != 0 && y != 0)) {
        continue;
      }
      
      int checkX = node.x + x;
      int checkY = node.y + y;
      
      if (checkX >= 0 && checkX < grid.length && 
          checkY >= 0 && checkY < grid[0].length) {
        neighbors.add(grid[checkX][checkY]);
      }
    }
  }
  
  return neighbors;
}

float getDistance(Node a, Node b) {
  // Euclidean distance
  return dist(a.x, a.y, b.x, b.y);
  
  // For Manhattan distance (4-directional movement):
  // return abs(a.x - b.x) + abs(a.y - b.y);
}

Queue<PVector> retracePath(Node startNode, Node endNode) {
  ArrayDeque<PVector> path = new ArrayDeque();
  Node currentNode = endNode;
  
  while (currentNode != startNode) {
    path.addFirst(new PVector(currentNode.x, currentNode.y));
    currentNode = currentNode.parent;
  }
  
  // Reverse to get path from start to end
  return path;
}
}

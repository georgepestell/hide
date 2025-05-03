public static class WorldInfo {
  static int currentId = 0;

  static int getNextId() {
    return currentId++;
  }   
}

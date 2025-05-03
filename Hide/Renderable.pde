public abstract class Renderable {

  int id = WorldInfo.getNextId();

  abstract void display();
  abstract float getZ();
  
  int getId() {
    return this.id;
  }
   

}

import java.util.Iterator;

class ForceRegistry {

  class ForceRegistration {
    public final PhysicsObject object;
    public final ForceGenerator fg;

    ForceRegistration(PhysicsObject object, ForceGenerator fg) {
      this.object = object;
      this.fg = fg;
    }
  }

  ArrayList<ForceRegistration> reg = new ArrayList();

  void add(PhysicsObject object, ForceGenerator fg) {
    this.reg.add(new ForceRegistration(object, fg));
  }

  void clear() {
    this.reg.clear();
  }


  void updateForces() {
    for (ForceRegistration fr : reg) {
      fr.fg.updateForce(fr.object);
    }
  }

}
 

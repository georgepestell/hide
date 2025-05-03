import java.util.Objects;
public class WeaponManager<WeaponType extends Weapon> extends UIElement {

  Wielder wielder;
  WeaponType weapon;

  WeaponManager(Wielder wielder, int w, int h) {
    super();
    this.w = w;
    this.h = h;
    this.wielder = wielder;
    this.weapon = null;
  }

  void attack() {
    if (weapon != null) {
      weapon.attack();
    }
  }

  void integrate() {
    // Update weapon origin and rotation
    if (this.weapon != null && this.wielder != null) {
      this.weapon.origin.set(this.wielder.getWeaponOrigin());

      if (!this.weapon.attacking) {
       this.weapon.rotation = this.wielder.getRotation();
      }
    } 
  }

  void display() {
    stroke(255);
    fill(0);
    rect(x, y, w, h);

    PImage icon = weaponPlaceholderArt;

    if (weapon != null) {
      // Draw weapon icon
      icon = weapon.icon;
    }

    image(icon, x, y, w, h);

  } 

  public void setWeapon(WeaponType weapon) {
    // this.weapon = Objects.requireNotNull(weapon, "Weapon cannot be null");
    this.weapon = weapon;
  }

  public void removeWeapon() {
    this.weapon = null;
  }

  public Contact detectContact(PhysicsObject object) {
    if (weapon == null || object == null || wielder == null) {
      return null;
    } 

    // Check the weapon type
    if (weapon instanceof MeleeWeapon) {
      MeleeWeapon meleeWeapon = (MeleeWeapon) weapon;

      if (!meleeWeapon.attacking) {
        return null;
      }
       


      Contact contact = contactHelper.detectMeleeContact(meleeWeapon, (PhysicsObject) wielder, object);

      if (contact != null) {
        contact.contactNormal.set(-cos(meleeWeapon.rotation), -sin(meleeWeapon.rotation));
        contact.weapon = weapon;
      }


      return contact;
    }

    println("Weapon type not yet implemented");
    return null;

  }
   

}

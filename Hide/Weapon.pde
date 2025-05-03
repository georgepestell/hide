abstract class Weapon extends Renderable { 

  PImage icon;

  PVector origin;
  
  float rotation;
  float knockback;


  boolean attacking = false;
  int lastAttack = Integer.MIN_VALUE;

  // Attack length in milliseconds
  final int attackLength = 100;

  // Attack cooldown in milliseconds
  final int attackCooldown = 500;

  Weapon(PImage icon) {
    this.icon = icon;
    this.origin = new PVector(width / 2 , height / 2);
    this.rotation = 0;
    this.knockback = 10;
  }

  abstract void display();
  abstract void attack();

}

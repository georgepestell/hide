public final class ContactHelper {

  void resolveContacts(ArrayList<Contact> contacts) {
    for (Contact contact : contacts) {
      contact.resolve();
    }
  } 

  Contact detectContactRectangleRectangle(PhysicsObject o1, PhysicsObject o2, ArrayList<PVector> r1, ArrayList<PVector> r2) {

    boolean insideRight = r1.get(1).x >= r2.get(0).x;
    boolean insideLeft = r1.get(0).x <= r2.get(1).x;
    boolean insideBottom = r1.get(2).y >= r2.get(0).y;
    boolean insideTop = r1.get(0).y <= r2.get(2).y;

    // Get contacts for each collision
    if (insideRight && insideLeft && insideBottom && insideTop) {

      float penLeft = r1.get(1).x - r2.get(0).x;
      float penRight = r2.get(1).x - r1.get(0).x;
      float penTop = r1.get(2).y - r2.get(0).y;
      float penBottom = r2.get(2).y - r1.get(0).y;

      float minPen = Math.min(Math.min(penLeft, penRight), Math.min(penTop, penBottom));

      PVector contactNormal = new PVector();

      if (minPen == penLeft) {
        contactNormal.set(-1, 0);
      } else if (minPen == penRight) {
        contactNormal.set(1, 0);
      } else if (minPen == penTop) {
        contactNormal.set(0, -1);
      } else {
        contactNormal.set(0, 1);
      }


      float c = 0.0f;

      return new Contact(o1, o2, c, contactNormal, minPen);


    }
    
    return null;

  }

  boolean pointInEllipse(float eWidth, float eHeight, PVector eOrigin, PVector p) {
    PVector diff = PVector.sub(p, eOrigin);
    diff.x /= (eWidth / 2);
    diff.y /= (eHeight / 2);

    return diff.magSq() <= 1.0f;
    
  }

  Contact detectContactEllipseRectangle(PhysicsObject o1, PhysicsObject o2, float eWidth, float eHeight, PVector eOrigin, ArrayList<PVector> rBBOX) {

    // Check if the bounding box collides
    
    float eMinX = eOrigin.x - eWidth / 2;
    float eMaxX = eOrigin.x + eWidth / 2;
    float eMinY = eOrigin.y - eHeight / 2;
    float eMaxY = eOrigin.y + eHeight / 2;

    ArrayList<PVector> eBBOX = new ArrayList();
    eBBOX.add(new PVector(eMinX, eMinY));
    eBBOX.add(new PVector(eMaxX, eMinY));
    eBBOX.add(new PVector(eMaxX, eMaxY));
    eBBOX.add(new PVector(eMinX, eMaxY));
    
    if (detectContactRectangleRectangle(o1, o2, eBBOX, rBBOX) == null) {
        return null;
    }

    // Check if any of the rectangle vertices are in the ellipse
    boolean vertexInside = false;
    for (PVector p : rBBOX) {
      if (pointInEllipse(eWidth, eHeight, eOrigin, p)) {
        vertexInside = true;
        break;
      } 
    }

    if (vertexInside) {
      PVector diff = PVector.sub(o2.position, o1.position);
      PVector contactNormal = diff.normalize();
      return new Contact(o1, o2, 0, contactNormal, diff.mag());
    }
    
    // Otherwise, we need to check if any of the lines intersect with the ellipse 
    // TODO: ellipse rectangle full contact

    return null;

  }


  Contact detectFloorContact(PhysicsObject o1, PhysicsObject o2) {

    // Get the walking bbox for the player
    ArrayList<PVector> bbox1 = o1.getFloorBoundingBox();

    // Get the bounding box of the object
    ArrayList<PVector> bbox2 = o2.getFloorBoundingBox();

    return detectContactRectangleRectangle(o1, o2, bbox1, bbox2);
  }

  Contact detectFloorContact(PhysicsObject o1, PhysicsObject o2, float c) {
    Contact contact = detectFloorContact(o1, o2);
    if (contact == null) {
      return null;
    }
    contact.c = c;

    return contact;

  }

  Contact detectContact(PhysicsObject o1, PhysicsObject o2) {
    return detectContactRectangleRectangle(o1, o2, o1.getBoundingBox(), o2.getBoundingBox());
  }

  Contact detectMeleeContact(MeleeWeapon weapon, PhysicsObject wielder, PhysicsObject object) {

    // Get the weapon bbox
    ArrayList<PVector> wBBOX = weapon.getBoundingBox(); 
    
    // Get the object bounding box
    ArrayList<PVector> oBBOX = object.getBoundingBox();

    Contact contact = detectContactRectangleRectangle(wielder, object, wBBOX, oBBOX);

    if (contact != null && detectContactEllipseRectangle(wielder, object, weapon.attackRangeWidth, weapon.attackRangeHeight, weapon.origin, oBBOX) != null) {
      return contact;
    } else {
      return null;
    }

  }

}

import java.util.Comparator;
import java.util.Arrays;
import java.util.Set;
import java.util.HashSet;
import java.util.AbstractMap.SimpleEntry;

// Configuration 

final int MY_WIDTH = 800;
final int MY_HEIGHT = 608;

int TILE_WIDTH = 32;
int TILE_HEIGHT = 32;

int TILES_X;
int TILES_Y;

final int NUM_BLOBS = 0;
final int NUM_SPAWNERS = 5;

final int spawnSafetyDistance = 10;

// Assets
PImage playerArt;
PImage rollingArt;
PImage spacekeyArt;
PImage wallArt;
PImage windowArt;
PImage weaponPlaceholderArt;
ArrayList<PImage> grassArt;

SoundFile attackSound;

PGraphics floorTexture;

PFont mainFont;

// UI
UI ui;
WeaponManager weaponManager;

PImage gradient;

// Objects
Player player;
ArrayList<Blob> blobs;
ArrayList<Wall> walls;

boolean[][] tilesBlocked;

MeleeWeapon sword;

// Forces
ForceRegistry fr;
UserInput userInput;
Drag drag;

// Contacts
ContactHelper contactHelper;

// Rendering
RenderQueue renderQueue;

// Spawn manager
SpawnManager spawnManager;

PathFinder pathFinder;

boolean gameover = false;
boolean startNewGame = false;

// SETUP
void setup() {

  // Use the P2D renderer for improved performance
  size(800, 608, P2D);
  ((PGraphicsOpenGL)g).textureSampling(2);
  hint(ENABLE_DEPTH_TEST);

  gameover = false;
  startNewGame = false;

  // Calculate tile width and height
  TILES_X = (int) (MY_WIDTH / TILE_WIDTH);
  TILES_Y = (int) (MY_HEIGHT / TILE_HEIGHT);

  tilesBlocked = new boolean[TILES_X][TILES_Y];

  // Setup render queue ordered in increasing z value
  renderQueue = new RenderQueue();
  fr = new ForceRegistry();

  // Create objects
  player = new Player(width / 2 - TILE_WIDTH / 2, height / 2);
  player.position.y += player.h / 2;
  renderQueue.add(player);


  walls = new ArrayList();

  walls.add(new Wall(0          , 0           , TILES_X , 2)); // TOP WALL
  walls.add(new Wall(0          , TILES_Y - 1 , TILES_X , 1)); // BOTTOM WALL
  walls.add(new Wall(0          , 0           , 1       , TILES_Y)); // LEFT WALL
  walls.add(new Wall(TILES_X - 1, 0           , 1       , TILES_Y)); // RIGHT WALL

  // Set wall blocked
  for (int i = 0; i < TILES_Y; i++) {
    tilesBlocked[0][i] = true;
    tilesBlocked[TILES_X - 1][i] = true;
  } 

  for (int i = 0; i < TILES_X; i++) {
    tilesBlocked[i][0] = true;
    tilesBlocked[i][1] = true;
    tilesBlocked[i][TILES_Y - 1] = true;
  } 

  // Add inner walls
  float innerSize = 0.5;
  float doorSize = 0.3;

  int ulx = (int) ((TILES_X * (1 - innerSize)) / 2);
  int uly = (int) (((TILES_Y - 1) * (1 - innerSize)) / 2) + 1;

  int innerWidth = (int) (TILES_X * innerSize);
  int innerHeight = (int) (TILES_Y * innerSize);
  int innerDoorHeight = (int) (innerHeight * doorSize);

  walls.add(new Wall(ulx, uly, innerWidth, 1));
  walls.add(new Wall(ulx, uly, 1, innerHeight));
  walls.add(new Wall(ulx, uly + innerHeight - 1, innerWidth, 1));
  walls.add(new Wall(ulx + innerWidth - 1, uly, 1, innerDoorHeight));
  walls.add(new Wall(ulx + innerWidth - 1, uly + innerHeight - innerDoorHeight, 1, innerDoorHeight));

  for (int i = ulx; i < ulx + innerWidth; i++) {
    tilesBlocked[i][uly] = true;
    tilesBlocked[i][uly + innerHeight - 1] = true;
  } 

  int doorMin = uly + innerDoorHeight;
  int doorMax = uly + innerHeight - innerDoorHeight;
  for (int i = uly; i < uly + innerHeight; i++) {
    tilesBlocked[ulx][i] = true;

    if (doorMin > i || i >= doorMax) {
      tilesBlocked[ulx + innerWidth - 1][i] = true;
    }
  }


  for (Wall wall : walls) {
    renderQueue.add(wall);
  }
  
  PVector playerTile = player.getTilePosition();
  blobs = new ArrayList();
  for (int i = 0; i < NUM_BLOBS; i++) {
    int x, y;

    PVector distFromPlayer = new PVector(0, 0);
    do {
      x = (int) random(1, TILES_X - 1);
      y = (int) random(2, TILES_Y - 1);

      distFromPlayer = PVector.sub(playerTile, new PVector(x, y));

    } while (tilesBlocked[x][y] || distFromPlayer.mag() < spawnSafetyDistance);

    Blob blob = new Blob(x, y, TILE_WIDTH, TILE_WIDTH);
    renderQueue.add(blob);
    blobs.add(blob);
  }

  spawnManager = new SpawnManager(3, 1.15);

  Set<SimpleEntry<Integer, Integer>> spawnerPos = new HashSet<>();
  for (int i = 0; i < NUM_SPAWNERS; i++) {


    int y;
    int x;
    int offsetX = 0;
    int offsetY = 0;
    boolean valid = true;
    SimpleEntry<Integer, Integer> pos;
    do {
      // Select a random wall 
      int leftRight = (int) random(0, 2);
      int ab = (int) random(0, 2);
      if (leftRight == 1) {
        y = (int) random(0, TILES_Y);
        if (ab == 1) {
          // Left
          x = 0;
        } else {
          // Right
          x = TILES_X - 1;
        }
      } else {
        x = (int) random(0, TILES_X);
        if (ab == 1) {
          // Top
          y = 1;
        } else {
          // Bottom
          y = TILES_Y - 1;
        }
      }

      pos = new SimpleEntry<Integer, Integer>(x, y);
      if (spawnerPos.contains(pos)) { 
          valid = false;
          continue;
      }

      // Check and fetch the valid spawn position around the spawner
      valid = false;
      if (y > 0 && !tilesBlocked[x][y-1]) {
        offsetY = -1;
        valid = true;
        continue;
      }
      if (y < TILES_Y - 1 && !tilesBlocked[x][y+1]) {
        offsetY = 1;
        valid = true;
        continue;
      }
      if (x > 0 && !tilesBlocked[x-1][y]) {
        offsetX = -1;
        valid = true;
        continue;
      }
      if (x < TILES_X - 1 && !tilesBlocked[x+1][y]) {
        offsetX = 1;
        valid = true;
        continue;
      }
      
    } while (!valid);

    spawnerPos.add(pos);

    Spawner spawner = new Spawner(x, y, offsetX, offsetY); // Spawn on the right of tile 1, 3
    spawnManager.add(spawner);
    renderQueue.add(spawner);
  }





  // Create forces
  drag = new Drag(0.1, 0.1);
  userInput = new UserInput(1);

  // Register forces 
  fr.add(player, userInput);
  fr.add(player, drag);

  for (Blob blob : blobs) {
    fr.add(blob, drag);
  }

  // Setup contacts
  contactHelper = new ContactHelper();

  // Setup path finder
  pathFinder = new PathFinder();

  // // Setup interact manager
  // interactManager = new InteractManager();
  // renderQueue.add(interactManager);

  // Load assets
  playerArt = loadImage("assets/spriteSheet.png");
  rollingArt = loadImage("assets/rolling.png");

  grassArt = new ArrayList();
  grassArt.add(loadImage("assets/grass_tile_0.png"));
  grassArt.add(loadImage("assets/grass_tile_1.png"));
  grassArt.add(loadImage("assets/grass_tile_2.png"));
  grassArt.add(loadImage("assets/grass_tile_3.png"));

  spacekeyArt = loadImage("assets/spacebar.png");
  wallArt = loadImage("assets/brick_tile.png");
  windowArt = loadImage("assets/window.png");
  PImage weaponArt = loadImage("assets/sword_wooden.png");
  weaponPlaceholderArt = loadImage("assets/weapon_placeholder.png");
  

  attackSound = new SoundFile(this, "swoosh.wav");

  // Set font
  mainFont = loadFont("AtkinsonHyperlegible-Regular-48.vlw");
  textFont(mainFont); 

  generateFloorTexture();

  ui = new UI(0, 0);
  RollUI rollUI = new RollUI(TILE_WIDTH, TILE_HEIGHT);
  RoundUI roundUI = new RoundUI(2 * TILE_WIDTH, TILE_HEIGHT);
  HealthUI healthUI = new HealthUI(player, 2 * TILE_WIDTH, TILE_HEIGHT);

  weaponManager = new WeaponManager<Weapon>(player, TILE_WIDTH, TILE_HEIGHT);

  ui.add(rollUI);
  ui.add(roundUI);
  ui.add(healthUI);
  ui.add(weaponManager);

  renderQueue.add(ui);

  sword = new MeleeWeapon(weaponArt, attackSound);

  weaponManager.setWeapon(sword);

  // Create gradient image - make it larger than the screen
  float gradientScale = 2.0;
  int gradientWidth = (int)(width * gradientScale);
  int gradientHeight = (int)(height * gradientScale);
  float tightnessFactor = 0.3;
  gradient = createImage(gradientWidth, gradientHeight, ARGB);
  
  // Generate the gradient
  gradient.loadPixels();
  for (int y = 0; y < gradientHeight; y++) {
    for (int x = 0; x < gradientWidth; x++) {
      // Calculate distance from center of gradient image
      float d = dist(gradientWidth/2, gradientHeight/2, x, y);
      // Map to alpha - use radius that covers half the gradient dimension
      int alpha = (int)map(d, 0, min(gradientWidth, gradientHeight)/2 * tightnessFactor, 50, 255);
      alpha = constrain(alpha, 0, 255);
      gradient.pixels[y * gradientWidth + x] = color(0, 0, 0, alpha);
    }
  }
  gradient.updatePixels();
  // printTilesBlocked();
}

void endGame() {
    gameover = true;

    // Draw end screen
    noStroke();
    fill(0, 0, 0, 180);
    rect(0, 0, width, height);

    fill(255);
    textSize(32);
    textAlign(CENTER, CENTER);
    text("     Memento Mori...", width/2, height/2 - 32);
    textSize(24);
    text("Round: " + Integer.toString(spawnManager.getRound()), width/2, height/2);
    text("EXIT\n<ESC>", width/2 - 50, height/2 + 48);
    text("RESTART\n<r>", width/2 + 50, height/2 + 48);

}

void draw() {
  if (gameover) {
    return;
  }

  // interactManager.clearObject();

  background(20);
  strokeWeight(2);

  // UPDATE
  player.update();
  sword.update();

  pathFinder.updateEnemyWeights(blobs);
  for (Blob blob : blobs) {
    blob.update();
    renderQueue.remove(blob);
  }

  spawnManager.update();
  
  renderQueue.remove(player);
  fr.updateForces();

  // Resolve wall contacts
  ArrayList<Contact> playerWallContacts = new ArrayList();
  ArrayList<Contact> blobWallContacts = new ArrayList();
  for (Wall wall : walls) {
    Contact contact = contactHelper.detectFloorContact(player, wall);
    if (contact != null) {
      playerWallContacts.add(contact);
    }
    for (Blob blob : blobs) {
      contact = contactHelper.detectFloorContact(blob, wall, 1.0);
      if (contact != null) {
        blobWallContacts.add(contact);
      }
    }
  }
  contactHelper.resolveContacts(playerWallContacts);
  contactHelper.resolveContacts(blobWallContacts);

  // Blob on blob / player contacts
  ArrayList<Contact> blobBlobContacts = new ArrayList();
  ArrayList<Contact> blobPlayerContacts = new ArrayList();
  ArrayList<Contact> blobWeaponContacts = new ArrayList();
  for (int b = 0; b < blobs.size(); b++) {
    
    // Check contact with weapon
    Contact wContact = null;
    if (weaponManager.weapon != null) {
      wContact = weaponManager.detectContact(blobs.get(b));
    } 

    if (wContact != null) {
      blobWeaponContacts.add(wContact);
    } 

    // Check contact with player
    Contact pContact = contactHelper.detectFloorContact(blobs.get(b), player, 1.0);
    if (pContact != null) {
      blobPlayerContacts.add(pContact);
    }


    // Check contact with other blobs
    for (int b2 = b + 1; b2 < blobs.size(); b2++) {
      Contact contact = contactHelper.detectFloorContact(blobs.get(b), blobs.get(b2), 1.0);
      if (contact != null) {
        blobBlobContacts.add(contact);
      }
    }
  }

  if (blobPlayerContacts.size() != 0) {
    player.damage();
  }

  contactHelper.resolveContacts(blobBlobContacts);

  for (Contact bContact : blobWeaponContacts) {
    if (bContact.weapon != null) {
      bContact.resolveKnockback();
      ((Killable) bContact.o2).damage();
    }
  }


  // INTEGRATE

  // TODO: player.rotate(PI / 360);
  player.integrate();
  weaponManager.integrate();

  for (Blob blob : blobs) {
    blob.integrate();
    renderQueue.add(blob);
  }

  renderQueue.add(player);


  // DRAW
  image(floorTexture, 0, 0);
  
  noTint();

  renderQueue.display();
  sword.display();

  // Draw the vision blocker around the player
  // TODO: Enable vision limiter after dev
  imageMode(CENTER);
  // image(gradient, player.position.x, player.position.y);
  imageMode(CORNER);

  // // Interact
  // interactManager.interact();
  // 
  // interactManager.disable();

  // Check game end conditions
  if (player.getHealth() <= 0) {
    endGame();
    return;
  }

  if (spawnManager.newRoundText) {
    textSize(50);
    noStroke();
    fill(100, 100, 100);
    textAlign(CENTER, CENTER);
    text("Round " + Integer.toString(spawnManager.getRound()), width/2, height/2);
  }
}

void keyPressed() {

  // Player movement
  if (key == 'w') {
    userInput.setMovingUp(true);
  } 
  if (key == 's') {
    userInput.setMovingDown(true);
  }
  if (key == 'a') 
    userInput.setMovingLeft(true);
  if (key == 'd') 
    userInput.setMovingRight(true);

  if (key == 'w' || key == 'a' || key == 's' || key == 'd') {
    userInput.update();
  } 

  if (key == ' ') {
    player.roll();
  }

  if (key == 'k') {
    weaponManager.attack();
  }

}

void keyReleased() {

  // Player movement
  if (key == 'w') {
    userInput.setMovingUp(false);
  } 
  if (key == 's') {
    userInput.setMovingDown(false);
  }
  if (key == 'a') {
    userInput.setMovingLeft(false);
  }
  if( key== 'd') {
    userInput.setMovingRight(false);
  }

  if (key == 'w' || key == 'a' || key == 's' || key == 'd') {
    userInput.update();
  } 
  
  if (key == 'r' && gameover) {
    setup();
  }
}

void printTilesBlocked() {
  println(Arrays.deepToString(tilesBlocked).replace("], ", "]\n").replace("true", "x").replace("false", "o"));
}

void generateFloorTexture() {
  floorTexture = createGraphics(width, height);

  floorTexture.beginDraw();
  floorTexture.background(0);

  for (int x = 0; x < TILES_X; x++) {
    for (int y = 0; y < TILES_Y; y++) {
      float isEmpty = random(0, 1);
      PImage asset;
      if (isEmpty > 0.99) {
        asset = grassArt.get(0);
      } else {
        int idx = (int) random(1, 4);
        asset = grassArt.get(idx);
      }
        floorTexture.image(asset, x * TILE_WIDTH, y * TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT);
    } 
  }
  floorTexture.endDraw();

}

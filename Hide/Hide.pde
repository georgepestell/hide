import java.util.TreeSet;
import java.util.Comparator;
import java.util.Arrays;
import java.util.Set;
import java.util.HashSet;
import java.util.AbstractMap.SimpleEntry;

// Configuration 

final int MY_WIDTH = 3200;
final int MY_HEIGHT = 2432;

int TILE_WIDTH = 32;
int TILE_HEIGHT = 32;

int TILES_X;
int TILES_Y;

PVector camera_pos;

// Assets
PImage playerArt;
PImage rollingArt;
PImage spacekeyArt;
PImage wallArt;
PImage windowArt;
PImage weaponPlaceholderArt;
ArrayList<PImage> grassArt;
PImage floorSpawnerArt;

SoundFile attackSound;

PGraphics floorTexture;
PGraphics voronoiTexture;

PFont mainFont;

World world;

// UI
UI ui;
WeaponManager weaponManager;

PImage gradient;

// Objects
Player player;
ArrayList<Blob> blobs;

MeleeWeapon sword;

// Forces
ForceRegistry fr;
UserInput userInput;
Drag drag;

// Contacts
ContactHelper contactHelper;

// Spawn manager
SpawnManager spawnManager;

PathFinder pathFinder;

boolean gameover = false;
boolean startNewGame = false;

float minCameraX;
float minCameraY;
float maxCameraX;
float maxCameraY;

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

  // Setup ordered in increasing z value
  fr = new ForceRegistry();

  // Create objects
  // player = new Player(MY_WIDTH / 2, MY_HEIGHT / 2);
  player = new Player(width/2, height/2);
  player.position.y += player.h / 2;

  minCameraX = - MY_WIDTH + width;
  minCameraY = - MY_HEIGHT + height;
  maxCameraX = 0;
  maxCameraY = 0;


  float camera_x = constrain(width / 2 - player.position.x, minCameraX, maxCameraX);
  float camera_y = constrain(height / 2 - player.position.y, minCameraY, maxCameraY);
  camera_pos = new PVector(camera_x, camera_y);

  blobs = new ArrayList<>();

  PVector playerTile = player.getTilePosition();

  spawnManager = new SpawnManager(3, 1.15);
  
  // Create forces
  drag = new Drag(0.1, 0.1);
  userInput = new UserInput(1);

  // Register forces 
  fr.add(player, userInput);
  fr.add(player, drag);

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
  floorSpawnerArt = loadImage("assets/grate.png");

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

  final int NUM_REGIONS = 20;
  int[][] regions = new int[TILES_Y][TILES_X];
  boolean[][] borders = new boolean[TILES_Y][TILES_X];
  PVector[] centers = new PVector[NUM_REGIONS];

  Voronoi.generate(this, TILES_X, TILES_Y, TILE_WIDTH, TILE_HEIGHT, NUM_REGIONS, centers, regions, borders);

  // voronoiTexture = Voronoi.generateTexture(this, TILES_X, TILES_Y, TILE_WIDTH, TILE_HEIGHT, NUM_REGIONS, regions, borders);

  WorldGenerator wg = new WorldGenerator();

  world = wg.generate(TILES_X, TILES_Y, TILE_WIDTH, TILE_HEIGHT, NUM_REGIONS, centers, regions, borders);
  world.renderQueue.add(player);

  ui = new UI(0, 0);
  RollUI rollUI = new RollUI(TILE_WIDTH, TILE_HEIGHT);
  RoundUI roundUI = new RoundUI(2 * TILE_WIDTH, TILE_HEIGHT);
  HealthUI healthUI = new HealthUI(player, 2 * TILE_WIDTH, TILE_HEIGHT);

  weaponManager = new WeaponManager<Weapon>(player, TILE_WIDTH, TILE_HEIGHT);

  ui.add(rollUI);
  ui.add(roundUI);
  ui.add(healthUI);
  ui.add(weaponManager);

  // renderQueue.add(ui);

  sword = new MeleeWeapon(weaponArt, attackSound);

  weaponManager.setWeapon(sword);
  world.renderQueue.add(sword);

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
  spawnManager.nextRound();
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
    world.renderQueue.remove(blob);
  }

  spawnManager.update();
  
  world.renderQueue.remove(player);
  fr.updateForces();

  // Resolve wall contacts
  Contact playerWallContact = world.getWallContact(player);
  if (playerWallContact != null) {
    playerWallContact.resolve();
  }

  // Blob on blob / player contacts
  ArrayList<Contact> blobBlobContacts = new ArrayList();
  ArrayList<Contact> blobPlayerContacts = new ArrayList();
  ArrayList<Contact> blobWeaponContacts = new ArrayList();
  ArrayList<Contact> blobWallContacts = new ArrayList();
  for (int b = 0; b < blobs.size(); b++) {
    
    // Get wall contacts
    blobWallContacts.addAll(world.getWallContacts(blobs.get(0)));
    
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
  contactHelper.resolveContacts(blobWallContacts);

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
    world.renderQueue.add(blob);
  }

  world.renderQueue.add(player);


  // DRAW
  float camera_x = constrain(width / 2 - player.position.x, minCameraX, maxCameraX);
  float camera_y = constrain(height / 2 - player.position.y, minCameraY, maxCameraY);
  camera_pos.set(camera_x, camera_y);
  
  image(floorTexture, camera_pos.x, camera_pos.y, MY_WIDTH, MY_HEIGHT);

  world.update();
  world.display();
  ui.display();

  // Display wall break mode
  if (spawnManager.wallBreak) {
     int tileX = constrain((int) ((player.position.x + player.orientation.x * TILE_WIDTH) / TILE_WIDTH), 0, TILES_X - 1);
     int tileY = constrain((int) ((player.position.y + player.orientation.y * TILE_HEIGHT - 1) / TILE_HEIGHT), 0, TILES_Y - 1);
     pushMatrix();
     translate(camera_x, camera_y);
     translate(tileX * TILE_WIDTH, tileY * TILE_HEIGHT);
     fill(50, 50, 200, 90);
     rect(0, 0, TILE_WIDTH, TILE_HEIGHT);
     popMatrix();
  }

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

  if (key == 'x' && spawnManager.wallBreak) {
    // Calculate the wall pointing at if any
     int tileX = constrain((int) ((player.position.x + player.orientation.x * TILE_WIDTH) / TILE_WIDTH), 0, TILES_X - 1);
     int tileY = constrain((int) ((player.position.y + player.orientation.y * TILE_HEIGHT - 1) / TILE_HEIGHT), 0, TILES_Y - 1);
     if (world.isWall(tileX, tileY)) {
       world.removeTile(tileX, tileY);
       spawnManager.nextRound();
     }
  }

}

void printTilesBlocked() {
  println(Arrays.deepToString(world.tilesBlocked).replace("], ", "]\n").replace("true", "x").replace("false", "o"));
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

PVector getTile(PVector p) {
 int tileX = constrain((int) (p.x / TILE_WIDTH), 0, TILES_X - 1);
 int tileY = constrain((int) ((p.y - 1) / TILE_HEIGHT), 0, TILES_Y - 1);
 return new PVector(tileX, tileY);
}

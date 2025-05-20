PImage cowboyImg, enemyImg, bulletImg;

float playerX, playerY;
float speed = 3;

float enemyX, enemyY;
float enemySpeed = 1.5;

ArrayList<Bullet> bullets;

int score = 0;
int lives = 3;
String gameState = "playing";

String lastDirection = "UP";

void setup() {
  size(800, 600);
  imageMode(CENTER);
  
  cowboyImg = loadImage("cowboy.png");
  enemyImg = loadImage("enemy.png");
  bulletImg = loadImage("bullet.png");
  
  playerX = width / 2;
  playerY = height / 2;
  
  enemyX = random(width);
  enemyY = random(height);
  
  bullets = new ArrayList<Bullet>();
}

void draw() {
  background(150, 200, 255);

  if (gameState.equals("gameover")) {
    fill(0);
    textAlign(CENTER);
    textSize(40);
    text("Game Over", width/2, height/2 - 20);
    textSize(20);
    text("Pontuação: " + score, width/2, height/2 + 20);
    return;
  }

  // Player
  image(cowboyImg, playerX, playerY, 64, 64);
  movePlayer();

  // Enemy
  moveEnemy();
  image(enemyImg, enemyX, enemyY, 50, 50);

  // Verifica colisão com jogador
  float distToPlayer = dist(playerX, playerY, enemyX, enemyY);
  if (distToPlayer < 40) {
    lives--;
    if (lives <= 0) {
      gameState = "gameover";
    } else {
      enemyX = random(width);
      enemyY = random(height);
    }
  }

  // Bullets
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    b.update();
    b.display();

    if (b.hits(enemyX, enemyY, 25)) {
      enemyX = random(width);
      enemyY = random(height);
      bullets.remove(i);
      score++;
    } else if (b.offscreen()) {
      bullets.remove(i);
    }
  }

  // HUD
  fill(0);
  textSize(16);
  text("Pontuação: " + score, 10, 20);
  text("Vidas: " + lives, 10, 40);
}

void keyPressed() {
  if (key == ' ') {
    float dx = 0, dy = 0;
    
    // TIRO PARA O LADO CONTRÁRIO DA MOVIMENTAÇÃO
    if (lastDirection.equals("UP"))    { dy = 5; }
    if (lastDirection.equals("DOWN"))  { dy = -5; }
    if (lastDirection.equals("LEFT"))  { dx = 5; }
    if (lastDirection.equals("RIGHT")) { dx = -5; }
    
    bullets.add(new Bullet(playerX, playerY, dx, dy));
  }
}

void movePlayer() {
  if (keyPressed) {
    if (keyCode == UP) {
      playerY -= speed;
      lastDirection = "UP";
    }
    if (keyCode == DOWN) {
      playerY += speed;
      lastDirection = "DOWN";
    }
    if (keyCode == LEFT) {
      playerX -= speed;
      lastDirection = "LEFT";
    }
    if (keyCode == RIGHT) {
      playerX += speed;
      lastDirection = "RIGHT";
    }
  }
}

void moveEnemy() {
  float dx = playerX - enemyX;
  float dy = playerY - enemyY;
  float dist = sqrt(dx*dx + dy*dy);

  if (dist > 0) {
    enemyX += enemySpeed * dx / dist;
    enemyY += enemySpeed * dy / dist;
  }
}

// === CLASSE Bullet ===
class Bullet {
  float x, y;
  float dx, dy;

  Bullet(float x_, float y_, float dx_, float dy_) {
    x = x_;
    y = y_;
    dx = dx_;
    dy = dy_;
  }

  void update() {
    x += dx;
    y += dy;
  }

  void display() {
    if (bulletImg != null) {
      image(bulletImg, x, y, 16, 16);
    } else {
      fill(255, 255, 0);
      noStroke();
      ellipse(x, y, 10, 10);
    }
  }

  boolean offscreen() {
    return x < 0 || x > width || y < 0 || y > height;
  }

  boolean hits(float ex, float ey, float r) {
    float d = dist(x, y, ex, ey);
    return d < r;
  }
}

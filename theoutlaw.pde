import processing.sound.*;

PImage[][] cowboySprites = new PImage[4][4];
PImage[][] enemySprites = new PImage[4][6];

int animationFrame = 0;

SoundFile trilhaSonora;
PImage bulletImg, bgImg, obstacleImg, obstacleDImg;

Cowboy cowboy;
float cowboySpeed = 3;

ArrayList<Enemy> enemies;
int numEnemies = 5;

ArrayList<Bullet> bullets;
ArrayList<Obstaculo> obstaculos;
ArrayList<ObstaculoD> obstaculosD;

int score = 0;
int lives = 3;
String gameState = "menu";

boolean imune = false;
int imuneTimer = 0;
int imuneDuration = 120;

void setup() {
  size(800, 600);
  imageMode(CENTER);

  loadCowboySprites();
  loadEnemySprites();

  bulletImg = loadImage("bullet.png");
  bgImg = loadImage("background.png");
  obstacleImg = loadImage("obstacle.png");
  obstacleDImg = loadImage("obstacleD.png");

  cowboy = new Cowboy(width / 2, height / 2);
  bullets = new ArrayList<Bullet>();
  obstaculos = new ArrayList<Obstaculo>();
  obstaculosD = new ArrayList<ObstaculoD>();

  obstaculos.add(new Obstaculo(300, 150, 32, 64));
  obstaculos.add(new Obstaculo(300, 300, 32, 64));
  obstaculos.add(new Obstaculo(460, 150, 32, 64)); 
  obstaculos.add(new Obstaculo(460, 300, 32, 64));
  obstaculosD.add(new ObstaculoD(300, 400, 64, 32)); 
  obstaculosD.add(new ObstaculoD(424, 400, 64, 32)); 

  enemies = new ArrayList<Enemy>();
  for (int i = 0; i < numEnemies; i++) {
    enemies.add(new Enemy(random(width), random(height), 1.5));
  }
  
  trilhaSonora = new SoundFile(this, "trilha.mp3");
  trilhaSonora.amp(0.3);
  trilhaSonora.loop(); 
}

void draw() {
  background(150, 200, 255);

  if (bgImg != null) {
    image(bgImg, width / 2, height / 2, width, height);
  }

  if (gameState.equals("menu")) {
    fill(255);
    textAlign(CENTER);
    textSize(40);
    text("The Outlaw", width / 2, height / 2 - 40);
    textSize(20);
    text("Pressione ESPAÇO para começar", width / 2, height / 2 + 20);
    return;
  }

  if (gameState.equals("gameover")) {
    fill(255);
    textAlign(CENTER);
    textSize(40);
    text("Game Over", width / 2, height / 2 - 20);
    textSize(20);
    text("Pontuação: " + score, width / 2, height / 2 + 20);
    text("Pressione ESPAÇO para tentar novamente", width / 2, height / 2 + 60);
    return;
  }

  for (Obstaculo o : obstaculos) {
    o.display();
  }
  
  for (ObstaculoD o : obstaculosD) {
    o.display();
  }

  cowboy.update();
  cowboy.display();

  if (imune) {
    imuneTimer++;
    if (imuneTimer >= imuneDuration) {
      imune = false;
      imuneTimer = 0;
    }
  }

  for (int i = enemies.size() - 1; i >= 0; i--) {
    Enemy e = enemies.get(i);
    e.moveTowards(cowboy.x, cowboy.y);
    e.display();

    if (!imune && e.hitsCowboy(cowboy.x, cowboy.y)) {
      lives--;
      imune = true;
      if (lives <= 0) {
        gameState = "gameover";
      }
    }
  }

  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    b.update();
    b.display();

    for (int j = enemies.size() - 1; j >= 0; j--) {
      Enemy e = enemies.get(j);
      if (b.hits(e.x, e.y, 25)) {
        enemies.remove(j);
        bullets.remove(i);
        score++;
        break;
      }
    }

    if (b.offscreen()) {
      bullets.remove(i);
    }
  }

  fill(255);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Pontuação: " + score, 10, 10);

  
  String vidasText = "Vidas: " + lives;
  float vidasTextWidth = textWidth(vidasText);
  text(vidasText, width - vidasTextWidth - 10, 10);

  if (imune) {
    fill(255, 0, 0);
    text("IMUNE!", 10, 60);
  }

  if (enemies.size() == 0) {
    for (int i = 0; i < numEnemies; i++) {
      enemies.add(new Enemy(random(width), random(height), 1.5));
    }
  }

  animationFrame = (frameCount / 10) % 6;
}

void keyPressed() {
  if (key == ' ') {
    if (gameState.equals("menu") || gameState.equals("gameover")) {
      startGame();
    } else if (gameState.equals("playing")) {
      float dirX = cowboy.lastShootDirX;
      float dirY = cowboy.lastShootDirY;
      if (dirX != 0 || dirY != 0) {
        bullets.add(new Bullet(cowboy.x, cowboy.y, dirX * 5, dirY * 5));
      }
    }
  }
}

void startGame() {
  gameState = "playing";
  score = 0;
  lives = 3;
  imune = false;
  imuneTimer = 0;

  cowboy = new Cowboy(width / 2, height / 2);
  bullets.clear();
  enemies.clear();
  for (int i = 0; i < numEnemies; i++) {
    enemies.add(new Enemy(random(width), random(height), 1.5));
  }
}

void loadCowboySprites() {
  String[] directions = {"down", "left", "right", "up"};
  for (int d = 0; d < directions.length; d++) {
    for (int i = 0; i < 4; i++) {
      cowboySprites[d][i] = loadImage(directions[d] + (i + 1) + ".png");
    }
  }
}

void loadEnemySprites() {
  String[] directions = {"Gdown", "Gleft", "Gright", "Gup"};
  for (int d = 0; d < directions.length; d++) {
    for (int i = 0; i < 6; i++) {
      enemySprites[d][i] = loadImage(directions[d] + (i + 1) + ".png");
    }
  }
}

// --------------------------------------- CLASSES ---------------------------------------

class Cowboy {
  float x, y;
  float dirX = 0, dirY = 0;
  int lastDir = 0;

  float lastShootDirX = 0;
  float lastShootDirY = -1;

  Cowboy(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void update() {
    dirX = 0;
    dirY = 0;

    if (keyPressed) {
      if (keyCode == UP) {
        dirY = -1;
        lastDir = 3;
      }
      if (keyCode == DOWN) {
        dirY = 1;
        lastDir = 0;
      }
      if (keyCode == LEFT) {
        dirX = -1;
        lastDir = 1;
      }
      if (keyCode == RIGHT) {
        dirX = 1;
        lastDir = 2;
      }
    }

    if (dirX != 0 || dirY != 0) {
      lastShootDirX = dirX;
      lastShootDirY = dirY;
    }

    float nextX = x + dirX * cowboySpeed;
    float nextY = y + dirY * cowboySpeed;

    boolean colidiu = false;
    for (Obstaculo o : obstaculos) {
      if (o.colide(nextX, nextY, 40)) {
        colidiu = true;
        break;
      }
    } 
    for (ObstaculoD o : obstaculosD) {
      if (o.colide(nextX, nextY, 40)) {
        colidiu = true;
        break;
      }
    }

    if (!colidiu) {
      x = nextX;
      y = nextY;
    }
  }

  void display() {
    PImage sprite = cowboySprites[lastDir][animationFrame % 4];
    if (sprite != null) {
      image(sprite, x, y, 40, 40);
    } else {
      fill(255, 200, 0);
      ellipse(x, y, 40, 40);
    }
  }
}

class Enemy {
  float x, y;
  float speed;
  int lastDir = 0;

  Enemy(float x, float y, float speed) {
    this.x = x;
    this.y = y;
    this.speed = speed;
  }

  void moveTowards(float targetX, float targetY) {
    float dx = targetX - x;
    float dy = targetY - y;
    float angle = atan2(dy, dx);
    
    float nextX = x + cos(angle) * speed;
    float nextY = y + sin(angle) * speed;

    // Verifica colisão com obstaculos no caminho direto
    if (!colisao(nextX, nextY)) {
      // Sem colisão, segue em frente
      x = nextX;
      y = nextY;
    } else {
      // Tentativa de desvio - tenta virar 90 graus para esquerda ou direita
      float angleLeft = angle - HALF_PI;
      float angleRight = angle + HALF_PI;

      float nextLeftX = x + cos(angleLeft) * speed;
      float nextLeftY = y + sin(angleLeft) * speed;

      float nextRightX = x + cos(angleRight) * speed;
      float nextRightY = y + sin(angleRight) * speed;

      if (!colisao(nextLeftX, nextLeftY)) {
        x = nextLeftX;
        y = nextLeftY;
      } else if (!colisao(nextRightX, nextRightY)) {
        x = nextRightX;
        y = nextRightY;
      }
      // Se ambos os lados estiverem bloqueados, inimigo fica parado neste frame
    }

    // Atualiza direção para animação
    if (abs(dx) > abs(dy)) {
      lastDir = (dx > 0) ? 2 : 1;
    } else {
      lastDir = (dy > 0) ? 0 : 3;
    }
  }

  // Função que verifica colisão com todos os obstáculos dado um ponto
  boolean colisao(float testX, float testY) {
    for (Obstaculo o : obstaculos) {
      if (o.colide(testX, testY, 30)) {
        return true;
      }
    }
    for (ObstaculoD o : obstaculosD) {
      if (o.colide(testX, testY, 30)) {
        return true;
      }
    }
    return false;
  }

  void display() {
    PImage sprite = enemySprites[lastDir][animationFrame % 6];
    if (sprite != null) {
      image(sprite, x, y, 30, 30);
    } else {
      fill(255, 0, 0);
      ellipse(x, y, 30, 30);
    }
  }

  boolean hitsCowboy(float cx, float cy) {
    return dist(x, y, cx, cy) < 30;
  }
}

class Bullet {
  float x, y;
  float speedX, speedY;

  Bullet(float x, float y, float speedX, float speedY) {
    this.x = x;
    this.y = y;
    this.speedX = speedX;
    this.speedY = speedY;
  }

  void update() {
    x += speedX;
    y += speedY;
  }

  void display() {
    if (bulletImg != null) {
      image(bulletImg, x, y, 10, 10);
    } else {
      fill(0);
      ellipse(x, y, 10, 10);
    }
  }

  boolean hits(float tx, float ty, float r) {
    return dist(x, y, tx, ty) < r / 2;
  }

  boolean offscreen() {
    return x < 0 || x > width || y < 0 || y > height;
  }
}

class Obstaculo {
  float x, y, w, h;

  Obstaculo(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void display() {
    if (obstacleImg != null) {
      imageMode(CORNER);
      image(obstacleImg, x, y, w, h);
      imageMode(CENTER);
    } else {
      fill(100);
      rect(x, y, w, h);
    }
  }

  boolean colide(float cx, float cy, float cr) {
    return cx + cr / 2 > x && cx - cr / 2 < x + w &&
           cy + cr / 2 > y && cy - cr / 2 < y + h;
  }
}

class ObstaculoD {
  float x, y, w, h;

  ObstaculoD(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void display() {
    if (obstacleDImg != null) {
      imageMode(CORNER);
      image(obstacleDImg, x, y, w, h);
      imageMode(CENTER);
    } else {
      fill(120);
      rect(x, y, w, h);
    }
  }

  boolean colide(float cx, float cy, float cr) {
    return cx + cr / 2 > x && cx - cr / 2 < x + w &&
           cy + cr / 2 > y && cy - cr / 2 < y + h;
  }
}

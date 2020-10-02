final float ballX = 320.0f ;
final float ballY = 400.0f ;
final float ballVX = - 5.0f ;
final float ballVY = - 5.0f ;
final float ballRadius = 10.0f ;

class Ball {
  float x, y ;
  float vx, vy ;
  float r ;

  Ball next ;
  Ball previous ;
  Ball() {
    x = ballX - width ;
    y = ballY ;
    vx = ballVX ;
    vy = ballVY ;
    r = ballRadius ;
    next = previous = this ;
  }

  void move() {
    x += vx ;
    y += vy ;
    if (x < -width && vx < 0 || x > 0 && vx > 0) vx = -vx ;
    if (y < 0 && vy < 0 || y > height && vy > 0) vy = -vy ;
  }

  boolean collisionTo(Block block) {
    if (x + r < block.x || x - r > block.x + block.blockWidth) return false ;
    if (y + r < block.y || y - r > block.y + block.blockHeight) return false ;
    if (x > block.x && x < block.x + block.blockWidth) {
      if (y < block.y + block.blockHeight / 2 && vy < 0) ;
      else if (y >= block.y + block.blockHeight / 2 && vy > 0) ;
      else vy = -vy ;
    }
    if (y > block.y && y < block.y + block.blockHeight) {
      if (x < block.x + block.blockWidth / 2 && vx < 0) ;
      else if (x >= block.x + block.blockWidth / 2 && vx > 0) ;
      else vx = -vx ;
    }
    return true ;
  }

  boolean collisionTo(Region[] bars) {
    for (int i = 0; i < bars.length; i++) {
      if (bars[i] != null) {
        float bx = bars[i].x - bars[i].rectWidth / 2 ;
        float by = bars[i].y - bars[i].rectHeight / 2 ;
        if (x + r < bx || x - r > bx + bars[i].rectWidth) continue ;
        if (y + r < by || y - r > by + bars[i].rectHeight) continue ;
        if (x > bx && x < bx + bars[i].rectWidth) {
          if (y < bars[i].y && vy < 0) continue ;
          if (y >= bars[i].y && vy > 0) continue ;
          vy = -vy ;
        }
        if (y > by && y < by + bars[i].rectHeight) {
          if (x < bars[i].x && vx < 0) continue ;
          if (x >= bars[i].x && vx > 0) continue ;
          vx = -vx ;
        }
        return true ;
      }
    }
    return false ;
  }

  boolean collisionTo(Goal goal) {
    if (x < goal.x - goal.r / 2 || x > goal.x + goal.r / 2) return false ;
    if (y < goal.y - goal.r / 2 || y > goal.y + goal.r / 2) return false ;
    return true ;
  }

  void drawBall() {
    ellipse(x, y, r * 2, r * 2) ;
  }
}

class BallSet {
  int count ;
  Ball head ;
  BallSet(int c) {
    count = 0 ;
    head = new Ball() ;
    for (int i = 0 ; i < c ; i++) {
      add(new Ball()) ;
    }
  }

  void add(Ball b) {
    b.next = head ;
    b.previous = head.previous ;
    head.previous.next = head.previous = b ;
    count++ ;
  }

  void move() {
    Ball b = head.next ;
    while (b != head) {
      b.move() ;
      b = b.next ;
    }
  }

  void collisionTo(BlockSet blocks) {
    Block b = blocks.head.next ;
    while(b != blocks.head) {
      b = b.next ;
      if (collisionTo(b.previous)) {
        blocks.remove(b.previous) ;
      }
    }
  }

  boolean collisionTo(Block block) {
    Ball b = head.next ;
    while (b != head) {
      if (b.collisionTo(block)) return true ;
      b = b.next ;
    }
    return false ;
  }

  void collisionTo(Region[] bars) {
    Ball b = head.next ;
    while (b != head) {
      if (b.collisionTo(bars)) return ;
      b = b.next ;
    }
  }

  boolean collisionTo(Goal goal) {
    Ball b = head.next ;
    while (b != head) {
      if (b.collisionTo(goal)) return true ;
      b = b.next ;
    }
    return false ;
  }

  void drawBallSet() {
    pushStyle() ;
    fill(255, 203, 89) ;
    stroke(255, 203, 89) ;
    Ball b = head.next ;
    while (b != head) {
      b.drawBall() ;
      b = b.next ;
    }
    popStyle() ;
  }
}

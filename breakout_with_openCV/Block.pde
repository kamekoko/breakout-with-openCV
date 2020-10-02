final float BLOCK_WIDTH = 40 ;
final float BLOCK_HEIGHT = 20 ;

final float BLOCK_ROWS = 5 ;
final float BLOCK_GAP = 10 ;

class Block {
  float x ;
  float y ;
  float blockWidth ;
  float blockHeight ;

  boolean isBreakable ;

  Block next ;
  Block previous ;
  Block() {
    next = previous = this ;
  }
  Block(float xx, float yy, float w, float h, boolean b) {
    x = xx - width ;
    y = yy ;
    blockWidth = w ;
    blockHeight = h ;
    isBreakable = b ;
    next = previous = this ;
  }

  void drawBlock() {
    pushStyle() ;
    if (isBreakable) fill(15, 151, 160) ;
    else fill(15, 93, 136) ;
    stroke(15, 93, 136) ;
    rect(x, y, blockWidth, blockHeight) ;
    popStyle() ;
  }
}

class BlockSet {
  int count ;
  Block head ;
  BlockSet(int stageNum) {
    count = 0 ;
    head = new Block() ;

    /*Stage 1*/
    if (stageNum == STAGE_1) {
      for (int i = 0 ; i < 7 ; i++) {
        add(new Block(180.0f + BLOCK_WIDTH * i, 30.0f, BLOCK_WIDTH, BLOCK_HEIGHT, false)) ;
      }
      for (int i = 0 ; i < 7 ; i++) {
        add(new Block(180.0f, 50.0f + BLOCK_WIDTH * i, BLOCK_HEIGHT, BLOCK_WIDTH, false)) ;
        add(new Block(440.0f, 50.0f + BLOCK_WIDTH * i, BLOCK_HEIGHT, BLOCK_WIDTH, false)) ;
      }
      for (int i = 0 ; i < 5 ; i++) {
        add(new Block(200.0f + BLOCK_WIDTH * i, 210.0f, BLOCK_WIDTH, BLOCK_HEIGHT, false)) ;
        add(new Block(400.0f - BLOCK_WIDTH * i, 310.0f, BLOCK_WIDTH, BLOCK_HEIGHT, false)) ;
      }
    }

    /*Stage 2*/
    else if (stageNum == STAGE_2) {
      for (int i = 0 ; i < 7 ; i++) {
        add(new Block(180.0f + BLOCK_WIDTH * i, 30.0f, BLOCK_WIDTH, BLOCK_HEIGHT, false)) ;
      }
      for (int i = 0 ; i < 7 ; i++) {
        add(new Block(180.0f, 50.0f + BLOCK_WIDTH * i, BLOCK_HEIGHT, BLOCK_WIDTH, false)) ;
        add(new Block(440.0f, 50.0f + BLOCK_WIDTH * i, BLOCK_HEIGHT, BLOCK_WIDTH, false)) ;
      }
      for (int i = 0 ; i < 5 ; i++) {
        boolean breakable = (random(1) > 0.5) ? true : false ;
        add(new Block(200.0f + BLOCK_WIDTH * i, 210.0f, BLOCK_WIDTH, BLOCK_HEIGHT, breakable)) ;
        add(new Block(400.0f - BLOCK_WIDTH * i, 310.0f, BLOCK_WIDTH, BLOCK_HEIGHT, breakable)) ;
      }
    }

    else if (stageNum == STAGE_3) {
      for (int h = 0  ; h < 3 ; h++) {
        for (int i = 0 ; i < 16 ; i++) {
          boolean breakable ;
          if (h == 0) {
            breakable = (i > 13) ? true : false ;
            add(new Block(BLOCK_WIDTH * i, 130.0f + 100.0f * h, BLOCK_WIDTH, BLOCK_HEIGHT, breakable)) ;
          }
          else if (h == 1) {
            breakable = (i < 3) ? true : false ;
            add(new Block(BLOCK_WIDTH * i, 130.0f + 100.0f * h, BLOCK_WIDTH, BLOCK_HEIGHT, breakable)) ;
          }
          else {
            breakable = (random(1) > 0.6) ? true : false ;
            add(new Block(BLOCK_WIDTH * i, 130.0f + 100.0f * h, BLOCK_WIDTH, BLOCK_HEIGHT, breakable)) ;
          }
        }
      }
    }
  }

  void add(Block b) {
    b.next = head ;
    b.previous = head.previous ;
    head.previous.next = head.previous = b ;
    count++ ;
  }

  void remove(Block b) {
    if (! b.isBreakable) return ;
    b.previous.next = b.next ;
    b.next.previous = b.previous ;
    b.next = b.previous = b ;
    count-- ;
  }

  void drawBlockSet() {
    Block b = head.next ;
    while(b != head) {
      b.drawBlock() ;
      b = b.next ;
    }
  }
}

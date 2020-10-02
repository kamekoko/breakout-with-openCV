final int MAX_BLOCKS = 10 ;
final int GAME_PLAY = 0 ;
final int GAME_OVER = 1 ;
final int GAME_CLEAR = 2 ;

class Stage {
  BallSet bas ;
  BlockSet bls ;
  Goal goal ;

  int gameStatus ;
  int startTime ;

  Stage(int stageNum) {
    bas = new BallSet(1) ;
    bls = new BlockSet(stageNum) ;
    goal = new Goal(width / 2, 100.0f) ;
    gameStatus = GAME_PLAY ;
    startTime = millis() ;
  }

  boolean isClear() {
    return bas.collisionTo(goal) ;
  }

  void checkCollision(Region[] regionArrayPtr) {
    bas.collisionTo(bls) ;
    bas.collisionTo(regionArrayPtr) ;
  }

  void drawStage(Region[] regionArrayPtr) {
    bas.drawBallSet() ;
    bls.drawBlockSet() ;
    goal.drawGoal() ;

    pushMatrix() ;
    pushStyle() ;
    if (gameStatus == GAME_PLAY) {
      bas.move() ;
      checkCollision(regionArrayPtr) ;
      textSize(50) ;
      fill(0) ;
      int time = GAME_TIME - int((millis() - startTime) / 1000) ;
      scale(-1, 1) ;
      text(time, 20, 50) ;
      if (time < 0) gameStatus = GAME_OVER ;
      if (isClear()) gameStatus = GAME_CLEAR ;
    }
    else if (gameStatus == GAME_CLEAR) {
      textSize(50) ;
      fill(236, 93, 83) ;
      scale(-1, 1) ;
      text("Clear!!!", width / 2, height / 2) ;
    }
    else {
      textSize(50) ;
      fill(236, 93, 83) ;
      scale(-1, 1) ;
      text("Game Over", width / 2, height / 2) ;
    }
    popStyle() ;
    popMatrix() ;
  }
}

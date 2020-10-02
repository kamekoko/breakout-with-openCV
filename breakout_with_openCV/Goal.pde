final float GOAL_RADIAS = 50 ;

class Goal {
  float x ;
  float y ;
  float r ;
  Goal(float xx, float yy) {
    x = xx - width ;
    y = yy ;
    r = GOAL_RADIAS ;
  }

  void drawGoal() {
    pushStyle() ;
    fill(236, 93, 83) ;
    stroke(236, 93, 83) ;
    ellipse(x, y, r, r) ;
    popStyle() ;
  }
}

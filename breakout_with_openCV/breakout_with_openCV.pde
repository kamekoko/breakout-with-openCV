///////////////////////////////////////
/*
you must choose CAMERA_INDEX in file camera.pde
green objects hit the ball
*/
///////////////////////////////////////


import gab.opencv.*;
import processing.video.*;
import spout.* ;

Stage stage ;

final int OPENING = 0 ;
final int STAGE_1 = 1 ;
final int STAGE_2 = 2 ;
final int STAGE_3 = 3 ;
final int GAME_TIME = 30 ;
int status ;
float keyPressedTime ;

void setup() {
  size(640, 480, P3D);
  setCamera() ;
  status = OPENING ;
  keyPressedTime = 0 ;
}

void draw() {

  if (keyPressed) {
    if (keyCode == ENTER) {
      if (millis() - keyPressedTime < 1000) ;
      else {
        if (status == OPENING) {
          status = STAGE_1 ;
          stage = new Stage(STAGE_1) ;
        }
        else if (status == STAGE_1) {
          status = STAGE_2 ;
          stage = new Stage(STAGE_2) ;
        }
        else if (status == STAGE_2) {
          status = STAGE_3 ;
          stage = new Stage(STAGE_3) ;
        }
        else if (status == STAGE_3) {
          status = OPENING ;
        }
        keyPressedTime = millis() ;
      }
    }
  }

  if (status == OPENING) {
    pushStyle() ;
    background(0) ;
    fill(123, 25, 63) ;
    textSize(50) ;
    text("Breakout", width / 2, height / 2) ;
    popStyle() ;
  }
  else {
    drawCV() ;
    stage.drawStage(regionArrayPtr) ;
  }
}

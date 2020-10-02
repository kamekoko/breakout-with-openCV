final int CAMERA_INDEX = 23 ; //choose your camera number

final int HUMAN_COLOR = 50 ;
final int HUE_RANGE = 20 ;

void setCamera() {
  String[] cameraList = Capture.list();
  
   /* カメラリストの表示 */
  for (int i = 0; i < cameraList.length; i++) {
    println(i + ": " + cameraList[i]);
  }

  cv = new OpenCV(this, width, height);
  cv.useColor();

  capture = new Capture(this, cameraList[CAMERA_INDEX]);
  capture.start();

  regionTracker = new RegionTracker();
  regionArrayPtr = regionTracker.getRegionArrayPtr();

  spout = new Spout(this) ;
}

void drawCV() {
  if (capture.available() == true) {
    capture.read();
    cv.loadImage(capture);

    fill(64, 255, 64);
    stroke(64, 255, 64);
    noFill();

    cv.useColor();
    srcRGBImage = cv.getSnapshot();

    cv.useColor(HSB);
    cv.setGray(cv.getH());

    cv.useGray();
    cv.inRange(HUMAN_COLOR, HUMAN_COLOR + HUE_RANGE);

    detectedRegionCount = regionTracker.trackRegion( cv.findContours() );

    scale(-1, 1) ;
    image(srcRGBImage, -width, 0);

    regionTracker.visualizeRegions(regionArrayPtr);

    spout.sendTexture() ;
  }
}

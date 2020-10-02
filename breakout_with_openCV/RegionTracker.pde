Spout spout ;

Capture capture;
OpenCV cv;

PImage srcRGBImage;
PImage grayImage;
PImage binarizedImage;

RegionTracker regionTracker ;
Region[] regionArrayPtr ;
int detectedRegionCount = 0 ;

/* トラッキング関係パラメータ */
final int MAX_REGIONS = 10;                 // 最大検出領域数
final int MAX_SIZE_THRESHOLD = 500000;      // 最大面積
final int MIN_SIZE_THRESHOLD = 10000;       // 最小面積
final int DELETE_WAITING_TIME_MSEC = 100;   // 見つからなくなってから削除するまでの猶予時間(mSec)
final int DISTANCE_THRESHOLD = 30;          // 同一の領域とみなす前のフレームからの重心移動量

final int SAY = 0 ;
final int GOOD = 1 ;
final int QUESTION = 2 ;

import gab.opencv.*;
import java.awt.Rectangle;   // Rectangle型のため

class Region {

  public Region(float x, float y, float size, Rectangle boundingBox) {
    this.x = x - width ;
    this.y = y;
    this.size = size;
    rectX = boundingBox.x - width ;
    rectY = boundingBox.y;
    rectWidth = boundingBox.width;
    rectHeight = boundingBox.height;
  }

  public int id = 0;    // IDは検出した時間で、millis()が返す値が入ります
  public float x, y;    // 領域の重心位置
  public float size;    // 領域のサイズ
  public float rectX, rectY, rectWidth, rectHeight;  // BoundingBox(AABB)
  public int lastUpdatedTime;    // 最後に検出された時間
}

class RegionTracker {

  public Region[] regionArray;
  public int detectedRegionCount = 0;
  public int numRegions;
  public int maxRegions;
  public int maxSizeThreshold;
  public int minSizeThreshold;
  public int distanceThreshold;
  public int deleteWaitingTimeThreshold;

  /* デフォルト値で初期化 */
  public RegionTracker() {
    this.maxRegions = MAX_REGIONS;
    regionArray = new Region[maxRegions];
    numRegions = 0;
    this.maxSizeThreshold = MAX_SIZE_THRESHOLD;
    this.minSizeThreshold = MIN_SIZE_THRESHOLD;
    this.distanceThreshold = DISTANCE_THRESHOLD;
    this.deleteWaitingTimeThreshold = DELETE_WAITING_TIME_MSEC;
  }

  /* パラメータ指定で初期化 */
  public RegionTracker(int maxRegions, int distanceThreshold, int deleteWaitingTimeThreshold,
    int minSizeThreshold, int maxSizeThreshold) {

    this.maxRegions = maxRegions;
    regionArray = new Region[maxRegions];
    numRegions = 0;
    this.maxSizeThreshold = maxSizeThreshold;
    this.minSizeThreshold = minSizeThreshold;
    this.distanceThreshold = distanceThreshold;
    this.deleteWaitingTimeThreshold = deleteWaitingTimeThreshold;
  }

  /* トラッキング結果のRegion配列の場所を返します */
  public Region[] getRegionArrayPtr() {
    return regionArray;
  }

  /* Labeling結果を入れるとトラッキングしてくれます */
  public int trackRegion(ArrayList<Contour> contours) {

    int idCounter = 0;  // millis()でIDを振っているため、同じフレームに複数領域が同時検出された際に同じIDが降られてしまうのでidCounterを足すことでこれを回避する(高fpsでの実行は想定していない)
    float maxSize = 0 ;
    int maxId = 0 ;

    for (int i = 0; i < contours.size(); i++) {

      Contour targetContour = contours.get(i);

      /* 面積で絞る */
      float area = targetContour.area();
      if ( area < minSizeThreshold || area > maxSizeThreshold ) {
        //println("Skipped: " + area);
        continue;
      }

      Rectangle tmpRect = targetContour.getBoundingBox();
      float centroidX = tmpRect.x + tmpRect.width / 2.0f;    // ここ割り切りポイント: 今回の実装では、領域のBoundingBoxの中心をその領域の重心がある位置とみなす
      float centroidY = tmpRect.y + tmpRect.height / 2.0f;

      /* 前フレームまでに登録された腕との対応を調べる */
      boolean flagUpdated = false;
      for (int j = 0; j < maxRegions; j++) {

        if ( regionArray[j] == null ) {
          continue;
        }

        float size = regionArray[j].rectWidth * regionArray[j].rectHeight ;
        if (maxSize < size) {
          maxSize = size ;
          maxId = j ;
        }

        /* 前のフレームで位置が十分近い領域と対応付ける */
        if ( (regionArray[j].x - centroidX) * (regionArray[j].x - centroidX)
          + (regionArray[j].y - centroidY) * (regionArray[j].y - centroidY) < distanceThreshold * distanceThreshold ) {
          regionArray[j].x = centroidX;
          regionArray[j].y = centroidY;
          regionArray[j].rectX = tmpRect.x;
          regionArray[j].rectY = tmpRect.y;
          regionArray[j].rectWidth = tmpRect.width;
          regionArray[j].rectHeight = tmpRect.height;
          regionArray[j].size = area;
          regionArray[j].lastUpdatedTime = millis();
          flagUpdated = true;
          //println("Updated: " + regionArray[j].id);
        }
      }

      /* 新規追加する */
      if ( !flagUpdated ) {
        for (int k = 0; k < maxRegions; k++) {
          if ( regionArray[k] == null ) {
            Region newRegion = new Region(centroidX, centroidY, area, tmpRect);
            regionArray[k] = newRegion;
            regionArray[k].id = regionArray[k].lastUpdatedTime = millis() + idCounter++;
            numRegions++;
            // println("Added: " + regionArray[k].id + " size: " + regionArray[k].size);
            break;
          }
        }
      }
    }

    /* しばらく更新の無いデータを削除する */
    detectedRegionCount = 0;
    for ( int i = 0; i < maxRegions; i++ ) {
      if ( regionArray[i] != null ) {
        detectedRegionCount++;
        if ( regionArray[i].lastUpdatedTime + deleteWaitingTimeThreshold < millis() ) {
          // println("Removed: " + regionArray[i].id);
          regionArray[i] = null;
        }
      }
    }
    return detectedRegionCount;
  }

  public void visualizeRegions(Region[] regionArrayPtr) {
    pushStyle() ;
    for (int i = 0; i < MAX_REGIONS; i++) {
      if (regionArrayPtr[i] != null) {
        ellipse(regionArrayPtr[i].x, regionArrayPtr[i].y, 10, 10);
        rect(regionArrayPtr[i].rectX, regionArrayPtr[i].rectY, regionArrayPtr[i].rectWidth, regionArrayPtr[i].rectHeight);
      }
    }
    popStyle() ;
  }

}

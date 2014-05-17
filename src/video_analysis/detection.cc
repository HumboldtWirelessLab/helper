#include "stdio.h"
#include "opencv2/opencv.hpp"
#include "iostream"
#include "vector"

#define DIRECTION_NONE 0
#define DIRECTION_LEFT -1
#define DIRECTION_RIGHT 1

static const char *dir_string[] = { "left", "none", "right" };

void FindRange(const cv::Mat &binary, int *center, int *size);

int main(int argc, char *argv[]) {

  printf("Press ESC to abort!\n");

  cv::Mat frame;
  cv::Mat back;
  cv::Mat fore;
  cv::Mat binary;
  cv::Mat gray_frame;

  cv::VideoCapture cap;

  if ( argc == 1 ) {
    cap = cv::VideoCapture(0);
  } else {
    cap = cv::VideoCapture(argv[1]);
  }

  double fps = cap.get(CV_CAP_PROP_FPS);
  //printf("FPS: %f\n",fps);
  //cap.set(CV_CAP_PROP_FPS, 1280);

  //cv::BackgroundSubtractorMOG2 bg(10000, 25, false);
  cv::BackgroundSubtractorMOG2 bg(10000, 100, false);
  //cv::BackgroundSubtractorMOG2 bg("nmixtures", 3);

  bg.bShadowDetection = false;

  std::vector<std::vector<cv::Point> > contours;

  cv::namedWindow("Frame");
  cv::namedWindow("Original");

  int center[2];
  int size[2];

  int last_center_x = -1;
  int direction = DIRECTION_NONE;

  int avg = 0;
  int full_dir = DIRECTION_NONE;
  int last_full_dir = DIRECTION_NONE;
  int event_size = 0;

  for(;;) {

    std::vector < std::vector<cv::Point2i > > blobs;

    cap >> frame;

    if (frame.empty()) break;

    cvtColor( frame, gray_frame, CV_RGB2GRAY );

    bg.operator ()(frame,fore);
    //bg.operator ()(gray_frame,fore);
    //bg.getBackgroundImage(back);

    cv::erode(fore,fore,cv::Mat());
    cv::dilate (fore, fore, cv::Mat ());

    cv::findContours (fore, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    //cv::drawContours (frame, contours, -1, cv::Scalar (0, 0, 255), -1);

    cv::threshold(fore, binary, 1, 255, cv::THRESH_BINARY/*_INV*/);

    FindRange(binary,center,size);

    if ( (last_center_x != -1) && (center[0] != -1)) {
      if ( last_center_x > center[0] ) {
        direction = DIRECTION_LEFT;
      } else if ( last_center_x < center[0] ) {
        direction = DIRECTION_RIGHT;
      }
    } else {
      direction = DIRECTION_NONE;
    }

    if ( avg == 0 ) {
      avg = direction * 10;
    } else {
      avg = (9 * avg + direction * 10) / 10;
    }

    full_dir = DIRECTION_NONE;
    if ( avg > 1 ) {
      full_dir = DIRECTION_RIGHT;
      if ( event_size < size[1] ) event_size = size[1];
    }
    if ( avg < -1 ) {
      full_dir = DIRECTION_LEFT;
      if ( event_size < size[1] ) event_size = size[1];
    }

    if ( last_full_dir != full_dir ) {
      //printf("DIR change: %d\n", full_dir);
      if ( full_dir == DIRECTION_NONE ) {
        printf("Detect Object: Direction to %s with size %d\n", dir_string[last_full_dir + 1], event_size);
        event_size = 0;
      }
    }

    last_full_dir = full_dir;

    last_center_x = center[0];

//    if ( direction != 0 )
//      printf("Center: %d %d Size: %d %d Direction: %d\n", center[0], center[1], size[0], size[1], direction);


    cv::imshow("Frame",binary);
    cv::imshow("Original",frame);

    if(cv::waitKey(50) >= 0) break;
  }

  return 0;

}

void FindRange(const cv::Mat &binary, int *center, int *size) {

  //printf("Size: %d %d\n", binary.cols, binary.rows);

  int max_x = 0, min_x = binary.cols, max_y = 0, min_y = binary.rows;

  for(int y=5; y < (binary.rows-5); y++) {
    int *row = (int*)binary.ptr(y);
    for(int x=5; x < (binary.cols-5); x++) {
      if (row[x] == 255) {
        if ( y > max_y ) max_y = y;
        if ( y < min_y ) min_y = y;
        if ( x > max_x ) max_x = x;
        if ( x < min_x ) min_x = x;
      }
    }
  }

  if ( max_x != 0 ) {
    //printf("(%d,%d) -> (%d,%d)\n", min_x, min_y, max_x, max_y);
    center[0] = (min_x + max_x) / 2;
    center[1] = (min_y + max_y) / 2;
    size[0] = (max_x - min_x);
    size[1] = (max_y - min_y);
  } else {
//    printf("-1\n");
    center[0] = -1;
    center[1] = -1;
    size[0] = 0;
    size[1] = 0;
  }
}

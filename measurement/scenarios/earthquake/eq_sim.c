#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

//http://de.wikipedia.org/wiki/Seismische_Welle
//zw: 5000 - 7000 m/s
//use: 6 m/ms
#define PSPEED 6

//zw: 3000 - 4000 m/s
//use: 3.5 m/ms
#define SSPEED 3.5

double sqr(double foo) {
  return foo * foo;
}

int calcTime(int x, int y, double eqx, double eqy, int time, double speed)
{
  double realdist = sqrt(sqr( (double)x - eqx) + sqr( (double)y - eqy));
  
  return ceil(((double)time + ( realdist / (double)speed )));
}

int calcPTime(int x, int y, double eqx, double eqy, int time) {
  return calcTime( x, y, eqx, eqy, time, PSPEED);
}

int calcSTime(int x, int y, double eqx, double eqy, int time) {
  return calcTime( x, y, eqx, eqy, time, SSPEED);
}


int main(int argc, char** argv)
{
  int fs, nc, mind, maxd, etime, dist, angle, i, npl, space;
  int *pos;
  int *nodestime,*nodeptime;
  
  if ( argc < 7 ) {
    printf("Use %s (\"rand\"|\"grid\") nodecount|space fieldsize mindist_earthquake maxdist_earthquake eventtime\n", argv[0]);
    exit(0);
  }
  
  fs = atoi(argv[3]);
  
  if ( strcmp("rand",argv[1]) == 0 ) {
    nc = atoi(argv[2]);
    npl = 0;
    space = 0;
  } else {
    space = atoi(argv[2]);
    npl = ( fs / space ) + 1;
    nc = npl * npl;
  }

  mind = atoi(argv[4]);
  maxd = atoi(argv[5]);
  etime = atoi(argv[6]);
  pos = (int*)malloc(2 * nc * sizeof(int));
  nodeptime = (int*)malloc(nc * sizeof(int));
  nodestime = (int*)malloc(nc * sizeof(int));

  srand(time(0));

  dist = mind + (rand() % (maxd - mind));
  angle = rand() % 360;

  double ang = ((double)angle / 180.0 ) * 3.14159265;
  
  double eqx = ((double)fs/ 2.0 ) + ((double)dist * cos(ang));
  double eqy = ((double)fs/ 2.0 ) - ((double)dist * sin(ang)); //coord-system is backwards in y-direction
  
  printf("Fieldsize: %d Dist: %d Angle: %d X: %f Y: %f\n", fs, dist, angle,eqx,eqy);
  
  for ( i=0; i < nc; i++) {
    if ( strcmp("rand",argv[1]) == 0 ) {
      pos[(2*i)] = rand()%fs;
      pos[(2*i) + 1] = rand()%fs;
    } else {
      pos[(2*i)] = ( i % npl ) * space;
      pos[(2*i) + 1] = ( i / npl ) * space;
    }
    
    nodeptime[i] = calcPTime( pos[(2*i)], pos[(2*i) + 1], eqx, eqy, etime );
    nodestime[i] = calcSTime( pos[(2*i)], pos[(2*i) + 1], eqx, eqy, etime );
    
    printf("X: %d Y: %d PTime: %d STime: %d DTime: %d\n",pos[(2*i)],pos[(2*i) + 1],nodeptime[i],nodestime[i], (nodestime[i]-nodeptime[i]));
  }
  
  
  free(pos);
  free(nodeptime);
  free(nodestime);
  
  return 0;
}

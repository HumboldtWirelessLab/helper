#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <sys/time.h>


//GATEWAY
//
// Server   ->    (CLICK) Gateway (FWD)   ->   (FWD) Forward (FWD)   -> ...
//                                                   ||  (CLICK)
//                                                   \/

#define MODE_UNKNOWN 0
#define MODE_GATEWAY 1
#define MODE_FORWARD 2


int main(int argc,char* argv[])
{
  int click_sd,  fwd_sd;
  
  int click_port, fwd_port, val; 
  struct sockaddr_in fwd_target, click_target, click_local, fwd_local;
  
  struct hostent *click_ip;
  struct hostent *fwd_ip;
  
  struct sockaddr_in receiver_from;
  socklen_t receiver_flen;
  receiver_flen = sizeof(struct sockaddr);


  char buf[2000];
  int rc;

  int mode = MODE_UNKNOWN;

  printf("Start\n");
  
  if ( argc < 6 ) {
    printf("Use %s mode click_port fwd_port click_ip fwd_ip\n",argv[0]);
  } else {
    
    printf("get mode\n");
    if ( strncmp(argv[1], "gw", strlen("gw") ) == 0 ) {
      mode = MODE_GATEWAY;
    } else {
      if ( strncmp(argv[1], "fwd", strlen("fwd") ) == 0 ) {
        mode = MODE_FORWARD;
      }
    }
    
    if ( mode == MODE_UNKNOWN ) {
      printf("Modes: gw|fwd");
      return 0;
    }

    printf("Mode: %d\n",mode);
    
    printf("Setup click\n");
    /* received port */
    printf("Port: %s  IP: %s\n",argv[2],argv[4]);
    click_port = atoi(argv[2]);
    click_ip = gethostbyname(argv[4]);
  
    click_sd = socket (AF_INET,SOCK_DGRAM,0);
    click_local.sin_family = AF_INET;
    
    if ( mode == MODE_FORWARD ) {
      click_local.sin_port = 0;
      click_local.sin_addr.s_addr = inet_addr(argv[4]);
      bcopy ( click_ip->h_addr, &(click_local.sin_addr.s_addr), click_ip->h_length);
    } else {
      click_local.sin_port = htons(click_port);
      click_local.sin_addr.s_addr = inet_addr("0.0.0.0");
    }

 
    val = 1;
    if ( setsockopt(click_sd, SOL_SOCKET, SO_BROADCAST, (char *) &val, sizeof(val)) == -1 ) {
      printf("Failed\n");
    }

    bind(click_sd, (struct sockaddr*)&click_local, sizeof(click_local));

    if ( mode == MODE_FORWARD ) { 
      memset(&click_target, 0, sizeof(struct sockaddr_in));
      click_target.sin_family = AF_INET;
      click_target.sin_addr.s_addr = inet_addr(argv[4]);
      click_target.sin_port = htons(click_port);
    } else {
      //No target for gw
    }
  

    printf("Setup fwd\n");
    /* fwd port */  
    fwd_port = atoi(argv[3]);
    fwd_ip = gethostbyname(argv[5]);
    printf("Port: %s  IP: %s\n",argv[3],argv[5]);

    fwd_sd = socket (AF_INET,SOCK_DGRAM,0);
    fwd_local.sin_family = AF_INET;
    if ( mode == MODE_FORWARD ) {
      fwd_local.sin_port = htons(fwd_port);
      fwd_local.sin_addr.s_addr = inet_addr("0.0.0.0");
  } else {
      fwd_local.sin_port = htons(0);
      fwd_local.sin_addr.s_addr = inet_addr(argv[5]);
      bcopy ( fwd_ip->h_addr, &(fwd_local.sin_addr.s_addr), fwd_ip->h_length);
    }
  
    val = 1;
    setsockopt(fwd_sd, SOL_SOCKET, SO_BROADCAST, (char *) &val, sizeof(val));
  
    bind(fwd_sd, (struct sockaddr*)&fwd_local, sizeof(fwd_local));

    memset(&fwd_target, 0, sizeof(struct sockaddr_in));
    fwd_target.sin_family = AF_INET;
    fwd_target.sin_addr.s_addr = ~0;
    fwd_target.sin_port = htons(fwd_port);

    /* 
     * GATEWAY loop
    */

    int last_rx_id = -1;
    
    for (;;) {
      printf("Start gateway\n");
     
      if ( mode == MODE_FORWARD ) {
        rc = recvfrom(fwd_sd, buf, sizeof(buf), 0,  (struct sockaddr*)&receiver_from, &receiver_flen);
      } else {
        rc = recvfrom(click_sd, buf, sizeof(buf), 0,  (struct sockaddr*)&receiver_from, &receiver_flen);
      }
      
      
      //rc = recv (sd, buf, sizeof(buf), 0);
      buf[rc]= (char)0;
      int *foo = (int*)buf;
      int new_id = ntohl(*foo);
      printf("Received from %s: %d\n",inet_ntoa(receiver_from.sin_addr), new_id);
      
      if ( (last_rx_id == -1) || (new_id > last_rx_id) ) {
        last_rx_id = new_id;
        //printf("Send to %s: %d\n",inet_ntoa(dst_server.sin_addr), ntohl(*foo));
        
        if ( mode == MODE_FORWARD ) {
          sendto(fwd_sd, buf,4, 0, (struct sockaddr*) &fwd_target, sizeof(fwd_target));
          sendto(click_sd, buf,4, 0, (struct sockaddr*) &click_target, sizeof(click_target));
        } else {
          sendto(fwd_sd, buf,4, 0, (struct sockaddr*) &fwd_target, sizeof(fwd_target));
        }
      }

 }



  }
}

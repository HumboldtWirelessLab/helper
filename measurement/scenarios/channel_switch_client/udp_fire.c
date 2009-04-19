#include  <stdio.h>
#include <string.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <sys/time.h>
#include <stdlib.h>
#include <syslog.h>


struct udp_connection {
  int udpsd;
  struct sockaddr_in dst;
  struct sockaddr_in src;
};


struct udp_connection *setupConnection(int16_t localport, char *name, int16_t port) {
  struct udp_connection *udpc;
  struct hostent *hp, *gethostbyname();

  udpc = (struct udp_connection*)malloc(sizeof(struct udp_connection));

  udpc->src.sin_family = AF_INET;
  udpc->src.sin_addr.s_addr = htonl(INADDR_ANY);
  udpc->src.sin_port = htons(localport);

  udpc->udpsd = socket (AF_INET,SOCK_DGRAM,0);

  bind(udpc->udpsd, (struct sockaddr *) &udpc->src, sizeof(udpc->src));

  udpc->dst.sin_family = AF_INET;
  hp = gethostbyname(name);
  bcopy(hp->h_addr, &(udpc->dst.sin_addr.s_addr), hp->h_length);
  udpc->dst.sin_port = htons(port);

  return udpc;
}

void close_udp_connection(struct udp_connection *udpc) {
  close(udpc->udpsd);
}


int sendTo(struct udp_connection *udpc, char* data, int len) {
  sendto(udpc->udpsd, data, len, 0, (struct sockaddr *)&udpc->dst, sizeof(udpc->dst));
  return 0;
}

static int receiveFrom(struct udp_connection *udpc,char* data) {
	struct timeval timer;
	fd_set fds;
	int timeouts = 0;
	int retval;
    int len;

	FD_ZERO(&fds);
	FD_SET(udpc->udpsd,&fds);

	timer.tv_sec = 5;
	timer.tv_usec = 0;

	do {
		timeouts++;
		retval = select(udpc->udpsd + 1,&fds,NULL,NULL,&timer);
	} while((retval <= 0) && (timeouts < 4));

	if ( retval > 0 ) {
		len = read(udpc->udpsd,data,2048);
		if ( len < 0 ) {
			return -1;
		}
	} else {
		return -1;
	}

	return len;
}


#define SOURCE 1
#define DESTINATION 2


int main( int argc, char **argv) {
  struct udp_connection	*con;
  
  char *p = (char*)malloc(sizeof(char) * 2000);
  int *c;
  
  int i;
  int mode = SOURCE;
  
  con =  setupConnection(12000, "192.168.1.1", 12001);

  if ( argc > 1 ) {
    if ( strncmp(argv[1],"d",1) == 0 )
      mode = DESTINATION;
  }
    
  if ( mode == SOURCE ) {
    for(i = 0; i < 10000; i++) {
	c = (int*)p;
 	*c = htonl(i); 
 	
 	sendTo(con,p,1500);
 	
    }
  } else {
  	while ( 1 ) {
      if ( receiveFrom(con,p) >= 0 ) {
        c = (int*)p[2];
        i = ntohl(*c);
        printf("Data: %d\n",i);
      }
    }
  }

  close_udp_connection(con);

}
	

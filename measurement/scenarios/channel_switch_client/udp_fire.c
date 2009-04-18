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


int main( int argc, char **argv) {
  struct udp_connection	*con;
  
  char *p = (char*)malloc(sizeof(char) * 1500);
  int *c;
  
  int i;
  
  con =  setupConnection(12000, "192.168.1.1", 12001);
  
  for(i = 0; i < 10000; i++) {
 	c = (int*)p;
 	*c = htonl(i); 
 	
 	sendTo(con,p,1500);
 	
  }

  close_udp_connection(con);

}
	

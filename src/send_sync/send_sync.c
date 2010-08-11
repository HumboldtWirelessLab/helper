#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <sys/time.h>

int main(int argc,char* argv[])
{
  int sd, port, val, interval, seq, nseq;
  struct sockaddr_in target, local;
  struct hostent *lp/*, *gethostbyname()*/;
  
  if ( argc < 3 ) {
    printf("Use %s port sourceaddress interval\n",argv[0]);
  } else {
    port = atoi(argv[1]);
    lp = gethostbyname(argv[2]);
  
    sd = socket (AF_INET,SOCK_DGRAM,0);
    local.sin_family = AF_INET;
    local.sin_addr.s_addr = htonl(INADDR_ANY);
    bcopy ( lp->h_addr, &(local.sin_addr.s_addr), lp->h_length);
    setsockopt(sd, SOL_SOCKET, SO_BROADCAST, (char *) &val, sizeof(val));
  
    bind(sd, (struct sockaddr*)&local, sizeof(local));

    memset(&target, 0, sizeof(struct sockaddr_in));
    target.sin_family = AF_INET;
    target.sin_addr.s_addr = ~0;
    target.sin_port = htons(port);
  
    interval = atoi(argv[3]);
  
    seq = 0;

    for (;;) {
      nseq = htonl(seq);
      sendto(sd, &nseq, sizeof(nseq), 0, (struct sockaddr*) &target, sizeof(target));
      sleep(interval);
      seq++;
    }
  }
}

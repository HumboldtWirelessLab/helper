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
  int val;
  
  int	sender_sd;
	struct sockaddr_in sender_server, sender_local;;
	struct hostent *sender_hp, *gethostbyname();

  int receiver_sd;
  struct sockaddr_in receiver_server;
  struct sockaddr_in receiver_from;
  socklen_t receiver_flen;
 
	struct	sockaddr_in dst_server;
	struct  hostent *dst_hp, *gethostbyname();
 
  if ( argc < 3 ) {
    printf("Use %s port destinationaddress\n",argv[0]);
  } else {
 
    /*
     *  SENDER part of gateway
     */
    sender_sd = socket (AF_INET,SOCK_DGRAM,0);

    sender_server.sin_family = AF_INET;
    sender_hp = gethostbyname(argv[2]);
    bcopy ( sender_hp->h_addr, &(sender_server.sin_addr.s_addr), sender_hp->h_length);
    setsockopt(sender_sd, SOL_SOCKET, SO_BROADCAST, (char *) &val, sizeof(val));
    
    sender_server.sin_port = htons(atoi(argv[1])+1);

    bind(sender_sd, (struct sockaddr*)&sender_local, sizeof(sender_local));
    /*
     * RECEIVER part of gateway
     */
    
     receiver_flen = sizeof(struct sockaddr);
     char buf[2000];
     int rc;

     receiver_server.sin_family = AF_INET;
     receiver_server.sin_addr.s_addr = htonl(INADDR_ANY);
     receiver_server.sin_port = htons(atoi(argv[1]));

     receiver_sd = socket (AF_INET,SOCK_DGRAM,0);

     setsockopt(receiver_sd, SOL_SOCKET, SO_BROADCAST, (char *) &val, sizeof(val));
     bind ( receiver_sd, (struct sockaddr *) &receiver_server, sizeof(receiver_server));
 
    /*
     * DESTINATION
     */
    
     dst_server.sin_family = AF_INET;
  	 dst_hp = gethostbyname(argv[2]);
	   bcopy ( dst_hp->h_addr, &(dst_server.sin_addr.s_addr), dst_hp->h_length);
	   dst_server.sin_port = htons(atoi(argv[1])+1);
    
    /* 
     * GATEWAY loop
     */
   
    for (;;) {
      rc = recvfrom(receiver_sd, buf, sizeof(buf), 0,  (struct sockaddr*)&receiver_from, &receiver_flen);
        
      //rc = recv (sd, buf, sizeof(buf), 0);
      buf[rc]= (char)0;
      int *foo = (int*)buf;
     // printf("Received from %s: %d\n",inet_ntoa(receiver_from.sin_addr), ntohl(*foo));
      //printf("Send to %s: %d\n",inet_ntoa(dst_server.sin_addr), ntohl(*foo));
      sendto(sender_sd, buf,4, 0, (struct sockaddr*) &dst_server, sizeof(dst_server));
    }
  }
}

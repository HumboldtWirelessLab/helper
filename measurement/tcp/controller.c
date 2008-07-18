#include <pthread.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdio.h>
#include <netdb.h>
#include <unistd.h>
#include <sys/time.h>
#include <stdlib.h>
#include <signal.h>

void sig_handler(int signr)
{
    exit(0);
}

main(int argc,char* argv[])
{
   int   sd;
   struct sockaddr_in server;
   struct sockaddr_in from;
   socklen_t flen;
   
   flen = sizeof(struct sockaddr);
   char buf[2000];
   int rc;

   signal(SIGTERM,sig_handler);

   server.sin_family = AF_INET;
   server.sin_addr.s_addr = htonl(INADDR_ANY);
   server.sin_port = htons(12345);

   sd = socket (AF_INET,SOCK_DGRAM,0);

   bind ( sd, (struct   sockaddr_in *) &server, sizeof(server));
   
   for(;;){
      rc = recvfrom(sd, buf, sizeof(buf), 0,  (struct sockaddr*)&from, &flen);
      
      //rc = recv (sd, buf, sizeof(buf), 0);
      buf[rc]= (char) NULL;
      printf("Received from %s\n",inet_ntoa(from.sin_addr)/*, buf*/);
   }
}

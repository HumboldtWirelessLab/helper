#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <assert.h>
#include <stdio.h>
#include <ctype.h>

#include <algorithm>

#include "csclient.hh"

#include <iostream>

#include <regex.h>
#include "base64.hh"
#include "lzw.hh"

using std::string;
using std::cout;
using std::endl;
using std::cerr;

#define check_init() do { if (!_init) return init_err; } while (false);
#define assert_eq(e, v) do { if ((e) != (v)) { cerr << "got " << (e) << endl; } assert((e) == (v)); } while (false)
#define ok(err) assert_eq(err, ControlSocketClient::no_err)
#define test(x, e) do { err_t err = (x); if (err != (e)) { cerr << "wanted " << assert(0) } while (false)

int
main(int argc, char **argv)
{

  unsigned short port = 7777;
  unsigned long ip;
  if (argc > 1) {
    ip = inet_addr(argv[1]);
    if(ip==INADDR_NONE) {
      struct hostent* he=gethostbyname(argv[1]);
      if(he!=NULL) {
        char newip[16];
        sprintf(newip,"%d.%d.%d.%d",(unsigned char)he->h_addr_list[0][0],(unsigned char)he->h_addr_list[0][1],(unsigned char)he->h_addr_list[0][2],(unsigned char)he->h_addr_list[0][3]);
        ip = inet_addr(newip);
        //printf("Addr: %s\n",newip);
      }
    }
  } else {
    ip = inet_addr("127.0.0.1");
  }

  if (argc > 2)
    port = (unsigned short) atoi(argv[2]);

  typedef ControlSocketClient csc_t;
  csc_t cs;

  typedef csc_t::err_t err_t;
  err_t err = cs.configure(ip, port); 
  if ( err != ControlSocketClient::no_err ) {
    cerr << "No connection\n";
    return 1;
  }

  if ( argc > 5 ) {
    string data = argv[5];

    err = cs.write( argv[3], argv[4], data);
    ok(err);
  } else {
    string data2;
    err = cs.read( argv[3], argv[4], data2);
    ok(err);
    

    char *marker_comdat = strstr((char *)data2.c_str(),"<compressed_data");
    if ( marker_comdat != NULL ) {
    	int res, uncompressed, compressed, base64comp;
    	char err_mesg[256], head[200], buffer[200], *data_enc;

		/* print first symbols */
    	strncpy(head, marker_comdat, 100);
    	head[100] = '\0';
    	printf("Head: %s\n", head);

//    	/* Compile regex */

    	regex_t r1;
    	regmatch_t matchptr[5];
    	regcomp(&r1, "type=\"\\(.*\\)\" uncompressed=\"\\(.*\\)\" compressed=\"\\(.*\\)\"><!\\[CDATA\\[\\(.*\\)\\]\\]", REG_ICASE); //

    	/* Execute regex against string */
    	res=regexec(&r1, marker_comdat, 5, matchptr, 0);
    	if ( !res ) {
			for(int i=1; i<5; i++) {
				if (i<4) {
					//printf("Res%d: %d %d\n", i /*, &marker_comdat[matchptr[i].rm_so]*/, matchptr[i].rm_so, matchptr[i].rm_eo);
					strncpy(buffer, &marker_comdat[matchptr[i].rm_so], matchptr[i].rm_eo-matchptr[i].rm_so);
					buffer[matchptr[i].rm_eo-matchptr[i].rm_so] = '\0';
					//printf("Found: %s\n\n", &buffer);
				}

				if (i==2) uncompressed = atoi(buffer);
				if (i==3) compressed = atoi(buffer);
				if (i==4) {
						base64comp = matchptr[i].rm_eo-matchptr[i].rm_so;
						data_enc = &marker_comdat[matchptr[i].rm_so];
				}


			}

			printf("%d %d %d \n", uncompressed, compressed, base64comp);

			char *data_base64_decoded = (char *)malloc(compressed+10);

			/* Decode Base64 */
			int res = Base64::decode((unsigned char*)data_enc, base64comp, (unsigned char*)data_base64_decoded, compressed+10);
			cout << res;

			/* Uncompress */
			LZW lzw;
			char *data_lzw_compressed = data_base64_decoded;
			char *data_lzw_uncompressed = (char *)malloc(uncompressed);
			lzw.decode((unsigned char*)data_lzw_compressed, compressed, (unsigned char*)data_lzw_uncompressed, uncompressed);

			printf("Result: %s\n", data_lzw_uncompressed);
    	} else {
    		regerror(res, &r1, err_mesg, 256);
    		cout << "Error: " << err_mesg << "\n";
    	}

    	regfree(&r1);
//      char *marker_uncom_s = strstr(data2,"uncompressed=");
//      char *marker_com_s = strstr(data2," compressed=");
//      char *marker_cddat = strstr(data2,"<compressed_data");
    } else {
      cout << data2 /*<< "\n"*/;
    }
  }

  return 0;
}

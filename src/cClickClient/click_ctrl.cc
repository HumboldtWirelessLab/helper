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

  if (argc > 2) port = (unsigned short) atoi(argv[2]);

  ControlSocketClient cs;

  ControlSocketClient::err_t err = cs.configure(ip, port); 

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

    if ( strstr((char *)data2.c_str(),"<compressed_data") != NULL ) {

      char *raw_data = (char *)data2.c_str();
      int res, uncompressed, compressed, base64comp;
      char buffer[151], *data_enc;

      /* Compile regex */

      regex_t r1;
      regmatch_t matchptr[5];
      regcomp(&r1, "type=\"\\(.*\\)\" uncompressed=\"\\(.*\\)\" compressed=\"\\(.*\\)\"><!\\[CDATA\\[\\(.*\\)\\]\\]", REG_ICASE);

      /* Execute regex against string */
      res = regexec(&r1, raw_data, 5, matchptr, 0);

      if ( !res ) {
        for(int i = 1; i < 5; i++) {
          if (i<4) {
            strncpy(buffer, &raw_data[matchptr[i].rm_so], matchptr[i].rm_eo-matchptr[i].rm_so);
            buffer[matchptr[i].rm_eo-matchptr[i].rm_so] = '\0';
          }

          if (i == 2) uncompressed = atoi(buffer);
          if (i == 3) compressed = atoi(buffer);
          if (i == 4) {
            base64comp = matchptr[i].rm_eo-matchptr[i].rm_so;
            data_enc = &(raw_data[matchptr[i].rm_so]);
          }
        }

        unsigned char *data_base64_decoded = (unsigned char *)malloc(compressed+10);

        /* Decode Base64 */
        int res = Base64::decode((unsigned char *)data_enc, base64comp, data_base64_decoded, compressed);

        /* Uncompress */
        LZW lzw;
        unsigned char *data_lzw_uncompressed = (unsigned char *)malloc(uncompressed);
        int size = lzw.decode(data_base64_decoded, compressed, data_lzw_uncompressed, uncompressed);
        data_lzw_uncompressed[size] = '\0';

        data2 = String(data_lzw_uncompressed);

        delete data_base64_decoded;
      }

      regfree(&r1);

    }

    cout << data2 << "\n";

  }

  return 0;
}

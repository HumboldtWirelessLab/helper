#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string>
#include <errno.h>
#include <assert.h>
#include <stdio.h>
#include <ctype.h>

#include <algorithm>

#include "csclient.hh"

#include <iostream>

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
  if (argc > 1)
    ip = inet_addr(argv[1]);
  else
    ip = inet_addr("127.0.0.1");

  if (argc > 2)
    port = (unsigned short) atoi(argv[2]);

  typedef ControlSocketClient csc_t;
  csc_t cs;

  typedef csc_t::err_t err_t;
  err_t err = cs.configure(ip, port); 
  ok(err); 

  
  if ( argc > 5 ) {
    string data = argv[5];

    err = cs.write( argv[3], argv[4], data);
    ok(err);
  } else {
    string data2;
    err = cs.read( argv[3], argv[4], data2);
    ok(err);
    cout << data2 << "\n";
  }

  return 0;
}

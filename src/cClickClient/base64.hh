#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string>
#include <cstring>
#include <errno.h>
#include <assert.h>
#include <stdio.h>
#include <ctype.h>

class Base64
{
 public:

  Base64();
  ~Base64();

  static int encode(unsigned char *input, int inputlen, unsigned char *encoded, int max_encodedlen);
  static int decode(unsigned char *encoded, int encodedlen, unsigned char *decoded, int max_decodedlen);

  static void base64_test();

 private:

  int _debug;
};

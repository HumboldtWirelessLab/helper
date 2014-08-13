/*
 * (c) 2008-2011 Daniel Halperin <dhalperi@cs.washington.edu>
 */
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <linux/socket.h>
#include <linux/netlink.h>
#include <linux/connector.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <netinet/in.h>

#include "iwl_nl.h"
#include "bf_to_eff.h"
#include "util.h"
#include "../../../click-brn/elements/brn/wifi/ap/virtualantenna/csi_protocol.h"
/*
  *
  * linux-80211n-csitool/include/linux/connector.h
  *
    struct cb_id {
      __u32 idx;
      __u32 val;
    };

    struct cn_msg {
      struct cb_id id;

      __u32 seq;
      __u32 ack;

      __u16 len;              // Length of the following data
      __u16 flags;
      __u8 data[0];
  };
*/

#define DEBUG_INFO   1
#define DEBUG_DEV    2


#define DEBUG_LEVEL_INFO (debug_level >= DEBUG_INFO)
#define DEBUG_LEVEL_DEV (debug_level >= DEBUG_DEV)


#define MAX_PAYLOAD 2048
#define BUF_SIZE  4096

#define SLOW_MSG_CNT 1

#define TARGET 1
#define INPUT  0

#define TARGET_STDOUT     0
#define TARGET_FILE       1
#define TARGET_TCP_SOCKET 2
#define TARGET_UDP_SOCKET 3
#define TARGET_UNKNOWN    4

#define OUTPUT_MODE_RAW      0
#define OUTPUT_MODE_FORMAT   1
#define OUTPUT_MODE_BFEE     2
#define OUTPUT_MODE_CLICK    3
#define OUTPUT_MODE_UNKNOWN  4

#define INPUT_SOCKET      0
#define INPUT_FILE        1
#define INPUT_UNKNOWN     2

static char* modes[] = { "s2s", "s2f", "s2t", "s2u", "f2s", "f2f", "f2t", "f2u"};
#define NO_MODES 8

static char* output_types[] = { "stdout", "file", "tcp","udp", "unknown" };
static char* input_types[] = { "socket", "file", "unknown" };

static char* format_types[] = { "raw", "text", "bfee", "click", "unknown" };
#define NO_TYPES 4

int io_type(char c, int type) {
  if ( type == TARGET ) {
    switch(c) {
      case 's': return TARGET_STDOUT;
      case 'f': return TARGET_FILE;
      case 't': return TARGET_TCP_SOCKET;
      case 'u': return TARGET_UDP_SOCKET;
      default: return TARGET_UNKNOWN;
    }
  } else {
    switch(c) {
      case 's': return INPUT_SOCKET;
      case 'f': return INPUT_FILE;
      default: return INPUT_UNKNOWN;
    }
  }
}

int format_type(char c) {
  switch(c) {
    case 'r': return OUTPUT_MODE_RAW;
    case 't': return OUTPUT_MODE_FORMAT;
    case 'b': return OUTPUT_MODE_BFEE;
    case 'c': return OUTPUT_MODE_CLICK;
    default: return TARGET_UNKNOWN;
  }
}

void print_help()
{
  int i;
  printf("Use ./csi_tool mode output input format ap_name client_name debug\n");
  printf("Mode:");
  for ( i = 0; i < NO_MODES; i++) {
    printf("\t%s:\t%s -> %s\n",modes[i],input_types[io_type(modes[i][0],INPUT)], output_types[io_type(modes[i][2],TARGET)]);
  }

  printf("\nOutputformat:\n");
  for ( i = 0; i < NO_TYPES; i++) {
    printf("\t%s\n", format_types[i]);
  }
}

int netlink_sock_fd;      // the socket
int out_fd = -1;          // out_fd

/* UDP/TCP (socket) target */
struct sockaddr_in servaddr;

/* Filter */
  uint8_t filter_code;
  uint16_t filter_rate;
  uint8_t filter_Nrx;

/* Functions */
int click_output(char *buf, struct iwl5000_bfee_notif *bfee, struct cn_msg *cmsg, double eff_snrs[][4],
                 uint32_t csi_node_addr, uint32_t tx_node_addr);

void check_usage(int argc, char** argv);

int open_file(char* filename, char* spec);
int open_udp_socket(char* server, int port);
int open_tcp_socket(char* server, int port);

void caught_signal(int sig);

void exit_program(int code);
void exit_program_err(int code, char* func);

int main(int argc, char** argv)
{
  int target = TARGET_UDP_SOCKET;
  int input = INPUT_FILE;
  int output_mode = OUTPUT_MODE_CLICK;

  filter_code = 0xFF;
  filter_rate = 0xFFFF;
  filter_Nrx = 0xFF;

  char *csi_node = "0.0.0.0";
  char *tx_node = "0.0.0.1";

  int debug_level = 0;

  if ( (argc < 5) || ((argc > 1) && (strcmp(argv[1], "help") == 0)) ) {
    print_help();
    exit(0);
  }

  target = io_type(argv[1][2],TARGET);
  input = io_type(argv[1][0],INPUT);
  output_mode = format_type(argv[4][0]);

  printf("Config: %s (%s -> %s) %s %s %s\n", argv[1], input_types[input], output_types[target],
                                             argv[2], argv[3], format_types[output_mode]);

  if ( argc > 5 ) {
    csi_node = argv[5];
    tx_node = argv[6];
  }

  if ( argc > 7 ) {
    debug_level = atoi(argv[7]);
  }

  struct cn_msg *cmsg;
  unsigned char cmsg_input_buf[BUF_SIZE];

  char sendline[3000];
  unsigned char buf[BUF_SIZE];

  int ret;
  int count = 0;

  char hostname[1024];
  gethostname(hostname, 1024);

  uint32_t csi_node_addr = (uint32_t)inet_addr(csi_node);
  uint32_t tx_node_addr = (uint32_t)inet_addr(tx_node);

  unsigned short l, l2;

  /* Make sure usage is correct */
  check_usage(argc, argv);

  /* Set up the "caught_signal" function as this program's sig handler */
  signal(SIGINT, caught_signal);

  /* Prepare Input */
  switch ( input ) {
    case INPUT_SOCKET:
      netlink_sock_fd = open_iwl_netlink_socket();
      break;
    case INPUT_FILE:
      netlink_sock_fd = open_file(argv[3], "r");
      break;
  }

  /* Prepare Output */
  switch ( target ) {
    case TARGET_TCP_SOCKET:
      out_fd = open_tcp_socket(argv[2], 32000);
      break;
    case TARGET_UDP_SOCKET:
      out_fd = open_udp_socket(argv[2], 32000);
      break;
    case TARGET_FILE:
      out_fd = open_file(argv[2], "w");
      break;
    case TARGET_STDOUT:
      out_fd = 1;
      break;
  }

  /* Poll socket forever waiting for a message */
  u_char *buf_p;
  int len_p, len_sendline;

  while (1) {
    /* Receive from socket with infinite timeout */
    //ret = recv(sock_fd, buf, sizeof(buf), 0);

    /* Read the next entry size */

    if (DEBUG_LEVEL_DEV) {
      printf("\n----- Next Data -----\n\n");
    }

    switch (input) {
      case INPUT_FILE:
        /* Read the next entry size */
        ret = read(netlink_sock_fd, &l2, 1 * sizeof(unsigned short));

        if ( ret != 0 ) {
          l = ntohs(l2);
          /* Sanity-check the entry size */

          if (l == 0) {
            fprintf(stderr, "Error: got entry size=0\n");
            exit_program(-1);
          } else if (l > BUF_SIZE) {
            fprintf(stderr, "Error: got entry size %u > BUF_SIZE=%u\n", l, BUF_SIZE);
            exit_program(-2);
          }

          /* Read in the entry */
          read(netlink_sock_fd, buf, l * sizeof(*buf));

          cmsg = (struct cn_msg*)&cmsg_input_buf[0];
          cmsg->id.idx = 0;
          cmsg->id.val = 0;
          cmsg->seq = 0;
          cmsg->ack = 0;
          cmsg->len = l;
          cmsg->flags = 0;
          memcpy(cmsg->data,buf,l);

        }
        if ( ret == 0 ) ret = -1;
        break;
      case INPUT_SOCKET:
        ret = iwl_netlink_recv(netlink_sock_fd, &buf_p, &len_p, &cmsg);
        break;
    }

    if (ret == -1) exit_program_err(-1, "recv");

    if (cmsg == NULL) {
      printf("cmsg == NULL\n");
      continue;
    }
    struct iwl5000_bfee_notif *bfee = NULL;
    bfee = (struct iwl5000_bfee_notif *)&(cmsg->data[1]);

    /* Filter */
    if ( (filter_code != 0xFF) && (cmsg->data[0] != filter_code) ) continue;
    if ( (filter_rate != 0xFFFF) && (bfee->fake_rate_n_flags != filter_rate) ) continue;
    if ( (filter_Nrx != 0xFF) && (bfee->Nrx != filter_Nrx) ) continue;

     if (DEBUG_LEVEL_DEV) printf("Entry size=%d, code=0x%X\n", cmsg->len, cmsg->data[0]);

    /* Evaluation */
    double eff_snrs[MAX_NUM_RATES][4];

    if ( cmsg->data[0] == IWL_CONN_BFEE_NOTIF /*0xBB*/) { /* Beamforming packet */

      calc_eff_snrs(bfee, eff_snrs);

      struct timeval timeVal;
      gettimeofday (&timeVal, NULL);

      if (DEBUG_LEVEL_INFO) printf("Rcvd pkt at <%ld.%06ld>\n", (long int)(timeVal.tv_sec), (long int)(timeVal.tv_usec));

      if (DEBUG_LEVEL_DEV) {
        /* Beamforming packet */
        printf("\nBeamforming: rate=0x%x\n", bfee->fake_rate_n_flags);
        /* Pull out the message portion and print some stats */
        if (count % SLOW_MSG_CNT == 0)
          printf("Received %d bytes: id: %d val: %d seq: %d clen: %d\n", cmsg->len, cmsg->id.idx, cmsg->id.val, cmsg->seq, cmsg->len);

        printf("\n--- Effektive SNR ---\n\n");
        int i;
        for ( i = 0; i < MAX_NUM_RATES; i++) {
          printf("%d: %f %f %f %f\n", i, db(eff_snrs[i][0]), db(eff_snrs[i][1]), db(eff_snrs[i][2]), db(eff_snrs[i][3]));
        }
        printf("\n---------------------\n\n");
      }
    }

    /* Log the data remote */
    /* Puffer mit Text füllen */
    switch (output_mode) {
      case OUTPUT_MODE_FORMAT:
        sprintf(sendline, "%s, Received %d bytes: id: %d val: %d seq: %d clen: %d\n", hostname, cmsg->len, cmsg->id.idx,
                                                                                      cmsg->id.val, cmsg->seq, cmsg->len);
        len_sendline = strlen(sendline);
        break;
      case OUTPUT_MODE_BFEE:
        if ( bfee != NULL) {
          calc_eff_snrs_tostr(bfee, eff_snrs, sendline, hostname);
        } else {
          sprintf(sendline, "bfee == NULL\n");
        }

        if (DEBUG_LEVEL_DEV) printf("To tx:\n%s\n", sendline);
        break;
      case OUTPUT_MODE_CLICK:
        len_sendline = click_output(sendline, bfee, cmsg, eff_snrs, csi_node_addr, tx_node_addr);
        break;
      default:
        /* Log the data to file */
        l = (unsigned short) cmsg->len;
        l2 = htons(l);
        memcpy(sendline, &l2, 1 * sizeof(unsigned short));
        len_sendline = 1 * sizeof(unsigned short);

        memcpy(&(sendline[len_sendline]), cmsg->data, 1 * l);
        len_sendline += 1 * l;

        if ((count % 100 == 0) && (DEBUG_LEVEL_DEV)) printf("wrote %d bytes [msgcnt=%u]\n", len_sendline, count);
    }

    switch ( target ) {
      case TARGET_FILE:
      case TARGET_TCP_SOCKET:
        ret = write(out_fd, sendline, len_sendline);
        break;
      case TARGET_UDP_SOCKET:
        sendto(out_fd, sendline, len_sendline, 0, (struct sockaddr *)&servaddr, sizeof(servaddr));
        break;
      case TARGET_STDOUT:
        dprintf(out_fd,"%s",sendline);
        break;
    }

    ++count;
  }

  exit_program(0);
  return 0;
}

int click_output(char *buf, struct iwl5000_bfee_notif *bfee, struct cn_msg *cmsg, double eff_snrs[][4], 
                 uint32_t csi_node_addr, uint32_t tx_node_addr)
{
  struct csi_packet *csi_p = (struct csi_packet *)buf;

  struct csi_header *csi_header = &(csi_p->header);
  struct csi_node   *csi_node = &(csi_p->node);
  struct csi_iwl5000_bfee_notif *csi_bfee = &(csi_p->bfee);
  struct csi_cn_msg             *csi_cn_msg = &(csi_p->cn_msg);

  csi_header->flags = 0;
  csi_header->bfee_payload_size = 0;
  csi_header->eff_snr_size = 0;

  csi_node->csi_node_addr = csi_node_addr;
  csi_node->tx_node_addr = tx_node_addr;
  csi_node->id = 0;

  memcpy(csi_bfee, bfee, sizeof(struct csi_iwl5000_bfee_notif));

  csi_cn_msg->id_idx = cmsg->id.idx;
  csi_cn_msg->id_val = cmsg->id.val;

  csi_cn_msg->seq = cmsg->seq;
  csi_cn_msg->ack = cmsg->ack;

  csi_cn_msg->len = cmsg->len;
  csi_cn_msg->flags = cmsg->flags;

  int i;
  for ( i = 0; i < MAX_NUM_RATES; i++) {
    csi_p->eff_snrs_int[i][0] = round(1000.0 * db(eff_snrs[i][0]));
    csi_p->eff_snrs_int[i][1] = round(1000.0 * db(eff_snrs[i][1]));
    csi_p->eff_snrs_int[i][2] = round(1000.0 * db(eff_snrs[i][2]));
    csi_p->eff_snrs_int[i][3] = round(1000.0 * db(eff_snrs[i][3]));
  }

  return sizeof(struct csi_packet);
}

void check_usage(int argc, char** argv)
{
	if (argc < 4)
	{
		fprintf(stderr, "Usage: log_to_file mode dst src\n");
		exit_program(1);
	}
}

int open_file(char* filename, char* spec)
{
  FILE* fp = fopen(filename, spec);
  if (!fp) {
    perror("fopen");
    exit_program(1);
  }

  return fileno(fp);
}

int open_tcp_socket(char* server, int port)
{
  /* create TCP/IP socket */
  /* Socket erstellen */
  int sock_fd2 = socket(AF_INET, SOCK_STREAM, 0);

  if (sock_fd2 == -1) exit_program_err(-1, "failed to TCP socket");

  bzero(&servaddr,sizeof(servaddr));
  servaddr.sin_family = AF_INET;
  servaddr.sin_addr.s_addr=inet_addr(server);
  servaddr.sin_port=htons(port);

  connect(sock_fd2, (struct sockaddr *)&servaddr, sizeof(servaddr));

  return sock_fd2;
}

int open_udp_socket(char* server, int port)
{
  int sd = socket (AF_INET,SOCK_DGRAM,0);

  bzero(&servaddr,sizeof(servaddr));
  servaddr.sin_family = AF_INET;
  servaddr.sin_addr.s_addr=inet_addr(server);
  servaddr.sin_port = htons(port);

  return sd;
}

void caught_signal(int sig)
{
  fprintf(stderr, "Caught signal %d\n", sig);
  exit_program(0);
}

void exit_program(int code)
{
  if (out_fd != -1) {
    close(out_fd);
    out_fd = -1;
  }

  if (netlink_sock_fd != -1) {
    close(netlink_sock_fd);
    netlink_sock_fd = -1;
  }
  exit(code);
}

void exit_program_err(int code, char* func)
{
  perror(func);
  exit_program(code);
}

#ifdef USERLEVEL

#ifdef CONTROLSOCKET

#ifndef CONTROLSOCKETPORT
#define CONTROLSOCKETPORT 7777
#endif

ControlSocket(tcp, CONTROLSOCKETPORT);
#endif

#endif

#ifndef TIME
#define TIME 60
#endif

#if TIME > 0
Script(wait TIME, stop);
#endif

#ifdef NODEID_NAME
//#warning Deprecated: Please use NAME in Nodeidentity.
Script( write id.nodename NODENAME );
#endif

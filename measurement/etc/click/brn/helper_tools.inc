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

#ifndef SIMULATION
Script(wait TIME, stop);
//#else
//Script(wait TIME.001, stop);
#endif

#endif

#ifdef NODEID_NAME
Script( write id.nodename NODENAME );
#endif


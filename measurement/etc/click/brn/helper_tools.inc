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
#ifdef LOGMARKEND
Script(wait TIME, print "MEASUREMENT FINISHED", stop);
#else
Script(wait TIME, stop);
#endif
#endif

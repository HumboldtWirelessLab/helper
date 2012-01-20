#ifdef USERLEVEL

#ifdef CONTROLSOCKET

#ifndef CONTROLSOCKETPORT
#define CONTROLSOCKETPORT 7777
#endif

ControlSocket(tcp, CONTROLSOCKETPORT);
#endif

#endif

#ifdef SIMULATION
#ifdef GUICONNECTOR
gc::GuiConnector(ADDR 127.0.0.1, PORT 2000);
#endif
#endif

#ifndef TIME
#define TIME 60
#endif

#if TIME > 0
Script(wait TIME,
#ifdef GUICONNECTOR
       write gc.finish 1,
#endif
#ifdef LOGMARKEND
       print "MEASUREMENT FINISHED",
#endif
       stop);

#endif

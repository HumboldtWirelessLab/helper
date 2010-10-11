// Basic class definitions for access to USB HID devices
//
// (C) 2001 Copyright Cleware GmbH
// All rights reserved
//
// History:
// 05.01.01	ws	Initial coding
// 17.07.01	ws	cleanup interface
// 03.11.02	ws	small changes for Linux


#ifndef __USBACCESSBASIC_H__
#define __USBACCESSBASIC_H__

#define INVALID_HANDLE_VALUE -1



enum cwUSBtype_enum {	ILLEGAL_DEVICE=0,
						LED_DEVICE=0x01,
						WATCHDOG_DEVICE=0x05,
						AUTORESET_DEVICE=0x06,
						SWITCH1_DEVICE=0x08,
						TEMPERATURE_DEVICE=0x10,
						TEMPERATURE2_DEVICE=0x11,
						TEMPERATURE5_DEVICE=0x15, 
						HUMIDITY1_DEVICE=0x20,
						CONTACT1_DEVICE=0x30 
						} ;

typedef struct {
	unsigned long int	handle ;
	int					gadgetVersionNo ;
	enum cwUSBtype_enum	gadgettype ;
	int					SerialNumber ;
	int					report_type ;
	} cwSUSBdata ;

void cwInitCleware() ;
int	cwOpenCleware(char *path) ;	// returns number of found Cleware devices
int cwRecover(char *path, int deviceNo) ;
void cwCloseCleware() ;
int	cwGetValue(int deviceNo, int UsagePage, int Usage, unsigned char *buf, int bufsize) ;
int	cwSetValue(int deviceNo, int UsagePage, int Usage, unsigned char *buf, int bufsize) ;
unsigned long int cwGetHandle(int deviceNo) ;
int	cwGetVersion(int deviceNo) ;
int	cwGetSerialNumber(int deviceNo) ;
enum cwUSBtype_enum	cwGetUSBType(int deviceNo) ;

#endif // __USBACCESS_H__

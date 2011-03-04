#!/usr/bin/perl

use LEGO::RCX;
use Time::HiRes qw(usleep nanosleep);

my $go_sleep = 100000;

#print 
if ( $#ARGV == 0 ) {
  $go_sleep = $ARGV[0];
}

my $rcx = new LEGO::RCX();

usleep(100000);
$rcx->beep( "Double Beep" );
usleep(100000);
$rcx->motorDir( "A", "backward" );
usleep(100000);
$rcx->motorPower( "A", 7 );
usleep(100000);
$rcx->motorOn( "A" );
usleep($go_sleep);
$rcx->motorOff( "A" );
usleep(100000);
$rcx->beep( "Double Beep" );


#!/usr/bin/perl

use LEGO::RCX;
use Time::HiRes qw(usleep nanosleep);

my $rcx = new LEGO::RCX();

print "Motor Should be going forward\n";
$rcx->beep( "Double Beep" );
sleep 1;
$rcx->motorDir( "A", "forward" );
#$rcx->motorDir( "A", "toggle" );
sleep 1;
$rcx->motorPower( "A", 7 );
sleep 1;
for( my $x = 0; $x < 20; $x ++ ) {
$rcx->motorOn( "A" );
usleep(100000);
#sleep 1;
$rcx->motorOff( "A" );
usleep(1000000);
}
sleep 1;
$rcx->beep( "Double Beep" );
sleep 1;

print "The End\n";


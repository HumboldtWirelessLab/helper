#!/usr/bin/perl

use LEGO::RCX;

my $rcx = new LEGO::RCX();

my $no_beep = 0;
$rcx->beep($no_beep);
sleep 1;

if ( $#ARGV == 0 ) {
  $no_beep = $ARGV[0];
}
    
$rcx->beep($no_beep);
sleep 1;

#!/usr/bin/perl

use LEGO::RCX;

my $rcx = new LEGO::RCX();

sleep 1;
my $bat = $rcx->getBattery();
sleep 1;

print $bat;
print $rcx->getBattery();

print "\n";

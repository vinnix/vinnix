#!/bin/env perl

use threads ();
use threads::shared ();

my $scalar : shared = 0;
my @thread;

push( @thread, threads->new( sub {
    for (1..100000)
    {
	$scalar++ ;
    }
} ) ) for 1..10;

$_->join foreach @thread; # wait for all threads to finish
print "scalar = $scalar\n";

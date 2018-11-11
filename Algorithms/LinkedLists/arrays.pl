#!/bin/env perl
#
#
#
#



use List::Util qw( first );


# Declaring variables for the experiment
my @list = ("Col1","Col2","Col3");
my $item_to_search = "Col1";



$found = defined( first { $_ eq $item_to_search } @list );


print "Found is $found\n";

#!/bin/env perl
#
#
#
#


use strict;

chomp(my $str = <>);

if ( $str eq reverse($str) ) 
{
     print "Checked, $str is a Palindrome!\n";
}
else 
{
     print "Ohh gosh, not a Palindrome!\n";
}

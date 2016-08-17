#!/bin/env perl
#
#
#
#
#
#
#
#



use strict;
use warnings;


chomp(my $word = <>);


my @chars = split //, $word;
my $palindrome = 1;
for (0..@chars/2-1) {
   $palindrome = $chars[$_] eq $chars[-($_+1)]
      or last;
}

print "$word ".($palindrome ? "is" : "isn't")." a palindrome\n";

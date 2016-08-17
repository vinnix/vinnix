#!/bin/env perl
#
#
#
#
#


my $n = 5;
my $result_to_print = 0;


## I have no problem with a helper function having more arguments.
sub fact {
   my ($n) = @_;

   local *_fact = sub {
       my ($n, $prod) = @_;
       return $prod if $n == 0;
       return _fact($n-1, $n*$prod);
   };

   return _fact($n, 1);
}

$result_to_print  = fact($n);
print "Resultado $result_to_print \n";

##In this case, you could even fake it as follows:
sub fact {
   my ($n, $prod) = @_;
   $prod ||= 1;
   return $prod if $n == 0;
   return _fact($n-1, $n*$prod);
}

$result_to_print  = fact($n);
print "Resultado $result_to_print \n";


## But since Perl doesn't do tail recursion optimisation, and since sub calls are relatively slow, you're better off with:
sub fact {
   my ($n) = @_;
   my $prod = 1;
   $prod *= $n-- while $n > 0;
   return $prod;
}

$result_to_print  = fact($n);
print "Resultado $result_to_print \n";

#!/bin/env perl
#
#
#
#
#




# We want to do something like:  echo 55 |  ./factorial_perl.pl
chomp(my $n = <STDIN>);;
my $result_to_print = 0;


## I have no problem with a helper function having more arguments.
sub fact1 {
   my ($n) = @_;

   local *_fact1 = sub {
       my ($n, $prod) = @_;
       return $prod if $n == 0;
       return _fact1($n-1, $n*$prod);
   };

   return _fact1($n, 1);
}

$result_to_print  = fact1($n);
print "Resultado $result_to_print \n";


## But since Perl doesn't do tail recursion optimisation, and since sub calls are relatively slow, you're better off with:
sub fact2 {
   my ($n) = @_;
   my $prod = 1;
   $prod *= $n-- while $n > 0;
   return $prod;
}

$result_to_print  = fact2($n);
print "Resultado $result_to_print \n";

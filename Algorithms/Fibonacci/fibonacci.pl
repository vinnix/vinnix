#!/usr/bin/perl -w
use strict;
use Benchmark;

timethese (10,

 { Normal=> 
    q{
       foreach (10..25)
       {
          #print "number $_ : fibonacci ",fibonacci($_),"\n";
          my $f = fibonacci($_);
       }
     },
         
   Slow =>
    q{
        foreach (10..25)
        {
           #print "number $_ : fibonacci ",fibonacci_slow($_),"\n";
           my $f = fibonacci_slow($_);
        } 
     },
  } 
);


sub fibonacci
{
  my $number  = shift;
  my $curnum  = 1;
  my $prevnum = 1;
  my $sum;
  
  if ($number ==1 || $number ==2){ return 1;}
  
  $number -= 2;
  while ($number--)
  {
     $sum = $curnum + $prevnum;
     $prevnum = $curnum;
     $curnum  = $sum;
  }
  
  return $sum;
}


sub fibonacci_slow
{
   my $number = shift;
   if ($number ==1 || $number ==2){ return 1;}
   
   return fibonacci_slow($number-1) + fibonacci_slow($number-2);
}

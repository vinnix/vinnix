
# Some experiments and demonstrations 

## References / Useful Links:

 * [Palindrome from Wikipedia](https://en.wikipedia.org/wiki/Palindrome)
 * [Reverse String with C or C++](http://stackoverflow.com/questions/198199/how-do-you-reverse-a-string-in-place-in-c-or-c)
 * [GLib Hash Tables](https://developer.gnome.org/glib/2.28/glib-Hash-Tables.html)
 * [C Hash Table Implementation](http://stackoverflow.com/questions/6844739/c-implement-a-hash-table)
 * [Quick hashtable implementation in C](https://gist.github.com/tonious/1377667)
 * [C/HashTables](http://www.cs.yale.edu/homes/aspnes/pinewiki/C(2f)HashTables.html?highlight=(CategoryAlgorithmNotes))
 * [Linked lists](http://www.learn-c.org/en/Linked_lists)    
 * [A simple look at arrays with Perl](http://blogs.perl.org/users/shawnhcorey/2012/05/a-look-at-arrays.html)
 * [More samples with Perl arrays](http://www.tutorialspoint.com/perl/perl_arrays.htm)
 * [Hashes with Perl](http://www.tutorialspoint.com/perl/perl_hashes.htm)
 * [Why bother? LL with Perl](http://pt.slideshare.net/lembark/perly-linked-lists)
 * [Pointers of Pointers in C - A](http://c-faq.com/~scs/cclass/int/sx8.html)
 * [Pointers of Pointers in C - B](http://stackoverflow.com/questions/897366/how-do-pointer-to-pointers-work-in-c)
 * [Data Structures](http://judy.sourceforge.net/examples/index.html)
 * [Reverse a LL with Perl](http://stackoverflow.com/questions/10965712/reverse-a-linked-list-in-perl)


## Tricks in Perl:

### My PoC with Catalyst framework

 * [vinnix/CatalystLab repository](https://github.com/vinnix/CatalystLab)
 * [PerlLab / Exercises that I have used to teach PERL](https://github.com/vinnix/PerlLab)

### Listing installed modules:

```perl
 use ExtUtils::Installed;

 my $inst = ExtUtils::Installed->new();
 my @modules = $inst->modules();
 foreach $module (@modules){
        print $module ." - ". $inst->version($module). "\n";
 }
```

Results:
```
App::cpanminus - 1.7042 
B::Hooks::EndOfScope - 0.21 
B::Keywords - 1.15 
B::Utils - 0.27 
Class::Inspector - 1.28 
Class::Load - 0.23 
Class::Load::XS - 0.09 
Clone - 0.38 
Data::Dump::Streamer - 2.39 
Data::Dumper::Concise - 2.022 
Data::OptList - 0.110 
Devel::Caller - 2.06 
Devel::GlobalDestruction - 0.13 
Devel::LexAlias - 0.05 
Devel::OverloadInfo - 0.004 
Devel::REPL - 1.003028 
Devel::StackTrace - 2.01 
Dist::CheckConflicts - 0.11 
Eval::Closure - 0.14 
Exporter::Tiny - 0.042 
ExtUtils::Config - 0.008 
ExtUtils::Depends - 0.405 
ExtUtils::Helpers - 0.022 
ExtUtils::InstallPaths - 0.011 
File::HomeDir - 1.00 
File::Next - 1.14 
File::Remove - 1.57 
File::Which - 1.21 
Getopt::Long::Descriptive - 0.099 
Hook::LexWrap - 0.25 
IO::String - 1.08 
JSON::PP - 2.27400 
Lexical::Persistence - 1.020 
List::MoreUtils - 0.415 
List::Util - 1.45 
MRO::Compat - 0.12 
Module::Build::Tiny - 0.039 
Module::Implementation - 0.09 
Module::Runtime - 0.014 
Module::Runtime::Conflicts - 0.003 
Moose - 2.1804 
MooseX::Getopt - 0.71 
MooseX::Object::Pluggable - 0.0014 
MooseX::Role::Parameterized - 1.08 
PPI - 1.220 
Package::DeprecationManager - 0.17 
Package::Stash - 0.37 
Package::Stash::XS - 0.28 
PadWalker - 2.2 
Params::Util - 1.07 
Params::Validate - 1.24 
Perl - 5.18.2 
Sub::Exporter - 0.987 
Sub::Exporter::Progressive - 0.001011 
Sub::Identify - 0.12 
Sub::Install - 0.928 
Sub::Name - 0.15 
Task::Weaken - 1.04 
Test::Fatal - 0.014 
Test::Harness - 3.36 
Test::NoWarnings - 1.04 
Test::Object - 0.07 
Test::Requires - 0.10 
Test::Simple - 1.302035 
Test::SubCalls - 1.09 
Try::Tiny - 0.24 
Variable::Magic - 0.59 
namespace::autoclean - 0.28 
namespace::clean - 0.27 
```

## PostgreSQL:elephant:

 * [Check this](https://github.com/vinnix/awesome-pg)


### ToDo:  

* [X] Rearrange directories from vinnix/vinnix
* [ ] Continue to build mePed bot (Machinelearning algo applied to bots)
* [ ] Sync my "cyber-security" bookmarks into this repository (Algos for security)
* [ ] Monitoring PostgreSQL project (Improve algo to monitor it)



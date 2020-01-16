# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

alias irssi_perl="irssi -c irc.perl.org -n vinnix"
alias irssi_freenode="irssi -c chat.freenode.net -n vinnix"
alias irssi_efnet="/usr/local/bin/irssi -c irc.efnet.org -n vinnix"

alias scr="screen -d -r " 

export TZ="/usr/share/zoneinfo/Europe/Dublin"

PATH="/home/vinnix/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/vinnix/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/vinnix/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/vinnix/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/vinnix/perl5"; export PERL_MM_OPT;

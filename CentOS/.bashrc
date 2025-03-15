# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

PATH="/home/vinnix/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/vinnix/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/vinnix/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/vinnix/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/vinnix/perl5"; export PERL_MM_OPT;

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

export PATH="$HOME/pg-versions/pg-17-stable/bin:$PATH"

PGDATA="$HOME/pg-versions/pg-17-stable-data"
export PGDATA

alias pg_start="pg_ctl -D $PGDATA start -l $PGDATA/log/pg_ctl.log"
alias pg_stop="pg_ctl -D $PGDATA stop -l $PGDATA/log/pg_ctl.log"
alias pg_reload="pg_ctl -D $PGDATA reload -l $PGDATA/log/pg_ctl.log"
alias pg_restart="pg_ctl -D $PGDATA restart -l $PGDATA/log/pg_ctl.log"

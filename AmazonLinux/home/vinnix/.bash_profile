# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=/opt/node/bin:$HOME/.local/bin:/home/postgres/pgsql/bin:$PATH:$HOME/.local/bin:$HOME/bin

export LC_ALL="en_US.UTF-8"
export TERM="xterm-256color"
export EDITOR="vim"


PGUSER="postgres"
PGDATABASE="postgres"
PGHOST="127.0.0.1"

export PGUSER PGDATABASE PGHOST

export PATH
#script /dev/null
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

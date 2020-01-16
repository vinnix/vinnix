# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=/opt/node/bin:$HOME/.local/bin:/home/postgres/pgsql/bin:$PATH:$HOME/.local/bin:$HOME/bin
TMP="/tmp"
export TMP
export PGDATA
export IBUS_ENABLE_SYNC_MODE=1
export PATH
alias xboxd="sudo xboxdrv --silent --dpad-as-button --trigger-as-button"

alias matr="/home/vinnix/Sources/tarballs/matrixgl-2.3.2/src/matrixgl -F -s -i 512 -l 1 -C green"
alias matrf="/home/vinnix/Sources/tarballs/matrixgl-2.3.2/src/matrixgl -F -s -i 512 -l 1000 -C green"
alias pgconf="./configure --prefix=/opt/pgCurrent --with-openssl --enable-debug --with-llvm --enable-dtrace --enable-cassert "
alias tool7set="scl enable devtoolset-7 llvm-toolset-7 bash"

# User specific environment and startup programs

export LC_ALL="en_US.UTF-8"
export TERM="xterm-256color"
export EDITOR="vim"


PGUSER="postgres"
PGDATABASE="postgres"
PGHOST="127.0.0.1"
PGDATA="/opt/pgsql/data"
export PGUSER PGDATABASE PGHOST PGDATA


export PLAYONLINUX="/usr/share/playonlinux"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"




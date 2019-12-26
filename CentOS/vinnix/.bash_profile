# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH="/opt/node/bin:$HOME/.local/bin:$HOME/bin:/usr/pgsql-9.6/bin/:$PATH"
PGDATA="/opt/pgsql/data"
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

export LC_ALL="en_US.UTF-8"
export TERM="xterm-256color"
export EDITOR="vim"
export PLAYONLINUX="/usr/share/playonlinux"

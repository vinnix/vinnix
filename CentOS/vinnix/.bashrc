# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
export TMP="/tmp"
export TMPDIR="/tmp"

alias mysteam="LD_PRELOAD='/usr/$LIB/libstdc++.so.6' LIBGL_DRI3_DISABLE=1 steam"

#export WORKON_HOME=~/.virtualenvs
#VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3.6
#source /usr/bin/virtualenvwrapper.sh
#alias python="/usr/bin/python3.6"
#alias python3="/usr/bin/python3.6"
#alias pip="/usr/bin/pip3.6"

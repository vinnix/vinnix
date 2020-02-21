
#export CPPFLAGS="-I/Users/vinics/homebrew/opt/openjdk/include"
#export LDFLAGS="-L/Users/vinics/homebrew/opt/llvm/lib"
#export CPPFLAGS="-I/Users/vinics/homebrew/opt/llvm/include"




ulimit -n 65536 200000



## Item settings
export PS1='\s-\v\$\[$(~/.iterm2/it2setkeylabel set status \
"$(test -d .git && (git rev-parse --abbrev-ref HEAD) || (echo -n "Not a repo"))")\] '
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

## ls colours
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
alias ls='ls -GFh'
alias ls='ls -lGFh'

export PATH="/Users/vinics/homebrew/opt/openssl@1.1/bin:$PATH"
export LDFLAGS="-L/Users/vinics/homebrew/opt/openssl@1.1/lib $LDFLAGS"
export LDFLAGS="-L/Users/vinics/homebrew/opt/libffi/lib $LDFLAGS"
export CPPFLAGS="-I/Users/vinics/homebrew/opt/openssl@1.1/include $CPPFLAGS"
export CFLAGS="-I/Users/vinics/homebrew/opt/openssl@1.1/include $CFLAGS"

export PATH="$HOME/homebrew/opt/openjdk/bin:$HOME/homebrew/bin:$HOME/homebrew/Cellar/llvm/9.0.1/Toolchains/LLVM9.0.1.xctoolchain/usr/bin/:$PATH"
export PATH="$HOME/Sources/builds/pgsql_HEAD/bin:$PATH"

export PGPORT="5432"
export PGUSER="postgres"
export PGDATABASE="postgres"
export PGHOST="localhost"
export PGDATA="$HOME/Sources/builds/pgsql_HEAD/data"

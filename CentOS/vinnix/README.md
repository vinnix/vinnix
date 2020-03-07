Make sure we have **wget** and basic packages:
=

```
sudo yum install wget -y
sudo yum install vim -y
sudo yum libevent-devel -y #required by tmux
```


Development Tools
==
```
sudo yum group install "Development Tools" 
```


Setup the basics on my environment:
==

```
sudo pip install --upgrade pip

adduser vinnix
echo "Requesting password for vinnix:"
passwd vinnix
```


Setup the basics fonts:
=
```
cd $HOME
mkdir ~/Sources

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf

mkdir -p ~/.config/fontconfig/conf.d/
cd ~/.config/fontconfig/conf.d/
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf

cd $HOME/Sources
git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh
cd ~/.config/fontconfig/conf.d/
wget https://github.com/powerline/fonts/blob/master/fontconfig/50-enable-terminess-powerline.conf


cd $HOME
ln -s ~/.local/share/fonts/ ~/.fonts/
ln -s ~/.local/share/fonts/ ~/.fonts
ln -s .config/fontconfig/ ~/.fontconfig


fc-cache -vf ~/.local/share/fonts/
fc-cache -vf ~/.config/fontconfig/conf.d/
fc-cache -vf 
```


Build tmux from source and download a nice config file
=
```
cd $HOME/Sources/
git clone https://github.com/tmux/tmux.git
cd tmux

./autogen.sh 
./configure --prefix=/home/vinnix/.local/
make 
make install


cd $HOME/Sources
git clone https://github.com/gpakosz/.tmux
cd $HOME
ln -s -f $HOME/Sources/.tmux/.tmux.conf
cp $HOME/Sources/.tmux/.tmux.conf.local .

cd $HOME
mkdir -p ~/.vim/bundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

.vim/vimrc
==

```
cat > ~/.vim/vimrc <<'VIMRC'

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
Plugin 'L9'
" Git plugin not hosted on GitHub
Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


VIMRC

vim +PluginInstall +qall

```
Alternatively we can use a copy of .vim/vimrc on this diretory

Then, run:
```
cd ~/.vim
rm ~/.vim/vimrc
ln -s ~/Sources/Github/vinnix/CentOS/vinnix/.vim/vimrc
vim +PluginInstall +qall
```

== Make sure we have **wget** and basic packages:

sudo yum install wget -y
sudo yum install vim -y

== Setup the basics on my environment:
```
sudo pip install --upgrade pip

adduser vinnix
echo "Requesting password for vinnix:"
passwd vinnix
```




== Setup the basics fonts:
```
cd $HOME
mkdir ~/Sources

mkdir ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf

mkdir ~/.config/fontconfig/conf.d/
cd ~/.config/fontconfig/conf.d/
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf

cd $HOME/Sources
git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh
cd ~/.config/fontconfig/conf.d/
wget https://github.com/powerline/fonts/blob/master/fontconfig/50-enable-terminess-powerline.conf

fc-cache -vf ~/.local/share/fonts/
fc-cache -vf ~/.config/fontconfig/conf.d/
fc-cache -vf 
```


==  Build tmux from source and download a nice config file
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




```

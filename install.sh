#!/bin/bash


USER=`logname`
HOME=/home/$USER

xrun() {
  sudo -u $USER $*
}

install_extension() {
  xrun gdbus call \
    --session \
    --dest org.gnome.Shell.Extensions \
    --object-path /org/gnome/Shell/Extensions \
    --method org.gnome.Shell.Extensions.InstallRemoteExtension $1
}

echo "Change LANGUAGE of user-dirs to English"
lang=$LANG
export LANG=en_US
xrun xdg-user-dirs-gtk-update
export LANG=$lang

source $HOME/.config/user-dirs.dirs

sudo apt update

echo "Install packages"
for package in `awk '{if($1=="+")printf $2"\n"}' packages.txt`; do
  sudo apt install -y $package
done

echo "Remove packages"
for package in `awk '{if($1=="-")printf $2"\n"}' packages.txt`; do
  sudo apt remove -y $package
done

DEB=google-chrome-stable_current_amd64.deb
echo "Download $DEB into $XDG_DOWNLOAD_DIR/"
xrun wget -O $XDG_DOWNLOAD_DIR/$DEB https://dl.google.com/linux/direct/$DEB
chmod 755 $XDG_DOWNLOAD_DIR/$DEB
sudo apt install $XDG_DOWNLOAD_DIR/$DEB

echo "Copy .vimrc as $HOME/.vimrc"
xrun cp home/.vimrc $HOME/

echo "Copy wallpapers into $XDG_PICTURES_DIR/"
xrun cp -r Pictures/* $XDG_PICTURES_DIR/

echo "Extract themes files into $HOME/.themes/"
xrun unzip "home/.themes/*.zip" -d $HOME/.themes/ >/dev/null

echo "Extract icons files into $HOME/.icons/"
xrun mkdir -p $HOME/.icons/
xrun tar -xvf home/.icons/*.tar.xz -C $HOME/.icons/ >/dev/null

echo "Copy grub into /etc/default/"
sudo cp grub /etc/default/
echo "Enter ./Themes/grub/sleek/bigSur/"
pushd ./Themes/grub/sleek/bigSur/ >/dev/null
echo "Install grub theme"
sudo ./install.sh
echo "Leave ./Theme/grub/sleek/bigSur/"
popd >/dev/null

echo "Install gnome-shell-extension: simple-system-monitor"
install_extension "ssm-gnome@lgiki.net"

# use the command `dconf dump /org/ > org.dconf` to backup
# your desktop configuration, and use following command to
# reproduce it in other machines, so that you will get
# consistent appearances in different machines.
echo -n "Load desktop..."
xrun dconf load /org/ < <(sed s:/absop/:/$USER/: org.dconf)
echo "done"

xrun gsettings set org.gnome.desktop.interface scaling-factor 2
xrun xrandr --output Virtual1 --scale 1x1

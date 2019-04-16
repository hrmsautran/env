#! /bin/bash


install_yaourt() {
  print "> > > Installing $BLUE YAOURT $DEFAULT < < < <"
  
  #sudo pacman -S --needed --noconfirm base-devel yajl
  git clone https://aur.archlinux.org/package-query.git /tmp/package-query
  cd /tmp/package-query && makepkg -si

  git clone https://aur.archlinux.org/yaourt.git /tmp/yaourt
  cd /tmp/yaourt && makepkg -si

}

install_xfce4() {
  print "> > > Installing $BLUE XFCE4 $DEFAULT < < < <"
  
  PACKAGES="xorg-server xorg-xinit xorg-twm xorg-xclock xterm xfce4 lightdm "
  PACKAGES+="xf86-input-mouse xf86-input-keyboard xf86-video-vesa "
  PACKAGES+="wget htop git vim zsh bash-completion ctags docker unrar unzip "
  # PACKAGES+="qemu-kvm qemu virt-manager virt-viewer libvirt-bin "
  #PACKAGES+="chromium firefox opera vlc clementine"

  sudo pacman -Sy

  if [ -n "`(pacman -Qk $PACKAGES 2>&1) | grep was\ not\ found`" ]; then
    print "\tInstalling pacman packages..."
    sudo pacman -Sq --needed --noconfirm $PACKAGES
  fi
}

install_utils() {
  print "> > > Installing $BLUE UTILS $DEFAULT < < < <"
  
  PACKAGES="google-chrome lightdm-webkit2-greeter lightdm-webkit-theme-litarvan"

  if [ -n "`(yaourt -Qk $PACKAGES 2>&1) | grep was\ not\ found`" ]; then
    print "\tInstalling yaourt packages..."
    yaourt -S --needed --noconfirm $PACKAGES
  fi
}

configure_desktop() {
  print "Configuring desktop..."
  
  #Configure lightdm.conf
  sudo sed -i -r -e 's/\#(greeter-session=).*$/\1lightdm-webkit2-greeter/' /etc/lightdm/lightdm.conf
  sudo sed -i -r -e 's/^(webkit_theme.*=).*$/\1 litarvan/' /etc/lightdm/lightdm-webkit2-greeter.conf
  sudo systemctl enable lightdm
  
  # Download Rele Theme
  # curl -o /tmp/rele.tar.bz2 https://dl.opendesktop.org/api/files/downloadfile/id/1462392025/s/947eec5cfb08c2bb291190370343f799/t/1527263464/u/60272/77260-rele-xfce4.tar.bz2
  # tar -xjvf /tmp/rele.tar.bz2
  # sudo cp -R /tmp/Rele /usr/share/themes/Rele

  curl -o /tmp/tintedarc.zip https://github.com/nizarmah/tintedarc/archive/master.zip
  unzip /tmp/tintedarc.zip -d /tmp/tintedarc
  rm -rf /tmp/tintedarc.zip
  sudo -s ./desktop-mode --setup
  desktop-mode --night

  # download image backgroud
  # xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s /temp/background.jpg
}

configure_docker() {
  print "Configuring docker..."
  #if [-n "`systemctl is-enabled docker | grep disabled`"]; then
  sudo systemctl enable docker
  sudo usermod -aG docker hermesautran

  print "Configuring docker bin..."
  sudo ln -s ~/env/bin/* /usr/local/bin/
}

configure_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  fi
  
  if [ ! -z "`echo $SHELL | grep zsh`" ]; then
    print "Configuring zsh..."
    chsh $USER -s $(which zsh)
  fi
}

install_arch() {

  install_xfce4
  install_yaourt
  install_utils
  
  configure_desktop
  configure_docker
  configure_oh_my_zsh
  
}

print () {
  DEFAULT='\033[0;31m'
  NC='\033[0m'
  echo -e "$DEFAULT > $1$NC"
}

install_arch

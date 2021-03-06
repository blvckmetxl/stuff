#!/bin/bash

if [ "$EUID" -ne 0 ]
then
	echo "not root"
	exit
fi

if [[ "$(cat /etc/os-release | grep \"Archcraft\")" ]]
then
    	chmod +x archcraft/setup.sh && cd archcraft && ./setup.sh
	exit
fi

sed -i "s/#Color/Color/g" /etc/pacman.conf
sed -i "s/#VerbosePkgLists/VerbosePkgLists/g" /etc/pacman.conf
sed -i "s/#ParallelDownloads/ParallelDownloads/g" /etc/pacman.conf

pacman -S --noconfirm base-devel
git clone https://aur.archlinux.org/yay.git
chown bm:bm -R yay
cd yay && sudo -u bm makepkg -si
cd .. && rm -rf yay
sudo pacman -Rns go

pacman -Qs zsh >& /dev/null
if [ "$?" -ne 0 ]
then
	pacman -S --noconfirm zsh
fi

[ ! -d "/home/bm/.oh-my-zsh" ] && curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O && sed -i 's/RUNZSH=${RUNZSH:-yes}/RUNZSH=${RUNZSH:-no}/g' install.sh && chmod +x install.sh && chown bm:bm install.sh && sudo -u bm ./install.sh && rm install.sh
mv bm.zsh-theme /home/bm/.oh-my-zsh/custom/themes
mv .zshrc /home/bm

mv wallpapers /home/bm
mkdir /home/bm/vpns
mv .screenlayout /home/bm
chmod +x /home/bm/.screenlayout/dualm.sh
chown bm:bm /home/bm/vpns
mkdir /opt/wordlists

pacman -Qs wget >& /dev/null
if [ "$?" -ne 0 ]
then
	pacman -S --noconfirm wget
fi
wget https://github.com/praetorian-inc/Hob0Rules/raw/master/wordlists/rockyou.txt.gz
gzip -d rockyou.txt.gz
mv rockyou.txt /opt/wordlists
curl -O https://raw.githubusercontent.com/daviddias/node-dirbuster/master/lists/directory-list-2.3-medium.txt
mv directory-list-2.3-medium.txt /opt/wordlists
mkdir /etc/feroxbuster
echo -e "wordlist = \"/opt/wordlists/directory-list-2.3-medium.txt\"\nthreads = 10\nsave_state = false" > /etc/feroxbuster/ferox-config.toml
mkdir /etc/samba
touch /etc/samba/smb.conf

echo -e "_JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on'\n_JAVA_AWT_WM_NONREPARENTING=1" >> /etc/environment # fix burpsuite weird font
echo "setxkbmap br" >> /home/bm/.profile
chown bm:bm /home/bm/.profile

rm -rf /home/bm/.config 2>/dev/null
mv .config /home/bm

dir=$(pwd)
cd /home/bm/.config
chmod +x bspwm/bspwmrc bspwm/mon.sh polybar/launch.sh polybar/mic.sh rofi/launcher.sh
cd $dir

pacman -S --noconfirm picom firefox whois ripgrep netcat alacritty unzip tcpdump flameshot pavucontrol xorg-xsetroot dialog sxhkd bspwm qbittorrent awesome-terminal-fonts arandr vlc rofi xcursor-simpleandsoft lxappearance-gtk3 xorg-server thunar discord openvpn feh gparted reflector lightdm rlwrap lightdm-gtk-greeter pkgfile noto-fonts noto-fonts-cjk noto-fonts-emoji pulseaudio python-pip xdg-utils gvfs gvfs-afc xsel

echo -e "\nopacity-rule = [ "20:class_g = 'Bspwm' && class_i = 'presel_feedback'" ];" >> /etc/xdg/picom.conf
sed -i 's/autospawn = no/autospawn = yes/g' /etc/pulse/client.conf # fix pulseaudio config
sed -i 's/\/usr\/bin\/gparted/\/usr\/bin\/sudo \/usr\/bin\/gparted/g' /usr/share/applications/gparted.desktop
mkdir -p /home/bm/.icons/default && chown -R bm:bm /home/bm/.icons
echo -e "[Icon Theme]\nName=Default\nComment=Default Cursor Theme\nInherits=Simple-and-Soft" > /home/bm/.icons/default/index.theme
chown bm:bm /home/bm/.icons/default/index.theme
pkgfile --update
systemctl enable lightdm

### tools ###
pacman -S --noconfirm aircrack-ng exploitdb hydra john metasploit nmap wireshark-qt
yay -S --noconfirm --nopgpfetch --mflags --skipinteg burpsuite feroxbuster rustscan wfuzz 
###   -   ###

sudo -u bm yay -S --noconfirm --removemake neovim nerd-fonts-mononoki suru-plus-git polybar
sudo -u bm yay -S --noconfirm --removemake --nopgpfetch --mflags --skipinteg spotify spotify-adblock tor-browser
chown root:root spotify.desktop
mv spotify.desktop /usr/share/applications
rm /usr/share/applications/spotify-adblock.desktop

cd /usr/share/nvim/runtime/colors
curl -O https://raw.githubusercontent.com/AlessandroYorba/Sierra/master/colors/sierra.vim
echo -e "\nhi Normal guibg=NONE ctermbg=NONE" >> sierra.vim

echo -e "colorscheme sierra\nset number" > /home/bm/.nvimrc
chown bm:bm /home/bm/.nvimrc
mkdir /home/bm/.config/nvim
echo "source ~/.nvimrc" >> /home/bm/.config/nvim/init.vim
chown -R bm:bm /home/bm/.config/nvim

cd $dir

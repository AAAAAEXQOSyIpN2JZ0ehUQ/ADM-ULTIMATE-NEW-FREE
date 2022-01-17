#!/bin/bash

apt-get install curl wget apt-transport-https dirmngr 

echo '#------------------------------------------------------------------------------#
#                   OFFICIAL DEBIAN REPOS                    
#------------------------------------------------------------------------------#

###### Debian Main Repos
deb http://deb.debian.org/debian/ stable main contrib non-free
deb-src http://deb.debian.org/debian/ stable main contrib non-free
deb http://deb.debian.org/debian/ stable-updates main contrib non-free
deb-src http://deb.debian.org/debian/ stable-updates main contrib non-free
deb http://deb.debian.org/debian-security stable/updates main
deb-src http://deb.debian.org/debian-security stable/updates main
deb http://ftp.debian.org/debian stretch-backports main
deb-src http://ftp.debian.org/debian stretch-backports main

#------------------------------------------------------------------------------#
#                      UNOFFICIAL  REPOS                       
#------------------------------------------------------------------------------#

###### 3rd Party Binary Repos
###Adapta GTK Theme
deb http://ppa.launchpad.net/tista/adapta/ubuntu artful main
deb-src http://ppa.launchpad.net/tista/adapta/ubuntu artful main
###Atom Editor
deb [arch=amd64,i386] https://dl.bintray.com/alanfranz/atom-apt stable main
###Benno MailArchiv
deb http://www.benno-mailarchiv.de/download/debian /
###Debian Multimedia
deb [arch=amd64,i386] https://www.deb-multimedia.org stable main non-free
###Dino
deb [arch=amd64,i386] http://download.opensuse.org/repositories/network:/messaging:/xmpp:/dino/Debian_9.0/ /
###Docker CE
deb [arch=amd64] https://download.docker.com/linux/debian stretch stable
###Dropbox
deb http://linux.dropbox.com/debian jessie main
###Enpass Password Manager
deb http://repo.sinew.in/ stable main
###Esmska
deb http://download.opensuse.org/repositories/Java:/esmska/common-deb/ ./
###FusionDirectory
deb http://repos.fusiondirectory.org/debian-jessie jessie main
###GNS3
deb http://ppa.launchpad.net/gns3/ppa/ubuntu xenial main
deb-src http://ppa.launchpad.net/gns3/ppa/ubuntu xenial main
###Google Chrome Browser
deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main
###Google Earth
deb [arch=amd64] http://dl.google.com/linux/earth/deb/ stable main
###Icon Repo
deb http://ppa.launchpad.net/noobslab/icons/ubuntu artful main
deb-src http://ppa.launchpad.net/noobslab/icons/ubuntu artful main
###Jabber.at ejabberd Repo
deb [arch=i386,amd64] https://apt.jabber.at stretch ejabberd
###Jabber.at gajim Repo
deb [arch=i386,amd64] https://apt.jabber.at stretch gajim
###Jabber.at mcabber Repo
deb [arch=i386,amd64] https://apt.jabber.at stretch mcabber
###Lazarus
deb http://www.hu.freepascal.org/lazarus/ lazarus-stable universe
###Lynis
deb https://packages.cisofy.com/community/lynis/deb/ stable main
###MariaDB
deb [arch=i386,amd64] http://mirror.23media.de/mariadb/repo/10.2/debian stretch main
deb-src [arch=i386,amd64] http://mirror.23media.de/mariadb/repo/10.2/debian stretch main
###MEGA Sync Client
deb http://mega.nz/linux/MEGAsync/Debian_9.0/ ./
###muCommander
deb http://apt.mucommander.com stable main non-free contrib
###Nextcloud Client
deb [arch=amd64,i386] http://download.opensuse.org/repositories/home:/ivaradi/Debian_9.0/ /
###nginx
deb [arch=amd64,i386] http://nginx.org/packages/debian/ stretch nginx
deb-src [arch=amd64,i386] http://nginx.org/packages/debian/ stretch nginx
###openmediavault
deb http://packages.openmediavault.org/public erasmus main
deb-src http://packages.openmediavault.org/public erasmus main
###Opera
deb [arch=amd64,i386] https://deb.opera.com/opera-stable/ stable non-free
###ownCloud Client
deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Debian_9.0/ /
###Pantheon Desktop
deb [arch=amd64] http://gandalfn.ovh/debian stretch-loki main contrib
###Paper GTK Theme
deb http://ppa.launchpad.net/snwh/pulp/ubuntu yakkety main
deb-src http://ppa.launchpad.net/snwh/pulp/ubuntu yakkety main
###Papirus GTK Theme
deb http://ppa.launchpad.net/papirus/papirus/ubuntu artful main 
deb-src http://ppa.launchpad.net/papirus/papirus/ubuntu artful main 
###PostgreSQL
deb [arch=amd64,i386] http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main
###Proxmox
deb [arch=amd64] http://download.proxmox.com/debian stretch pve-no-subscription
###Resilio Sync
deb http://linux-packages.resilio.com/resilio-sync/deb resilio-sync non-free
###Signal Desktop
deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main
###Skype
deb [arch=amd64] https://repo.skype.com/deb stable main
###Spotify
deb http://repository.spotify.com stable non-free
###Steam
deb [arch=i386,amd64] http://repo.steampowered.com/steam/ precise steam
###Sublime Text
deb https://download.sublimetext.com/ apt/stable/
###Toot - a Mastodon CLI client
deb http://bezdomni.net/packages/ ./
###TOR
deb [arch=i386,amd64,armel,armhf] http://deb.torproject.org/torproject.org stable main
deb-src [arch=i386,amd64,armel,armhf] http://deb.torproject.org/torproject.org stable main
###TOX
deb [arch=i386,amd64] https://pkg.tox.chat/debian stable stretch 
###Ubuntuzilla
deb http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt all main
###Vagrant
deb https://vagrant-deb.linestarve.com/ any main
###video-dl
deb http://repo.daniil.it lenny main
###Virtualbox
deb [arch=i386,amd64] http://download.virtualbox.org/virtualbox/debian stretch contrib
###Visual Studio Code
deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main
###Vivaldi Browser
deb [arch=i386,amd64] http://repo.vivaldi.com/stable/deb/ stable main
###Webmin
deb http://download.webmin.com/download/repository sarge contrib
###Wine
deb [arch=i386] https://dl.winehq.org/wine-builds/debian/ stretch main' > /etc/apt/sources.list

apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys EAC0D406E5D79A82ADEEDFDFB76E53652D87398A
curl https://www.franzoni.eu/keys/D401AB61.txt | apt-key add -
wget -O - http://www.benno-mailarchiv.de/download/debian/benno.asc | apt-key add -
wget http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb && dpkg -i deb-multimedia-keyring_2016.8.1_all.deb
wget -nv https://download.opensuse.org/repositories/network:messaging:xmpp:dino/Debian_9.0/Release.key -O Release.key && apt-key add - < Release.key && rm Release.key
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys FC918B335044912E
wget -O - https://dl.sinew.in/keys/enpass-linux.key | apt-key add -
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 29255F95E60A19CD
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys E184859262B4981F
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F88F6D313016330404F710FC9A2FD067A2E3EF7B
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 1397BC53640DB551
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 1397BC53640DB551
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys D530E028F59EAE4D
wget -qO- https://apt.jabber.at/gpg-key | apt-key add -
wget -qO- https://apt.jabber.at/gpg-key | apt-key add -
wget -qO- https://apt.jabber.at/gpg-key | apt-key add -
gpg --keyserver hkp://pgp.mit.edu:11371 --recv-keys 6A11800F  && gpg --export --armor 0F7992B0 | apt-key add -
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C80E383C3DE9F082E01391A0366C67DE91CA5D5F
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 4B4E7A9523ACD201
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 030BBF253A687AFF
wget -q -O - http://download.opensuse.org/repositories/home:/ivaradi/Debian_9.0/Release.key | apt-key add -
wget https://nginx.org/keys/nginx_signing.key && apt-key add nginx_signing.key
apt-get update && apt-get install openmediavault-keyring && apt-get update
wget -O - http://deb.opera.com/archive.key | apt-key add -
wget http://download.opensuse.org/repositories/isv:ownCloud:desktop/Debian_8.0/Release.key && apt-key add - < Release.key && rm Release.key
wget http://gandalfn.ovh/debian/pantheon-debian.gpg.key -O- | apt-key add -
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 3766223989993A70
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys E58A9D36647CAE7F
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
wget -O- "http://download.proxmox.com/debian/key.asc" | apt-key add -
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 05CD43032484414B
curl -s https://updates.signal.org/desktop/apt/keys.asc | apt-key add -
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 1F3045A5DF7587C3
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys EFDC8610341D9410
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F24AEA9FB05498B7
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
curl https://keybase.io/ihabunek/pgp_keys.asc | apt-key add -
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 74A941BA219EC810
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys A2B076511A171ABE
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 2667CA5C
apt-key adv --keyserver pgp.mit.edu --recv-key AD319E0F7CFFA38B4D9F6E55CE3F3DE92099F7A4
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 72B97FD1D9672C93
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 2CC26F777B8B44A1
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys D97A3AE911F63C51
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 818A435C5FCBF54A


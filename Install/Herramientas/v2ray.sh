#!/bin/bash

SCPdir="/etc/newadm"
SCPusr="${SCPdir}/ger-user"
SCPfrm="/etc/ger-frm"
SCPfrm3="/etc/adm-lite"
SCPinst="/etc/ger-inst"
SCPidioma="${SCPdir}/idioma"

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
meu_ip () {
if [[ -e /etc/MEUIPADM ]]; then
echo "$(cat /etc/MEUIPADM)"
else
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && echo "$MEU_IP2" || echo "$MEU_IP"
echo "$MEU_IP2" > /etc/MEUIPADM
fi
}
IP="$(meu_ip)"

BARRA1="\e[1;30m➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖\e[0m"
BARRA="\e[0;31m--------------------------------------------------------------------\e[0m"
blan='\033[1;37m'
ama='\033[1;33m'
blue='\033[1;34m'
asul='\033[0;34m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
 
fun_V2ray () {
if [[ -e /usr/local/V2ray.Fun ]]; then
 clear
   v2ray
else
   install_V2ray
fi
}
 
 
install_V2ray () {
clear
tput setaf 7 ; tput setab 4 ; tput bold ; printf '%30s%s%-10s\n' "V2ray PANEL" ; tput sgr0 ; echo ""
echo -e "$BARRA1"
echo -e "${blue}ESTE SCRIPT INSTALARA V2ray PANEL EN SU VPS, ESTO${plain}"
echo -e "${blue}TOMARA UNOS MINUTOS SEA PACIENTE${plain}"
echo -e "$BARRA1"
    echo -e "${blan}Presione ENTER para comenzar o presione Ctrl + C para cancelar. Continue!${plain}"
    read enter
echo -e "$BARRA1"
 
#Check Root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: Debe ser root para ejecutar este script${CEND}"; exit 1; }
 
#Check OS
if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ]; then
  OS=CentOS
  [ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
  [ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
  [ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ]; then
  OS=CentOS
  CentOS_RHEL_version=6
elif [ -n "$(grep bian /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Debian' ]; then
  OS=Debian
  [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
  Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Deepin /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Deepin' ]; then
  OS=Debian
  [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
  Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Ubuntu /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Ubuntu' -o -n "$(grep 'Linux Mint' /etc/issue)" ]; then
  OS=Ubuntu
  [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
  Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
  [ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
else
  echo "${CFAILURE} no es compatible con este sistema operativo, comuníquese con el autor! ${CEND}"
  kill -9 $$
fi
 
#Install Needed Packages
 
if [ ${OS} == Ubuntu ] || [ ${OS} == Debian ];then
    apt-get update -y
    apt-get install wget curl socat git unzip python python-dev openssl libssl-dev ca-certificates supervisor -y
    wget -O - "https://bootstrap.pypa.io/get-pip.py" | python
    pip install --upgrade pip
    pip install flask requests urllib3 Flask-BasicAuth Jinja2 requests six wheel
    pip install pyOpenSSL
fi
 
if [ ${OS} == CentOS ];then
    yum install epel-release -y
    yum install python-pip python-devel socat ca-certificates openssl unzip git curl crontabs wget -y
    pip install --upgrade pip
    pip install flask requests urllib3 Flask-BasicAuth supervisor Jinja2 requests six wheel
    pip install pyOpenSSL
fi
 
if [ ${Debian_version} == 9 ];then
    wget -N --no-check-certificate https://github.com/Dankelthaher/V2ray.Fun/blob/master/enable-debian9-rclocal.sh
    bash enable-debian9-rclocal.sh
    rm enable-debian9-rclocal.sh
fi
 
 
#Install acme.sh
curl https://get.acme.sh | sh
 
#Install V2ray
curl -L -s https://install.direct/go.sh | bash
 
#Install V2ray.Fun
cd /usr/local/
git clone https://github.com/Dankelthaher/V2ray.Fun
 
#Generate Default Configurations
cd /usr/local/V2ray.Fun/ && python init.py
cp /usr/local/V2ray.Fun/v2ray.py /usr/local/bin/v2ray
chmod +x /usr/local/bin/v2ray
chmod +x /usr/local/V2ray.Fun/start.sh
 
#Start All services
service v2ray start
 
#Configure Supervisor
mkdir /etc/supervisor
mkdir /etc/supervisor/conf.d
echo_supervisord_conf > /etc/supervisor/supervisord.conf
cat>>/etc/supervisor/supervisord.conf<<EOF
[include]
files = /etc/supervisor/conf.d/*.ini
EOF
touch /etc/supervisor/conf.d/v2ray.fun.ini
cat>>/etc/supervisor/conf.d/v2ray.fun.ini<<EOF
[program:v2ray.fun]
command=/usr/local/V2ray.Fun/start.sh run
stdout_logfile=/var/log/v2ray.fun
autostart=true
autorestart=true
startsecs=5
priority=1
stopasgroup=true
killasgroup=true
EOF
 
echo -e "${blue}ESTOS DATOS SE USARAN PARA ENRAR AL PANEL${plain}"
echo -e "$BARRA1"
read -p "ingrese el nombre de usuario [predeterminado admin]: " un
echo -e "$BARRA"
read -p "Ingrese la contrasena de inicio de sesion [predeterminado admin]: " pw
echo -e "$BARRA"
read -p "Introduzca el numero de puerto [predeterminado 5000]: " uport
if [[ -z "${uport}" ]];then
    uport="5000"
else
    if [[ "$uport" =~ ^(-?|\+?)[0-9]+(\.?[0-9]+)?$ ]];then
        if [[ $uport -ge "65535" || $uport -le 1 ]];then
            echo -e "${red}valor de rango de puerto [1,65535], aplique el numero de puerto predeterminado 5000${plain}"
            unset uport
            uport="5000"
        else
            tport=`netstat -anlt | awk '{print $4}' | sed -e '1,2d' | awk -F : '{print $NF}' | sort -n | uniq | grep "$uport"`
            if [[ ! -z ${tport} ]];then
                echo -e "${red}El numero de puerto ya existe! Aplique el numero de puerto predeterminado 5000${plain}"
                unset uport
                uport="5000"
            fi
        fi
    else
        echo -e "${blan}Por favor, ingrese un número. Aplique el número de puerto predeterminado 5000${plain}"
        uport="5000"
    fi
fi
if [[ -z "${un}" ]];then
    un="admin"
fi
if [[ -z "${pw}" ]];then
    pw="admin"
fi
sed -i "s/%%username%%/${un}/g" /usr/local/V2ray.Fun/panel.config
sed -i "s/%%passwd%%/${pw}/g" /usr/local/V2ray.Fun/panel.config
sed -i "s/%%port%%/${uport}/g" /usr/local/V2ray.Fun/panel.config
chmod 777 /etc/v2ray/config.json
supervisord -c /etc/supervisor/supervisord.conf
echo "supervisord -c /etc/supervisor/supervisord.conf">>/etc/rc.local
chmod +x /etc/rc.local
 
echo -e "$BARRA1"
echo -e "${green}La instalacion ah sido exitosa!${plain}"

echo -e "${blan}con estos datos entrara al panel${plain}"
echo -e "$BARRA1"
echo ""
echo -e "${blan}Puerto del panel:${plain} ${uport}"
echo -e "$BARRA"
echo -e "${blan}Nombre de usuario:${plain} ${un}"
echo -e "$BARRA"
echo -e "${blan}Contrasena:${plain} ${pw}"
echo -e "$BARRA"
echo -e "${blan}Acceso al panel: http://$IP:${uport}${plain}"
echo -e "${blan}O use la direccion de su dominio mas el puerto${plain}"
echo -e "$BARRA1"
echo ''
echo "Gracias por utilizar v2ray"
 
#LIMPIAR ARCHIVOS BASURA
rm -rf /root/config.json
rm -rf /root/install-debian.sh
}
fun_V2ray
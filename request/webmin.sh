#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

fun_ip () {
if [[ -e /etc/MEUIPADM ]]; then
IP="$(cat /etc/MEUIPADM)"
else
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && IP="$MEU_IP2" || IP="$MEU_IP"
echo "$MEU_IP2" > /etc/MEUIPADM
fi
}

fun_bar () {
comando="$1"
 _=$(
$comando > /dev/null 2>&1
) & > /dev/null
pid=$!
while [[ -d /proc/$pid ]]; do
echo -ne " \033[1;33m["
   for((i=0; i<10; i++)); do
   echo -ne "\033[1;31m##"
   sleep 0.2
   done
echo -ne "\033[1;33m]"
sleep 1s
echo
tput cuu1
tput dl1
done
echo -e " \033[1;33m[\033[1;31m####################\033[1;33m] - \033[1;32m100%\033[0m"
sleep 1s
}

# https://clouding.io/hc/es/articles/360010749399-C%C3%B3mo-Instalar-Webmin-en-Ubuntu-18-04

webmin_update () {
apt-get update -y > /dev/null 2>&1
apt-get upgrade -y > /dev/null 2>&1
apt-get install software-properties-common apt-transport-https wget -y
wget -q http://www.webmin.com/jcameron-key.asc -O- | apt-key add -
add-apt-repository "deb [arch=amd64] http://download.webmin.com/download/repository sarge contrib"
apt-get install webmin
ufw allow 10000/tcp
sleep 1s
}

web_min () {
 [[ -e /etc/webmin/miniserv.conf ]] && {
 echo -e "${cor[3]} $(fun_trans "REMOVENDO WEBMIN")"
 echo -e "$barra"
 fun_bar "apt-get remove webmin -y"
 echo -e "$barra"
 echo -e "${cor[3]} $(fun_trans "REMOVIDO CON SUCESSO") ${cor[2]} [!OK]"
 echo -e "$barra"
 [[ -e /etc/webmin/miniserv.conf ]] && rm /etc/webmin/miniserv.conf
 return 0
 }
echo -e "${cor[3]} Instalando Webmin, aguarde:"
echo -e "$barra"
echo -ne " \033[1;31m[ ! ] apt-get update"
apt-get update -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get upgrade"
apt-get upgrade -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -e "$barra"
echo -ne " $(fun_trans "Desea Seguir?") [S/N]: "; read x
[[ $x = @(n|N) ]] && echo -e "$barra" && return
echo -e ""
apt-get install software-properties-common apt-transport-https wget -y
wget -q http://www.webmin.com/jcameron-key.asc -O- | apt-key add -
add-apt-repository "deb [arch=amd64] http://download.webmin.com/download/repository sarge contrib"
apt-get install webmin
ufw allow 10000/tcp
sleep 1s
echo -e "$barra"
service webmin restart > /dev/null 2>&1
fun_ip
echo -e "${cor[0]} $(fun_trans "Acesso via web usando o link"): https://$IP:10000"
echo -e "$barra"
echo -e "${cor[3]} $(fun_trans "INSTALADO CON SUCESSO") ${cor[4]} [!OK] "
echo -e "$barra"
return 0
}
web_min
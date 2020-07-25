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

antiddos (){
fun_bar "service ssh restart" "service squid3 restart"
if [ -d '/usr/local/ddos' ]; then
	if [ -e '/usr/local/sbin/ddos' ]; then
		rm -f /usr/local/sbin/ddos
	fi
	if [ -d '/usr/local/ddos' ]; then
		rm -rf /usr/local/ddos
	fi
	if [ -e '/etc/cron.d/ddos.cron' ]; then
		rm -f /etc/cron.d/ddos.cron
	fi
	sleep 4s
	echo -e "$barra"
	echo -e "${cor[3]}$(fun_trans "ANTIDDOS DESINSTALADO CON SUCESSO")"
	return 1
else
	mkdir /usr/local/ddos
fi
fun_bar "service ssh restart" "service squid3 restart"
wget -q -O /usr/local/ddos/ddos.conf https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/ddos.conf -o /dev/null
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf -o /dev/null
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE -o /dev/null
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list -o /dev/null
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh -o /dev/null
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
sleep 2s
echo -e "$barra"
echo -e "${cor[3]}$(fun_trans "ANTIDDOS INSTALACAO CON SUCESSO")"
}

backup (){
#BACKUP ANTI-DDOS
fun_bar "mkdir /root/scripts"
wget -O /root/scripts/listcron.sh http://www.inetbase.com/scripts/listcron.sh -o /dev/null
fun_bar "mkdir /root/scripts/ddos"
wget -O /root/scripts/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENS -o /dev/null
wget -O /root/scripts/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf -o /dev/null
wget -O /root/scripts/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh -o /dev/null
wget -O /root/scripts/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list -o /dev/null
echo "#BACKUP DE SCRIPT ANTIDDOS" > /root/scripts/Importante.txt
wget -O /root/scripts/ddos/install.ddos http://www.inetbase.com/scripts/ddos/install.ddos -o /dev/null
wget -O /root/scripts/ddos/install.sh http://www.inetbase.com/scripts/ddos/install.sh -o /dev/null
wget -O /root/scripts/ddos/uninstall.ddos http://www.inetbase.com/scripts/ddos/uninstall.ddos -o /dev/null
wget -O /root/scripts/ddos/uninstall.sh http://www.inetbase.com/scripts/ddos/uninstall.sh -o /dev/null
fun_bar "service ssh restart" "service squid3 restart"
echo -e "$barra"
echo -e "${cor[3]}$(fun_trans "BACKUP ANTIDDOS CON SUCESSO")"
echo -e "$barra"
echo -e "${cor[4]}$(fun_trans "Ruta del backup:") ${cor[2]}/root/scripts"
}

[[ -e /usr/local/ddos/ddos.conf ]] && ddos=$(echo -e "\033[1;32mon ") || ddos=$(echo -e "\033[1;31moff ")

msg -ama "$(fun_trans "ANTI DDOS") ${cor[4]}[NEW-ADM]"
echo -e "$barra"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "Anti DDOS") $ddos"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "BACKUP Anti DDOS")"
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
echo -e "$barra"
while [[ ${arquivoonlineadm} != @(0|[1-2]) ]]; do
read -p "Selecione a Opcao: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)antiddos;;
2)backup;;
esac
msg -bar
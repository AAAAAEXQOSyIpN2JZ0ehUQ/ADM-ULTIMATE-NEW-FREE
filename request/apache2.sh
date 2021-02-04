#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;32m" [3]="\033[1;36m" [4]="\033[1;31m" )
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
API_TRANS="aHR0cDovL2dpdC5pby90cmFucw=="
SUB_DOM='base64 -d'
wget -O /usr/bin/trans $(echo $API_TRANS|$SUB_DOM) &> /dev/null

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
tput cuu1 && tput dl1
done
echo -e " \033[1;33m[\033[1;31m####################\033[1;33m] - \033[1;32m100%\033[0m"
sleep 1s
}

inst_components () {
fun_bar "apt-get purge apache2 -y" 
fun_bar "apt-get install apache2 -y"
sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf
service apache2 restart > /dev/null 2>&1 &
sleep 0.5s
msg -bar
msg -ama "$(fun_trans "PROCESSO CONCLUIDO")"
msg -bar
}

apache2_restart () {
fun_bar "service apache2 start" "service apache2 restart"
sleep 0.5s
msg -bar
msg -ama "$(fun_trans "PROCESSO CONCLUIDO")"
msg -bar
}

apache2_stop () {
fun_bar "service apache2 stop"
sleep 0.5s
msg -bar
msg -ama "$(fun_trans "PROCESSO CONCLUIDO")"
msg -bar
}

fun_apache2 () {
unset OPENBAR
[[ -e /etc/apache2/ports.conf ]] && OPENBAR="\033[1;32mOnline" || OPENBAR="\033[1;31mOffline"
msg -ama " $(fun_trans "MENU APACHE2")"
msg -bar
echo -e "\033[1;32m [0] >\033[1;37m $(fun_trans "Voltar")"
echo -e "\033[1;32m [1] >\033[1;36m $(fun_trans "Reinstalar APACHE2 Port 81") $OPENBAR"
echo -e "\033[1;32m [2] >\033[1;36m $(fun_trans "Editar Cliente APACHE2") \033[1;31m(comand nano)"
echo -e "\033[1;32m [3] >\033[1;36m $(fun_trans "Iniciar/Reiniciar APACHE2")"
echo -e "\033[1;32m [4] >\033[1;36m $(fun_trans "Parar APACHE2")"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-4]) ]]; do
read -p "[0-4]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)inst_components;;
2)nano /etc/apache2/ports.conf
   service apache2 restart &>/dev/null
   return 0;;
3)apache2_restart;;
4)apache2_stop;;
esac
}
fun_apache2
#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

mportas () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}

verif_ptrs() {
porta=$1
PT=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" | grep -v "COMMAND" | grep "LISTEN")
for pton in $(echo -e "$PT" | cut -d: -f2 | cut -d' ' -f1 | uniq); do
svcs=$(echo -e "$PT" | grep -w "$pton" | awk '{print $1}' | uniq)
[[ "$porta" = "$pton" ]] && {
echo -e "\n\033[1;31mPORTA \033[1;33m$porta \033[1;31mEM USO PELO \033[1;37m$svcs\033[0m"
sleep 3
menu
}
done
}

fun_bar () {
comando[0]="$1"
comando[1]="$2"
 (
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} -y > /dev/null 2>&1
${comando[1]} -y > /dev/null 2>&1
touch $HOME/fim
 ) > /dev/null 2>&1 &
echo -ne "\033[1;33m ["
while true; do
   for((i=0; i<10; i++)); do
   echo -ne "\033[1;31m##"
   sleep 0.1s
   done
   [[ -e $HOME/fim ]] && rm $HOME/fim && break
   echo -e "\033[1;33m]"
   sleep 1s
   tput cuu1
   tput dl1
   echo -ne "\033[1;33m ["
done
echo -e "\033[1;33m]\033[1;31m -\033[1;32m 100%\033[1;37m"
}

x="ok"

fun_sslh() {
[[ "$(netstat -nltp | grep 'sslh' | wc -l)" = '0' ]] && {
msg -azu " $(fun_trans "INSTALADOR SSLH MULTIPLEX")"
msg -bar
msg -ama " $(fun_trans "A PORTA 443 SERA USADA POR PADRAO")"
msg -bar
echo -ne " \033[1;37mDeseja Instalar o SSLH [s/n]: "
read resp
[[ "$resp" = 's' ]] && {
verif_ptrs 443
fun_instsslh() {
[[ -e "/etc/stunnel/stunnel.conf" ]] && ptssl="$(netstat -nplt | grep 'stunnel' | awk {'print $4'} | cut -d: -f2 | xargs)" || ptssl='3128'
[[ -e "/etc/openvpn/server.conf" ]] && ptvpn="$(netstat -nplt | grep 'openvpn' | awk {'print $4'} | cut -d: -f2 | xargs)" || ptvpn='1194'
DEBIAN_FRONTEND=noninteractive apt-get -y install sslh
echo -e "#Modo autónomo\n\nRUN=yes\n\nDAEMON=/usr/sbin/sslh\n\nDAEMON_OPTS='--user sslh --listen 0.0.0.0:443 --ssh 127.0.0.1:22 --ssl 127.0.0.1:$ptssl --http 127.0.0.1:80 --openvpn 127.0.0.1:$ptvpn --pidfile /var/run/sslh/sslh.pid'" >/etc/default/sslh
/etc/init.d/sslh start && service sslh start
}
msg -bar
msg -ama " $(fun_trans "INSTALANDO O SSLH")"
msg -bar
fun_bar 'fun_instsslh'
msg -bar
msg -ne "\033[1;31m [ ! ] \033[1;33m$(fun_trans "INICIANDO O SSLH*")"
/etc/init.d/sslh restart  > /dev/null 2>&1
service sslh restart > /dev/null 2>&1
echo -e " \033[1;32m[OK]"
msg -bar
sleep 0.5s
[[ $(netstat -nplt | grep -w 'sslh' | wc -l) != '0' ]] && echo -e " \033[1;32mINSTALADO COM SUCESSO !\033[0m" || echo -e " \033[1;31mERRO INESPERADO !\033[0m"
sleep 3
msg -bar
return 0
} || {
echo -e "\033[1;31mRetornando.."
sleep 2
msg -bar
return 0
}
} || {
msg -azu " $(fun_trans "REMOVER O SSLH MULTIPLEX")"
msg -bar
echo -ne " \033[1;37mDeseja Remover o  SSLH [s/n]: "
read respo
[[ "$respo" = "s" ]] && {
fun_delsslh() {
/etc/init.d/sslh stop && service sslh stop
apt-get remove sslh -y
apt-get purge sslh -y
}
msg -bar
msg -ama " $(fun_trans "REMOVENDO O SSLH")"
msg -bar
fun_bar 'fun_delsslh'
msg -bar
msg -ama " $(fun_trans "REMOVIDO COM SUCESSO")"
msg -bar
return 0
} || {
echo -e "\033[1;31mRetornando.."
sleep 2
msg -bar
return 0
}
}
}
fun_sslh
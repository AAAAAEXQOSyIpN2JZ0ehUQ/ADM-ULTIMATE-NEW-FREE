#!/bin/bash

fun_bar() {
comando[0]="$1"
comando[1]="$2"
(
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} >/dev/null 2>&1
${comando[1]} >/dev/null 2>&1
touch $HOME/fim
) >/dev/null 2>&1 &
tput civis
echo -ne "\033[1;33mAGUARDE \033[1;37m- \033[1;33m["
while true; do
for ((i = 0; i < 18; i++)); do
echo -ne "\033[1;31m#"
sleep 0.1s
done
[[ -e $HOME/fim ]] && rm $HOME/fim && break
echo -e "\033[1;33m]"
sleep 1s
tput cuu1
tput dl1
echo -ne "\033[1;33mAGUARDE \033[1;37m- \033[1;33m["
done
echo -e "\033[1;33m]\033[1;37m -\033[1;32m OK !\033[1;37m"
tput cnorm
}
x="ok"

verif_ptrs() {
porta=$1
PT=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" | grep -v "COMMAND" | grep "LISTEN")
for pton in $(echo -e "$PT" | cut -d: -f2 | cut -d' ' -f1 | uniq); do
svcs=$(echo -e "$PT" | grep -w "$pton" | awk '{print $1}' | uniq)
[[ "$porta" = "$pton" ]] && {
echo -e "\n\033[1;31mPORTA \033[1;33m$porta \033[1;31mEM USO PELO \033[1;37m$svcs\033[0m"
sleep 3
fun_conexao
}
done
}

fun_instsslh() {
[[ -e "/etc/stunnel/stunnel.conf" ]] && ptssl="$(netstat -nplt | grep 'stunnel' | awk {'print $4'} | cut -d: -f2 | xargs)" || ptssl='3128'
[[ -e "/etc/openvpn/server.conf" ]] && ptvpn="$(netstat -nplt | grep 'openvpn' | awk {'print $4'} | cut -d: -f2 | xargs)" || ptvpn='1194'
DEBIAN_FRONTEND=noninteractive apt-get -y install sslh
echo -e "#Modo autónomo\n\nRUN=yes\n\nDAEMON=/usr/sbin/sslh\n\nDAEMON_OPTS='--user sslh --listen 0.0.0.0:3128 --ssh  0.0.0.0:22 --ssl  0.0.0.0:$ptssl --http  0.0.0.0:80 --openvpn 127.0.0.1:$ptvpn --pidfile /var/run/sslh/sslh.pid'" >/etc/default/sslh
/etc/init.d/sslh start && service sslh start
}

fun_delsslh() {
/etc/init.d/sslh stop && service sslh stop
apt-get remove sslh -y
apt-get purge sslh -y
}

fun_sslh() {
[[ "$(netstat -nltp | grep 'sslh' | wc -l)" = '0' ]] && {
clear
echo -e "\E[44;1;37m             INSTALADOR SSLH               \E[0m\n"
echo -e "\n\033[1;33m[\033[1;31m!\033[1;33m] \033[1;32mA PORTA \033[1;37m3128 \033[1;32mSERA USADA POR PADRAO\033[0m\n"
echo -ne "\033[1;32mREALMENTE DESEJA INSTALAR O SSLH \033[1;31m? \033[1;33m[s/n]:\033[1;37m "
read resp
[[ "$resp" = 's' ]] && {
verif_ptrs 3128
echo -e "\n\033[1;32mINSTALANDO O SSLH !\033[0m\n"
fun_bar 'fun_instsslh'
echo -e "\n\033[1;32mINICIANDO O SSLH !\033[0m\n"
fun_bar '/etc/init.d/sslh restart && service sslh restart'
[[ $(netstat -nplt | grep -w 'sslh' | wc -l) != '0' ]] && echo -e "\n\033[1;32mINSTALADO COM SUCESSO !\033[0m" || echo -e "\n\033[1;31mERRO INESPERADO !\033[0m"
sleep 3
menu
} || {
echo -e "\n\033[1;31mRetornando.."
sleep 2
menu
}
} || {
clear
echo -e "\E[41;1;37m             REMOVER O SSLH               \E[0m\n"
echo -ne "\033[1;32mREALMENTE DESEJA REMOVER O SSLH \033[1;31m? \033[1;33m[s/n]:\033[1;37m "
read respo
[[ "$respo" = "s" ]] && {
echo -e "\n\033[1;32mREMOVENDO O SSLH !\033[0m\n"
fun_bar 'fun_delsslh'
echo -e "\n\033[1;32mREMOVIDO COM SUCESSO !\033[0m\n"
sleep 2
menu
} || {
echo -e "\n\033[1;31mRetornando.."
sleep 2
menu
}
}
}
fun_sslh
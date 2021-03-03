#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;32m" [3]="\033[1;36m" [4]="\033[1;31m" )
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
API_TRANS="aHR0cDovL2dpdC5pby90cmFucw=="
SUB_DOM='base64 -d'
wget -O /usr/bin/trans $(echo $API_TRANS|$SUB_DOM) &> /dev/null

mine_port () {
local portasVAR=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
local NOREPEAT
local reQ
local Port
while read port; do
reQ=$(echo ${port}|awk '{print $1}')
Port=$(echo {$port} | awk '{print $9}' | awk -F ":" '{print $2}')
[[ $(echo -e $NOREPEAT|grep -w "$Port") ]] && continue
NOREPEAT+="$Port\n"
case ${reQ} in
apache|apache2)
[[ -z $APC ]] && msg -bar && local APC="\033[1;32mPORTA \033[1;37m"
APC+="$Port ";;
esac
done <<< "${portasVAR}"
[[ ! -z $APC ]] && echo -e $APC
}

port () {
local portas
local portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
i=0
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e ${portas}|grep -w "$var1 $var2")" ]] || {
    portas+="$var1 $var2 $portas"
    echo "$var1 $var2"
    let i++
    }
done <<< "$portas_var"
}
verify_port () {
local SERVICE="$1"
local PORTENTRY="$2"
[[ ! $(echo -e $(port|grep -v ${SERVICE})|grep -w "$PORTENTRY") ]] && return 0 || return 1
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
tput cuu1 && tput dl1
done
echo -e " \033[1;33m[\033[1;31m####################\033[1;33m] - \033[1;32m100%\033[0m"
sleep 1s
}

inst_components () {
msg -bra "$(fun_trans " REINSTALANDO APACHE2")"
fun_bar "apt-get purge apache2 -y"
fun_bar "apt-get install apache2 -y"
msg -bra "$(fun_trans " VERIFICANDO PUERTA") 81"
sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf
service apache2 restart > /dev/null 2>&1 &
sleep 0.5s
msg -bar
msg -ama "$(fun_trans "PROCESSO CONCLUIDO")"
msg -bar
}

edit_apache () {
msg -azu "$(fun_trans "REDEFINIR PORTAS APACHE")"
msg -bar
local CONF="/etc/apache2/ports.conf"
local NEWCONF="$(cat ${CONF})"
msg -ne "$(fun_trans "Novas Porta"): "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port apache "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
msg -bar
exit 1
}
done
rm ${CONF}
while read varline; do
if [[ $(echo ${varline}|grep -w "Listen") ]]; then
 if [[ -z ${END} ]]; then
 echo -e "Listen ${newports}" >> ${CONF}
 END="True"
 else
 echo -e "${varline}" >> ${CONF}
 fi
else
echo -e "${varline}" >> ${CONF}
fi
done <<< "${NEWCONF}"
msg -azu "$(fun_trans "AGUARDE")"
service apache2 restart &>/dev/null
sleep 1s
msg -bar
msg -azu "$(fun_trans "PORTAS REDEFINIDAS")"
msg -bar
}

apache2_restart () {
[[ -e /etc/apache2/ports.conff ]] && inst_components && return 0
msg -ama " $(fun_trans "Apache2 Nao Encontrado")"
fun_bar "service apache2 start" "service apache2 restart"
sleep 0.5s
msg -bar
msg -ama "$(fun_trans "PROCESSO CONCLUIDO")"
msg -bar
}

apache2_stop () {
[[ -e /etc/apache2/ports.conff ]] && inst_components && return 0
msg -ama " $(fun_trans "Apache2 Nao Encontrado")"
msg -bar
fun_bar "service apache2 stop"
apt-get purge apache2 -y &>/dev/null
sleep 0.5s
msg -bar
msg -ama "$(fun_trans "PROCESSO CONCLUIDO")"
msg -bar
}

fun_apache2 () {
unset OPENBAR
[[ -e /etc/apache2/ports.conf ]] && OPENBAR="\033[1;32mOnline" || OPENBAR="\033[1;31mOffline"
msg -ama "$(fun_trans "MENU") APACHE_2"
#msg -bar
mine_port
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "Voltar")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "Reinstalar") APACHE_2 $OPENBAR"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "Alterar porta") APACHE_2"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "Iniciar/Reiniciar") APACHE_2"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "Parar") APACHE_2"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-4]) ]]; do
read -p "[0-4]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)inst_components;;
2)edit_apache;;
3)apache2_restart;;
4)apache2_stop;;
esac
}
fun_apache2
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
tput cuu1
tput dl1
done
echo -e " \033[1;33m[\033[1;31m####################\033[1;33m] - \033[1;32m100%\033[0m"
sleep 1s
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

apache2_restart () {
msg -ama " $(fun_trans "INSTALANDO APACHE")"
msg -bar
fun_bar "apt-get install apache2 -y"
sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf
msg -bar
sleep 2s
msg -ne "\033[1;31m [ ! ] \033[1;33m$(fun_trans "REINICIANDO SERVICOS")"
service apache2 start > /dev/null 2>&1
service apache2 restart > /dev/null 2>&1 &
echo -e " \033[1;32m[OK]"
msg -bar
echo -e " \033[1;33m$(fun_trans "APACHE2 PORTA 81 POR PADRAO ")"
msg -bar
sleep 0.5s
msg -ama " $(fun_trans "Sucesso Procedimento Feito")"
msg -bar
}

remover_apache2 () {
msg -ama " $(fun_trans "DESINTALANDO APACHE")"
msg -bar
/etc/init.d/apache2 stop > /dev/null 2>&1
fun_bar "sleep 3s"
apt-get purge apache2 -y &>/dev/null
msg -bar
msg -ama " $(fun_trans "Apache removido Com Sucesso!")"
[[ -d /etc/apache2 ]] && rm -rf /etc/apache2
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

fun_iniciastop () {
if [[ ! -e /etc/apache2/apache_stop ]]; then
echo -e "\033[1;36mPARANDO APACHE"
msg -bar
fun_bar "service apache2 stop"
service apache2 stop > /dev/null 2>&1
echo "#STOP" > /etc/apache2/apache_stop
msg -bar
echo -e "\033[1;33mAPACHE PARADO COM SUCESSO"
msg -bar
exit 1
fi
echo -e "\033[1;36mINICIANDO APACHE"
msg -bar
fun_bar "service apache2 start"
service apache2 restart > /dev/null 2>&1
rm -rf /etc/apache2/apache_stop
msg -bar
echo -e "\033[1;33mAPACHE ACTIVADO COM SUCESSO"
msg -bar
}

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
[[ -z $APC ]] && msg -bar && local APC="\033[1;32m $(fun_trans "PORTA") \033[1;37m"
APC+="$Port ";;
esac
done <<< "${portasVAR}"
[[ ! -z $APC ]] && echo -e $APC
}

fun_apache2 () {
if [[ ! -e /etc/apache2/ports.conf ]]; then
apache2_restart
exit 1
fi
unset OPENBAR
[[ $(port|grep -w "apache2") ]] && OPENBAR="\033[1;32mOnline" || OPENBAR="\033[1;31mOffline"
msg -ama "$(fun_trans "MENU APACHE")"
mine_port
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR ")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "DESINTALAR APACHE")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "REDEFINIR PORTA APACHE")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "Editar Cliente APACHE") \033[1;31m(comand nano)"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "Iniciar ou Parar  APACHE2") $OPENBAR"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-4]) ]]; do
read -p "[0-4]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)remover_apache2;;
2)edit_apache;;
3)
   nano /etc/apache2/ports.conf
   return 0;;
4)fun_iniciastop;;
esac
}
fun_apache2
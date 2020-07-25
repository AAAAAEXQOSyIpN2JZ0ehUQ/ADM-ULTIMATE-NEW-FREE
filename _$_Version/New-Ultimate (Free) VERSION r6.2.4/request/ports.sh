#!/bin/bash
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
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
squid|squid3)
[[ -z $SQD ]] && local SQD="\033[1;32m SERVICO\033[1;31m SQUID\033[1;32m PORTA \033[1;37m"
SQD+="$Port ";;
apache|apache2)
[[ -z $APC ]] && local APC="\033[1;32m SERVICO\033[1;31m APACHE\033[1;32m PORTA \033[1;37m"
APC+="$Port ";;
ssh|sshd)
[[ -z $SSH ]] && local SSH="\033[1;32m SERVICO\033[1;31m SSH\033[1;32m PORTA \033[1;37m"
SSH+="$Port ";;
dropbear)
[[ -z $DPB ]] && local DPB="\033[1;32m SERVICO\033[1;31m DROPBEAR\033[1;32m PORTA \033[1;37m"
DPB+="$Port ";;
ssserver)
[[ -z $SSV ]] && local SSV="\033[1;32m SERVICO\033[1;31m SHADOWSOCKS\033[1;32m PORTA \033[1;37m"
SSV+="$Port ";;
openvpn)
[[ -z $OVPN ]] && local OVPN="\033[1;32m SERVICO\033[1;31m OPENVPN\033[1;32m PORTA \033[1;37m"
OVPN+="$Port ";;
stunnel4|stunnel)
[[ -z $SSL ]] && local SSL="\033[1;32m SERVICO\033[1;31m SSL\033[1;32m PORTA \033[1;37m"
SSL+="$Port ";;
python|python3)
[[ -z $PY3 ]] && local PY3="\033[1;32m SERVICO\033[1;31m SOCKS\033[1;32m PORTA \033[1;37m"
PY3+="$Port ";;
esac
done <<< "${portasVAR}"
[[ ! -z $SQD ]] && echo -e $SQD
[[ ! -z $APC ]] && echo -e $APC
[[ ! -z $SSH ]] && echo -e $SSH
[[ ! -z $DPB ]] && echo -e $DPB
[[ ! -z $OVPN ]] && echo -e $OVPN
[[ ! -z $PY3 ]] && echo -e $PY3
[[ ! -z $SSL ]] && echo -e $SSL
[[ ! -z $SSV ]] && echo -e $SSV
}

echo -e "\033[1;33m $(fun_trans "Portas") \033[1;32m[NEW-ADM]"
msg -bar
mine_port
msg -bar

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
edit_squid () {
msg -azu "$(fun_trans "REDEFINIR PORTAS SQUID")"
msg -bar
if [[ -e /etc/squid/squid.conf ]]; then
local CONF="/etc/squid/squid.conf"
elif [[ -e /etc/squid3/squid.conf ]]; then
local CONF="/etc/squid3/squid.conf"
fi
NEWCONF="$(cat ${CONF}|grep -v "http_port")"
msg -ne "$(fun_trans "Novas Portas"): "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port squid "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
msg -bar
exit 1
}
done
rm ${CONF}
while read varline; do
echo -e "${varline}" >> ${CONF}
 if [[ "${varline}" = "#portas" ]]; then
  for NPT in $(echo ${newports}); do
  echo -e "http_port ${NPT}" >> ${CONF}
  done
 fi
done <<< "${NEWCONF}"
msg -azu "$(fun_trans "AGUARDE")"
service squid restart &>/dev/null
service squid3 restart &>/dev/null
sleep 1s
msg -bar
msg -azu "$(fun_trans "PORTAS REDEFINIDAS")"
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
edit_openvpn () {
msg -azu "$(fun_trans "REDEFINIR PORTAS OPENVPN")"
msg -bar
local CONF="/etc/openvpn/server.conf"
local CONF2="/etc/openvpn/client-common.txt"
local NEWCONF="$(cat ${CONF}|grep -v [Pp]ort)"
local NEWCONF2="$(cat ${CONF2})"
msg -ne "$(fun_trans "Nova Porta"): "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port openvpn "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
msg -bar
exit 1
}
done
rm ${CONF}
while read varline; do
echo -e "${varline}" >> ${CONF}
if [[ ${varline} = "proto tcp" ]]; then
echo -e "port ${newports}" >> ${CONF}
fi
done <<< "${NEWCONF}"
rm ${CONF2}
while read varline; do
if [[ $(echo ${varline}|grep -v "remote-random"|grep "remote") ]]; then
echo -e "$(echo ${varline}|cut -d' ' -f1,2) ${newports} $(echo ${varline}|cut -d' ' -f4)" >> ${CONF2}
else
echo -e "${varline}" >> ${CONF2}
fi
done <<< "${NEWCONF2}"
msg -azu "$(fun_trans "AGUARDE")"
service openvpn restart &>/dev/null
/etc/init.d/openvpn restart &>/dev/null
sleep 1s
msg -bar
msg -azu "$(fun_trans "PORTAS REDEFINIDAS")"
msg -bar
}
edit_dropbear () {
msg -azu "$(fun_trans "REDEFINIR PORTAS DROPBEAR")"
msg -bar
local CONF="/etc/default/dropbear"
local NEWCONF="$(cat ${CONF}|grep -v "DROPBEAR_EXTRA_ARGS")"
msg -ne "$(fun_trans "Novas Portas"): "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port dropbear "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
msg -bar
exit 1
}
done
rm ${CONF}
while read varline; do
echo -e "${varline}" >> ${CONF}
 if [[ ${varline} = "NO_START=0" ]]; then
 echo -e 'DROPBEAR_EXTRA_ARGS="VAR"' >> ${CONF}
 for NPT in $(echo ${newports}); do
 sed -i "s/VAR/-p ${NPT} VAR/g" ${CONF}
 done
 sed -i "s/VAR//g" ${CONF}
 fi
done <<< "${NEWCONF}"
msg -azu "$(fun_trans "AGUARDE")"
service dropbear restart &>/dev/null
sleep 1s
msg -bar
msg -azu "$(fun_trans "PORTAS REDEFINIDAS")"
msg -bar
}
edit_openssh () {
msg -azu "$(fun_trans "REDEFINIR PORTAS OPENSSH")"
msg -bar
local CONF="/etc/ssh/sshd_config"
local NEWCONF="$(cat ${CONF}|grep -v [Pp]ort)"
msg -ne "$(fun_trans "Novas Portas"): "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port sshd "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
msg -bar
exit 1
}
done
rm ${CONF}
for NPT in $(echo ${newports}); do
echo -e "Port ${NPT}" >> ${CONF}
done
while read varline; do
echo -e "${varline}" >> ${CONF}
done <<< "${NEWCONF}"
msg -azu "$(fun_trans "AGUARDE")"
service ssh restart &>/dev/null
service sshd restart &>/dev/null
sleep 1s
msg -bar
msg -azu "$(fun_trans "PORTAS REDEFINIDAS")"
msg -bar
}
main_fun () {
unset newports
i=0
while read line; do
let i++
          case $line in
          squid|squid3)squid=$i;; 
          apache|apache2)apache=$i;; 
          openvpn)openvpn=$i;; 
          dropbear)dropbear=$i;; 
          sshd)ssh=$i;; 
          esac
done <<< "$(port|cut -d' ' -f1|sort -u)"
for((a=1; a<=$i; a++)); do
[[ $squid = $a ]] && echo -ne "\033[1;32m [$squid] > " && msg -azu "$(fun_trans "REDEFINIR PORTAS SQUID")"
[[ $apache = $a ]] && echo -ne "\033[1;32m [$apache] > " && msg -azu "$(fun_trans "REDEFINIR PORTA APACHE")"
[[ $openvpn = $a ]] && echo -ne "\033[1;32m [$openvpn] > " && msg -azu "$(fun_trans "REDEFINIR PORTA OPENVPN")"
[[ $dropbear = $a ]] && echo -ne "\033[1;32m [$dropbear] > " && msg -azu "$(fun_trans "REDEFINIR PORTAS DROPBEAR")"
[[ $ssh = $a ]] && echo -ne "\033[1;32m [$ssh] > " && msg -azu "$(fun_trans "REDEFINIR PORTAS SSH")"
done
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
msg -bar
while true; do
echo -ne "\033[1;37m$(fun_trans "Selecione"): " && read selection
tput cuu1 && tput dl1
[[ ! -z $squid ]] && [[ $squid = $selection ]] && edit_squid && break
[[ ! -z $apache ]] && [[ $apache = $selection ]] && edit_apache && break
[[ ! -z $openvpn ]] && [[ $openvpn = $selection ]] && edit_openvpn && break
[[ ! -z $dropbear ]] && [[ $dropbear = $selection ]] && edit_dropbear && break
[[ ! -z $ssh ]] && [[ $ssh = $selection ]] && edit_openssh && break
[[ "0" = $selection ]] && break
done
#exit 0
}
main_fun
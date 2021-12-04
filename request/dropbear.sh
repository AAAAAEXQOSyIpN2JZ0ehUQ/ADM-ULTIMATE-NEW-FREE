#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
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
fun_eth () {
eth=$(ifconfig | grep -v inet6 | grep -v lo | grep -v 127.0.0.1 | grep "encap:Ethernet" | awk '{print $1}')
    [[ $eth != "" ]] && {
    msg -bar
    msg -ama " $(fun_trans "Aplicar Sistema Para Melhorar Pacotes Ssh?")"
    msg -ama " $(fun_trans "Opcao Para Usuarios Avancados")"
    msg -bar
    read -p " [S/N]: " -e -i n sshsn
	tput cuu1 && tput dl1
           [[ "$sshsn" = @(s|S|y|Y) ]] && {
           echo -e "${cor[1]} $(fun_trans "Correcao de problemas de pacotes no SSH...")"
           echo -e " $(fun_trans "Qual A Taxa RX")"
           echo -ne "[ 1 - 999999999 ]: "; read rx
           [[ "$rx" = "" ]] && rx="999999999"
           echo -e " $(fun_trans "Qual A Taxa TX")"
           echo -ne "[ 1 - 999999999 ]: "; read tx
           [[ "$tx" = "" ]] && tx="999999999"
           apt-get install ethtool -y > /dev/null 2>&1
           ethtool -G $eth rx $rx tx $tx > /dev/null 2>&1
           msg -bar
           }
     }
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
fun_dropbear () {
 [[ -e /etc/default/dropbear ]] && {
 echo -e "\033[1;32m $(fun_trans "REMOVENDO DROPBEAR*")"
msg -bar
 service dropbear stop > /dev/null 2>&1
 fun_bar "apt-get remove dropbear -y"
 msg -bar
 echo -e "\033[1;32m $(fun_trans "Dropbear Removido")!"
 msg -bar
 [[ -e /etc/default/dropbear ]] && rm /etc/default/dropbear
 return 0
 }
echo -e "\033[1;32m $(fun_trans "INSTALADOR DROPBEAR*")ADM-ULTIMATE"
msg -bar
echo -e "\033[1;31m $(fun_trans "Selecione Portas Validas em Ordem Sequencial")"
echo -e "\033[1;31m $(fun_trans "Exemplo"):\033[1;32m 22 80 81 82 85 90\033[1;37m"
msg -bar
echo -ne "\033[1;31m $(fun_trans "Digite a Porta"): \033[1;37m" && read DPORT
tput cuu1 && tput dl1
TTOTAL=($DPORT)
    for((i=0; i<${#TTOTAL[@]}; i++)); do
        [[ $(mportas|grep "${TTOTAL[$i]}") = "" ]] && {
        echo -e "\033[1;33m $(fun_trans "Porta Escolhida:")\033[1;32m ${TTOTAL[$i]} OK"
        PORT="$PORT ${TTOTAL[$i]}"
        } || {
        echo -e "\033[1;33m $(fun_trans "Porta Escolhida:")\033[1;31m ${TTOTAL[$i]} FAIL"
        }
   done
  [[  -z $PORT ]] && {
  msg -bar
  echo -e "\033[1;31m $(fun_trans "Nenhuma Porta Valida Foi Escolhida")\033[0m"
  msg -bar
  return 1
  }
sysvar=$(cat -n /etc/issue |grep 1 |cut -d' ' -f6,7,8 |sed 's/1//' |sed 's/      //' | grep -o Ubuntu)
[[ ! $(cat /etc/shells|grep "/bin/false") ]] && echo -e "/bin/false" >> /etc/shells
[[ "$sysvar" != "" ]] && {
echo -e "Port 22
Protocol 2
KeyRegenerationInterval 3600
ServerKeyBits 1024
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin yes
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
PermitTunnel yes
ChallengeResponseAuthentication no
PasswordAuthentication yes
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
#UseLogin no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes" > /etc/ssh/sshd_config
msg -bar
echo -e "${cor[2]} $(fun_trans "Instalando dropbear")"
msg -bar
fun_bar "apt-get install dropbear -y"
msg -bar
touch /etc/dropbear/banner
echo -e "${cor[2]} $(fun_trans "Configurando dropbear")"
cat <<EOF > /etc/default/dropbear
NO_START=0
DROPBEAR_EXTRA_ARGS="VAR"
DROPBEAR_BANNER="/etc/dropbear/banner"
DROPBEAR_RECEIVE_WINDOW=65536
EOF
for dpts in $(echo $PORT); do
sed -i "s/VAR/-p $dpts VAR/g" /etc/default/dropbear
done
sed -i "s/VAR//g" /etc/default/dropbear
} || {
echo -e "Port 22
Protocol 2
KeyRegenerationInterval 3600
ServerKeyBits 1024
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin yes
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
PermitTunnel yes
ChallengeResponseAuthentication no
PasswordAuthentication yes
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
#UseLogin no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes" > /etc/ssh/sshd_config
msg -bar
echo -e "\033[1;31m $(fun_trans "Instalando dropbear")"
msg -bar
fun_bar "apt-get install dropbear -y"
touch /etc/dropbear/banner
msg -bar
echo -e "\033[1;31m $(fun_trans "Configurando dropbear")"
cat <<EOF > /etc/default/dropbear
NO_START=0
DROPBEAR_EXTRA_ARGS="VAR"
DROPBEAR_BANNER="/etc/dropbear/banner"
DROPBEAR_RECEIVE_WINDOW=65536
EOF
for dpts in $(echo $PORT); do
sed -i "s/VAR/-p $dpts VAR/g" /etc/default/dropbear
done
sed -i "s/VAR//g" /etc/default/dropbear
}
fun_eth
service ssh restart > /dev/null 2>&1
service dropbear restart > /dev/null 2>&1
echo -e "\033[1;33m $(fun_trans "Seu dropbear foi configurado com sucesso")"
msg -bar
#UFW
for ufww in $(mportas|awk '{print $2}'); do
ufw allow $ufww > /dev/null 2>&1
done
}

edit_dropbear () {
echo -e "\033[1;31m $(fun_trans "Selecione Portas Validas em Ordem Sequencial")"
echo -e "\033[1;31m $(fun_trans "Exemplo"):\033[1;32m 22 80 81 82 85 90\033[1;37m"
msg -bar
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
dropbear)
[[ -z $DPB ]] && msg -bar && local DPB="\033[1;32m $(fun_trans "PORTA") \033[1;37m"
DPB+="$Port ";;
esac
done <<< "${portasVAR}"
[[ ! -z $DPB ]] && echo -e $DPB
}

online_dropbear () {
msg -azu " $(fun_trans "CONFIGURAÇÃO DE DROPBEAR*")"
mine_port
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "Voltar")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "Editar Cliente DROPBEAR") \033[1;31m(comand nano)"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "REDEFINIR PORTAS DROPBEAR")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "Desinstalar o dropbear")"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-3]) ]]; do
read -p "[0-3]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)
   nano /etc/default/dropbear
   return 0;;
2)edit_dropbear;;
3)fun_dropbear;;
esac
}
if [[ -e /etc/default/dropbear ]]; then
online_dropbear
else
fun_dropbear
fi
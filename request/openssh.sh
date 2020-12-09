#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
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
IP="$(meu_ip)"
fun_ssh () {
sshvar=$(cat /etc/ssh/sshd_config | grep -v "Port $1")
echo "$sshvar" > /etc/ssh/sshd_config
sed -i "s;Port 22;Port 22\nPort $1;g" /etc/ssh/sshd_config
sed -i "s;PermitRootLogin prohibit-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PermitRootLogin without-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PasswordAuthentication no;PasswordAuthentication yes;g" /etc/ssh/sshd_config
service ssh restart > /dev/null 2>&1 &
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
openssh () {
msg -verd " $(fun_trans "OPENSSH AUTO-CONFIGURAÇAO ADM-ULTIMATE")"
msg -bar
fun_ip
msg -ne " $(fun_trans "Confirme seu ip")"; read -p ": " -e -i $IP ip
msg -bar
msg -bra " $(fun_trans "INICIANDO AUTO-CONFIGURAÇAO PORTA 22 ")"
msg -bar
fun_bar "apt-get update -y" "apt-get upgrade -y"
service ssh restart > /dev/null 2>&1
cp /etc/ssh/sshd_config /etc/ssh/sshd_back
fun_ssh
fun_eth
msg -bra " $(fun_trans "REINICIANDO SERVIÇOS")"
service ssh restart > /dev/null 2>&1
msg -bar
msg -ama " $(fun_trans "SSH CONFIGURADO COM SUCESSO")"
msg -bar
return 0
}
openssh
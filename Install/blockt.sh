#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

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
IP="$(cat /etc/MEUIPADM)"
arq="/etc/Plus-torrent"

fun_fireoff () {
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t mangle -F
iptables -t mangle -X
iptables -t nat -F
iptables -t nat -X
iptables -t filter -F
iptables -t filter -X
iptables -F
iptables -X
rm $arq
sleep 3
}

fun_fireon () {
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
[[ $(iptables -h|wc -l) -lt 5 ]] && apt-get install iptables -y > /dev/null 2>-1
NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
echo 'iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t filter -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT' > $arq
echo 'iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT' >> $arq
echo 'iptables -A OUTPUT -p tcp --dport 67 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 67 -m state --state NEW -j ACCEPT' >> $arq
list_ips=$(mportas|awk '{print $2}')
while read PORT; do
echo "iptables -A INPUT -p tcp --dport $PORT -j ACCEPT
iptables -A INPUT -p udp --dport $PORT -j ACCEPT
iptables -A OUTPUT -p tcp --dport $PORT -j ACCEPT
iptables -A OUTPUT -p udp --dport $PORT -j ACCEPT
iptables -A FORWARD -p tcp --dport $PORT -j ACCEPT
iptables -A FORWARD -p udp --dport $PORT -j ACCEPT
iptables -A OUTPUT -p tcp -d $IP --dport $PORT -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp -d $IP --dport $PORT -m state --state NEW -j ACCEPT" >> $arq
done <<< "$list_ips"
echo 'iptables -A INPUT -p icmp --icmp-type echo-request -j DROP' >> $arq
echo 'iptables -A INPUT -p tcp --dport 10000 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 10000 -j ACCEPT' >> $arq
echo "iptables -t nat -A PREROUTING -i $NIC -p tcp --dport 6881:6889 -j DNAT --to-dest $IP
iptables -A FORWARD -p tcp -i $NIC --dport 6881:6889 -d $IP -j REJECT
iptables -A OUTPUT -p tcp --dport 6881:6889 -j DROP
iptables -A OUTPUT -p udp --dport 6881:6889 -j DROP" >> $arq
echo 'iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP' >> $arq
sleep 2
chmod +x $arq
/etc/Plus-torrent > /dev/null
}

block_torrent () {
msg -azu " $(fun_trans "REGRAS FIREWALL")"
msg -bar
msg -ama " $(fun_trans "Funcao Beta Ultilize Por Sua Conta Em Risco ")"
msg -ama " $(fun_trans "Deseja Aplicar Regras Firewall ")"
msg -bar
read -p "$(echo -e " Prosseguir? [N/S]:") " -e -i s resp
[[ $resp = @(n|N) ]] && msg -bar && return 0
msg -bar
fun_ip
msg -ne " $(fun_trans "Confirme seu ip")"; read -p ": " -e -i $IP ip
msg -bar
msg -ama " $(fun_trans "APLICANDO FIREWALL ")"
msg -bar
fun_bar "fun_fireon"
msg -bar
msg -ama " $(fun_trans "BLOQUEIO TORRENT APLICADO")"
msg -bar
msg -ne "\033[1;31m [ ! ] \033[1;33m$(fun_trans "REINICIANDO SERVICOS*")"
service ssh restart > /dev/null 2>&1
service sshd restart > /dev/null 2>&1
echo -e " \033[1;32m[OK]"
msg -bar
msg -ama " $(fun_trans "Seu Firewall foi Aplicado com sucesso")"
echo "#Plus-torrent ON" > /etc/torrent-on
msg -bar
return 0
}
remove_torrent () {
msg -azu " $(fun_trans "REMOVENDO REGRAS FIREWALL")"
msg -bar
fun_bar "fun_fireoff"
msg -bar
msg -ama " $(fun_trans "BLOQUEIO TORRENT LIBERADO")"
msg -bar
msg -ne "\033[1;31m [ ! ] \033[1;33m$(fun_trans "REINICIANDO SERVICOS*")"
service ssh restart > /dev/null 2>&1
service sshd restart > /dev/null 2>&1
echo -e " \033[1;32m[OK]"
msg -bar
msg -verd " $(fun_trans "Reinicie o Sistema Pra Concluir") (reboot)"
msg -bar
msg -ama " $(fun_trans "Seu Firewall foi Removido com sucesso")"
rm -rf /etc/torrent-admon
msg -bar
return 0
}
if [[ -e /etc/Plus-torrent ]]; then
remove_torrent
else
block_torrent
fi
#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
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
TCPspeed () {
if [[ `grep -c "^#ADM" /etc/sysctl.conf` -eq 0 ]]; then
#INSTALA
msg -ama "$(fun_trans "TCP Speed Nao Ativado, Deseja Ativar Agora")?"
msg -bar
while [[ ${resposta} != @(s|S|n|N|y|Y) ]]; do
read -p " [S/N]: " -e -i s resposta
tput cuu1 && tput dl1
done
[[ "$resposta" = @(s|S|y|Y) ]] && {
echo "#ADM" >> /etc/sysctl.conf
echo "net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 16384 16777216
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf > /dev/null 2>&1
msg -ama "$(fun_trans "TCP Ativo Com Sucesso")!"
} || msg -ama "$(fun_trans "Cancelado")!"
 else
#REMOVE
msg -ama "$(fun_trans "TCP Speed ja Ativado, Deseja Parar Agora")?"
msg -bar
while [[ ${resposta} != @(s|S|n|N|y|Y) ]]; do
read -p " [S/N]: " -e -i s resposta
tput cuu1 && tput dl1
done
[[ "$resposta" = @(s|S|y|Y) ]] && {
grep -v "^#ADM
net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 16384 16777216
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_slow_start_after_idle = 0" /etc/sysctl.conf > /tmp/syscl && mv -f /tmp/syscl /etc/sysctl.conf
sysctl -p /etc/sysctl.conf > /dev/null 2>&1
msg -ama "$(fun_trans "TCP Parado Com Sucesso")!"
} || msg -ama "$(fun_trans "Cancelado")!"
fi
}
block_torrent () {
 arq="/etc/torrent-adm"
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
 [[ -e /etc/torrent-adm ]] && {
 echo -e "\033[1;33m $(fun_trans "REMOVENDO TORRENT*")"
 msg -bar
 service ssh restart > /dev/null 2>&1
 service sshd restart > /dev/null 2>&1
 fun_bar "fun_fireoff"
 msg -bar
 echo -e "\033[1;32m $(fun_trans "Reinicie o Sistema Pra Concluir") (reboot)"
 msg -bar
 echo -e "\033[1;33m $(fun_trans "Seu Torrent foi Removido com sucesso")!"
 # msg -bar
 [[ -e /etc/torrent-adm ]] && rm /etc/torrent-adm
 return 0
 }
arq="/etc/torrent-adm"
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
[[ $(iptables -h|wc -l) -lt 5 ]] && apt-get install iptables -y > /dev/null 2>-1
NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
msg -ama "$(fun_trans "Essas configuracoes so Devem ser adicionadas")"
msg -ama "$(fun_trans "apos a vps estar totalmente configurada!")"
msg -bar
echo -e "$(fun_trans "Deseja Prosseguir?")"
read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
fun_ip #Pega IP e armazena em uma variavel
msg -bar
fun_bar "service ssh restart"
#Inicia Procedimentos
#Parametros iniciais
echo 'iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t filter -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT' > $arq
#libera DNS
echo 'iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT' >> $arq
#Liberar DHCP
echo 'iptables -A OUTPUT -p tcp --dport 67 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 67 -m state --state NEW -j ACCEPT' >> $arq
#Liberando Serviços Ativos
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
#Bloqueando Ping
echo 'iptables -A INPUT -p icmp --icmp-type echo-request -j DROP' >> $arq
#Liberar WEBMIN
echo 'iptables -A INPUT -p tcp --dport 10000 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 10000 -j ACCEPT' >> $arq
#Bloqueando torrent
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
/etc/torrent-adm > /dev/null
#ServiceInicia
service ssh restart > /dev/null 2>&1
service sshd restart > /dev/null 2>&1
msg -bar
msg -ama " $(fun_trans "Seu Torrent foi Aplicado com sucesso")"
}

on="\033[1;32mon" && off="\033[1;31moff"
[[ `grep -c "^#ADM" /etc/sysctl.conf` -eq 0 ]] && tcp=$off || tcp=$on
[[ -e /etc/torrent-adm ]] && torrent=$(echo -e "\033[1;32mon ") || torrent=$(echo -e "\033[1;31moff ")
msg -ama "$(fun_trans "MENU DE UTILITARIOS")"
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "TCPSPEED") $tcp"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "TORRENT") $torrent"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-2]) ]]; do
read -p "[0-2]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
1)TCPspeed;;
2)block_torrent;;
0)exit;;
esac
msg -bar
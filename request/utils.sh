#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
BadVPN () {
pid_badvpn=$(ps x | grep badvpn | grep -v grep | awk '{print $1}')
if [ "$pid_badvpn" = "" ]; then
    msg -ama "$(fun_trans "Liberando Badvpn")"
    msg -bar
    if [[ ! -e /bin/badvpn-udpgw ]]; then
    wget -O /bin/badvpn-udpgw https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/badvpn-udpgw &>/dev/null
    chmod 777 /bin/badvpn-udpgw
    fi
    screen -dmS screen /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10
    [[ "$(ps x | grep badvpn | grep -v grep | awk '{print $1}')" ]] && msg -ama "$(fun_trans "Sucesso")" || msg -ama "$(fun_trans "Falhou")"
else
    msg -ama "$(fun_trans "Parando Badvpn")"
    msg -bar
    kill -9 $(ps x | grep badvpn | grep -v grep | awk '{print $1'}) > /dev/null 2>&1
    killall badvpn-udpgw > /dev/null 2>&1
    [[ ! "$(ps x | grep badvpn | grep -v grep | awk '{print $1}')" ]] && msg -ama "$(fun_trans "Sucesso")" || msg -ama "$(fun_trans "Falhou")"
    unset pid_badvpn
    fi
unset pid_badvpn
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
SquidCACHE () {
msg -ama "$(fun_trans "Squid Cache, Aplica cache no squid")"
msg -ama "$(fun_trans "melhora a velocidade do squid")"
msg -bar
if [ -e /etc/squid/squid.conf ]; then
squid_var="/etc/squid/squid.conf"
elif [ -e /etc/squid3/squid.conf ]; then
squid_var="/etc/squid3/squid.conf"
else
msg -ama "$(fun_trans "Seu sistema nao possui um squid")!" && return 1
fi
teste_cache="#CACHE DO SQUID"
if [[ `grep -c "^$teste_cache" $squid_var` -gt 0 ]]; then
  [[ -e ${squid_var}.bakk ]] && {
  msg -ama "$(fun_trans "Cache squid identificado, removendo")!"
  mv -f ${squid_var}.bakk $squid_var
  msg -ama "$(fun_trans "cache squid removido")!"
  service squid restart > /dev/null 2>&1 &
  service squid3 restart > /dev/null 2>&1 &
  return 0
  }
fi
msg -ama "$(fun_trans "Aplicando Cache Squid")!"
msg -bar
_tmp="#CACHE DO SQUID\ncache_mem 200 MB\nmaximum_object_size_in_memory 32 KB\nmaximum_object_size 1024 MB\nminimum_object_size 0 KB\ncache_swap_low 90\ncache_swap_high 95"
[[ "$squid_var" = "/etc/squid/squid.conf" ]] && _tmp+="\ncache_dir ufs /var/spool/squid 100 16 256\naccess_log /var/log/squid/access.log squid" || _tmp+="\ncache_dir ufs /var/spool/squid3 100 16 256\naccess_log /var/log/squid3/access.log squid"
while read s_squid; do
[[ "$s_squid" != "cache deny all" ]] && _tmp+="\n${s_squid}"
done < $squid_var
cp ${squid_var} ${squid_var}.bakk
echo -e "${_tmp}" > $squid_var
msg -ama "$(fun_trans "Cache Aplicado Com Sucesso")!"
service squid restart > /dev/null 2>&1 &
service squid3 restart > /dev/null 2>&1 &
}
block_torrent () {
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
echo -e "$(fun_trans "Essas configuracoes so Devem ser adicionadas")"
echo -e "$(fun_trans "apos a vps estar totalmente configurada!")"
msg -bar
echo -e "$(fun_trans "Deseja Prosseguir?")"
read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
fun_ip #Pega IP e armazena em uma variavel
#Inicia Procedimentos
#Parametros iniciais
echo 'iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t filter -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT' > ./torrent-adm
chmod +x ./torrent-adm
#libera DNS
echo 'iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT' >> ./torrent-adm
#Liberar DHCP
echo 'iptables -A OUTPUT -p tcp --dport 67 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 67 -m state --state NEW -j ACCEPT' >> ./torrent-adm
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
iptables -A OUTPUT -p udp -d $IP --dport $PORT -m state --state NEW -j ACCEPT" >> ./torrent-adm
done <<< "$list_ips"
#Bloqueando Ping
echo 'iptables -A INPUT -p icmp --icmp-type echo-request -j DROP' >> ./torrent-adm
#Liberar WEBMIN
echo 'iptables -A INPUT -p tcp --dport 10000 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 10000 -j ACCEPT' >> ./torrent-adm
#Bloqueando torrent
echo "iptables -t nat -A PREROUTING -i $NIC -p tcp --dport 6881:6889 -j DNAT --to-dest $IP
iptables -A FORWARD -p tcp -i $NIC --dport 6881:6889 -d $IP -j REJECT
iptables -A OUTPUT -p tcp --dport 6881:6889 -j DROP
iptables -A OUTPUT -p udp --dport 6881:6889 -j DROP" >> ./torrent-adm
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
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP' >> ./torrent-adm
./torrent-adm
echo "#TORRENT-ON" > /etc/torrent-on
msg -bar
echo -e " $(fun_trans "Aplicado!")"
}
on="\033[1;32mon" && off="\033[1;31moff"
[[ $(ps x | grep badvpn | grep -v grep | awk '{print $1}') ]] && badvpn=$on || badvpn=$off
[[ `grep -c "^#ADM" /etc/sysctl.conf` -eq 0 ]] && tcp=$off || tcp=$on
[[ -e /etc/torrent-on ]] && torrent=$(echo -e "\033[1;32mon ") || torrent=$(echo -e "\033[1;31moff ")
if [ -e /etc/squid/squid.conf ]; then
[[ `grep -c "^#CACHE DO SQUID" /etc/squid/squid.conf` -gt 0 ]] && squid=$on || squid=$off
elif [ -e /etc/squid3/squid.conf ]; then
[[ `grep -c "^#CACHE DO SQUID" /etc/squid3/squid.conf` -gt 0 ]] && squid=$on || squid=$off
fi
msg -ama "$(fun_trans "MENU DE UTILITARIOS")"
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "BADVPN") $badvpn"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "TCPSPEED") $tcp"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "CACHE DO SQUID") $squid"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "TORRENT") $torrent"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-4]) ]]; do
read -p "[0-4]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
1)BadVPN;;
2)TCPspeed;;
3)SquidCACHE;;
4)block_torrent;;
0)exit;;
esac
msg -bar
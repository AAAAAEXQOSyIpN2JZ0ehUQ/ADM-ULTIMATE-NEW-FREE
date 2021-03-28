#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;32m" [3]="\033[1;36m" [4]="\033[1;31m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
jaillocal="/etc/fail2ban/jail.local"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
serv_sshd=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN" | grep "sshd")
serv_squid=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN" | grep "squid")
serv_dropbear=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN" | grep "dropbear")
serv_apache=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN" | grep "apache")
fun_trans () { 
local texto
local retorno
declare -A texto
SCPidioma="${SCPdir}/idioma"
[[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
local LINGUAGE=$(cat ${SCPidioma})
[[ -z $LINGUAGE ]] && LINGUAGE=pt
[[ ! -e /etc/texto-adm ]] && touch /etc/texto-adm
source /etc/texto-adm
if [[ -z "$(echo ${texto[$@]})" ]]; then
 retorno="$(source trans -e google -b pt:${LINGUAGE} "$@"|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
 if [[ $retorno = "" ]];then
 retorno="$(source trans -e bing -b pt:${LINGUAGE} "$@"|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
 fi
 if [[ $retorno = "" ]];then 
 retorno="$(source trans -e yandex -b pt:${LINGUAGE} "$@"|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
 fi
echo "texto[$@]='$retorno'"  >> /etc/texto-adm
echo "$retorno"
else
echo "${texto[$@]}"
fi
}
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
ip_checks () {
#Instal GEOIP
[[ $(dpkg -l | grep geoip-bin | grep ii) = "" ]] && apt-get install geoip-bin -y > /dev/null 2>&1
fail2ban_list="/tmp/fail2ban_list"
#BAN LISTA
grep "Ban " /var/log/fail2ban.log|awk '{print $8}'| sort --unique >> $fail2ban_list
if [[ $(awk '{x++}END{print x}' $fail2ban_list) != "" ]]; then
while read linea; do
[[ $linea = "" ]] && break
echo -e "\033[1;37m IP: $(echo $linea|awk '{print $1}') \033[1;31m[$(fun_trans "BLOQUEADA")] \033[1;31m->\033[1;33m$(geoiplookup $(echo $linea|awk '{print $1}')|awk '{$1=""}{$2=""}{$3="";print}' )"
done < $fail2ban_list
else
echo -e "\033[1;31m $(fun_trans "Não foi encontrados IPs BLOQUEADAS")!"
fi
rm $fail2ban_list
echo -e "$barra"
#UNBAN LISTA
grep "Unban " /var/log/fail2ban.log|awk '{print $8}'| sort --unique >> $fail2ban_list
if [[ $(awk '{x++}END{print x}' $fail2ban_list) != "" ]]; then
while read linea; do
[[ $linea = "" ]] && break
echo -e "\033[1;37m IP: $(echo $linea|awk '{print $1}') \033[1;32m[$(fun_trans "LIBERADA")] \033[1;31m->\033[1;33m$(geoiplookup $(echo $linea|awk '{print $1}')|awk '{$1=""}{$2=""}{$3="";print}' )"
done < $fail2ban_list
else
echo -e "\033[1;31m $(fun_trans "Não foi encontrados IPs LIBERADA")!"
fi 
rm $fail2ban_list
echo -e "$barra"
#FoundLista
echo -e "\033[1;37m ¿$(fun_trans "Você deseja ver a lista de IPs detectados")?"
read -p " $(fun_trans "Digite a Opcao"): [s/n] " -e -i n sshsn
tput cuu1 && tput dl1
tput cuu1 && tput dl1
   [[ "$sshsn" = @(s|S|y|Y) ]] && {
grep "Found " /var/log/fail2ban.log|awk '{print $8}'| sort --unique >> $fail2ban_list
while read linea; do
[[ $linea = "" ]] && break
echo -e "\033[1;37m IP: $(echo $linea|awk '{print $1}') \033[1;36m[$(fun_trans "DETECTADA")] \033[1;31m->\033[1;33m$(geoiplookup $(echo $linea|awk '{print $1}')|awk '{$1=""}{$2=""}{$3="";print}' )"
done < $fail2ban_list
rm $fail2ban_list
echo -e "$barra"
}
}
#FUN_BAR
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
   for((i=0; i<18; i++)); do
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
pid_inst () {
[[ $1 = "" ]] && echo "" && return 0
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
i=0
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e ${portas[@]}|grep "$var1 $var2")" ]] || {
    portas[$i]="$var1 $var2\n"
    let i++
    }
done <<< "$portas_var"
[[ $(echo "${portas[@]}"|grep "$1") ]] && echo "ok" || echo ""
}
portsquid_fun () {
#Identificar ports squid
portis=/tmp/portis
if [[ -e /etc/squid/squid.conf ]]; then
_squid="squid"
elif [[ -e /etc/squid3/squid.conf ]]; then
_squid="squid3"
fi
touch $portis
mportas > /tmp/portz
while read portas; do
[[ $portas = "" ]] && break
if [[ $(echo $portas|awk '{print $1}') = $_squid ]]; then
echo -n $(echo $portas|awk '{print $2}')","  >> $portis
fi
done < /tmp/portz
prox_squid=$(sed 's/.$//g' "$portis")
rm $portis
rm /tmp/portz
}
portsapache_fun () {
#Identificar ports squid
portis=/tmp/portis
touch $portis
mportas > /tmp/portz
while read portas; do
[[ $portas = "" ]] && break
if [[ $(echo $portas|awk '{print $1}') = "apache2" ]]; then
echo -n $(echo $portas|awk '{print $2}')","  >> $portis
fi
done < /tmp/portz
prox_apache=$(sed 's/.$//g' "$portis")
rm $portis
rm /tmp/portz
}
portsdropbear_fun () {
#Identificar ports squid
portis=/tmp/portis
touch $portis
mportas > /tmp/portz
while read portas; do
[[ $portas = "" ]] && break
if [[ $(echo $portas|awk '{print $1}') = "dropbear" ]]; then
echo -n $(echo $portas|awk '{print $2}')","  >> $portis
fi
done < /tmp/portz
prox_dropbear=$(sed 's/.$//g' "$portis")
rm $portis
rm /tmp/portz
}
bin_remove () {
#Limpiar PY
[[ -e usr/local/bin/fail2ban-client ]] && rm -rf usr/local/bin/fail2ban-client
[[ -e usr/local/bin/fail2ban-regex ]] && rm -rf usr/local/bin/fail2ban-regex
[[ -e usr/local/bin/fail2ban-server ]] && rm -rf usr/local/bin/fail2ban-server
[[ -e usr/local/bin/fail2ban-testcases ]] && rm -rf usr/local/bin/fail2ban-testcases
}
fail2ban_service () {
(
portsquid_fun
portsapache_fun
portsdropbear_fun
echo '[INCLUDES]
before = paths-debian.conf

[DEFAULT]
ignoreip = 127.0.0.1/8
bantime = 600
findtime = 600
maxretry = 3
backend = auto
usedns = warn
destemail = root@localhost
sendername = Fail2Ban
banaction = iptables-multiport
mta = sendmail
protocol = tcp
chain = INPUT
action_ = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
action_mw = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
          %(mta)s-whois[name=%(__name__)s, dest="%(destemail)s", protocol="%(protocol)s", chain="%(chain)s", sendername="%(sendername)s"]
action_mwl = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
           %(mta)s-whois-lines[name=%(__name__)s, dest="%(destemail)s", logpath=%(logpath)s, chain="%(chain)s", sendername="%(sendername)s"]
action = %(action_)s' > $jaillocal
if [[ $serv_sshd != "" ]]; then
echo '[sshd]
enabled = true
port    = ssh
logpath = %(sshd_log)s
backend = polling
bantime = 60000
findtime = 600
maxretry = 4
[sshd-ddos]
enabled = true
port    = ssh
logpath = %(sshd_log)s
backend = polling
bantime = 60000
findtime = 600
maxretry = 4' >> $jaillocal
fi
if [[ $serv_squid != "" ]]; then
echo "[squid]
enabled = true
port     =  ${prox_squid}
logpath = /var/log/${_squid}/access.log
bantime = 1200
findtime = 600
maxretry = 6" >> $jaillocal
fi
if [[ $serv_dropbear != "" ]]; then
echo "[dropbear]
enabled = true
port     = ${prox_dropbear},ssh
logpath  = %(dropbear_log)s
backend  = polling
bantime = 1200
findtime = 600
maxretry = 12" >> $jaillocal
fi
if [[ $serv_apache != "" ]]; then
echo "[apache-auth]
enabled = true
port     = ${prox_apache}
logpath  = %(apache_error_log)s" >> $jaillocal
fi
) > /dev/null 2>&1
}
fail2ban_remove_iptables () {
reuq="/tmp/iptables_"
reuq2="/tmp/iptable_"
[[ -e $reuq ]] && rm -rf $reuq2
[[ -e $reuq ]] && rm -rf $reuq2
while true; do
echo "$(iptables -S | grep INPUT | grep tcp )" >> $reuq
echo "$(grep -n f2b $reuq | awk '{print $1}' | sed 's/.$//g' | sed 's/.$//g' | sed 's/.$//g') " >> $reuq2
[[ $(echo $(awk 'NR==1' $reuq2)) = "" ]] && break
iptables -D INPUT $(echo $(awk 'NR==1' $reuq2))
rm $reuq && rm $reuq2
done
rm $reuq && rm $reuq2
}
fail2ban_instal () {
[[ $(iptables -h|wc -l) -lt 5 ]] && apt-get install iptables -y > /dev/null 2>-1
fail2ban_remove_iptables
fail2ban_remove_iptables
fun_bar "apt-get install fail2ban -y"
bin_remove
#configs
cd $HOME
[[ -e $HOME/fail2.tar.gz ]] && rm -rf $HOME/fail2.tar.gz
[[ -d $HOME/fail2ban ]] && rm -rf $HOME/fail2ban
wget -O fail2.tar.gz https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/fail2ban.tar.gz -o /dev/null
tar -xzf $HOME/fail2.tar.gz
[[ -d /etc/fail2ban ]] && rm -rf /etc/fail2ban
mv -f $HOME/fail2ban /etc
chmod 755 /etc/fail2ban
[[ -e $HOME/fail2.tar.gz ]] && rm $HOME/fail2.tar.gz
[[ -d $HOME/fail2ban ]] && rm -rf $HOME/fail2ban
#Setup
cd $HOME
wget -O fail2ban https://github.com/fail2ban/fail2ban/archive/0.10.tar.gz -o /dev/null
tar -xf $HOME/fail2ban
cd $HOME/fail2ban-0.10
fun_bar "./setup.py install" 
[[ -e $jaillocal ]] && rm -rf $jaillocal
[[ ! -e $jaillocal ]] && touch $jaillocal
fail2ban_service
}
fail2ban_remove () {
fail2ban-client -x stop > /dev/null 2>&1
fail2ban_remove_iptables
fail2ban_remove_iptables
fun_bar "apt-get remove fail2ban -y"
fun_bar "apt-get purge fail2ban -y"
[[ -d /etc/fail2ban ]] && rm -rf /etc/fail2ban
bin_remove
echo -e "$barra"
}
Fail2Ban_update () {
if [[ -e /etc/fail2ban/jail.conf ]]; then
rm -rf $jaillocal
fail2ban_service
/etc/init.d/fail2ban restart > /dev/null 2>&1
fail2ban-client -x start > /dev/null 2>&1
fi
exit
}
fail2ban_function () {
echo -e " \033[1;36m $(fun_trans "FAIL2BAN PROTECAO") \033[1;32m[NEW-ADM]"
echo -e "$barra"
if [[ -e /etc/fail2ban/jail.conf ]]; then
while true; do
echo -e "${cor[2]} [1] > \033[1;37m$(fun_trans "Ver registro de IP")s"
echo -e "${cor[2]} [2] > \033[1;37m$(fun_trans "Remover") fail2ban"
echo -e "${cor[2]} [0] > \033[1;37m$(fun_trans "VOLTAR")\n${barra}"
while [[ ${lo_og} != [0-2] ]]; do
echo -ne "\033[1;37m $(fun_trans "Digite a Opcao"): " && read lo_og
tput cuu1 && tput dl1
done
case $lo_og in
     0)
	 return;;
     1)
	 ip_checks
	 return;;
     2)
	 fail2ban_remove
	 return;;
esac
done
fi
fail2ban_instal
/etc/init.d/fail2ban restart > /dev/null 2>&1
fail2ban-client -x stop > /dev/null 2>&1
fail2ban-client -x start > /dev/null 2>&1
[[ -e $HOME/fail2ban ]] && rm $HOME/fail2ban
[[ -d $HOME/fail2ban-0.10 ]] && rm -rf $HOME/fail2ban-0.10
echo -e "$barra"
if [ "$failtwoban" != "" ]; then
echo -e "\033[1;31m FAIL2BAN $(fun_trans "no se instalo")!"
echo -e "$barra"
else
echo -e "\033[1;32m FAIL2BAN $(fun_trans "instalado")!"
echo -e "$barra"
fi
return
}
[[ "$1" = "1" ]] && Fail2Ban_update
fail2ban_function
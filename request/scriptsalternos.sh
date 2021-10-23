#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

meu_ip () {
if [[ -e /etc/MEUIPADM ]]; then
echo "$(cat /etc/MEUIPADM)"
else
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && echo "$MEU_IP2" || echo "$MEU_IP"
echo "$MEU_IP2" > /etc/MEUIPADM
fi
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
tput cuu1
tput dl1
done
echo -e " \033[1;33m[\033[1;31m####################\033[1;33m] - \033[1;32m100%\033[0m"
sleep 1s
}

act_hora () {
echo -ne " \033[1;31m[ ! ] timedatectl"
timedatectl > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] timedatectl list-timezones"
timedatectl list-timezones > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] timedatectl list-timezones  | grep Santiago"
timedatectl list-timezones  | grep Santiago > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] timedatectl set-timezone America/Santiago"
timedatectl set-timezone America/Santiago > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
return
}

newadm_color () {
echo -e "$(fun_trans "Deseja Prosseguir?")"
read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
msg -bar
rm -rf /etc/new-adm-color > /dev/null 2>&1
echo "4 1 7 3 2 5 4 " > /etc/new-adm-color
echo -ne " \033[1;31m[ ! ] new-adm-color \033[1;32m[OK]\n"
return
}

fun_statussistema () {
echo -e "\033[1;33m DETALHES DO SISTEMA"
msg -bar
# SISTEMA OPERACIONAL
_hora=$(printf '%(%H:%M:%S)T')
_hoje=$(date +'%d/%m/%Y')
if [ -f /etc/lsb-release ]
then
name=$(cat /etc/lsb-release |grep DESCRIPTION |awk -F = {'print $2'})
codename=$(cat /etc/lsb-release |grep CODENAME |awk -F = {'print $2'})
echo -e "\033[1;31mNome: \033[1;37m$name"
echo -e "\033[1;31mIP: \033[1;37m$(meu_ip)"
echo -e "\033[1;31mHora : \033[1;37m$_hora"
echo -e "\033[1;31mData: \033[1;37m$_hoje"
echo -e "\033[1;31mCodeName: \033[1;37m$codename"
echo -e "\033[1;31mKernel: \033[1;37m$(uname -s)"
echo -e "\033[1;31mKernel Release: \033[1;37m$(uname -r)"
if [ -f /etc/os-release ]
then
devlike=$(cat /etc/os-release |grep LIKE |awk -F = {'print $2'})
echo -e "\033[1;31mDerivado do OS: \033[1;37m$devlike"
fi
else
system=$(cat /etc/issue.net)
echo -e "\033[1;31mNome: \033[1;37m$system"
fi
# PROCESSADOR
msg -bar
if [ -f /proc/cpuinfo ]
then
uso=$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')
modelo=$(cat /proc/cpuinfo |grep "model name" |uniq |awk -F : {'print $2'})
cpucores=$(grep -c cpu[0-9] /proc/stat)
cache=$(cat /proc/cpuinfo |grep "cache size" |uniq |awk -F : {'print $2'})
echo -e "\033[1;31mModelo:\033[1;37m$modelo"
echo -e "\033[1;31mNucleos:\033[1;37m $cpucores"
echo -e "\033[1;31multilizacao: \033[37m$uso"
echo -e "\033[1;31mArquitetura: \033[1;37m$(uname -p)"
echo -e "\033[1;31mMemoria Cache:\033[1;37m$cache"
else
echo "Não foi possivel obter informações"
fi
# MEMORIA RAM
msg -bar
if free 1>/dev/null 2>/dev/null
then
ram1=$(free -h | grep -i mem | awk {'print $2'})
ram2=$(free -h | grep -i mem | awk {'print $4'})
ram3=$(free -h | grep -i mem | awk {'print $3'})
usoram=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')
echo -e "\033[1;31mRam Total: \033[1;32m$ram1"
echo -e "\033[1;31mRam Em Uso: \033[1;32m$ram3"
echo -e "\033[1;31mRam Livre: \033[1;32m$ram2"
echo -e "\033[1;31mRam ultilizacao: \033[32m$usoram"
else
echo "Não foi possivel obter informações"
fi
# SERVICOS EM EXECUCAO
msg -bar
PT=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
for porta in `echo -e "$PT" | cut -d: -f2 | cut -d' ' -f1 | uniq`; do
    svcs=$(echo -e "$PT" | grep -w "$porta" | awk '{print $1}' | uniq)
    echo -e "\033[1;32mServico \033[1;31m$svcs \033[1;32mPorta \033[1;37m$porta"
done
}

fun_nettools () {
[[ ! -e /bin/nettools.py ]] && wget -O /bin/nettools.py https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/nettools.py > /dev/null 2>&1; chmod +x /bin/nettools.py; /bin/nettools.py
}

resetiptables () {
echo -e "Reiniciando Ipetables espere"
iptables -F && iptables -X && iptables -t nat -F && iptables -t nat -X && iptables -t mangle -F && iptables -t mangle -X && iptables -t raw -F && iptables -t raw -X && iptables -t security -F && iptables -t security -X && iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT && iptables -P OUTPUT ACCEPT
echo -e "iptables reiniciadas con exito"
}

packobs () {
msg -ama "Buscando Paquetes Obsoletos"
dpkg -l | grep -i ^rc
msg -ama "Limpiando Paquetes Obsoloteos"
dpkg -l |grep -i ^rc | cut -d " " -f 3 | xargs dpkg --purge
msg -ama "Limpieza Completa"
}

# SISTEMA DE SELECAO
selection_fun () {
local selection="null"
local range
for((i=0; i<=$1; i++)); do range[$i]="$i "; done
while [[ ! $(echo ${range[*]}|grep -w "$selection") ]]; do
echo -ne "[0-12]: " >&2
read selection
tput cuu1 >&2 && tput dl1 >&2
done
echo $selection
}

clear
clear
rm -rf /bin/C-SSR.sh > /dev/null 2>&1
rm -rf /bin/Shadowsocks-libev.sh > /dev/null 2>&1
rm -rf /bin/Shadowsocks-R.sh > /dev/null 2>&1
rm -rf /bin/shadowsocks.sh > /dev/null 2>&1
rm -rf /bin/v2ray84.sh > /dev/null 2>&1
rm -rf /bin/conexao.sh > /dev/null 2>&1
rm -rf /bin/conexao > /dev/null 2>&1
rm -rf /bin/tcp.sh > /dev/null 2>&1
rm -rf /bin/blockBT.sh > /dev/null 2>&1
msg -bar
msg -ama " $(fun_trans "TESTE SCRIPTS ALTERNOS")"
msg -bar
msg -azu " \033[1;31m[\033[1;33m!\033[1;31m]\033[1;33m $(fun_trans "FUNCAO BETA ULTILIZE POR SUA CONTA EM RISCO") \033[1;31m[\033[1;33m!\033[1;31m]"
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "ATUALIZAR HORA AMERICA-SANTIAGO")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "MUDAR CORES SISTEMA A RED-TEME")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "DETALHES DO SISTEMA")"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "NET TOOLS TARGET")"
echo -ne "\033[1;32m [5] > " && msg -azu "$(fun_trans "REINICIAR IPTABLES")"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "LIMPAR PACOTES OBSOLETOS")"
msg -bar
echo -ne "\033[1;32m [7] > " && msg -azu "$(fun_trans "ADMINISTRAR CUENTAS SS/SSRR")"
echo -ne "\033[1;32m [8] > " && msg -azu "$(fun_trans "SHADOWSOCKS-LIBEV")"
echo -ne "\033[1;32m [9] > " && msg -azu "$(fun_trans "SHADOWSOCKS-R")"
echo -ne "\033[1;32m [10] > " && msg -azu "$(fun_trans "SHADOWSOCKS-NORMAL")"
msg -bar
echo -ne "\033[1;32m [11] > " && msg -azu "$(fun_trans "TCP ACELERACION") (BBR/PLUS)"
echo -ne "\033[1;32m [12] > " && msg -azu "$(fun_trans "FIREWALL PARA VPS")"
msg -bar
# FIM
selection=$(selection_fun 14)
case ${selection} in
1)act_hora;;
2)newadm_color;;
3)fun_statussistema;;
4)fun_nettools;;
5)resetiptables;;
6)packobs;;
7)wget -O /bin/C-SSR.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/C-SSR.sh > /dev/null 2>&1; chmod +x /bin/C-SSR.sh; C-SSR.sh
exit;;
8)wget -O /bin/Shadowsocks-libev.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/Shadowsocks-libev.sh > /dev/null 2>&1; chmod +x /bin/Shadowsocks-libev.sh; Shadowsocks-libev.sh
exit;;
9)wget -O /bin/Shadowsocks-R.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/Shadowsocks-R.sh > /dev/null 2>&1; chmod +x /bin/Shadowsocks-R.sh; Shadowsocks-R.sh
exit;;
10)wget -O /bin/shadowsocks.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/shadowsocks.sh > /dev/null 2>&1; chmod +x /bin/shadowsocks.sh; shadowsocks.sh
exit;;
11)wget -O /bin/tcp.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/tcp.sh > /dev/null 2>&1; chmod 777 /bin/tcp.sh; tcp.sh
exit;;
12)wget -O /bin/blockBT.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/blockBT.sh > /dev/null 2>&1; chmod 777 /bin/blockBT.sh; blockBT.sh
exit;;
teste675)wget -O /etc/ger-inst/v2ray.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/v2ray84.sh > /dev/null 2>&1; chmod +x /etc/ger-inst/v2ray.sh; /etc/ger-inst/v2ray.sh
exit;;
teste844)wget -O /bin/conexao https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/conexao.sh > /dev/null 2>&1; chmod +x /bin/conexao; conexao
exit;;
0)exit;;
esac
msg -bar
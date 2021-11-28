#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
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
echo -e "\033[1;33m Removendo new-adm-color"
rm -rf /etc/new-adm-color > /dev/null 2>&1
msg -bar
echo -e "$(fun_trans "Deseja Prosseguir?")"
read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
msg -bar
echo "4 1 7 3 2 5 4 " > /etc/new-adm-color
echo -ne " \033[1;31m[ ! ] new-adm-color \033[1;32m[OK]\n"
return
}

fun_statussistema () {
clear
clear
msg -bar
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
msg -ama "Reiniciando Ipetables espere"
msg -bar
iptables -F && iptables -X && iptables -t nat -F && iptables -t nat -X && iptables -t mangle -F && iptables -t mangle -X && iptables -t raw -F && iptables -t raw -X && iptables -t security -F && iptables -t security -X && iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT && iptables -P OUTPUT ACCEPT
fun_bar "service ssh restart" "service sshd restart"
msg -bar
msg -ama "iptables reiniciadas con exito"
}

packobs () {
msg -ama "Buscando Paquetes Obsoletos"
msg -bar
fun_bar "service ssh restart" "service sshd restart"
dpkg -l | grep -i ^rc
msg -bar
msg -ama "Limpiando Paquetes Obsoloteos"
msg -bar
dpkg -l |grep -i ^rc | cut -d " " -f 3 | xargs dpkg --purge
msg -bar
msg -ama "Limpieza Completa"
}

fun_cssr () {
wget -O /bin/C-SSR.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/C-SSR.sh
chmod +x /bin/C-SSR.sh; C-SSR.sh
exit
}

fun_shadowsockslibev () {
wget -O /bin/Shadowsocks-libev.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/Shadowsocks-libev.sh
chmod +x /bin/Shadowsocks-libev.sh; Shadowsocks-libev.sh
exit
}

fun_shadowsocksr () {
wget -O /bin/Shadowsocks-R.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/Shadowsocks-R.sh
chmod +x /bin/Shadowsocks-R.sh; Shadowsocks-R.sh
exit
}

fun_shadowsocks () {
wget -O /bin/shadowsocks.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/shadowsocks.sh
chmod +x /bin/shadowsocks.sh; shadowsocks.sh
exit
}

fun_tcp () {
wget -O /bin/tcp.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/tcp.sh
chmod 777 /bin/tcp.sh; tcp.sh
exit
}

fun_blockbt () {
wget -O /bin/blockBT.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/blockBT.sh
chmod 777 /bin/blockBT.sh; blockBT.sh
exit
}

# SISTEMA DE SELECAO
selection_fun () {
local selection="null"
local range
for((i=0; i<=$1; i++)); do range[$i]="$i "; done
while [[ ! $(echo ${range[*]}|grep -w "$selection") ]]; do
echo -ne "\033[1;37m$(fun_trans "Selecione a Opcao"): " >&2
read selection
tput cuu1 >&2 && tput dl1 >&2
done
echo $selection
}

clear
clear
msg -bar
msg -ama "$(fun_trans "TESTE SCRIPTS ALTERNOS")"
msg -bar
msg -azu " \033[1;31m[\033[1;33m!\033[1;31m]\033[1;33m $(fun_trans "FUNCAO BETA ULTILIZE POR SUA CONTA EM RISCO") \033[1;31m[\033[1;33m!\033[1;31m]"
msg -bar
echo -ne "$(msg -verd "[0]") $(msg -verm2 ">") " && msg -bra "$(fun_trans "VOLTAR")"
echo -ne "$(msg -verd "[1]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "ATUALIZAR HORA AMERICA-SANTIAGO")"
echo -ne "$(msg -verd "[2]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "MUDAR CORES SISTEMA A RED-TEME")"
echo -ne "$(msg -verd "[3]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "DETALHES DO SISTEMA")"
echo -ne "$(msg -verd "[4]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "NET TOOLS TARGET")"
echo -ne "$(msg -verd "[5]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "REINICIAR IPTABLES")"
echo -ne "$(msg -verd "[6]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "LIMPAR PACOTES OBSOLETOS")"
msg -bar
echo -ne "$(msg -verd "[7]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "ADMINISTRAR CUENTAS SS/SSRR")"
echo -ne "$(msg -verd "[8]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "SHADOWSOCKS-LIBEV")"
echo -ne "$(msg -verd "[9]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "SHADOWSOCKS-R")"
echo -ne "$(msg -verd "[10]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "SHADOWSOCKS-NORMAL")"
msg -bar
echo -ne "$(msg -verd "[11]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "TCP ACELERACION") (BBR/PLUS)"
echo -ne "$(msg -verd "[12]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "FIREWALL PARA VPS")"
msg -bar
# FIM
selection=$(selection_fun 12)
case ${selection} in
1)act_hora;;
2)newadm_color;;
3)fun_statussistema;;
4)fun_nettools;;
5)resetiptables;;
6)packobs;;
7)fun_cssr;;
8)fun_shadowsockslibev;;
9)fun_shadowsocksr;;
10)fun_shadowsocks;;
11)fun_tcp;;
12)fun_blockbt;;
0)exit;;
esac
msg -bar
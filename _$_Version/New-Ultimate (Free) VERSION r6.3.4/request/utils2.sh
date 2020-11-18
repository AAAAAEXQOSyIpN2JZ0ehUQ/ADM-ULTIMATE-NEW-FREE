#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

[[ -d /etc/ger-tools ]] && rm -rf /etc/ger-tools

link_bin="https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/nettools.py"
[[ ! -e /bin/nettools.py ]] && wget -O /bin/nettools.py ${link_bin} > /dev/null 2>&1 && chmod +x /bin/nettools.py

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

fun_nload () {
echo -e "${cor[3]} $(fun_trans "Con nload puedes ver todos el trafico")"
echo -e "${cor[3]} $(fun_trans "de red generado en tu sistema")"
echo -e "${cor[4]} $(fun_trans "PARA SALIR DEL PANEL PRESIONE") ${cor[3]}CTLR+C"
msg -bar
sleep 1s
fun_bar "apt-get install nload -y"
sleep 2s
nload
}

fun_htop () {
echo -e "${cor[3]} $(fun_trans "Con htop puedes ver todos los procesos")"
echo -e "${cor[3]} $(fun_trans "que se ejecutan en tu sistema")"
echo -e "${cor[4]} $(fun_trans "PARA SALIR DEL PANEL PRESIONE") ${cor[3]}CTLR+C"
msg -bar
sleep 1s
fun_bar "apt-get install htop -y"
sleep 2s
htop
}

fun_statussistema () {
echo -e "\033[1;33m STATUS DO SISTEMA"
echo -e "$barra"
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
echo -e "$barra"
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
echo -e "$barra"
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
echo -e "$barra"
PT=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
for porta in `echo -e "$PT" | cut -d: -f2 | cut -d' ' -f1 | uniq`; do
    svcs=$(echo -e "$PT" | grep -w "$porta" | awk '{print $1}' | uniq)
    echo -e "\033[1;32mServico \033[1;31m$svcs \033[1;32mPorta \033[1;37m$porta"
done
}

fun_nettools () {
/bin/nettools.py
}

msg -ama "$(fun_trans "MENU DE UTILITARIOS") ${cor[4]}[NEW-ADM]"
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "TRAFICO DE RED NLOAD")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "PROCESOS DEL SISTEMA HTOP")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "STATUS DO SISTEMA") \033[1;33m(\033[1;37mBETA\033[1;33m)"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "NET TOOLS TARGET") \033[1;33m(\033[1;37mBETA\033[1;33m)"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-4]) ]]; do
read -p "[0-4]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)fun_nload;;
2)fun_htop;;
3)fun_statussistema;;
4)fun_nettools;;
esac
msg -bar
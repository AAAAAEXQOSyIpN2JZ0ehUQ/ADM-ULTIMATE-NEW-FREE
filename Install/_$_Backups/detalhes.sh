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

clear
echo -e "$barra"
echo -e "\033[1;33m DETALHES DO SISTEMA \033[1;32m[NEW-ADM]"
echo -e "$barra"

# SISTEMA OPERACIONAL
_hora=$(printf '%(%H:%M:%S)T')
_hoje=$(date +'%d/%m/%Y')
if [ -f /etc/lsb-release ]
then
echo -e "\033[1;36m SISTEMA OPERACIONAL"
echo ""
name=$(cat /etc/lsb-release |grep DESCRIPTION |awk -F = {'print $2'})
codename=$(cat /etc/lsb-release |grep CODENAME |awk -F = {'print $2'})
echo -e "\033[1;33mNome: \033[1;31m$name"
echo -e "\033[1;33mIP: \033[1;31m$(meu_ip)"
echo -e "\033[1;33mHora : \033[1;31m$_hora"
echo -e "\033[1;33mData: \033[1;31m$_hoje"
echo -e "\033[1;33mCodeName: \033[1;31m$codename"
echo -e "\033[1;33mKernel: \033[1;31m$(uname -s)"
echo -e "\033[1;33mKernel Release: \033[1;31m$(uname -r)"
if [ -f /etc/os-release ]
then
devlike=$(cat /etc/os-release |grep LIKE |awk -F = {'print $2'})
echo -e "\033[1;33mDerivado do OS: \033[1;31m$devlike"
fi
else
system=$(cat /etc/issue.net)
echo -e "\033[1;36m SISTEMA OPERACIONAL"
echo ""
echo -e "\033[1;33mNome: \033[1;31m$system"
fi
echo -e ""

# PROCESSADOR
if [ -f /proc/cpuinfo ]
then
uso=$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')
echo -e "\033[1;36m PROCESSADOR"
echo ""
modelo=$(cat /proc/cpuinfo |grep "model name" |uniq |awk -F : {'print $2'})
cpucores=$(grep -c cpu[0-9] /proc/stat)
cache=$(cat /proc/cpuinfo |grep "cache size" |uniq |awk -F : {'print $2'})
echo -e "\033[1;33mModelo:\033[1;31m$modelo"
echo -e "\033[1;33mNucleos:\033[1;31m $cpucores"
echo -e "\033[1;33mMemoria Cache:\033[1;31m$cache"
echo -e "\033[1;33mArquitetura: \033[1;31m$(uname -p)"
echo -e "\033[1;33multilizacao: \033[31m$uso"
else
echo -e "\033[1;36m PROCESSADOR"
echo ""
echo "Não foi possivel obter informações"
fi
echo ""

# MEMORIA RAM
if free 1>/dev/null 2>/dev/null
then
ram1=$(free -h | grep -i mem | awk {'print $2'})
ram2=$(free -h | grep -i mem | awk {'print $4'})
ram3=$(free -h | grep -i mem | awk {'print $3'})
usoram=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')
echo -e "\033[1;36m MEMORIA RAM"
echo ""
echo -e "\033[1;33mTotal: \033[1;31m$ram1"
echo -e "\033[1;33mEm Uso: \033[1;31m$ram3"
echo -e "\033[1;33mLivre: \033[1;31m$ram2"
echo -e "\033[1;33multilizacao: \033[31m$usoram"
else
echo -e "\033[1;36mMEMORIA RAM"
echo ""
echo "Não foi possivel obter informações"
fi
echo ""

# SERVICOS EM EXECUCAO
echo -e "\033[1;36m SERVICOS EM EXECUCAO"
echo ""
PT=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
for porta in `echo -e "$PT" | cut -d: -f2 | cut -d' ' -f1 | uniq`; do
    svcs=$(echo -e "$PT" | grep -w "$porta" | awk '{print $1}' | uniq)
    echo -e "\033[1;32m Servico \033[1;31m$svcs \033[1;32mPorta \033[1;37m$porta"
done
echo -e "$barra"
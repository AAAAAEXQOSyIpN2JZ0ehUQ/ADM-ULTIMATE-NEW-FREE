#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

echo -e "\033[1;33m INFORMACION DE SISTEMAS"
echo -e "$barra"

# SISTEMA OPERACIONAL
_hora=$(printf '%(%H:%M:%S)T')
_hoje=$(date +'%d/%m/%Y')
if [ -f /etc/lsb-release ]
then
echo -e "\033[1;33m SISTEMA OPERACIONAL"
echo ""
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
echo -e "\033[1;33m SISTEMA OPERACIONAL"
echo ""
echo -e "\033[1;31mNome: \033[1;37m$system"
fi

echo -e "$barra"
# PROCESSADOR
if [ -f /proc/cpuinfo ]
then
uso=$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')
echo -e "\033[1;33m PROCESSADOR"
echo ""
modelo=$(cat /proc/cpuinfo |grep "model name" |uniq |awk -F : {'print $2'})
cpucores=$(grep -c cpu[0-9] /proc/stat)
cache=$(cat /proc/cpuinfo |grep "cache size" |uniq |awk -F : {'print $2'})
echo -e "\033[1;31mModelo:\033[1;37m$modelo"
echo -e "\033[1;31mNucleos:\033[1;37m $cpucores"
echo -e "\033[1;31mMemoria Cache:\033[1;37m$cache"
echo -e "\033[1;31mArquitetura: \033[1;37m$(uname -p)"
echo -e "\033[1;31multilizacao: \033[37m$uso"
else
echo -e "\033[1;33m PROCESSADOR"
echo ""
echo "Não foi possivel obter informações"
fi

echo -e "$barra"
# MEMORIA RAM
if free 1>/dev/null 2>/dev/null
then
ram1=$(free -h | grep -i mem | awk {'print $2'})
ram2=$(free -h | grep -i mem | awk {'print $4'})
ram3=$(free -h | grep -i mem | awk {'print $3'})
usoram=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')
echo -e "\033[1;33m MEMORIA RAM"
echo ""
echo -e "\033[1;31mTotal: \033[1;32m$ram1"
echo -e "\033[1;31mEm Uso: \033[1;32m$ram3"
echo -e "\033[1;31mLivre: \033[1;32m$ram2"
echo -e "\033[1;31multilizacao: \033[32m$usoram"
else
echo -e "\033[1;33mMEMORIA RAM"
echo ""
echo "Não foi possivel obter informações"
fi

echo -e "$barra"
# SERVICOS EM EXECUCAO
echo -e "\033[1;33m SERVICOS EM EXECUCAO"
echo ""
PT=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
for porta in `echo -e "$PT" | cut -d: -f2 | cut -d' ' -f1 | uniq`; do
    svcs=$(echo -e "$PT" | grep -w "$porta" | awk '{print $1}' | uniq)
    echo -e "\033[1;31m$svcs: \033[1;32m$porta"
done
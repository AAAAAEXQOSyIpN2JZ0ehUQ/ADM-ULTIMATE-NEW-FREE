#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit

echo -e "${cor[3]} $(fun_trans "INFORMACION DE SISTEMAS Y PUERTOS") ${cor[4]}[NEW-ADM]"
echo -e "$barra"

#HORA SISTEMA
_hora=$(printf '%(%H:%M:%S)T')

echo -e "\033[1;31mHORA SISTEMA: \033[1;37m$_hora          \033[1;31mIP: \033[1;37m$(meu_ip)"
echo -e "$barra"

#SISTEMA OPERATIVO
system=$(cat /etc/issue.net)
if [ "$system" ]
then

#PROCESSADOR
_core=$(printf '%-1s' "$(grep -c cpu[0-9] /proc/stat)")
_usop=$(printf '%-1s' "$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')")

#SISTEMA-USO DA CPU-MEMORIA RAM
ram1=$(free -h | grep -i mem | awk {'print $2'})
ram2=$(free -h | grep -i mem | awk {'print $4'})
ram3=$(free -h | grep -i mem | awk {'print $3'})

#_ram=$(printf ' %-9s' "$(free -h | grep -i mem | awk {'print $2'})")
_usor=$(printf '%-8s' "$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')")

echo -e "\033[1;31mSISTEMA: \033[1;37m$system     "
else
echo -e "\033[1;32mSISTEMA: \033[1;33m[\033[1;37mNo Disponible\033[1;33m]"
fi
echo -e "$barra"
echo -e "\033[1;31mPROCESSADOR: \033[1;37mNUCLEOS: \033[1;32m$_core         \033[1;37mUSO DE CPU: \033[1;32m$_usop"
echo -e "$barra"
echo -e "\033[1;31mLA MEMORIA RAM SE ENCUENTRA TRABAJANDO AL: \033[1;32m$_usor"
echo -e "\033[1;31mDETALLE RAM: \033[1;37mTOTAL: \033[1;32m$ram1  \033[1;37mUSADO: \033[1;32m$ram3  \033[1;37mLIBRE: \033[1;32m$ram2"
echo -e "$barra"

#SISTEMA DE PUERTAS
mine_port () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
i=0
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e ${portas[@]}|grep "$var1 $var2")" ]] || {
    portas[$i]="$var1 $var2"
    let i++
    }
done <<< "$portas_var"
for((i=0; i<=${#portas[@]}; i++)); do
servico="$(echo ${portas[$i]}|cut -d' ' -f1)"
porta="$(echo ${portas[$i]}|cut -d' ' -f2)"
[[ -z $servico ]] && break
texto="\033[1;31m${servico}: \033[1;32m${porta}"
     while [[ ${#texto} -lt 35 ]]; do
        texto=$texto" "
     done
echo -ne "${texto}"
let i++
servico="$(echo ${portas[$i]}|cut -d' ' -f1)"
porta="$(echo ${portas[$i]}|cut -d' ' -f2)"
[[ -z $servico ]] && {
   echo -e " "
   break
   }
texto="\033[1;31m${servico}: \033[1;32m${porta}"
     while [[ ${#texto} -lt 35 ]]; do
        texto=$texto" "
     done
echo -ne "${texto}"
let i++
servico="$(echo ${portas[$i]}|cut -d' ' -f1)"
porta="$(echo ${portas[$i]}|cut -d' ' -f2)"
[[ -z $servico ]] && {
   echo -e " "
   break
   }
texto="\033[1;31m${servico}: \033[1;32m${porta}"
     while [[ ${#texto} -lt 35 ]]; do
        texto=$texto" "
     done
echo -e "${texto}"
done
echo -e "$barra"
}

mine_port
#!/bin/bash
red=$(tput setaf 1)
gren=$(tput setaf 2)
yellow=$(tput setaf 3)
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
ofc="\033[0m${gren}(#OFC)"
dev="\033[0m${gren}(#DEV)"
bet="\033[0m${gren}(#BET)"

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

fun_nload () {
msg -azu " $(fun_trans "PARA SALIR DEL PANEL PRESIONE") \033[1;33mCTLR + C"
msg -bar
echo -ne " $(fun_trans "Deseja Prosseguir?")"; read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
#Inicia Procedimentos
msg -bar
[[ $(dpkg --get-selections|grep -w "nload"|head -1) ]] || apt-get install nload -y &>/dev/null
nload
msg -ama " $(fun_trans "Procedimento concluido")"
}

fun_htop () {
msg -azu " $(fun_trans "PARA SALIR DEL PANEL PRESIONE") \033[1;33mCTLR + C"
msg -bar
echo -ne " $(fun_trans "Deseja Prosseguir?")"; read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
#Inicia Procedimentos
msg -bar
[[ $(dpkg --get-selections|grep -w "htop"|head -1) ]] || apt-get install htop -y &>/dev/null
htop
msg -ama " $(fun_trans "Procedimento concluido")"
}

fun_glances () {
msg -azu " $(fun_trans "PARA SALIR DEL PANEL PRESIONE") \033[1;33mCTLR + C"
msg -azu " $(fun_trans "PARA SALIR DEL PANEL PRESIONE LA LETRA") \033[1;33mq"
msg -bar
echo -ne " $(fun_trans "Deseja Prosseguir?")"; read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
#Inicia Procedimentos
msg -bar
apt-get install python-pip build-essential python-dev -y &>/dev/null
apt install glances -y &>/dev/null
pip install Glances &>/dev/null
pip install PySensors &>/dev/null
glances
msg -ama " $(fun_trans "Procedimento concluido")"
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
msg -ama "$(fun_trans "MONITORAMENTO DO SISTEMA") "
msg -bar
echo -ne "$(msg -verd "[0]") $(msg -verm2 ">") " && msg -bra "$(fun_trans "VOLTAR")"
echo -ne "$(msg -verd "[1]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "TRAFICO DE RED NLOAD")"
echo -ne "$(msg -verd "[2]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "PROCESOS DE SISTEMA HTOP")"
echo -ne "$(msg -verd "[3]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "MONITOR DO SISTEMA GLANCES") $bet"
msg -bar
# FIM
selection=$(selection_fun 3)
case ${selection} in
1)fun_nload;;
2)fun_htop;;
3)fun_glances;;
0)exit;;
esac
msg -bar
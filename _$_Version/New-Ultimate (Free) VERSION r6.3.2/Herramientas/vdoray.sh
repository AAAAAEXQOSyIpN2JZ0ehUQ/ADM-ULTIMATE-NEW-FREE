#!/bin/bash

SCPdir="/etc/newadm"
SCPusr="${SCPdir}/ger-user"
SCPfrm="/etc/ger-frm"
SCPfrm3="/etc/adm-lite"
SCPinst="/etc/ger-inst"
SCPidioma="${SCPdir}/idioma"

declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;35m" [3]="\033[1;32m" [4]="\033[1;31m" [5]="\033[1;33m" [6]="\E[44;1;37m" [7]="\E[41;1;37m" )
barra="\033[0m\e[31m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

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
tput cuu1 && tput dl1
done
echo -e " \033[1;33m[\033[1;31m####################\033[1;33m] - \033[1;32m100%\033[0m"
sleep 1s
}
v2ray_ps () {
msg -bar
msg -ama " $(fun_trans "INSTALANDO V2RAY")"
source <(curl -sL https://git.io/fNgqx)
msg -bar
msg -ama " $(fun_trans "PARA SALIR PRECIONA CTRL + C")"
msg -bar
msg -ama " $(fun_trans "EJECUTE v2ray PARA ENTRAR AL MENÚ")"
msg -bar
v2ray stream
}

corregir_fun () {
echo -e " \033[1;36m $(fun_trans "INSTALAR V2RAY")"
echo -e "$barra"
while true; do
echo -e "${cor[4]} [1] > ${cor[5]}$(fun_trans "INSTALAR V2RAY")"
echo -e "${cor[4]} [2] > ${cor[5]}$(fun_trans "MENÚ V2RAY")"
echo -e "${cor[4]} [3] > ${cor[5]}$(fun_trans "INSTALAR TLS")"
echo -e "${cor[4]} [4] > ${cor[5]}$(fun_trans "V2RAY INFO")"
echo -e "${cor[4]} [5] > ${cor[0]}$(fun_trans "SALIR")"
echo -e "${cor[4]} [0] > ${cor[0]}$(fun_trans "VOLVER")\n${barra}"
while [[ ${opx} != @(0|[1-5]) ]]; do
echo -ne "${cor[0]}$(fun_trans "Digite una Opcion"): \033[1;37m" && read opx
tput cuu1 && tput dl1
done
case $opx in
	0)
	menu;;
	1)
	v2ray_ps
	break;;
	2)
	v2ray
	break;;
    3)
	v2ray tls
	break;;
	4)
	v2ray info
	break;;
    5)
	exit;;
  
esac
done
}
corregir_fun
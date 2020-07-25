#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;35m" [3]="\033[1;32m" [4]="\033[1;31m" [5]="\033[1;33m" [6]="\E[44;1;37m" [7]="\E[41;1;37m" )
barra="\033[0m\e[31m======================================================\033[1;37m"

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

act_hora () {
echo "America/Chihuahua" > /etc/timezone
ln -fs /usr/share/zoneinfo/America/Chihuahua /etc/localtime > /dev/null 2>&1
dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -e "$barra"
menu
}

act_hora1 () {
echo "America/Mexico_City" > /etc/timezone
ln -fs /usr/share/zoneinfo/America/Mexico_City /etc/localtime > /dev/null 2>&1
dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -e "$barra"
menu
}

act_hora2 () {
echo "America/Hermosillo" > /etc/timezone
ln -fs /usr/share/zoneinfo/America/Hermosillo /etc/localtime > /dev/null 2>&1
dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -e "$barra"
menu
}

shadowe_fun () {
echo -e " \033[1;36m $(fun_trans "ZONA HORARIO")"
echo -e "$barra"
while true; do
echo -e "${cor[4]} [1] > ${cor[5]}$(fun_trans "ACTUALIZAR HORARIO  CHICHUAHUA")"
echo -e "${cor[4]} [2] > ${cor[5]}$(fun_trans "ACTUALIZAR HORARIO  MEXICO")"
echo -e "${cor[4]} [3] > ${cor[5]}$(fun_trans "ACTUALIZAR HORARIO  HERMOSILLO")"
echo -e "${cor[4]} [4] > ${cor[0]}$(fun_trans "VOLVER")"
echo -e "${cor[4]} [0] > ${cor[0]}$(fun_trans "SALIR")\n${barra}"
while [[ ${opx} != @(0|[1-4]) ]]; do
echo -ne "${cor[0]}$(fun_trans "Digite una Opcion"): \033[1;37m" && read opx
tput cuu1 && tput dl1
done
case $opx in
	0)
	exit;;
	1)
	act_hora
	break;;
	2)
	act_hora1
	break;;
	3)
	act_hora2
	break;;
    4)
	menu;;
  
esac
done
}
shadowe_fun
#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

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

limpar_caches () {
(
VE="\033[1;33m" && MA="\033[1;31m" && DE="\033[1;32m"
while [[ ! -e /tmp/abc ]]; do
A+="#"
echo -e " ${VE}[${MA}${A}${VE}]" >&2
sleep 0.3s
tput cuu1 && tput dl1
done
echo -e " ${VE}[${MA}${A}${VE}] ${MA}- ${DE}100%" >&2
rm /tmp/abc
) &
echo 3 > /proc/sys/vm/drop_caches &>/dev/null
sleep 1s
sysctl -w vm.drop_caches=3 &>/dev/null
apt-get autoclean -y &>/dev/null
sleep 1s
apt-get clean -y &>/dev/null
rm /tmp/* &>/dev/null
touch /tmp/abc
sleep 0.5s
}

fun_limpram() {
	sync
	echo 3 >/proc/sys/vm/drop_caches
	sync && sysctl -w vm.drop_caches=3
	sysctl -w vm.drop_caches=0
	swapoff -a
	swapon -a
	sleep 4
}

function aguarde() {
	sleep 1
	helice() {
		fun_limpram >/dev/null 2>&1 &
		tput civis
		while [ -d /proc/$! ]; do
			for i in / - \\ \|; do
				sleep .1
				echo -ne "\e[1D$i"
			done
		done
		tput cnorm
	}
	echo -ne "\033[1;36m Limpando memoria \033[1;32mRAM \033[1;36me \033[1;32mSWAP\033[1;31m... \033[1;33m"
	helice
	echo -e "\e[1DOk"
}

fun_optimizer () {
clear
clear
msg -bar
[[ $(grep -wc mlocate /var/lib/dpkg/statoverride) != '0' ]] && sed -i '/mlocate/d' /var/lib/dpkg/statoverride
msg -ama " $(fun_trans "OTIMIZAR SISTEMA") \033[1;32m[NEW-ADM]"
msg -bar
echo -e "\033[1;36m Atualizando pacotes\033[0m"
fun_bar 'apt-get update -y' 'apt-get upgrade -y'
echo -e "\033[1;36m Corrigindo problemas de dependências"
fun_bar 'apt-get -f install'
echo -e "\033[1;36m Removendo pacotes inúteis"
fun_bar 'apt-get autoremove -y' 'apt-get autoclean -y'
echo -e "\033[1;36m Removendo pacotes com problemas"
fun_bar 'apt-get -f remove -y' 'apt-get clean -y'
# Limpar o cache memoria RAM
msg -bar
MEM1=$(free | awk '/Mem:/ {print int(100*$3/$2)}')
ram1=$(free -h | grep -i mem | awk {'print $2'})
ram2=$(free -h | grep -i mem | awk {'print $4'})
ram3=$(free -h | grep -i mem | awk {'print $3'})
swap1=$(free -h | grep -i swap | awk {'print $2'})
swap2=$(free -h | grep -i swap | awk {'print $4'})
swap3=$(free -h | grep -i swap | awk {'print $3'})
echo -e " \033[1;37mMemória \033[1;32mRAM \033[1;37mAntes da Otimizacao:\033[1;36m" $MEM1%
msg -bar
sleep 1
aguarde
limpar_caches
sleep 1
msg -bar
MEM2=$(free | awk '/Mem:/ {print int(100*$3/$2)}')
ram1=$(free -h | grep -i mem | awk {'print $2'})
ram2=$(free -h | grep -i mem | awk {'print $4'})
ram3=$(free -h | grep -i mem | awk {'print $3'})
swap1=$(free -h | grep -i swap | awk {'print $2'})
swap2=$(free -h | grep -i swap | awk {'print $4'})
swap3=$(free -h | grep -i swap | awk {'print $3'})
echo -e " \033[1;37mMemória \033[1;32mRAM \033[1;37mapós a Otimizacao:\033[1;36m" $MEM2%
msg -bra " $(fun_trans "Economia de"):\033[1;31m $(expr $MEM1 - $MEM2)%\033[0m"
msg -bar
msg -ama " $(fun_trans "Sucesso Procedimento Feito")"
msg -bar
}
fun_optimizer
#fin
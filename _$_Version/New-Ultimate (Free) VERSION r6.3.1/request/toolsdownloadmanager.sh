#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
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
tput cuu1
tput dl1
done
echo -e " \033[1;33m[\033[1;31m####################\033[1;33m] - \033[1;32m100%\033[0m"
sleep 1s
}

GENERADOR_BIN () {
wget -O /etc/ger-frm/GENERADOR_BIN.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/HerramientasADM/GENERADOR_BIN.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/GENERADOR_BIN.sh
fun_bar "chmod -R 777 /etc/ger-frm/GENERADOR_BIN.sh"
chmod -R 777 /etc/ger-frm/GENERADOR_BIN.sh > /dev/null 2>&1
echo -e "$barra"
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

MasterBin () {
wget -O /etc/ger-frm/MasterBin.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/HerramientasADM/MasterBin.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/MasterBin.sh
fun_bar "chmod -R 777 /etc/ger-frm/MasterBin.sh"
chmod -R 777 /etc/ger-frm/MasterBin.sh > /dev/null 2>&1
echo -e "$barra"
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

real-host () {
wget -O /etc/ger-frm/real-host.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/HerramientasADM/real-host.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/real-host.sh
fun_bar "chmod -R 777 /etc/ger-frm/real-host.sh"
chmod -R 777 /etc/ger-frm/real-host.sh > /dev/null 2>&1
echo -e "$barra"
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

dados () {
wget -O /etc/ger-frm/dados.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/HerramientasADM/dados.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/dados.sh
fun_bar "chmod -R 777 /etc/ger-frm/dados.sh"
chmod -R 777 /etc/ger-frm/dados.sh > /dev/null 2>&1
echo -e "$barra"
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

Crear-Demo () {
wget -O /etc/ger-frm/Crear-Demo.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/HerramientasADM/Crear-Demo.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/Crear-Demo.sh
fun_bar "chmod -R 777 /etc/ger-frm/Crear-Demo.sh"
chmod -R 777 /etc/ger-frm/Crear-Demo.sh > /dev/null 2>&1
echo -e "$barra"
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

squidpass () {
wget -O /etc/ger-frm/squidpass.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/HerramientasADM/squidpass.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/squidpass.sh
fun_bar "chmod -R 777 /etc/ger-frm/squidpass.sh"
chmod -R 777 /etc/ger-frm/squidpass.sh > /dev/null 2>&1
echo -e "$barra"
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

insta_painel () {
wget -O /etc/ger-frm/insta_painel https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/HerramientasADM/insta_painel > /dev/null 2>&1; chmod +x /etc/ger-frm/insta_painel
fun_bar "chmod -R 777 /etc/ger-frm/insta_painel"
chmod -R 777 /etc/ger-frm/insta_painel > /dev/null 2>&1
echo -e "$barra"
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

vnc () {
wget -O /etc/ger-frm/vnc.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/HerramientasADM/vnc.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/vnc.sh
fun_bar "chmod -R 777 /etc/ger-frm/vnc.sh"
chmod -R 777 /etc/ger-frm/vnc.sh > /dev/null 2>&1
echo -e "$barra"
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

msg -ama "$(fun_trans "TOOLS DOWNLOAD MANAGER") ${cor[4]}[NEW-ADM]"
echo -e "$barra"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "GERADOR DE BIN")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "CONSULTAR UN BIN")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "HOST EXTRACTOR")"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "MONITOR DE CONSUMO")"
echo -ne "\033[1;32m [5] > " && msg -azu "$(fun_trans "USUARIO TEMPORAL")"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "PROTECAO SQUID PASS")"
echo -ne "\033[1;32m [7] > " && msg -azu "$(fun_trans "PAINEL DE UPLOAD DE EHI")"
echo -ne "\033[1;32m [8] > " && msg -azu "$(fun_trans "VNC SERVER")"
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
echo -e "$barra"
while [[ ${arquivoonlineadm} != @(0|[1-9]) ]]; do
read -p "Selecione a Opcao: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)GENERADOR_BIN;;
2)MasterBin;;
3)real-host;;
4)dados;;
5)Crear-Demo;;
6)squidpass;;
7)insta_painel;;
8)vnc;;
esac
msg -bar
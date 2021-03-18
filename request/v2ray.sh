#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

intallv2ray () {
apt install python3-pip -y 
source <(curl -sL https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install//install-v2ray.sh)
msg -ama "$(fun_trans "Intalado con Exito")!"
msg -bar
msg -ne "Enter Para Continuar" && read enter
}

protocolv2ray () {
msg -ama "$(fun_trans "Escojer opcion 3 y poner el dominio de nuestra IP")!"
msg -bar
v2ray stream
msg -bar
msg -ne "Enter Para Continuar" && read enter
}

tls () {
msg -ama "$(fun_trans "Activar o Desactivar TLS")!"
msg -bar
v2ray tls
msg -bar
msg -ne "Enter Para Continuar" && read enter
}

portv () {
msg -ama "$(fun_trans "Cambiar Puerto v2ray")!"
msg -bar
v2ray port
msg -bar
msg -ne "Enter Para Continuar" && read enter
}

infocuenta () {
v2ray info
msg -bar
msg -ne "Enter Para Continuar" && read enter
}

stats () {
msg -ama "$(fun_trans "Estadisticas de Consumo")!"
msg -bar
v2ray stats
msg -bar
msg -ne "Enter Para Continuar" && read enter
}

unistallv2 () {
source <(curl -sL https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/install-v2ray.sh) --remove
msg -bar
msg -ne "Enter Para Continuar" && read enter
}

fun_v2ray () {
msg -ama "$(fun_trans " INSTALADOR V2RAY ADM-ULTIMATE")"
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "INSTALAR V2RAY") "
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "CAMBIAR PROTOCOLO") "
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "ACTIVAR TLS") "
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "CAMBIAR PUERTO V2RAY") "
echo -ne "\033[1;32m [5] > " && msg -azu "$(fun_trans "INFORMACION DE CUENTA")"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "ESTADISTICAS DE CONSUMO")"
echo -ne "\033[1;32m [7] > " && msg -azu "$(fun_trans "DESINTALAR V2RAY")"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-7]) ]]; do
read -p "[0-7]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)intallv2ray;;
2)protocolv2ray;;
3)tls;;
4)portv;;
5)infocuenta;;
6)stats;;
7)unistallv2;;
esac
}
fun_v2ray
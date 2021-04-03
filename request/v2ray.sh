#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;32m" [3]="\033[1;36m" [4]="\033[1;31m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

# https://github.com/Jrohy (19/12/2019 - k8.3.1)

intallv2ray () {
apt install python3-pip -y 
source <(curl -sL https://multi.netlify.app/v2ray.sh)
msg -ama "$(fun_trans "Intalado con Exito")!"
echo "#V2RAY ON" > /etc/v2ray-on
}

protocolv2ray () {
msg -ama "$(fun_trans "Escojer opcion 3 y poner el dominio de nuestra IP")!"
msg -bar
v2ray stream
}

tls () {
msg -ama "$(fun_trans "Activar o Desactivar TLS")!"
msg -bar
echo -ne "\033[1;97mTip elige opcion -1.open TLS- y eliges la opcion 1 para\ngenerar los certificados automaticamente y seguir los pasos\nsi te marca algun error esocjer la opcion 1 de nuevo pero\nahora elegir opcion 2 para gregar las rutas del certificado\nmanualmente.\n\033[1;93m
certificado = /root/cer.crt\nkey= /root/key.key\n\033[1;97m"
openssl genrsa -out key.key 2048 > /dev/null 2>&1
(echo ; echo ; echo ; echo ; echo ; echo ; echo ) | openssl req -new -key key.key -x509 -days 1000 -out cer.crt > /dev/null 2>&1
echo ""
v2ray tls
}

portv () {
msg -ama "$(fun_trans "Cambiar Puerto v2ray")!"
msg -bar
v2ray port
}

infocuenta () {
v2ray info
}

stats () {
msg -ama "$(fun_trans "Estadisticas de Consumo")!"
msg -bar
v2ray stats
}

unistallv2 () {
source <(curl -sL https://multi.netlify.app/v2ray.sh) --remove
rm -rf /etc/v2ray-on
}

msg -ama "$(fun_trans "INSTALAR V2RAY")"
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLVER")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "INSTALAR V2RAY") "
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "CAMBIAR PROTOCOLO")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "ACTIVAR TLS") "
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "CAMBIAR PUERTO V2RAY") "
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "INFORMACION DE CUENTA")"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "ESTADISTICAS DE CONSUMO")"
echo -ne "\033[1;32m [5] > " && msg -azu "$(fun_trans "DESINTALAR V2RAY")"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-5]) ]]; do
read -p "[0-5]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
1)intallv2ray;;
2)protocolv2ray;;
3)tls;;
4)infocuenta;;
5)unistallv2;;
0)exit;;
esac
msg -bar
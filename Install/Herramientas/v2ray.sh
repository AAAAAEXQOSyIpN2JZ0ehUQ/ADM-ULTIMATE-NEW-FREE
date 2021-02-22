#!/bin/bash
#19/12/2019
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
intallv2ray () {
apt install python3-pip -y 
source <(curl -sL https://raw.githubusercontent.com/VPS-MX/VPS-MX-8.0/master/ArchivosUtilitarios/V2RAY/install.sh)
msg -ama "$(fun_trans "Intalado con Exito")!"
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
unistallv2 () {
source <(curl -sL https://raw.githubusercontent.com/VPS-MX/VPS-MX-8.0/master/ArchivosUtilitarios/V2RAY/install.sh) --remove
}
infocuenta () {
v2ray info
}

msg -ama "$(fun_trans "MENU DE UTILITARIOS")"
msg -bar
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "INSTALAR V2RAY") "
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "CAMBIAR PROTOCOLO") "
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "ACTIVAR TLS") "
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "INFORMACION DE CUENTA")"
echo -ne "\033[1;32m [5] > " && msg -azu "$(fun_trans "DESINTALAR V2RAY")"
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLVER")"
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
#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
UNLOCK () {
sudo apt-get install libpam-cracklib -y > /dev/null 2>&1
wget https://raw.githubusercontent.com/VPS-MX/VPS-MX-8.0/master/ArchivosUtilitarios/common-password -O /etc/pam.d/common-password > /dev/null 2>&1
    chmod +x /etc/pam.d/common-password
msg -bar2
echo -e "${cor[4]}Pass Alfanumerico Desactivado con EXITO"
}
echo -e "${cor[2]}  Desactivar contraseñas Alfanumericas en VULTR"
echo -e "\033[1;34m Sepodra usar cualquier pass de 6 digitos"
msg -bar2
read -p " [ s | n ]: " UNLOCK   
[[ "$UNLOCK" = "s" || "$UNLOCK" = "S" ]] && UNLOCK
msg -bar2
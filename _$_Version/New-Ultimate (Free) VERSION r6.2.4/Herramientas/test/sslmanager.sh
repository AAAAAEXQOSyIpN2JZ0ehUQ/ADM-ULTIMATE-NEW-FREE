#!/bin/bash

SCPdir="/etc/newadm"
SCPusr="${SCPdir}/ger-user"
SCPfrm="/etc/ger-frm"
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
mportas () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}

ssl_iniciar () {
msg -bra " $(fun_trans "Que puerto desea abrir como SSL Openssh")"
msg -bar
    while true; do
    read -p " Puerto SSL: " SSLPORT
    [[ $(mportas|grep -w "$SSLPORT") ]] || break
    msg -ama "$(fun_trans "esta puerta está en uso")"
    unset SSLPORT
    done
msg -bar
msg -ama " $(fun_trans "Instalando SSL")"
msg -bar
fun_bar "apt-get install stunnel4 -y"
msg -bar
msg -azuc "Presione Enter a todas las opciones"
sleep 3
msg -bar
openssl genrsa 1024 > stunnel.key
openssl req -new -key stunnel.key -x509 -days 1000 -out stunnel.crt
cat stunnel.crt stunnel.key > stunnel.pem
mv stunnel.pem /etc/stunnel/
echo -e "client = no\n[ssh]\ncert = /etc/stunnel/stunnel.pem\naccept = ${SSLPORT}\nconnect = 127.0.0.1:22" > /etc/stunnel/stunnel.conf

echo "ENABLED=1 " >> /etc/default/stunnel4
echo "FILES="/etc/stunnel/*.conf" " >> /etc/default/stunnel4
echo "OPTIONS="" " >> /etc/default/stunnel4
echo "PPP_RESTART=0" >> /etc/default/stunnel4
service stunnel4 restart > /dev/null 2>&1
msg -bar
msg -ama " $(fun_trans "INSTALADO CON EXITO")"
msg -bar
}

ssl_portas () {
msg -bra "$(fun_trans "Que puerto desea agregar como SSL Openssh")"
msg -bar
    while true; do
    read -p " Puerto SSL: " SSLPORT1
    [[ $(mportas|grep -w "$SSLPORT1") ]] || break
    echo -e "$(fun_trans "esta puerta está en uso")"
    unset SSLPORT1
    done
msg -bar
msg -ama " $(fun_trans "Instalando SSL")"
msg -bar
fun_bar "apt-get install stunnel4"
msg -bar
msg -azuc "Presione Enter a todas las opciones"
sleep 3
msg -bar
openssl genrsa 1024 > stunnel.key
openssl req -new -key stunnel.key -x509 -days 1000 -out stunnel.crt
cat stunnel.crt stunnel.key > stunnel.pem
mv stunnel.pem /etc/stunnel/

echo "client = no" >> /etc/stunnel/stunnel.conf
echo "[ssh+]" >> /etc/stunnel/stunnel.conf
echo "cert = /etc/stunnel/stunnel.pem" >> /etc/stunnel/stunnel.conf
echo "accept = ${SSLPORT1}" >> /etc/stunnel/stunnel.conf
echo "connect = 127.0.0.1:22" >> /etc/stunnel/stunnel.conf

service stunnel4 restart > /dev/null 2>&1
msg -bar
msg -ama " $(fun_trans "AGREGADO CON EXITO")"
msg -bar
}
ssl_del () {
msg -bar
msg -ama " $(fun_trans "ELIMINANDO PUERTOS SSL")"
msg -bar
service stunnel4 stop
apt-get remove stunnel4 -y
apt-get purge stunnel4 -y
rm -rf /etc/stunnel/stunnel.conf
rm -rf /etc/default/stunnel4
rm -rf /etc/stunnel/stunnel.pem
msg -bar
msg -ama " $(fun_trans "LOS PUERTOS SSL SEAN DETENIDO CON EXITO")"
msg -bar
}
inst_sslt () {
wget -O $HOME/ssl.sh https://www.dropbox.com/s/833a2nhtzskolfw/ssl.sh &>/dev/null
chmod +x $HOME/ssl.sh
cd $HOME
./ssl.sh
rm $HOME/ssl.sh &>/dev/null
}
multi_ssl () {
wget -O $HOME/multissl.sh https://www.dropbox.com/s/h5kzdymmd632jaq/multissl.sh &> /dev/null
chmod +x $HOME/multissl.sh
cd $HOME
./multissl.sh
rm $HOME/multissl.sh &>/dev/null
}
shadow_fun () {
echo -e " \033[1;36m SSL MANAGER OPENSSH"
echo -e "$barra"
while true; do
echo -e "${cor[4]} [1] > ${cor[5]}$(fun_trans "INSTALAR SSL MANUAL-OPENSSH")"
echo -e "${cor[5]} [2] > ${cor[2]}$(fun_trans "INSTALAR SSL DIRECTO")"
echo -e "${cor[4]} [3] > ${cor[5]}$(fun_trans "ABRIR MAS PUERTOS SSL MANUAL")"
echo -e "${cor[5]} [4] > ${cor[2]}$(fun_trans "REDIRECCIONAR SSL")"
echo -e "${cor[5]} [5] > ${cor[4]}$(fun_trans "DETENER EL PUERTO SSL")"
echo -e "${cor[4]} [6] > ${cor[0]}$(fun_trans "SALIR")"
echo -e "${cor[4]} [0] > ${cor[0]}$(fun_trans "VOLVER")\n${barra}"
while [[ ${opx} != @(0|[1-5]) ]]; do
echo -ne "${cor[0]}$(fun_trans "Digite una Opcion"): \033[1;37m" && read opx
tput cuu1 && tput dl1
done
case $opx in
	0)
	menu;;
	1)
	ssl_iniciar
	break;;
	2)
	inst_sslt
	break;;
	3)
	ssl_portas
	break;;
	4)
	multi_ssl
	break;;
	5)
	ssl_del
	break;;
   6)
	exit;;
  
esac
done
}
shadow_fun
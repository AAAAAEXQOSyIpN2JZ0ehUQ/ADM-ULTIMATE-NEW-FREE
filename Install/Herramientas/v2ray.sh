#!/bin/bash
#25/01/2021 by @Kalix1
clear
clear
SCPdir="/etc/VPS-MX"
SCPfrm="${SCPdir}/herramientas" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="${SCPdir}/protocolos"&& [[ ! -d ${SCPinst} ]] && exit
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
err_fun () {
     case $1 in
     1)msg -verm "$(fun_trans "Usuario Nulo")"; sleep 2s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
     2)msg -verm "$(fun_trans "Nombre muy corto (MIN: 2 CARACTERES)")"; sleep 2s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
     3)msg -verm "$(fun_trans "Nombre muy grande (MAX: 5 CARACTERES)")"; sleep 2s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
     4)msg -verm "$(fun_trans "Contraseña Nula")"; sleep 2s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
     5)msg -verm "$(fun_trans "Contraseña muy corta")"; sleep 2s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
     6)msg -verm "$(fun_trans "Contraseña muy grande")"; sleep 2s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
     7)msg -verm "$(fun_trans "Duracion Nula")"; sleep 2s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
     8)msg -verm "$(fun_trans "Duracion invalida utilize numeros")"; sleep 2s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
     9)msg -verm "$(fun_trans "Duracion maxima y de un año")"; sleep 2s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
     11)msg -verm "$(fun_trans "Limite Nulo")"; sleep 2s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
     12)msg -verm "$(fun_trans "Limite invalido utilize numeros")"; sleep 2s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
     13)msg -verm "$(fun_trans "Limite maximo de 999")"; sleep 2s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
     14)msg -verm "$(fun_trans "Usuario Ya Existe")"; sleep 2s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
	 15)msg -verm "$(fun_trans "(Solo numeros) GB = Min: 1gb Max: 1000gb")"; sleep 2s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
	 16)msg -verm "$(fun_trans "(Solo numeros)")"; sleep 2s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
	 17)msg -verm "$(fun_trans "(Sin Informacion - Para Cancelar Digite CRTL + C)")"; sleep 4s; tput cuu1; tput dl1; tput cuu1; tput dl1;;
     esac
}
intallv2ray () {
apt install python3-pip -y 
source <(curl -sL https://www.dropbox.com/s/ukkyksfdo3lqqmc/install-v2ray.sh)
msg -ama "$(fun_trans "Intalado con Exito")!"
USRdatabase="/etc/VPS-MX/RegV2ray"
[[ ! -e ${USRdatabase} ]] && touch ${USRdatabase}
sort ${USRdatabase} | uniq > ${USRdatabase}tmp
mv -f ${USRdatabase}tmp ${USRdatabase}
msg -bar
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh

}
protocolv2ray () {
msg -ama "$(fun_trans "Escojer opcion 3 y poner el dominio de nuestra IP")!"
msg -bar
v2ray stream
msg -bar
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh
}
dirapache="/usr/local/lib/ubuntn/apache/ver" && [[ ! -d ${dirapache} ]] && exit
tls () {
msg -ama "$(fun_trans "Activar o Desactivar TLS")!"
msg -bar
v2ray tls
msg -bar
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh
}
portv () {
msg -ama "$(fun_trans "Cambiar Puerto v2ray")!"
msg -bar
v2ray port
msg -bar
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh
}
stats () {
msg -ama "$(fun_trans "Estadisticas de Consumo")!"
msg -bar
v2ray stats
msg -bar
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh
}
unistallv2 () {
source <(curl -sL https://www.dropbox.com/s/ukkyksfdo3lqqmc/install-v2ray.sh) --remove > /dev/null 2>&1
rm -rf /etc/VPS-MX/RegV2ray > /dev/null 2>&1
echo -e "\033[1;92m                  V2RAY REMOVIDO OK "
msg -bar
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh
}
infocuenta () {
v2ray info
msg -bar
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh
}
addusr () {
clear 
clear
msg -bar
msg -tit
msg -ama "             AGREGAR USUARIO | UUID V2RAY"
msg -bar
##DAIS
valid=$(date '+%C%y-%m-%d' -d " +31 days")		  
##CORREO		  
MAILITO=$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c 10)
##ADDUSERV2RAY		  
UUID=`uuidgen`	  
sed -i '13i\           \{' /etc/v2ray/config.json
sed -i '14i\           \"alterId": 0,' /etc/v2ray/config.json
sed -i '15i\           \"id": "'$UUID'",' /etc/v2ray/config.json
sed -i '16i\           \"email": "'$MAILITO'@gmail.com"' /etc/v2ray/config.json
sed -i '17i\           \},' /etc/v2ray/config.json
echo ""
while true; do
echo -ne "\e[91m >> Digita un Nombre: \033[1;92m"
     read -p ": " nick
     nick="$(echo $nick|sed -e 's/[^a-z0-9 -]//ig')"
     if [[ -z $nick ]]; then
     err_fun 17 && continue
     elif [[ "${#nick}" -lt "2" ]]; then
     err_fun 2 && continue
     elif [[ "${#nick}" -gt "5" ]]; then
     err_fun 3 && continue
     fi
     break
done
echo -e "\e[91m >> Agregado UUID: \e[92m$UUID "
while true; do
     echo -ne "\e[91m >> Duracion de UUID (Dias):\033[1;92m " && read diasuser
     if [[ -z "$diasuser" ]]; then
     err_fun 17 && continue
     elif [[ "$diasuser" != +([0-9]) ]]; then
     err_fun 8 && continue
     elif [[ "$diasuser" -gt "360" ]]; then
     err_fun 9 && continue
     fi 
     break
done
#Lim
[[ $(cat /etc/passwd |grep $1: |grep -vi [a-z]$1 |grep -v [0-9]$1 > /dev/null) ]] && return 1
valid=$(date '+%C%y-%m-%d' -d " +$diasuser days") && datexp=$(date "+%F" -d " + $diasuser days")
echo -e "\e[91m >> Expira el : \e[92m$datexp "
##Registro
echo "  $UUID | $nick | $valid " >> /etc/VPS-MX/RegV2ray
v2ray restart > /dev/null 2>&1
echo ""
v2ray info > /etc/VPS-MX/v2ray/confuuid.log
lineP=$(sed -n '/'${UUID}'/=' /etc/VPS-MX/v2ray/confuuid.log)
numl1=4
let suma=$lineP+$numl1
sed -n ${suma}p /etc/VPS-MX/v2ray/confuuid.log 
echo ""
msg -bar
echo -e "\e[92m           UUID AGREGEGADO CON EXITO "
msg -bar
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh
}

delusr () {
clear 
clear
invaliduuid () {
msg -bar
echo -e "\e[91m                    UUID INVALIDO \n$(msg -bar)"
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh
}
msg -bar
msg -tit
msg -ama "             ELIMINAR USUARIO | UUID V2RAY"
msg -bar
echo -e "\e[97m               USUARIOS REGISTRADOS"
echo -e "\e[33m$(cat /etc/VPS-MX/RegV2ray|cut -d '|' -f2,1)" 
msg -bar
echo -ne "\e[91m >> Digita el UUID a elininar:\n \033[1;92m " && read uuidel
[[ $(sed -n '/'${uuidel}'/=' /etc/v2ray/config.json|head -1) ]] || invaliduuid
lineP=$(sed -n '/'${uuidel}'/=' /etc/v2ray/config.json)
linePre=$(sed -n '/'${uuidel}'/=' /etc/VPS-MX/RegV2ray)
sed -i "${linePre}d" /etc/VPS-MX/RegV2ray
numl1=2
let resta=$lineP-$numl1
sed -i "${resta}d" /etc/v2ray/config.json
sed -i "${resta}d" /etc/v2ray/config.json
sed -i "${resta}d" /etc/v2ray/config.json
sed -i "${resta}d" /etc/v2ray/config.json
sed -i "${resta}d" /etc/v2ray/config.json
v2ray restart > /dev/null 2>&1
msg -bar
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh
}

mosusr_kk() {
clear 
clear
msg -bar
msg -tit
msg -ama "         USUARIOS REGISTRADOS | UUID V2RAY"
msg -bar
# usersss=$(cat /etc/VPS-MX/RegV2ray|cut -d '|' -f1)
# cat /etc/VPS-MX/RegV2ray|cut -d'|' -f3
VPSsec=$(date +%s)
local HOST="/etc/VPS-MX/RegV2ray"
local HOST2="/etc/VPS-MX/RegV2ray"
local RETURN="$(cat $HOST|cut -d'|' -f2)"
local IDEUUID="$(cat $HOST|cut -d'|' -f1)"
if [[ -z $RETURN ]]; then
echo -e "----- NINGUN USER REGISTRADO -----"
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh

else
i=1
echo -e "\e[97m                 UUID                | USER | EXPIRACION \e[93m"
msg -bar
while read hostreturn ; do
DateExp="$(cat /etc/VPS-MX/RegV2ray|grep -w "$hostreturn"|cut -d'|' -f3)"
if [[ ! -z $DateExp ]]; then             
DataSec=$(date +%s --date="$DateExp")
[[ "$VPSsec" -gt "$DataSec" ]] && EXPTIME="\e[91m[EXPIRADO]\e[97m" || EXPTIME="\e[92m[$(($(($DataSec - $VPSsec)) / 86400))]\e[97m Dias"
else
EXPTIME="\e[91m[ S/R ]"
fi 
usris="$(cat /etc/VPS-MX/RegV2ray|grep -w "$hostreturn"|cut -d'|' -f2)"
local contador_secuencial+="\e[93m$hostreturn \e[97m|\e[93m$usris\e[97m|\e[93m $EXPTIME \n"           
      if [[ $i -gt 30 ]]; then
	      echo -e "$contador_secuencial"
	  unset contador_secuencial
	  unset i
	  fi
let i++
done <<< "$IDEUUID"

[[ ! -z $contador_secuencial ]] && {
linesss=$(cat /etc/VPS-MX/RegV2ray | wc -l)
	      echo -e "$contador_secuencial \n Numero de Registrados: $linesss"
	}
fi
msg -bar
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh
}
lim_port () {
clear 
clear
msg -bar
msg -tit
msg -ama "          LIMITAR MB X PORT | UUID V2RAY"
msg -bar
###VER
estarts () {
VPSsec=$(date +%s)
local HOST="/etc/VPS-MX/v2ray/lisportt.log"
local HOST2="/etc/VPS-MX/v2ray/lisportt.log"
local RETURN="$(cat $HOST|cut -d'|' -f2)"
local IDEUUID="$(cat $HOST|cut -d'|' -f1)"
if [[ -z $RETURN ]]; then
echo -e "----- NINGUN PUERTO REGISTRADO -----"
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh
else
i=1
while read hostreturn ; do
iptables -n -v -L > /etc/VPS-MX/v2ray/data1.log 
statsss=$(cat /etc/VPS-MX/v2ray/data1.log|grep -w "tcp spt:$hostreturn quota:"|cut -d' ' -f3,4,5)
gblim=$(cat /etc/VPS-MX/v2ray/lisportt.log|grep -w "$hostreturn"|cut -d'|' -f2)
local contador_secuencial+="         \e[97mPUERTO: \e[93m$hostreturn \e[97m|\e[93m$statsss \e[97m|\e[93m $gblim GB  \n"          
      if [[ $i -gt 30 ]]; then
	      echo -e "$contador_secuencial"
	  unset contador_secuencial
	  unset i
	  fi
let i++
done <<< "$IDEUUID"

[[ ! -z $contador_secuencial ]] && {
linesss=$(cat /etc/VPS-MX/v2ray/lisportt.log | wc -l)
	      echo -e "$contador_secuencial \n Puertos Limitados: $linesss"
	}
fi
msg -bar
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh 
}
###LIM
liport () {
while true; do
     echo -ne "\e[91m >> Digite Port a Limitar:\033[1;92m " && read portbg
     if [[ -z "$portbg" ]]; then
     err_fun 17 && continue
     elif [[ "$portbg" != +([0-9]) ]]; then
     err_fun 16 && continue
     elif [[ "$portbg" -gt "1000" ]]; then
     err_fun 16 && continue
     fi 
     break
done
while true; do
     echo -ne "\e[91m >> Digite Cantidad de GB:\033[1;92m " && read capgb
     if [[ -z "$capgb" ]]; then
     err_fun 17 && continue
     elif [[ "$capgb" != +([0-9]) ]]; then
     err_fun 15 && continue
     elif [[ "$capgb" -gt "1000" ]]; then
     err_fun 15 && continue
     fi 
     break
done
uml1=1073741824
gbuser="$capgb"
let multiplicacion=$uml1*$gbuser
sudo iptables -I OUTPUT -p tcp --sport $portbg -j DROP
sudo iptables -I OUTPUT -p tcp --sport $portbg -m quota --quota $multiplicacion -j ACCEPT
iptables-save > /etc/iptables/rules.v4
echo ""
echo -e " Port Seleccionado: $portbg | Cantidad de GB: $gbuser"
echo ""
echo " $portbg | $gbuser | $multiplicacion " >> /etc/VPS-MX/v2ray/lisportt.log 
msg -bar
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh
}
###RES
resdata () {
VPSsec=$(date +%s)
local HOST="/etc/VPS-MX/v2ray/lisportt.log"
local HOST2="/etc/VPS-MX/v2ray/lisportt.log"
local RETURN="$(cat $HOST|cut -d'|' -f2)"
local IDEUUID="$(cat $HOST|cut -d'|' -f1)"
if [[ -z $RETURN ]]; then
echo -e "----- NINGUN PUERTO REGISTRADO -----"
return 0
else
i=1
while read hostreturn ; do
iptables -n -v -L > /etc/VPS-MX/v2ray/data1.log 
statsss=$(cat /etc/VPS-MX/v2ray/data1.log|grep -w "tcp spt:$hostreturn quota:"|cut -d' ' -f3,4,5)
gblim=$(cat /etc/VPS-MX/v2ray/lisportt.log|grep -w "$hostreturn"|cut -d'|' -f2)
local contador_secuencial+="         \e[97mPUERTO: \e[93m$hostreturn \e[97m|\e[93m$statsss \e[97m|\e[93m $gblim GB  \n"  
        
      if [[ $i -gt 30 ]]; then
	      echo -e "$contador_secuencial"
	  unset contador_secuencial
	  unset i
	  fi
let i++
done <<< "$IDEUUID"

[[ ! -z $contador_secuencial ]] && {
linesss=$(cat /etc/VPS-MX/v2ray/lisportt.log | wc -l)
	      echo -e "$contador_secuencial \n Puertos Limitados: $linesss"
	}
fi
msg -bar

while true; do
     echo -ne "\e[91m >> Digite Puerto a Limpiar:\033[1;92m " && read portbg
     if [[ -z "$portbg" ]]; then
     err_fun 17 && continue
     elif [[ "$portbg" != +([0-9]) ]]; then
     err_fun 16 && continue
     elif [[ "$portbg" -gt "1000" ]]; then
     err_fun 16 && continue
     fi 
     break
done
invaliduuid () {
msg -bar
echo -e "\e[91m                PUERTO INVALIDO \n$(msg -bar)"
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh
}
[[ $(sed -n '/'${portbg}'/=' /etc/VPS-MX/v2ray/lisportt.log|head -1) ]] || invaliduuid
gblim=$(cat /etc/VPS-MX/v2ray/lisportt.log|grep -w "$portbg"|cut -d'|' -f3)
sudo iptables -D OUTPUT -p tcp --sport $portbg -j DROP
sudo iptables -D OUTPUT -p tcp --sport $portbg -m quota --quota $gblim -j ACCEPT
iptables-save > /etc/iptables/rules.v4
lineP=$(sed -n '/'${portbg}'/=' /etc/VPS-MX/v2ray/lisportt.log)
sed -i "${linePre}d" /etc/VPS-MX/v2ray/lisportt.log
msg -bar
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh 
}
## MENU
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "LIMITAR DATA x PORT") "
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "RESETEAR DATA DE PORT") "
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "VER DATOS CONSUMIDOS") "
echo -ne "$(msg -bar)\n\033[1;32m [0] > " && msg -bra "\e[97m\033[1;41m VOLVER \033[1;37m"
msg -bar
selection=$(selection_fun 3)
case ${selection} in
1)liport ;;
2)resdata;;
3)estarts;;
0)
${SCPinst}/v2ray.sh
;;
esac
}

limpiador_activador () {
unset PIDGEN
PIDGEN=$(ps aux|grep -v grep|grep "limv2ray")
if [[ ! $PIDGEN ]]; then
screen -dmS limv2ray watch -n 21600 limv2ray
else
#killall screen
screen -S limv2ray -p 0 -X quit
fi
unset PID_GEN
PID_GEN=$(ps x|grep -v grep|grep "limv2ray")
[[ ! $PID_GEN ]] && PID_GEN="\e[91m [ DESACTIVADO ] " || PID_GEN="\e[92m [ ACTIVADO ] "
statgen="$(echo $PID_GEN)"
clear 
clear
msg -bar
msg -tit
msg -ama "          ELIMINAR EXPIRADOS | UUID V2RAY"
msg -bar
echo ""
echo -e "                    $statgen " 
echo "" 						
msg -bar
msg -ne "Enter Para Continuar" && read enter
${SCPinst}/v2ray.sh

}

selection_fun () {
local selection="null"
local range
for((i=0; i<=$1; i++)); do range[$i]="$i "; done
while [[ ! $(echo ${range[*]}|grep -w "$selection") ]]; do
echo -ne "\033[1;37m$(fun_trans " ► Selecione una Opcion"): " >&2
read selection
tput cuu1 >&2 && tput dl1 >&2
done
echo $selection
}

PID_GEN=$(ps x|grep -v grep|grep "limv2ray")
[[ ! $PID_GEN ]] && PID_GEN="\e[91m [ DESACTIVADO ] " || PID_GEN="\e[92m [ ACTIVADO ] "
statgen="$(echo $PID_GEN)"
SPR & 
msg -bar3
msg -bar
msg -tit
msg -ama "$(fun_trans "        INSTALADOR DE V2RAY (PASO A PASO) ")"
msg -bar
## INSTALADOR
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "INSTALAR V2RAY") "
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "CAMBIAR PROTOCOLO") "
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "ACTIVAR TLS") "
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "CAMBIAR PUERTO V2RAY")\n$(msg -bar) "
## CONTROLER
echo -ne "\033[1;32m [5] > " && msg -azu "AGREGAR USUARIO UUID "
echo -ne "\033[1;32m [6] > " && msg -azu "ELIMINAR USUARIO UUID"
echo -ne "\033[1;32m [7] > " && msg -azu "MOSTAR USUARIOS REGISTRADOS"
echo -ne "\033[1;32m [8] > " && msg -azu "INFORMACION DE CUENTAS"
echo -ne "\033[1;32m [9] > " && msg -azu "ESTADISTICAS DE CONSUMO "
echo -ne "\033[1;32m [10] > " && msg -azu "LIMITADOR POR CONSUMO\e[91m ( BETA x PORT )"
echo -ne "\033[1;32m [11] > " && msg -azu "LIMPIADOR DE EXPIRADOS ------- $statgen\n$(msg -bar)"
## DESISNTALAR
echo -ne "\033[1;32m [12] > " && msg -azu "\033[1;31mDESINSTALAR V2RAY"
echo -ne "$(msg -bar)\n\033[1;32m [0] > " && msg -bra "\e[97m\033[1;41m VOLVER \033[1;37m"
msg -bar
pid_inst () {
[[ $1 = "" ]] && echo -e "\033[1;31m[OFF]" && return 0
unset portas
portas_var=$(lsof -V -i -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND")
i=0
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e ${portas[@]}|grep "$var1 $var2")" ]] || {
    portas[$i]="$var1 $var2\n"
    let i++
    }
done <<< "$portas_var"
[[ $(echo "${portas[@]}"|grep "$1") ]] && echo -e "\033[1;32m[ Servicio Activo ]" || echo -e "\033[1;31m[ Servicio Desactivado ]"
}
echo -e "         \e[97mEstado actual: $(pid_inst v2ray)"
msg -bar
# while [[ ${arquivoonlineadm} != @(0|[1-99]) ]]; do
# read -p "Seleccione una Opcion [0-12]: " arquivoonlineadm
# tput cuu1 && tput dl1
# done
selection=$(selection_fun 18)
case ${selection} in
1)intallv2ray;;
2)protocolv2ray;;
3)tls;;
4)portv;;
5)addusr;;
6)delusr;;
7)mosusr_kk;;
8)infocuenta;;
9)stats;;
10)lim_port;;
11)limpiador_activador;;
12)unistallv2;;
0)exit;;
esac
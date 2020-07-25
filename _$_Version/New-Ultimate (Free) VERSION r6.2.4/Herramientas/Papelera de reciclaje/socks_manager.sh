#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

#LIPIAR SCRIPTS
rm -rf /bin/ssld.sh > /dev/null 2>&1
rm -rf /bin/sslmanager.sh > /dev/null 2>&1
rm -rf /bin/hora.sh > /dev/null 2>&1
rm -rf /bin/insta_plusconeccion.sh > /dev/null 2>&1
rm -rf /bin/pan_cracklib.sh > /dev/null 2>&1

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

cleanreg () {
echo -ne " \033[1;31m[ ! ] Registro del limitador eliminado"
sudo rm -rf /etc/newadm/ger-user/Limiter.log > /dev/null 2>&1 && echo -e "\033[1;32m [OK]"
echo -e "$barra"
sleep 3s
adm
}

userdell () {
echo -e "\033[1;33mATENCION ESTO REMOVERA TODOS LOS USUARIOS\033[0m"
echo -e "\033[1;33mNO FUNCIONA CON OPENVPN\033[0m"
echo -e "$barra"
read -p "Opcion [S/N]: " -e -i s remov
if [ "$remov" = "s" ]
then
for u in `awk -F : '$3 > 900 { print $1 }' /etc/passwd | grep -v "nobody" |grep -vi polkitd |grep -vi system-`; do
userdel $u
done
echo -e "$barra"
echo -e "\033[1;31mUSUARIOS ELIMINADOS CON EXITO [OK]!\033[0m"
echo -e "$barra"
else
echo -e "$barra"
echo -e "\033[1;31mOPERACION CANCELADA\033[0m"
echo -e "$barra"
  sleep 5s
adm
fi
 }

ssl_redir() {
msg -bra "$(fun_trans "Asigne un nombre para el redirecionador")"
msg -bar
read -p " nombre: " namer
msg -bar
msg -ama "$(fun_trans "A que puerto redirecionara el puerto SSL")"
msg -ama "$(fun_trans "Es decir un puerto abierto en su servidor")"
msg -ama "$(fun_trans "Ejemplo Dropbear, OpenSSH, ShadowSocks, OpenVPN, Etc")"
msg -bar
read -p " Local-Port: " portd
msg -bar
msg -ama "$(fun_trans "Que puerto desea agregar como SSL")"
msg -bar
    while true; do
    read -p " Puerto SSL: " SSLPORTr
    [[ $(mportas|grep -w "$SSLPORTr") ]] || break
    msg -bar
    echo -e "$(fun_trans "${cor[0]}Esta puerta está en uso")"
    msg -bar
    unset SSLPORT1
    done

echo "" >> /etc/stunnel/stunnel.conf
echo "[${namer}]" >> /etc/stunnel/stunnel.conf
echo "connect = 127.0.0.1:${portd}" >> /etc/stunnel/stunnel.conf
echo "accept = ${SSLPORTr}" >> /etc/stunnel/stunnel.conf
echo "client = no" >> /etc/stunnel/stunnel.conf


service stunnel4 restart > /dev/null 2>&1
msg -bar
msg -bra " $(fun_trans "AGREGADO CON EXITO") ${cor[2]}[!OK]"
msg -bar
}

gestor_fun () {
echo -e " ${cor[3]} $(fun_trans "PROXY MANAGER 2 BETA-TESTER") ${cor[4]}[NEW-ADM]"
echo -e " ${cor[3]} $(fun_trans "herramienta en modo de prueba")"
echo -e "$barra"
while true; do
echo -e "${cor[4]} [1] > \033[1;36m$(fun_trans "SSL Manager")"
echo -e "${cor[4]} [2] > \033[1;36m$(fun_trans "SSL MANAGERS")"
echo -e "${cor[4]} [3] > \033[1;36m$(fun_trans "ACTUALIZAR ZONA HORARIO")"
echo -e "${cor[4]} [4] > \033[1;36m$(fun_trans "MENU SSHPLUS CONECCION")"
echo -e "$barra"
echo -e "${cor[4]} [5] > \033[1;36m$(fun_trans "LIBERAR VPS VURTL PARA CREAR USUARIOS")"
echo -e "${cor[4]} [6] > \033[1;36m$(fun_trans "NO DISPONIBLE")"
echo -e "$barra"
echo -e "${cor[4]} [7] > \033[1;36m$(fun_trans "Eliminar Registro del Limitador")"
echo -e "${cor[4]} [8] > \033[1;36m$(fun_trans "Eliminar todos los usuarios del VPS")"
echo -e "$barra"
echo -e "${cor[4]} [9] > \033[1;36m$(fun_trans "Multi portos SSL")"
echo -e "${cor[4]} [0] > ${cor[0]}$(fun_trans "VOLTAR")\n${barra}"
while [[ ${opx} != @(0|[1-9]) ]]; do
echo -ne "${cor[0]}$(fun_trans "Digite a Opcao"): \033[1;37m" && read opx
tput cuu1 && tput dl1
done
case $opx in
	0)
	return;;
	1)
	wget -O /bin/ssld.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/test/ssld.sh > /dev/null 2>&1; chmod +x /bin/ssld.sh; ssld.sh 
	break;;
	2)
	wget -O /bin/sslmanager.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/test/sslmanager.sh > /dev/null 2>&1; chmod +x /bin/sslmanager.sh; sslmanager.sh
	break;;
	3)
	wget -O /bin/hora.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/test/hora.sh > /dev/null 2>&1; chmod +x /bin/hora.sh; hora.sh
	break;;
	4)
	wget -O /bin/insta_plusconeccion.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/test/insta_plusconeccion.sh > /dev/null 2>&1; chmod +x /bin/insta_plusconeccion.sh; insta_plusconeccion.sh
	break;;
	5)
	wget -O /bin/pan_cracklib.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/test/pan_cracklib.sh > /dev/null 2>&1; chmod +x /bin/pan_cracklib.sh; pan_cracklib.sh
	break;;
        6)
	return;;
        7)
	cleanreg
	break;;
        8)
	userdell
	break;;
        9)
	ssl_redir
	break;;
esac
done
}
gestor_fun
#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

#LIPIAR SCRIPTS
rm -rf /bin/conexao.sh > /dev/null 2>&1
rm -rf /bin/shadown.sh > /dev/null 2>&1
rm -rf /bin/shadowsocks.sh > /dev/null 2>&1
rm -rf /bin/shadowsock.sh > /dev/null 2>&1
rm -rf /bin/ssrrmu.sh > /dev/null 2>&1
rm -rf /bin/v2ray.sh > /dev/null 2>&1
rm -rf /bin/vdoray.sh > /dev/null 2>&1

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

menu () {
echo -ne " \033[1;31m[ ! ] Instalando Menu Beta v.2"
wget -O /etc/newadm/menu https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/menu > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Cocediendo Permisos"
chmod 777 /etc/newadm/menu > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Accediendo al menu... \033[1;32m [OK]"
sleep 3
chmod 777 /etc/newadm/menu; /etc/newadm/menu

echo -e "$barra"
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

service stunnel4 restart > /dev/null 2>&1
msg -bar
msg -bra " $(fun_trans "AGREGADO CON EXITO") ${cor[2]}[!OK]"
msg -bar
}

gestor_fun () {
echo -e " ${cor[4]} [0] > ${cor[0]}$(fun_trans "VOLTAR")"
echo -e " ${cor[3]} $(fun_trans "PROXY MANAGER - BETA-TESTER") ${cor[4]}[NEW-ADM]"
echo -e " ${cor[3]} $(fun_trans "herramienta en modo de prueba")"
echo -e "$barra"
while true; do
echo -e "${cor[4]} [1] > \033[1;36m$(fun_trans "Menu SSHPlus Coneccion ")"
echo -e "$barra"
echo -e "${cor[4]} [2] > \033[1;36m$(fun_trans "Menu Beta v.2")"
echo -e "$barra"
echo -e "${cor[4]} [3] > \033[1;36m$(fun_trans "Multi portos SSL")"
echo -e "$barra"
echo -e "${cor[4]} [4] > \033[1;36m$(fun_trans "Shadowsocks Cloack")"
echo -e "${cor[4]} [5] > \033[1;36m$(fun_trans "Shadowsocks-Libev")"
echo -e "${cor[4]} [6] > \033[1;36m$(fun_trans "Shadowsocks-R,Go,Liv")"
echo -e "${cor[4]} [7] > \033[1;36m$(fun_trans "ShadowsocksR Manager")"
echo -e "$barra"
echo -e "${cor[4]} [8] > \033[1;36m$(fun_trans "V2ray Panel")"
echo -e "${cor[4]} [9] > \033[1;36m$(fun_trans "V2ray Manager")\n${barra}"
while [[ ${opx} != @(0|[1-9]) ]]; do
echo -ne "${cor[0]}$(fun_trans "Digite a Opcao"): \033[1;37m" && read opx
tput cuu1 && tput dl1
done
case $opx in
	0)
	return;;
	1)
	wget -O /bin/conexao.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/conexao.sh > /dev/null 2>&1; chmod +x /bin/conexao.sh; conexao.sh
	break;;
	2)
	menu
	break;;
	3)
	ssl_redir
	break;;
	4)
	wget -O /bin/shadown.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/shadown.sh > /dev/null 2>&1; chmod +x /bin/shadown.sh; shadown.sh
	break;;
	5)
	wget -O /bin/shadowsocks.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/shadowsocks.sh > /dev/null 2>&1; chmod +x /bin/shadowsocks.sh; shadowsocks.sh
	break;;
        6)
	wget -O /bin/shadowsock.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/shadowsock.sh > /dev/null 2>&1; chmod +x /bin/shadowsock.sh; shadowsock.sh
	break;;
        7)
	wget -O /bin/ssrrmu.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/ssrrmu.sh > /dev/null 2>&1; chmod +x /bin/ssrrmu.sh; ssrrmu.sh
	break;;
        8)
	wget -O /bin/v2ray.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/v2ray.sh > /dev/null 2>&1; chmod +x /bin/v2ray.sh; v2ray.sh
	break;;
        9)
	wget -O /bin/vdoray.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/vdoray.sh > /dev/null 2>&1; chmod +x /bin/vdoray.sh; vdoray.sh
	break;;
esac
done
}
gestor_fun
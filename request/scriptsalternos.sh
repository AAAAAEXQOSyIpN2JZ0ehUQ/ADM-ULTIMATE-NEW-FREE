#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

#LIPIAR SCRIPTS
rm -rf /bin/conexao.sh > /dev/null 2>&1
rm -rf /bin/C-SSR.sh
rm -rf /bin/Shadowsocks-libev.sh
rm -rf /bin/Shadowsocks-R.sh
rm -rf /bin/shadowsocks.sh
rm -rf /bin/v2ray.sh > /dev/null 2>&1
rm -rf /bin/vdoray.sh > /dev/null 2>&1

ssl_redir() {
if [[ ! -e /etc/stunnel/stunnel.conf ]]; then
msg -ama " $(fun_trans "stunnel.conf Nao Encontrado")"
msg -bar
exit 1
fi
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

fun_scriptsalternos () {
while true; do
echo -e "\033[1;33m$(fun_trans "TESTE SCRIPTS ALTERNOS") ${cor[4]}[NEW-ADM]"
echo -e "$barra"
echo -e "\033[1;32m[0] > ${cor[0]}$(fun_trans "VOLTAR")"
echo -e "$barra"
echo -e "\033[1;32m[1] > \033[1;36m$(fun_trans "Menu SSHPlus Coneccion ")"
echo -e "$barra"
echo -e "\033[1;32m[2] > \033[1;36m$(fun_trans "Menu Beta v.2")"
echo -e "$barra"
echo -e "\033[1;32m[3] > \033[1;36m$(fun_trans "Multi portos SSL")"
echo -e "$barra"
echo -e "\033[1;32m[4] > \033[1;36m$(fun_trans "ADMINISTRAR CUENTAS SS/SSRR")"
echo -e "\033[1;32m[5] > \033[1;36m$(fun_trans "SHADOWSOCKS-LIBEV")"
echo -e "\033[1;32m[6] > \033[1;36m$(fun_trans "SHADOWSOCKS-R")"
echo -e "\033[1;32m[7] > \033[1;36m$(fun_trans "SHADOWSOCKS-NORMAL")"
echo -e "$barra"
echo -e "\033[1;32m[8] > \033[1;36m$(fun_trans "V2ray Panel")"
echo -e "\033[1;32m[9] > \033[1;36m$(fun_trans "V2ray Manager")\n${barra}"
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
return
break;;
3)
ssl_redir
break;;
4)
wget -O /bin/C-SSR.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/C-SSR.sh > /dev/null 2>&1; chmod +x /bin/C-SSR.sh; C-SSR.sh
break;;
5)
wget -O /bin/Shadowsocks-libev.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/Shadowsocks-libev.sh > /dev/null 2>&1; chmod +x /bin/Shadowsocks-libev.sh; Shadowsocks-libev.sh
break;;
6)
wget -O /bin/Shadowsocks-R.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/Shadowsocks-R.sh > /dev/null 2>&1; chmod +x /bin/Shadowsocks-R.sh; Shadowsocks-R.sh
break;;
7)
wget -O /bin/shadowsocks.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/shadowsocks.sh > /dev/null 2>&1; chmod +x /bin/shadowsocks.sh; shadowsocks.sh
break;;
8)
wget -O /etc/ger-inst/v2ray.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/Herramientas/v2ray.sh > /dev/null 2>&1; chmod +x /etc/ger-inst/v2ray.sh
break;;
9)
wget -O /bin/vdoray.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/vdoray.sh > /dev/null 2>&1; chmod +x /bin/vdoray.sh; vdoray.sh
break;;
esac
done
}
fun_scriptsalternos
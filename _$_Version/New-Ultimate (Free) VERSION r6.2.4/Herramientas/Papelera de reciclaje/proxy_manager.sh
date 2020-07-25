#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

#LIPIAR SCRIPTS
rm -rf /bin/tcp-client.py
rm -rf /bin/Proxy-Publico.py
rm -rf /bin/Proxy-Privado.py
rm -rf /bin/shadown.sh
rm -rf /bin/shadowsocks.sh
rm -rf /bin/shadowsock.sh
rm -rf /bin/ssrrmu.sh
rm -rf /bin/v2ray.sh
rm -rf /bin/vdoray.sh

gestor_fun () {
echo -e " ${cor[3]} $(fun_trans "PROXY MANAGER BETA-TESTER") ${cor[4]}[NEW-ADM]"
echo -e " ${cor[3]} $(fun_trans "herramienta en modo de prueba")"
echo -e "$barra"
while true; do
echo -e "${cor[4]} [1] > \033[1;36m$(fun_trans "TCP-Client para TCP-OVER")"
echo -e "${cor[4]} [2] > \033[1;36m$(fun_trans "Proxy Python Color Publico")"
echo -e "${cor[4]} [3] > \033[1;36m$(fun_trans "Proxy Python Color Privado")"
echo -e "$barra"
echo -e "${cor[4]} [4] > \033[1;36m$(fun_trans "Shadowsocks Cloack")"
echo -e "${cor[4]} [5] > \033[1;36m$(fun_trans "Shadowsocks-Libev")"
echo -e "${cor[4]} [6] > \033[1;36m$(fun_trans "Shadowsocks-R,Go,Liv")"
echo -e "${cor[4]} [7] > \033[1;36m$(fun_trans "ShadowsocksR Manager")"
echo -e "$barra"
echo -e "${cor[4]} [8] > \033[1;36m$(fun_trans "V2ray Panel")"
echo -e "${cor[4]} [9] > \033[1;36m$(fun_trans "V2ray Manager")"
echo -e "$barra"
echo -e "${cor[4]} [0] > ${cor[0]}$(fun_trans "VOLTAR")\n${barra}"
while [[ ${opx} != @(0|[1-9]) ]]; do
echo -ne "${cor[0]}$(fun_trans "Digite a Opcao"): \033[1;37m" && read opx
tput cuu1 && tput dl1
done
case $opx in
	0)
	return;;
	1)
	wget -O /bin/tcp-client.py https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/tcp-client.py > /dev/null 2>&1; chmod +x /bin/tcp-client.py; tcp-client.py 
	break;;
	2)
	wget -O /bin/Proxy-Publico.py https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/Proxy-Publico.py > /dev/null 2>&1; chmod +x /bin/Proxy-Publico.py; Proxy-Publico.py
	break;;
	3)
	wget -O /bin/Proxy-Privado.py https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/Proxy-Privado.py > /dev/null 2>&1; chmod +x /bin/Proxy-Privado.py; Proxy-Privado.py
	break;;
	4)
	wget -O /bin/shadown.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/shadown.sh > /dev/null 2>&1; chmod +x /bin/shadown.sh; shadown.sh
	break;;
	5)
	wget -O /bin/shadowsocks.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/shadowsocks.sh > /dev/null 2>&1; chmod +x /bin/shadowsocks.sh; shadowsocks.sh
	break;;
        6)
	wget -O /bin/shadowsock.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/shadowsock.sh > /dev/null 2>&1; chmod +x /bin/shadowsock.sh; shadowsock.sh
	break;;
        7)
	wget -O /bin/ssrrmu.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/ssrrmu.sh > /dev/null 2>&1; chmod +x /bin/ssrrmu.sh; ssrrmu.sh
	break;;
        8)
	wget -O /bin/v2ray.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/v2ray.sh > /dev/null 2>&1; chmod +x /bin/v2ray.sh; v2ray.sh
	break;;
        9)
	wget -O /bin/vdoray.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/vdoray.sh > /dev/null 2>&1; chmod +x /bin/vdoray.sh; vdoray.sh
	break;;
esac
done
}
gestor_fun
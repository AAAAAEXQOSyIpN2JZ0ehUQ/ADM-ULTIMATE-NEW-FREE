#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
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
tput cuu1
tput dl1
done
echo -e " \033[1;33m[\033[1;31m####################\033[1;33m] - \033[1;32m100%\033[0m"
sleep 1s
}

#PREENXE A VARIAVEL $IP
meu_ip () {
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && IP="$MEU_IP2" || IP="$MEU_IP"
}

vnc_fun () {
if [ -d  /root/.vnc/ ];then
vnc=$(ls /root/.vnc/ | grep :1.pid)
else
vnc=""
fi
meu_ip
if [[ $vnc = "" ]]; then
echo -ne " $(fun_trans "VNC não está ativo Deseja ativar?") [S/N]: "; read x
[[ $x = @(n|N) ]] && msg -bar && return
msg -bar
echo -e " \033[1;36mInstalling VNC:"
fun_bar 'apt-get install xfce4 xfce4-goodies gnome-icon-theme tightvncserver'
echo -e " \033[1;36mInstalling DEPENDENCE:"
fun_bar 'apt-get install iceweasel'
echo -e " \033[1;36mInstalling FIREFOX:"
fun_bar 'apt-get install firefox -y'
echo "#VNC-ADM ON" > /etc/vnc-on
msg -bar
echo -e "\033[1;33m $(fun_trans "ENTRE UMA SENHA E DEPOIS DE CONFIRMAR")\033[1;32m"
msg -bar
vncserver
msg -bar
echo -e " $(fun_trans "VNC conecta usando o ip do vps na porta") 5901"
echo -e " Ex: $IP:5901\033[1;32m"
echo -e " $(fun_trans "Para acessar a interface gráfica") "
echo -e " $(fun_trans "Faça o download da PlayStore:") VNC VIWER"
elif [[ $vnc != "" ]]; then
echo -e " $(fun_trans "VNC está ativo Deseja desabilitar?") [S/N]: "; read x
[[ $x = @(n|N) ]] && msg -bar && return
msg -bar
echo -e " \033[1;36mremoving VNC:"
fun_bar 'apt-get purge xfce4 xfce4-goodies gnome-icon-theme tightvncserver'
echo -e "\033[1;36m removing DEPENDENCES:"
fun_bar 'apt-get purge iceweasel'
echo -e "\033[1;36m removing FIREFOX:"
fun_bar 'apt-get purge firefox -y'
rm -rf /etc/vnc-on
vncserver -kill :1 > /dev/null
vncserver -kill :2 > /dev/null
vncserver -kill :3 > /dev/null
fi
msg -bar
}
vnc_fun

####_Eliminar_Tmps_####
[[ -e $_tmp ]] && rm $_tmp
[[ -e $_tmp2 ]] && rm $_tmp2
[[ -e $_tmp3 ]] && rm $_tmp3
[[ -e $_tmp4 ]] && rm $_tmp4
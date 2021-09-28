#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

fun_bar () {
comando[0]="$1"
comando[1]="$2"
 (
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} -y > /dev/null 2>&1
${comando[1]} -y > /dev/null 2>&1
touch $HOME/fim
 ) > /dev/null 2>&1 &
echo -ne "\033[1;33m ["
while true; do
   for((i=0; i<18; i++)); do
   echo -ne "\033[1;31m##"
   sleep 0.1s
   done
   [[ -e $HOME/fim ]] && rm $HOME/fim && break
   echo -e "\033[1;33m]"
   sleep 1s
   tput cuu1
   tput dl1
   echo -ne "\033[1;33m ["
done
echo -e "\033[1;33m]\033[1;31m -\033[1;32m 100%\033[1;37m"
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
[[ $x = @(n|N) ]] && return
echo -e "$barra"
echo -e " \033[1;36mInstalling VNC:"
fun_bar 'apt-get install xfce4 xfce4-goodies gnome-icon-theme tightvncserver'
echo -e " \033[1;36mInstalling DEPENDENCE:"
fun_bar 'apt-get install iceweasel'
echo -e " \033[1;36mInstalling FIREFOX:"
fun_bar 'apt-get install firefox -y'
echo "Activo VNC" > /usr/bin/vnc_log1
echo -e "$barra"
echo -e "\033[1;33m $(fun_trans "ENTRE UMA SENHA E DEPOIS DE CONFIRMAR")\033[1;32m"
echo -e "$barra"
vncserver
echo -e "$barra"
echo -e " $(fun_trans "VNC conecta usando o ip do vps na porta") 5901"
echo -e " Ex: $IP:5901\033[1;32m"
echo -e " $(fun_trans "Para acessar a interface gráfica") "
echo -e " $(fun_trans "Faça o download da PlayStore:") VNC VIWER"
elif [[ $vnc != "" ]]; then
echo -e " $(fun_trans "VNC está ativo Deseja desabilitar?") [S/N]: "; read x
[[ $x = @(n|N) ]] && echo -e "$barra" && return
echo -e "$barra"
vncserver -kill :1 > /dev/null 2>&1
echo -e " \033[1;36mremoving VNC:"
fun_bar 'apt-get purge xfce4 xfce4-goodies gnome-icon-theme tightvncserver -y'
echo -e "\033[1;36m removing DEPENDENCES:"
fun_bar 'apt-get purge iceweasel -y'
echo -e "\033[1;36m removing FIREFOX:"
fun_bar 'apt-get purge firefox -y'
rm -rf /usr/bin/vnc_log1
vncserver -kill :1 > /dev/null 2>&1
vncserver -kill :2 > /dev/null 2>&1
vncserver -kill :3 > /dev/null 2>&1
fi
}

vncpurge_fun () {
echo -ne " $(fun_trans "Si VNC está ativo Deseja desabilitar?") [S/N]: "; read x
[[ $x = @(n|N) ]] && return
echo -e "$barra"
vncserver -kill :1 > /dev/null 2>&1
echo -e " \033[1;36mremoving VNC:"
fun_bar 'apt-get purge xfce4 xfce4-goodies gnome-icon-theme tightvncserver -y'
echo -e "\033[1;36m removing DEPENDENCES:"
fun_bar 'apt-get purge iceweasel -y'
echo -e "\033[1;36m removing FIREFOX:"
fun_bar 'apt-get purge firefox -y'
rm -rf /usr/bin/vnc_log1
vncserver -kill :1 > /dev/null 2>&1
vncserver -kill :2 > /dev/null 2>&1
vncserver -kill :3 > /dev/null 2>&1
}

backup (){
#BACKUP ANTI-DDOS
wget -O /etc/ger-frm/vnc.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/HerramientasADM/vnc.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/vnc.sh
fun_bar "chmod -R 777 /etc/ger-frm/vnc.sh"
chmod -R 777 /etc/ger-frm/vnc.sh > /dev/null 2>&1
echo -e "$barra"
echo -e "${cor[3]}$(fun_trans "VNC ACTUALIZADO CON SUCESSO")"
echo -e "$barra"
}

[[ -e /usr/bin/vnc_log1 ]] && vnc_log1=$(echo -e "\033[1;32mon ") || vnc_log1=$(echo -e "\033[1;31moff ")

msg -ama "$(fun_trans "VNC SERVER") ${cor[4]}[NEW-ADM]"
echo -e "$barra"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "VNC SERVER") $vnc_log1"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "ELIMINAR VNC")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "ACTUALIZAR VNC")"
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
echo -e "$barra"
while [[ ${arquivoonlineadm} != @(0|[1-2]) ]]; do
read -p "Selecione a Opcao: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)vnc_fun;;
2)vncpurge_fun;;
3)backup;;
esac
msg -bar

[[ "$1" = "1" ]]
####_Eliminar_Tmps_####
[[ -e $_tmp ]] && rm $_tmp
[[ -e $_tmp2 ]] && rm $_tmp2
[[ -e $_tmp3 ]] && rm $_tmp3
[[ -e $_tmp4 ]] && rm $_tmp4
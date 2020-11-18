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

update_pak () {
echo -ne " \033[1;31m[ ! ] apt-get update"
apt-get update -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get upgrade"
apt-get upgrade -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
return
}

reiniciar_ser () {
echo -ne " \033[1;31m[ ! ] Services ssh restart"
service ssh restart > /dev/null 2>&1
[[ -e /etc/init.d/ssh ]] && /etc/init.d/ssh restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services dropbear restart"
service dropbear restart > /dev/null 2>&1
[[ -e /etc/init.d/dropbear ]] && /etc/init.d/dropbear restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services squid restart"
service squid restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services squid3 restart"
service squid3 restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services openvpn restart"
service openvpn restart > /dev/null 2>&1
[[ -e /etc/init.d/openvpn ]] && /etc/init.d/openvpn restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services stunnel4 restart"
service stunnel4 restart > /dev/null 2>&1
[[ -e /etc/init.d/stunnel4 ]] && /etc/init.d/stunnel4 restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services apache2 restart"
service apache2 restart > /dev/null 2>&1
[[ -e /etc/init.d/apache2 ]] && /etc/init.d/apache2 restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services fail2ban restart"
( 
[[ -e /etc/init.d/ssh ]] && /etc/init.d/ssh restart
fail2ban-client -x stop && fail2ban-client -x start
) > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
return
}

reiniciar_vps () {
echo -ne " \033[1;31m[ ! ] Sudo Reboot"
sleep 3s
echo -e "\033[1;32m [OK]"
(
sudo reboot
) > /dev/null 2>&1
return
}

host_name () {
unset name
while [[ ${name} = "" ]]; do
echo -ne "\033[1;37m $(fun_trans "Nuevo nombre del host"): " && read name
tput cuu1 && tput dl1
done
hostnamectl set-hostname $name 
if [ $(hostnamectl status | head -1  | awk '{print $3}') = "${name}" ]; then 
echo -e "\033[1;33m $(fun_trans "Host alterado corretamente")!, $(fun_trans "reiniciar VPS")"
else
echo -e "\033[1;33m $(fun_trans "Host no modificado")!"
fi
return
}

cambiopass () {
echo -e "${cor[3]} $(fun_trans "Esta herramienta cambia la contraseña de su servidor vps")"
echo -e "${cor[3]} $(fun_trans "Esta contraseña es utilizada como usuario") root"
echo -e "$barra"
echo -ne " $(fun_trans "Desea Seguir?") [S/N]: "; read x
[[ $x = @(n|N) ]] && return
#Inicia Procedimentos
echo -e "$barra"
echo -e "\033[1;37m $(fun_trans "Escriba su nueva contraseña")"
echo -e "$barra"
read  -p " Nuevo passwd: " pass
(echo $pass; echo $pass)|passwd 2>/dev/null
sleep 1s
echo -e "$barra"
echo -e "${cor[3]} $(fun_trans "Contraseña cambiada con exito!")"
echo -e "${cor[2]} $(fun_trans "Su contraseña ahora es"): ${cor[4]}$pass"
return
}

act_hora () {
echo -ne " \033[1;31m[ ! ] timedatectl"
timedatectl > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] timedatectl list-timezones"
timedatectl list-timezones > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] timedatectl list-timezones  | grep Santiago"
timedatectl list-timezones  | grep Santiago > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] timedatectl set-timezone America/Santiago"
timedatectl set-timezone America/Santiago > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
return
}

cleanreg () {
echo -ne " \033[1;31m[ ! ] Registro del limitador eliminado"
sudo rm -rf /etc/newadm/ger-user/Limiter.log > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
return
}

pamcrack () {
echo -e "${cor[3]} $(fun_trans "Liberar passwd para VURTL")"
echo -e "$barra"
echo -ne " $(fun_trans "Desea Seguir?") [S/N]: "; read x
[[ $x = @(n|N) ]] && echo -e "$barra" && return
echo -e ""
fun_bar "service ssh restart"
sed -i 's/.*pam_cracklib.so.*/password sufficient pam_unix.so sha512 shadow nullok try_first_pass #use_authtok/' /etc/pam.d/common-password
fun_bar "service ssh restart"
echo -e ""
echo -e " \033[1;31m[ ! ]\033[1;33m $(fun_trans "Configuraciones VURTL aplicadas")"
return
}

rootpass () {
echo -e "${cor[3]} $(fun_trans "Esta herramienta cambia a usuario root las vps de ")"
echo -e "${cor[3]} $(fun_trans "Googlecloud y Amazon esta configuracion solo")"
echo -e "${cor[3]} $(fun_trans "funcionan en Googlecloud y Amazon Puede causar")"
echo -e "${cor[3]} $(fun_trans "error en otras VPS agenas a Googlecloud y Amazon ")"
echo -e "$barra"
echo -ne " $(fun_trans "Desea Seguir?") [S/N]: "; read x
[[ $x = @(n|N) ]] && echo -e "$barra" && return
echo -e "$barra"
#Inicia Procedimentos
echo -e "${cor[0]} $(fun_trans "Aplicando Configuracoes")"
fun_bar "service ssh restart"
#Parametros Aplicados
sed -i "s;PermitRootLogin prohibit-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PermitRootLogin without-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PasswordAuthentication no;PasswordAuthentication yes;g" /etc/ssh/sshd_config
echo -e "$barra"
echo -e "${cor[0]} $(fun_trans "Escriba su contraseña root actual")"
echo -e "${cor[0]} $(fun_trans "si lo decea puede cambiarla")"
echo -e "$barra"
read  -p " Nuevo passwd: " pass
(echo $pass; echo $pass)|passwd 2>/dev/null
sleep 1s
echo -e "$barra"
echo -e "${cor[3]} $(fun_trans "Configuraciones aplicadas con exito!")"
echo -e "${cor[2]} $(fun_trans "Su contraseña ahora es"): ${cor[4]}$pass"
service ssh restart > /dev/null 2>&1
return
}

msg -ama " $(fun_trans "GERENCIAR SERVIDOR VPS")"
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "ATUALIZAR PACOTES")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "REINICIAR OS SERVICO")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "REINICIAR SISTEMA")"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "ALTERAR O NOME DO SISTEMA")"
echo -ne "\033[1;32m [5] > " && msg -azu "$(fun_trans "CAMBIAR CONTRASEñA ROOT DEL SISTEMA")"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "ATUALIZAR HORA AMERICA-SANTIAGO")"
echo -ne "\033[1;32m [7] > " && msg -azu "$(fun_trans "ELIMINAR REGISTRO DEL LIMITADO") \033[1;33m(\033[1;37mBETA\033[1;33m)"
echo -ne "\033[1;32m [8] > " && msg -azu "$(fun_trans "DESBLOQUEAR VURTL PARA CREAR USUARIOS") \033[1;33m(\033[1;37mBETA\033[1;33m)"
echo -ne "\033[1;32m [9] > " && msg -azu "$(fun_trans "SERVICO ROOT PARA GOOGLECLOUD E AMAZON") \033[1;33m(\033[1;37mBETA\033[1;33m)"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-9]) ]]; do
read -p "[0-9]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)update_pak;;
2)reiniciar_ser;;
3)reiniciar_vps;;
4)host_name;;
5)cambiopass;;
6)act_hora;;
7)cleanreg;;
8)pamcrack;;
9)rootpass;;
esac
msg -bar
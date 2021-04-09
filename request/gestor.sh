#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

meu_ip () {
if [[ -e /etc/MEUIPADM ]]; then
echo "$(cat /etc/MEUIPADM)"
else
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && echo "$MEU_IP2" || echo "$MEU_IP"
echo "$MEU_IP2" > /etc/MEUIPADM
fi
}

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
echo -e "\033[1;33m $(fun_trans "Host alterado corretamente")"
msg -bar
echo -e "$(fun_trans "Reiniciar Sistema?")"
read -p " [S/N]: " -e -i s PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
#Inicia Procedimentos
reiniciar_vps
else
echo -e "\033[1;33m $(fun_trans "Host no modificado")!"
fi
return
}

cambiopass () {
echo -e "${cor[3]} $(fun_trans "Esta herramienta cambia la contraseña de su servidor vps")"
echo -e "${cor[3]} $(fun_trans "Esta contraseña es utilizada como usuario") root"
msg -bar
echo -e "$(fun_trans "Deseja Prosseguir?")"
read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
#Inicia Procedimentos
msg -bar
echo -e "\033[1;37m $(fun_trans "Escriba su nueva contraseña")"
msg -bar
read  -p " Nuevo passwd: " pass
(echo $pass; echo $pass)|passwd 2>/dev/null
sleep 1s
msg -bar
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
if [[ ! -e /etc/newadm/ger-user/Limiter.log ]]; then
msg -ama " Limiter.log No Encontrado"
msg -bar
exit 1
fi
echo -ne " \033[1;31m[ ! ] Registro del limitador eliminado"
sudo rm -rf /etc/newadm/ger-user/Limiter.log > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
return
}

newadm_color () {
echo -e "$(fun_trans "Deseja Prosseguir?")"
read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
msg -bar
# rm -rf /etc/new-adm-color > /dev/null 2>&1
echo -ne " \033[1;31m[ ! ] new-adm-color"
rm -rf /etc/new-adm-color > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo "2 2 2 4 2 4 7 " > /etc/new-adm-color
chmod +x /etc/new-adm-color
return
}

pamcrack () {
echo -e "${cor[3]} $(fun_trans "Liberar passwd para VURTL")"
msg -bar
echo -e "$(fun_trans "Deseja Prosseguir?")"
read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
msg -bar
fun_bar "service ssh restart"
sed -i 's/.*pam_cracklib.so.*/password sufficient pam_unix.so sha512 shadow nullok try_first_pass #use_authtok/' /etc/pam.d/common-password
service ssh restart > /dev/null 2>&1
#-----------------------------------------------------------------------------------------------------------------
# sudo apt-get install libpam-cracklib -y > /dev/null 2>&1
# wget https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/VPS-MX/main/VPS-MX_Oficial/ArchivosUtilitarios/common-password -O /etc/pam.d/common-password > /dev/null 2>&1 
# chmod +x /etc/pam.d/common-password
#-----------------------------------------------------------------------------------------------------------------
msg -bar
echo -e " \033[1;31m[ ! ]\033[1;33m $(fun_trans "Configuraciones VURTL aplicadas")"
msg -bar
echo -e "${cor[3]} $(fun_trans "Passwd Alfanumerico Desactivado con EXITO")"
return
}

aplica_root () {
echo -e "${cor[3]} $(fun_trans "Esta herramienta cambia a usuario root")"
echo -e "${cor[3]} $(fun_trans "las VPS de GoogleCloud y Amazon")"
msg -bar
echo -e "$(fun_trans "Deseja Prosseguir?")"
read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
msg -bar
#Inicia Procedimentos
fun_bar "service ssh restart"
#Parametros Aplicados
sed -i "s;PermitRootLogin prohibit-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PermitRootLogin without-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PasswordAuthentication no;PasswordAuthentication yes;g" /etc/ssh/sshd_config
msg -bar
echo -e "\033[1;37m $(fun_trans "Escriba su contraseña root actual o cambiela")"
msg -bar
read  -p " Nuevo passwd: " pass
(echo $pass; echo $pass)|passwd 2>/dev/null
sleep 1s
service ssh restart &>/dev/null
msg -bar
echo -e "${cor[3]} $(fun_trans "Configuraciones aplicadas con exito!")"
echo -e "${cor[2]} $(fun_trans "Su contraseña ahora es"): ${cor[4]}$pass"
return
}

fun_nload () {
echo -e "${cor[4]} $(fun_trans "PARA SALIR DEL PANEL PRESIONE") ${cor[3]}CTLR + C"
msg -bar
sleep 1s
fun_bar "apt-get install nload -y"
sleep 2s
nload
}

fun_htop () {
echo -e "${cor[4]} $(fun_trans "PARA SALIR DEL PANEL PRESIONE") ${cor[3]}CTLR + C"
msg -bar
sleep 1s
fun_bar "apt-get install htop -y"
sleep 2s
htop
}

fun_statussistema () {
echo -e "\033[1;33m DETALHES DO SISTEMA"
msg -bar
# SISTEMA OPERACIONAL
_hora=$(printf '%(%H:%M:%S)T')
_hoje=$(date +'%d/%m/%Y')
if [ -f /etc/lsb-release ]
then
name=$(cat /etc/lsb-release |grep DESCRIPTION |awk -F = {'print $2'})
codename=$(cat /etc/lsb-release |grep CODENAME |awk -F = {'print $2'})
echo -e "\033[1;31mNome: \033[1;37m$name"
echo -e "\033[1;31mIP: \033[1;37m$(meu_ip)"
echo -e "\033[1;31mHora : \033[1;37m$_hora"
echo -e "\033[1;31mData: \033[1;37m$_hoje"
echo -e "\033[1;31mCodeName: \033[1;37m$codename"
echo -e "\033[1;31mKernel: \033[1;37m$(uname -s)"
echo -e "\033[1;31mKernel Release: \033[1;37m$(uname -r)"
if [ -f /etc/os-release ]
then
devlike=$(cat /etc/os-release |grep LIKE |awk -F = {'print $2'})
echo -e "\033[1;31mDerivado do OS: \033[1;37m$devlike"
fi
else
system=$(cat /etc/issue.net)
echo -e "\033[1;31mNome: \033[1;37m$system"
fi
# PROCESSADOR
msg -bar
if [ -f /proc/cpuinfo ]
then
uso=$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')
modelo=$(cat /proc/cpuinfo |grep "model name" |uniq |awk -F : {'print $2'})
cpucores=$(grep -c cpu[0-9] /proc/stat)
cache=$(cat /proc/cpuinfo |grep "cache size" |uniq |awk -F : {'print $2'})
echo -e "\033[1;31mModelo:\033[1;37m$modelo"
echo -e "\033[1;31mNucleos:\033[1;37m $cpucores"
echo -e "\033[1;31multilizacao: \033[37m$uso"
echo -e "\033[1;31mArquitetura: \033[1;37m$(uname -p)"
echo -e "\033[1;31mMemoria Cache:\033[1;37m$cache"
else
echo "Não foi possivel obter informações"
fi
# MEMORIA RAM
msg -bar
if free 1>/dev/null 2>/dev/null
then
ram1=$(free -h | grep -i mem | awk {'print $2'})
ram2=$(free -h | grep -i mem | awk {'print $4'})
ram3=$(free -h | grep -i mem | awk {'print $3'})
usoram=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')
echo -e "\033[1;31mRam Total: \033[1;32m$ram1"
echo -e "\033[1;31mRam Em Uso: \033[1;32m$ram3"
echo -e "\033[1;31mRam Livre: \033[1;32m$ram2"
echo -e "\033[1;31mRam ultilizacao: \033[32m$usoram"
else
echo "Não foi possivel obter informações"
fi
# SERVICOS EM EXECUCAO
msg -bar
PT=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
for porta in `echo -e "$PT" | cut -d: -f2 | cut -d' ' -f1 | uniq`; do
    svcs=$(echo -e "$PT" | grep -w "$porta" | awk '{print $1}' | uniq)
    echo -e "\033[1;32mServico \033[1;31m$svcs \033[1;32mPorta \033[1;37m$porta"
done
}

fun_nettools () {
[[ ! -e /bin/nettools.py ]] && wget -O /bin/nettools.py https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/nettools.py > /dev/null 2>&1; chmod +x /bin/nettools.py; /bin/nettools.py
}

resetiptables () {
echo -e "Reiniciando Ipetables espere"
iptables -F && iptables -X && iptables -t nat -F && iptables -t nat -X && iptables -t mangle -F && iptables -t mangle -X && iptables -t raw -F && iptables -t raw -X && iptables -t security -F && iptables -t security -X && iptables -P INPUT ACCEPT && iptables -P FORWARD ACCEPT && iptables -P OUTPUT ACCEPT
echo -e "iptables reiniciadas con exito"
}
packobs () {
msg -ama "Buscando Paquetes Obsoletos"
dpkg -l | grep -i ^rc
msg -ama "Limpiando Paquetes Obsoloteos"
dpkg -l |grep -i ^rc | cut -d " " -f 3 | xargs dpkg --purge
msg -ama "Limpieza Completa"
}

RAM () {
sudo sync
sudo sysctl -w vm.drop_caches=3 > /dev/null 2>&1
msg -ama "   Ram limpiada con Exito!"
}

selection_fun () {
local selection="null"
local range
for((i=0; i<=$1; i++)); do range[$i]="$i "; done
while [[ ! $(echo ${range[*]}|grep -w "$selection") ]]; do
echo -ne "[0-13]: " >&2
read selection
tput cuu1 >&2 && tput dl1 >&2
done
echo $selection
}
msg -ama " $(fun_trans "GERENCIAR SISTEMA INTERNO")"
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "ATUALIZAR PACOTES")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "REINICIAR OS SERVICO")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "REINICIAR SISTEMA")"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "ALTERAR O NOME DO SISTEMA")"
echo -ne "\033[1;32m [5] > " && msg -azu "$(fun_trans "CAMBIAR CONTRASEÑA ROOT DEL SISTEMA")"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "ATUALIZAR HORA AMERICA-SANTIAGO")"
echo -ne "\033[1;32m [7] > " && msg -azu "$(fun_trans "MUDAR CORES SISTEMA A RED-TEME")"
echo -ne "\033[1;32m [8] > " && msg -azu "$(fun_trans "DESBLOQUEAR VURTL PARA CREAR USUARIOS") \033[1;33m(\033[1;37mBETA\033[1;33m)"
echo -ne "\033[1;32m [9] > " && msg -azu "$(fun_trans "APLICAR ROOT A GOOGLECLOUD Y AMAZON")"
echo -ne "\033[1;32m [10] > " && msg -azu "$(fun_trans "TRAFICO DE RED NLOAD")"
echo -ne "\033[1;32m [11] > " && msg -azu "$(fun_trans "PROCESOS DEL SISTEMA HTOP")"
echo -ne "\033[1;32m [12] > " && msg -azu "$(fun_trans "DETALHES DO SISTEMA") \033[1;33m(\033[1;37mBETA\033[1;33m)"
echo -ne "\033[1;32m [13] > " && msg -azu "$(fun_trans "NET TOOLS TARGET") \033[1;33m(\033[1;37mBETA\033[1;33m)"
msg -bar
selection=$(selection_fun 18)
case ${selection} in
# while [[ ${arquivoonlineadm} != @(0|[1-9]) ]]; do
# read -p "[0-13]: " arquivoonlineadm
# tput cuu1 && tput dl1
# done
# case $arquivoonlineadm in
1)update_pak;;
2)reiniciar_ser;;
3)reiniciar_vps;;
4)host_name;;
5)cambiopass;;
6)act_hora;;
7)newadm_color;;
8)pamcrack;;
9)aplica_root;;
10)fun_nload;;
11)fun_htop;;
12)fun_statussistema;;
13)fun_nettools;;
0)exit;;
esac
msg -bar
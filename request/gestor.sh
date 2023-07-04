#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

fun_ip () {
if [[ -e /etc/MEUIPADM ]]; then
IP="$(cat /etc/MEUIPADM)"
else
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && IP="$MEU_IP2" || IP="$MEU_IP"
echo "$MEU_IP2" > /etc/MEUIPADM
fi
}

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
   for((i=0; i<10; i++)); do
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

update_pak () {
echo -ne " \033[1;31m[ ! ] apt-get update"
apt-get update -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo ""
echo -ne " $(fun_trans "Deseja Prosseguir upgrade?")"; read -p " [S/N]: " PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
tput cuu1 && tput dl1
tput cuu1 && tput dl1
echo -ne " \033[1;31m[ ! ] apt-get upgrade"
apt-get upgrade -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
return
}

reiniciar_ser () {
# SERVICE SSH
echo -ne " \033[1;31m[ ! ] Services ssh restart"
service ssh restart > /dev/null 2>&1
[[ -e /etc/init.d/ssh ]] && /etc/init.d/ssh restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
# SERVICE DROPBEAR
echo -ne " \033[1;31m[ ! ] Services dropbear restart"
service dropbear restart > /dev/null 2>&1
[[ -e /etc/init.d/dropbear ]] && /etc/init.d/dropbear restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
# SERVICE SQUID
echo -ne " \033[1;31m[ ! ] Services squid restart"
service squid restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
# SERVICE SQUID3
echo -ne " \033[1;31m[ ! ] Services squid3 restart"
service squid3 restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
# SERVICE OPENVPN
echo -ne " \033[1;31m[ ! ] Services openvpn restart"
service openvpn restart > /dev/null 2>&1
[[ -e /etc/init.d/openvpn ]] && /etc/init.d/openvpn restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
# SERVICE STUNNEL4
echo -ne " \033[1;31m[ ! ] Services stunnel4 restart"
service stunnel4 restart > /dev/null 2>&1
[[ -e /etc/init.d/stunnel4 ]] && /etc/init.d/stunnel4 restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
# SERVICE APACHE2
echo -ne " \033[1;31m[ ! ] Services apache2 restart"
service apache2 restart > /dev/null 2>&1
[[ -e /etc/init.d/apache2 ]] && /etc/init.d/apache2 restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
# SERVICE FAIL2BAN
echo -ne " \033[1;31m[ ! ] Services fail2ban restart"
( 
[[ -e /etc/init.d/ssh ]] && /etc/init.d/ssh restart
fail2ban-client -x stop && fail2ban-client -x start
) > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
return
}

inst_components () {
# 
# echo -ne " \033[1;31m[ ! ] apt-get grep"
# apt-get install grep -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
# echo -ne " \033[1;31m[ ! ] apt-get at"
# apt-get install at -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
# echo -ne " \033[1;31m[ ! ] apt-get netcat-openbsd"
# apt-get install netcat-openbsd -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
# 
echo -ne " \033[1;31m[ ! ] apt-get gawk"
apt-get install gawk -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get mlocate"
apt-get install mlocate -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get bc"
apt-get install bc -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get screen"
apt-get install screen -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get nano"
apt-get install nano -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get zip"
apt-get install zip -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get unzip"
apt-get install unzip -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get lsof"
apt-get install lsof -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get netstat"
apt-get install netstat -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get net-tools"
apt-get install net-tools -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get dos2unix"
apt-get install dos2unix -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get nload"
apt-get install nload -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get htop"
apt-get install htop -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get jq"
apt-get install jq -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get curl"
apt-get install curl -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get figlet"
apt-get install figlet -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get ufw"
apt-get install ufw -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get apache2"
apt-get install apache2 -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf
service apache2 restart > /dev/null 2>&1 &
echo -ne " \033[1;31m[ ! ] apt-get python"
apt-get install python -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get python3"
apt-get install python3 -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get python-pip"
apt-get install python-pip -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
pip install speedtest-cli &>/dev/null
return
}

reiniciar_vps () {
## REINICIAR VPS (REBOOT)
echo -e "\033[1;33m Realmente desea Reiniciar la VPS?"
read -p " [S/N]: " -e -i n sshsn
[[ "$sshsn" = @(s|S|y|Y) ]] && {
msg -bar
echo -e "\033[1;36m Preparando para reinicio"
echo -e "\033[1;36m AGUARDE"
sleep 3s
msg -bar
echo -e "\033[1;31m[ ! ] Reboot... \033[1;32m[OK]"
sleep 1s
reboot
} 
}

host_name () {
msg -ama " $(fun_trans "O nome sera alterado internamente no servodor")"
msg -bar
echo -ne " $(fun_trans "Deseja Prosseguir?")"; read -p " [S/N]: " PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
#Inicia Procedimentos
msg -bar
unset name
while [[ ${name} = "" ]]; do
msg -ama " $(fun_trans "Digite o Novo Nome ")"
echo -ne " \033[1;32mNuevo nome\033[1;37m: "; read name
[[ -z "$name" ]] && {
echo -e "\n\033[1;31mNOME INVALIDA !\033[0m"
return
}
done
hostnamectl set-hostname $name 
if [ $(hostnamectl status | head -1  | awk '{print $3}') = "${name}" ]; then 
service ssh restart > /dev/null 2>&1
service sshd restart > /dev/null 2>&1
msg -bar
echo -e "\033[1;31m $(fun_trans "NOVO NOME"): \033[1;32m$name"
msg -bar
msg -ama " $(fun_trans "NOME ALTERADO COM SUCESSO")!"
else
echo -e "\n\033[1;31mNOME INVALIDA !\033[0m"
fi
return
}

senharoot () {
[[ ! -e /home/passwordroot.txt ]] && touch /home/passwordroot.txt
PASSWORD_FILE="/home/passwordroot.txt"
msg -ama " $(fun_trans "Essa senha sera usada para entrar no seu servidor")"
msg -bar
echo -ne " $(fun_trans "Deseja Prosseguir?")"; read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
#Inicia Procedimentos
msg -bar
#DEFINIR SENHA ROOT
msg -ama " $(fun_trans "Digite Uma Nova Senha ")"
echo -ne " \033[1;32mNuevo passwd\033[1;37m: "; read senha
[[ -z "$senha" ]] && {
echo -e "\n\033[1;31m[!] SENHA INVALIDA\033[0m"
return
}
echo "root:$senha" | chpasswd
echo -e "$senha" > $PASSWORD_FILE
service ssh restart > /dev/null 2>&1
service sshd restart > /dev/null 2>&1
msg -bar
echo -e "\033[1;31m $(fun_trans "Nova Senha"): \033[01;37m$(cat $PASSWORD_FILE)"
msg -bar
msg -ama " $(fun_trans "Senha de usuário root alterada com sucesso")!"
return
}

fun_nload () {
msg -azu " $(fun_trans "PARA SALIR DEL PANEL PRESIONE") \033[1;33mCTLR + C"
msg -bar
echo -ne " $(fun_trans "Deseja Prosseguir?")"; read -p " [S/N]: " PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
#Inicia Procedimentos
msg -bar
[[ $(dpkg --get-selections|grep -w "nload"|head -1) ]] || apt-get install nload -y &>/dev/null
nload
msg -ama " $(fun_trans "Procedimento concluido")"
}

fun_htop () {
msg -azu " $(fun_trans "PARA SALIR DEL PANEL PRESIONE") \033[1;33mCTLR + C"
msg -bar
echo -ne " $(fun_trans "Deseja Prosseguir?")"; read -p " [S/N]: " PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
#Inicia Procedimentos
msg -bar
[[ $(dpkg --get-selections|grep -w "htop"|head -1) ]] || apt-get install htop -y &>/dev/null
htop
msg -ama " $(fun_trans "Procedimento concluido")"
}

fun_glances () {
msg -azu " $(fun_trans "PARA SALIR DEL PANEL PRESIONE") \033[1;33mCTLR + C"
msg -azu " $(fun_trans "O presione la letra") \033[1;33mq"
msg -bar
echo -ne " $(fun_trans "Deseja Prosseguir?")"; read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
#Inicia Procedimentos
msg -bar
apt-get install python-pip build-essential python-dev -y &>/dev/null
apt install glances -y &>/dev/null
pip install Glances &>/dev/null
pip install PySensors &>/dev/null
glances
msg -ama " $(fun_trans "Procedimento concluido")"
}

systen_info () {
clear
clear
msg -bar2
msg -ama "$(fun_trans "DETALHES DO SISTEMA")"
msg -bar
null="\033[1;31m"
if [ ! /proc/cpuinfo ]; then msg -verm "$(fun_trans "Sistema Nao Suportado")" && msg -bar; return 1; fi
if [ ! /etc/issue.net ]; then msg -verm "$(fun_trans "Sistema Nao Suportado")" && msg -bar; return 1; fi
if [ ! /proc/meminfo ]; then msg -verm "$(fun_trans "Sistema Nao Suportado")" && msg -bar; return 1; fi
totalram=$(free | grep Mem | awk '{print $2}')
usedram=$(free | grep Mem | awk '{print $3}')
freeram=$(free | grep Mem | awk '{print $4}')
swapram=$(cat /proc/meminfo | grep SwapTotal | awk '{print $2}')
system=$(cat /etc/issue.net)
clock=$(lscpu | grep "CPU MHz" | awk '{print $3}')
based=$(cat /etc/*release | grep ID_LIKE | awk -F "=" '{print $2}')
processor=$(cat /proc/cpuinfo | grep "model name" | uniq | awk -F ":" '{print $2}')
cpus=$(cat /proc/cpuinfo | grep processor | wc -l)
# SISTEMA OPERACIONAL
echo -e "\033[1;32mSISTEMA OPERACIONAL \033[0m"
msg -ama "$(fun_trans "Nome Da Maquina"): ${null}$(hostname)"
[[ "$system" ]] && msg -ama "$(fun_trans "Sistema"): ${null}$system" || msg -ama "$(fun_trans "Sistema"): ${null}???"
msg -ama "$(fun_trans "Endereco Da Maquina"): ${null}$(ip addr | grep inet | grep -v inet6 | grep -v "host lo" | awk '{print $2}' | awk -F "/" '{print $1}')"
msg -ama "$(fun_trans "Versao do Kernel"): ${null}$(uname -r)"
[[ "$based" ]] && msg -ama "$(fun_trans "Baseado"): ${null}$based" || msg -ama "$(fun_trans "Baseado"): ${null}???"
# PROCESSADOR
echo ""
echo -e "\033[1;32mPROCESSADOR \033[0m"
[[ "$processor" ]] && msg -ama "$(fun_trans "Processador"): ${null}$processor x$cpus" || msg -ama "$(fun_trans "Processador"): ${null}???"
[[ "$clock" ]] && msg -ama "$(fun_trans "Frequecia de Operacao"): ${null}$clock MHz" || msg -ama "$(fun_trans "Frequecia de Operacao"): ${null}???"
msg -ama "$(fun_trans "Arquitetura"): ${null}$(uname -m)"
msg -ama "$(fun_trans "Uso do Processador"): ${null}$(ps aux  | awk 'BEGIN { sum = 0 }  { sum += sprintf("%f",$3) }; END { printf " " "%.2f" "%%", sum}')"
# MEMORIA RAM
echo ""
echo -e "\033[1;32mMEMORIA RAM \033[0m"
msg -ama "$(fun_trans "Memoria Virtual Total"): ${null}$(($totalram / 1024))"
msg -ama "$(fun_trans "Memoria Virtual Em Uso"): ${null}$(($usedram / 1024))"
msg -ama "$(fun_trans "Memoria Virtual Livre"): ${null}$(($freeram / 1024))"
msg -ama "$(fun_trans "Memoria Virtual Swap"): ${null}$(($swapram / 1024))MB"
# TEMPO ONLINE
echo ""
echo -e "\033[1;32mTEMPO ONLINE \033[0m"
msg -ama "$(fun_trans "Tempo Online"): ${null}$(uptime)"
return 0
}

limpar_cachesOFF () {
(
VE="\033[1;33m" && MA="\033[1;31m" && DE="\033[1;32m"
while [[ ! -e /tmp/abc ]]; do
A+="#"
echo -e " ${VE}[${MA}${A}${VE}]" >&2
sleep 0.3s
tput cuu1 && tput dl1
done
echo -e " ${VE}[${MA}${A}${VE}] - ${DE}100%" >&2
rm /tmp/abc
) &
echo 3 > /proc/sys/vm/drop_caches &>/dev/null
sleep 1s
sysctl -w vm.drop_caches=3 &>/dev/null
apt-get autoclean -y &>/dev/null
sleep 1s
apt-get clean -y &>/dev/null
rm /tmp/* &>/dev/null
touch /tmp/abc
sleep 0.5s
}

limpar_caches () {
fun_limpram() {
	sync
	echo 3 >/proc/sys/vm/drop_caches
	sync && sysctl -w vm.drop_caches=3
	sysctl -w vm.drop_caches=0
	swapoff -a
	swapon -a
	sleep 4
}
function aguarde() {
	sleep 1
	helice() {
		fun_limpram >/dev/null 2>&1 &
		tput civis
		while [ -d /proc/$! ]; do
			for i in / - \\ \|; do
				sleep .1
				echo -ne "\e[1D$i"
			done
		done
		tput cnorm
	}
	echo -ne "\033[1;36m Limpando memoria \033[1;32mRAM \033[1;36me \033[1;32mSWAP\033[1;31m... \033[1;33m"
	helice
	echo -e "\e[1DOk"
}
clear
clear
msg -bar
[[ $(grep -wc mlocate /var/lib/dpkg/statoverride) != '0' ]] && sed -i '/mlocate/d' /var/lib/dpkg/statoverride
msg -ama " $(fun_trans "LIMPAR CACHE SISTEMA")"
msg -bar
# echo -e "\033[1;36m Atualizando pacotes\033[0m"
# fun_bar 'apt-get update -y' 'apt-get upgrade -y'
echo -e "\033[1;36m Corrigindo problemas de dependências"
fun_bar 'apt-get -f install'
echo -e "\033[1;36m Removendo pacotes inúteis"
fun_bar 'apt-get autoremove -y' 'apt-get autoclean -y'
echo -e "\033[1;36m Removendo pacotes com problemas"
fun_bar 'apt-get -f remove -y' 'apt-get clean -y'
# Limpar o cache memoria RAM
msg -bar
MEM1=$(free | awk '/Mem:/ {print int(100*$3/$2)}')
ram1=$(free -h | grep -i mem | awk {'print $2'})
ram2=$(free -h | grep -i mem | awk {'print $4'})
ram3=$(free -h | grep -i mem | awk {'print $3'})
swap1=$(free -h | grep -i swap | awk {'print $2'})
swap2=$(free -h | grep -i swap | awk {'print $4'})
swap3=$(free -h | grep -i swap | awk {'print $3'})
echo -e " \033[1;37mMemória \033[1;32mRAM \033[1;37mAntes da Otimizacao:\033[1;36m" $MEM1%
msg -bar
sleep 1
aguarde
sleep 1
msg -bar
MEM2=$(free | awk '/Mem:/ {print int(100*$3/$2)}')
ram1=$(free -h | grep -i mem | awk {'print $2'})
ram2=$(free -h | grep -i mem | awk {'print $4'})
ram3=$(free -h | grep -i mem | awk {'print $3'})
swap1=$(free -h | grep -i swap | awk {'print $2'})
swap2=$(free -h | grep -i swap | awk {'print $4'})
swap3=$(free -h | grep -i swap | awk {'print $3'})
echo -e " \033[1;37mMemória \033[1;32mRAM \033[1;37mapós a Otimizacao:\033[1;36m" $MEM2%
msg -bra " $(fun_trans "Economia de"):\033[1;31m $(expr $MEM1 - $MEM2)%\033[0m"
msg -bar
msg -ama " $(fun_trans "Sucesso Procedimento Feito")"
}

resetiptables () {
# REINICIAR IPTABLES
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X
iptables -t security -F
iptables -t security -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
service ssh restart > /dev/null 2>&1
service sshd restart > /dev/null 2>&1
msg -ama " $(fun_trans "Procedimento concluido")"
msg -bar
}

packobs () {
# LIMPAR PACOTES OBSOLETOS
#Buscando Pacotes Obsoletos"
dpkg -l | grep -i ^rc
dpkg -l | grep -i ^rc | cut -d " " -f 3 | xargs dpkg --purge
#Pacotes obsoletos limpos
service ssh restart > /dev/null 2>&1
service sshd restart > /dev/null 2>&1
msg -bar
msg -ama " $(fun_trans "Procedimento concluido")"
msg -bar
}

# SISTEMA DE SELECAO
selection_fun () {
local selection="null"
local range
for((i=0; i<=$1; i++)); do range[$i]="$i "; done
while [[ ! $(echo ${range[*]}|grep -w "$selection") ]]; do
echo -ne "\033[1;37m$(fun_trans "Selecione a Opcao"): " >&2
read selection
tput cuu1 >&2 && tput dl1 >&2
done
echo $selection
}

clear
clear
msg -bar
msg -ama "$(fun_trans "MENU DE SISTEMA") "
msg -bar
echo -ne "$(msg -verd "[0]") $(msg -verm2 ">") " && msg -bra "$(fun_trans "VOLTAR")"
echo -ne "$(msg -verd "[1]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "ATUALIZAR SISTEMA")"
echo -ne "$(msg -verd "[2]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "REINICIAR SERVICOS")"
echo -ne "$(msg -verd "[3]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "REINSTALL PACOTES")"
echo -ne "$(msg -verd "[4]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "REINICIAR SISTEMA")"
echo -ne "$(msg -verd "[5]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "ALTERAR NOME DO SISTEMA")"
echo -ne "$(msg -verd "[6]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "ALTERAR SENHA ROOT")"
echo -ne "$(msg -verd "[7]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "TRAFICO DE RED nload")"
echo -ne "$(msg -verd "[8]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "PROCESOS DE SISTEMA htop")"
#------------------------------------------------
echo -ne "$(msg -verd "[9]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "MONITOR DO SISTEMA glances") \033[1;31m[Inestable]"
echo -ne "$(msg -verd "[10]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "RESET IPTABLES") \033[1;31m[Inestable]"
echo -ne "$(msg -verd "[11]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "CLEAN PACKAGE OSOLECTS") \033[1;31m[Inestable]"
#------------------------------------------------
echo -ne "$(msg -verd "[12]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "DETALHES DO SISTEMA")"
echo -ne "$(msg -verd "[13]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "LIMPAR CACHE SISTEMA")"
msg -bar
# FIM
selection=$(selection_fun 11)
case ${selection} in
1)update_pak;;
2)reiniciar_ser;;
3)inst_components;;
4)reiniciar_vps;;
5)host_name;;
6)senharoot;;
7)fun_nload;;
8)fun_htop;;
9)fun_glances;;
10)resetiptables;;
11)packobs;;
12)systen_info;;
13)limpar_caches;;
0)exit;;
esac
msg -bar
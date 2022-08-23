#!/bin/bash
LINK1="https://www.dropbox.com/s/jbwls2qbdsks8tl/menu-dialog.sh?dl=0"
LINK2="https://www.dropbox.com/s/j9m7kjj6328lqxk/interface.sh?dl=0"
cor=( "\033[0m" "\033[1;31m" "\033[1;32m" "\033[1;33m" "\033[1;34m" "\033[1;35m" "\033[1;36m" "\033[1;37m" )
error_fun () {
echo -e "${cor[5]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
echo -e "${cor[2]} Opa, Parece que Algo de Errado não Esta Certo!"
echo -e "\033[1;31mYour apt-get Error!"
echo -e "Reboot the System!"
echo -e "Use Command:"
echo -e "\033[1;36mdpkg --configure -a"
echo -e "\033[1;31mVerify your Source.list"
echo -e "For Update Source list use this comand"
echo -e "\033[1;36mwget https://www.dropbox.com/s/sb82ddp9fjcg1ub/apt-source.sh && chmod 777 ./* && ./apt-*"
echo -e "${cor[5]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
echo -ne "\033[0m"
exit 1
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
Install_dep () {
echo -e "${cor[1]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
echo -e "${cor[6]} Instalando"
echo -e "${cor[1]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
echo -e "${cor[2]} Update"
fun_bar 'apt-get install screen' 'apt-get install python'
echo -e "${cor[2]} Upgrade"
fun_bar 'apt-get install lsof' 'apt-get install python3-pip'
echo -e "${cor[2]} Lsof"
fun_bar 'apt-get install python' 'apt-get install unzip'
echo -e "${cor[2]} Dialog"
fun_bar 'apt-get install dialog' 'apt-get install zip'
echo -e "${cor[2]} Python3"
fun_bar 'apt-get install zip' 'apt-get install apache2'
echo -e "${cor[2]} Unzip"
fun_bar 'apt-get install ufw' 'apt-get install nmap'
echo -e "${cor[2]} Screen"
fun_bar 'apt-get install figlet' 'apt-get install bc'
echo -e "${cor[2]} Figlet"
fun_bar 'apt-get install lynx' 'apt-get install curl'
sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf
service apache2 restart > /dev/null 2>&1
echo -e "${cor[1]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
echo -e "${cor[3]}Perfeito Procedimento Feito com Sucesso!"
echo -e "${cor[1]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
echo -e "${cor[2]}Use os Comandos: menu"
echo -e "${cor[2]}e acesse o script, um bom uso!"
echo -e "${cor[1]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
echo -ne " \033[0m"
}

if ! apt-get install at -y > /dev/null 2>&1
then
error_fun
fi
if ! apt-get install netpipes -y > /dev/null 2>&1
then
error_fun
fi
if ! apt-get install gawk -y > /dev/null 2>&1
then
error_fun
fi
locale-gen en_US.UTF-8 > /dev/null 2>&1
update-locale LANG=en_US.UTF-8 > /dev/null 2>&1

while true
do
clear
echo -e "${cor[1]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
echo -e "${cor[6]} ADM DIALOG - POR (LUIS 8TH4VER)"
echo -e "${cor[3]} ESSA E UMA VERSAO BETA, DESEJA MESMO INSTALAR?"
echo -e "${cor[1]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
read -p " [Sim/Nao]: " Variavel
case $Variavel in
y|Y|s|S|[Ss]im|[Yy]es)break;;
n|N|[Nn]ao|[Nn]o)break;;
esac
done

Install_dep
wget -O /bin/menu ${LINK1} -o /dev/null 2>&1 && chmod 777 /bin/menu
wget -O /bin/interface.sh ${LINK2} -o /dev/null 2>&1 && chmod 777 /bin/interface.sh
rm $0
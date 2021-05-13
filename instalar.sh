#!/bin/bash
cd $HOME
SCPdir="/etc/newadm"
SCPinstal="$HOME/install"
SCPidioma="${SCPdir}/idioma"
SCPusr="${SCPdir}/ger-user"
SCPfrm="/etc/ger-frm"
SCPinst="/etc/ger-inst"
SCPresq="aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL0FBQUFBRVhRT1N5SXBOMkpaMGVoVVEvQURNLVVMVElNQVRFLU5FVy1GUkVFL21hc3Rlci9yZXF1ZXN0"
SUB_DOM='base64 -d'
[[ $(dpkg --get-selections|grep -w "gawk"|head -1) ]] || apt-get install gawk -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "mlocate"|head -1) ]] || apt-get install mlocate -y &>/dev/null
rm $(pwd)/$0 &> /dev/null

msg () {
local colors="/etc/new-adm-color"
if [[ ! -e $colors ]]; then
COLOR[0]='\033[1;37m' #BRAN='\033[1;37m'
COLOR[1]='\e[31m' #VERMELHO='\e[31m'
COLOR[2]='\e[32m' #VERDE='\e[32m'
COLOR[3]='\e[33m' #AMARELO='\e[33m'
COLOR[4]='\e[34m' #AZUL='\e[34m'
COLOR[5]='\e[35m' #MAGENTA='\e[35m'
COLOR[6]='\033[1;36m' #MAG='\033[1;36m'
else
local COL=0
for number in $(cat $colors); do
case $number in
1)COLOR[$COL]='\033[1;37m';;
2)COLOR[$COL]='\e[31m';;
3)COLOR[$COL]='\e[32m';;
4)COLOR[$COL]='\e[33m';;
5)COLOR[$COL]='\e[34m';;
6)COLOR[$COL]='\e[35m';;
7)COLOR[$COL]='\033[1;36m';;
esac
let COL++
done
fi
NEGRITO='\e[1m'
SEMCOR='\e[0m'
 case $1 in
  -ne)cor="${COLOR[1]}${NEGRITO}" && echo -ne "${cor}${2}${SEMCOR}";;
  -ama)cor="${COLOR[3]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -verm)cor="${COLOR[3]}${NEGRITO}[!] ${COLOR[1]}" && echo -e "${cor}${2}${SEMCOR}";;
  -verm2)cor="${COLOR[1]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -azu)cor="${COLOR[6]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -verd)cor="${COLOR[2]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -bra)cor="${COLOR[0]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  "-bar2"|"-bar")cor="${COLOR[4]}——————————————————————————————————————————————————————" && echo -e "${SEMCOR}${cor}${SEMCOR}";;
 esac
}

fun_ip () {
MIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MIP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MIP" != "$MIP2" ]] && IP="$MIP2" || IP="$MIP"
}

inst_components () {
clear
clear
[[ $(dpkg --get-selections|grep -w "curl"|head -1) ]] || apt-get install curl -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "netcat-openbsd"|head -1) ]] || apt-get install netcat-openbsd -y &>/dev/null
msg -bar2
msg -ama "   $(source trans -b pt:${id} "INSTALADOR DO") NEW - ULTIMATE - SCRIPT"
msg -bar2
msg -azu "ESTE SCRIPT IRA!:"
msg -azu "INSTALAR O GERENCIADOR \033[01;31m New-Ultimate-Manager"
msg -bar2
PRETTY_NAME=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/"//g' | cut -d "=" -f2-)
echo -e "\033[01;31mOS:\033[01;37m $PRETTY_NAME"
echo -e "\033[01;31mIP:\033[01;37m $IP"
msg -bar2
apt-get install grep -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "grep"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "grep"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m grep\033[01;37m............$STATUS "
#nano
[[ $(dpkg --get-selections|grep -w "nano"|head -1) ]] || apt-get install nano -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "nano"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "nano"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m nano\033[01;37m............$STATUS "
#bc
[[ $(dpkg --get-selections|grep -w "bc"|head -1) ]] || apt-get install bc -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "bc"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "bc"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m bc\033[01;37m..............$STATUS "
#screen
[[ $(dpkg --get-selections|grep -w "screen"|head -1) ]] || apt-get install screen -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "screen"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "screen"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m screen\033[01;37m..........$STATUS "
#python
[[ $(dpkg --get-selections|grep -w "python"|head -1) ]] || apt-get install python -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "python"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "python"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m python\033[01;37m..........$STATUS "
#python3
[[ $(dpkg --get-selections|grep -w "python3"|head -1) ]] || apt-get install python3 -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "python3"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "python3"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m python3\033[01;37m.........$STATUS "
#curl
[[ $(dpkg --get-selections|grep -w "curl"|head -1) ]] || apt-get install curl -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "curl"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "curl"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m curl\033[01;37m............$STATUS "
#ufw
[[ $(dpkg --get-selections|grep -w "ufw"|head -1) ]] || apt-get install ufw -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "ufw"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "ufw"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m ufw\033[01;37m.............$STATUS "
#unzip
[[ $(dpkg --get-selections|grep -w "unzip"|head -1) ]] || apt-get install unzip -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "unzip"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "unzip"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m unzip\033[01;37m...........$STATUS "
#zip
[[ $(dpkg --get-selections|grep -w "zip"|head -1) ]] || apt-get install zip -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "zip"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "zip"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m zip\033[01;37m.............$STATUS "
#lsof
[[ $(dpkg --get-selections|grep -w "lsof"|head -1) ]] || apt-get install lsof -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "lsof"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "lsof"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m lsof\033[01;37m............$STATUS "
#net-tools
[[ $(dpkg --get-selections|grep -w "net-tools"|head -1) ]] || apt-get install net-tools -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "net-tools"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "net-tools"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m net-tools\033[01;37m.......$STATUS "
#dos2unix
[[ $(dpkg --get-selections|grep -w "dos2unix"|head -1) ]] || apt-get install dos2unix -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "dos2unix"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "dos2unix"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m dos2unix\033[01;37m........$STATUS "
#nload
[[ $(dpkg --get-selections|grep -w "nload"|head -1) ]] || apt-get install nload -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "nload"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "nload"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m nload\033[01;37m...........$STATUS "
#jq
[[ $(dpkg --get-selections|grep -w "jq"|head -1) ]] || apt-get install jq -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "jq"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "jq"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m jq\033[01;37m..............$STATUS "
#python-pip
[[ $(dpkg --get-selections|grep -w "python-pip"|head -1) ]] || apt-get install python-pip -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "python-pip"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "python-pip"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m python-pip\033[01;37m......$STATUS "
#ufw
[[ $(dpkg --get-selections|grep -w "ufw"|head -1) ]] || apt-get install ufw -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "ufw"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "ufw"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m ufw\033[01;37m.............$STATUS "
#gawk
[[ $(dpkg --get-selections|grep -w "gawk"|head -1) ]] || apt-get install gawk -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "gawk"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "gawk"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m gawk\033[01;37m............$STATUS "
#mlocate
[[ $(dpkg --get-selections|grep -w "mlocate"|head -1) ]] || apt-get install mlocate -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "mlocate"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "mlocate"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m mlocate\033[01;37m.........$STATUS "
#at
[[ $(dpkg --get-selections|grep -w "at"|head -1) ]] || apt-get install at -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "at"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "at"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m at\033[01;37m..............$STATUS "
#apache2
[[ $(dpkg --get-selections|grep -w "apache2"|head -1) ]] || {
 apt-get install apache2 -y &>/dev/null
 sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf
 service apache2 restart > /dev/null 2>&1 &
 }
[[ $(dpkg --get-selections|grep -w "apache2"|head -1) ]] || STATUS=`echo -e "\033[91mERRO"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "apache2"|head -1) ]] && STATUS=`echo -e "\033[92mOK"` &>/dev/null
echo -e "\033[01;31mINSTALANDO\033[01;37m apache2\033[01;37m.........$STATUS "
msg -bar
read -n1 -r -p " Enter to Continue..."
}

funcao_idioma () {
msg -bar2
declare -A idioma=( [1]="en English" [2]="fr Franch" [3]="de German" [4]="it Italian" [5]="pl Polish" [6]="pt Portuguese" [7]="es Spanish" [8]="tr Turkish" )
for ((i=1; i<=12; i++)); do
valor1="$(echo ${idioma[$i]}|cut -d' ' -f2)"
[[ -z $valor1 ]] && break
valor1="\033[1;32m[$i] > \033[1;33m$valor1"
    while [[ ${#valor1} -lt 37 ]]; do
       valor1=$valor1" "
    done
echo -ne "$valor1"
let i++
valor2="$(echo ${idioma[$i]}|cut -d' ' -f2)"
[[ -z $valor2 ]] && {
   echo -e " "
   break
   }
valor2="\033[1;32m[$i] > \033[1;33m$valor2"
     while [[ ${#valor2} -lt 37 ]]; do
        valor2=$valor2" "
     done
echo -ne "$valor2"
let i++
valor3="$(echo ${idioma[$i]}|cut -d' ' -f2)"
[[ -z $valor3 ]] && {
   echo -e " "
   break
   }
valor3="\033[1;32m[$i] > \033[1;33m$valor3"
     while [[ ${#valor3} -lt 37 ]]; do
        valor3=$valor3" "
     done
echo -e "$valor3"
done
msg -bar2
unset selection
while [[ ${selection} != @([1-8]) ]]; do
echo -ne "\033[1;37mSELECT: " && read selection
tput cuu1 && tput dl1
done
pv="$(echo ${idioma[$selection]}|cut -d' ' -f1)"
[[ ${#id} -gt 2 ]] && id="pt" || id="$pv"
byinst="true"
}

install_fim () {
msg -ama "$(source trans -b pt:${id} "Instalacao Completa, Utilize os Comandos"|sed -e 's/[^a-z -]//ig')" && msg bar2
echo -e " menu / adm"
msg -bar2
}

install_hosts () {
_arq_host="/etc/hosts"
_host[0]="d1n212ccp6ldpw.cloudfront.net"
_host[1]="dns.whatsapp.net"
_host[2]="portalrecarga.vivo.com.br/recarga"
_host[3]="navegue.vivo.com.br/controle/"
_host[4]="navegue.vivo.com.br/pre/"
_host[5]="www.whatsapp.net"
_host[6]="c.whatsapp.net"
for host in ${_host[@]}; do
	if [[ "$(grep -w "$host" $_arq_host | wc -l)" = "0" ]]; then
		sed -i "3i\127.0.0.1 $host" $_arq_host
	fi
done
}

ofus () {
unset txtofus
number=$(expr length $1)
for((i=1; i<$number+1; i++)); do
txt[$i]=$(echo "$1" | cut -b $i)
case ${txt[$i]} in
".")txt[$i]="+";;
"+")txt[$i]=".";;
"1")txt[$i]="@";;
"@")txt[$i]="1";;
"2")txt[$i]="?";;
"?")txt[$i]="2";;
"3")txt[$i]="%";;
"%")txt[$i]="3";;
"/")txt[$i]="K";;
"K")txt[$i]="/";;
esac
txtofus+="${txt[$i]}"
done
echo "$txtofus" | rev
}

verificar_arq () {
[[ ! -d ${SCPdir} ]] && mkdir ${SCPdir}
[[ ! -d ${SCPusr} ]] && mkdir ${SCPusr}
[[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
[[ ! -d ${SCPinst} ]] && mkdir ${SCPinst}
case $1 in
"menu"|"message.txt")ARQ="${SCPdir}/";; #Menu
"usercodes")ARQ="${SCPusr}/";; #User
"openssh.sh")ARQ="${SCPinst}/";; #Instalacao
"budp.sh")ARQ="${SCPinst}/";; #Instalacao
"apache2.sh")ARQ="${SCPinst}/";; #Instalacao
"squid.sh")ARQ="${SCPinst}/";; #Instalacao
"sslh.sh")ARQ="${SCPinst}/";; #Instalacao
"dropbear.sh")ARQ="${SCPinst}/";; #Instalacao
"openvpn.sh")ARQ="${SCPinst}/";; #Instalacao
"ssl.sh")ARQ="${SCPinst}/";; #Instalacao
"sslpythonAUT.sh")ARQ="${SCPinst}/";; #Instalacao
"shadowsocks.sh")ARQ="${SCPinst}/";; #Instalacao
"vnc.sh")ARQ="${SCPinst}/";; #Instalacao
"webmin.sh")ARQ="${SCPinst}/";; #Instalacao
"v2ray.sh")ARQ="${SCPinst}/";; #Instalacao
"sockspy.sh"|"PDirect.py"|"PPub.py"|"PPriv.py"|"POpen.py"|"PGet.py")ARQ="${SCPinst}/";; #Instalacao
*)ARQ="${SCPfrm}/";; #Ferramentas
esac
mv -f ${SCPinstal}/$1 ${ARQ}/$1
chmod +x ${ARQ}/$1
}

# Instala��o NEW-ULTIMATE
fun_ip
wget -O /usr/bin/trans https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/trans &> /dev/null
inst_components
clear
clear
msg -bar2
msg -ama "[ NEW - ULTIMATE - SCRIPT ]            \033[1;37m@admmanagerfree"
[[ $1 = "" ]] && funcao_idioma || {
[[ ${#1} -gt 2 ]] && funcao_idioma || id="$1"
 }
error_fun () {
msg -bar2 && msg -verm "$(source trans -b pt:${id} "Esta Chave Era de Outro Servidor Portanto Foi Excluida"|sed -e 's/[^a-z -]//ig') " && msg -bar2
[[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
exit 1
}
invalid_key () {
msg -bar2 && msg -verm "Key Failed! " && msg -bar2
[[ -e $HOME/lista-arq ]] && rm $HOME/lista-arq
exit 1
}
Key="qra-atsilK?29@%6087%?88d5K8888:%05+08+@@?+91"
REQUEST=$(echo $SCPresq|$SUB_DOM)
echo "$IP" > /usr/bin/vendor_code
cd $HOME
msg -ne "Files: "
wget -O $HOME/lista-arq ${REQUEST}/lista-arq > /dev/null 2>&1 && echo -e "\033[1;32m Verified" || {
   echo -e "\033[1;32m Verified"
   invalid_key
   exit
   }
sleep 1s
updatedb
if [[ -e $HOME/lista-arq ]] && [[ ! $(cat $HOME/lista-arq|grep "KEY INVALIDA!") ]]; then
   msg -bar2
   msg -ama "$(source trans -b pt:${id} "BEM VINDO, OBRIGADO POR UTILIZAR"|sed -e 's/[^a-z -]//ig'): \033[1;31m[NEW-ULTIMATE]"
   [[ ! -d ${SCPinstal} ]] && mkdir ${SCPinstal}
   pontos="."
   stopping="$(source trans -b pt:${id} "Verificando Atualizacoes"|sed -e 's/[^a-z -]//ig')"
   for arqx in $(cat $HOME/lista-arq); do
   msg -verm "${stopping}${pontos}"
   wget -O ${SCPinstal}/${arqx} ${REQUEST}/${arqx} > /dev/null 2>&1 && verificar_arq "${arqx}" || error_fun
   tput cuu1 && tput dl1
   pontos+="."
   done
   sleep 1s
   msg -bar2
   listaarqs="$(locate "lista-arq"|head -1)" && [[ -e ${listaarqs} ]] && rm $listaarqs   
   cat /etc/bash.bashrc|grep -v '[[ $UID != 0 ]] && TMOUT=15 && export TMOUT' > /etc/bash.bashrc.2
   echo -e '[[ $UID != 0 ]] && TMOUT=15 && export TMOUT' >> /etc/bash.bashrc.2
   mv -f /etc/bash.bashrc.2 /etc/bash.bashrc
   echo "${SCPdir}/menu" > /usr/bin/menu && chmod +x /usr/bin/menu
   echo "${SCPdir}/menu" > /usr/bin/adm && chmod +x /usr/bin/adm
   echo "${SCPdir}/menu" > /bin/h && chmod +x /bin/h
   wget -O $HOME/versao https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/versao &> /dev/null
   # inst_components
   install_hosts
   echo "$Key" > ${SCPdir}/key.txt
   [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}   
   [[ ${#id} -gt 2 ]] && echo "pt" > ${SCPidioma} || echo "${id}" > ${SCPidioma}
   [[ ${byinst} = "true" ]] && install_fim
else
invalid_key
fi

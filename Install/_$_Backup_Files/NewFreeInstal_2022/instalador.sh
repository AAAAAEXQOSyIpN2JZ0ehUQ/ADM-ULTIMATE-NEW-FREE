#!/bin/bash
LINK1="https://www.dropbox.com/s/w5u4qfnyrcv38d2/adm_codes.sh?dl=0"
cor=( "\033[0m" "\033[1;31m" "\033[1;32m" "\033[1;33m" "\033[1;34m" "\033[1;35m" "\033[1;36m" "\033[1;37m" )
function error_fun () {
  echo -e "${cor[5]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
  echo -e "${cor[2]} Opa, Parece que Algo de Errado não Esta Certo!"
  echo -e "\033[1;31mYour apt-get Error!"
  echo -e "Reboot the System!"
  echo -e "Use Command:"
  echo -e "\033[1;36mdpkg --configure -a"
  echo -e "\033[1;31mVerify your Source.list"
  echo -e "For Update Source list use this comand"
  echo -e "\033[1;36mwget https://www.dropbox.com/s/sb82ddp9fjcg1ub/apt-source.sh && chmod +x ./apt-* && ./apt-*"
  echo -e "${cor[5]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
  echo -ne "\033[0m"
  exit 1
}
function fun_bar () {
  local PID="$RANDOM"
  (
  $@ > /dev/null 2>&1
  touch /tmp/$PID
  ) > /dev/null 2>&1 &
  echo -ne "\033[1;33m ["
  while true; do
    for((i=0; i<18; i++)); do
    echo -ne "\033[1;31m##"
    sleep 0.1s
    done
    if [[ -e /tmp/$PID ]]; then
      echo -e "\033[1;33m]\033[1;31m -\033[1;32m 100%\033[1;37m"
      rm /tmp/$PID
      break
    else
    echo -e "\033[1;33m]"
    sleep 1s
    tput cuu1 && tput dl1
    echo -ne "\033[1;33m ["
    fi
  done
}
function Install_dep () {
  echo -e "${cor[1]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
  echo -e "${cor[6]} Instalando Dependencias"
  echo -e "${cor[1]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
  echo -e "${cor[2]} Screen"
  fun_bar 'apt-get install screen -y'
  echo -e "${cor[2]} lsof"
  fun_bar 'apt-get install lsof -y'
  echo -e "${cor[2]} Python"
  fun_bar 'apt-get install python3 -y'
  fun_bar 'apt-get install python3-pip -y'
  echo -e "${cor[2]} Zip/Unzip"
  fun_bar 'apt-get install unzip -y'
  fun_bar 'apt-get install zip -y'
  echo -e "${cor[2]} Ufw"
  fun_bar 'apt-get install ufw -y'
  echo -e "${cor[2]} Nmap/Curl"
  fun_bar 'apt-get install nmap -y'
  fun_bar 'apt-get install curl -y'
  echo -e "${cor[2]} Figlet/bc"
  fun_bar 'apt-get install figlet -y'
  fun_bar 'apt-get install bc -y'
  echo -e "${cor[2]} Utils"
  fun_bar 'apt-get install lynx -y'
  fun_bar 'apt-get install net-tools -y'
  fun_bar 'apt-get install mlocate -y'
  fun_bar 'apt-get install apache2-utils -y'
  echo -e "${cor[1]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
  echo -e "${cor[3]}Perfeito Procedimento Feito com Sucesso!"
  echo -e "${cor[1]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
  echo -e "${cor[2]}Use os Comandos: menu"
  echo -e "${cor[2]}e acesse o script, um bom uso!"
  echo -e "${cor[1]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
  echo -ne " \033[0m"
}
function main () {
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
  SCPdir="/etc/adm_manager" && [[ ! -d ${SCPdir} ]] && mkdir ${SCPdir}
  SCPusr="${SCPdir}/gerenciador" && [[ ! -d ${SCPusr} ]] && mkdir ${SCPusr}
  SCPmsg="${SCPdir}/message.txt"
  while :
    do
    clear
    echo -e "${cor[1]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
    echo -e "${cor[6]} ADM 2021 - POR (LUIS 8TH4VER)"
    echo -e "${cor[3]} ESSA E UMA VERSAO BETA, DESEJA MESMO INSTALAR?"
    echo -e "${cor[1]}=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠=≠"
    read -p " [Sim/Nao]: " Variavel
    case $Variavel in
      y|Y|s|S|[Ss]im|[Yy]es) break;;
      n|N|[Nn]ao|[Nn]o) echo -e "${cor[0]}" && rm $0 && exit 0;;
    esac
  done
  Install_dep
  wget -O ${SCPusr}/adm_codes.sh ${LINK1} -o /dev/null 2>&1
  chmod +x ${SCPusr}/adm_codes.sh
  echo -e "Para Sugestao ou Bugs @E8th4ver" > ${SCPmsg} #Dev Msg
  # init
  echo "${SCPusr}/adm_codes.sh" > /usr/bin/menu && chmod +x /usr/bin/menu
  echo "${SCPusr}/adm_codes.sh" > /usr/bin/adm && chmod +x /usr/bin/adm
  rm $0
}
main
# CMD
# apt-get update -y && apt-get upgrade -y && wget https://www.dropbox.com/s/h3p3oxk223jibh5/instalador.sh?dl=0 && chmod +x ./instal* && ./insta* 
#!/bin/bash

IVAR="/etc/http-instas"
# FUNCAO PARA DETERMINAR O IP
remover_key_usada () {
local DIR="/etc/http-shell"
i=0
[[ -z $(ls $DIR|grep -v "ERROR-KEY") ]] && return
for arqs in `ls $DIR|grep -v "ERROR-KEY"|grep -v ".name"`; do
 if [[ -e ${DIR}/${arqs}/used.date ]]; then #KEY USADA
  if [[ $(ls -l -c ${DIR}/${arqs}/used.date|cut -d' ' -f7) != $(date|cut -d' ' -f3) ]]; then
  rm -rf ${DIR}/${arqs}*
  fi
 fi
let i++
done
}
fun_ip () {
if [[ ! -e /etc/MEU_IP ]]; then
local MIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
local MIP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MIP" != "$MIP2" ]] && IP="$MIP2" || IP="$MIP"
echo "$IP" > /etc/MEU_IP
echo "$IP"
else
echo "$(cat /etc/MEU_IP)"
fi
}
# LOOP PARA EXECUCAO DO PROGRAMA
listen_fun () {
local PORTA="8888" && local PROGRAMA="/bin/http-server.sh"
while true; do nc.traditional -l -p "$PORTA" -e "$PROGRAMA"; done
}
# SERVER EXECUTAVEL
server_fun () {
DIR="/etc/http-shell" #DIRETORIO DAS KEYS ARMAZENADAS
if [[ ! -d $DIR ]]; then mkdir $DIR; fi
read URL
KEY=$(echo $URL|cut -d' ' -f2|cut -d'/' -f2) && [[ ! $KEY ]] && KEY="ERRO" #KEY
ARQ=$(echo $URL|cut -d' ' -f2|cut -d'/' -f3)  && [[ ! $ARQ ]] && ARQ="ERRO" #LISTA INSTALACAO
USRIP=$(echo $URL|cut -d' ' -f2|cut -d'/' -f4) && [[ ! $USRIP ]] && USRIP="ERRO" #IP DO USUARIO
REQ=$(echo $URL|cut -d' ' -f2|cut -d'/' -f5) && [[ ! $REQ ]] && REQ="ERRO"
echo "KEY: $KEY" >&2
echo "LISTA: $ARQ" >&2
echo "IP: $USRIP" >&2
echo "REQ: $REQ" >&2
DIRETORIOKEY="$DIR/$KEY" # DIRETORIO DA KEY
LISTADEARQUIVOS="$DIRETORIOKEY/$ARQ" # LISTA DE ARQUIVOS
if [[ -d "$DIRETORIOKEY" ]]; then #VERIFICANDO SE A CHAVE EXISTE
  if [[ -e "$DIRETORIOKEY/$ARQ" ]]; then #VERIFICANDO LISTA DE ARQUIVOS
  #ENVIA LISTA DE DOWLOADS
  FILE="$DIRETORIOKEY/$ARQ" 
  STATUS_NUMBER="200"
  STATUS_NAME="Found"
  ENV_ARQ="True"
  fi
  if [[ -e "$DIRETORIOKEY/FERRAMENTA" ]]; then #VERIFICA SE A KEY E FERRAMETA
   if [[ ${USRIP} != "ERRO" ]]; then #SE FOR FERRAMENTA O IP NAO DEVE SER ENVIADO
    FILE="${DIR}/ERROR-KEY"
    echo "FERRAMENTA KEY!" > ${FILE}
    ENV_ARQ="False"
   fi
 else
   if [[ ${USRIP} = "ERRO" ]]; then #VERIFICA SE FOR INSTALACAO O IP DEVE SER ENVIADO
    FILE="${DIR}/ERROR-KEY"
    echo "KEY DE INSTALA�AO!" > ${FILE}
    ENV_ARQ="False"
   fi
 fi
else
# KEY INVALIDA
  FILE="${DIR}/ERROR-KEY"
  echo "KEY INVALIDA!" > ${FILE}
  STATUS_NUMBER="200"
  STATUS_NAME="Found"
  ENV_ARQ="False"
fi
#ENVIA DADOS AO USUARIO
cat << EOF
HTTP/1.1 $STATUS_NUMBER - $STATUS_NAME
Date: $(date)
Server: ShellHTTP
Content-Length: $(wc --bytes "$FILE" | cut -d " " -f1)
Connection: close
Content-Type: text/html; charset=utf-8

$(cat "$FILE")
EOF
#FINALIZA O ENVIO
if [[ $ENV_ARQ != "True" ]]; then exit; fi #FINALIZA REQUEST CASO NAO ENVIE ARQUIVOS
if [[ $(cat $DIRETORIOKEY/used 2>/dev/null) = "" ]]; then
# at now + 1440 min <<< "rm -rf ${DIRETORIOKEY}*" # AGENDADOR!
echo "$USRIP" > $DIRETORIOKEY/used
echo "USADA: $(date |cut -d' ' -f3,4)" > $DIRETORIOKEY/used.date
fi #VERIFICA SE O IP E VARIAVEL
#VERIFICA SE A KEY FIXA ESTA NO IP CORRETO
if [[ $(cat $DIRETORIOKEY/used) != "$USRIP" ]]; then
  #IP INVALIDO BLOQUEIA INSTALACAO
  log="/etc/gerar-sh-log"
  echo "USUARIO: $(cat $DIRETORIOKEY.name) IP FIXO: $(cat $DIRETORIOKEY/keyfixa) USOU IP: $USRIP" >> $log
  echo "SUA KEY FIXA FOI BLOQUEADA" >> $log
  echo "--------------------------------------------------------------------" >> $log
  rm -rf ${DIRETORIOKEY}*
  exit #KEY INVALIDA, FINALIZA REQUEST
fi
(
mkdir /var/www/$KEY
mkdir /var/www/html/$KEY
TIME="20+"
  for arqs in `cat $FILE`; do
  cp $DIRETORIOKEY/$arqs /var/www/html/$KEY/
  cp $DIRETORIOKEY/$arqs /var/www/$KEY/
  TIME+="1+"
  done
TIME=$(echo "${TIME}0"|bc)
sleep ${TIME}s
if [[ -d /var/www/$KEY ]]; then rm -rf /var/www/$KEY; fi
if [[ -d /var/www/html/$KEY ]]; then rm -rf /var/www/html/$KEY; fi
num=$(cat ${IVAR})
if [[ $num = "" ]]; then num=0; fi
let num++
echo $num > $IVAR
remover_key_usada
) & > /dev/null
}
[[ $1 = @(-[Ss]tart|-[Ss]|-[Ii]niciar) ]] && listen_fun && exit
[[ $1 = @(-[Ii]stall|-[Ii]|-[Ii]stalar) ]] && listen_fun && exit
server_fun
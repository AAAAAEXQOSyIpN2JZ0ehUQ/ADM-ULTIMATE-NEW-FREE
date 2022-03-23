#!/bin/bash
clear
# INSTALACAO BASICA
BASICINST="menu message.txt ports.sh ADMbot.sh PGet.py usercodes sockspy.sh POpen.py PPriv.py PPub.py PDirect.py speedtest.py speed.sh utils.sh dropbear.sh apacheon.sh openvpn.sh shadowsocks.sh ssl.sh squid.sh"
IVAR="/etc/http-instas"
IVAR2="/etc/key-gerador"
cabecalho_fun () {
BARRA="\033[1;36m============================================\033[0m"
echo -e "$BARRA"
cat << EOF

           NEW KEY GENERATOR BY 8TH
           INSTALACOES: $(cat $IVAR)
           
EOF
[[ -e $IVAR2 ]] && echo -e "\033[1;32mFIXKEY: $(cat $IVAR2)\033[0m"
SCPT_DIR="/etc/SCRIPT"
[[ ! -e ${SCPT_DIR} ]] && mkdir ${SCPT_DIR}
rm ${SCPT_DIR}/*.x.c &> /dev/null
INSTA_ARQUIVOS="ADMVPS.zip"
DIR="/etc/http-shell"
LIST="lista-arq"
}
meu_ip () {
MIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MIP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MIP" != "$MIP2" ]] && IP="$MIP2" || IP="$MIP"
}
fun_trans () { 
local texto
local retorno
[[ ! -e  $HOME/ID ]] && local LANG=pt || local LANG="$(cat $HOME/ID)"
declare -A texto
[[ ! -e /etc/texto-adm ]] && touch /etc/texto-adm
source /etc/texto-adm
if [[ -z $(echo ${texto[$2]}) ]]; then
ENGINES=(aspell google deepl bing spell hunspell apertium yandex)
  while [[ -z $retorno ]]; do
   local NUM="$(($RANDOM%${#ENGINES[@]}))"
   local retorno="$(source trans -e ${ENGINES[$NUM]} -b pt:$LANG "$2"|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
  done
 echo "texto[$2]='$retorno'"  >> /etc/texto-adm
 echo "$retorno"
else
 echo "${texto[$2]}"
fi
}
meu_ip
cabecalho_fun
fun_list () {
unset KEY
KEY="$1"
#CRIA DIR
[[ ! -e ${DIR} ]] && mkdir ${DIR}
[[ ! -e ${DIR}/${KEY} ]] && mkdir ${DIR}/${KEY}
#ENVIA ARQS
i=0
for arqx in `ls ${SCPT_DIR}`; do
[[ $(echo $BASICINST|grep -w "${arqx}") ]] && continue
echo -e "[$i] -> FERRAMENTA \033[1;31m[${arqx}]\033[0m"
arq_list[$i]="${arqx}"
let i++
done
echo -e "[x] -> TODAS FERRAMENTA"
echo -e "[b] -> \033[1;33mINSTALACAO NEW-ADM\033[0m"
read -p "Escolha os Arquivos a Serem Repassados: " readvalue
[[ -z $readvalue ]] && readvalue="b"
read -p "Nome do Usuario ( dono da Key ): " nombrevalue
[[ -z $nombrevalue ]] && nombrevalue="unnamed"
read -p "Key Fixa? [S/N]: " -e -i n fixakey
[[ $fixakey = @(s|S|y|Y) ]] && read -p "IP-Fixo: " IPFIX && nombrevalue+=[FIXA]
if [[ $readvalue = @(b|B) ]]; then
#ADM BASIC
 arqslist="$BASICINST"
 for arqx in `echo "${arqslist}"`; do
 [[ -e ${DIR}/${KEY}/$arqx ]] && continue #ANULA ARQUIVO CASO EXISTA
 cp ${SCPT_DIR}/$arqx ${DIR}/${KEY}/
 echo "$arqx" >> ${DIR}/${KEY}/${LIST}
 done
elif [[ $readvalue = @(x|X) ]]; then
#FULL ARQS
 for arqx in `echo "${arq_list[@]}"`; do
  [[ -e ${DIR}/${KEY}/$arqx ]] && continue #ANULA ARQUIVO CASO EXISTA
  cp ${SCPT_DIR}/$arqx ${DIR}/${KEY}/
 echo "$arqx" >> ${DIR}/${KEY}/${LIST}
 done
echo "TRUE" >> ${DIR}/${KEY}/FERRAMENTA
else
 for arqx in `echo "${readvalue}"`; do
 #UNE ARQ
 [[ -e ${DIR}/${KEY}/${arq_list[$arqx]} ]] && continue #ANULA ARQUIVO CASO EXISTA
 cp ${SCPT_DIR}/${arq_list[$arqx]} ${DIR}/${KEY}/
 echo "${arq_list[$arqx]}" >> ${DIR}/${KEY}/${LIST}
 done
echo "TRUE" >> ${DIR}/${KEY}/FERRAMENTA
fi
echo "$nombrevalue" > ${DIR}/${KEY}.name
[[ ! -z $IPFIX ]] && echo "$IPFIX" > ${DIR}/${KEY}/keyfixa
echo -e "$BARRA"
echo -e "Key Ativa, e Aguardando Instalacao!"
echo -e "$BARRA"
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
gerar_key () {
valuekey="$(date | md5sum | head -c10)"
valuekey+="$(echo $(($RANDOM*10))|head -c 5)"
fun_list "$valuekey"
keyfinal=$(ofus "$IP:8888/$valuekey/$LIST")
echo -e "KEY: $keyfinal\nGerada!"
echo -e "$BARRA"
read -p "Enter to Finalize"
}
remover_key () {
i=0
[[ -z $(ls $DIR|grep -v "ERROR-KEY") ]] && return
echo "[$i] Retornar"
keys="$keys retorno"
let i++
for arqs in `ls $DIR|grep -v "ERROR-KEY"|grep -v ".name"`; do
arqsx=$(ofus "$IP:8888/$arqs/$LIST")
[[ $(cat ${DIR}/${arqs}.name|grep FIXA) ]] && echo -e "\033[1;33m[$i] $arqsx ($(cat ${DIR}/${arqs}.name))\033[1;32m ($(cat ${DIR}/${arqs}/keyfixa))\033[0m" || echo -e "[$i] $arqsx ($(cat ${DIR}/${arqs}.name))"
keys="$keys $arqs"
let i++
done
keys=($keys)
echo -e "$BARRA"
while [[ -z ${keys[$value]} || -z $value ]]; do
read -p "Escolha qual remover: " -e -i 0 value
done
[[ -d "$DIR/${keys[$value]}" ]] && rm -rf $DIR/${keys[$value]}* || return
}
atualizar_keyfixa () {
i=0
[[ -z $(ls $DIR|grep -v "ERROR-KEY") ]] && return
for arqs in `ls $DIR|grep -v "ERROR-KEY"|grep -v ".name"`; do
 if [[ $(cat ${DIR}/${arqs}.name|grep FIXA) ]]; then #Keyfixa Atualiza
   for arqx in `echo "${BASICINST}"`; do
    cp ${SCPT_DIR}/$arqx ${DIR}/${arqs}/$arqx
   done
 arqsx=$(ofus "$IP:8888/$arqs/$LIST")
 echo -e "\033[1;33m[KEY]: $arqsx \033[1;32m(ATUALIZADA!)\033[0m"
 fi
let i++
done
echo -e "$BARRA"
echo -ne "\033[0m" && read -p "Enter"
}
start_gen () {
unset PIDGEN
PIDGEN=$(ps aux|grep -v grep|grep "http-server.sh")
if [[ ! $PIDGEN ]]; then
screen -dmS generador /bin/http-server.sh -start
else
killall http-server.sh
fi
}
message_gen () {
read -p "NEW MESSAGE: " MSGNEW
echo "$MSGNEW" > ${SCPT_DIR}/message.txt
echo -e "$BARRA"
}
atualizar_geb () {
wget -O $HOME/instger.sh https://www.dropbox.com/s/w0s2rv92wy7z3fq/instgerador.sh?dl=0 &>/dev/null
chmod +x $HOME/instger.sh
cd $HOME
./instger.sh
rm $HOME/instger.sh &>/dev/null
}
meu_ip
id=pt
unset PID_GEN
PID_GEN=$(ps x|grep -v grep|grep "http-server.sh")
[[ ! $PID_GEN ]] && PID_GEN="\033[1;31moff" || PID_GEN="\033[1;32monline"
echo -e "$BARRA"
echo -e "Diretorio Dos Arquivos Repassados \033[1;31m${SCPT_DIR}\033[0m"
echo -e "$BARRA"
echo -e "[1] = $(fun_trans ${id} "GERAR 1 KEY ALEATORIA")"
echo -e "[2] = $(fun_trans ${id} "APAGAR OLHAR KEYS")"
echo -e "[3] = $(fun_trans ${id} "INICIAR PARAR") KEYGEN $PID_GEN\033[0m"
echo -e "[4] = $(fun_trans ${id} "VER LOG")"
echo -e "[5] = $(fun_trans ${id} "MUDAR MENSAGEM")"
echo -e "[6] = $(fun_trans ${id} "ATUALIZAR KEYS FIXA")"
echo -e "[7] = $(fun_trans ${id} "ATUALIZAR GERADOR")"
echo -e "[0] = $(fun_trans ${id} "SAIR")"
echo -e "$BARRA"
while [[ ${varread} != @([0-7]) ]]; do
read -p "Opcao: " varread
done
echo -e "$BARRA"
if [[ ${varread} = 1 ]]; then
gerar_key
elif [[ ${varread} = 2 ]]; then
remover_key
elif [[ ${varread} = 3 ]]; then
start_gen
read -p "Enter"
elif [[ ${varread} = 4 ]]; then
echo -ne "\033[1;36m"
cat /etc/gerar-sh-log 2>/dev/null || echo "NENHUM LOG NO MOMENTO"
echo -ne "\033[0m" && read -p "Enter"
elif [[ ${varread} = 5 ]]; then
message_gen
elif [[ ${varread} = 6 ]]; then
atualizar_keyfixa
elif [[ ${varread} = 7 ]]; then
atualizar_geb
elif [[ ${varread} = 0 ]]; then
exit 0
fi
gerar.sh
#!/bin/bash
up () { # PARA TESTE
rm menu*
wget https://www.dropbox.com/s/djmrty689kj2mzt/menu.sh &>/dev/null
bash menu*
}
# CONDICOES PRIMARIAS
[[ ! $(which dialog) ]] && debconf-apt-progress -- apt-get install dialog -y
SCPlcl="/etc/dg-adm" && [[ ! -d ${SCPlcl} ]] && mkdir $SCPlcl
SCPfrm="$SCPlcl/ger-frm" && [[ ! -d ${SCPfrm} ]] && mkdir $SCPfrm
SCPinst="$SCPlcl/ger-inst" && [[ ! -d ${SCPinst} ]] && mkdir $SCPinst
#####################
# INTERFACE GRAFICA DIALOG #
#####################
space () { #Palavra #Espaco
local RET="$1"
while [[ ${#RET} -lt "$2" ]]; do
RET=$RET' '
done
echo "$RET"
}
txt () { # Sistema de Traducao
echo "$@"
}
seletor_fun () {
local MSG=$(txt $1) ; local DIR=$(txt $2)
dialog --stdout --title "$MSG" --fselect $DIR/ 14 48
[[ $? = 1 ]] && return 1 || return 0
}
fun_alterar() { # Arquivo # Campo_busca_para_definir_a_linha # Novo_campo
ARQUIVO="$1" ; LINHA=$(grep -n "$2" $ARQUIVO|head -1|awk -F: 'END{print$1}')
sed -i "${LINHA}s/.*/$3/" $ARQUIVO
}
fun_unir() { # coloca _ entre os espaçamentos do texto.
echo "$@"|tr ' ' '_'
}
menu () { # Menu com Dialog OPT=MSG
[[ -z $@ ]] && return 1
if [[ "$1" = -[Tt] ]]; then
local TITLE="$(txt $2)" && shift ; shift
else 
local TITLE="$(txt Escolha As Seguintes Opcoes)"
fi
local line opt1 opt2
while [[ "$@" ]]; do
IFS="=" && read -r opt1 opt2 <<< "$1" && unset IFS
read -r opt2 < <(fun_unir $(txt $opt2))
line+="$opt1 $opt2 "
shift
done
dialog --stdout --title "$(txt Selecione...)" --menu "$TITLE"  0 0 0 \
$line
case $? in
0)return 0;; # Ok
1)return 1;; # Cancelar
2)return 1;; # Help
255)return 1;; # Esc
esac
} 
fun_pergunta () { # Cria Um Box De Pergunta Usando Dialog
local IMPUT=$(fun_unir $(txt $@))
dialog --stdout --inputbox "$IMPUT" 0 0
case $? in
0)return 0;; # Ok
1)return 1;; # Cancelar
2)return 1;; # Help
255)return 1;; # Esc
esac
}
box_arq (){ # Cria um Box Apartir de Um Arquivo "arq" "texto"
local ARQ="$2" ; local TI="$1"
[[ -z "$TI" ]] && local TI="$(txt Mensagem)" || local TI=$(fun_unir $(txt "$TI"))
dialog --stdout --title "${TI}" --textbox "${ARQ}" 0 0
}
box () { # Cria Um Box Apartir De Um Texto
local ENT=("$@") ; local TITLE=$(fun_unir $(txt ${ENT[0]})) ; local IMPUT="$(txt ${ENT[@]:1})"
dialog --stdout --title "${TITLE}" --msgbox "${IMPUT}" 0 0
}
box_info () {
local ENT=("$@") ; local TITLE=$(fun_unir $(txt ${ENT[0]})) ; local IMPUT="$(txt ${ENT[@]:1})"
dialog --stdout --title "${TITLE}" --infobox "${IMPUT}" 0 0
sleep 2s
}
read_var () { # 1 Parametro e a Pergunta do Read
local VAR ; local READ=$(fun_unir $(txt $@))
while [[ -z $VAR || ${#VAR} -lt 5 ]]; do
if [[ ! -z "$VAR" ]]; then # MANDA MENSAGEM DE ERRO
   [[ "${#VAR}" -lt 5 ]] && box "$(txt ERRO)" "$(txt POR FAVOR DIGITE MAIS DE 5 CARACTERES)"
fi
VAR=$(fun_pergunta $READ) || return 1
done
VAR=$(fun_unir $VAR) && echo "$VAR"
}
read_var_num () { # 1 Parametro e a Pergunta do Read
local VAR ; local READ=$(fun_unir $(txt $@))
while [[ -z $VAR ]] || [[ ${#VAR} -lt 1 ]] || [[ "$VAR" != ?(+|-)+([0-9]) ]]; do
if [[ ! -z "$VAR" ]]; then # MANDA MENSAGEM DE ERRO
    if [[ "${#VAR}" -lt 6 ]]; then box "$(txt ERRO)" "$(txt POR FAVOR DIGITE AO MENOS 1 NUMERO)"
    else [[ "$VAR" != ?(+|-)+([0-9]) ]] && box "$(txt ERRO)" "$(txt POR FAVOR DIGITE APENAS NUMEROS)"
    fi
fi
VAR=$(fun_pergunta $READ) || return 1
done
VAR=$(fun_unir $VAR) && echo "$VAR"
}
fun_bar () { # $1 = Titulo, $2 = Mensagem $3 = %%
local TITLE=$(fun_unir $(txt $1)) ; local MSG=$(fun_unir $(txt $2)) ; local PERCENT=$3
dialog --title "${TITLE}" --gauge "${MSG}" 8 40 0 <<< "${PERCENT}"
}
# INTERFACE GRAFICA DIALOG
# Cores
RED="\e[31m" ; GREN="\e[32m" ; YELLOW="\e[33m" ; BRAN="\e[1;37m"
# Variaveis Globais
ssh_connect () { # openssh - sshpass depend
local ENDERECO_SSH="167.114.4.171" # IP
local USUARIO_SSH="root"
local SENHA_SSH="sHqRqAb78FUt"
local PORTA_SSH="22"
sshpass -p "$SENHA_SSH" ssh $USUARIO_SSH@$ENDERECO_SSH -p "$PORTA_SSH" "$@"
}
#Verificaçao e VARIAVEIS GLOBAIS
SCPdir="/etc/dialogADM" && [[ ! -d ${SCPdir} ]] && mkdir ${SCPdir}
SCPusr="${SCPdir}/ger-user" && [[ ! -d ${SCPusr} ]] && mkdir ${SCPusr}
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
SCPidioma="${SCPdir}/idioma"
USRdatabase="${SCPusr}/USUARIOS"
TMP="/tmp/adm.tmp"
# Auto Run
BASHRCB="/etc/bash.bashrc-bakup"
[[ -e $BASHRCB ]] && AutoRun="[on]" || AutoRun="[off]"
# Funcoes
print () { # Imprime Entradas ARG
cat << EOF
$@
EOF
}
fun_trans () { # tradutor
local texto ; local retorno ; local message=($@)
which jq || apt-get install jq -y 2&>1 /dev/null
which php || apt-get install php -y 2&>1 /dev/null
declare -A texto
SCPidioma="${SCPdir}/idioma"
[[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
local lang=$(cat ${SCPidioma})
[[ -z $lang ]] && lang=pt
[[ ! -e /etc/texto-adm ]] && touch /etc/texto-adm
source /etc/texto-adm
if [[ -z "$(echo ${texto[$@]})" ]]; then
key_api="trnsl.1.1.20160119T111342Z.fd6bf13b3590838f.6ce9d8cca4672f0ed24f649c1b502789c9f4687a"
text=$(echo "${message[@]}"| php -r 'echo urlencode(fgets(STDIN));' // Or: php://stdin)
link=$(curl -s -d "key=$key_api&format=plain&lang=$lang&text=$text" https://translate.yandex.net/api/v1.5/tr.json/translate)
retorno="$(echo $link|jq -r '.text[0]'|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
echo "texto[$@]='$retorno'"  >> /etc/texto-adm
echo "$retorno"
else
echo "${texto[$@]}"
fi
}
fun_line () { # $1=n linhas
for((i=0;i<$1;i++)); do tput cuu1 && tput dl1 ; done
}
funcao_idioma () { # Funcao Idioma
declare -A IDIOMA=( [1]="en English" \
[2]="fr Franch" \
[3]="de German" \
[4]="it Italian" \
[5]="pl Polish" \
[6]="pt Portuguese" \
[7]="es Spanish" \
[8]="tr Turkish" )
local VAR ; local IDIOMA ; local RET
VAR=$(menu -t "Selecione o Seu Idioma" [1]="en English" [2]="fr Franch" [3]="de German" [4]="it Italian" [5]="pl Polish" [6]="pt Portuguese" [7]="es Spanish" [8]="tr Turkish") || return 1
RET=$(echo ${IDIOMA[$(echo $VAR|tr -d '[]')]}|cut -d ' ' -f1)
echo $RET
}
mine_port () { # Saida = Portas em Uso
local portasVAR=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
local NOREPEAT reQ Port SSL SQD APC SSH DPB OVPN PY3
while read port; do
reQ=$(echo ${port}|awk '{print $1}')
Port=$(echo ${port} | awk '{print $9}' | awk -F ":" '{print $2}')
[[ $(echo -e $NOREPEAT|grep -w "$Port") ]] && continue
NOREPEAT+="$Port\n"
case ${reQ} in
squid|squid3)[[ -z $SQD ]] && SQD="SQUID:"
SQD+=" $Port";;
apache|apache2)[[ -z $APC ]] && APC="APACHE:"
APC+=" $Port";;
ssh|sshd)[[ -z $SSH ]] && SSH="SSH:"
SSH+=" $Port";;
stunnel4|stunnel)[[ -z $DPB ]] && SSL="SSL:"
SSL+=" $Port";;
dropbear)[[ -z $DPB ]] && DPB="DROPBEAR:"
DPB+=" $Port";;
openvpn)[[ -z $OVPN ]] && OVPN="OPENVPN:"
OVPN+=" $Port";;
python|python3)[[ -z $PY3 ]] && PY3="SOCKS:"
PY3+=" $Port";;
esac
done <<< "${portasVAR}"
[[ ! -z $SQD ]] && echo -n $SQD'\n'
[[ ! -z $APC ]] && echo -n $APC'\n'
[[ ! -z $SSH ]] && echo -n $SSH'\n'
[[ ! -z $SSL ]] && echo -n $SSL'\n'
[[ ! -z $DPB ]] && echo -n $DPB'\n'
[[ ! -z $OVPN ]] && echo -n $OVPN'\n'
[[ ! -z $PY3 ]] && echo -n $PY3'\n'
}
limpar_caches () { # Limpador de Cache
fun_bar "LIMPANDO CACHE" "AGUARDE LIMPANDO" "0" && sleep 1s
echo 3 > /proc/sys/vm/drop_caches &>/dev/null | fun_bar "LIMPANDO CACHE" "AGUARDE LIMPANDO" "20" && sleep 1s
sysctl -w vm.drop_caches=3 &>/dev/null | fun_bar "LIMPANDO CACHE" "AGUARDE LIMPANDO" "40" && sleep 1s
apt-get autoclean -y &>/dev/null | fun_bar "LIMPANDO CACHE" "AGUARDE LIMPANDO" "60" && sleep 1s
apt-get clean -y &>/dev/null | fun_bar "LIMPANDO CACHE" "AGUARDE LIMPANDO" "80" && sleep 1s
fun_bar "LIMPANDO CACHE" "LIMPEZA CONCLUIDA" "100" && sleep 1s
}
meu_ip () { # Retorna o IP
local IPDATA="/etc/meu-ip"
[[ -e $IPDATA ]] && echo "$(cat $IPDATA)" && return 0
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
[[ $MEU_IP = "127.0.0.1" ]] && MEU_IP=$(wget -qO- ipv4.icanhazip.com)
echo "$MEU_IP" > $IPDATA && echo $MEU_IP
}
os_system () { # Retorna a Distro
system=$(echo $(cat -n /etc/issue |grep 1 |cut -d' ' -f6,7,8 |sed 's/1//' |sed 's/      //')) && echo $system|awk '{print $1, $2}'
}
systen_info () { # info os
local msg && [[ ! -z $msg ]] && unset msg
[[ ! /proc/cpuinfo ]] && msg+="Sistema Nao Suportado\n" && return 1
[[ ! /etc/issue.net ]] && msg+="Sistema Nao Suportado\n" && return 1
[[ ! /proc/meminfo ]] && msg+="Sistema Nao Suportado\n" && return 1
totalram=$(free | grep Mem | awk '{print $2}') ; usedram=$(free | grep Mem | awk '{print $3}')
freeram=$(free | grep Mem | awk '{print $4}') ; swapram=$(cat /proc/meminfo | grep SwapTotal | awk '{print $2}')
system=$(cat /etc/issue.net) ; clock=$(lscpu | grep "CPU MHz" | awk '{print $3}')
based=$(cat /etc/*release | grep ID_LIKE | awk -F "=" '{print $2}') ; processor=$(cat /proc/cpuinfo | grep "model name" | uniq | awk -F ":" '{print $2}')
cpus=$(cat /proc/cpuinfo | grep processor | wc -l)
[[ "$system" ]] && msg+="Sistema $system\n" || msg+="Sistema ???\n"
[[ "$based" ]] && msg+="Baseado $based\n" || msg+="Baseado ???\n"
[[ "$processor" ]] && msg+="Processador $processor x$cpus\n" || msg+="Processador ???\n"
[[ "$clock" ]] && msg+="Frequecia de Operacao $clock MHz\n" || msg+="Frequecia de Operacao ???\n"
msg+="Uso do Processador $(ps aux  | awk 'BEGIN { sum = 0 }  { sum += sprintf("%f",$3) }; END { printf " " "%.2f" "%%", sum}')\n"
msg+="Memoria Virtual Total $(($totalram / 1024))\n"
msg+="Memoria Virtual Em Uso $(($usedram / 1024))\n"
msg+="Memoria Virtual Livre $(($freeram / 1024))\n"
msg+="Memoria Virtual Swap $(($swapram / 1024))MB\n"
msg+="Tempo Online $(uptime)\n"
msg+="Nome Da Maquina $(hostname)\n"
msg+="Endereço Da Maquina $(ip addr | grep inet | grep -v inet6 | grep -v "host lo" | awk '{print $2}' | awk -F "/" '{print $1}')\n"
msg+="Versao do Kernel $(uname -r)\n"
msg+="Arquitetura $(uname -m)"
print $msg
} # box "Detalhes do Sistema" $(systen_info)
# Cabeçalho
VAR () {
local msg && [[ ! -z $msg ]] && unset msg
msg+="FREE NEW OFICIAL POR: LUIS 8TH\n"
msg+="PORTAS ATIVAS E INFORMACOES DO SERVIDOR\n"
msg+="$(mine_port)"
msg+="SISTEMA OPERACIONAL $(os_system)\n"
msg+="ENDERECO DA MAQUINA $(meu_ip)\n"
[[ -e ${SCPdir}/USRonlines ]] && msg+="USUARIOS ONLINE $(cat ${SCPdir}/USRonlines) Usuarios\n"
[[ -e ${SCPdir}/USRexpired ]] && msg+="USUARIOS EXPIRADOS $(cat ${SCPdir}/USRexpired) Usuarios\n"
[[ -e ${SCPdir}/message.txt ]] && msg+="MESSAGE: $(cat ${SCPdir}/message.txt)\n"
[[ -e ${SCPdir}/key.txt ]] && msg+="USER-KEY: $(cat ${SCPdir}/key.txt)\n"
msg+="GERENCIADOR NEW-ULTIMATE DIALOG\n"
print $msg
}
#####################
# GERENCIADOR DE USUARIOS #
#####################
mostrar_usuarios () {
for u in `awk -F : '$3 > 900 { print $1 }' /etc/passwd | grep -v "nobody" |grep -vi polkitd |grep -vi system-`; do
echo "$u"
done
}
att_data() {
local VPSsec DATAUS DataSec
local USUARIO=$1
VPSsec=$(date +%s)
DATAUS=$(chage -l "$USUARIO" |grep -i co |awk -F ":" '{print $2}')
if [[ $DATAUS = *never* ]]; then
echo "Nao-Expira"
else
  DataSec=$(date +%s --date="$DATAUS")
  if [[ $DataSec -gt $VPSsec ]]; then
    echo "$(($(($DataSec - $VPSsec)) / 86400))-Dias"
    else
    echo "Expirado"
  fi
fi
}
atualiza_db () { #USER = PASS DURACAO LIMITE LOKED
local USUARIOSARRAY ; local EDIT=$1 ; local PASS ; local DURA ; local LIMI ; local LOKED
declare -A USUARIOSARRAY
source ${USRdatabase}
echo '#!/bin/bash' > $TMP
for USER in $(mostrar_usuarios); do
[[ $USER = $EDIT ]] && continue
read -r PASS DURA LIMI LOKED <<< "${USUARIOSARRAY[$USER]}"
[[ -z $PASS ]] && PASS=Null
[[ -z $DURA ]] && DURA=Null
[[ -z $LIMI ]] && LIMI=Null
[[ -z $LOKED ]] && LOKED=0
DURA=$(att_data $USER)
echo "USUARIOSARRAY[$USER]='$PASS $DURA $LIMI $LOKED'" >> $TMP
done
mv -f $TMP ${USRdatabase}
[[ ! -z $EDIT ]] && echo ${USUARIOSARRAY[$EDIT]}
}
add_user () { # Usuario # Senha # Duracao # Limite
local US=$1 ; local PAS=$2 ; local DUR=$3 ; local LIM=$4
[[ ! -e ${USRdatabase} ]] && touch ${USRdatabase}
[[ $(cat /etc/passwd |grep $US: |grep -vi [a-z]$US |grep -v [0-9]$US &>/dev/null) ]] && return 1
atualiza_db
local VALIDADE=$(date '+%C%y-%m-%d' -d " +$DUR days")
local EXPIRA=$(date "+%F" -d " + $DUR days")
useradd -M -s /bin/false $US -e ${VALIDADE} &>/dev/null || return 1
passwd $US <<< $(echo $PAS ; echo $PAS) &>/dev/null
if [[ $? = "1" ]]; then
    userdel --force $1
    return 1
fi
echo "USUARIOSARRAY[$US]='$PAS $DUR $LIM 0'" >> ${USRdatabase}
}
edit_user () {
local NULL ; local DATEXP ; local VALID ; local NOME=$1 ; local PASS=$2 ; local DIAS=$3 ; local LIMITE=$4 ; local BLOK=$5
[[ -z $5 ]] && return 1
NULL=$(atualiza_db $NOME)
passwd $NOME <<< $(echo "$PASS" ; echo "$PASS" ) &>/dev/null || return 1
DATEXP=$(date "+%F" -d " + $DIAS days")
VALID=$(date '+%C%y-%m-%d' -d " + $DIAS days")
chage -E $VALID $NOME &>/dev/null || return 1
echo "USUARIOSARRAY[$NOME]='$PASS $DIAS $LIMITE $BLOK'" >> ${USRdatabase}
}
renew_user_fun () { #nome dias
local US=$1 ; local RENEW=$2 ; local PAS ; local DUR ; local LIM ; local BLOK
[[ ! -e ${USRdatabase} ]] && touch ${USRdatabase}
local DATEXP=$(date "+%F" -d " + $RENEW days")
local VALID=$(date '+%C%y-%m-%d' -d " + $RENEW days")
chage -E $VALID $US &> /dev/null || return 1
read -r PAS DUR LIM BLOK<<< $(atualiza_db $US)
local DUR=$RENEW
echo "USUARIOSARRAY[$US]='$PAS $DUR $LIM 0'" >> ${USRdatabase}
}
criar_usuario () {
local RETURN ; local NOME ; local SENHA ; local DURACAO ; local LIMITE
NOME=$(read_var "Digite o Nome do Novo Usuario") || return 1
SENHA=$(read_var "Digite o A Senha do Usuario ${NOME^^}") || return 1
DURACAO=$(read_var_num "Digite a  Duracao do Usuario ${NOME^^}") || return 1
LIMITE=$(read_var_num "Digite o  Limite do Usuario ${NOME^^}") || return 1
RETURN="INFORMACOES_DO_REGISTRO IP do Servidor: $(meu_ip)\nUsuario: $NOME\nSenha: $SENHA\nDias de Duracao: $DURACAO\nData de Expiracao: $(date "+%F" -d " + $DURACAO days")\nLimite de Conexao $LIMITE"
box $RETURN
add_user "${NOME}" "${SENHA}" "${DURACAO}" "${LIMITE}"
}
alterar_usuario () {
local RETURN ; local NOME ; local SENHA ; local DURACAO ; local LIMITE ; local RMV
NOME=$(usuario_select EDITOR DE USUARIO) || return 1
SENHA=$(read_var "Digite o A Senha do Usuario ${NOME^^}") || return 1
DURACAO=$(read_var_num "Digite a  Duracao do Usuario ${NOME^^}") || return 1
LIMITE=$(read_var_num "Digite o  Limite do Usuario ${NOME^^}") || return 1
RETURN="INFORMACOES_DO_REGISTRO IP do Servidor: $(meu_ip)\nUsuario: $NOME\nSenha: $SENHA\nDias de Duracao: $DURACAO\nData de Expiracao: $(date "+%F" -d " + $DURACAO days")\nLimite de Conexao $LIMITE"
box $RETURN
edit_user "${NOME}" "${SENHA}" "${DURACAO}" "${LIMITE}" "0"
}
usuario_select () {
local TEXT="$@" ; local RET ; local RETURN="" ; local ARRAY ; local i ; local USUARIO
RET=$(menu -t "$TEXT" [1]="DIGITAR O NOME DO USUARIO" [2]="SELECIONAR EM UMA LISTA" ) || return 1
if [[ $RET = "[2]" ]]; then
i=1
for USER in $(mostrar_usuarios); do
RETURN+="[$i]=$USER "
ARRAY[$i]=$USER
let i++
done
RET=$(menu -t "SELECIONE O USUARIO" $RETURN) || return 1
USUARIO=${ARRAY[$(echo $RET|tr -d "[]")]}
else
USUARIO=$(read_var "Digite o Nome do Usuario") || return 1
fi
if [[ ! $(awk -F : '$3 > 900 { print $1 }' /etc/passwd | grep -v "nobody" |grep -vi polkitd |grep -vi system-|grep $USUARIO) ]]; then
box "Algo deu Errado" "Usuario Nao Encontrado"
return 1
else
echo $USUARIO
fi
}
usuario_select_rmv () {
local TEXT="$@" ; local RET ; local RETURN="" ; local ARRAY ; local i ; local USUARIO
RET=$(menu -t "$TEXT" [1]="DIGITAR O NOME DO USUARIO" [2]="SELECIONAR EM UMA LISTA" [3]="SELECIONAR TODOS USUARIOS"|tr -d "[]") || return 1
case $RET in
1)USUARIO=$(read_var "Digite o Nome do Usuario") || return 1;;
2)i=1
for USER in $(mostrar_usuarios); do
RETURN+="[$i]=$USER "
ARRAY[$i]=$USER
let i++
done
RET=$(menu -t "SELECIONE O USUARIO" $RETURN|tr -d "[]") || return 1
USUARIO=${ARRAY[$RET]};;
3)echo $(mostrar_usuarios) && return 0;;
esac
if [[ ! $(awk -F : '$3 > 900 { print $1 }' /etc/passwd | grep -v "nobody" |grep -vi polkitd |grep -vi system-|grep $USUARIO) ]]; then
box "Algo deu Errado" "Usuario Nao Encontrado"
return 1
else
echo $USUARIO
fi
}
remover_usuario () {
local RMV USER RETORNO
if [[ -z $1 ]]; then
RMV=$(usuario_select_rmv REMOVEDOR DE USUARIO) || return 1
else
RMV=$1
fi
RETORNO=""
for USER in $(echo $RMV); do
userdel --force $USER && RETORNO+="USUARIO $USER REMOVIDO\n"
done
atualiza_db
box "SUCESSO" $RETORNO
}
block_usuario () {
local RMV ; local PAS ; local DUR ; local LIM ; local BLOK
RMV=$(usuario_select BLOQUEIO DE USUARIO) || return 1
read -r PAS DUR LIM BLOK<<< $(atualiza_db $RMV)
if [[ $BLOK = 1 ]]; then
box "DESBLOQUEADO" "Usuario Desbloqueado com Exito"
echo "USUARIOSARRAY[$RMV]='$PAS $DUR $LIM 0'" >> ${USRdatabase}
else
box "BLOQUEADO" "Usuario Bloqueado com Exito"
echo "USUARIOSARRAY[$RMV]='$PAS $DUR $LIM 1'" >> ${USRdatabase}
fi
}
renovar_user () {
local RMV
RMV=$(usuario_select RENOVAR DATA DE USUARIO) || return 1
DURACAO=$(read_var_num "Digite a  Duracao do Usuario ${RMV^^}") || return 1
renew_user_fun $RMV $DURACAO
}
info_users () {
atualiza_db
local USUARIOSARRAY USER VARX PAS DUR LIM BLOK TOTALUSER
declare -A USUARIOSARRAY
source ${USRdatabase}
TOTALUSER=$(mostrar_usuarios)
if [[ -z $TOTALUSER ]]; then
box "Ops..." "Nenhum Usuario Foi Encontrado\nCrie um usuario e depois Retorne Aqui."
return 0
fi
VARX+="$(space USUARIO 20)$(space SENHA 20)$(space TEMPO 12)$(space LIMITE 14)\n"
for USER in $TOTALUSER; do
read -r PAS DUR LIM BLOK <<< "${USUARIOSARRAY[$USER]}"
VARX+="$(space $USER 20)$(space $PAS 20)$(space $DUR 12)"
[[ $BLOK = 1 ]] && VARX+="$(space $LIM 7)[BLOCK]\n" || VARX+="$(space $LIM 14)\n"
done
echo -e "$VARX" > $TMP
box_arq "DETALHES DOS USUARIOS" $TMP && rm $TMP
}
verify_connect () {
local VERIFY=$1
echo 0
}
monit_ssh () {
local USER ; local VARX
VARX+="$(space USUARIO 20)CONEXAO\n"
for USER in $(mostrar_usuarios); do
VARX+="$(space $USER 20)$(verify_connect $USER)\n"
done
echo -e "$VARX" > $TMP
box_arq "MONITOR" $TMP && rm $TMP
}
rmv_venc () {
local DataVPS DataUser DataSEC RETORNO USER
DataVPS=$(date +%s)
RETORNO=""
while read USER; do
DataUser=$(chage -l "${USER}" |grep -i co|awk -F ":" '{print $2}')
if [[ "$DataUser" = " never" ]]; then
RETORNO+="$USER [Sem Expiracao]\n"
continue
fi
DataSEC=$(date +%s --date="$DataUser")
if [[ "$DataSEC" -lt "$DataVPS" ]]; then
RETORNO+="$USER [Expirado "
remover_usuario "$USER" && RETORNO+="Removido]\n" || RETORNO+="Falha na Remocao]\n"
else
RETORNO+="$USER [Dentro da Validade]\n"
fi
done <<< "$(mostrar_usuarios)"
box "Sucesso" $RETORNO
}
bkp_user () {
local NOME SENHA DATA LIMITE 
local CONT=0
FILE=$(seletor_fun "SELECIONE O BACKUP" $HOME) || return 1
[[ ! -e $FILE ]] && box "OPS" "BACKUP NAO ENCONTRADO" && return 0
while read -r LINE; do
IFS="|" && read -r NOME SENHA DATA LIMITE <<< "$LINE" && unset IFS
[[ -z $NOME ]] && continue
[[ -z $SENHA ]] && continue
[[ -z $DATA ]] && continue
[[ -z $LIMITE ]] && continue
add_user "${NOME}" "${SENHA}" "${DATA}" "${LIMITE}" && let CONT++
done  <<< $(cat $FILE)
local ERRO=$(($(cat $FILE|wc -l)-${CONT}))
local RETURN="IP do Servidor: $(meu_ip)\nTotal de Usuarios No Arquivo: $(cat $FILE|wc -l)\nUsuarios Cadastrados: ${CONT}\nErros Ocorridos: ${ERRO}"
box "PROCESSO FINALIZADO" $RETURN
}
banner_ssh () {
local MSG RET MESSAGE
local FILE="/etc/bannerssh"
if [[ ! $(cat /etc/ssh/sshd_config | grep "Banner /etc/bannerssh") ]]; then
cat /etc/ssh/sshd_config | grep -v Banner > /etc/ssh/s_config && mv -f /etc/ssh/s_config /etc/ssh/sshd_config
echo "Banner /etc/bannerssh" >> /etc/ssh/sshd_config
fi
MSG="Bem vindo esse e o instalador do banner\n"
MSG+="digite a mensagem principal do banner"
box "BANNER SSH" $MSG
MESSAGE=$(read_var "Digite o A Mensagem") || return 1
MSG="[1]=Verde [2]=Vermelho [3]=Azul [4]=Amarelo [5]=Roxo"
RET=$(menu -t "Selecione uma cor" $MSG|tr -d "[]")
echo '<h1><font>=============================</font></h1>' > $FILE
case $RET in
"1")echo -n '<h1><font color="green">' >> $FILE;;
"2")echo -n '<h1><font color="red">' >> $FILE;;
"3")echo -n '<h1><font color="blue">' >> $FILE;;
"4")echo -n '<h1><font color="yellow">' >> $FILE;;
"5")echo -n '<h1><font color="purple">' >> $FILE;;
*)echo -n '<h1><font color="blue">' >> $FILE;;
esac
echo -n "$MESSAGE" >> $FILE
echo '</font></h1>' >> $FILE
echo '<h1><font>=============================</font></h1>' >> $FILE
while true; do
RET=$(menu -t "Adicionar Mensagem Secundaria" [1]=SIM [2]=NAO|tr -d "[]")
if [[ $RET -eq 1 ]]; then
MESSAGE=$(read_var "Digite o A Mensagem") || return 1
MSG="[1]=Verde [2]=Vermelho [3]=Azul [4]=Amarelo [5]=Roxo"
RET=$(menu -t "Selecione uma cor" $MSG|tr -d "[]")
case $RET in
"1")echo -n '<h6><font color="green">' >> $FILE;;
"2")echo -n '<h6><font color="red">' >> $FILE;;
"3")echo -n '<h6><font color="blue">' >> $FILE;;
"4")echo -n '<h6><font color="yellow">' >> $FILE;;
"5")echo -n '<h6><font color="purple">' >> $FILE;;
*)echo -n '<h6><font color="blue">' >> $FILE;;
esac
echo -n "$MESSAGE" >> $FILE
echo "</h6></font>" >> $FILE
else
break
fi
done
#echo '</h8><font color="purple">new®</font></h8>' >> $local
#echo '<h1><font>=============================</font></h1>' >> $local
MSG="Banner Adicionado Com Sucesso\n"
MSG+="Bom Aproveito."
box "BANNER SSH" $MSG
service ssh restart > /dev/null 2>&1 &
service sshd restart > /dev/null 2>&1 & 
service dropbear restart > /dev/null 2>&1 &
}
limiter_ssh () {
if [[ $1 = "info" ]]; then
echo off
else
echo on
fi
}
ger_user_fun () {
local RET
while true
do
PIDLIMITER=$(limiter_ssh info)
RET=$(menu -t "$(VAR)" [1]="CRIAR NOVO USUARIO" \
[2]="REMOVER USUARIO" \
[3]="BLOQUEAR OU DESBLOQUEAR USUARIO" \
[4]="RENOVAR USUARIO" \
[5]="EDITAR USUARIO" \
[6]="DETALHES DE TODOS USUARIOS" \
[7]="MONITORAR USUARIOS CONECTADOS" \
[8]="ELIMINAR USUARIOS VENCIDOS" \
[9]="BACKUP USUARIOS" \
[10]="BANNER SSH" \
[11]="VERIFICACOES $PIDLIMITER") || break
case $RET in
"[1]")criar_usuario;;
"[2]")remover_usuario;;
"[3]")block_usuario;;
"[4]")renovar_user;;
"[5]")alterar_usuario;;
"[6]")info_users;;
"[7]")monit_ssh;;
"[8]")rmv_venc;;
"[9]")bkp_user;;
"[10]")banner_ssh;;
"[11]")limiter_ssh;;
esac
done
}
#####################
#      MENU DE INSTALACOES      #
#####################
minhas_portas () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}
teste_porta () {
local PTST PROGRAM PORT_PROX
PTST=$@
while read PROGRAM PORT_PROX; do
if [[ ! -z $PROGRAM && ! -z $PORT_PROX ]]; then
 if [[ $PTST = $PORT_PROX ]]; then # USO
 echo $PROGRAM
 return 1
 fi
fi
done <<< $(minhas_portas|grep $PTST)
}
agrega_dns () {
local VAR
local SDNS="$1"
cat /etc/hosts|grep -v "$SDNS" > /etc/hosts.bak && mv -f /etc/hosts.bak /etc/hosts
if [[ -e /etc/opendns ]]; then
VAR=$(cat /etc/opendns|grep -v $SDNS)
cat << EOF > /etc/opendns
$VAR
$SDNSl
EOF
else
echo "$SDNS" > /etc/opendns
fi
}
ufw_fun () {
local UFW
for UFW in $(minhas_portas|awk '{print $2}'); do
ufw allow $UFW &> /dev/null
done
}
instalar_squid () {
local SQUID RESP MSG UFW PORTAS PTS PROGRAM PORT PORTA_SQUID NEW_HOST PAYLOADS IP
if [[ -e /etc/squid/squid.conf ]]; then
  SQUID="/etc/squid/squid.conf"
elif [[ -e /etc/squid3/squid.conf ]]; then
  SQUID="/etc/squid3/squid.conf"
fi
if [[ ! -z $SQUID ]]; then
RESP=$(menu -t "SQUID ENCONTRADO." [1]="REMOVER SQUID" [2]="COLOCAR HOST NO SQUID" [3]="REMOVER HOST DO SQUID") || return 1
RESP=$(echo $RESP|tr -d "[]")
case $RESP in
1)box_info "PERFEITO" "REMOVENDO SQUID, AGUARDE"
box_info "REMOVENDO SQUID" "Parando Processos do Squid..."
service squid stop &>/dev/null
debconf-apt-progress -- apt-get remove squid3 -y
[[ -e $SQUID ]] && rm $SQUID
box "PERFEITO" "SQUID REMOVIDO COM SUCESSO"
return 0;;
2)box "Hosts Atuais Dentro do Squid" $(cat /etc/payloads | awk -F "/" '{print $1,$2,$3,$4}')
NEW_HOST=$(read_var "Digite a Nova Host\nComece Utilizando um .\nTermine Utilizando /")
if [[ `grep -c "^$NEW_HOST" /etc/payloads` -eq 1 ]]; then
box "ERRO" "Host Ja Existe"
return 1
fi
PAYLOADS=$(cat /etc/payloads)
cat << EOF > /etc/payloads
$PAYLOADS
$NEW_HOST
EOF
box "SUCESSO" "Host Adicionada Com Sucesso"
if [[ ! -f "/etc/init.d/squid" ]]; then
service squid3 reload &>/dev/null
service squid3 restart &>/dev/null
else
/etc/init.d/squid reload &>/dev/null
service squid restart &>/dev/null
fi
return 0;;
3)box "Hosts Atuais Dentro do Squid" $(cat /etc/payloads | awk -F "/" '{print $1,$2,$3,$4}')
NEW_HOST=$(read_var "Digite a Host Para Remover")
if [[ ! `grep -c "^$NEW_HOST*" /etc/payloads` ]]; then
box "ERRO" "Host Nao Existe"
return 1
fi
PAYLOADS=$(cat /etc/payloads|grep -v $NEW_HOST*)
cat << EOF > /etc/payloads
$PAYLOADS
EOF
box "SUCESSO" "Host Removida Com Sucesso"
if [[ ! -f "/etc/init.d/squid" ]]; then
service squid3 reload &>/dev/null
service squid3 restart &>/dev/null
else
/etc/init.d/squid reload &>/dev/null
service squid restart &>/dev/null
fi
return 0;;
esac
fi
box_info "INSTALADOR" "INSTALANDO SQUID\nINICIANDO CONFIGURACAO"
while [[ -z $PORTA_SQUID ]]; do
PORTAS=$(read_var "Digite as Portas do SQUID\nEx: 8080 80 8989"|tr "_" " ") || return 1
PORTA_SQUID="" && MSG=""
for PTS in $PORTAS; do
if [[ -z $(teste_porta $PTS) ]]; then
PORTA_SQUID+="$PTS "
MSG+="PORTA: [$PTS] OK\n"
else
MSG+="PORTA: [$PTS] USADA POR: $(teste_porta $PTS)\n"
fi
done
box "INSTALADOR" "PORTAS TESTADAS:\n${MSG}"
[[ -z $PORTA_SQUID ]] && box "ERRO" "NENHUMA PORTA VALIDA FOI SELECIONADA"
done
box_info "INSTALADOR" "INSTALANDO SQUID"
debconf-apt-progress -- apt-get install squid3 -y
echo -e ".bookclaro.com.br/\n.claro.com.ar/\n.claro.com.br/\n.claro.com.co/\n.claro.com.ec/\n.claro.com.gt/\n.cloudfront.net/\n.claro.com.ni/\n.claro.com.pe/\n.claro.com.sv/\n.claro.cr/\n.clarocurtas.com.br/\n.claroideas.com/\n.claroideias.com.br/\n.claromusica.com/\n.clarosomdechamada.com.br/\n.clarovideo.com/\n.facebook.net/\n.facebook.com/\n.netclaro.com.br/\n.oi.com.br/\n.oimusica.com.br/\n.speedtest.net/\n.tim.com.br/\n.timanamaria.com.br/\n.vivo.com.br/\n.rdio.com/\n.compute-1.amazonaws.com/\n.portalrecarga.vivo.com.br/\n.vivo.ddivulga.com/" > /etc/payloads
box_info "INSTALADOR" "APLICANDO CONFIGURACOES TRADICIONAIS..."
unset SQUID
if [[ -d /etc/squid ]]; then
SQUID="/etc/squid/squid.conf"
elif [[ -d /etc/squid3 ]]; then
SQUID="/etc/squid3/squid.conf"
fi
read IP <<< $(curl ifconfig.me 2>/dev/null)
cat << EOF > $SQUID
#ConfiguracaoSquiD
acl url1 dstdomain -i $IP
acl url2 dstdomain -i 127.0.0.1
acl url3 url_regex -i '/etc/payloads'
acl url4 url_regex -i '/etc/opendns'
acl url5 dstdomain -i localhost
acl all src 0.0.0.0/0
http_access allow url1
http_access allow url2
http_access allow url3
http_access allow url4
http_access allow url5
http_access deny all

#portas
EOF
for PTS in $PORTA_SQUID; do
echo -e "http_port $PTS" >> $SQUID
done
cat << EOF >> $SQUID
#nome
visible_hostname ADM-MANAGER

via off
forwarded_for off
pipeline_prefetch off
EOF
touch /etc/opendns
box_info "INSTALADOR" "SQUID CONFIGURADO\nREINICIANDO SERVICOS"
squid3 -k reconfigure &> /dev/null
squid -k reconfigure &> /dev/null
service ssh restart &> /dev/null
if [[ ! -f "/etc/init.d/squid" ]]; then
service squid3 reload &>/dev/null
service squid3 restart &>/dev/null
else
/etc/init.d/squid reload &>/dev/null
service squid restart &>/dev/null
fi
ufw_fun
box "FINALIZADO" "SQUID INSTALADO COM SUCESSO\nPORTAS INSTALADAS: $PORTA_SQUID"
}
instalar_dropbear () {
local RESP PORTA_DROPBEAR MSG PROGRAM PORT PORTAS PTS DROP
if [[ -e /etc/default/dropbear ]]; then
RESP=$(menu -t "DROPBEAR ENCONTRADO." [1]="REMOVER DROPBEAR" [2]="MANTER DROPBEAR") || return 1
[[ $RESP != "[1]" ]] && return 0
box "INSTALADOR" "REMOVENDO DROPBEAR"
service dropbear stop &>/dev/null &
debconf-apt-progress -- apt-get remove dropbear -y
box "INSTALADOR"  "Dropbear Removido"
[[ -e /etc/default/dropbear ]] && rm /etc/default/dropbear
return 0
fi
box_info "INSTALADOR" "INSTALADOR DROPBEAR ADM-NEW"
while [[ -z $PORTA_DROPBEAR ]]; do
PORTAS=$(read_var "Digite as Portas do DROPBEAR\nEx: 8080 80 8989"|tr "_" " ") || return 1
PORTA_DROPBEAR="" && MSG=""
for PTS in $PORTAS; do
if [[ -z $(teste_porta $PTS) ]]; then 
PORTA_DROPBEAR+="$PTS "
MSG+="PORTA: [$PTS] OK\n"
else
MSG+="PORTA: [$PTS] USADA POR: $(teste_porta $PTS)\n"
fi
done
box "INSTALADOR" "PORTAS TESTADAS:\n${MSG}"
[[ -z $PORTA_DROPBEAR ]] && box "ERRO" "NENHUMA PORTA VALIDA FOI SELECIONADA"
done
[[ ! $(cat /etc/shells|grep "/bin/false") ]] && echo -e "/bin/false" >> /etc/shells
box_info "INSTALADOR" "INSTALANDO DROPBEAR"
debconf-apt-progress -- apt-get install dropbear -y
cat << EOF > /etc/ssh/sshd_config
Port 22
Protocol 2
KeyRegenerationInterval 3600
ServerKeyBits 1024
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin yes
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication yes
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
#UseLogin no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
EOF
touch /etc/bannerssh
# Capta Distro # $(cat -n /etc/issue |grep 1 |cut -d' ' -f6,7,8 |sed 's/1//' |sed 's/      //' | grep -o Ubuntu)
cat <<EOF > /etc/default/dropbear
NO_START=0
DROPBEAR_EXTRA_ARGS="VAR"
DROPBEAR_BANNER="/etc/bannerssh"
DROPBEAR_RECEIVE_WINDOW=65536
EOF
for DROP in $PORTA_DROPBEAR; do
sed -i "s/VAR/-p $DROP VAR/g" /etc/default/dropbear
done
sed -i "s/VAR//g" /etc/default/dropbear
service ssh restart &> /dev/null
service dropbear restart &> /dev/null
ufw_fun
box "FINALIZADO" "DROPBEAR INSTALADO COM SUCESSO\nPORTAS INSTALADAS: $PORTA_DROPBEAR"
}
# Instalador openvpn
instalar_openvpn () {
local OS VERSION_ID IPTABLES SYSCTL RESP NIC PORT PROTOCOL DNS dns PLUGIN OVPN_PORT PROGRAM PORT_PROX PPROXY NEWDNS DENESI DDNS pid tuns RET
if [[ ! -e /dev/net/tun ]]; then
box_info "INSTALADOR" "TUN nao esta disponivel"
return 1
fi
if [[ ! -e /etc/debian_version ]]; then
box_info "INSTALADOR" "Parece que voce nao esta executando este instalador em um sistema Debian ou Ubuntu"
return 1
fi
OS="debian"
VERSION_ID=$(cat /etc/os-release | grep "VERSION_ID")
IPTABLES='/etc/iptables/iptables.rules'
SYSCTL='/etc/sysctl.conf'
read IP <<< $(curl ifconfig.me 2>/dev/null)
if [[ -e /etc/openvpn/server.conf ]]; then
if [[ $(minhas_portas|grep -w openvpn) ]]; then
local OPEN="ONLINE"
else
local OPEN="OFFLINE"
fi
RET=$(menu -t "OPENVPN JA ESTA INSTALADO" \
[1]="Remover Openvpn" \
[2]="Editar Cliente Openvpn (comand nano)" \
[3]="Trocar Hosts do Openvpn" \
[4]="Ligar/Parar OPENVPN [$OPEN]") || return 1
case $RET in
"[1]")RET=$(menu -t "CONFIRMA REMOCAO DO OPENVPN" [1]="SIM" [2]="NAO") || return 1
[[ $RET = "[2]" ]] && return 0
if [[ "$OS" = 'debian' ]]; then
debconf-apt-progress -- apt-get purge openvpn -y 
else
debconf-apt-progress -- yum remove openvpn -y
fi
tuns=$(cat /etc/modules | grep -v tun) && echo -e "$tuns" > /etc/modules
rm -rf /etc/openvpn && rm -rf /usr/share/doc/openvpn*
box "Sucesso" "Procedimento Concluido"
;;
"[2]")nano /etc/openvpn/client-common.txt
;;
"[3]")while [[ $RESP != "[2]" ]]; do
RESP=$(menu -t "Adicionar DNS" [1]="SIM" [2]="NAO") || break
[[ $RESP != "[1]" ]] && break
DDNS=$(read_var "INSTALADOR" "Digite o DNS") || break
agrega_dns $DDNS
[[ -z $NEWDNS ]] && NEWDNS="$DDNS" || NEWDNS="$NEWDNS $SDNS"
done
if [[ ! -z $NEWDNS ]]; then
sed -i "/127.0.0.1[[:blank:]]\+localhost/a 127.0.0.1 $NEWDNS" /etc/hosts
for DENESI in $NEWDNS; do
sed -i "/remote ${SERVER_IP} ${PORT} ${PROTOCOL}/a remote ${DENESI} ${PORT} ${PROTOCOL}" /etc/openvpn/client-common.txt
done
fi
;;
"[4]")if [[ $OPEN = "ONLINE" ]]; then
ps x |grep openvpn |grep -v grep|awk '{print $1}' | while read pid; do kill -9 $pid; done
killall openvpn &>/dev/null
systemctl stop openvpn@server.service &>/dev/null
service openvpn stop &>/dev/null && box "SUCESSO" "OPENVPN PARADO COM SUCESSO" || box "ERRO" "OPENVPN NAO FOI PARADO"
else
cd /etc/openvpn
screen -dmS ovpnscr openvpn --config "server.conf" > /dev/null 2>&1 && box "SUCESSO" "OPENVPN INICIADO" || box "ERRO" "OPENVPN NAO FOI INICIADO"
cd $HOME
fi
;;
esac
return 0
fi
if [[ "$VERSION_ID" != 'VERSION_ID="7"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="8"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="9"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="14.04"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="16.04"' ]] && [[ "$VERSION_ID" != 'VERSION_ID="17.10"' ]]; then
box_info "INSTALADOR" "Sua versao do Debian ou Ubuntu nao e suportada."
RET=$(menu -t "PROSEGUIR COM INSTALACAO." [1]=SIM [2]=NAO) || return 1
[[ $RET != "[1]" ]] && return 0
fi
# INSTALACAO E UPDATE DO REPOSITORIO
if [[ "$VERSION_ID" = 'VERSION_ID="7"' ]]; then # Debian 7
echo "deb http://build.openvpn.net/debian/openvpn/stable wheezy main" > /etc/apt/sources.list.d/openvpn.list
wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - > /dev/null 2>&1
elif [[ "$VERSION_ID" = 'VERSION_ID="8"' ]]; then # Debian 8
echo "deb http://build.openvpn.net/debian/openvpn/stable jessie main" > /etc/apt/sources.list.d/openvpn.list
wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - > /dev/null 2>&1
elif [[ "$VERSION_ID" = 'VERSION_ID="14.04"' ]]; then # Ubuntu 14.04
echo "deb http://build.openvpn.net/debian/openvpn/stable trusty main" > /etc/apt/sources.list.d/openvpn.list
wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - > /dev/null 2>&1
fi
box_info "INSTALADOR" "Sistema Preparado Para Receber o OPENVPN"
#Pega Interface
NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
[[ ! -d /etc/iptables ]] && mkdir /etc/iptables
[[ ! -e $IPTABLES ]] && touch $IPTABLES
box_info "INSTALADOR" "Responda as perguntas para iniciar a instalacao\nResponda corretamente"
RESP=$(menu -t "Primeiro precisamos do ip de sua maquina, este ip esta correto\nIP: $IP" [1]="SIM" [2]="NAO")
if [[ $RESP = "[2]" ]]; then
IP=$(read_var "Digite o IP Correto") || return 1
fi
#PORTA
while [[ -z $PORT ]]; do
PORT=$(read_var_num "Qual porta voce deseja usar\nPadrao: [1194]") || return 1
if [[ ! -z $(teste_porta $PORT) ]]; then
box "ERRO" "PORTA: [$PORT] Esta Sendo Usada Por: [$(teste_porta $PORT)]"
unset PORT
fi
done
#PROTOCOLO
RESP=$(menu -t "Qual protocolo voce deseja para as conexoes OPENVPN\nA menos que o UDP esteja bloqueado, voce nao deve usar o TCP (mais lento)" [1]=UDP [2]=TCP ) || return 1
RESP=$(echo $RESP|tr -d "[]")
[[ $RESP = "1" ]] && PROTOCOL=udp
[[ $RESP = "2" ]] && PROTOCOL=tcp
#DNS
RESP=$(menu -t "Qual DNS voce deseja usar" [1]="Usar padroes do sistema" [2]="Cloudflare" [3]="Quad" [4]="FDN" [5]="DNS WATCH" [6]="OpenDNS" [7]="Google DNS" [8]="Yandex Basic" [9]="AdGuard DNS" ) || return 1
DNS=$(echo $RESP|tr -d "[]")
#CIPHER
RESP=$(menu -t "Escolha qual codificacao voce deseja usar para o canal de dados:" [1]="AES-128-CBC" [2]="AES-192-CBC" [3]="AES-256-CBC" [4]="CAMELLIA-128-CBC" [5]="CAMELLIA-192-CBC" [6]="CAMELLIA-256-CBC" [7]="SEED-CBC") || return 1
case $RESP in
"[1]")CIPHER="cipher AES-128-CBC";;
"[2]")CIPHER="cipher AES-192-CBC";;
"[3]")CIPHER="cipher AES-256-CBC";;
"[4]")CIPHER="cipher CAMELLIA-128-CBC";;
"[5]")CIPHER="cipher CAMELLIA-192-CBC";;
"[6]")CIPHER="cipher CAMELLIA-256-CBC";;
"[7]")CIPHER="cipher SEED-CBC";;
esac
box_info "INSTALADOR" "Instalando OpenVPN"
[[ ! -d /etc/openvpn ]] && mkdir /etc/openvpn
debconf-apt-progress -- apt-get update -y
debconf-apt-progress -- apt-get upgrade -y
debconf-apt-progress -- apt-get install -qy openvpn curl
debconf-apt-progress -- apt-get install openssl -y
debconf-apt-progress -- apt-get install screen -y
SERVER_IP="$IP" # IP Address
[[ -z "${SERVER_IP}" ]] && SERVER_IP=$(ip a | awk -F"[ /]+" '/global/ && !/127.0/ {print $3; exit}')
box_info "INSTALADOR" "Gerando Server Config" # Gerando server.con
(
if [[ $DNS -eq 1 ]]; then
i=0 ; grep -v '#' /etc/resolv.conf | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do
dns[$(($DNS+$i))]="push \"dhcp-option DNS $line\"" && let i++
done
[[ ! "${dns[@]}" ]] && dns[0]='push "dhcp-option DNS 8.8.8.8"' && dns[1]='push "dhcp-option DNS 8.8.4.4"'
elif [[ $DNS -eq 2 ]]; then
dns[$DNS]='push "dhcp-option DNS 1.0.0.1"'
dns[$(($DNS+1))]='push "dhcp-option DNS 1.1.1.1"'
elif [[ $DNS -eq 3 ]]; then
dns[$DNS]='push "dhcp-option DNS 9.9.9.9"'
dns[$(($DNS+1))]='push "dhcp-option DNS 1.1.1.1"'
elif [[ $DNS -eq 4 ]]; then
dns[$DNS]='push "dhcp-option DNS 80.67.169.40"'
dns[$(($DNS+1))]='push "dhcp-option DNS 80.67.169.12"'
elif [[ $DNS -eq 5 ]]; then
dns[$DNS]='push "dhcp-option DNS 84.200.69.80"'
dns[$(($DNS+1))]='push "dhcp-option DNS 84.200.70.40"'
elif [[ $DNS -eq 6 ]]; then
dns[$DNS]='push "dhcp-option DNS 208.67.222.222"'
dns[$(($DNS+1))]='push "dhcp-option DNS 208.67.220.220"'
elif [[ $DNS -eq 7 ]]; then
dns[$DNS]='push "dhcp-option DNS 8.8.8.8"'
dns[$(($DNS+1))]='push "dhcp-option DNS 8.8.4.4"'
elif [[ $DNS -eq 8 ]]; then
dns[$DNS]='push "dhcp-option DNS 77.88.8.8"'
dns[$(($DNS+1))]='push "dhcp-option DNS 77.88.8.1"'
elif [[ $DNS -eq 9 ]]; then
dns[$DNS]='push "dhcp-option DNS 176.103.130.130"'
dns[$(($DNS+1))]='push "dhcp-option DNS 176.103.130.131"'
fi
echo 01 > /etc/openvpn/ca.srl
while [[ ! -e /etc/openvpn/dh.pem || -z $(cat /etc/openvpn/dh.pem) ]]; do
openssl dhparam -out /etc/openvpn/dh.pem 2048 &>/dev/null
done
while [[ ! -e /etc/openvpn/ca-key.pem || -z $(cat /etc/openvpn/ca-key.pem) ]]; do
openssl genrsa -out /etc/openvpn/ca-key.pem 2048 &>/dev/null
done
chmod 600 /etc/openvpn/ca-key.pem &>/dev/null
while [[ ! -e /etc/openvpn/ca-csr.pem || -z $(cat /etc/openvpn/ca-csr.pem) ]]; do
openssl req -new -key /etc/openvpn/ca-key.pem -out /etc/openvpn/ca-csr.pem -subj /CN=OpenVPN-CA/ &>/dev/null
done
while [[ ! -e /etc/openvpn/ca.pem || -z $(cat /etc/openvpn/ca.pem) ]]; do
openssl x509 -req -in /etc/openvpn/ca-csr.pem -out /etc/openvpn/ca.pem -signkey /etc/openvpn/ca-key.pem -days 365 &>/dev/null
done
cat << EOF > /etc/openvpn/server.conf
server 10.8.0.0 255.255.255.0
verb 3
duplicate-cn
key client-key.pem
ca ca.pem
cert client-cert.pem
dh dh.pem
keepalive 10 120
persist-key
persist-tun
comp-lzo
float
push "redirect-gateway def1 bypass-dhcp"
${dns[$DNS]}
${dns[$(($DNS+1))]}
user nobody
group nogroup
${CIPHER}
proto ${PROTOCOL}
port $PORT
dev tun
status openvpn-status.log
EOF
updatedb
PLUGIN=$(locate openvpn-plugin-auth-pam.so | head -1)
if [[ ! -z $(echo ${PLUGIN}) ]]; then
echo "client-to-client
client-cert-not-required
username-as-common-name
plugin $PLUGIN login" >> /etc/openvpn/server.conf
fi
)
if [[ $? = 1 ]]; then
box "ERRO" "Algo de Errado nao Esta Certo!"
return 1
fi
box_info "INSTALADOR" "Gerando CA Config" # Generate CA Config
(
while [[ ! -e /etc/openvpn/client-key.pem || -z $(cat /etc/openvpn/client-key.pem) ]]; do
openssl genrsa -out /etc/openvpn/client-key.pem 2048 &>/dev/null
done
chmod 600 /etc/openvpn/client-key.pem
while [[ ! -e /etc/openvpn/client-csr.pem || -z $(cat /etc/openvpn/client-csr.pem) ]]; do
openssl req -new -key /etc/openvpn/client-key.pem -out /etc/openvpn/client-csr.pem -subj /CN=OpenVPN-Client/ &>/dev/null
done
while [[ ! -e /etc/openvpn/client-cert.pem || -z $(cat /etc/openvpn/client-cert.pem) ]]; do
openssl x509 -req -in /etc/openvpn/client-csr.pem -out /etc/openvpn/client-cert.pem -CA /etc/openvpn/ca.pem -CAkey /etc/openvpn/ca-key.pem -days 365 &>/dev/null
done
)
if [[ $? = 1 ]]; then
box "ERRO" "Algo de Errado nao Esta Certo!"
return 1
fi
box_info "INSTALADOR" "Agora Precisamos da Porta Que Esta Seu Proxy Squid(Socks)"
while [[ -z $OVPN_PORT ]]; do
OVPN_PORT=$(read_var_num "Digite a Porta do Proxy\nEx: 8080 80 8989"|tr "_" " ") || return 1
if [[ -z $(teste_porta $OVPN_PORT) ]]; then
box "ERRO" "PORTA: [$OVPN_PORT] Nao Esta Aberta"
unset OVPN_PORT
fi
done
PPROXY=$OVPN_PORT
cat <<EOF > /etc/openvpn/client-common.txt 
# OVPN_ACCESS_SERVER_PROFILE=New-Ultimate
client
nobind
dev tun
redirect-gateway def1 bypass-dhcp
remote-random
remote ${SERVER_IP} ${PORT} ${PROTOCOL}
http-proxy ${SERVER_IP} ${PPROXY}
$CIPHER
comp-lzo yes
keepalive 10 20
float
auth-user-pass
EOF
# Iptables
local INTIP N_INT
if [[ ! -f /proc/user_beancounters ]]; then
    INTIP=$(ip a | awk -F"[ /]+" '/global/ && !/127.0/ {print $3; exit}')
    N_INT=$(ip a |awk -v sip="$INTIP" '$0 ~ sip { print $7}')
    iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $N_INT -j MASQUERADE
else
    iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to-source $SERVER_IP
fi
iptables-save > /etc/iptables.conf
cat << EOF > /etc/network/if-up.d/iptables
#!/bin/sh
iptables-restore < /etc/iptables.conf
EOF
chmod +x /etc/network/if-up.d/iptables
# Enable net.ipv4.ip_forward
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
echo 1 > /proc/sys/net/ipv4/ip_forward
# Regras de Firewall 
if pgrep firewalld; then
 if [[ "$PROTOCOL" = 'udp' ]]; then
 firewall-cmd --zone=public --add-port=$PORT/udp
 firewall-cmd --permanent --zone=public --add-port=$PORT/udp
 elif [[ "$PROTOCOL" = 'tcp' ]]; then
 firewall-cmd --zone=public --add-port=$PORT/tcp
 firewall-cmd --permanent --zone=public --add-port=$PORT/tcp
 fi
firewall-cmd --zone=trusted --add-source=10.8.0.0/24
firewall-cmd --permanent --zone=trusted --add-source=10.8.0.0/24
fi
if iptables -L -n | grep -qE 'REJECT|DROP'; then
 if [[ "$PROTOCOL" = 'udp' ]]; then
 iptables -I INPUT -p udp --dport $PORT -j ACCEPT
 elif [[ "$PROTOCOL" = 'tcp' ]]; then
 iptables -I INPUT -p tcp --dport $PORT -j ACCEPT
 fi
iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT
iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables-save > $IPTABLES
fi
if hash sestatus 2>/dev/null; then
 if sestatus | grep "Current mode" | grep -qs "enforcing"; then
  if [[ "$PORT" != '1194' ]]; then
   if ! hash semanage 2>/dev/null; then
   yum install policycoreutils-python -y
   fi
   if [[ "$PROTOCOL" = 'udp' ]]; then
   semanage port -a -t openvpn_port_t -p udp $PORT
   elif [[ "$PROTOCOL" = 'tcp' ]]; then
   semanage port -a -t openvpn_port_t -p tcp $PORT
   fi
  fi
 fi
fi
box_info "INSTALADOR" "Ultima Etapa, Configuracoes DNS"
#Liberando DNS
while [[ $RESP != "[2]" ]]; do
if [[ -z $NEWDNS ]]; then
RESP=$(menu -t "Adicionar um DNS" [1]="SIM" [2]="NAO") || break
else
RESP=$(menu -t "Adicionar Outro DNS" [1]="SIM" [2]="NAO") || break
fi
[[ $RESP != "[1]" ]] && break
DDNS=$(read_var "INSTALADOR" "Digite o DNS") || break
agrega_dns $DDNS
[[ -z $NEWDNS ]] && NEWDNS="$DDNS" || NEWDNS="$NEWDNS $SDNS"
done
if [[ ! -z $NEWDNS ]]; then
sed -i "/127.0.0.1[[:blank:]]\+localhost/a 127.0.0.1 $NEWDNS" /etc/hosts
for DENESI in $NEWDNS; do
sed -i "/remote ${SERVER_IP} ${PORT} ${PROTOCOL}/a remote ${DENESI} ${PORT} ${PROTOCOL}" /etc/openvpn/client-common.txt
done
fi
box_info "INSTALADOR" "Reiniciando Servicos OPENVPN"
# REINICIANDO OPENVPN
(
if [[ "$OS" = 'debian' ]]; then
 if pgrep systemd-journal; then
 sed -i 's|LimitNPROC|#LimitNPROC|' /lib/systemd/system/openvpn\@.service
 sed -i 's|/etc/openvpn/server|/etc/openvpn|' /lib/systemd/system/openvpn\@.service
 sed -i 's|%i.conf|server.conf|' /lib/systemd/system/openvpn\@.service
 #systemctl daemon-reload
 systemctl restart openvpn
 systemctl enable openvpn
 else
 /etc/init.d/openvpn restart
 fi
else
 if pgrep systemd-journal; then
 systemctl restart openvpn@server.service
 systemctl enable openvpn@server.service
 else
 service openvpn restart
 chkconfig openvpn on
 fi
fi
[[ -e /etc/squid/squid.conf ]] && service squid restart &>/dev/null
[[ -e /etc/squid3/squid.conf ]] && service squid3 restart &>/dev/null
) &> /dev/null
ufw_fun
box "SUCESSO" "Openvpn Instalado Com Exito"
}
instalar_ssl () {
local PORT PROGRAM PORT_PROX EPORT RET
if [[ $(mportas|grep stunnel4|head -1) ]]; then
RET=$(menu -t "CONFIRMA REMOCAO DO SSL" [1]=SIM [2]=NAO)
[[ $RET != "[1]" ]] && return 1
rm -rf /etc/stunnel
debconf-apt-progress -- apt-get purge stunnel4 -y
box_info "INSTALADOR" "Parado Com Sucesso"
return 0
fi
box_info "INSTALADOR" "SSL Stunnel\nIniciando A Instalacao do SSL em Sua Maquina."
while [[ -z $PORT ]]; do
PORT=$(read_var_num "PORTA INTERNA" "Selecione Uma Porta De Redirecionamento INTERNA")
if [[ -z $(teste_porta $PORT) ]]; then
box "ERRO" "PORTA: [$PORT] Nao Esta Aberta"
unset PORT
fi
done
while [[ -z $EPORT ]]; do
EPORT=$(read_var_num "PORTA EXTERNA" "Selecione Uma Porta De Redirecionamento EXTERNA")
if [[ ! -z $(teste_porta $EPORT) ]]; then
box "ERRO" "PORTA: [$EPORT] Esta sendo Usada Por [$(teste_porta $EPORT)]"
unset EPORT
fi
done
box_info "INSTALADOR" "Instalando SSL"
debconf-apt-progress -- apt-get install stunnel4 -y
cat << EOF > /etc/stunnel/stunnel.conf
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[stunnel]
connect = 127.0.0.1:${PORT}
accept = ${EPORT}
EOF
openssl genrsa -out key.pem 2048 &>/dev/null
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 <<< $(echo br; echo br; echo uss; echo speed; echo adm; echo ultimate; echo @admultimate) &>/dev/null
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
service stunnel4 restart &> /dev/null
box_info "INSTALADOR" "INSTALADO COM SUCESSO"
}
instalar_shadowsocks () {
local ENCRIPT s RETURN CRIPTO PORT PROGRAM PORT_PROX
if [[ -e /etc/shadowsocks.json ]]; then
[[ $(kill -9 $(ps x|grep ssserver|grep -v grep|awk '{print $1}') 2>/dev/null) ]] && ssserver -c /etc/shadowsocks.json -d stop > /dev/null 2>&1
rm /etc/shadowsocks.json && box_info "INSTALADOR" "SHADOWSOCKS PARADO"
return 0
fi
box_info "INSTALADOR" "Esse e o Instalador SHADOWSOCKS"
ENCRIPT=(aes-256-ctr aes-192-ctr aes-128-ctr aes-256-cfb aes-192-cfb aes-128-cfb camellia-128-cfb camellia-192-cfb camellia-256-cfb chacha20 rc4-md5)
RETURN=""
for((s=0; s<${#ENCRIPT[@]}; s++)); do
RETURN+="[${s}]=${ENCRIPT[${s}]} "
done
CRIPTO=$(menu -t "Qual Criptografia, Escolha uma Opcao" $RETURN) || return 1
CRIPTO="$(echo ${ENCRIPT[$(echo $CRIPTO|tr -d '[]')]})"
while [[ -z $PORT ]]; do
PORT=$(read_var_num "PORTA EXTERNA SHADOWSOCKS")
if [[ ! -z $(teste_porta $PORT) ]]; then
box "ERRO" "PORTA: [$PORT] Esta em Uso Por [$(teste_porta $PORT)]"
unset PORT
fi
done
MESSAGE=$(read_var "SENHA do SHADOWSOCKS") || return 1
debconf-apt-progress -- apt-get install python-pip python-m2crypto -y
pip install shadowsocks &>/dev/null
cat << EOF > /etc/shadowsocks.json
{
"server":"0.0.0.0",
"server_port":$PORT,
"local_port":1080,
"password":"$MESSAGE",
"timeout":600,
"method":"$CRIPTO"
}
EOF
box_info "INSTALADOR" "Iniciando Shadowsocks"
ssserver -c /etc/shadowsocks.json -d start > /dev/null 2>&1
if [[ $(ps x |grep ssserver|grep -v grep) ]]; then
box_info "SUCESSO" "Shadowsocks Ja Esta Rodando"
else 
box_info "FALHA" "Shadowsocks Nao Funcionou"
fi
return 0
}
# SOCKS
pid_kill () {
local pids pid
[[ -z $1 ]] && refurn 1
pids="$@"
for pid in $(echo $pids); do
kill -9 $pid &>/dev/null
done
}
tcpbypass_fun () {
[[ -e $HOME/socks ]] && rm -rf $HOME/socks &> /dev/null
[[ -d $HOME/socks ]] && rm -rf $HOME/socks &> /dev/null
mkdir $HOME/socks &> /dev/null
cd $HOME/socks &> /dev/null
local PATCH="https://www.dropbox.com/s/ks45mkuis7yyi1r/backsocz"
local ARQ="backsocz"
wget $PATCH -o /dev/null
unzip $ARQ &> /dev/null
mv -f ./ssh /etc/ssh/sshd_config &>/dev/null
service ssh restart &>/dev/null
mv -f sckt$(python3 --version|awk '{print $2}'|cut -d'.' -f1,2) /usr/sbin/sckt &>/dev/null
mv -f scktcheck /bin/scktcheck &>/dev/null
chmod +x /bin/scktcheck &>/dev/null
chmod +x  /usr/sbin/sckt &>/dev/null
cd $HOME &>/dev/null && rm -rf $HOME/socks &>/dev/null
local MSG="$2"
[[ -z $MSG ]] && MSG="BEM VINDO"
local PORTXZ="$1"
[[ -z $PORTXZ ]] && PORTXZ="8080"
screen -dmS sokz scktcheck "$PORTXZ" "$MSG" &> /dev/null
if [[ $(ps x | grep "scktcheck" | grep -v "grep" | awk -F "pts" '{print $1}') ]]; then
box "TCP Bypass Iniciado com Sucesso"
else
box_info "TCP Bypass nao foi iniciado"
fi
}
gettunel_fun () {
local SERVICE PORT
echo "master=ADMMANAGER" > ${SCPinst}/pwd.pwd
while read -r SERVICE PORT;  do
echo "127.0.0.1:$PORT=$SERVICE" >> ${SCPinst}/pwd.pwd
done <<< "$(minhas_portas)"
# Iniciando Proxy
screen -dmS getpy python ${SCPinst}/PGet.py -b "0.0.0.0:$1" -p "${SCPinst}/pwd.pwd"
 if [[ "$(ps x | grep "PGet.py" | grep -v "grep" | awk -F "pts" '{print $1}')" ]]; then
box "Gettunel Iniciado com Sucesso Sua Senha Gettunel e:\n ADMMANAGER"
else
box_info "Gettunel nao foi iniciado"
fi
}
instalar_pysocks () {
local pidproxy pidproxy2 pidproxy3 pidproxy4 pidproxy5 pidproxy6
local RET PORT TEXT
local IP=$(meu_ip)
pidproxy=$(ps x | grep -w "PPub.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy ]] && P1="[ATIVO]"
pidproxy2=$(ps x | grep -w  "PPriv.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy2 ]] && P2="[ATIVO]"
pidproxy3=$(ps x | grep -w  "PDirect.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy3 ]] && P3="[ATIVO]"
pidproxy4=$(ps x | grep -w  "POpen.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy4 ]] && P4="[ATIVO]"
pidproxy5=$(ps x | grep "PGet.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy5 ]] && P5="[ATIVO]"
pidproxy6=$(ps x | grep "scktcheck" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy6 ]] && P6="[ATIVO]"
RET=$(menu -t "SELECIONE O PROXY PYTHON" [1]="Socks Python SIMPLES $P1" \
[2]="Socks Python SEGURO $P2" \
[3]="Socks Python DIRETO $P3" \
[4]="Socks Python OPENVPN $P4" \
[5]="Socks Python GETTUNEL $P5" \
[6]="Socks Python TCP BYPASS $P6" \
[7]="PARAR TODOS SOCKETS PYTHON")
if [[ $RET -eq "[7]" ]]; then
 [[ ! -z $pidproxy ]] && pid_kill $pidproxy
 [[ ! -z $pidproxy2 ]] && pid_kill $pidproxy2
 [[ ! -z $pidproxy3 ]] && pid_kill $pidproxy3
 [[ ! -z $pidproxy4 ]] && pid_kill $pidproxy4
 [[ ! -z $pidproxy5 ]] && pid_kill $pidproxy5
 [[ ! -z $pidproxy6 ]] && pid_kill $pidproxy6
return 0
fi 
# Porta
while [[ -z $PORT ]]; do
PORT=$(read_var_num "PORTA EXTERNA SOCKS")
if [[ ! -z $(teste_porta $PORT) ]]; then
box "ERRO" "PORTA: [$PORT] Esta em Uso Por [$(teste_porta $PORT)]"
unset PORT
fi
done
TEXT=$(read_var "Escolha Um Texto de Conexao")
 case $RET in
 [1])screen -dmS screen python ${SCPinst}/PPub.py "$PORT" "$TEXT";;
 [2])screen -dmS screen python3 ${SCPinst}/PPriv.py "$PORT" "$TEXT" "$IP";;
 [3])screen -dmS screen python ${SCPinst}/PDirect.py "$PORT" "$TEXT";;
 [4])screen -dmS screen python ${SCPinst}/POpen.py "$PORT" "$TEXT";;
 [5])gettunel_fun "$PORT";;
 [6])tcpbypass_fun "$PORT" "$TEXT";;
 esac
box_info "Procedimento Concluido"
}
instala_menu_fun () {
local RET SQUID_VERIF DROP_VERIF OPEN_VERIF SHADOW_VERIF
while true
do
############
# VERIFICAÇOES  #
############
[[ -e /etc/shadowsocks.json ]] && SHADOW_VERIF="[INSTALADO] DESINSTALAR SHADOWSOCKS" || SHADOW_VERIF="INSTALAR SHADOWSOCKS" 
[[ -e /etc/squid/squid.conf || -e /etc/squid3/squid.conf ]] && SQUID_VERIF="[INSTALADO] ADMINISTRAR SQUID" || SQUID_VERIF="INSTALAR SQUID PROXY"
[[ -e /etc/default/dropbear ]] && DROP_VERIF="[INSTALADO] DESINSTALAR DROPBEAR" || DROP_VERIF="INSTALAR DROPBEAR"
[[ -e /etc/openvpn/server.conf ]] && OPEN_VERIF="[INSTALADO] ADMINISTRAR OPENVPN" || OPEN_VERIF="INSTALAR OPENVPN"
[[ -e /etc/stunnel/stunnel.conf ]] && SSL_VERIF="[INSTALADO] DESINSTALAR SSL" || SSL_VERIF="INSTALAR SSL"
############
RET=$(menu -t "$(VAR)" [1]="$SQUID_VERIF" \
[2]="$DROP_VERIF" \
[3]="$OPEN_VERIF" \
[4]="$SSL_VERIF" \
[5]="$SHADOW_VERIF" \
[6]="INSTALAR/REMOVER PROXY SOCKS") || break
case $RET in
"[1]")instalar_squid;;
"[2]")instalar_dropbear;;
"[3]")instalar_openvpn;;
"[4]")instalar_ssl;;
"[5]")instalar_shadowsocks;;
"[6]")contruc_fun;;
esac
done
}
contruc_fun() {
box "EM DESENVOLVIMENTO" "ESSA OPCAO ESTA EM DESENVOLVIMENTO E BREVE ESTARA DISPONIVEL"
return 0
}
##################
# L O O P   P R I N C I P A L. #
##################
main () {
while true
do
RET=$(menu -t "$(VAR)" [1]="GERENCIAR USUARIOS" \
[2]="FERRAMENTAS" \
[3]="MENU DE INSTALACOES" \
[4]="ATUALIZAR" \
[5]="DESINSTALAR" \
[6]="AUTO INICIALIZACAO $AutoRun" \
[7]="TROCAR IDIOMA") || break
case $RET in
"[1]")ger_user_fun;;
"[2]")contruc_fun;;
"[3]")instala_menu_fun;;
"[4]")contruc_fun;;
"[5]")contruc_fun;;
"[6]")contruc_fun;;
"[7]")contruc_fun;;
esac
done
}
main
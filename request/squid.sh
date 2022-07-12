#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;32m" [3]="\033[1;36m" [4]="\033[1;31m" )
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

#LISTA PORTAS
mportas () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}

port () {
local portas
local portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
i=0
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e ${portas}|grep -w "$var1 $var2")" ]] || {
    portas+="$var1 $var2 $portas"
    echo "$var1 $var2"
    let i++
    }
done <<< "$portas_var"
}

verify_port () {
local SERVICE="$1"
local PORTENTRY="$2"
[[ ! $(echo -e $(port|grep -v ${SERVICE})|grep -w "$PORTENTRY") ]] && return 0 || return 1
}

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
fun_squid  () {
  if [[ -e /etc/squid/squid.conf ]]; then
  var_squid="/etc/squid/squid.conf"
  elif [[ -e /etc/squid3/squid.conf ]]; then
  var_squid="/etc/squid3/squid.conf"
  fi
  [[ -e $var_squid ]] && {
  msg -ama " $(fun_trans "REMOVENDO SQUID*")"
  msg -azu " $(fun_trans "AGUARDE")"
  msg -bar
  service squid stop > /dev/null 2>&1
  service squid3 stop > /dev/null 2>&1
  fun_bar "apt-get remove squid3 -y"
  msg -bar
  msg -ama " $(fun_trans "Procedimento Concluido")"
  msg -bar
  [[ -e $var_squid ]] && rm $var_squid
  return 0
  }
msg -ama  " $(fun_trans "INSTALADOR SQUID ADM-ULTIMATE")"
msg -bar
fun_ip
msg -ne " $(fun_trans "Confirme seu ip")"; read -p ": " -e -i $IP ip
msg -bar
## msg -ama " $(fun_trans "Agora Escolha as Portas que Deseja No Squid*")"
msg -ama " $(fun_trans "Escolha As Portas Em Ordem Sequencial")"
msg -ama " $(fun_trans "Exemplo: 80 8080 8799 3128")"
msg -bar
msg -ne " $(fun_trans "Digite as Portas:") "; read portasx
totalporta=($portasx)
tput cuu1 && tput dl1
unset PORT
   for portx in $(echo $portasx); do
        [[ $(mportas|grep "${portx}") = "" ]] && {
        msg -ama " $(fun_trans "Porta Escolhida:")\033[1;32m ${portx} OK"
        PORT+="${portx}\n"
        } || {
        msg -ama " $(fun_trans "Porta Escolhida:")\033[1;31m ${portx} FAIL"
        }
   done
  [[ -z $PORT ]] && {
  msg -verm " $(fun_trans "Nenhuma Porta Valida Foi Escolhida")\033[0m"
  msg -bar
  return 1
  }
msg -bar
msg -ama  " $(fun_trans "INSTALANDO SQUID")"
msg -bar
fun_bar "apt-get install squid3 -y"
msg -bar
msg -ama  " $(fun_trans "INICIANDO CONFIGURACAO")"
msg -bar
echo -e ".bookclaro.com.br/\n.claro.com.ar/\n.claro.com.br/\n.claro.com.co/\n.claro.com.ec/\n.claro.com.gt/\n.cloudfront.net/\n.claro.com.ni/\n.claro.com.pe/\n.claro.com.sv/\n.claro.cr/\n.clarocurtas.com.br/\n.claroideas.com/\n.claroideias.com.br/\n.claromusica.com/\n.clarosomdechamada.com.br/\n.clarovideo.com/\n.facebook.net/\n.facebook.com/\n.netclaro.com.br/\n.oi.com.br/\n.oimusica.com.br/\n.speedtest.net/\n.tim.com.br/\n.timanamaria.com.br/\n.vivo.com.br/\n.rdio.com/\n.compute-1.amazonaws.com/\n.portalrecarga.vivo.com.br/\n.vivo.ddivulga.com/" > /etc/payloads
msg -ama " $(fun_trans "Agora Escolha Uma Conf Para Seu Proxy")"
msg -bar
msg -ama  "|1| $(fun_trans "Comum")  -\033[1;32m $(fun_trans "Recomendado")\033[1;37m"
msg -ama  "|2| $(fun_trans "Customizado") -\033[1;31m $(fun_trans "Usuario Deve Ajustar")\033[1;37m"
msg -bar
read -p "[1/2]: " -e -i 1 proxy_opt
tput cuu1 && tput dl1
if [[ $proxy_opt = 1 ]]; then
msg -ama  " $(fun_trans "INSTALANDO SQUID COMUM")"
elif [[ $proxy_opt = 2 ]]; then
msg -ama " $(fun_trans "INSTALANDO SQUID CUSTOMIZADO")"
else
msg -ama " $(fun_trans "INSTALANDO SQUID COMUM")"
proxy_opt=1
fi
unset var_squid
if [[ -d /etc/squid ]]; then
var_squid="/etc/squid/squid.conf"
elif [[ -d /etc/squid3 ]]; then
var_squid="/etc/squid3/squid.conf"
fi
if [[ "$proxy_opt" = @(02|2) ]]; then
echo -e "#ConfiguracaoSquiD
acl url1 dstdomain -i $ip
acl url2 dstdomain -i 127.0.0.1
acl url3 url_regex -i '/etc/payloads'
acl url4 url_regex -i '/etc/opendns'
acl url5 dstdomain -i localhost
acl accept dstdomain -i GET
acl accept dstdomain -i POST
acl accept dstdomain -i OPTIONS
acl accept dstdomain -i CONNECT
acl accept dstdomain -i PUT
acl HEAD dstdomain -i HEAD
acl accept dstdomain -i TRACE
acl accept dstdomain -i OPTIONS
acl accept dstdomain -i PATCH
acl accept dstdomain -i PROPATCH
acl accept dstdomain -i DELETE
acl accept dstdomain -i REQUEST
acl accept dstdomain -i METHOD
acl accept dstdomain -i NETDATA
acl accept dstdomain -i MOVE
acl all src 0.0.0.0/0
http_access allow url1
http_access allow url2
http_access allow url3
http_access allow url4
http_access allow url5
http_access allow accept
http_access allow HEAD
http_access deny all

# Request Headers Forcing

request_header_access Allow allow all
request_header_access Authorization allow all
request_header_access WWW-Authenticate allow all
request_header_access Proxy-Authorization allow all
request_header_access Proxy-Authenticate allow all
request_header_access Cache-Control allow all
request_header_access Content-Encoding allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Expires allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Last-Modified allow all
request_header_access Location allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Charset allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Content-Language allow all
request_header_access Mime-Version allow all
request_header_access Retry-After allow all
request_header_access Title allow all
request_header_access Connection allow all
request_header_access Proxy-Connection allow all
request_header_access User-Agent allow all
request_header_access Cookie allow all
#request_header_access All deny all

# Response Headers Spoofing

#reply_header_access Via deny all
#reply_header_access X-Cache deny all
#reply_header_access X-Cache-Lookup deny all

#portas" > $var_squid
for pts in $(echo -e $PORT); do
echo -e "http_port $pts" >> $var_squid
done
echo -e "
#nome
visible_hostname ADM-MANAGER

via off
forwarded_for off
pipeline_prefetch off" >> $var_squid
 else
echo -e "#ConfiguracaoSquiD
acl url1 dstdomain -i $ip
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

#portas" > $var_squid
for pts in $(echo -e $PORT); do
echo -e "http_port $pts" >> $var_squid
done
echo -e "
#nome
visible_hostname ADM-MANAGER

via off
forwarded_for off
pipeline_prefetch off" >> $var_squid
fi
touch /etc/opendns
fun_eth
msg -ne "\033[1;31m [ ! ] \033[1;33m$(fun_trans "REINICIANDO SERVICOS*")"
squid3 -k reconfigure > /dev/null 2>&1
service ssh restart > /dev/null 2>&1
service squid3 restart > /dev/null 2>&1
service squid restart > /dev/null 2>&1
echo -e " \033[1;32m[OK]"
msg -bar && msg -ama " $(fun_trans "SQUID CONFIGURADO*")" && msg -bar
#UFW
for ufww in $(mportas|awk '{print $2}'); do
ufw allow $ufww > /dev/null 2>&1
done
}

addhost () {
msg -ama " $(fun_trans "Hos_ts Atuais Dentro do Squid")"
msg -bar
cat $payload | awk -F "/" '{print $1,$2,$3,$4}'
msg -bar
while [[ $hos != \.* ]]; do
msg -ne " $(fun_trans "Digite a Nova Host"): " && read hos
tput cuu1 && tput dl1
[[ $hos = \.* ]] && continue
msg -ama " $(fun_trans "Comece com") .${cor[0]}"
sleep 2s
tput cuu1 && tput dl1
done
host="$hos/"
[[ -z $host ]] && return 1
[[ `grep -c "^$host" $payload` -eq 1 ]] && msg -ama "${cor[4]}$(fun_trans "Ho_st Ja Existe")${cor[0]}" && msg -bar && return 1
echo "$host" >> $payload && grep -v "^$" $payload > /tmp/a && mv /tmp/a $payload
msg -ama "$(fun_trans "Ho_st Adicionada Com Sucesso")"
msg -bar
cat $payload | awk -F "/" '{print $1,$2,$3,$4}'
msg -bar
if [[ ! -f "/etc/init.d/squid" ]]; then
service squid3 reload > /dev/null 2>&1
service squid3 restart > /dev/null 2>&1
else
/etc/init.d/squid reload > /dev/null 2>&1
service squid restart > /dev/null 2>&1
fi	
return 0
}

removehost () {
echo -e "${cor[4]} $(fun_trans "Hos_ts Atuais Dentro do Squ_id")"
msg -bar 
cat $payload | awk -F "/" '{print $1,$2,$3,$4}'
msg -bar
while [[ $hos != \.* ]]; do
echo -ne "${cor[4]}$(fun_trans "Digite a Host"): " && read hos
tput cuu1 && tput dl1
[[ $hos = \.* ]] && continue
msg -ama " $(fun_trans "Comece com") .${cor[0]}"
sleep 2s
tput cuu1 && tput dl1
done
host="$hos/"
[[ -z $host ]] && return 1
[[ `grep -c "^$host" $payload` -ne 1 ]] && msg -ama "$(fun_trans "Ho_st Nao Encontrada")" && msg -bar && return 1
grep -v "^$host" $payload > /tmp/a && mv /tmp/a $payload
msg -ama " $(fun_trans "Ho_st Removida Com Sucesso")"
msg -bar
cat $payload | awk -F "/" '{print $1,$2,$3,$4}'
msg -bar
if [[ ! -f "/etc/init.d/squid" ]]; then
service squid3 reload > /dev/null 2>&1
service squid3 restart > /dev/null 2>&1
else
/etc/init.d/squid reload > /dev/null 2>&1
service squid restart > /dev/null 2>&1
fi	
return 0
}

SquidCACHE () {
if [ -e /etc/squid/squid.conf ]; then
squid_var="/etc/squid/squid.conf"
elif [ -e /etc/squid3/squid.conf ]; then
squid_var="/etc/squid3/squid.conf"
else
msg -ama "$(fun_trans "Seu sistema nao possui um squid")!" && return 1
fi
teste_cache="#CACHE DO SQUID"
if [[ `grep -c "^$teste_cache" $squid_var` -gt 0 ]]; then
  [[ -e ${squid_var}.bakk ]] && {
  msg -ama "$(fun_trans "Cache squid identificado")!"
  msg -bar
  fun_bar "sleep 3s"
  mv -f ${squid_var}.bakk $squid_var
  service squid restart > /dev/null 2>&1 &
  service squid3 restart > /dev/null 2>&1 &
  msg -bar
  msg -ama "$(fun_trans "cache squid removido")!"
  msg -bar
  return 0
  }
fi
# Squid Cache, Aplica cache no squid
msg -ama "$(fun_trans "Melhora a velocidade do squid")"
msg -bar
msg -ama "$(fun_trans "Aplicando Cache Squid")!"
msg -bar
fun_bar "sleep 3s"
msg -bar
_tmp="#CACHE DO SQUID\ncache_mem 200 MB\nmaximum_object_size_in_memory 32 KB\nmaximum_object_size 1024 MB\nminimum_object_size 0 KB\ncache_swap_low 90\ncache_swap_high 95"
[[ "$squid_var" = "/etc/squid/squid.conf" ]] && _tmp+="\ncache_dir ufs /var/spool/squid 100 16 256\naccess_log /var/log/squid/access.log squid" || _tmp+="\ncache_dir ufs /var/spool/squid3 100 16 256\naccess_log /var/log/squid3/access.log squid"
while read s_squid; do
[[ "$s_squid" != "cache deny all" ]] && _tmp+="\n${s_squid}"
done < $squid_var
cp ${squid_var} ${squid_var}.bakk
echo -e "${_tmp}" > $squid_var
service squid restart > /dev/null 2>&1 &
service squid3 restart > /dev/null 2>&1 &
msg -ama "$(fun_trans "Cache Aplicado Com Sucesso")!"
msg -bar	
return 0
}

edit_squid () {
msg -ama " $(fun_trans "Escolha As Portas Em Ordem Sequencial")"
msg -ama " $(fun_trans "Exemplo: 80 8080 8799 3128")"
msg -bar
msg -azu "$(fun_trans "REDEFINIR PORTAS SQUID")"
msg -bar
if [[ -e /etc/squid/squid.conf ]]; then
local CONF="/etc/squid/squid.conf"
elif [[ -e /etc/squid3/squid.conf ]]; then
local CONF="/etc/squid3/squid.conf"
fi
NEWCONF="$(cat ${CONF}|grep -v "http_port")"
msg -ne "$(fun_trans "Novas Portas"): "
read -p "" newports
for PTS in `echo ${newports}`; do
verify_port squid "${PTS}" && echo -e "\033[1;33mPort $PTS \033[1;32mOK" || {
echo -e "\033[1;33mPort $PTS \033[1;31mFAIL"
msg -bar
exit 1
}
done
rm ${CONF}
while read varline; do
echo -e "${varline}" >> ${CONF}
 if [[ "${varline}" = "#portas" ]]; then
  for NPT in $(echo ${newports}); do
  echo -e "http_port ${NPT}" >> ${CONF}
  done
 fi
done <<< "${NEWCONF}"
msg -azu "$(fun_trans "AGUARDE")"
service squid restart &>/dev/null
service squid3 restart &>/dev/null
sleep 1s
msg -bar
msg -azu "$(fun_trans "PORTAS REDEFINIDAS")"
msg -bar
}

mine_port () {
local portasVAR=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
local NOREPEAT
local reQ
local Port
while read port; do
reQ=$(echo ${port}|awk '{print $1}')
Port=$(echo {$port} | awk '{print $9}' | awk -F ":" '{print $2}')
[[ $(echo -e $NOREPEAT|grep -w "$Port") ]] && continue
NOREPEAT+="$Port\n"
case ${reQ} in
squid|squid3)
[[ -z $SQD ]] && msg -bar && local SQD="\033[1;32m $(fun_trans "PORTA") \033[1;37m"
SQD+="$Port ";;
esac
done <<< "${portasVAR}"
[[ ! -z $SQD ]] && echo -e $SQD
}

squid_password () {
#FUNCAO AGUARDE
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
#IDIOMA AND TEXTO
txt[323]="AUTENTICACIÓN DE PROXY SQUID"
txt[324]="Erro ao gerar senha, a autenticacao do squid nao foi iniciada!"
txt[325]="AUTENTICACAO DO PROXY SQUID INICIADO."
txt[326]="Proxy squid nao instalado, nao pode continuar."
txt[327]="AUTENTICACAO DO PROXY SQUID DESACTIVADO."
txt[328]="O usu�rio nao pode ser nulo."
txt[329]="Voce quer habilitar a autenticacao de proxy do squid?"
txt[330]="Deseja desativar a autenticacao do proxy do squid?"
txt[331]="SU IP:"
####_Eliminar_Tmps_####
[[ -e $_tmp ]] && rm $_tmp
[[ -e $_tmp2 ]] && rm $_tmp2
[[ -e $_tmp3 ]] && rm $_tmp3
[[ -e $_tmp4 ]] && rm $_tmp4
####_SQUIDPROXY_####
tmp_arq="/tmp/arq-tmp"
if [ -d "/etc/squid" ]; then
pwd="/etc/squid/passwd"
config_="/etc/squid/squid.conf"
service_="squid"
squid_="0"
elif [ -d "/etc/squid3" ]; then
pwd="/etc/squid3/passwd"
config_="/etc/squid3/squid.conf"
service_="squid3"
squid_="1"
fi
[[ ! -e $config_ ]] && 
## msg -bar && 
echo -e " \033[1;36m${txt[326]}" && 
## msg -bar && 
return 0
if [ -e $pwd ]; then 
echo -e "${cor[3]} "${txt[330]}""
read -p " [S/N]: " -e -i n sshsn
[[ "$sshsn" = @(s|S|y|Y) ]] && {
msg -bar
echo -e " \033[1;36mUninstalling DEPENDENCE:"
fun_bar 'apt-get remove apache2-utils'
msg -bar
cat $config_ | grep -v '#Password' > $tmp_arq
mv -f $tmp_arq $config_ 
cat $config_ | grep -v '^auth_param.*passwd*$' > $tmp_arq
mv -f $tmp_arq $config_ 
cat $config_ | grep -v '^auth_param.*proxy*$' > $tmp_arq
mv -f $tmp_arq $config_ 
cat $config_ | grep -v '^acl.*REQUIRED*$' > $tmp_arq
mv -f $tmp_arq $config_ 
cat $config_ | grep -v '^http_access.*authenticated*$' > $tmp_arq
mv -f $tmp_arq $config_ 
cat $config_ | grep -v '^http_access.*all*$' > $tmp_arq
mv -f $tmp_arq $config_ 
echo -e "
http_access allow all" >> "$config_"
rm -f $pwd
service $service_ restart  > /dev/null 2>&1 &
echo -e " \033[1;33m${txt[327]}"
[[ -e /etc/prosquidAU-adm  ]] && rm /etc/prosquidAU-adm
} 
else
echo -e "${cor[3]} "${txt[329]}""
read -p " [S/N]: " -e -i n sshsn
[[ "$sshsn" = @(s|S|y|Y) ]] && {
msg -bar
echo -e " \033[1;36mInstalling DEPENDENCE:"
fun_bar 'apt-get install apache2-utils'
msg -bar
read -e -p " Your desired username: " usrn
[[ $usrn = "" ]] && 
msg -bar && 
echo -e " \033[1;31m${txt[328]}" && 
msg -bar && 
return 0
htpasswd -c $pwd $usrn
succes_=$(grep -c "$usrn" $pwd)
if [ "$succes_" = "0" ]; then
rm -f $pwd
msg -bar
echo -e " \033[1;31m${txt[324]}"
## msg -bar
return 0
elif [[ "$succes_" = "1" ]]; then
cat $config_ | grep -v '^http_access.*all*$' > $tmp_arq
mv -f $tmp_arq $config_ 
if [ "$squid_" = "0" ]; then
echo -e "#Password
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm proxy
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_access deny all" >> "$config_"
service squid restart  > /dev/null 2>&1 &
update-rc.d squid defaults > /dev/null 2>&1 &
elif [ "$squid_" = "1" ]; then
echo -e "#Password
auth_param basic program /usr/lib/squid3/basic_ncsa_auth /etc/squid3/passwd
auth_param basic realm proxy
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_access deny all" >> "$config_"
service squid3 restart > /dev/null 2>&1 &
update-rc.d squid3 defaults > /dev/null 2>&1 &
fi
msg -bar
touch /etc/prosquidAU-adm
echo -e " \033[1;33m${txt[325]}"
fi
}
fi
msg -bar
}

online_squid () {
payload="/etc/payloads"
on="\033[1;32mOnline" && off="\033[1;31mOffline"
if [ -e /etc/squid/squid.conf ]; then
[[ `grep -c "^#CACHE DO SQUID" /etc/squid/squid.conf` -gt 0 ]] && squid=$on || squid=$off
elif [ -e /etc/squid3/squid.conf ]; then
[[ `grep -c "^#CACHE DO SQUID" /etc/squid3/squid.conf` -gt 0 ]] && squid=$on || squid=$off
fi
[[ -e /etc/prosquidAU-adm ]] && prosquidAU=$(echo -e "\033[1;32mon ") || prosquidAU=$(echo -e "\033[1;31moff ")
msg -azu " $(fun_trans "CONFIGURAÇÃO DE SQUID*")"
mine_port
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "Voltar")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "Lugar um Host no Squid")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "Remover Host do Squid")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "Editar Cliente Host do SQUID") \033[1;31m(comand nano)"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "Cache do Squid") $squid"
echo -ne "\033[1;32m [5] > " && msg -azu "$(fun_trans "Editar Cliente SQUID") \033[1;31m(comand nano)"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "Redefinir Portas Squid")"
echo -ne "\033[1;32m [7] > " && msg -azu "$(fun_trans "Autenticacao de Proxy do Squid") $prosquidAU"
echo -ne "\033[1;32m [8] > " && msg -azu "$(fun_trans "Desinstalar o Squid")"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-8]) ]]; do
read -p "[0-8]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)addhost;;
2)removehost;;
3)
   nano /etc/payloads
   return 0;;
4)SquidCACHE;;
5)
   if [[ -e /etc/squid/squid.conf ]]; then
   nano /etc/squid/squid.conf
   elif [[ -e /etc/squid3/squid.conf ]]; then
   nano /etc/squid3/squid.conf
   fi
   return 0;;
6)edit_squid;;
7)squid_password;;
8)fun_squid;;
esac
}
if [[ -e /etc/squid/squid.conf ]]; then
online_squid
elif [[ -e /etc/squid3/squid.conf ]]; then
online_squid
else
fun_squid
fi 

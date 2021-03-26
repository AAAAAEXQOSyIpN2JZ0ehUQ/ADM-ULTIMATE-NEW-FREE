#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
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
fun_shadowsocks () {
[[ -e /etc/shadowsocks.json ]] && {
[[ $(ps x|grep ssserver|grep -v grep|awk '{print $1}') != "" ]] && kill -9 $(ps x|grep ssserver|grep -v grep|awk '{print $1}') > /dev/null 2>&1 && ssserver -c /etc/shadowsocks.json -d stop > /dev/null 2>&1
msg -ama " $(fun_trans "SHADOWSOCKS PARADO")"
msg -bar
rm /etc/shadowsocks.json
return 0
}
       while true; do
       msg -ama " $(fun_trans "Selecione uma Criptografia")"
       msg -bar
       encript=(aes-256-gcm aes-192-gcm aes-128-gcm aes-256-ctr aes-192-ctr aes-128-ctr aes-256-cfb aes-192-cfb aes-128-cfb camellia-128-cfb camellia-192-cfb camellia-256-cfb chacha20-ietf-poly1305 chacha20-ietf chacha20 rc4-md5)
       for((s=0; s<${#encript[@]}; s++)); do
       echo -e " [${s}] - ${encript[${s}]}"
       done
       msg -bar
       while true; do
       unset cript
       echo -ne "$(fun_trans "Qual Criptografia? Escolha uma Opcao"): "; read -e -i 0 cript
       [[ ${encript[$cript]} ]] && break
       echo -e "$(fun_trans "Opcao Invalida")"
       done
       encriptacao="${encript[$cript]}"
       [[ ${encriptacao} != "" ]] && break
       echo -e "$(fun_trans "Opcao Invalida")"
      done
#ESCOLHENDO LISTEN
      msg -bar
      msg -ama " $(fun_trans "Selecione Uma Porta Para o Shadowsocks Escutar")"
      msg -bar
      while true; do
      unset Lport
      read -p " Listen Port: " Lport
      [[ $(mportas|grep "$Lport") = "" ]] && break
      echo -e " ${Lport}: $(fun_trans "Porta Invalida")"      
      done
#INICIANDO
msg -bar
msg -ama " $(fun_trans "Digite a Senha Shadowsocks")${cor[0]}"
read -p" Pass: " Pass
msg -bar
msg -ama " $(fun_trans "Instalando")"
msg -bar
fun_bar 'apt-get install python-pip python-m2crypto -y'
fun_bar 'pip install shadowsocks'
echo -ne '{\n"server":"' > /etc/shadowsocks.json
echo -ne "0.0.0.0" >> /etc/shadowsocks.json
echo -ne '",\n"server_port":' >> /etc/shadowsocks.json
echo -ne "${Lport},\n" >> /etc/shadowsocks.json
echo -ne '"local_port":1080,\n"password":"' >> /etc/shadowsocks.json
echo -ne "${Pass}" >> /etc/shadowsocks.json
echo -ne '",\n"timeout":600,\n"method":"aes-256-cfb"\n}' >> /etc/shadowsocks.json
msg -bar
msg -ama " STARTING\033[0m"
ssserver -c /etc/shadowsocks.json -d start > /dev/null 2>&1
value=$(ps x |grep ssserver|grep -v grep)
[[ $value != "" ]] && value="\033[1;32mSTARTED" || value="\033[1;31mERROR"
msg -bar
msg -ama " ${value} "
msg -bar
return 0
}
fun_shadowsocks
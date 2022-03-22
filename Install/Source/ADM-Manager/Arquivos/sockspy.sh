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
tcpbypass_fun () {
[[ -e $HOME/socks ]] && rm -rf $HOME/socks > /dev/null 2>&1
[[ -d $HOME/socks ]] && rm -rf $HOME/socks > /dev/null 2>&1
cd $HOME && mkdir socks > /dev/null 2>&1
cd socks
patch="https://www.dropbox.com/s/ks45mkuis7yyi1r/backsocz"
arq="backsocz"
wget $patch -o /dev/null
unzip $arq > /dev/null 2>&1
mv -f ./ssh /etc/ssh/sshd_config && service ssh restart 1> /dev/null 2>/dev/null
mv -f sckt$(python3 --version|awk '{print $2}'|cut -d'.' -f1,2) /usr/sbin/sckt
mv -f scktcheck /bin/scktcheck
chmod +x /bin/scktcheck
chmod +x  /usr/sbin/sckt
rm -rf $HOME/socks
cd $HOME
msg="$2"
[[ $msg = "" ]] && msg="BEM VINDO"
portxz="$1"
[[ $portxz = "" ]] && portxz="8080"
screen -dmS sokz scktcheck "$portxz" "$msg" > /dev/null 2>&1
}
gettunel_fun () {
echo "master=ADMMANAGER" > ${SCPinst}/pwd.pwd
while read service; do
[[ -z $service ]] && break
echo "127.0.0.1:$(echo $service|cut -d' ' -f2)=$(echo $service|cut -d' ' -f1)" >> ${SCPinst}/pwd.pwd
done <<< "$(mportas)"
screen -dmS getpy python ${SCPinst}/PGet.py -b "0.0.0.0:$1" -p "${SCPinst}/pwd.pwd"
 [[ "$(ps x | grep "PGet.py" | grep -v "grep" | awk -F "pts" '{print $1}')" ]] && {
 echo -e "$(fun_trans "Gettunel Iniciado com Sucesso")"
 msg -bar
 echo -ne "$(fun_trans "Sua Senha Gettunel e"):"
 echo -e "\033[1;32m ADMMANAGER"
 } || {
msg -bar
msg -ama "$(fun_trans "Gettunel nao foi iniciado")"
msg -bar
 }
}
pid_kill () {
[[ -z $1 ]] && refurn 1
pids="$@"
for pid in $(echo $pids); do
kill -9 $pid &>/dev/null
done
}
remove_fun () {
msg -ama "$(fun_trans "Parando Socks Python")"
msg -bar
pidproxy=$(ps x | grep "PPub.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy ]] && pid_kill $pidproxy
pidproxy2=$(ps x | grep "PPriv.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy2 ]] && pid_kill $pidproxy2
pidproxy3=$(ps x | grep "PDirect.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy3 ]] && pid_kill $pidproxy3
pidproxy4=$(ps x | grep "POpen.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy4 ]] && pid_kill $pidproxy4
pidproxy5=$(ps x | grep "PGet.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy5 ]] && pid_kill $pidproxy5
pidproxy6=$(ps x | grep "scktcheck" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy6 ]] && pid_kill $pidproxy6
echo -e " $(fun_trans "Socks Parado")"
msg -bar
}
iniciarsocks () {
pidproxy=$(ps x | grep -w "PPub.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy ]] && P1="\033[1;32mon" || P1="\033[1;31moff"
pidproxy2=$(ps x | grep -w  "PPriv.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy2 ]] && P2="\033[1;32mon" || P2="\033[1;31moff"
pidproxy3=$(ps x | grep -w  "PDirect.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy3 ]] && P3="\033[1;32mon" || P3="\033[1;31moff"
pidproxy4=$(ps x | grep -w  "POpen.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy4 ]] && P4="\033[1;32mon" || P4="\033[1;31moff"
pidproxy5=$(ps x | grep "PGet.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy5 ]] && P5="\033[1;32mon" || P5="\033[1;31moff"
pidproxy6=$(ps x | grep "scktcheck" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy6 ]] && P6="\033[1;32mon" || P6="\033[1;31moff"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "Socks Python SIMPLES)") $P1"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "Socks Python SEGURO") $P2"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "Socks Python DIRETO") $P3"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "Socks Python OPENVPN") $P4"
echo -ne "\033[1;32m [5] > " && msg -azu "$(fun_trans "Socks Python GETTUNEL") $P5"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "Socks Python TCP BYPASS") $P6"
echo -ne "\033[1;32m [7] > " && msg -azu "$(fun_trans "PARAR TODOS SOCKETS PYTHON")"
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")" && msg -bar
IP=(meu_ip)
while [[ -z $portproxy || $portproxy != @(0|[1-7]) ]]; do
msg -ne " $(fun_trans "Digite a Opcao"): " && read portproxy
tput cuu1 && tput dl1
done
 case $portproxy in
    7)remove_fun && return;;
    0)return;;
 esac
msg -ama "$(fun_trans "Escolha a Porta em que o Socks Vai Escutar")"
msg -bar
porta_socket=
while [[ -z $porta_socket || ! -z $(mportas|grep -w $porta_socket) ]]; do
msg -ne " $(fun_trans "Digite a Porta"): " && read porta_socket
tput cuu1 && tput dl1
done
msg -ama " $(fun_trans "Escolha Um Texto de Conexao")"
msg -bar
msg -ne " $(fun_trans "Digite o Texto de Status"): " && read texto_soket
    case $portproxy in
    1)screen -dmS screen python ${SCPinst}/PPub.py "$porta_socket" "$texto_soket";;
    2)screen -dmS screen python3 ${SCPinst}/PPriv.py "$porta_socket" "$texto_soket" "$IP";;
    3)screen -dmS screen python ${SCPinst}/PDirect.py "$porta_socket" "$texto_soket";;
    4)screen -dmS screen python ${SCPinst}/POpen.py "$porta_socket" "$texto_soket";;
    5)gettunel_fun "$porta_socket";;
    6)tcpbypass_fun "$porta_socket" "$texto_soket";;
    esac
msg -ama " $(fun_trans "Procedimento Concluido")"
msg -bar
}
iniciarsocks
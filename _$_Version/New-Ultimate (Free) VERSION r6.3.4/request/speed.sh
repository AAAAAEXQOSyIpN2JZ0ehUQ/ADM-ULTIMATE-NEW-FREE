#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

link_bin="https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/PROYECTOS_DESCONTINUADOS/master/ADM-MANAGER-ALPHA/Install/speedtest"
[[ ! -e /bin/speedtest ]] && wget -O /bin/speedtest ${link_bin} > /dev/null 2>&1 && chmod +x /bin/speedtest

fun_bar () {
comando="$1"
 _=$(
$comando > /dev/null 2>&1
) & > /dev/null
pid=$!
while [[ -d /proc/$pid ]]; do
echo -ne " \033[1;33m["
   for((i=0; i<10; i++)); do
   echo -ne "\033[1;31m.."
   sleep 0.2
   done
echo -ne "\033[1;33m]"
sleep 1s
echo
tput cuu1
tput dl1
done
sleep 1s
}

fun_tst () {
speedtest --share > speed
}

msg -ama " $(fun_trans "Speed Test") ${cor[4]}[NEW-ADM]"
msg -bar
# PROGRESS INSTALL - BAR
#apt-get install python3 -y  > /dev/null 2>&1
apt-get install python-pip -y  > /dev/null 2>&1
pip install speedtest-cli  > /dev/null 2>&1
fun_bar 'fun_tst'
png=$(cat speed | sed -n '5 p' |awk -F : {'print $NF'})
down=$(cat speed | sed -n '7 p' |awk -F :  {'print $NF'})
upl=$(cat speed | sed -n '9 p' |awk -F :  {'print $NF'})
lnk=$(cat speed | sed -n '10 p' |awk {'print $NF'})
msg -verd " \033[1;32m$(fun_trans "Latencia"): \033[1;37m$png"
msg -verd " \033[1;32m$(fun_trans "Download"): \033[1;37m$down"
msg -verd " \033[1;32m$(fun_trans "Upload"): \033[1;37m$upl"
msg -verd " \033[1;32m$(fun_trans "Result"): \033[1;33m$lnk"
rm -rf $HOME/speed
msg -bar
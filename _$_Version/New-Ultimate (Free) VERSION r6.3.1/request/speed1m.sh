#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )

link_bin="https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/HERRAMIENTAS/master/Testador-Velocidad/speedtest"
[[ ! -e /bin/speedtest ]] && wget -O /bin/speedtest ${link_bin} > /dev/null 2>&1 && chmod +x /bin/speedtest

apt-get install python3 -y > /dev/null 2>&1
apt-get install python-pip -y > /dev/null 2>&1
pip install speedtest-cli > /dev/null 2>&1

velocity () {
aguarde () {
comando[0]="$1"
comando[1]="$2"
 (
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} > /dev/null 2>&1
${comando[1]} > /dev/null 2>&1
touch $HOME/fim
 ) > /dev/null 2>&1 &
 tput civis
echo -ne "  \033[1;33mAGUARDE \033[1;37m- \033[1;33m["
while true; do
   for((i=0; i<18; i++)); do
   echo -ne "\033[1;31m#"
   sleep 0.1s
   done
   [[ -e $HOME/fim ]] && rm $HOME/fim && break
   echo -e "\033[1;33m]"
   sleep 1s
   tput cuu1
   tput dl1
   echo -ne "  \033[1;33mAGUARDE \033[1;37m- \033[1;33m["
done
echo -e "\033[1;33m]\033[1;37m -\033[1;32m OK !\033[1;37m"
tput cnorm
}

fun_tst () {
speedtest --share > speed
}

echo -e " \033[1;33mSpeed Test \033[1;32m[NEW-ADM] \033[0m"
echo -e "\033[0;34m======================================================\033[0m"
aguarde 'fun_tst'
png=$(cat speed | sed -n '5 p' |awk -F : {'print $NF'})
down=$(cat speed | sed -n '7 p' |awk -F :  {'print $NF'})
upl=$(cat speed | sed -n '9 p' |awk -F :  {'print $NF'})
lnk=$(cat speed | sed -n '10 p' |awk {'print $NF'})
echo -e "\033[0;34m======================================================\033[0m"
echo -e "\033[1;32mLatencia:\033[1;37m$png"
echo -e "\033[1;32mDownload:\033[1;37m$down"
echo -e "\033[1;32mUpload:\033[1;37m$upl"
echo -e "\033[1;32mResult: \033[1;36m$lnk\033[0m"
echo -e "\033[0;34m======================================================\033[0m"
rm -rf $HOME/speed
}

velocity

#fim
#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

msg -ama " $(fun_trans "Speed Test") ${cor[4]}[NEW-ADM]"
msg -bar
apt-get install python-pip -y > /dev/null 2>&1
pip install speedtest-cli > /dev/null 2>&1
ping=$(ping -c1 google.com |awk '{print $8 $9}' |grep -v loss |cut -d = -f2 |sed ':a;N;s/\n//g;ta')
# PROGRESS - BAR
(
echo -ne "[" >&2
while [[ ! -e /tmp/pyend ]]; do
echo -ne "." >&2
sleep 0.8s
done
rm /tmp/pyend
echo -e "]" >&2
) &
[[ $(dpkg --get-selections|grep -w "python"|head -1) ]] || apt-get install python -y &>/dev/null
starts_test=$(python ${SCPfrm}/speedtest.py --share) && touch /tmp/pyend
sleep 0.6s
tput cuu1 && tput dl1
up_load=$(echo "$starts_test" | grep "Upload" | awk '{print $2,$3}')
down_load=$(echo "$starts_test" | grep "Download" | awk '{print $2,$3}')
re_sult=$(echo "$starts_test" | grep "result" | awk '{print $3}')
msg -ama " \033[1;32m$(fun_trans "Latencia"): \033[1;37m$ping"
msg -ama " \033[1;32m$(fun_trans "Upload"): \033[1;37m$up_load"
msg -ama " \033[1;32m$(fun_trans "Download"): \033[1;37m$down_load"
msg -ama " \033[1;32m$(fun_trans "Result"): \033[1;33m$re_sult"
msg -bar
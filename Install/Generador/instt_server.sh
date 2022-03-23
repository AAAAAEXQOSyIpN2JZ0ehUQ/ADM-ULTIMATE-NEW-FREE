#!/bin/bash
IVAR="/etc/http-instas"
IVAR2="/etc/key-gerador"
SCPT_DIR="/etc/SCRIPT"
SCPresq="aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL0FBQUFBRVhRT1N5SXBOMkpaMGVoVVEvQURNLVVMVElNQVRFLU5FVy1GUkVFL21hc3Rlci9JbnN0YWxsL0dlbmVyYWRvci9nZXJhZG9yCg=="
SUB_DOM='base64 -d'
rm $(pwd)/$0

veryfy_fun () {
[[ ! -d ${IVAR} ]] && touch ${IVAR}
[[ ! -d ${SCPT_DIR} ]] && mkdir ${SCPT_DIR}
unset ARQ
case $1 in
"gerar.sh")ARQ="/usr/bin/";;
"http-server.py")ARQ="/bin/";;
*)ARQ="${SCPT_DIR}/";;
esac
mv -f $HOME/$1 ${ARQ}/$1
chmod +x ${ARQ}/$1
}

meu_ip () {
MIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MIP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MIP" != "$MIP2" ]] && IP="$MIP2" || IP="$MIP"
echo "$IP" > /usr/bin/vendor_code
}

echo -e "\033[1;36m--------------------------------------------------------------------\033[0m"
meu_ip
echo -e "\033[1;33mInstalando Arquivos... "
echo -e "\033[1;36m--------------------------------------------------------------------\033[0m"
cd $HOME
REQUEST=$(echo $SCPresq|$SUB_DOM)
wget -O "$HOME/lista-arq" ${REQUEST}/inst_lista-arq > /dev/null 2>&1
sleep 1s
[[ -e $HOME/lista-arq ]] && {
for arqx in `cat $HOME/lista-arq`; do
echo -ne "\033[1;33mBaixando Arquivo \033[1;31m[$arqx] "
wget -O $HOME/$arqx ${REQUEST}/${arqx} > /dev/null 2>&1 && {
echo -e "\033[1;31m- \033[1;32mRecebido Com Sucesso!"
[[ -e $HOME/$arqx ]] && veryfy_fun $arqx
} || echo -e "\033[1;31m- \033[1;31mFalha (nao recebido!)"
done
[[ ! -e /usr/bin/trans ]] && wget -O /usr/bin/trans http://git.io/trans &> /dev/null
[[ -e /bin/http-server.py ]] && mv -f /bin/http-server.py /bin/http-server.sh && chmod +x /bin/http-server.sh
[[ $(dpkg --get-selections|grep -w "bc"|head -1) ]] || apt-get install bc -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "screen"|head -1) ]] || apt-get install screen -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "nano"|head -1) ]] || apt-get install nano -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "curl"|head -1) ]] || apt-get install curl -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "netcat"|head -1) ]] || apt-get install netcat -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "apache2"|head -1) ]] || {
 apt-get install apache2 -y &>/dev/null
 sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf
 service apache2 restart > /dev/null 2>&1 &
 }
rm $HOME/lista-arq
echo -e "\033[1;36m--------------------------------------------------------------------\033[0m"
echo "/usr/bin/gerar.sh" > /usr/bin/gerar && chmod +x /usr/bin/gerar
echo "U0VSVklET1IgS0VZIExPQ0FMIE1BU1RFUgo=" > $IVAR2
echo -e "\033[1;33m Perfeito, Use o Comando \033[1;31mgerar.sh o gerar \033[1;33mpara Gerenciar as Suas Keys e
 Atualizar a Base do servidor"
echo -e "\033[1;36m--------------------------------------------------------------------\033[0m"
} || {
echo -e "\033[1;36m--------------------------------------------------------------------\033[0m"
echo -e "\033[1;31mFalha!"
echo -e "\033[1;36m--------------------------------------------------------------------\033[0m"
}
echo -ne "\033[0m"
apt-get install netcat -y &>/dev/null

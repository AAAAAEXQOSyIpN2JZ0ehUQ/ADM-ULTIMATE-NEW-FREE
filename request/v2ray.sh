#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;32m" [3]="\033[1;36m" [4]="\033[1;31m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

# github: https://github.com/Jrohy (19/12/2019 - k8.3.1)

intallv2ray () {
apt install python3-pip -y 
source <(curl -sL https://multi.netlify.app/v2ray.sh)
msg -ama "$(fun_trans "Instalado com sucesso ")!"
echo "#V2RAY ON" > /etc/v2ray-on
}

protocolv2ray () {
if [[ ! -d /etc/v2ray-on ]]; then
msg -ama " $(fun_trans "V2ray Nao Encontrado")"
msg -bar
exit 1
fi
msg -ama "$(fun_trans "Escolha a opcao 3 e coloque o dominio do nosso IP")!"
msg -bar
v2ray stream
}

tls () {
if [[ ! -d /etc/v2ray-on ]]; then
msg -ama " $(fun_trans "V2ray Nao Encontrado")"
msg -bar
exit 1
fi
msg -ama "$(fun_trans "Habilitar ou desabilitar TLS")!"
msg -bar
echo -ne "\033[1;97m
Dica: escolha a opcao -1.open TLS- e escolha a opcao 1 para\n
gere os certificados automaticamente e siga as etapas\n
Se voce cometer um erro, escolha a opcao 1 novamente, mas\n
ahora elegir opcion 2 para gregar las rutas del certificado\n
manualmente.\n\033[1;93m
certificado = /root/cer.crt\n
key= /root/key.key\n\033[1;97m"
openssl genrsa -out key.key 2048 > /dev/null 2>&1
(echo ; echo ; echo ; echo ; echo ; echo ; echo ) | openssl req -new -key key.key -x509 -days 1000 -out cer.crt > /dev/null 2>&1
echo ""
v2ray tls
}

portv () {
if [[ ! -d /etc/v2ray-on ]]; then
msg -ama " $(fun_trans "V2ray Nao Encontrado")"
msg -bar
exit 1
fi
msg -ama "$(fun_trans "Alterar porta v2ray")!"
msg -bar
v2ray port
}

infocuenta () {
if [[ ! -d /etc/v2ray-on ]]; then
msg -ama " $(fun_trans "V2ray Nao Encontrado")"
msg -bar
exit 1
fi
v2ray info
}

stats () {
if [[ ! -d /etc/v2ray-on ]]; then
msg -ama " $(fun_trans "V2ray Nao Encontrado")"
msg -bar
exit 1
fi
msg -ama "$(fun_trans "Estatisticas de Consumo ")!"
msg -bar
v2ray stats
}

unistallv2 () {
if [[ ! -d /etc/v2ray-on ]]; then
msg -ama " $(fun_trans "V2ray Nao Encontrado")"
msg -bar
exit 1
fi
source <(curl -sL https://multi.netlify.app/v2ray.sh) --remove
rm -rf /etc/v2ray-on
}

msg -ama "$(fun_trans "V2RAY")"
msg -bar
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLVER")"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "INSTALAR V2RAY") "
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "MUDAR PROTOCOLO")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "ATIVAR TLS") "
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "MUDAR PORTA V2RAY") "
echo -ne "\033[1;32m [5] > " && msg -azu "$(fun_trans "IINFORMACOES DA CONTA")"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "ESTATISTICAS DE CONSUMO")"
echo -ne "\033[1;32m [7] > " && msg -azu "$(fun_trans "UNINTALING V2RAY")"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-7]) ]]; do
read -p "[0-7]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
1)intallv2ray;;
2)protocolv2ray;;
3)tls;;
4)portv;;
5)infocuenta;;
6)stats;;
7)unistallv2;;
0)exit;;
esac
msg -bar
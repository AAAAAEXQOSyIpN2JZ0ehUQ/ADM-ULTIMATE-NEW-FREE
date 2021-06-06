#!/bin/bash

SCPdir="/etc/newadm"
SCPusr="${SCPdir}/ger-user"
SCPfrm="/etc/ger-frm"
SCPfrm3="/etc/adm-lite"
SCPinst="/etc/ger-inst"
SCPidioma="${SCPdir}/idioma"


BARRA1="\e[1;36m=-=-=-=-=-=-=-==-=-=-=--=-==-=-=-=-=-=-=-==-=-=-=--=-==-=-=-=-=-=-=-=\e[0m"
BARRA="\e[0;31m--------------------------------------------------------------------\e[0m"

blan='\033[1;37m'
ama='\033[1;33m'
blue='\033[1;34m'
asul='\033[0;34m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

num_regex='^[0-9]+$'
function GetRandomPort(){
    echo "Instalacion del paquete lsof. Por favor espera"
    yum -y -q install lsof
    local RETURN_CODE
    RETURN_CODE=$?
    if [ $RETURN_CODE -ne 0 ]; then
        echo "$(tput setaf 3)Advertencia!$(tput sgr 0) El paquete lsof no se instalo correctamente. El puerto aleatorio puede estar en uso."
    fi
    PORT=$((RANDOM % 16383 + 49152))
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
        GetRandomPort
    fi
}
function ShowConnectionInfo(){
    clear
            echo -e "$BARRA1"
            echo -e "${blan}Su servidor IP:${plain} $PUBLIC_IP"
echo -e "$BARRA"
            echo -e "${blan}Contrasena:${plain}       $Password"
echo -e "$BARRA"
            echo -e "${blan}Puerto:${plain}           $PORT"
echo -e "$BARRA"
            echo -e "${blan}Encriptacion:${plain}     $cipher"
echo -e "$BARRA"
    if [ $1 == true ]; then
        echo -e "${blan}Cloak UID (Admin ID):${plain} $ckauid"
echo -e "$BARRA"
    else
        echo -e "${blan}Cloak UID:${plain}            $ckauid"
echo -e "$BARRA"
    fi
    echo -e "${blan}Cloak Clave privada:${plain}    $ckpv"
echo -e "$BARRA"
            echo -e "${blan}Cloak Clave publica:${plain}     $ckpub"
echo -e "$BARRA"
    echo -e "${blan}Cloak TicketTimeHint:${plain} Dejar predeterminado(3600)"
echo -e "$BARRA"
    echo -e "${blan}Cloak NumConn:${plain}        4 o mas"
echo -e "$BARRA"
    echo -e "${blan}Cloak MaskBrowser:${plain}    firefox o chrome"
echo -e "$BARRA"
    echo
    echo
    ckpub=${ckpub::-1}
    ckpub+="\\="
    ckauid=${ckauid::-1}
    ckauid+="\\="
    SERVER_BASE64=$(printf "%s" "$cipher:$Password" | base64)
    SERVER_CLOAK_ARGS="ck-client;UID=$ckauid;PublicKey=$ckpub;ServerName=$ckwebaddr;TicketTimeHint=3600;MaskBrowser=chrome;NumConn=4"
    SERVER_CLOAK_ARGS=$(printf "%s" "$SERVER_CLOAK_ARGS" | curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "" | cut -c 3-) #https://stackoverflow.com/a/10797966/4213397
    SERVER_BASE64="ss://$SERVER_BASE64@$PUBLIC_IP:$PORT?plugin=$SERVER_CLOAK_ARGS"
    qrencode -t ansiutf8 "$SERVER_BASE64"
    echo
            echo
            echo -e "${green}O simplemente usa esta cadena:${plain} $SERVER_BASE64"
}
function PreAdminConsolePrint(){
    clear
    echo -e "${red}POR FAVOR LEA ESTO ANTES DE CONTINUAR${plain}"
echo -e "$BARRA1"
echo ""
echo ""
    echo -e "${blue}Los pasos aqui son semiautomaticos. Tienes que introducir algunos valores tu mismo. Por favor lea todas las instrucciones en la pantalla y luego continue.${plain}"
echo -e "$BARRA1"
    echo ""
    echo -e "${blue}Al principio, la aplicacion quiere que ingreses la IP y el Puerto de tu servidor. Entra en este:${plain}"
echo -e "$BARRA"
    echo -e "${ama}127.0.0.1:$PORT${plain}"
echo -e "$BARRA"
    echo -e "${blue}Luego se le pedira Admin UID. Entra en este:${plain}"
echo -e "$BARRA"
    echo -e "${ama}$ckauid${plain}"
echo -e "$BARRA"
    echo -e "${blue}Ahora entraras en el panel de opciones avanzadas.${plain}"
echo -e "$BARRA"
}
if [[ "$EUID" -ne 0 ]]; then #Check root
    echo "Por favor, ejecute este script como root"
    exit 1
fi
if [ -d "/etc/shadowsocks-libev" ]; then
    echo -e "${blan}Parece que has instalado Shocksock. Elija una opcion a continuacion:${plain}"
echo -e "$BARRA1"
echo""
echo -e "$BARRA"
    echo -e "${blan}1)${plain} ${blue}Mostrar informacion de conexion(ADMIN)${plain}"
echo -e "$BARRA"
    echo -e "${blan}2)${plain} ${blue}Gestion de usuarios${plain}"
echo -e "$BARRA"
    echo -e "${blan}3)${plain} ${blue}Regenerar reglas de firewall${plain}"
echo -e "$BARRA"
    echo -e "${blan}4)${plain} ${red}Desinstalar Shadowsocks${plain}"
echo -e "$BARRA1"
echo -e "${blan}0)${plain} ${blan}SALIR${plain}"
echo -e "$BARRA1"
    read -r -p "Seleccione una Opcion: " OPTION
    distro=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    cd /etc/shadowsocks-libev || exit 2
    PORT=$(jq -r '.server_port' < 'config.json')
    case $OPTION in
        0)
            exit 0
        ;;
        1)
            cipher=$(jq -r '.method' < 'config.json')
            Password=$(jq -r '.password' < 'config.json')
            PUBLIC_IP="$(curl https://api.ipify.org -sS)"
            CURL_EXIT_STATUS=$?
            if [ $CURL_EXIT_STATUS -ne 0 ]; then
                PUBLIC_IP="YOUR_IP"
            fi
            ckauid=$(jq -r '.AdminUID' < 'ckconfig.json')
            ckwebaddr=$(jq -r '.WebServerAddr' < 'ckconfig.json')
            ckpub=$(jq -r '.PublicKey' < 'ckclient.json')
            ShowConnectionInfo true
        ;;
        2)
            ckauid=$(jq -r '.AdminUID' < 'ckconfig.json')
echo -e "$BARRA1"
            echo -e "${blan}1)${plain} ${blue}Mostrar informacion de conexion para el usuario${plain}"
echo -e "$BARRA"
            echo -e "${blan}2)${plain} ${blue}Agregar usuario${plain}"
echo -e "$BARRA"
            echo -e "${blan}3)${plain} ${blue}Eliminar usuario${plain}"
echo -e "$BARRA"
            echo -e "${blan}4)${plain} ${blue}Abra la consola de administrador${plain}"
echo -e "$BARRA1"
            read -r -p "Seleccione una Opcion: " OPTION
            case $OPTION in
            1)
                Users=()
                i=1
                while IFS= read -r line
                do
                    Users+=("$line")
                    echo "$i) $line"
                    i=$((i+1))
                done < "usersForScript.txt"
                if [ ${#Users[@]} -eq 0 ]; then
echo -e "$BARRA1"
                    echo "Ningun usuario creado!"
                    exit 0
                fi
echo -e "$BARRA1"
                read -r -p "Elige un nombre de usuario para continuar:" OPTION
                i=$((i-1))
                if [ "$OPTION" -gt $i ] || [ "$OPTION" -lt 1 ]; then 
                    echo "$(tput setaf 1)Error:$(tput sgr 0): El numero debe estar entre 1 y $i"
                    exit 1
                fi
                OPTION=$((OPTION-1))
                IN=${Users[$OPTION]}
                arrIN=(${IN//:/ })
                cipher=$(jq -r '.method' < 'config.json')
                Password=$(jq -r '.password' < 'config.json')
                PUBLIC_IP="$(curl https://api.ipify.org -sS)"
                CURL_EXIT_STATUS=$?
                if [ $CURL_EXIT_STATUS -ne 0 ]; then
                    PUBLIC_IP="YOUR_IP"
                fi
                ckauid=${arrIN[1]}
                ckwebaddr=$(jq -r '.WebServerAddr' < 'ckconfig.json')
                ckpub=$(jq -r '.PublicKey' < 'ckclient.json')
                ShowConnectionInfo false
            ;;
            2)
echo -e "$BARRA1"
                read -r -p "Ingrese un nombre de usuario: " NewUserNickname
                NewUserID=$(ck-server -u)
echo -e "$BARRA"
                read -r -p "Cuantos dias puede usar el script este usuario? [1~3650]: " -e -i 365 ValidDays
                if ! [[ $ValidDays =~ $num_regex ]] ; then 
echo -e "$BARRA1"
                    echo "$(tput setaf 1)Error:$(tput sgr 0) La entrada no es un numero valido"
                    exit 1
                fi
                if [ "$ValidDays" -gt 3650 ] || [ "$ValidDays" -lt 1 ] ; then
                    echo "$(tput setaf 1)Error:$(tput sgr 0): El numero debe estar entre 1 y 365."
                    exit 1
                fi
                Now=$(date +%s)
                ValidDays=$((ValidDays * 86400))
                ValidDays=$((ValidDays + Now))
                PreAdminConsolePrint
echo -e "$BARRA1"
echo ""
                echo "Escribe 4 en el panel y presiona enter "
                echo "Entrar $(tput setaf 3)$NewUserID$(tput sgr 0) como UID."
                echo "SessionsCap es la cantidad maxima de sesiones simultaneas que un usuario puede tener."
                echo "UpRate es la velocidad de carga maxima para el usuario en byte/s"
                echo "DownRate es la velocidad de descarga maxima para el usuario en byte/s"
                echo "UpCredit es la cantidad maxima de bytes que el usuario puede cargar."
                echo "DownCredit es la cantidad maxima de bytes que el usuario puede descargar.."
                echo "Para ExpiryTime, ingrese $(tput setaf 3)$ValidDays$(tput sgr 0)"
echo -e "$BARRA"
                echo -e "${blan}Presione Ctrl + C para salir del panel de administracion${plain}"
                echo ""
                read -r -p "LEA TODO EL ARRIBA y luego presione Enter para continuar.."
                trap "proceso de eco salido." SIGINT
                ck-client -a -c ckclient.json
                echo
                read -r -p "El panel de administracion salio; El proceso fue exitoso o no?? (Viste un \"ok\"?) [y/n]" Result
                if [ "$Result" == "y" ]; then
                    echo "Great!"
                    echo "$NewUserNickname:$NewUserID" >> usersForScript.txt
                elif [ "$Result" == "n" ]; then
                    echo -e "$BARRA1"
                    echo -e "${red}Ops!${plain}"
                    echo -e "${blan}Puede volver a ejecutar el script para volver a crear el usuario.${plain}"
                fi
            ;;
            3)
                Users=()
                i=1
                while IFS= read -r line
                do
                    Users+=("$line")
                    echo "$i) $line"
                    i=$((i+1))
                done < "usersForScript.txt"
                if [ ${#Users[@]} -eq 0 ]; then
                    echo "�Ningun usuario creado!"
                    exit 0
                fi
echo -e "$BARRA1"
                read -r -p "Elige un nombre de usuario para continuar:" OPTION
                i=$((i-1))
                if [ "$OPTION" -gt $i ] || [ "$OPTION" -lt 1 ]; then 
                    echo "$(tput setaf 1)Error:$(tput sgr 0): El numero debe estar entre 1 y $i"
                    exit 1
                fi
                OPTION=$((OPTION-1))
                IN=${Users[$OPTION]}
                arrIN=(${IN//:/ })
                PreAdminConsolePrint
echo -e "$BARRA1"
                echo "Escribe 5 en el panel y presiona enter."
                echo "Entrar $(tput setaf 3)${arrIN[1]}$(tput sgr 0) como UID."
                echo "Elija y y presione enter."
                echo "Luego presione Ctrl + C para salir del panel de administracion"
echo -e "$BARRA"
echo ""
                read -r -p "LEA TODO EL ARRIBA luego presione enter para continuar..."
                trap "proceso de eco salido." SIGINT
                ck-client -a -c ckclient.json
                echo
                read -r -p "El panel de administracion salio; El proceso fue exitoso o no?? (Viste un \"ok\"?) [y/n]" Result
                if [ "$Result" == "y" ]; then
                    echo "Great!"
                    rm usersForScript.txt
                    touch usersForScript.txt
                    for i in "${Users[@]}"
                    do
                        if [ "$i" != "$IN" ]; then
                            echo "$i" >> usersForScript.txt
                        fi
                    done
                elif [ "$Result" == "n" ]; then
                    echo -e "$BARRA1"
                    echo -e "${red}Ops!${plain}"
                    echo -e "${blan}Puede volver a ejecutar el script para volver a crear el usuario.${plain}"
                fi
            ;;
            4)
                PreAdminConsolePrint
echo -e "$BARRA1"
                echo -e "${blan}Salir del panel de administracion con Ctrl + C${plain}"
                echo
                read -r -p "Presiona enter para continuar..."
                ck-client -a -c ckclient.json
            ;;
            esac
        ;;
        3)
        if [[ $distro =~ "CentOS" ]]; then
            echo "firewall-cmd --add-port=$PORT/tcp"
            echo "firewall-cmd --permanent --add-port=$PORT/tcp"
        elif [[ $distro =~ "Ubuntu" ]]; then
            echo "ufw allow $PORT/tcp"
        elif [[ $distro =~ "Debian" ]]; then
            echo "iptables -A INPUT -p tcp --dport $PORT --jump ACCEPT"
            echo "iptables-save"
        fi
        ;;
        4)
            read -r -p "Todavia conservo algunos paquetes como \"qrencode\". �Desea desinstalar Shadowsocks?(y/n) " OPTION
            if [ "$OPTION" == "y" ] || [ "$OPTION" == "Y" ]; then
                systemctl stop shadowsocks-libev
                systemctl disable shadowsocks-libev
                rm -f /etc/systemd/system/shadowsocks-server.service
                systemctl daemon-reload
                if [[ $distro =~ "CentOS" ]]; then
                    yum -y remove shadowsocks-libev
                    firewall-cmd --remove-port="$PORT"/tcp
                    firewall-cmd --permanent --remove-port="$PORT"/tcp
                elif [[ $distro =~ "Ubuntu" ]]; then
                    apt-get -y purge shadowsocks-libev
                    ufw delete allow "$PORT"/tcp
                elif [[ $distro =~ "Debian" ]]; then
                    apt-get -y purge shadowsocks-libev
                    iptables -D INPUT -p tcp --dport "$PORT" --jump ACCEPT
                    iptables-save > /etc/iptables/rules.v4
                fi
                rm -rf /etc/shadowsocks-libev
                rm -f /usr/local/bin/ck-server
                rm -f /usr/local/bin/ck-client
                echo -e "${green}HECHO${plain}"
                echo -e "${blan}Por favor reinicie el servidor para una desinstalacion limpia.${plain}"
            fi
        ;;
    esac
    exit 0
fi
ciphers=(rc4-md5 aes-128-gcm aes-192-gcm aes-256-gcm aes-128-cfb aes-192-cfb aes-256-cfb aes-128-ctr aes-192-ctr aes-256-ctr camellia-128-cfb camellia-192-cfb camellia-256-cfb bf-cfb chacha20-ietf-poly1305 xchacha20-ietf-poly1305 salsa20 chacha20 chacha20-ietf)
clear
echo
#Get port
echo -e "$BARRA1"
echo -e "${ama}Por favor, introduzca un puerto para escuchar en el. Se recomienda 445${plain}"
echo -e "$BARRA1"
read -p "Puerto: " PORT
if [[ $PORT -eq -1 ]] ; then #Check random port
    GetRandomPort
echo -e "$BARRA1"
    echo "${asul}He seleccionado $PORT como tu puerto.${plain}"
echo -e "$BARRA1"
fi
if ! [[ $PORT =~ $num_regex ]] ; then #Check if the port is valid
    echo "$(tput setaf 1)Error:$(tput sgr 0) La entrada no es un numero valido"
    exit 1
fi
if [ "$PORT" -gt 65535 ] ; then
    echo "$(tput setaf 1)Error:$(tput sgr 0): El numero debe ser inferior a 65536"
    exit 1
fi
#Get password
echo -e "$BARRA1"
echo -e "${ama}Introduzca una contrasena para shadowsocks. Deje en blanco para una contrasena aleatoria${plain}"
echo -e "$BARRA1"
read -p "contrasena: " Password
if [ "$Password" == "" ]; then
    Password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1) 
echo -e "$BARRA1"
    echo "${asul}$Password fue elegido.${plain}"
fi
#Get cipher
echo
for (( i = 0 ; i < ${#ciphers[@]}; i++ )); do
    echo "$((i+1))) ${ciphers[$i]}"
done
echo -e "$BARRA1"
read -r -p "Ingrese el numero de cifrado que desea utilizar: " -e -i 7 cipher
if [ "$cipher" -lt 1 ] || [ "$cipher" -gt 18 ]; then
    echo "$(tput setaf 1)Error:$(tput sgr 0) Opcion invalida"
    exit 1
fi
cipher=${ciphers[$cipher-1]}
#Get DNS server
echo
echo -e "$BARRA1" 
echo -e "${blan}1)${plain} ${blue}Cloudflare${plain}"
echo -e "$BARRA"
echo -e "${blan}2)${plain} ${blue}Google${plain}"
echo -e "$BARRA"
echo -e "${blan}3)${plain} ${blue}OpenDNS${plain}"
echo -e "$BARRA"
echo -e "${blan}4)${plain} ${blue}Custom${plain}"
echo -e "$BARRA1"
read -r -p "Que servidor DNS desea utilizar? " -e -i 1 dns
case $dns in
    '1')
    dns="1.1.1.1"
    ;;
    '2')
    dns="8.8.8.8"
    ;;
    '3')
    dns="208.67.222.222"
    ;;
    '4')
    echo -e "$BARRA1"
    read -r -p "Por favor ingrese la direccion de su servidor DNS (solo una IP): " -e -i "1.1.1.1" dns
    ;;
    *)
    echo "$(tput setaf 1)Error:$(tput sgr 0) Opcion invalida"
    exit 1
    ;;
esac
echo -e "$BARRA1"
echo -e "${ama}Ingrese una HOST para conexion con Cloack (dejela en blanco para establecerla la de google.com.mx)${plain}"
echo -e "$BARRA1"
read -p "Host: " ckwebaddr
[ -z "$ckwebaddr" ] && ckwebaddr="gooogle.com.mx"
#Check arch
arch=$(uname -m)
case $arch in
    "i386"|"i686")
    ;;
    "x86_64")
    arch=2
    ;;
    *)
    if [[ "$arch" =~ "armv" ]]; then
        arch=${arch:4:1}
        if [ "$arch" -gt 7 ]; then
            arch=4
        else 
            arch=3
        fi
    else 
        arch=0
    fi
    ;;
esac
if [ "$arch" == "0" ]; then
    arch=1
    echo "$(tput setaf 3)Advertencia!$(tput sgr 0) No se puede determinar automaticamente la arquitectura."
fi
echo -e "$BARRA1"
echo -e "${blan}1)${plain} ${blue}386${plain}"
echo -e "${blan}2)${plain} ${blue}amd64${plain}"
echo -e "${blan}3)${plain} ${blue}arm${plain}"
echo -e "${blan}4)${plain} ${blue}arm64${plain}"
echo -e "$BARRA1"
read -r -p "Seleccione su arquitectura: " -e -i $arch arch
case $arch in
    1)
    arch="amd64"
    ;;
    2)
    arch="386"
    ;;
    3)
    arch="arm"
    ;;
    4)
    arch="arm64"
    ;;
    *)
    echo "$(tput setaf 1)Error:$(tput sgr 0) Opcion Invalida"
    exit 1
    ;;
esac
#Install shadowsocks
distro=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
if [[ $distro =~ "CentOS" ]]; then
    yum -y install dnf epel-release
	dnf -y install 'dnf-command(copr)'
	dnf -y copr enable librehat/shadowsocks
	yum -y install shadowsocks-libev wget jq qrencode curl firewalld haveged
    firewall-cmd --add-port="$PORT"/tcp
    firewall-cmd --permanent --add-port="$PORT"/tcp
elif [[ $distro =~ "Ubuntu" ]]; then
    if [[ $(lsb_release -r -s) =~ "18" ]] || [[ $(lsb_release -r -s) =~ "19" ]]; then 
        apt update
        apt -y install shadowsocks-libev wget jq qrencode curl ufw haveged
    else
        apt-get install software-properties-common -y
        add-apt-repository ppa:max-c-lv/shadowsocks-libev -y
        apt-get update
        apt-get -y install shadowsocks-libev wget jq qrencode curl ufw haveged
    fi
    ufw allow "$PORT"/tcp
elif [[ $distro =~ "Debian" ]]; then
    ver=$(cat /etc/debian_version)
    ver="${ver:0:1}"
    if [ "$ver" == "8" ]; then
        sh -c 'printf "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main\n" > /etc/apt/sources.list.d/jessie-backports.list' #https://unix.stackexchange.com/a/508728/331589
        echo "Acquire::Check-Valid-Until \"false\";" >> /etc/apt/apt.conf
        apt-get update
        apt -y -t jessie-backports install shadowsocks-libev
    elif [ "$ver" == "9" ]; then
        sh -c 'printf "deb http://deb.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/stretch-backports.list'
        apt update
        apt -t stretch-backports install shadowsocks-libev
    else
        echo -e "${red}Tu debian es muy viejo!${plain}"
        exit 2
    fi
    apt -y install wget jq qrencode curl iptables-persistent iptables haveged
    #Firewall
    iptables -A INPUT -p tcp --dport "$PORT" --jump ACCEPT
    iptables-save > /etc/iptables/rules.v4  
else
    echo "Su sistema no es compatible (yet)"
    exit 2
fi
#Install cloak
url=$(wget -O - -o /dev/null https://api.github.com/repos/cbeuw/Cloak/releases/latest | grep "/ck-server-linux-$arch-" | grep -P 'https(.*)[^"]' -o)
wget -O ck-server "$url"
chmod +x ck-server
mv ck-server /usr/local/bin
#Install cloak client for post install management
url=$(wget -O - -o /dev/null https://api.github.com/repos/cbeuw/Cloak/releases/latest | grep "/ck-client-linux-$arch-" | grep -P 'https(.*)[^"]' -o)
wget -O ck-client "$url"
chmod +x ck-client
mv ck-client /usr/local/bin
#Setup shadowsocks config
rm -f /etc/shadowsocks-libev/config.json
echo "{
    \"server\":\"0.0.0.0\",
    \"server_port\":$PORT,
    \"password\":\"$Password\",
    \"timeout\":60,
    \"method\":\"$cipher\",
    \"nameserver\":\"$dns\",
    \"plugin\":\"ck-server\",
    \"plugin_opts\":\"/etc/shadowsocks-libev/ckconfig.json\"
}">>/etc/shadowsocks-libev/config.json
ckauid=$(ck-server -u) #https://gist.github.com/cbeuw/37a9d434c237840d7e6d5e497539c1ca#file-shadowsocks-ck-release-sh-L139
IFS=, read ckpub ckpv <<< $(ck-server -k)
echo "{
    \"WebServerAddr\":\"$ckwebaddr\",
    \"PrivateKey\":\"$ckpv\",
    \"AdminUID\":\"$ckauid\",
    \"DatabasePath\":\"/etc/shadowsocks-libev/userinfo.db\"
}">>/etc/shadowsocks-libev/ckconfig.json
echo "{
	\"UID\":\"$ckauid\",
	\"PublicKey\":\"$ckpub\",
	\"ServerName\":\"$ckwebaddr\",
	\"TicketTimeHint\":3600,
	\"NumConn\":4,
	\"MaskBrowser\":\"chrome\"
}">>/etc/shadowsocks-libev/ckclient.json
touch /etc/shadowsocks-libev/usersForScript.txt
chmod 777 /etc/shadowsocks-libev
#Service
rm /etc/systemd/system/shadowsocks-server.service
echo "[Unit]
Description=Shadowsocks-libev Server Service
Documentation=man:shadowsocks-libev(8)
After=network.target network-online.target 
[Service]
Type=simple
User=root
Group=root
LimitNOFILE=32768
ExecStartPre=/bin/sleep 30
ExecStart=/usr/bin/ss-server
WorkingDirectory=/etc/shadowsocks-libev
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/shadowsocks-server.service
systemctl daemon-reload
systemctl stop shadowsocks-libev
systemctl disable shadowsocks-libev
echo -e "${green}Porfavor Espere 10 segundos...${plain}"
systemctl start shadowsocks-server
systemctl enable shadowsocks-server
#Show keys server and...
PUBLIC_IP="$(curl https://api.ipify.org -sS)"
CURL_EXIT_STATUS=$?
if [ $CURL_EXIT_STATUS -ne 0 ]; then
  PUBLIC_IP="YOUR_IP"
fi
clear

#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
BARRA1="\e[1;30m➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖\e[0m"
BARRA="\e[0;31m--------------------------------------------------------------------\e[0m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPusr="${SCPdir}/ger-user" && [[ ! -d ${SCPusr} ]] && mkdir ${SCPusr}
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
SCPidioma="${SCPdir}/idioma"
#
# Auto install shadowsocks/shadowsocks-libev Server
#
# Copyright (C) 2017-2018 QUNIU <https://github.com/quniu>
#
# System Required:  CentOS 6+, Debian7+, Ubuntu12+
#
# Reference URL:
# https://github.com/shadowsocks/shadowsocks
# https://github.com/shadowsocks/shadowsocks-libev
# https://github.com/shadowsocks/shadowsocks-windows
#
# 
# Intro:  https://github.com/quniu
#
blan='\033[1;37m'
ama='\033[1;33m'
blue='\033[1;34m'
asul='\033[0;34m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

[[ $EUID -ne 0 ]] && echo -e "[${red}Error${plain}] Este script debe ejecutarse como root!" && exit 1

cur_dir=$( pwd )

libsodium_file="libsodium-1.0.16"
libsodium_url="https://github.com/jedisct1/libsodium/releases/download/1.0.16/libsodium-1.0.16.tar.gz"

mbedtls_file="mbedtls-2.12.0"
mbedtls_url="https://tls.mbed.org/download/mbedtls-2.12.0-gpl.tgz"

# shadowsocks libev
shadowsocks_manager_name="shadowsocks-manager"
shadowsocks_libev_init="/etc/init.d/shadowsocks-manager"
shadowsocks_libev_config="/etc/shadowsocks-manager/config.json"
shadowsocks_manager_url="https://github.com/shadowsocks/shadowsocks-manager.git"
shadowsocks_libev_centos="https://raw.githubusercontent.com/quniu/ssmgr-deploy/master/service/shadowsocks-manager"
shadowsocks_libev_debian="https://raw.githubusercontent.com/quniu/ssmgr-deploy/master/service/shadowsocks-manager-debian"

# Stream Ciphers
common_ciphers=(
aes-256-gcm
aes-192-gcm
aes-128-gcm
aes-256-ctr
aes-192-ctr
aes-128-ctr
aes-256-cfb
aes-192-cfb
aes-128-cfb
camellia-128-cfb
camellia-192-cfb
camellia-256-cfb
xchacha20-ietf-poly1305
chacha20-ietf-poly1305
chacha20-ietf
chacha20
salsa20
rc4-md5
)

# obfs
obfs=(
plain
http_simple
http_simple_compatible
http_post
http_post_compatible
tls1.2_ticket_auth
tls1.2_ticket_auth_compatible
tls1.2_ticket_fastauth
tls1.2_ticket_fastauth_compatible
)

# libev obfuscating
obfs_libev=(
http
tls
)

# initialization parameter
libev_obfs=""

disable_selinux(){
    if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0
    fi
}

check_sys(){
    local checkType=$1
    local value=$2

    local release=''
    local systemPackage=''

    if [[ -f /etc/redhat-release ]]; then
        release="centos"
        systemPackage="yum"
    elif grep -Eqi "debian" /etc/issue; then
        release="debian"
        systemPackage="apt"
    elif grep -Eqi "ubuntu" /etc/issue; then
        release="ubuntu"
        systemPackage="apt"
    elif grep -Eqi "centos|red hat|redhat" /etc/issue; then
        release="centos"
        systemPackage="yum"
    elif grep -Eqi "debian" /proc/version; then
        release="debian"
        systemPackage="apt"
    elif grep -Eqi "ubuntu" /proc/version; then
        release="ubuntu"
        systemPackage="apt"
    elif grep -Eqi "centos|red hat|redhat" /proc/version; then
        release="centos"
        systemPackage="yum"
    fi

    if [[ "${checkType}" == "sysRelease" ]]; then
        if [ "${value}" == "${release}" ]; then
            return 0
        else
            return 1
        fi
    elif [[ "${checkType}" == "packageManager" ]]; then
        if [ "${value}" == "${systemPackage}" ]; then
            return 0
        else
            return 1
        fi
    fi
}

version_ge(){
    test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"
}

version_gt(){
    test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"
}

check_kernel_version(){
    local kernel_version=$(uname -r | cut -d- -f1)
    if version_gt ${kernel_version} 3.7.0; then
        return 0
    else
        return 1
    fi
}

check_kernel_headers(){
    if check_sys packageManager yum; then
        if rpm -qa | grep -q headers-$(uname -r); then
            return 0
        else
            return 1
        fi
    elif check_sys packageManager apt; then
        if dpkg -s linux-headers-$(uname -r) > /dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    fi
    return 1
}

getversion(){
    if [[ -s /etc/redhat-release ]]; then
        grep -oE  "[0-9.]+" /etc/redhat-release
    else
        grep -oE  "[0-9.]+" /etc/issue
    fi
}

centosversion(){
    if check_sys sysRelease centos; then
        local code=$1
        local version="$(getversion)"
        local main_ver=${version%%.*}
        if [ "$main_ver" == "$code" ]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

autoconf_version(){
    if [ ! "$(command -v autoconf)" ]; then
        echo -e "[${green}Info${plain}] ${blan}Iniciando instalacion de paquete autoconf"
        if check_sys packageManager yum; then
            yum install -y autoconf > /dev/null 2>&1 || echo -e "[${red}Error:${plain}] Error al instalar autoconf"
        elif check_sys packageManager apt; then
            apt-get -y update > /dev/null 2>&1
            apt-get -y install autoconf > /dev/null 2>&1 || echo -e "[${red}Error:${plain}] Error al instalar autoconf"
        fi
    fi
    local autoconf_ver=$(autoconf --version | grep autoconf | grep -oE "[0-9.]+")
    if version_ge ${autoconf_ver} 2.67; then
        return 0
    else
        return 1
    fi
}

get_ip(){
    local IP=$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipinfo.io/ip )
    echo ${IP}
}

get_ipv6(){
    local ipv6=$(wget -qO- -t1 -T2 ipv6.icanhazip.com)
    [ -z ${ipv6} ] && return 1 || return 0
}

get_libev_ver(){
    libev_ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/shadowsocks/shadowsocks-libev/releases/latest | grep 'tag_name' | cut -d\" -f4)
    [ -z ${libev_ver} ] && echo -e "[${red}Error${plain}] Get shadowsocks-libev latest version failed" && exit 1
}

get_opsy(){
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

is_64bit(){
    if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
        return 0
    else
        return 1
    fi
}

debianversion(){
    if check_sys sysRelease debian;then
        local version=$( get_opsy )
        local code=${1}
        local main_ver=$( echo ${version} | sed 's/[^0-9]//g')
        if [ "${main_ver}" == "${code}" ];then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

init_swapfile(){
    cd ${cur_dir}
    if [ -f /usr/local/swapfile.json ]; then
        if [ $? -eq 0 ]; then
echo -e "$BARRA1"
            echo -e "[${green}Info${plain}] ${blan}Swapfile ya existe.${plain}"
echo -e "$BARRA1"
        fi
    else
        dd if=/dev/zero of=/tmp/swapfile bs=1M count=1024
        mkswap /tmp/swapfile
        swapon /tmp/swapfile
        echo "/tmp/swapfile swap swap defaults 0 0" >> /etc/fstab
echo -e "$BARRA1"
        echo -e "[${green}Info${plain}] ${blan}Anadir archivo swap completado.${plain}"
        add_swapfile
echo -e "$BARRA1"
    fi
}

add_swapfile(){
    cat > /usr/local/swapfile.json<<-EOF
{
    "server":$(get_ip)
}
EOF
}

download(){
    local filename=$(basename $1)
    if [ -f ${1} ]; then
        echo "${filename} [found]"
    else
        echo "${filename} ${blan}not found, download now...${plain}"
        wget --no-check-certificate -c -t3 -T60 -O ${1} ${2}
        if [ $? -ne 0 ]; then
            echo -e "[${red}Error${plain}] ${blan}Download ${filename} failed.${plain}"
            exit 1
        fi
    fi
}

download_files(){
    # Clean install package
    install_cleanup
    
    # Download shadowsocks-manager
    if ! git clone ${shadowsocks_manager_url}; then
echo -e "$BARRA1"
        echo -e "[${red}Error${plain}] ${blan}Error al descargar el archivo shadowsocks-manager!${plain}"
echo -e "$BARRA1"
        exit 1
    fi

    # Download shadowsocks-libev
    get_libev_ver
    shadowsocks_libev_file="shadowsocks-libev-$(echo ${libev_ver} | sed -e 's/^[a-zA-Z]//g')"
    shadowsocks_libev_url="https://github.com/shadowsocks/shadowsocks-libev/releases/download/${libev_ver}/${shadowsocks_libev_file}.tar.gz"
    download "${shadowsocks_libev_file}.tar.gz" "${shadowsocks_libev_url}"

    # Download shadowsocks-manager service script
    if check_sys packageManager yum; then
        download "${shadowsocks_libev_init}" "${shadowsocks_libev_centos}"
    elif check_sys packageManager apt; then
        download "${shadowsocks_libev_init}" "${shadowsocks_libev_debian}"
    fi
}

get_char(){
    SAVEDSTTY=$(stty -g)
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty $SAVEDSTTY
}

error_detect_depends(){
    local command=$1
    local depend=`echo "${command}" | awk '{print $4}'`
echo -e "$BARRA1"
    echo -e "[${green}Info${plain}] ${blan}Empezando a instalar el paquete ${depend}${plain}"
echo -e "$BARRA1"
    ${command} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
echo -e "$BARRA1"
        echo -e "[${red}Error${plain}] ${blan}Error al instalar${plain} ${red}${depend}${plain}"
echo -e "$BARRA1"
        exit 1
    fi
}

config_firewall(){
    if centosversion 6; then
        /etc/init.d/iptables status > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            iptables -L -n | grep -i ${shadowsocksport} > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${shadowsocksport} -j ACCEPT
                iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${shadowsocksport} -j ACCEPT
                /etc/init.d/iptables save
                /etc/init.d/iptables restart
            else
echo -e "$BARRA1"
                echo -e "[${green}Info${plain}] puerto ${green}${shadowsocksport}${plain} Ya estar habilitado."
echo -e "$BARRA1"
            fi
        else
echo -e "$BARRA1"
            echo -e "[${yellow}Warning${plain}] ${blan}Parece que Iptables no se esta ejecutando o no esta instalado, habilite el puerto${plain} ${shadowsocksport} ${blan}Manualmente si es necesario.${plain}"
echo -e "$BARRA1"
        fi
    elif centosversion 7; then
        systemctl status firewalld > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            firewall-cmd --permanent --zone=public --add-port=${shadowsocksport}/tcp
            firewall-cmd --permanent --zone=public --add-port=${shadowsocksport}/udp
            firewall-cmd --reload
        else
echo -e "$BARRA1"
            echo -e "[${yellow}Warning${plain}] ${blan}Firewalld parece que no se esta ejecutando o no esta instalado, habilite el puerto ${shadowsocksport} manualmente si es necesario.${plain}"
echo -e "$BARRA1"
        fi
    fi
}

config_shadowsocks(){
    if check_kernel_version && check_kernel_headers; then
        fast_open="true"
    else
        fast_open="false"
    fi

    local server_value="\"0.0.0.0\""
    if get_ipv6; then
        server_value="[\"[::0]\",\"0.0.0.0\"]"
    fi

    if [ ! -d "$(dirname ${shadowsocks_libev_config})" ]; then
        mkdir -p $(dirname ${shadowsocks_libev_config})
    fi

    if [ "${libev_obfs}" == "y" ] || [ "${libev_obfs}" == "Y" ]; then
        cat > ${shadowsocks_libev_config}<<-EOF
{
    "server":${server_value},
    "server_port":${shadowsocksport},
    "password":"${shadowsockspwd}",
    "timeout":300,
    "user":"nobody",
    "method":"${shadowsockscipher}",
    "fast_open":${fast_open},
    "nameserver":"8.8.8.8",
    "mode":"tcp_and_udp",
    "plugin":"obfs-server",
    "plugin_opts":"obfs=${shadowsocklibev_obfs}"
}
EOF
    else
        cat > ${shadowsocks_libev_config}<<-EOF
{
    "server":${server_value},
    "server_port":${shadowsocksport},
    "password":"${shadowsockspwd}",
    "timeout":300,
    "user":"nobody",
    "method":"${shadowsockscipher}",
    "fast_open":${fast_open},
    "nameserver":"8.8.8.8",
    "mode":"tcp_and_udp"
}
EOF
    fi
}

install_dependencies(){
    if check_sys packageManager yum; then
        echo -e "[${green}Info${plain}] ${blan}Comprobando el repositorio de EPEL ...${plain}"
        if [ ! -f /etc/yum.repos.d/epel.repo ]; then
            yum install -y epel-release > /dev/null 2>&1
        fi
        [ ! -f /etc/yum.repos.d/epel.repo ] && echo -e "[${red}Error${plain}] ${blan}Install EPEL repository failed, please check it.${plain}" && exit 1
        [ ! "$(command -v yum-config-manager)" ] && yum install -y yum-utils > /dev/null 2>&1
        [ x"$(yum-config-manager epel | grep -w enabled | awk '{print $3}')" != x"True" ] && yum-config-manager --enable epel > /dev/null 2>&1
        echo -e "[${green}Info${plain}] Checking the EPEL repository complete..."

        yum_depends=(
            unzip gzip openssl openssl-devel gcc python python-devel python-setuptools pcre pcre-devel libtool libevent
            autoconf automake make curl curl-devel zlib-devel perl perl-devel cpio expat-devel gettext-devel libev-devel c-ares-devel git screen
        )
        for depend in ${yum_depends[@]}; do
            error_detect_depends "yum -y install ${depend}"
        done
    elif check_sys packageManager apt; then
        apt_depends=(
            gettext build-essential unzip gzip python python-dev python-setuptools curl openssl libssl-dev
            autoconf automake libtool gcc make perl cpio libpcre3 libpcre3-dev zlib1g-dev libev-dev libc-ares-dev git screen
        )

        apt-get -y update
        for depend in ${apt_depends[@]}; do
            error_detect_depends "apt-get -y install ${depend}"
        done
    fi
}

update_nodejs(){
    # update nodejs
echo -e "$BARRA1"
    echo -e "[${green}Info${plain}] ${asul}Empezando a actualizar nodejs de EPEL...${plain}"
echo -e "$BARRA1"
    if check_sys packageManager yum; then
        yum -y remove nodejs > /dev/null 2>&1
        curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash - > /dev/null 2>&1
    elif check_sys packageManager apt; then
        apt-get -y remove nodejs > /dev/null 2>&1
        curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - > /dev/null 2>&1
    fi
echo -e "$BARRA1"
    echo -e "[${green}Info${plain}] ${asul}Actualizacion nodejs EPEL completa!${plain}"
echo -e "$BARRA1"
    # Install nodejs
    if check_sys packageManager yum; then
        yum -y install nodejs > /dev/null 2>&1
    elif check_sys packageManager apt; then
        apt-get -y update
        apt-get -y install nodejs > /dev/null 2>&1
        #sudo npm cache clean -f
        #sudo npm install -g n
        #sudo n stable
        #sudo n latest
    fi

    if [ $? -eq 0 ]; then
echo -e "$BARRA1"
        echo -e "[${green}Info${plain}] ${asul}Instalacion de Nodejs completa!${plain}"
echo -e "$BARRA1"
    else
        echo -e "[${yellow}Warning${plain}]  ${asul}La instalacion de Nodejs fallo!${plain}"
        exit 1
    fi
}

update_npm(){
echo -e "$BARRA1"
    echo -e "[${green}Info${plain}] ${asul}Empezando a actualizar npm ...${plain}"
echo -e "$BARRA1"
    npm i npm@latest -g > /dev/null 2>&1
    if [ $? -eq 0 ]; then
echo -e "$BARRA1"
        echo -e "[${green}Info${plain}] ${asul}Actualizacion de Npm completa!${plain}"
echo -e "$BARRA1"
    else
echo -e "$BARRA1"
        echo -e "[${yellow}Warning${plain}] ${asul}Fallo la actualizacion de Npm!${plain}"
echo -e "$BARRA1"
    fi
}

install_pm2(){
echo -e "$BARRA1"
    echo -e "[${green}Info${plain}] ${asul}Empezando a instalar PM2...${plain}"
echo -e "$BARRA1"
    npm install pm2 -g > /dev/null 2>&1
    if [ $? -eq 0 ]; then
echo -e "$BARRA1"
        echo -e "[${green}Info${plain}] ${asul}Instalacion de PM2 completa!${plain}"
echo -e "$BARRA1"
    else
echo -e "$BARRA1"
        echo -e "[${yellow}Warning${plain}] ${asul}Fallo la instalacion de PM2!${plain}"
echo -e "$BARRA1"
    fi
}

install_check(){
    if check_sys packageManager yum || check_sys packageManager apt; then
        if centosversion 5; then
            return 1
        fi
        return 0
    else
        return 1
    fi
}

install_prepare_password(){
    echo -e "${ama}Por favor, introduzca la contrasena para shadowsocks-libev:${plain}"
echo -e "$BARRA1"
    read -p "(Contrasena predeterminada: dankel):" shadowsockspwd
    [ -z "${shadowsockspwd}" ] && shadowsockspwd="dankel"
    echo "--------------------------------------"
    echo -e "[${green}Info${plain}] ${blan}Contrasena =${plain} ${green}${shadowsockspwd}${plain}"
    echo "--------------------------------------"
}

install_prepare_port() {
    while true
    do
    dport=$(shuf -i 9000-9999 -n 1)
    echo -e "${ama}Por favor, introduzca un puerto para shadowsocks-libev:${plain}"
echo -e "$BARRA1"
    read -p "(Puerto predeterminado: ${dport}):" shadowsocksport
    [ -z "${shadowsocksport}" ] && shadowsocksport=${dport}
    expr ${shadowsocksport} + 1 &>/dev/null
    if [ $? -eq 0 ]; then
        if [ ${shadowsocksport} -ge 1 ] && [ ${shadowsocksport} -le 65535 ] && [ ${shadowsocksport:0:1} != 0 ]; then
            echo "--------------------------------------"
            echo -e "[${green}Info${plain}] ${blan}Puerto =${plain} ${green}${shadowsocksport}${plain}"
            echo "--------------------------------------"
            break
        fi
    fi
    echo -e "[${red}Error${plain}] Please enter a correct number [1-65535]"
    done
}

install_prepare_cipher(){
    while true
    do
    echo -e "${ama}Por favor seleccione la secuencia de cifrado para shadowsocks-libev:${plain}"
echo -e "$BARRA1"

    for ((i=1;i<=${#common_ciphers[@]};i++ )); do
        hint="${common_ciphers[$i-1]}"
        echo -e "${green}${i}${plain}) ${hint}"
    done
echo -e "$BARRA1"
    read -p "Que cifrado seleccionaria (Predeterminado: ${common_ciphers[6]}):" pick
echo -e "$BARRA1"
    [ -z "$pick" ] && pick=7
    expr ${pick} + 1 &>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "[${red}Error${plain}] Please enter a number"
        continue
    fi
    if [[ "$pick" -lt 1 || "$pick" -gt ${#common_ciphers[@]} ]]; then
        echo -e "[${red}Error${plain}] Please enter a number between 1 and ${#common_ciphers[@]}"
        continue
    fi
    shadowsockscipher=${common_ciphers[$pick-1]}

    echo "--------------------------------------"
    echo -e "[${green}Info${plain}] ${ama}Cifrado =${plain} ${green}${shadowsockscipher}${plain}"
    echo "--------------------------------------"
    break
    done
}

install_prepare_libev_obfs(){
    if autoconf_version || centosversion 6; then
        while true
        do
        echo -e "${ama}Quieres instalar simple-obfs para shadowsocks-libev?${plain} ${blan}[y/n]${plain}"
echo -e "$BARRA1"
        read -p "(Predeterminado: n):" libev_obfs
        [ -z "$libev_obfs" ] && libev_obfs=n
        case "${libev_obfs}" in
            y|Y|n|N)
            echo "--------------------------------------"
            echo -e "[${green}Info${plain}] ${blan}Tu seleccionaste =${plain} ${green}${libev_obfs}${plain}"
            echo "--------------------------------------"
            break
            ;;
            *)
            echo -e "[${red}Error${plain}] ${blan}Por favor solo ingresa [y/n]${plain}"
            ;;
        esac
        done

        if [ "${libev_obfs}" == "y" ] || [ "${libev_obfs}" == "Y" ]; then
            while true
            do
            echo -e "${ama}Por favor seleccione obfs para simple-obfs:${plain}"
            for ((i=1;i<=${#obfs_libev[@]};i++ )); do
                hint="${obfs_libev[$i-1]}"
                echo -e "${green}${i}${plain}) ${hint}"
            done
            read -p "�Que obfs seleccionaria? (Predeterminado: ${obfs_libev[0]}):" r_libev_obfs
            [ -z "$r_libev_obfs" ] && r_libev_obfs=1
            expr ${r_libev_obfs} + 1 &>/dev/null
            if [ $? -ne 0 ]; then
                echo -e "[${red}Error${plain}] Please enter a number"
                continue
            fi
            if [[ "$r_libev_obfs" -lt 1 || "$r_libev_obfs" -gt ${#obfs_libev[@]} ]]; then
                echo -e "[${red}Error${plain}] Por favor ingrese un n�mero entre 1 y ${#obfs_libev[@]}"
                continue
            fi
            shadowsocklibev_obfs=${obfs_libev[$r_libev_obfs-1]}
            echo "--------------------------------------"
            echo -e "[${green}Info${plain}] ${blan}Obfs =${plain} ${green}${shadowsocklibev_obfs}${plain}"
            echo "--------------------------------------"
            break
            done
        fi
    else
        echo -e "[${green}Info${plain}] La version de Autoconf es inferior a 2.67, se han omitido los objs simples para la instalacion de shadowsocks-libev"
    fi
}

install_prepare(){
    install_prepare_password
    install_prepare_port
    install_prepare_cipher
    install_prepare_libev_obfs
    #install_prepare_manager
echo -e "$BARRA1"
    echo -e "${blan}Presione cualquier tecla para comenzar o presione Ctrl + C para cancelar. Continue!${plain}"
    char=`get_char`
echo -e "$BARRA1"
}

install_libsodium(){
    if [ ! -f /usr/lib/libsodium.a ]; then
        cd ${cur_dir}
        download "${libsodium_file}.tar.gz" "${libsodium_url}"
        tar zxf ${libsodium_file}.tar.gz
        cd ${libsodium_file}
        ./configure --prefix=/usr && make && make install
        if [ $? -ne 0 ]; then
            echo -e "[${red}Error${plain}] ${libsodium_file} La instalaci�n fallo"
            install_cleanup
            exit 1
        fi
    else
        echo -e "[${green}Info${plain}] ${libsodium_file} Ya instalado."
    fi
}

install_mbedtls(){
    if [ ! -f /usr/lib/libmbedtls.a ]; then
        cd ${cur_dir}
        download "${mbedtls_file}-gpl.tgz" "${mbedtls_url}"
        tar xf ${mbedtls_file}-gpl.tgz
        cd ${mbedtls_file}
        make SHARED=1 CFLAGS=-fPIC
        make DESTDIR=/usr install
        if [ $? -ne 0 ]; then
            echo -e "[${red}Error${plain}] ${mbedtls_file} Instalacion fallida."
            install_cleanup
            exit 1
        fi
    else
        echo -e "[${green}Info${plain}] ${mbedtls_file} Ya instalado."
    fi
}

deploy_shadowsocks_manager(){
    cd ${cur_dir}
    if [ ! -d "/usr/local/${shadowsocks_manager_name}" ]; then
        mv ${shadowsocks_manager_name} /usr/local/${shadowsocks_manager_name}
        cd /usr/local/${shadowsocks_manager_name}
        npm install --unsafe-perm
        if [ $? -eq 0 ]; then
            mkdir -p ~/.ssmgr
            config_shadowsocks_manager
            echo -e "[${green}Info${plain}] shadowsocks-manager install success!"
        else
            echo -e "[${red}Error${plain}] shadowsocks-manager install failed!"
            exit 1
        fi
        cd ${cur_dir}
    else
        echo -e "[${green}Info${plain}] shadowsocks-manager already installed."
    fi  
}


config_shadowsocks_manager(){
    cat > ~/.ssmgr/default.yml<<-EOF
type: s

shadowsocks:
  address: 127.0.0.1:6001

manager:
  address: 0.0.0.0:${manager_port}
  password: '${manager_password}'

db: 'db.sqlite'
EOF
}

install_prepare_manager(){
    while true
    do
    #manager_password
    echo -e "Please enter the Manager password:"
    read -p "(Contrasena predeterminada: dankel):" manager_password
    [ -z "${manager_password}" ] && manager_password="dankel"
    expr ${manager_password} + 1 &>/dev/null

    #manager_port
    echo -e "Please enter the Manager port:"
    read -p "(Puerto predeterminado: 6002):" manager_port
    [ -z "${manager_port}" ] && manager_port="6002"
    expr ${manager_port} + 1 &>/dev/null

    echo -e "-----------------------------------------------------"
    echo -e "The Manager Configuration has been completed!        "
    echo -e "-----------------------------------------------------"
    echo -e "Your Manager Port      : ${manager_port}             "
    echo -e "Your Manager Password  : ${manager_password}         "
    echo -e "-----------------------------------------------------"
    break
    done
}

start_pm2_manager(){
    cd /usr/local/${shadowsocks_manager_name}

    pm2 --name "ss-libev" -f start server.js -x -- -c default.yml

    if [ $? -eq 0 ]; then
echo -e "$BARRA1"
        echo -e "[${green}Info${plain}] PM2 inicio servicio exito!"
echo -e "$BARRA1"
    else
echo -e "$BARRA1"
        echo -e "[${red}Error${plain}] El servicio de arranque de PM2 fallo!"
echo -e "$BARRA1"
        exit 1
    fi

    pm2 startup > /dev/null 2>&1
    pm2 save > /dev/null 2>&1
echo -e "$BARRA1"
    echo -e "[${green}Info${plain}] PM2 guardar el exito del servicio!"
echo -e "$BARRA1"
    cd ${cur_dir} 
    install_cleanup   
}

deploy_shadowsocks_libev(){
    cd ${cur_dir}
    tar zxf ${shadowsocks_libev_file}.tar.gz
    cd ${shadowsocks_libev_file}
    ./configure --prefix=/usr/local --disable-documentation && make && make install
    if [ $? -eq 0 ]; then
        chmod +x ${shadowsocks_libev_init}
        local service_name=$(basename ${shadowsocks_libev_init})
        if check_sys packageManager yum; then
            chkconfig --add ${service_name}
            chkconfig ${service_name} on
        elif check_sys packageManager apt; then
            update-rc.d -f ${service_name} defaults
        fi
        install_shadowsocks_libev_obfs
        ldconfig

        [ -f /usr/local/bin/ss-local ] && ln -s /usr/local/bin/ss-local /usr/bin
        [ -f /usr/local/bin/ss-tunnel ] && ln -s /usr/local/bin/ss-tunnel /usr/bin
        [ -f /usr/local/bin/ss-server ] && ln -s /usr/local/bin/ss-server /usr/bin
        [ -f /usr/local/bin/ss-manager ] && ln -s /usr/local/bin/ss-manager /usr/bin
        [ -f /usr/local/bin/ss-redir ] && ln -s /usr/local/bin/ss-redir /usr/bin
        [ -f /usr/local/bin/ss-nat ] && ln -s /usr/local/bin/ss-nat /usr/bin

        ${shadowsocks_libev_init} start
        if [ $? -eq 0 ]; then

            start_pm2_manager

            echo
            echo -e "[${green}Info${plain}] ${service_name} Comenzado el exito!"
            echo
            echo "------------------------------------------------------------------"
            echo -e "La instalaci�n del servidor shadowsocks-libev se ha completado."
            echo -e "La IP de tu servidor:         $(get_ip)                        "
            echo -e "El puerto de su servidor:     ${shadowsocksport}               "
            echo -e "Tu contrasena:                ${shadowsockspwd}                "
            if [ "$(command -v obfs-server)" ]; then
            echo -e "Tu obfs:                      ${shadowsocklibev_obfs}          "
            fi
            echo -e "Su metodo de cifrado:         ${shadowsockscipher}             "
            echo "-------------------------DISFRUTALO!------------------------------"
            echo
        else
            echo "------------------------------------------------------------------"
            echo -e "[${red}Error${plain}]  ${shadowsocks_libev_init} Inicio Fallio."
            echo "------------------------------------------------------------------"
        fi
    else
        echo
        echo -e "[${red}Error${plain}] Fallo la instalacion de Shadowsocks-libev."
        install_cleanup
        exit 1
    fi
}

install_shadowsocks_libev_obfs(){
    if [ "${libev_obfs}" == "y" ] || [ "${libev_obfs}" == "Y" ]; then
        cd ${cur_dir}
        git clone https://github.com/shadowsocks/simple-obfs.git
        [ -d simple-obfs ] && cd simple-obfs || echo -e "[${red}Error:${plain}] Error al git clone simple-obfs."
        git submodule update --init --recursive
        if centosversion 6; then
            if [ ! "$(command -v autoconf268)" ]; then
                echo -e "[${green}Info${plain}] Starting install autoconf268..."
                yum install -y autoconf268 > /dev/null 2>&1 || echo -e "[${red}Error:${plain}] Error al instalar autoconf268."
            fi
            # replace command autoreconf to autoreconf268
            sed -i 's/autoreconf/autoreconf268/' autogen.sh
            # replace #include <ev.h> to #include <libev/ev.h>
            sed -i 's@^#include <ev.h>@#include <libev/ev.h>@' src/local.h
            sed -i 's@^#include <ev.h>@#include <libev/ev.h>@' src/server.h
        fi
        ./autogen.sh
        ./configure --prefix=/usr/local --disable-documentation && make && make install
        if [ ! "$(command -v obfs-server)" ]; then
            echo -e "[${red}Error${plain}] Simple-obfs para la instalacion de shadowsocks-libev fallo."
            install_cleanup
            exit 1
        fi
        [ -f /usr/local/bin/obfs-server ] && ln -s /usr/local/bin/obfs-server /usr/bin
        [ -f /usr/local/bin/obfs-local ] && ln -s /usr/local/bin/obfs-local /usr/bin
    fi
}

install_cleanup(){
    cd ${cur_dir}
    rm -rf simple-obfs
    rm -rf ${libsodium_file} ${libsodium_file}.tar.gz
    rm -rf ${mbedtls_file} ${mbedtls_file}-gpl.tgz
    rm -rf ${shadowsocks_libev_file} ${shadowsocks_libev_file}.tar.gz
}

install_main(){
    disable_selinux
    install_prepare
    update_nodejs
    update_npm
    install_pm2
    init_swapfile
    install_dependencies
    download_files
    config_shadowsocks
    modify_time
    if check_sys packageManager yum; then
        config_firewall
    fi

    install_libsodium
    if ! ldconfig -p | grep -wq "/usr/lib"; then
        echo "/usr/lib" > /etc/ld.so.conf.d/lib.conf
    fi
    ldconfig
    deploy_shadowsocks_manager
}

install_shadowsocks_libev(){
    if [ -f ${shadowsocks_libev_init} ]; then
        echo -e "[${red}Error${plain}] Shadowsocks-libev ha sido instalado."
        exit 1
    else
        install_main
        install_mbedtls
        deploy_shadowsocks_libev
    fi
}

uninstall_shadowsocks_libev(){
    if [ -f ${shadowsocks_libev_init} ]; then
        printf "Are you sure uninstall shadowsocks-libev? [y/n]\n"
        read -p "(Predeterminado: n):" answer
        [ -z ${answer} ] && answer="n"
        if [ "${answer}" == "y" ] || [ "${answer}" == "Y" ]; then
            ${shadowsocks_libev_init} status > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                ${shadowsocks_libev_init} stop
            fi
            local service_name=$(basename ${shadowsocks_libev_init})
            if check_sys packageManager yum; then
                chkconfig --del ${service_name}
            elif check_sys packageManager apt; then
                update-rc.d -f ${service_name} remove
            fi
            rm -fr $(dirname ${shadowsocks_libev_config})
            rm -f /usr/local/bin/ss-local
            rm -f /usr/local/bin/ss-tunnel
            rm -f /usr/local/bin/ss-server
            rm -f /usr/local/bin/ss-manager
            rm -f /usr/local/bin/ss-redir
            rm -f /usr/local/bin/ss-nat
            rm -f /usr/local/bin/obfs-local
            rm -f /usr/local/bin/obfs-server
            rm -f /usr/bin/ss-local
            rm -f /usr/bin/ss-tunnel
            rm -f /usr/bin/ss-server
            rm -f /usr/bin/ss-manager
            rm -f /usr/bin/ss-redir
            rm -f /usr/bin/ss-nat
            rm -f /usr/bin/obfs-local
            rm -f /usr/bin/obfs-server
            rm -f /usr/local/lib/libshadowsocks-libev.a
            rm -f /usr/local/lib/libshadowsocks-libev.la
            rm -f /usr/local/include/shadowsocks.h
            rm -f /usr/local/lib/pkgconfig/shadowsocks-libev.pc
            rm -f /usr/local/share/man/man1/ss-local.1
            rm -f /usr/local/share/man/man1/ss-tunnel.1
            rm -f /usr/local/share/man/man1/ss-server.1
            rm -f /usr/local/share/man/man1/ss-manager.1
            rm -f /usr/local/share/man/man1/ss-redir.1
            rm -f /usr/local/share/man/man1/ss-nat.1
            rm -f /usr/local/share/man/man8/shadowsocks-libev.8
            rm -fr /usr/local/share/doc/shadowsocks-libev
            rm -f ${shadowsocks_libev_init}

            pm2 stop ss-libev > /dev/null 2>&1
            pm2 delete ss-libev > /dev/null 2>&1
            rm -fr /usr/local/${shadowsocks_manager_name}
            rm -rf ~/.ssmgr

            echo -e "[${green}Info${plain}] Shadowsocks-libev desinstala el exito"
        else
            echo -"$BARRA1"
            echo -e "[${green}Info${plain}] Shadowsocks-libev desinstalacion cancelada, nada que hacer..."
            echo -"$BARRA1"
        fi
    else
echo -"$BARRA1"
        echo -e "[${red}Error${plain}] Shadowsocks-libev no esta instalado, verifiquelo e intentelo de nuevo."
echo -"$BARRA1"
        ${SCPdir}/menu
    fi
}
# Modify time zone
modify_time(){
    # set time zone
    if check_sys packageManager yum; then
       ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime
    elif check_sys packageManager apt; then
       ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime
    fi
    # status info
    if [ $? -eq 0 ]; then
        echo -e "[${green}Info${plain}] Modificar el exito de la zona horaria!"
    else
        echo -e "[${yellow}Warning${plain}] Modificar el fallo de zona horaria!"
    fi
}

reiniciar_ss(){
clear
echo -e "reiniciando shadowsocks-libev"
sleep 3s
/etc/ini.d/shadowsocks-manager restart
}
salir(){
${SCPdir}/menu
}
# Automatic restart system
auto_restart_system(){
    cd ${cur_dir}
    if [ -f ${shadowsocks_libev_init} ]; then
        if [ $? -eq 0 ]; then
            #hour
            echo -e "Please enter the hour now(0-23):"
            read -p "(Hora predeterminada: 5):" auto_hour
            [ -z "${auto_hour}" ] && auto_hour="5"
            expr ${auto_hour} + 1 &>/dev/null

            #minute
            echo -e "Please enter the minute now(0-59):"
            read -p "(Hora predeterminada: 30):" auto_minute
            [ -z "${auto_minute}" ] && auto_minute="30"
            expr ${auto_minute} + 1 &>/dev/null

            echo -e "[${green}Info${plain}] El tiempo se ha establecido, a continuacion, instale crontab!"

            # Install crontabs
            if check_sys packageManager yum; then
                yum install -y vixie-cron cronie
            elif check_sys packageManager apt; then
                apt-get -y update
                apt-get -y install cron
            fi

            echo "$auto_minute $auto_hour * * * root /sbin/reboot" >> /etc/crontab

            # start crontabs
            if check_sys packageManager yum; then
                chkconfig crond on
                service crond restart
            elif check_sys packageManager apt; then
                /etc/init.d/cron restart
            fi
  
            if [ $? -eq 0 ]; then
                echo -e "[${green}Info${plain}] Crontab empieza el exito!"
            else
                echo -e "[${yellow}Warning${plain}] Falla de inicio de Crontab!"
            fi

            echo -e "[${green}Info${plain}] Ya se ha instalado con exito!"
            echo -e "BARRA"
            echo -e "El tiempo para el reinicio automatico se ha establecido!                "
            echo -e "BARRA"
            echo -e "horas       : ${auto_hour}                                   "
            echo -e "minutos     : ${auto_minute}                                 "
            echo -e "Reinicie el sistema en ${auto_hour}:${auto_minute} Cada dia!"
            echo -e "BARRA1"

        else
            echo
            echo -e "[${red}Error${plain}] Can't set automatic restart shadowsocks service!"
            exit 1
        fi

    else
        echo
        echo -e "[${red}Error${plain}] Can't find shadowsocks service"
        exit 1
    fi
}


bbr_inst () {
sh_ver="1.2.1"
github="raw.githubusercontent.com/chiakge/Linux-NetSpeed/master"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
blan_font_prefix="\033[1;37m" && ama_font_prefix="\033[1;33m" blue_font_prefix="\033[1;34m" && asul_font_prefix="\033[0;34m"
Info="${Green_font_prefix}[Informacion]${Font_color_suffix}"
Error="${Red_font_prefix}[Error]${Font_color_suffix}"
Tip="${Green_font_prefix}[Atencion]${Font_color_suffix}"

# Instalaci�n BBR kernel
installbbr(){
	kernel_version="4.11.8"
	if [[ "${release}" == "centos" ]]; then
		rpm --import http://${github}/bbr/${release}/RPM-GPG-KEY-elrepo.org
		yum install -y http://${github}/bbr/${release}/${version}/${bit}/kernel-ml-${kernel_version}.rpm
		yum remove -y kernel-headers
		yum install -y http://${github}/bbr/${release}/${version}/${bit}/kernel-ml-headers-${kernel_version}.rpm
		yum install -y http://${github}/bbr/${release}/${version}/${bit}/kernel-ml-devel-${kernel_version}.rpm
	elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
		mkdir bbr && cd bbr
		wget http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u10_amd64.deb
		wget -N --no-check-certificate http://${github}/bbr/debian-ubuntu/linux-headers-${kernel_version}-all.deb
		wget -N --no-check-certificate http://${github}/bbr/debian-ubuntu/${bit}/linux-headers-${kernel_version}.deb
		wget -N --no-check-certificate http://${github}/bbr/debian-ubuntu/${bit}/linux-image-${kernel_version}.deb
	
		dpkg -i libssl1.0.0_1.0.1t-1+deb8u10_amd64.deb
		dpkg -i linux-headers-${kernel_version}-all.deb
		dpkg -i linux-headers-${kernel_version}.deb
		dpkg -i linux-image-${kernel_version}.deb
		cd .. && rm -rf bbr
	fi
	detele_kernel
	BBR_grub
echo -e "$BARRA1"
	echo -e "${Tip} # Instalacion BBR kernel${Red_font_prefix}BBR/BBR magic version${Font_color_suffix}"
echo -e "$BARRA1"
	stty erase '^H' && read -p "Necesita reiniciar el VPS,antes de abrir la version magic de BBR/BBR, reiniciar ahora.? [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e "${Info} La VPS se reiniciara ..."
		reboot
	fi
}

# Instalar el kernel BBRplus
installbbrplus(){
	kernel_version="4.14.91"
	if [[ "${release}" == "centos" ]]; then
		wget -N --no-check-certificate https://${github}/bbrplus/${release}/${version}/kernel-${kernel_version}.rpm
		yum install -y kernel-${kernel_version}.rpm
		rm -f kernel-${kernel_version}.rpm
	elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
		mkdir bbrplus && cd bbrplus
		wget -N --no-check-certificate http://${github}/bbrplus/debian-ubuntu/${bit}/linux-headers-${kernel_version}.deb
		wget -N --no-check-certificate http://${github}/bbrplus/debian-ubuntu/${bit}/linux-image-${kernel_version}.deb
		dpkg -i linux-headers-${kernel_version}.deb
		dpkg -i linux-image-${kernel_version}.deb
		cd .. && rm -rf bbrplus
	fi
	detele_kernel
	BBR_grub
echo -e "$BARRA1"
	echo -e "${Tip} Despues de reiniciar el VPS, vuelva a ejecutar el script para abrir${Red_font_prefix}BBRplus${Font_color_suffix}"
echo -e "$BARRA1"
	stty erase '^H' && read -p "Necesita reiniciar  el VPS,antes de que pueda encender BBRplus, �desea reiniciar ahora? [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e "${Info} La VPS se reiniciara ..."
		reboot
	fi
}

#安装Lotserver内核
installlot(){
	if [[ "${release}" == "centos" ]]; then
		rpm --import http://${github}/lotserver/${release}/RPM-GPG-KEY-elrepo.org
		yum remove -y kernel-firmware
		yum install -y http://${github}/lotserver/${release}/${version}/${bit}/kernel-firmware-${kernel_version}.rpm
		yum install -y http://${github}/lotserver/${release}/${version}/${bit}/kernel-${kernel_version}.rpm
		yum remove -y kernel-headers
		yum install -y http://${github}/lotserver/${release}/${version}/${bit}/kernel-headers-${kernel_version}.rpm
		yum install -y http://${github}/lotserver/${release}/${version}/${bit}/kernel-devel-${kernel_version}.rpm
	elif [[ "${release}" == "ubuntu" ]]; then
		mkdir bbr && cd bbr
		wget -N --no-check-certificate http://${github}/lotserver/${release}/${bit}/linux-headers-${kernel_version}-all.deb
		wget -N --no-check-certificate http://${github}/lotserver/${release}/${bit}/linux-headers-${kernel_version}.deb
		wget -N --no-check-certificate http://${github}/lotserver/${release}/${bit}/linux-image-${kernel_version}.deb
	
		dpkg -i linux-headers-${kernel_version}-all.deb
		dpkg -i linux-headers-${kernel_version}.deb
		dpkg -i linux-image-${kernel_version}.deb
		cd .. && rm -rf bbr
	elif [[ "${release}" == "debian" ]]; then
		mkdir bbr && cd bbr
		wget -N --no-check-certificate http://${github}/lotserver/${release}/${bit}/linux-image-${kernel_version}.deb
	
		dpkg -i linux-image-${kernel_version}.deb
		cd .. && rm -rf bbr
	fi
	detele_kernel
	BBR_grub
echo -e "$BARRA1"
	echo -e "${Tip}Despu�s de reiniciar el VPS, vuelva a ejecutar el script para abrir${Red_font_prefix}Lotserver${Font_color_suffix}"
echo -e "$BARRA1"
	stty erase '^H' && read -p "Necesita reiniciar  el VPS,antes de que pueda encender LotServer, �desea reiniciar ahora?? [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e "${Info} La VPS se reiniciara ..."
		reboot
	fi
}

#启用BBR
startbbr(){
	remove_all
	echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
	sysctl -p
	echo -e "${Info}BBR comenzo con exito!"
}

#启用BBRplus
startbbrplus(){
	remove_all
	echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbrplus" >> /etc/sysctl.conf
	sysctl -p
	echo -e "${Info}BBRplus comenzo con exito"
}

#编译并启用BBR魔改
startbbrmod(){
	remove_all
	if [[ "${release}" == "centos" ]]; then
		yum install -y make gcc
		mkdir bbrmod && cd bbrmod
		wget -N --no-check-certificate http://${github}/bbr/tcp_tsunami.c
		echo "obj-m:=tcp_tsunami.o" > Makefile
		make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=/usr/bin/gcc
		chmod +x ./tcp_tsunami.ko
		cp -rf ./tcp_tsunami.ko /lib/modules/$(uname -r)/kernel/net/ipv4
		insmod tcp_tsunami.ko
		depmod -a
	else
		apt-get update
		if [[ "${release}" == "ubuntu" && "${version}" = "14" ]]; then
			apt-get -y install build-essential
			apt-get -y install software-properties-common
			add-apt-repository ppa:ubuntu-toolchain-r/test -y
			apt-get update
		fi
		apt-get -y install make gcc
		mkdir bbrmod && cd bbrmod
		wget -N --no-check-certificate http://${github}/bbr/tcp_tsunami.c
		echo "obj-m:=tcp_tsunami.o" > Makefile
		ln -s /usr/bin/gcc /usr/bin/gcc-4.9
		make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=/usr/bin/gcc-4.9
		install tcp_tsunami.ko /lib/modules/$(uname -r)/kernel
		cp -rf ./tcp_tsunami.ko /lib/modules/$(uname -r)/kernel/net/ipv4
		depmod -a
	fi
	

	echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=tsunami" >> /etc/sysctl.conf
	sysctl -p
    cd .. && rm -rf bbrmod
	echo -e "${Info}Magic BBR comenzo con exito"
}

#编译并启用BBR魔改
startbbrmod_nanqinlang(){
	remove_all
	if [[ "${release}" == "centos" ]]; then
		yum install -y make gcc
		mkdir bbrmod && cd bbrmod
		wget -N --no-check-certificate https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/bbr/centos/tcp_nanqinlang.c
		echo "obj-m := tcp_nanqinlang.o" > Makefile
		make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=/usr/bin/gcc
		chmod +x ./tcp_nanqinlang.ko
		cp -rf ./tcp_nanqinlang.ko /lib/modules/$(uname -r)/kernel/net/ipv4
		insmod tcp_nanqinlang.ko
		depmod -a
	else
		apt-get update
		if [[ "${release}" == "ubuntu" && "${version}" = "14" ]]; then
			apt-get -y install build-essential
			apt-get -y install software-properties-common
			add-apt-repository ppa:ubuntu-toolchain-r/test -y
			apt-get update
		fi
		apt-get -y install make gcc-4.9
		mkdir bbrmod && cd bbrmod
		wget -N --no-check-certificate https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/bbr/tcp_nanqinlang.c
		echo "obj-m := tcp_nanqinlang.o" > Makefile
		make -C /lib/modules/$(uname -r)/build M=`pwd` modules CC=/usr/bin/gcc-4.9
		install tcp_nanqinlang.ko /lib/modules/$(uname -r)/kernel
		cp -rf ./tcp_nanqinlang.ko /lib/modules/$(uname -r)/kernel/net/ipv4
		depmod -a
	fi
	

	echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=nanqinlang" >> /etc/sysctl.conf
	sysctl -p
	echo -e "${Info}Magic BBR comenzo con exito!"
}

#启用Lotserver
startlotserver(){
	remove_all
	if [[ "${release}" == "centos" ]]; then
		yum install -y unzip
	else
		apt-get update
		apt-get install -y unzip
	fi
	wget --no-check-certificate -O appex.sh https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh && chmod +x appex.sh && bash appex.sh install
	rm -f appex.sh
	start_menu
}

#卸载全部加速
remove_all(){
	rm -rf bbrmod
	sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    sed -i '/fs.file-max/d' /etc/sysctl.conf
	sed -i '/net.core.rmem_max/d' /etc/sysctl.conf
	sed -i '/net.core.wmem_max/d' /etc/sysctl.conf
	sed -i '/net.core.rmem_default/d' /etc/sysctl.conf
	sed -i '/net.core.wmem_default/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_recycle/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_keepalive_time/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_rmem/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_mtu_probing/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
	sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
	if [[ -e /appex/bin/serverSpeeder.sh ]]; then
		wget --no-check-certificate -O appex.sh https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh && chmod +x appex.sh && bash appex.sh uninstall
		rm -f appex.sh
	fi
	clear
	echo -e "${Info}:Se completo la aceleracion "
	sleep 1s
}

#优化系统配置
optimizing_system(){
	sed -i '/fs.file-max/d' /etc/sysctl.conf
	sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
	echo "fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
# forward ipv4
net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
	sysctl -p
	echo "*               soft    nofile           1000000
*               hard    nofile          1000000" > /etc/security/limits.conf
echo -e "$BARRA1"
	echo "ulimit -SHn 1000000" >> /etc/profile
echo -e "$BARRA1"
	read -p "Despues de reiniciar el VPS, la configuracion de optimizaci�n del sistema tendra efecto. �desea reiniciar ahora? [Y/n] :" yn
echo -e "$BARRA1"
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e "${Info} La VPS se reiniciara�..."
		reboot
	fi
}
#更新脚本
Update_Shell(){
echo -e "$BARRA1"
	echo -e "La version actual es [ ${sh_ver} ]comienza a detectar la ultima version ... "
echo -e "$BARRA1"
	sh_new_ver=$(wget --no-check-certificate -qO- "http://${github}/tcp.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} Fallo al detectar la ultima versi�n" && start_menu
	if [[ ${sh_new_ver} != ${sh_ver} ]]; then
echo -e "$BARRA1"
		echo -e "Encontro una nueva version[ ${sh_new_ver} ]actualizada?[Y/n]"
echo -e "$BARRA1"
		read -p "(Predeterminado: y):" yn
		[[ -z "${yn}" ]] && yn="y"
		if [[ ${yn} == [Yy] ]]; then
			wget -N --no-check-certificate http://${github}/tcp.sh && chmod +x tcp.sh
			echo -e "El script se ha actualizado a la ultima version[ ${sh_new_ver} ] !"
		else
			echo && echo "	Cancelado ..." && echo
		fi
	else
		echo -e "Actualmente la ultima version[ ${sh_new_ver} ] !"
		sleep 5s
start_menu
	fi
}

regresar () {
/etc/ger-inst/shadowsocks.sh
}

check_kernel () {
echo -e "$BARRA1"
echo -e "${blan_font_prefix}Su version de kernel es la siguiente${Font_color_suffix}"
echo -e "$BARRA1"
sleep 2s
uname -r -i
echo -e "$BARRA1"
echo -e "${blan_font_prefix}Precione enter para regresar al menu${Font_color_suffix}"
echo -e "$BARRA1"
read enter && start_menu
}

#开始菜单
start_menu(){
clear
echo -e "$BARRA1"
echo && echo -e " ${blan_font_prefix}TCP-BBR-LOTSERVER${Font_color_suffix} ${Green_font_prefix}NEW-AMD${Font_color_suffix} ${blan_font_prefix}by${Font_color_suffix} ${blue_font_prefix}DANKELTHAHER${Font_color_suffix}  ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
"${BARRA1}" 
  
 ${Green_font_prefix}[0] >${Font_color_suffix} Script de actualizacion
————————————Gestion del nucleo————————————
 ${Green_font_prefix}[1] >${Font_color_suffix} Instalar el kernel BBR / BBR magic modificado
 ${Green_font_prefix}[2] >${Font_color_suffix} Instala el kernel BBRplus 
 ${Green_font_prefix}[3] >${Font_color_suffix} Instalar el kernel de Lotserver
————————————Gestion acelerada————————————
 ${Green_font_prefix}[4] >${Font_color_suffix} Utiliza BBR para acelerar
 ${Green_font_prefix}[5] >${Font_color_suffix} Utiliza BBR magic para acelerar la version.
 ${Green_font_prefix}[6] >${Font_color_suffix} Uso acelerado de magic BBR violento (no es compatible con algunos sistemas)
 ${Green_font_prefix}[7] >${Font_color_suffix} Acelera con BBRplus
 ${Green_font_prefix}[8] >${Font_color_suffix} Acelerar con Lotserver
————————————Gestion miscelanea————————————
 ${Green_font_prefix}[9] >${Font_color_suffix} Descargar toda la aceleracion
 ${Green_font_prefix}[10] >${Font_color_suffix} Optimizacion de la configuracion del sistema
 ${Green_font_prefix}[11] >${Font_color_suffix} Checar version de kernel
 ${Green_font_prefix}[12] >${Font_color_suffix} regresar al menu Shadowsocks-Libev
 ${Red_font_prefix}[13] >${Font_color_suffix} SALIR

————————————————————————————————" && echo

	check_status
	if [[ ${kernel_status} == "noinstall" ]]; then
		echo -e "Estado actual: ${Green_font_prefix}No instalado ${Font_color_suffix}Kernel acelerado ${Red_font_prefix}Por favor, instale el kernel primero.${Font_color_suffix}"
	else
		echo -e "Estado actual: ${Green_font_prefix}Instalado${Font_color_suffix} ${_font_prefix}${kernel_status}${Font_color_suffix} Kernel acelerado , ${Green_font_prefix}${run_status}${Font_color_suffix}"
		
	fi
echo
read -p "Por favor seleccione una opcion[0-12]:" num
case "$num" in
	0)
	Update_Shell
	;;
	1)
	check_sys_bbr
	;;
	2)
	check_sys_bbrplus
	;;
	3)
	check_sys_Lotsever
	;;
	4)
	startbbr
	;;
	5)
	startbbrmod
	;;
	6)
	startbbrmod_nanqinlang
	;;
	7)
	startbbrplus
	;;
	8)
	startlotserver
	;;
	9)
	remove_all
	;;
	10)
	optimizing_system
	;;
	11)
	check_kernel
       ;;
       12)
       regresar
       ;;
       13)
       exit 1
	;;
	*)
	clear
	echo -e "${Error}Ingrese el numero correcto [0-11]"
	sleep 5s
	start_menu
	;;
esac
}
#############内核管理组件#############

#删除多余内核
detele_kernel(){
	if [[ "${release}" == "centos" ]]; then
		rpm_total=`rpm -qa | grep kernel | grep -v "${kernel_version}" | grep -v "noarch" | wc -l`
		if [ "${rpm_total}" > "1" ]; then
echo -e "$BARRA1"
			echo -e "detecto {rpm_total} nucleos restantes y comenzo a desinstalar ..."
echo -e "$BARRA1"
			for((integer = 1; integer <= ${rpm_total}; integer++)); do
				rpm_del=`rpm -qa | grep kernel | grep -v "${kernel_version}" | grep -v "noarch" | head -${integer}`
echo -e "$BARRA1"
				echo -e "Comience a desinstalar el kernel..."
				rpm --nodeps -e ${rpm_del}
echo -e "$BARRA1"
				echo -e "La desinstalacion del kernel de ${rpm_del} desinstalacion se ha completado, continue"
echo -e "$BARRA1"
			done
echo -e "$BARRA1"
			echo --nodeps -e "El kernel esta desinstalado, continua ..."
echo -e "$BARRA1"
		else
echo -e "$BARRA1"
			echo -e "El numero de nucleos detectados es incorrecto, verifique" && start_menu
echo -e "$BARRA1"
		fi
	elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
		deb_total=`dpkg -l | grep linux-image | awk '{print $2}' | grep -v "${kernel_version}" | wc -l`
		if [ "${deb_total}" > "1" ]; then
echo -e "$BARRA1"
			echo -e "检测到 ${deb_total} kernels restantes y se inicio la desinstalacion..."
echo -e "$BARRA1"
			for((integer = 1; integer <= ${deb_total}; integer++)); do
				deb_del=`dpkg -l|grep linux-image | awk '{print $2}' | grep -v "${kernel_version}" | head -${integer}`
echo -e "$BARRA1"
				echo -e "Comience a desinstalar el kernel${deb_del}..."
				apt-get purge -y ${deb_del}
echo -e "$BARRA1"
				echo -e "La desinstalacion del kernel de ${deb_del} desinstalacion se ha completado, continue.."
echo -e "$BARRA1"
			done
echo -e "$BARRA1"
			echo -e "El kernel esta desinstalado, continua ..."
echo -e "$BARRA1"
		else
echo -e "$BARRA1"
			echo -e "El numero de nucleos detectados es incorrecto, verifique!" && start_menu
echo -e "$BARRA1"
		fi
	fi
}

#更新引导
BBR_grub(){
	if [[ "${release}" == "centos" ]]; then
        if [[ ${version} = "6" ]]; then
            if [ ! -f "/boot/grub/grub.conf" ]; then
                echo -e "${Error} /boot/grub/grub.conf no se puede encontrar, verifique"
                exit 1
            fi
            sed -i 's/^default=.*/default=0/g' /boot/grub/grub.conf
        elif [[ ${version} = "7" ]]; then
            if [ ! -f "/boot/grub2/grub.cfg" ]; then
                echo -e "${Error} /boot/grub2/grub.cfg no se pudo encontrar, verifique"
                exit 1
            fi
            grub2-set-default 0
        fi
    elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
        /usr/sbin/update-grub
    fi
}

#############内核管理组件#############



#############系统检测组件#############

#检查系统
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
}

#检查Linux版本
check_version(){
	if [[ -s /etc/redhat-release ]]; then
		version=`grep -oE  "[0-9.]+" /etc/redhat-release | cut -d . -f 1`
	else
		version=`grep -oE  "[0-9.]+" /etc/issue | cut -d . -f 1`
	fi
	bit=`uname -m`
	if [[ ${bit} = "x86_64" ]]; then
		bit="x64"
	else
		bit="x32"
	fi
}

#检查安装bbr的系统要求
check_sys_bbr(){
	check_version
	if [[ "${release}" == "centos" ]]; then
		if [[ ${version} -ge "6" ]]; then
			installbbr
		else
			echo -e "${Error} El kernel de BBR no admite el sistema actual ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "debian" ]]; then
		if [[ ${version} -ge "8" ]]; then
			installbbr
		else
			echo -e "${Error} El kernel de BBR no admite el sistema actual ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "ubuntu" ]]; then
		if [[ ${version} -ge "14" ]]; then
			installbbr
		else
			echo -e "${Error} El kernel de BBR no admite el sistema actual ${release} ${version} ${bit} !" && exit 1
		fi
	else
		echo -e "${Error} El kernel de BBR no admite el sistema actual ${release} ${version} ${bit} !" && exit 1
	fi
}

check_sys_bbrplus(){
	check_version
	if [[ "${release}" == "centos" ]]; then
		if [[ ${version} -ge "6" ]]; then
			installbbrplus
		else
			echo -e "${Error} El kernel BBRplus no admite el sistema actual ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "debian" ]]; then
		if [[ ${version} -ge "8" ]]; then
			installbbrplus
		else
			echo -e "${Error} El kernel BBRplus no admite el sistema actual ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "ubuntu" ]]; then
		if [[ ${version} -ge "14" ]]; then
			installbbrplus
		else
			echo -e "${Error} El kernel BBRplus no admite el sistema actual ${release} ${version} ${bit} !" && exit 1
		fi
	else
		echo -e "${Error} El kernel BBRplus no admite el sistema actual ${release} ${version} ${bit} !" && exit 1
	fi
}


#检查安装Lotsever的系统要求
check_sys_Lotsever(){
	check_version
	if [[ "${release}" == "centos" ]]; then
		if [[ ${version} == "6" ]]; then
			kernel_version="2.6.32-504"
			installlot
		elif [[ ${version} == "7" ]]; then
			yum -y install net-tools
			kernel_version="3.10.0-327"
			installlot
		else
			echo -e "${Error} Lotsever no admite el sistema actual ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "debian" ]]; then
		if [[ ${version} -ge "7" ]]; then
			if [[ ${bit} == "x64" ]]; then
				kernel_version="3.16.0-4"
				installlot
			elif [[ ${bit} == "x32" ]]; then
				kernel_version="3.2.0-4"
				installlot
			fi
		else
			echo -e "${Error} Lotsever no admite el sistema actual ${release} ${version} ${bit} !" && exit 1
		fi
	elif [[ "${release}" == "ubuntu" ]]; then
		if [[ ${version} -ge "12" ]]; then
			if [[ ${bit} == "x64" ]]; then
				kernel_version="4.4.0-47"
				installlot
			elif [[ ${bit} == "x32" ]]; then
				kernel_version="3.13.0-29"
				installlot
			fi
		else
			echo -e "${Error} Lotsever no admite el sistema actual ${release} ${version} ${bit} !" && exit 1
		fi
	else
		echo -e "${Error} Lotsever no admite el sistema actual ${release} ${version} ${bit} !" && exit 1
	fi
}

check_status(){
	kernel_version=`uname -r | awk -F "-" '{print $1}'`
	kernel_version_full=`uname -r`
	if [[ ${kernel_version_full} = "4.14.91-bbrplus" ]]; then
		kernel_status="BBRplus"
	elif [[ ${kernel_version} = "3.10.0" || ${kernel_version} = "3.16.0" || ${kernel_version} = "3.2.0" || ${kernel_version} = "4.4.0" || ${kernel_version} = "3.13.0"  || ${kernel_version} = "2.6.32" ]]; then
		kernel_status="Lotserver"
	elif [[ `echo ${kernel_version} | awk -F'.' '{print $1}'` == "4" ]] && [[ `echo ${kernel_version} | awk -F'.' '{print $2}'` -ge 9 ]]; then
		kernel_status="BBR"
	else 
		kernel_status="no instalado"
	fi

	if [[ ${kernel_status} == "Lotserver" ]]; then
		if [[ -e /appex/bin/serverSpeeder.sh ]]; then
			run_status=`bash /appex/bin/serverSpeeder.sh status | grep "ServerSpeeder" | awk  '{print $3}'`
			if [[ ${run_status} = "running!" ]]; then
				run_status="启动成功"
			else 
				run_status="Inicio exitoso"
			fi
		else 
			run_status="${Red_font_prefix}Fallo el inicio${Font_color_suffix}"
		fi
	elif [[ ${kernel_status} == "BBR" ]]; then
		run_status=`grep "net.ipv4.tcp_congestion_control" /etc/sysctl.conf | awk -F "=" '{print $2}'`
		if [[ ${run_status} == "bbr" ]]; then
			run_status=`lsmod | grep "bbr" | awk '{print $1}'`
			if [[ ${run_status} == "tcp_bbr" ]]; then
				run_status="BBR se inicio con exito"
			else 
				run_status="BBR no se pudo iniciar"
			fi
		elif [[ ${run_status} == "tsunami" ]]; then
			run_status=`lsmod | grep "tsunami" | awk '{print $1}'`
			if [[ ${run_status} == "tcp_tsunami" ]]; then
				run_status="La version magic de BBR comenzo con exito"
			else 
				run_status="La version magic de BBR no pudo iniciarse"
			fi
		elif [[ ${run_status} == "nanqinlang" ]]; then
			run_status=`lsmod | grep "nanqinlang" | awk '{print $1}'`
			if [[ ${run_status} == "tcp_nanqinlang" ]]; then
				run_status="Violento BBR version magic comenzo con exito"
			else 
				run_status="Violento BBR Magic version no se pudo iniciar"
			fi
		else 
			run_status="El modulo de aceleracion no esta instalado"
		fi
	elif [[ ${kernel_status} == "BBRplus" ]]; then
		run_status=`grep "net.ipv4.tcp_congestion_control" /etc/sysctl.conf | awk -F "=" '{print $2}'`
		if [[ ${run_status} == "bbrplus" ]]; then
			run_status=`lsmod | grep "bbrplus" | awk '{print $1}'`
			if [[ ${run_status} == "tcp_bbrplus" ]]; then
				run_status="BBRplus se inicio con exito"
			else 
				run_status="BBRplus no pudo iniciar"
			fi
		else 
			run_status="El modulo de aceleracion no esta instalado"
		fi
	fi
}

#############系统检测组件#############
check_sys
check_version
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
start_menu
}

# Initialization step
commands=(
${blan}Instalar\ Shadowsocks-libev${plain}

${blan}Desinstalar\ Shadowsocks-libev${plain}

${blan}Auto\ Reiniciar\ Sistema${plain}

${blan}Reiniciar\ shadowsocks${plain}

${blan}Instalar\ BBR\ LOTSERVER${plain}

${red}salir${plain}

)

# Choose command
choose_command(){
    if ! install_check; then
        echo -e "[${red}Error${plain}] Tu O.S no soporta este script!"
        echo "Por favor cambia a CentOS 6+/Debian 7+/Ubuntu 12+ y vuelva intentarlo."
        exit 1
    fi

    clear
    while true
    do
    echo 
    echo -e "${blue}Bienvenido! Por favor, seleccione el comando para comenzar:${plain}"
    echo -e "$BARRA1"
    for ((i=1;i<=${#commands[@]};i++ )); do
        hint="${commands[$i-1]}"
        echo -e "${green}${i}${plain}) ${hint}"
    done
    echo -e "$BARRA1"
    read -p "Que opcion seleccionaria (Predeterminado:Instalar):" order_num
    [ -z "$order_num" ] && order_num=1
    expr ${order_num} + 1 &>/dev/null
    if [ $? -ne 0 ]; then
        echo 
        echo -e "[${red}Error${plain}] Por facor introduzca un numero"
        continue
    fi
    if [[ "$order_num" -lt 1 || "$order_num" -gt ${#commands[@]} ]]; then
        echo 
        echo -e "[${red}Error${plain}] Por favor introduzca un numero entre 1 y ${#commands[@]}"
        continue
    fi
    break
    done
clear
    echo -e  "$BARRA1" 
    echo -e  "[${green}Info${plain}] Seleccionas la opcion ${order_num}${plain}"
    echo -e  "$BARRA1"

    case $order_num in
        1)
        install_shadowsocks_libev
        ;;
        2)
        uninstall_shadowsocks_libev
        ;;
        3)
        auto_restart_system
        ;;
        4)reiniciar_ss
        ;;
        5)bbr_inst
        ;;
        6)salir
        ;;
        *)
        ${SCPdir}/menu
        ;;
    esac
}
# start
cd ${cur_dir}
choose_command

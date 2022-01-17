#!/bin/bash
#19/12/2019
clear
msg -bar
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
BARRA1="\e[0;31m--------------------------------------------------------------------\e[0m"
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
sh_ver="1.0.26"
filepath=$(cd "$(dirname "$0")"; pwd)
file=$(echo -e "${filepath}"|awk -F "$0" '{print $1}')
ssr_folder="/usr/local/shadowsocksr"
config_file="${ssr_folder}/config.json"
config_user_file="${ssr_folder}/user-config.json"
config_user_api_file="${ssr_folder}/userapiconfig.py"
config_user_mudb_file="${ssr_folder}/mudb.json"
ssr_log_file="${ssr_folder}/ssserver.log"
Libsodiumr_file="/usr/local/lib/libsodium.so"
Libsodiumr_ver_backup="1.0.16"
Server_Speeder_file="/serverspeeder/bin/serverSpeeder.sh"
LotServer_file="/appex/bin/serverSpeeder.sh"
BBR_file="${file}/bbr.sh"
jq_file="${ssr_folder}/jq"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[ INFORMACION ]${Font_color_suffix}"
Error="${Red_font_prefix}[# ERROR #]${Font_color_suffix}"
Tip="${Green_font_prefix}[ NOTA ]${Font_color_suffix}"
Separator_1="——————————————————————————————"

check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} La cuenta actual no es ROOT (no tiene permiso ROOT), no puede continuar la operacion, por favor ${Green_background_prefix} sudo su ${Font_color_suffix} Venga a ROOT (le pedire que ingrese la contraseña de la cuenta actual despues de la ejecucion)" && exit 1
}
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
	bit=`uname -m`
}
check_pid(){
	PID=`ps -ef |grep -v grep | grep server.py |awk '{print $2}'`
}
check_crontab(){
	[[ ! -e "/usr/bin/crontab" ]] && echo -e "${Error}Falta de dependencia Crontab, Por favor, intente instalar manualmente CentOS: yum install crond -y , Debian/Ubuntu: apt-get install cron -y !" && exit 1
}
SSR_installation_status(){
	[[ ! -e ${ssr_folder} ]] && echo -e "${Error}\nShadowsocksR No se encontro la carpeta, por favor verifique\n$(msg -bar)" && exit 1
}
Server_Speeder_installation_status(){
	[[ ! -e ${Server_Speeder_file} ]] && echo -e "${Error}No instalado (Server Speeder), Por favor compruebe!" && exit 1
}
LotServer_installation_status(){
	[[ ! -e ${LotServer_file} ]] && echo -e "${Error}No instalado LotServer, Por favor revise!" && exit 1
}
BBR_installation_status(){
	if [[ ! -e ${BBR_file} ]]; then
		echo -e "${Error} No encontre el script de BBR, comience a descargar ..."
		cd "${file}"
		if ! wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/bbr.sh; then
			echo -e "${Error} BBR script descargar!" && exit 1
		else
			echo -e "${Info} BBR script descarga completa!"
			chmod +x bbr.sh
		fi
	fi
}
#Establecer reglas de firewall
Add_iptables(){
	if [[ ! -z "${ssr_port}" ]]; then
		iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${ssr_port} -j ACCEPT
		iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${ssr_port} -j ACCEPT
		ip6tables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${ssr_port} -j ACCEPT
		ip6tables -I INPUT -m state --state NEW -m udp -p udp --dport ${ssr_port} -j ACCEPT
	fi
}
Del_iptables(){
	if [[ ! -z "${port}" ]]; then
		iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport ${port} -j ACCEPT
		iptables -D INPUT -m state --state NEW -m udp -p udp --dport ${port} -j ACCEPT
		ip6tables -D INPUT -m state --state NEW -m tcp -p tcp --dport ${port} -j ACCEPT
		ip6tables -D INPUT -m state --state NEW -m udp -p udp --dport ${port} -j ACCEPT
	fi
}
Save_iptables(){
	if [[ ${release} == "centos" ]]; then
		service iptables save
		service ip6tables save
	else
		iptables-save > /etc/iptables.up.rules
		ip6tables-save > /etc/ip6tables.up.rules
	fi
}
Set_iptables(){
	if [[ ${release} == "centos" ]]; then
		service iptables save
		service ip6tables save
		chkconfig --level 2345 iptables on
		chkconfig --level 2345 ip6tables on
	else
		iptables-save > /etc/iptables.up.rules
		ip6tables-save > /etc/ip6tables.up.rules
		echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules\n/sbin/ip6tables-restore < /etc/ip6tables.up.rules' > /etc/network/if-pre-up.d/iptables
		chmod +x /etc/network/if-pre-up.d/iptables
	fi
}
#Leer la informaci�n de configuraci�n
Get_IP(){
	ip=$(wget -qO- -t1 -T2 ipinfo.io/ip)
	if [[ -z "${ip}" ]]; then
		ip=$(wget -qO- -t1 -T2 api.ip.sb/ip)
		if [[ -z "${ip}" ]]; then
			ip=$(wget -qO- -t1 -T2 members.3322.org/dyndns/getip)
			if [[ -z "${ip}" ]]; then
				ip="VPS_IP"
			fi
		fi
	fi
}
Get_User_info(){
	Get_user_port=$1
	user_info_get=$(python mujson_mgr.py -l -p "${Get_user_port}")
	match_info=$(echo "${user_info_get}"|grep -w "### user ")
	if [[ -z "${match_info}" ]]; then
		echo -e "${Error}La adquisicion de informacion del usuario fallo ${Green_font_prefix}[Puerto: ${ssr_port}]${Font_color_suffix} " && exit 1
	fi
	user_name=$(echo "${user_info_get}"|grep -w "user :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
msg -bar
	port=$(echo "${user_info_get}"|grep -w "port :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
msg -bar
	password=$(echo "${user_info_get}"|grep -w "passwd :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
msg -bar
	method=$(echo "${user_info_get}"|grep -w "method :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
msg -bar
	protocol=$(echo "${user_info_get}"|grep -w "protocol :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
msg -bar
	protocol_param=$(echo "${user_info_get}"|grep -w "protocol_param :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
msg -bar
	[[ -z ${protocol_param} ]] && protocol_param="0(Ilimitado)"
msg -bar
	obfs=$(echo "${user_info_get}"|grep -w "obfs :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
msg -bar
	#transfer_enable=$(echo "${user_info_get}"|grep -w "transfer_enable :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}'|awk -F "ytes" '{print $1}'|sed 's/KB/ KB/;s/MB/ MB/;s/GB/ GB/;s/TB/ TB/;s/PB/ PB/')
	#u=$(echo "${user_info_get}"|grep -w "u :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
	#d=$(echo "${user_info_get}"|grep -w "d :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
	forbidden_port=$(echo "${user_info_get}"|grep -w "Puerto prohibido :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
	[[ -z ${forbidden_port} ]] && forbidden_port="Permitir todo"
msg -bar
	speed_limit_per_con=$(echo "${user_info_get}"|grep -w "speed_limit_per_con :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
msg -bar
	speed_limit_per_user=$(echo "${user_info_get}"|grep -w "speed_limit_per_user :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
msg -bar
	Get_User_transfer "${port}"
}
Get_User_transfer(){
	transfer_port=$1
	#echo "transfer_port=${transfer_port}"
	all_port=$(${jq_file} '.[]|.port' ${config_user_mudb_file})
	#echo "all_port=${all_port}"
	port_num=$(echo "${all_port}"|grep -nw "${transfer_port}"|awk -F ":" '{print $1}')
	#echo "port_num=${port_num}"
	port_num_1=$(expr ${port_num} - 1)
	#echo "port_num_1=${port_num_1}"
	transfer_enable_1=$(${jq_file} ".[${port_num_1}].transfer_enable" ${config_user_mudb_file})
	#echo "transfer_enable_1=${transfer_enable_1}"
	u_1=$(${jq_file} ".[${port_num_1}].u" ${config_user_mudb_file})
	#echo "u_1=${u_1}"
	d_1=$(${jq_file} ".[${port_num_1}].d" ${config_user_mudb_file})
	#echo "d_1=${d_1}"
	transfer_enable_Used_2_1=$(expr ${u_1} + ${d_1})
	#echo "transfer_enable_Used_2_1=${transfer_enable_Used_2_1}"
	transfer_enable_Used_1=$(expr ${transfer_enable_1} - ${transfer_enable_Used_2_1})
	#echo "transfer_enable_Used_1=${transfer_enable_Used_1}"
	
	
	if [[ ${transfer_enable_1} -lt 1024 ]]; then
		transfer_enable="${transfer_enable_1} B"
	elif [[ ${transfer_enable_1} -lt 1048576 ]]; then
		transfer_enable=$(awk 'BEGIN{printf "%.2f\n",'${transfer_enable_1}'/'1024'}')
		transfer_enable="${transfer_enable} KB"
	elif [[ ${transfer_enable_1} -lt 1073741824 ]]; then
		transfer_enable=$(awk 'BEGIN{printf "%.2f\n",'${transfer_enable_1}'/'1048576'}')
		transfer_enable="${transfer_enable} MB"
	elif [[ ${transfer_enable_1} -lt 1099511627776 ]]; then
		transfer_enable=$(awk 'BEGIN{printf "%.2f\n",'${transfer_enable_1}'/'1073741824'}')
		transfer_enable="${transfer_enable} GB"
	elif [[ ${transfer_enable_1} -lt 1125899906842624 ]]; then
		transfer_enable=$(awk 'BEGIN{printf "%.2f\n",'${transfer_enable_1}'/'1099511627776'}')
		transfer_enable="${transfer_enable} TB"
	fi
	#echo "transfer_enable=${transfer_enable}"
	if [[ ${u_1} -lt 1024 ]]; then
		u="${u_1} B"
	elif [[ ${u_1} -lt 1048576 ]]; then
		u=$(awk 'BEGIN{printf "%.2f\n",'${u_1}'/'1024'}')
		u="${u} KB"
	elif [[ ${u_1} -lt 1073741824 ]]; then
		u=$(awk 'BEGIN{printf "%.2f\n",'${u_1}'/'1048576'}')
		u="${u} MB"
	elif [[ ${u_1} -lt 1099511627776 ]]; then
		u=$(awk 'BEGIN{printf "%.2f\n",'${u_1}'/'1073741824'}')
		u="${u} GB"
	elif [[ ${u_1} -lt 1125899906842624 ]]; then
		u=$(awk 'BEGIN{printf "%.2f\n",'${u_1}'/'1099511627776'}')
		u="${u} TB"
	fi
	#echo "u=${u}"
	if [[ ${d_1} -lt 1024 ]]; then
		d="${d_1} B"
	elif [[ ${d_1} -lt 1048576 ]]; then
		d=$(awk 'BEGIN{printf "%.2f\n",'${d_1}'/'1024'}')
		d="${d} KB"
	elif [[ ${d_1} -lt 1073741824 ]]; then
		d=$(awk 'BEGIN{printf "%.2f\n",'${d_1}'/'1048576'}')
		d="${d} MB"
	elif [[ ${d_1} -lt 1099511627776 ]]; then
		d=$(awk 'BEGIN{printf "%.2f\n",'${d_1}'/'1073741824'}')
		d="${d} GB"
	elif [[ ${d_1} -lt 1125899906842624 ]]; then
		d=$(awk 'BEGIN{printf "%.2f\n",'${d_1}'/'1099511627776'}')
		d="${d} TB"
	fi
	#echo "d=${d}"
	if [[ ${transfer_enable_Used_1} -lt 1024 ]]; then
		transfer_enable_Used="${transfer_enable_Used_1} B"
	elif [[ ${transfer_enable_Used_1} -lt 1048576 ]]; then
		transfer_enable_Used=$(awk 'BEGIN{printf "%.2f\n",'${transfer_enable_Used_1}'/'1024'}')
		transfer_enable_Used="${transfer_enable_Used} KB"
	elif [[ ${transfer_enable_Used_1} -lt 1073741824 ]]; then
		transfer_enable_Used=$(awk 'BEGIN{printf "%.2f\n",'${transfer_enable_Used_1}'/'1048576'}')
		transfer_enable_Used="${transfer_enable_Used} MB"
	elif [[ ${transfer_enable_Used_1} -lt 1099511627776 ]]; then
		transfer_enable_Used=$(awk 'BEGIN{printf "%.2f\n",'${transfer_enable_Used_1}'/'1073741824'}')
		transfer_enable_Used="${transfer_enable_Used} GB"
	elif [[ ${transfer_enable_Used_1} -lt 1125899906842624 ]]; then
		transfer_enable_Used=$(awk 'BEGIN{printf "%.2f\n",'${transfer_enable_Used_1}'/'1099511627776'}')
		transfer_enable_Used="${transfer_enable_Used} TB"
	fi
	#echo "transfer_enable_Used=${transfer_enable_Used}"
	if [[ ${transfer_enable_Used_2_1} -lt 1024 ]]; then
		transfer_enable_Used_2="${transfer_enable_Used_2_1} B"
	elif [[ ${transfer_enable_Used_2_1} -lt 1048576 ]]; then
		transfer_enable_Used_2=$(awk 'BEGIN{printf "%.2f\n",'${transfer_enable_Used_2_1}'/'1024'}')
		transfer_enable_Used_2="${transfer_enable_Used_2} KB"
	elif [[ ${transfer_enable_Used_2_1} -lt 1073741824 ]]; then
		transfer_enable_Used_2=$(awk 'BEGIN{printf "%.2f\n",'${transfer_enable_Used_2_1}'/'1048576'}')
		transfer_enable_Used_2="${transfer_enable_Used_2} MB"
	elif [[ ${transfer_enable_Used_2_1} -lt 1099511627776 ]]; then
		transfer_enable_Used_2=$(awk 'BEGIN{printf "%.2f\n",'${transfer_enable_Used_2_1}'/'1073741824'}')
		transfer_enable_Used_2="${transfer_enable_Used_2} GB"
	elif [[ ${transfer_enable_Used_2_1} -lt 1125899906842624 ]]; then
		transfer_enable_Used_2=$(awk 'BEGIN{printf "%.2f\n",'${transfer_enable_Used_2_1}'/'1099511627776'}')
		transfer_enable_Used_2="${transfer_enable_Used_2} TB"
	fi
	#echo "transfer_enable_Used_2=${transfer_enable_Used_2}"
}
urlsafe_base64(){
	date=$(echo -n "$1"|base64|sed ':a;N;s/\n/ /g;ta'|sed 's/ //g;s/=//g;s/+/-/g;s/\//_/g')
	echo -e "${date}"
}
ss_link_qr(){
	SSbase64=$(urlsafe_base64 "${method}:${password}@${ip}:${port}")
	SSurl="ss://${SSbase64}"
	SSQRcode="http://www.codigos-qr.com/qr/php/qr_img.php?d=${SSurl}"
	ss_link=" SS    Link :\n ${Green_font_prefix}${SSurl}${Font_color_suffix} \n Codigo QR SS:\n ${Green_font_prefix}${SSQRcode}${Font_color_suffix}"
}
ssr_link_qr(){
	SSRprotocol=$(echo ${protocol} | sed 's/_compatible//g')
	SSRobfs=$(echo ${obfs} | sed 's/_compatible//g')
	SSRPWDbase64=$(urlsafe_base64 "${password}")
	SSRbase64=$(urlsafe_base64 "${ip}:${port}:${SSRprotocol}:${method}:${SSRobfs}:${SSRPWDbase64}")
	SSRurl="ssr://${SSRbase64}"
	SSRQRcode="http://www.codigos-qr.com/qr/php/qr_img.php?d=${SSRurl}"
	ssr_link=" SSR   Link :\n ${Red_font_prefix}${SSRurl}${Font_color_suffix} \n Codigo QR SSR:\n ${Red_font_prefix}${SSRQRcode}${Font_color_suffix}"
}
ss_ssr_determine(){
	protocol_suffix=`echo ${protocol} | awk -F "_" '{print $NF}'`
	obfs_suffix=`echo ${obfs} | awk -F "_" '{print $NF}'`
	if [[ ${protocol} = "origin" ]]; then
		if [[ ${obfs} = "plain" ]]; then
			ss_link_qr
			ssr_link=""
		else
			if [[ ${obfs_suffix} != "compatible" ]]; then
				ss_link=""
			else
				ss_link_qr
			fi
		fi
	else
		if [[ ${protocol_suffix} != "compatible" ]]; then
			ss_link=""
		else
			if [[ ${obfs_suffix} != "compatible" ]]; then
				if [[ ${obfs_suffix} = "plain" ]]; then
					ss_link_qr
				else
					ss_link=""
				fi
			else
				ss_link_qr
			fi
		fi
	fi
	ssr_link_qr
}
# Display configuration information
View_User(){
clear
	SSR_installation_status
	List_port_user
	while true
	do
		echo -e "Ingrese el puerto de usuario para ver la informacion\nde la cuenta completa"
msg -bar
		stty erase '^H' && read -p "(Predeterminado: cancelar):" View_user_port
		[[ -z "${View_user_port}" ]] && echo -e "Cancelado ...\n$(msg -bar)" && exit 1
		View_user=$(cat "${config_user_mudb_file}"|grep '"port": '"${View_user_port}"',')
		if [[ ! -z ${View_user} ]]; then
			Get_User_info "${View_user_port}"
			View_User_info
			break
		else
			echo -e "${Error} Por favor ingrese el puerto correcto !"
		fi
	done
#read -p "Enter para continuar" enter
}
View_User_info(){
	ip=$(cat ${config_user_api_file}|grep "SERVER_PUB_ADDR = "|awk -F "[']" '{print $2}')
	[[ -z "${ip}" ]] && Get_IP
	ss_ssr_determine
	clear 
	echo -e " Usuario [{user_name}] Informacion de Cuenta:"
msg -bar
    echo -e " PANEL VPS-MX By @Kalix1"
	
	echo -e " IP : ${Green_font_prefix}${ip}${Font_color_suffix}"

	echo -e " Puerto : ${Green_font_prefix}${port}${Font_color_suffix}"

	echo -e " Contraseña : ${Green_font_prefix}${password}${Font_color_suffix}"

	echo -e " Encriptacion : ${Green_font_prefix}${method}${Font_color_suffix}"

	echo -e " Protocol : ${Red_font_prefix}${protocol}${Font_color_suffix}"

	echo -e " Obfs : ${Red_font_prefix}${obfs}${Font_color_suffix}"

	echo -e " Limite de dispositivos: ${Green_font_prefix}${protocol_param}${Font_color_suffix}"

	echo -e " Velocidad de subproceso Unico: ${Green_font_prefix}${speed_limit_per_con} KB/S${Font_color_suffix}"

	echo -e " Velocidad Maxima del Usuario: ${Green_font_prefix}${speed_limit_per_user} KB/S${Font_color_suffix}"

	echo -e " Puertos Prohibido: ${Green_font_prefix}${forbidden_port} ${Font_color_suffix}"

	echo -e " Consumo de sus Datos:\n Carga: ${Green_font_prefix}${u}${Font_color_suffix} + Descarga: ${Green_font_prefix}${d}${Font_color_suffix} = ${Green_font_prefix}${transfer_enable_Used_2}${Font_color_suffix}"
	
         echo -e " Trafico Restante: ${Green_font_prefix}${transfer_enable_Used} ${Font_color_suffix}"
msg -bar
	echo -e " Trafico Total del Usuario: ${Green_font_prefix}${transfer_enable} ${Font_color_suffix}"
msg -bar
	echo -e "${ss_link}"
msg -bar
	echo -e "${ssr_link}"
msg -bar
	echo -e " ${Green_font_prefix} Nota: ${Font_color_suffix}
 En el navegador, abra el enlace del codigo QR, puede\n ver la imagen del codigo QR."
msg -bar
}
#Configuracion de la informacion de configuracion
Set_config_user(){
msg -bar
	echo -ne "\e[92m 1) Ingrese un nombre al usuario que desea Configurar\n (No repetir, o se marcara incorrectamente!)\n"
msg -bar
	stty erase '^H' && read -p "(Predeterminado: VPS-MX):" ssr_user
	[[ -z "${ssr_user}" ]] && ssr_user="VPS-MX"
	echo && echo -e "	Nombre de usuario : ${Green_font_prefix}${ssr_user}${Font_color_suffix}" && echo
}
Set_config_port(){
msg -bar
	while true
	do
	echo -e "\e[92m 2) Por favor ingrese un Puerto para el Usuario "
msg -bar
	stty erase '^H' && read -p "(Predeterminado: 2525):" ssr_port
	[[ -z "$ssr_port" ]] && ssr_port="2525"
	expr ${ssr_port} + 0 &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_port} -ge 1 ]] && [[ ${ssr_port} -le 65535 ]]; then
			echo && echo -e "	Port : ${Green_font_prefix}${ssr_port}${Font_color_suffix}" && echo
			break
		else
			echo -e "${Error} Por favor ingrese el numero correcto (1-65535)"
		fi
	else
		echo -e "${Error} Por favor ingrese el numero correcto (1-65535)"
	fi
	done
}
Set_config_password(){
msg -bar
	echo -e "\e[92m 3) Por favor ingrese una contrasena para el Usuario"
msg -bar
	stty erase '^H' && read -p "(Predeterminado: VPS-MX):" ssr_password
	[[ -z "${ssr_password}" ]] && ssr_password="VPS-MX"
	echo && echo -e "	contrasena : ${Green_font_prefix}${ssr_password}${Font_color_suffix}" && echo
}
Set_config_method(){
msg -bar
	echo -e "\e[92m 4) Seleccione tipo de Encriptacion para el Usuario\e[0m
$(msg -bar)
 ${Green_font_prefix} 1.${Font_color_suffix} Ninguno
 ${Green_font_prefix} 2.${Font_color_suffix} rc4
 ${Green_font_prefix} 3.${Font_color_suffix} rc4-md5
 ${Green_font_prefix} 4.${Font_color_suffix} rc4-md5-6
 ${Green_font_prefix} 5.${Font_color_suffix} aes-128-ctr
 ${Green_font_prefix} 6.${Font_color_suffix} aes-192-ctr
 ${Green_font_prefix} 7.${Font_color_suffix} aes-256-ctr
 ${Green_font_prefix} 8.${Font_color_suffix} aes-128-cfb
 ${Green_font_prefix} 9.${Font_color_suffix} aes-192-cfb
 ${Green_font_prefix}10.${Font_color_suffix} aes-256-cfb
 ${Green_font_prefix}11.${Font_color_suffix} aes-128-cfb8
 ${Green_font_prefix}12.${Font_color_suffix} aes-192-cfb8
 ${Green_font_prefix}13.${Font_color_suffix} aes-256-cfb8
 ${Green_font_prefix}14.${Font_color_suffix} salsa20
 ${Green_font_prefix}15.${Font_color_suffix} chacha20
 ${Green_font_prefix}16.${Font_color_suffix} chacha20-ietf
 
 ${Red_font_prefix}17.${Font_color_suffix} xsalsa20
 ${Red_font_prefix}18.${Font_color_suffix} xchacha20
$(msg -bar)
 ${Tip} Para salsa20/chacha20-*:\n Porfavor instale libsodium:\n Opcion 4 en menu principal SSRR"
msg -bar
	stty erase '^H' && read -p "(Predeterminado: 16. chacha20-ietf):" ssr_method
msg -bar
	[[ -z "${ssr_method}" ]] && ssr_method="16"
	if [[ ${ssr_method} == "1" ]]; then
		ssr_method="Ninguno"
	elif [[ ${ssr_method} == "2" ]]; then
		ssr_method="rc4"
	elif [[ ${ssr_method} == "3" ]]; then
		ssr_method="rc4-md5"
	elif [[ ${ssr_method} == "4" ]]; then
		ssr_method="rc4-md5-6"
	elif [[ ${ssr_method} == "5" ]]; then
		ssr_method="aes-128-ctr"
	elif [[ ${ssr_method} == "6" ]]; then
		ssr_method="aes-192-ctr"
	elif [[ ${ssr_method} == "7" ]]; then
		ssr_method="aes-256-ctr"
	elif [[ ${ssr_method} == "8" ]]; then
		ssr_method="aes-128-cfb"
	elif [[ ${ssr_method} == "9" ]]; then
		ssr_method="aes-192-cfb"
	elif [[ ${ssr_method} == "10" ]]; then
		ssr_method="aes-256-cfb"
	elif [[ ${ssr_method} == "11" ]]; then
		ssr_method="aes-128-cfb8"
	elif [[ ${ssr_method} == "12" ]]; then
		ssr_method="aes-192-cfb8"
	elif [[ ${ssr_method} == "13" ]]; then
		ssr_method="aes-256-cfb8"
	elif [[ ${ssr_method} == "14" ]]; then
		ssr_method="salsa20"
	elif [[ ${ssr_method} == "15" ]]; then
		ssr_method="chacha20"
	elif [[ ${ssr_method} == "16" ]]; then
		ssr_method="chacha20-ietf"
	elif [[ ${ssr_method} == "17" ]]; then
		ssr_method="xsalsa20"
	elif [[ ${ssr_method} == "18" ]]; then
		ssr_method="xchacha20"
	else
		ssr_method="aes-256-cfb"
	fi
	echo && echo -e "	Encriptacion: ${Green_font_prefix}${ssr_method}${Font_color_suffix}" && echo
}
Set_config_protocol(){
msg -bar
	echo -e "\e[92m 5) Por favor, seleccione un Protocolo
$(msg -bar)
 ${Green_font_prefix}1.${Font_color_suffix} origin
 ${Green_font_prefix}2.${Font_color_suffix} auth_sha1_v4
 ${Green_font_prefix}3.${Font_color_suffix} auth_aes128_md5
 ${Green_font_prefix}4.${Font_color_suffix} auth_aes128_sha1
 ${Green_font_prefix}5.${Font_color_suffix} auth_chain_a
 ${Green_font_prefix}6.${Font_color_suffix} auth_chain_b

 ${Red_font_prefix}7.${Font_color_suffix} auth_chain_c
 ${Red_font_prefix}8.${Font_color_suffix} auth_chain_d
 ${Red_font_prefix}9.${Font_color_suffix} auth_chain_e
 ${Red_font_prefix}10.${Font_color_suffix} auth_chain_f
$(msg -bar)
 ${Tip}\n Si selecciona el protocolo de serie auth_chain_ *:\n Se recomienda establecer el metodo de cifrado en ninguno"
msg -bar
	stty erase '^H' && read -p "(Predterminado: 1. origin):" ssr_protocol
msg -bar
	[[ -z "${ssr_protocol}" ]] && ssr_protocol="1"
	if [[ ${ssr_protocol} == "1" ]]; then
		ssr_protocol="origin"
	elif [[ ${ssr_protocol} == "2" ]]; then
		ssr_protocol="auth_sha1_v4"
	elif [[ ${ssr_protocol} == "3" ]]; then
		ssr_protocol="auth_aes128_md5"
	elif [[ ${ssr_protocol} == "4" ]]; then
		ssr_protocol="auth_aes128_sha1"
	elif [[ ${ssr_protocol} == "5" ]]; then
		ssr_protocol="auth_chain_a"
	elif [[ ${ssr_protocol} == "6" ]]; then
		ssr_protocol="auth_chain_b"
	elif [[ ${ssr_protocol} == "7" ]]; then
		ssr_protocol="auth_chain_c"
	elif [[ ${ssr_protocol} == "8" ]]; then
		ssr_protocol="auth_chain_d"
	elif [[ ${ssr_protocol} == "9" ]]; then
		ssr_protocol="auth_chain_e"
	elif [[ ${ssr_protocol} == "10" ]]; then
		ssr_protocol="auth_chain_f"
	else
		ssr_protocol="origin"
	fi
	echo && echo -e "	Protocolo : ${Green_font_prefix}${ssr_protocol}${Font_color_suffix}" && echo
	if [[ ${ssr_protocol} != "origin" ]]; then
		if [[ ${ssr_protocol} == "auth_sha1_v4" ]]; then
			stty erase '^H' && read -p "Set protocol plug-in to compatible mode(_compatible)?[Y/n]" ssr_protocol_yn
			[[ -z "${ssr_protocol_yn}" ]] && ssr_protocol_yn="y"
			[[ $ssr_protocol_yn == [Yy] ]] && ssr_protocol=${ssr_protocol}"_compatible"
			echo
		fi
	fi
}
Set_config_obfs(){
msg -bar
	echo -e "\e[92m 6) Por favor, seleccione el metodo OBFS
$(msg -bar)
 ${Green_font_prefix}1.${Font_color_suffix} plain
 ${Green_font_prefix}2.${Font_color_suffix} http_simple
 ${Green_font_prefix}3.${Font_color_suffix} http_post
 ${Green_font_prefix}4.${Font_color_suffix} random_head
 ${Green_font_prefix}5.${Font_color_suffix} tls1.2_ticket_auth
$(msg -bar)
  Si elige tls1.2_ticket_auth, entonces el cliente puede\n  elegir tls1.2_ticket_fastauth!"
msg -bar
	stty erase '^H' && read -p "(Predeterminado: 5. tls1.2_ticket_auth):" ssr_obfs
	[[ -z "${ssr_obfs}" ]] && ssr_obfs="5"
	if [[ ${ssr_obfs} == "1" ]]; then
		ssr_obfs="plain"
	elif [[ ${ssr_obfs} == "2" ]]; then
		ssr_obfs="http_simple"
	elif [[ ${ssr_obfs} == "3" ]]; then
		ssr_obfs="http_post"
	elif [[ ${ssr_obfs} == "4" ]]; then
		ssr_obfs="random_head"
	elif [[ ${ssr_obfs} == "5" ]]; then
		ssr_obfs="tls1.2_ticket_auth"
	else
		ssr_obfs="tls1.2_ticket_auth"
	fi
	echo && echo -e "	obfs : ${Green_font_prefix}${ssr_obfs}${Font_color_suffix}" && echo
	msg -bar
	if [[ ${ssr_obfs} != "plain" ]]; then
			stty erase '^H' && read -p "Configurar modo Compatible (Para usar SS)? [y/n]: " ssr_obfs_yn
			[[ -z "${ssr_obfs_yn}" ]] && ssr_obfs_yn="y"
			[[ $ssr_obfs_yn == [Yy] ]] && ssr_obfs=${ssr_obfs}"_compatible"
	fi
}
Set_config_protocol_param(){
msg -bar
	while true
	do
	echo -e "\e[92m 7) Limitar Cantidad de Dispositivos Simultaneos\n  ${Green_font_prefix} auth_*La serie no es compatible con la version original. ${Font_color_suffix}"
msg -bar
	echo -e "${Tip} Limite de numero de dispositivos:\n Es el numero de clientes que usaran la cuenta\n el minimo recomendado 2."
msg -bar
	stty erase '^H' && read -p "(Predeterminado: Ilimitado):" ssr_protocol_param
	[[ -z "$ssr_protocol_param" ]] && ssr_protocol_param="" && echo && break
	expr ${ssr_protocol_param} + 0 &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_protocol_param} -ge 1 ]] && [[ ${ssr_protocol_param} -le 9999 ]]; then
			echo && echo -e "	Limite del dispositivo: ${Green_font_prefix}${ssr_protocol_param}${Font_color_suffix}" && echo
			break
		else
			echo -e "${Error} Por favor ingrese el numero correcto (1-9999)"
		fi
	else
		echo -e "${Error} Por favor ingrese el numero correcto (1-9999)"
	fi
	done
}
Set_config_speed_limit_per_con(){
msg -bar
	while true
	do
	echo -e "\e[92m 8) Introduzca un Limite de Velocidad x Hilo (en KB/S)"
msg -bar
	stty erase '^H' && read -p "(Predterminado: Ilimitado):" ssr_speed_limit_per_con
msg -bar
	[[ -z "$ssr_speed_limit_per_con" ]] && ssr_speed_limit_per_con=0 && echo && break
	expr ${ssr_speed_limit_per_con} + 0 &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_speed_limit_per_con} -ge 1 ]] && [[ ${ssr_speed_limit_per_con} -le 131072 ]]; then
			echo && echo -e "	Velocidad de Subproceso Unico: ${Green_font_prefix}${ssr_speed_limit_per_con} KB/S${Font_color_suffix}" && echo
			break
		else
			echo -e "${Error} Por favor ingrese el numero correcto (1-131072)"
		fi
	else
		echo -e "${Error} Por favor ingrese el numero correcto (1-131072)"
	fi
	done
}
Set_config_speed_limit_per_user(){
msg -bar
	while true
	do
	echo -e "\e[92m 9) Introduzca un Limite de Velocidad Maxima (en KB/S)"
msg -bar
	echo -e "${Tip} Limite de Velocidad Maxima del Puerto :\n Es la velocidad maxima que ira el Usuario."
msg -bar
	stty erase '^H' && read -p "(Predeterminado: Ilimitado):" ssr_speed_limit_per_user
	[[ -z "$ssr_speed_limit_per_user" ]] && ssr_speed_limit_per_user=0 && echo && break
	expr ${ssr_speed_limit_per_user} + 0 &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_speed_limit_per_user} -ge 1 ]] && [[ ${ssr_speed_limit_per_user} -le 131072 ]]; then
			echo && echo -e "	Velocidad Maxima del Usuario : ${Green_font_prefix}${ssr_speed_limit_per_user} KB/S${Font_color_suffix}" && echo
			break
		else
			echo -e "${Error} Por favor ingrese el numero correcto (1-131072)"
		fi
	else
		echo -e "${Error} Por favor ingrese el numero correcto (1-131072)"
	fi
	done
}
Set_config_transfer(){
msg -bar
	while true
	do
	echo -e "\e[92m 10) Ingrese Cantidad Total de Datos para el Usuario\n   (en GB, 1-838868 GB)"
msg -bar
	stty erase '^H' && read -p "(Predeterminado: Ilimitado):" ssr_transfer
	[[ -z "$ssr_transfer" ]] && ssr_transfer="838868" && echo && break
	expr ${ssr_transfer} + 0 &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_transfer} -ge 1 ]] && [[ ${ssr_transfer} -le 838868 ]]; then
			echo && echo -e "	Trafico Total Para El Usuario: ${Green_font_prefix}${ssr_transfer} GB${Font_color_suffix}" && echo
			break
		else
			echo -e "${Error} Por favor ingrese el numero correcto (1-838868)"
		fi
	else
		echo -e "${Error} Por favor ingrese el numero correcto (1-838868)"
	fi
	done
}
Set_config_forbid(){
msg -bar
	echo "PROIBIR PUERTOS"
msg -bar
	echo -e "${Tip} Puertos prohibidos:\n Por ejemplo, si no permite el acceso al puerto 25, los\n usuarios no podran acceder al puerto de correo 25 a\n traves del proxy de SSR. Si 80,443 esta desactivado,\n los usuarios no podran acceda a los sitios\n http/https normalmente."
msg -bar
	stty erase '^H' && read -p "(Predeterminado: permitir todo):" ssr_forbid
	[[ -z "${ssr_forbid}" ]] && ssr_forbid=""
	echo && echo -e "	Puerto prohibido: ${Green_font_prefix}${ssr_forbid}${Font_color_suffix}" && echo
}
Set_config_enable(){
	user_total=$(expr ${user_total} - 1)
	for((integer = 0; integer <= ${user_total}; integer++))
	do
		echo -e "integer=${integer}"
		port_jq=$(${jq_file} ".[${integer}].port" "${config_user_mudb_file}")
		echo -e "port_jq=${port_jq}"
		if [[ "${ssr_port}" == "${port_jq}" ]]; then
			enable=$(${jq_file} ".[${integer}].enable" "${config_user_mudb_file}")
			echo -e "enable=${enable}"
			[[ "${enable}" == "null" ]] && echo -e "${Error} Obtenga el puerto actual [${ssr_port}] Estado deshabilitado fallido!" && exit 1
			ssr_port_num=$(cat "${config_user_mudb_file}"|grep -n '"puerto": '${ssr_port}','|awk -F ":" '{print $1}')
			echo -e "ssr_port_num=${ssr_port_num}"
			[[ "${ssr_port_num}" == "null" ]] && echo -e "${Error}Obtener actual Puerto [${ssr_port}] Numero de filas fallidas!" && exit 1
			ssr_enable_num=$(expr ${ssr_port_num} - 5)
			echo -e "ssr_enable_num=${ssr_enable_num}"
			break
		fi
	done
	if [[ "${enable}" == "1" ]]; then
		echo -e "Puerto [${ssr_port}] El estado de la cuenta es: ${Green_font_prefix}Enabled ${Font_color_suffix} , Cambiar a ${Red_font_prefix}Disabled${Font_color_suffix} ?[Y/n]"
		stty erase '^H' && read -p "(Predeterminado: Y):" ssr_enable_yn
		[[ -z "${ssr_enable_yn}" ]] && ssr_enable_yn="y"
		if [[ "${ssr_enable_yn}" == [Yy] ]]; then
			ssr_enable="0"
		else
			echo -e "Cancelado...\n$(msg -bar)" && exit 0
		fi
	elif [[ "${enable}" == "0" ]]; then
		echo -e "Port [${ssr_port}] El estado de la cuenta:${Green_font_prefix}Habilitado ${Font_color_suffix} , Cambie a ${Red_font_prefix}Deshabilitado${Font_color_suffix} ?[Y/n]"
		stty erase '^H' && read -p "(Predeterminado: Y):" ssr_enable_yn
		[[ -z "${ssr_enable_yn}" ]] && ssr_enable_yn = "y"
		if [[ "${ssr_enable_yn}" == [Yy] ]]; then
			ssr_enable="1"
		else
			echo "Cancelar ..." && exit 0
		fi
	else
		echo -e "${Error} El actual estado de discapacidad de Puerto es anormal.[${enable}] !" && exit 1
	fi
}
Set_user_api_server_pub_addr(){
	addr=$1
	if [[ "${addr}" == "Modify" ]]; then
		server_pub_addr=$(cat ${config_user_api_file}|grep "SERVER_PUB_ADDR = "|awk -F "[']" '{print $2}')
		if [[ -z ${server_pub_addr} ]]; then
			echo -e "${Error} La IP del servidor o el nombre de dominio obtenidos fallaron!" && exit 1
		else
			echo -e "${Info} La IP del servidor o el nombre de dominio actualmente configurados es ${Green_font_prefix}${server_pub_addr}${Font_color_suffix}"
		fi
	fi
	echo "Introduzca la IP del servidor o el nombre de dominio que se mostrara en la configuracion del usuario (cuando el servidor tiene varias IP, puede especificar la IP o el nombre de dominio que se muestra en la configuracion del usuario)"
msg -bar
	stty erase '^H' && read -p "(Predeterminado:Deteccion automatica de la red externa IP):" ssr_server_pub_addr
	if [[ -z "${ssr_server_pub_addr}" ]]; then
		Get_IP
		if [[ ${ip} == "VPS_IP" ]]; then
			while true
			do
			stty erase '^H' && read -p "${Error} La deteccion automatica de la IP de la red externa fallo, ingrese manualmente la IP del servidor o el nombre de dominio" ssr_server_pub_addr
			if [[ -z "$ssr_server_pub_addr" ]]; then
				echo -e "${Error}No puede estar vacio!"
			else
				break
			fi
			done
		else
			ssr_server_pub_addr="${ip}"
		fi
	fi
	echo && msg -bar && echo -e "	IP o nombre de dominio: ${Green_font_prefix}${ssr_server_pub_addr}${Font_color_suffix}" && msg -bar && echo
}
Set_config_all(){
	lal=$1
	if [[ "${lal}" == "Modify" ]]; then
		Set_config_password
		Set_config_method
		Set_config_protocol
		Set_config_obfs
		Set_config_protocol_param
		Set_config_speed_limit_per_con
		Set_config_speed_limit_per_user
		Set_config_transfer
		Set_config_forbid
	else
		Set_config_user
		Set_config_port
		Set_config_password
		Set_config_method
		Set_config_protocol
		Set_config_obfs
		Set_config_protocol_param
		Set_config_speed_limit_per_con
		Set_config_speed_limit_per_user
		Set_config_transfer
		Set_config_forbid
	fi
}
#Modificar la informaci�n de configuraci�n
Modify_config_password(){
	match_edit=$(python mujson_mgr.py -e -p "${ssr_port}" -k "${ssr_password}"|grep -w "edit user ")
	if [[ -z "${match_edit}" ]]; then
		echo -e "${Error} Fallo la modificacion de la contrasena del usuario ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} La contrasena del usuario se modifico correctamente ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} (Puede tardar unos 10 segundos aplicar la ultima configuracion)"
	fi
}
Modify_config_method(){
	match_edit=$(python mujson_mgr.py -e -p "${ssr_port}" -m "${ssr_method}"|grep -w "edit user ")
	if [[ -z "${match_edit}" ]]; then
		echo -e "${Error} La modificacion del metodo de cifrado del usuario fallo ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Modo de cifrado de usuario ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} (Note: Nota: la configuracion mas reciente puede demorar unos 10 segundos)"
	fi
}
Modify_config_protocol(){
	match_edit=$(python mujson_mgr.py -e -p "${ssr_port}" -O "${ssr_protocol}"|grep -w "edit user ")
	if [[ -z "${match_edit}" ]]; then
		echo -e "${Error} Fallo la modificacion del protocolo de usuario ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Acuerdo de usuario modificacion exito ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} (Nota: la configuracion m�s reciente puede demorar unos 10 segundos)"
	fi
}
Modify_config_obfs(){
	match_edit=$(python mujson_mgr.py -e -p "${ssr_port}" -o "${ssr_obfs}"|grep -w "edit user ")
	if [[ -z "${match_edit}" ]]; then
		echo -e "${Error} La modificacion de la confusion del usuario fallo ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Confusion del usuario exito de modificacion ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} (Nota: La aplicacion de la ultima configuracion puede demorar unos 10 segundos)"
	fi
}
Modify_config_protocol_param(){
	match_edit=$(python mujson_mgr.py -e -p "${ssr_port}" -G "${ssr_protocol_param}"|grep -w "edit user ")
	if [[ -z "${match_edit}" ]]; then
		echo -e "${Error} Fallo la modificacion del parametro del protocolo del usuario (numero de dispositivos limite) ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Parametros de negociaci�n del usuario (numero de dispositivos limite) modificados correctamente ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} (Nota: puede tomar aproximadamente 10 segundos aplicar la ultima configuracion)"
	fi
}
Modify_config_speed_limit_per_con(){
	match_edit=$(python mujson_mgr.py -e -p "${ssr_port}" -s "${ssr_speed_limit_per_con}"|grep -w "edit user ")
	if [[ -z "${match_edit}" ]]; then
		echo -e "${Error} Fallo la modificacion de la velocidad de un solo hilo ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Modificacion de la velocidad de un solo hilo exitosa ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} (Nota: puede tomar aproximadamente 10 segundos aplicar la ultima configuracion)"
	fi
}
Modify_config_speed_limit_per_user(){
	match_edit=$(python mujson_mgr.py -e -p "${ssr_port}" -S "${ssr_speed_limit_per_user}"|grep -w "edit user ")
	if [[ -z "${match_edit}" ]]; then
		echo -e "${Error} Usuario Puerto la modificaci�n del limite de velocidad total fallo ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Usuario Puerto limite de velocidad total modificado con exito ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} (Nota: la configuracion mas reciente puede demorar unos 10 segundos)"
	fi
}
Modify_config_connect_verbose_info(){
	sed -i 's/"connect_verbose_info": '"$(echo ${connect_verbose_info})"',/"connect_verbose_info": '"$(echo ${ssr_connect_verbose_info})"',/g' ${config_user_file}
}
Modify_config_transfer(){
	match_edit=$(python mujson_mgr.py -e -p "${ssr_port}" -t "${ssr_transfer}"|grep -w "edit user ")
	if [[ -z "${match_edit}" ]]; then
		echo -e "${Error} La modificacion de trafico total del usuario fallo ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Trafico total del usuario ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} (Nota: la configuracion mas reciente puede demorar unos 10 segundos)"
	fi
}
Modify_config_forbid(){
	match_edit=$(python mujson_mgr.py -e -p "${ssr_port}" -f "${ssr_forbid}"|grep -w "edit user ")
	if [[ -z "${match_edit}" ]]; then
		echo -e "${Error} La modificacion del puerto prohibido por el usuario ha fallado ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Los puertos prohibidos por el usuario se modificaron correctamente ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} (Nota: puede tomar aproximadamente 10 segundos aplicar la ultima configuracion)"
	fi
}
Modify_config_enable(){
	sed -i "${ssr_enable_num}"'s/"enable": '"$(echo ${enable})"',/"enable": '"$(echo ${ssr_enable})"',/' ${config_user_mudb_file}
}
Modify_user_api_server_pub_addr(){
	sed -i "s/SERVER_PUB_ADDR = '${server_pub_addr}'/SERVER_PUB_ADDR = '${ssr_server_pub_addr}'/" ${config_user_api_file}
}
Modify_config_all(){
	Modify_config_password
	Modify_config_method
	Modify_config_protocol
	Modify_config_obfs
	Modify_config_protocol_param
	Modify_config_speed_limit_per_con
	Modify_config_speed_limit_per_user
	Modify_config_transfer
	Modify_config_forbid
}
Check_python(){
	python_ver=`python -h`
	if [[ -z ${python_ver} ]]; then
		echo -e "${Info} No instalo Python, comience a instalar ..."
		if [[ ${release} == "centos" ]]; then
			yum install -y python
		else
			apt-get install -y python
		fi
	fi
}
Centos_yum(){
	yum update
	cat /etc/redhat-release |grep 7\..*|grep -i centos>/dev/null
	if [[ $? = 0 ]]; then
		yum install -y vim unzip crond net-tools git
	else
		yum install -y vim unzip crond git
	fi
}
Debian_apt(){
	apt-get update
	apt-get install -y vim unzip cron git net-tools
}
#Descargar ShadowsocksR
Download_SSR(){
	cd "/usr/local"
	# wget -N --no-check-certificate "https://github.com/ToyoDAdoubi/shadowsocksr/archive/manyuser.zip"
	#git config --global http.sslVerify false
	git clone -b akkariiin/master https://github.com/shadowsocksrr/shadowsocksr.git
	[[ ! -e ${ssr_folder} ]] && echo -e "${Error} Fallo la descarga del servidor ShadowsocksR!" && exit 1
	# [[ ! -e "manyuser.zip" ]] && echo -e "${Error} Fallo la descarga del paquete de compresion lateral ShadowsocksR !" && rm -rf manyuser.zip && exit 1
	# unzip "manyuser.zip"
	# [[ ! -e "/usr/local/shadowsocksr-manyuser/" ]] && echo -e "${Error} Fallo la descompresi�n del servidor ShadowsocksR !" && rm -rf manyuser.zip && exit 1
	# mv "/usr/local/shadowsocksr-manyuser/" "/usr/local/shadowsocksr/"
	# [[ ! -e "/usr/local/shadowsocksr/" ]] && echo -e "${Error} Fallo el cambio de nombre del servidor ShadowsocksR!" && rm -rf manyuser.zip && rm -rf "/usr/local/shadowsocksr-manyuser/" && exit 1
	# rm -rf manyuser.zip
	cd "shadowsocksr"
	cp "${ssr_folder}/config.json" "${config_user_file}"
	cp "${ssr_folder}/mysql.json" "${ssr_folder}/usermysql.json"
	cp "${ssr_folder}/apiconfig.py" "${config_user_api_file}"
	[[ ! -e ${config_user_api_file} ]] && echo -e "${Error} Fallo la replicacion apiconfig.py del servidor ShadowsocksR!" && exit 1
	sed -i "s/API_INTERFACE = 'sspanelv2'/API_INTERFACE = 'mudbjson'/" ${config_user_api_file}
	server_pub_addr="127.0.0.1"
	Modify_user_api_server_pub_addr
	#sed -i "s/SERVER_PUB_ADDR = '127.0.0.1'/SERVER_PUB_ADDR = '${ip}'/" ${config_user_api_file}
	sed -i 's/ \/\/ only works under multi-user mode//g' "${config_user_file}"
	echo -e "${Info} Descarga del servidor ShadowsocksR completa!"
}
Service_SSR(){
	if [[ ${release} = "centos" ]]; then
		if ! wget --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/service/ssrmu_centos -O /etc/init.d/ssrmu; then
			echo -e "${Error} Fallo la descarga de la secuencia de comandos de administracion de servicios de ShadowsocksR!" && exit 1
		fi
		chmod +x /etc/init.d/ssrmu
		chkconfig --add ssrmu
		chkconfig ssrmu on
	else
		if ! wget --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/service/ssrmu_debian -O /etc/init.d/ssrmu; then
			echo -e "${Error} Fallo la descarga de la secuencia de comandos de administraci�n de servicio de ShadowsocksR!" && exit 1
		fi
		chmod +x /etc/init.d/ssrmu
		update-rc.d -f ssrmu defaults
	fi
	echo -e "${Info} ShadowsocksR Service Management Script Descargar Descargar!"
}
#Instalar el analizador JQ
JQ_install(){
	if [[ ! -e ${jq_file} ]]; then
		cd "${ssr_folder}"
		if [[ ${bit} = "x86_64" ]]; then
			# mv "jq-linux64" "jq"
			wget --no-check-certificate "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64" -O ${jq_file}
		else
			# mv "jq-linux32" "jq"
			wget --no-check-certificate "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux32" -O ${jq_file}
		fi
		[[ ! -e ${jq_file} ]] && echo -e "${Error} JQ parser, por favor!" && exit 1
		chmod +x ${jq_file}
		echo -e "${Info} La instalacion del analizador JQ se ha completado, continuar ..." 
	else
		echo -e "${Info} JQ parser esta instalado, continuar ..."
	fi
}
#Instalacion
Installation_dependency(){
	if [[ ${release} == "centos" ]]; then
		Centos_yum
	else
		Debian_apt
	fi
	[[ ! -e "/usr/bin/unzip" ]] && echo -e "${Error} Dependiente de la instalacion de descomprimir (paquete comprimido) fallo, en su mayoria problema, por favor verifique!" && exit 1
	Check_python
	#echo "nameserver 8.8.8.8" > /etc/resolv.conf
	#echo "nameserver 8.8.4.4" >> /etc/resolv.conf
	cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	if [[ ${release} == "centos" ]]; then
		/etc/init.d/crond restart
	else
		/etc/init.d/cron restart
	fi
}
Install_SSR(){
clear
	check_root
	msg -bar
	[[ -e ${ssr_folder} ]] && echo -e "${Error}\nLa carpeta ShadowsocksR ha sido creada, por favor verifique\n(si la instalacion falla, desinstalela primero) !\n$(msg -bar)" && exit 1 
	echo -e "${Info}\nComience la configuracion de la cuenta de ShadowsocksR..."
msg -bar
	Set_user_api_server_pub_addr
	Set_config_all
	echo -e "${Info} Comience a instalar / configurar las dependencias de ShadowsocksR ..."
	Installation_dependency
	echo -e "${Info} Iniciar descarga / Instalar ShadowsocksR File ..."
	Download_SSR
	echo -e "${Info} Iniciar descarga / Instalar ShadowsocksR Service Script(init)..."
	Service_SSR
	echo -e "${Info} Iniciar descarga / instalar JSNO Parser JQ ..."
	JQ_install
	echo -e "${Info} Comience a agregar usuario inicial ..."
	Add_port_user "install"
	echo -e "${Info} Empezar a configurar el firewall de iptables ..."
	Set_iptables
	echo -e "${Info} Comience a agregar reglas de firewall de iptables ..."
	Add_iptables
	echo -e "${Info} Comience a guardar las reglas del servidor de seguridad de iptables ..."
	Save_iptables
	echo -e "${Info} Todos los pasos para iniciar el servicio ShadowsocksR ..."
	Start_SSR
	Get_User_info "${ssr_port}"
	View_User_info

}
Update_SSR(){
	SSR_installation_status
	# echo -e "Debido a que el beb� roto actualiza el servidor ShadowsocksR, entonces."
	cd ${ssr_folder}
	git pull
	Restart_SSR

}
Uninstall_SSR(){
	[[ ! -e ${ssr_folder} ]] && echo -e "${Error} ShadowsocksR no esta instalado, por favor, compruebe!\n$(msg -bar)" && exit 1
	echo "Desinstalar ShadowsocksR [y/n]"
msg -bar 
	stty erase '^H' && read -p "(Predeterminado: n):" unyn
msg -bar
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		check_pid
		[[ ! -z "${PID}" ]] && kill -9 ${PID}
		user_info=$(python mujson_mgr.py -l)
		user_total=$(echo "${user_info}"|wc -l)
		if [[ ! -z ${user_info} ]]; then
			for((integer = 1; integer <= ${user_total}; integer++))
			do
				port=$(echo "${user_info}"|sed -n "${integer}p"|awk '{print $4}')
				Del_iptables
			done
		fi
		if [[ ${release} = "centos" ]]; then
			chkconfig --del ssrmu
		else
			update-rc.d -f ssrmu remove
		fi
		rm -rf ${ssr_folder} && rm -rf /etc/init.d/ssrmu
		echo && echo " Desinstalacion de ShadowsocksR completada!" && echo
	else
		echo && echo "Desinstalar cancelado ..." && echo
	fi

}
Check_Libsodium_ver(){
	echo -e "${Info} Descargando la ultima version de libsodium"
	#Libsodiumr_ver=$(wget -qO- "https://github.com/jedisct1/libsodium/tags"|grep "/jedisct1/libsodium/releases/tag/"|head -1|sed -r 's/.*tag\/(.+)\">.*/\1/')
	Libsodiumr_ver=1.0.17
	[[ -z ${Libsodiumr_ver} ]] && Libsodiumr_ver=${Libsodiumr_ver_backup}
	echo -e "${Info} La ultima version de libsodium es ${Green_font_prefix}${Libsodiumr_ver}${Font_color_suffix} !"
}
Install_Libsodium(){
	if [[ -e ${Libsodiumr_file} ]]; then
		echo -e "${Error} libsodium ya instalado, quieres actualizar?[y/N]"
		stty erase '^H' && read -p "(Default: n):" yn
		[[ -z ${yn} ]] && yn="n"
		if [[ ${yn} == [Nn] ]]; then
			echo -e "Cancelado...\n$(msg -bar)" && exit 1
		fi
	else
		echo -e "${Info} libsodium no instalado, instalacion iniciada ..."
	fi
	Check_Libsodium_ver
	if [[ ${release} == "centos" ]]; then
		yum -y actualizacion
		echo -e "${Info} La instalacion depende de ..."
		yum -y groupinstall "Herramientas de desarrollo"
		echo -e "${Info} Descargar ..."
		wget  --no-check-certificate -N "https://github.com/jedisct1/libsodium/releases/download/${Libsodiumr_ver}/libsodium-${Libsodiumr_ver}.tar.gz"
		echo -e "${Info} Descomprimir ..."
		tar -xzf libsodium-${Libsodiumr_ver}.tar.gz && cd libsodium-${Libsodiumr_ver}
		echo -e "${Info} Compilar e instalar ..."
		./configure --disable-maintainer-mode && make -j2 && make install
		echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	else
		apt-get update
		echo -e "${Info} La instalacion depende de ..."
		apt-get install -y build-essential
		echo -e "${Info} Descargar ..."
		wget  --no-check-certificate -N "https://github.com/jedisct1/libsodium/releases/download/${Libsodiumr_ver}/libsodium-${Libsodiumr_ver}.tar.gz"
		echo -e "${Info} Descomprimir ..."
		tar -xzf libsodium-${Libsodiumr_ver}.tar.gz && cd libsodium-${Libsodiumr_ver}
		echo -e "${Info} Compilar e instalar ..."
		./configure --disable-maintainer-mode && make -j2 && make install
	fi
	ldconfig
	cd .. && rm -rf libsodium-${Libsodiumr_ver}.tar.gz && rm -rf libsodium-${Libsodiumr_ver}
	[[ ! -e ${Libsodiumr_file} ]] && echo -e "${Error} libsodium Instalacion fallida!" && exit 1
	echo && echo -e "${Info} libsodium exito de instalacion!" && echo
msg -bar
}
#Mostrar informaci�n de conexi�n
debian_View_user_connection_info(){
	format_1=$1
	user_info=$(python mujson_mgr.py -l)
	user_total=$(echo "${user_info}"|wc -l)
	[[ -z ${user_info} ]] && echo -e "${Error} No encontro, por favor compruebe!" && exit 1
	IP_total=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp6' |awk '{print $5}' |awk -F ":" '{print $1}' |sort -u |wc -l`
	user_list_all=""
	for((integer = 1; integer <= ${user_total}; integer++))
	do
		user_port=$(echo "${user_info}"|sed -n "${integer}p"|awk '{print $4}')
		user_IP_1=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp6' |grep ":${user_port} " |awk '{print $5}' |awk -F ":" '{print $1}' |sort -u`
		if [[ -z ${user_IP_1} ]]; then
			user_IP_total="0"
		else
			user_IP_total=`echo -e "${user_IP_1}"|wc -l`
			if [[ ${format_1} == "IP_address" ]]; then
				get_IP_address
			else
				user_IP=`echo -e "\n${user_IP_1}"`
			fi
		fi
		user_list_all=${user_list_all}"Puerto: ${Green_font_prefix}"${user_port}"${Font_color_suffix}, El numero total de IPs vinculadas: ${Green_font_prefix}"${user_IP_total}"${Font_color_suffix}, Current linked IP: ${Green_font_prefix}${user_IP}${Font_color_suffix}\n"
		user_IP=""
	done
	echo -e "Numero total de usuarios: ${Green_background_prefix} "${user_total}" ${Font_color_suffix} Numero total de IPs vinculadas: ${Green_background_prefix} "${IP_total}" ${Font_color_suffix}\n"
	echo -e "${user_list_all}"
msg -bar 
}
centos_View_user_connection_info(){
	format_1=$1
	user_info=$(python mujson_mgr.py -l)
	user_total=$(echo "${user_info}"|wc -l)
	[[ -z ${user_info} ]] && echo -e "${Error} No encontrado, por favor revise!" && exit 1
	IP_total=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp' | grep '::ffff:' |awk '{print $5}' |awk -F ":" '{print $4}' |sort -u |wc -l`
	user_list_all=""
	for((integer = 1; integer <= ${user_total}; integer++))
	do
		user_port=$(echo "${user_info}"|sed -n "${integer}p"|awk '{print $4}')
		user_IP_1=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp' |grep ":${user_port} "|grep '::ffff:' |awk '{print $5}' |awk -F ":" '{print $4}' |sort -u`
		if [[ -z ${user_IP_1} ]]; then
			user_IP_total="0"
		else
			user_IP_total=`echo -e "${user_IP_1}"|wc -l`
			if [[ ${format_1} == "IP_address" ]]; then
				get_IP_address
			else
				user_IP=`echo -e "\n${user_IP_1}"`
			fi
		fi
		user_list_all=${user_list_all}"Puerto: ${Green_font_prefix}"${user_port}"${Font_color_suffix}, El numero total de IPs vinculadas: ${Green_font_prefix}"${user_IP_total}"${Font_color_suffix}, Current linked IP: ${Green_font_prefix}${user_IP}${Font_color_suffix}\n"
		user_IP=""
	done
	echo -e "El numero total de usuarios: ${Green_background_prefix} "${user_total}" ${Font_color_suffix} El numero total de IPs vinculadas: ${Green_background_prefix} "${IP_total}" ${Font_color_suffix} "
	echo -e "${user_list_all}"
}
View_user_connection_info(){
clear
	SSR_installation_status
	msg -bar
	 echo -e "Seleccione el formato para mostrar :
$(msg -bar)
 ${Green_font_prefix}1.${Font_color_suffix} Mostrar IP 

 ${Green_font_prefix}2.${Font_color_suffix} Mostrar IP + Resolver el nombre DNS"
msg -bar
	stty erase '^H' && read -p "(Predeterminado: 1):" ssr_connection_info
msg -bar
	[[ -z "${ssr_connection_info}" ]] && ssr_connection_info="1"
	if [[ ${ssr_connection_info} == "1" ]]; then
		View_user_connection_info_1 ""
	elif [[ ${ssr_connection_info} == "2" ]]; then
		echo -e "${Tip} Detectar IP (ipip.net)puede llevar mas tiempo si hay muchas IPs"
msg -bar
		View_user_connection_info_1 "IP_address"
	else
		echo -e "${Error} Ingrese el numero correcto(1-2)" && exit 1
	fi
}
View_user_connection_info_1(){
	format=$1
	if [[ ${release} = "centos" ]]; then
		cat /etc/redhat-release |grep 7\..*|grep -i centos>/dev/null
		if [[ $? = 0 ]]; then
			debian_View_user_connection_info "$format"
		else
			centos_View_user_connection_info "$format"
		fi
	else
		debian_View_user_connection_info "$format"
	fi
}
get_IP_address(){
	#echo "user_IP_1=${user_IP_1}"
	if [[ ! -z ${user_IP_1} ]]; then
	#echo "user_IP_total=${user_IP_total}"
		for((integer_1 = ${user_IP_total}; integer_1 >= 1; integer_1--))
		do
			IP=`echo "${user_IP_1}" |sed -n "$integer_1"p`
			#echo "IP=${IP}"
			IP_address=`wget -qO- -t1 -T2 http://freeapi.ipip.net/${IP}|sed 's/\"//g;s/,//g;s/\[//g;s/\]//g'`
			#echo "IP_address=${IP_address}"
			user_IP="${user_IP}\n${IP}(${IP_address})"
			#echo "user_IP=${user_IP}"
			sleep 1s
		done
	fi
}
#Modificar la configuraci�n del usuario
Modify_port(){
msg -bar
	List_port_user
	while true
	do
		echo -e "Por favor ingrese el usuario (Puerto) que tiene que ser modificado" 
msg -bar
		stty erase '^H' && read -p "(Predeterminado: cancelar):" ssr_port
		[[ -z "${ssr_port}" ]] && echo -e "Cancelado ...\n$(msg -bar)" && exit 1
		Modify_user=$(cat "${config_user_mudb_file}"|grep '"port": '"${ssr_port}"',')
		if [[ ! -z ${Modify_user} ]]; then
			break
		else
			echo -e "${Error} Puerto Introduzca el Puerto correcto!"
		fi
	done
}
Modify_Config(){
clear
	SSR_installation_status
	echo && echo -e "    ###¿Que desea realizar?###Mod By @Kalix1
$(msg -bar)
 ${Green_font_prefix}1.${Font_color_suffix}  Agregar y Configurar Usuario
 ${Green_font_prefix}2.${Font_color_suffix}  Eliminar la Configuracion del Usuario
————————— Modificar la Configuracion del Usuario ————
 ${Green_font_prefix}3.${Font_color_suffix}  Modificar contrasena de Usuario
 ${Green_font_prefix}4.${Font_color_suffix}  Modificar el metodo de Cifrado
 ${Green_font_prefix}5.${Font_color_suffix}  Modificar el Protocolo
 ${Green_font_prefix}6.${Font_color_suffix}  Modificar Ofuscacion
 ${Green_font_prefix}7.${Font_color_suffix}  Modificar el Limite de Dispositivos
 ${Green_font_prefix}8.${Font_color_suffix}  Modificar el Limite de Velocidad de un solo Hilo
 ${Green_font_prefix}9.${Font_color_suffix}  Modificar limite de Velocidad Total del Usuario
 ${Green_font_prefix}10.${Font_color_suffix} Modificar el Trafico Total del Usuario
 ${Green_font_prefix}11.${Font_color_suffix} Modificar los Puertos Prohibidos Del usuario
 ${Green_font_prefix}12.${Font_color_suffix} Modificar la Configuracion Completa
————————— Otras Configuraciones —————————
 ${Green_font_prefix}13.${Font_color_suffix} Modificar la IP o el nombre de dominio que\n se muestra en el perfil del usuario
$(msg -bar)
 ${Tip} El nombre de usuario y el puerto del usuario\n no se pueden modificar. Si necesita modificarlos, use\n el script para modificar manualmente la funcion !"
msg -bar
	stty erase '^H' && read -p "(Predeterminado: cancelar):" ssr_modify
	[[ -z "${ssr_modify}" ]] && echo -e "Cancelado ...\n$(msg -bar)" && exit 1
	if [[ ${ssr_modify} == "1" ]]; then
		Add_port_user
	elif [[ ${ssr_modify} == "2" ]]; then
		Del_port_user
	elif [[ ${ssr_modify} == "3" ]]; then
		Modify_port
		Set_config_password
		Modify_config_password
	elif [[ ${ssr_modify} == "4" ]]; then
		Modify_port
		Set_config_method
		Modify_config_method
	elif [[ ${ssr_modify} == "5" ]]; then
		Modify_port
		Set_config_protocol
		Modify_config_protocol
	elif [[ ${ssr_modify} == "6" ]]; then
		Modify_port
		Set_config_obfs
		Modify_config_obfs
	elif [[ ${ssr_modify} == "7" ]]; then
		Modify_port
		Set_config_protocol_param
		Modify_config_protocol_param
	elif [[ ${ssr_modify} == "8" ]]; then
		Modify_port
		Set_config_speed_limit_per_con
		Modify_config_speed_limit_per_con
	elif [[ ${ssr_modify} == "9" ]]; then
		Modify_port
		Set_config_speed_limit_per_user
		Modify_config_speed_limit_per_user
	elif [[ ${ssr_modify} == "10" ]]; then
		Modify_port
		Set_config_transfer
		Modify_config_transfer
	elif [[ ${ssr_modify} == "11" ]]; then
		Modify_port
		Set_config_forbid
		Modify_config_forbid
	elif [[ ${ssr_modify} == "12" ]]; then
		Modify_port
		Set_config_all "Modify"
		Modify_config_all
	elif [[ ${ssr_modify} == "13" ]]; then
		Set_user_api_server_pub_addr "Modify"
		Modify_user_api_server_pub_addr
	else
		echo -e "${Error} Ingrese el numero correcto(1-13)" && exit 1
	fi

}
List_port_user(){
	user_info=$(python mujson_mgr.py -l)
	user_total=$(echo "${user_info}"|wc -l)
	[[ -z ${user_info} ]] && echo -e "${Error} No encontre al usuario, por favor verifica otra vez!" && exit 1
	user_list_all=""
	for((integer = 1; integer <= ${user_total}; integer++))
	do
		user_port=$(echo "${user_info}"|sed -n "${integer}p"|awk '{print $4}')
		user_username=$(echo "${user_info}"|sed -n "${integer}p"|awk '{print $2}'|sed 's/\[//g;s/\]//g')
		Get_User_transfer "${user_port}"
		
		user_list_all=${user_list_all}"Nombre de usuario: ${Green_font_prefix} "${user_username}"${Font_color_suffix}\nPort: ${Green_font_prefix}"${user_port}"${Font_color_suffix}\nUso del trafico (Usado + Restante = Total):\n ${Green_font_prefix}${transfer_enable_Used_2}${Font_color_suffix} + ${Green_font_prefix}${transfer_enable_Used}${Font_color_suffix} = ${Green_font_prefix}${transfer_enable}${Font_color_suffix}\n--------------------------------------------\n "
	done
	echo && echo -e "===== El numero total de usuarios ===== ${Green_background_prefix} "${user_total}" ${Font_color_suffix}\n--------------------------------------------"
	echo -e ${user_list_all}
}
Add_port_user(){
clear
	lalal=$1
	if [[ "$lalal" == "install" ]]; then
		match_add=$(python mujson_mgr.py -a -u "${ssr_user}" -p "${ssr_port}" -k "${ssr_password}" -m "${ssr_method}" -O "${ssr_protocol}" -G "${ssr_protocol_param}" -o "${ssr_obfs}" -s "${ssr_speed_limit_per_con}" -S "${ssr_speed_limit_per_user}" -t "${ssr_transfer}" -f "${ssr_forbid}"|grep -w "add user info")
	else
		while true
		do
			Set_config_all
			match_port=$(python mujson_mgr.py -l|grep -w "port ${ssr_port}$")
			[[ ! -z "${match_port}" ]] && echo -e "${Error} El puerto [${ssr_port}] Ya existe, no lo agregue de nuevo !" && exit 1
			match_username=$(python mujson_mgr.py -l|grep -w "Usuario \[${ssr_user}]")
			[[ ! -z "${match_username}" ]] && echo -e "${Error} Nombre de usuario [${ssr_user}] Ya existe, no lo agregues de nuevo !" && exit 1
			match_add=$(python mujson_mgr.py -a -u "${ssr_user}" -p "${ssr_port}" -k "${ssr_password}" -m "${ssr_method}" -O "${ssr_protocol}" -G "${ssr_protocol_param}" -o "${ssr_obfs}" -s "${ssr_speed_limit_per_con}" -S "${ssr_speed_limit_per_user}" -t "${ssr_transfer}" -f "${ssr_forbid}"|grep -w "add user info")
			if [[ -z "${match_add}" ]]; then
				echo -e "${Error} Usuario no se pudo agregar ${Green_font_prefix}[Nombre de usuario: ${ssr_user} , port: ${ssr_port}]${Font_color_suffix} "
				break
			else
				Add_iptables
				Save_iptables
				msg -bar
				echo -e "${Info} Usuario agregado exitosamente\n ${Green_font_prefix}[Nombre de usuario: ${ssr_user} , Puerto: ${ssr_port}]${Font_color_suffix} "
				echo
				stty erase '^H' && read -p "Continuar para agregar otro Usuario?[y/n]:" addyn
				[[ -z ${addyn} ]] && addyn="y"
				if [[ ${addyn} == [Nn] ]]; then
					Get_User_info "${ssr_port}"
					View_User_info
					break
				else
					echo -e "${Info} Continuar agregando configuracion de usuario ..."
				fi
			fi
		done
	fi
}
Del_port_user(){

	List_port_user
	while true
	do
		msg -bar
		echo -e "Por favor ingrese el puerto de usuario para ser eliminado"
		stty erase '^H' && read -p "(Predeterminado: Cancelar):" del_user_port
		msg -bar
		[[ -z "${del_user_port}" ]] && echo -e "Cancelado...\n$(msg -bar)" && exit 1
		del_user=$(cat "${config_user_mudb_file}"|grep '"port": '"${del_user_port}"',')
		if [[ ! -z ${del_user} ]]; then
			port=${del_user_port}
			match_del=$(python mujson_mgr.py -d -p "${del_user_port}"|grep -w "delete user ")
			if [[ -z "${match_del}" ]]; then
				echo -e "${Error} La eliminación del usuario falló ${Green_font_prefix}[Puerto: ${del_user_port}]${Font_color_suffix} "
			else
				Del_iptables
				Save_iptables
				echo -e "${Info} Usuario eliminado exitosamente ${Green_font_prefix}[Puerto: ${del_user_port}]${Font_color_suffix} "
			fi
			break
		else
			echo -e "${Error} Por favor ingrese el puerto correcto !"
		fi
	done
	msg -bar
}
Manually_Modify_Config(){
clear
msg -bar
	SSR_installation_status
	nano ${config_user_mudb_file}
	echo "Si reiniciar ShadowsocksR ahora?[Y/n]" && echo
msg -bar
	stty erase '^H' && read -p "(Predeterminado: y):" yn
	[[ -z ${yn} ]] && yn="y"
	if [[ ${yn} == [Yy] ]]; then
		Restart_SSR
	fi

}
Clear_transfer(){
clear
msg -bar
	SSR_installation_status
	 echo -e "Que quieres realizar?
$(msg -bar)
 ${Green_font_prefix}1.${Font_color_suffix}  Borrar el trafico de un solo usuario
 ${Green_font_prefix}2.${Font_color_suffix}  Borrar todo el trafico de usuarios (irreparable)
 ${Green_font_prefix}3.${Font_color_suffix}  Todo el trafico de usuarios se borra en el inicio
 ${Green_font_prefix}4.${Font_color_suffix}  Deja de cronometrar todo el trafico de usuarios
 ${Green_font_prefix}5.${Font_color_suffix}  Modificar la sincronizacion de todo el trafico de usuarios"
msg -bar
	stty erase '^H' && read -p "(Predeterminado:Cancelar):" ssr_modify
	[[ -z "${ssr_modify}" ]] && echo "Cancelado ..." && exit 1
	if [[ ${ssr_modify} == "1" ]]; then
		Clear_transfer_one
	elif [[ ${ssr_modify} == "2" ]]; then
msg -bar
		echo "Esta seguro de que desea borrar todo el trafico de usuario[y/n]" && echo
msg -bar
		stty erase '^H' && read -p "(Predeterminado: n):" yn
		[[ -z ${yn} ]] && yn="n"
		if [[ ${yn} == [Yy] ]]; then
			Clear_transfer_all
		else
			echo "Cancelar ..."
		fi
	elif [[ ${ssr_modify} == "3" ]]; then
		check_crontab
		Set_crontab
		Clear_transfer_all_cron_start
	elif [[ ${ssr_modify} == "4" ]]; then
		check_crontab
		Clear_transfer_all_cron_stop
	elif [[ ${ssr_modify} == "5" ]]; then
		check_crontab
		Clear_transfer_all_cron_modify
	else
		echo -e "${Error} Por favor numero de (1-5)" && exit 1
	fi

}
Clear_transfer_one(){
	List_port_user
	while true
	do
	    msg -bar
		echo -e "Por favor ingrese el puerto de usuario para borrar el tráfico usado"
		stty erase '^H' && read -p "(Predeterminado: Cancelar):" Clear_transfer_user_port
		[[ -z "${Clear_transfer_user_port}" ]] && echo -e "Cancelado...\n$(msg -bar)" && exit 1
		Clear_transfer_user=$(cat "${config_user_mudb_file}"|grep '"port": '"${Clear_transfer_user_port}"',')
		if [[ ! -z ${Clear_transfer_user} ]]; then
			match_clear=$(python mujson_mgr.py -c -p "${Clear_transfer_user_port}"|grep -w "clear user ")
			if [[ -z "${match_clear}" ]]; then
				echo -e "${Error} El usuario no ha podido utilizar la compensación de tráfico ${Green_font_prefix}[Puerto: ${Clear_transfer_user_port}]${Font_color_suffix} "
			else
				echo -e "${Info} El usuario ha eliminado con éxito el tráfico utilizando cero. ${Green_font_prefix}[Puerto: ${Clear_transfer_user_port}]${Font_color_suffix} "
			fi
			break
		else
			echo -e "${Error} Por favor ingrese el puerto correcto !"
		fi
	done
}
Clear_transfer_all(){
clear
	cd "${ssr_folder}"
	user_info=$(python mujson_mgr.py -l)
	user_total=$(echo "${user_info}"|wc -l)
	[[ -z ${user_info} ]] && echo -e "${Error} No encontro, por favor compruebe!" && exit 1
	for((integer = 1; integer <= ${user_total}; integer++))
	do
		user_port=$(echo "${user_info}"|sed -n "${integer}p"|awk '{print $4}')
		match_clear=$(python mujson_mgr.py -c -p "${user_port}"|grep -w "clear user ")
		if [[ -z "${match_clear}" ]]; then
			echo -e "${Error} El usuario ha utilizado el trafico borrado fallido ${Green_font_prefix}[Port: ${user_port}]${Font_color_suffix} "
		else
			echo -e "${Info} El usuario ha utilizado el trafico para borrar con exito ${Green_font_prefix}[Port: ${user_port}]${Font_color_suffix} "
		fi
	done
	echo -e "${Info} Se borra todo el trafico de usuarios!"
}
Clear_transfer_all_cron_start(){
	crontab -l > "$file/crontab.bak"
	sed -i "/ssrmu.sh/d" "$file/crontab.bak"
	echo -e "\n${Crontab_time} /bin/bash $file/ssrmu.sh clearall" >> "$file/crontab.bak"
	crontab "$file/crontab.bak"
	rm -r "$file/crontab.bak"
	cron_config=$(crontab -l | grep "ssrmu.sh")
	if [[ -z ${cron_config} ]]; then
		echo -e "${Error} Temporizacion de todo el trafico de usuarios borrado. !" && exit 1
	else
		echo -e "${Info} Programacion de todos los tiempos de inicio claro exitosos!"
	fi
}
Clear_transfer_all_cron_stop(){
	crontab -l > "$file/crontab.bak"
	sed -i "/ssrmu.sh/d" "$file/crontab.bak"
	crontab "$file/crontab.bak"
	rm -r "$file/crontab.bak"
	cron_config=$(crontab -l | grep "ssrmu.sh")
	if [[ ! -z ${cron_config} ]]; then
		echo -e "${Error} Temporizado Todo el trafico de usuarios se ha borrado Parado fallido!" && exit 1
	else
		echo -e "${Info} Timing All Clear Stop Stop Successful!!"
	fi
}
Clear_transfer_all_cron_modify(){
	Set_crontab
	Clear_transfer_all_cron_stop
	Clear_transfer_all_cron_start
}
Set_crontab(){
clear

		echo -e "Por favor ingrese el intervalo de tiempo de flujo
 === Formato ===
 * * * * * Mes * * * * *
 ${Green_font_prefix} 0 2 1 * * ${Font_color_suffix} Representante 1er, 2:00, claro, trafico usado.
$(msg -bar)
 ${Green_font_prefix} 0 2 15 * * ${Font_color_suffix} Representativo El 1  2} representa el 15  2:00 minutos Punto de flujo usado despejado 0 minutos Borrar flujo usado�
$(msg -bar)
 ${Green_font_prefix} 0 2 */7 * * ${Font_color_suffix} Representante 7 dias 2: 0 minutos despeja el trafico usado.
$(msg -bar)
 ${Green_font_prefix} 0 2 * * 0 ${Font_color_suffix} Representa todos los domingos (7) para despejar el trafico utilizado.
$(msg -bar)
 ${Green_font_prefix} 0 2 * * 3 ${Font_color_suffix} Representante (3) Flujo de trafico usado despejado"
msg -bar
	stty erase '^H' && read -p "(Default: 0 2 1 * * 1 de cada mes 2:00):" Crontab_time
	[[ -z "${Crontab_time}" ]] && Crontab_time="0 2 1 * *"
}
Start_SSR(){
clear
	SSR_installation_status
	check_pid
	[[ ! -z ${PID} ]] && echo -e "${Error} ShadowsocksR se esta ejecutando!" && exit 1
	/etc/init.d/ssrmu start

}
Stop_SSR(){
clear
	SSR_installation_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} ShadowsocksR no esta funcionando!" && exit 1
	/etc/init.d/ssrmu stop

}
Restart_SSR(){
clear
	SSR_installation_status
	check_pid
	[[ ! -z ${PID} ]] && /etc/init.d/ssrmu stop
	/etc/init.d/ssrmu start

}
View_Log(){
	SSR_installation_status
	[[ ! -e ${ssr_log_file} ]] && echo -e "${Error} El registro de ShadowsocksR no existe!" && exit 1
	echo && echo -e "${Tip} Presione ${Red_font_prefix}Ctrl+C ${Font_color_suffix} Registro de registro de terminacion" && echo
	tail -f ${ssr_log_file}

}
#Afilado
Configure_Server_Speeder(){
clear
msg -bar
	echo && echo -e "Que vas a hacer
${BARRA1}
 ${Green_font_prefix}1.${Font_color_suffix} Velocidad aguda
$(msg -bar)
 ${Green_font_prefix}2.${Font_color_suffix} Velocidad aguda
————————
 ${Green_font_prefix}3.${Font_color_suffix} Velocidad aguda
$(msg -bar)
 ${Green_font_prefix}4.${Font_color_suffix} Velocidad aguda
$(msg -bar)
 ${Green_font_prefix}5.${Font_color_suffix} Reinicie la velocidad aguda
$(msg -bar)
 ${Green_font_prefix}6.${Font_color_suffix} Estado agudo
 $(msg -bar)
 Nota: Sharp y LotServer no se pueden instalar / iniciar al mismo tiempo"
msg -bar
	stty erase '^H' && read -p "(Predeterminado: Cancelar):" server_speeder_num
	[[ -z "${server_speeder_num}" ]] && echo "Cancelado ..." && exit 1
	if [[ ${server_speeder_num} == "1" ]]; then
		Install_ServerSpeeder
	elif [[ ${server_speeder_num} == "2" ]]; then
		Server_Speeder_installation_status
		Uninstall_ServerSpeeder
	elif [[ ${server_speeder_num} == "3" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} start
		${Server_Speeder_file} status
	elif [[ ${server_speeder_num} == "4" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} stop
	elif [[ ${server_speeder_num} == "5" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} restart
		${Server_Speeder_file} status
	elif [[ ${server_speeder_num} == "6" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} status
	else
		echo -e "${Error} Por favor numero(1-6)" && exit 1
	fi
}
Install_ServerSpeeder(){
	[[ -e ${Server_Speeder_file} ]] && echo -e "${Error} Server Speeder esta instalado!" && exit 1
	#Prestamo de la version feliz de 91yun.rog
	wget --no-check-certificate -qO /tmp/serverspeeder.sh https://raw.githubusercontent.com/91yun/serverspeeder/master/serverspeeder.sh
	[[ ! -e "/tmp/serverspeeder.sh" ]] && echo -e "${Error} Prestamo de la version feliz de 91yun.rog!" && exit 1
	bash /tmp/serverspeeder.sh
	sleep 2s
	PID=`ps -ef |grep -v grep |grep "serverspeeder" |awk '{print $2}'`
	if [[ ! -z ${PID} ]]; then
		rm -rf /tmp/serverspeeder.sh
		rm -rf /tmp/91yunserverspeeder
		rm -rf /tmp/91yunserverspeeder.tar.gz
		echo -e "${Info} La instalacion del servidor Speeder esta completa!" && exit 1
	else
		echo -e "${Error} Fallo la instalacion de Server Speeder!" && exit 1
	fi
}
Uninstall_ServerSpeeder(){
clear
msg -bar
	echo "yes para desinstalar Speed ??Speed ??(Server Speeder)[y/N]" && echo
msg -bar
	stty erase '^H' && read -p "(Predeterminado: n):" unyn
	[[ -z ${unyn} ]] && echo && echo "Cancelado ..." && exit 1
	if [[ ${unyn} == [Yy] ]]; then
		chattr -i /serverspeeder/etc/apx*
		/serverspeeder/bin/serverSpeeder.sh uninstall -f
		echo && echo "Server Speeder Desinstalacion completa!" && echo
	fi
}
# LotServer
Configure_LotServer(){
clear
msg -bar
	echo && echo -e "Que vas a hacer?
$(msg -bar)
 ${Green_font_prefix}1.${Font_color_suffix} Instalar LotServer
$(msg -bar)
 ${Green_font_prefix}2.${Font_color_suffix} Desinstalar LotServer
————————
 ${Green_font_prefix}3.${Font_color_suffix} Iniciar LotServer
$(msg -bar)
 ${Green_font_prefix}4.${Font_color_suffix} Detener LotServer
$(msg -bar)
 ${Green_font_prefix}5.${Font_color_suffix} Reiniciar LotServer
$(msg -bar)
 ${Green_font_prefix}6.${Font_color_suffix} Ver el estado de LotServer
${BARRA1}
 
 Nota: Sharp y LotServer no se pueden instalar / iniciar al mismo tiempo"
msg -bar

	stty erase '^H' && read -p "(Predeterminado: Cancelar):" lotserver_num
	[[ -z "${lotserver_num}" ]] && echo "Cancelado ..." && exit 1
	if [[ ${lotserver_num} == "1" ]]; then
		Install_LotServer
	elif [[ ${lotserver_num} == "2" ]]; then
		LotServer_installation_status
		Uninstall_LotServer
	elif [[ ${lotserver_num} == "3" ]]; then
		LotServer_installation_status
		${LotServer_file} start
		${LotServer_file} status
	elif [[ ${lotserver_num} == "4" ]]; then
		LotServer_installation_status
		${LotServer_file} stop
	elif [[ ${lotserver_num} == "5" ]]; then
		LotServer_installation_status
		${LotServer_file} restart
		${LotServer_file} status
	elif [[ ${lotserver_num} == "6" ]]; then
		LotServer_installation_status
		${LotServer_file} status
	else
		echo -e "${Error} Por favor numero(1-6)" && exit 1
	fi
}
Install_LotServer(){
	[[ -e ${LotServer_file} ]] && echo -e "${Error} LotServer esta instalado!" && exit 1
	#Github: https://github.com/0oVicero0/serverSpeeder_Install
	wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh"
	[[ ! -e "/tmp/appex.sh" ]] && echo -e "${Error} Fallo la descarga del script de instalacion de LotServer!" && exit 1
	bash /tmp/appex.sh 'install'
	sleep 2s
	PID=`ps -ef |grep -v grep |grep "appex" |awk '{print $2}'`
	if [[ ! -z ${PID} ]]; then
		echo -e "${Info} La instalacion de LotServer esta completa!" && exit 1
	else
		echo -e "${Error} Fallo la instalacion de LotServer!" && exit 1
	fi
}
Uninstall_LotServer(){
clear
msg -bar
	echo "Desinstalar Para desinstalar LotServer[y/N]" && echo
msg -bar
	stty erase '^H' && read -p "(Predeterminado: n):" unyn
msg -bar
	[[ -z ${unyn} ]] && echo && echo "Cancelado ..." && exit 1
	if [[ ${unyn} == [Yy] ]]; then
		wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh" && bash /tmp/appex.sh 'uninstall'
		echo && echo "La desinstalacion de LotServer esta completa!" && echo
	fi
}
# BBR
Configure_BBR(){
clear
msg -bar
 echo -e "  Que vas a hacer?
$(msg -bar)	
 ${Green_font_prefix}1.${Font_color_suffix} Instalar BBR
————————
${Green_font_prefix}2.${Font_color_suffix} Iniciar BBR
${Green_font_prefix}3.${Font_color_suffix} Dejar de BBR
${Green_font_prefix}4.${Font_color_suffix} Ver el estado de BBR"
msg -bar
echo -e "${Green_font_prefix} [Por favor, preste atencion antes de la instalacion] ${Font_color_suffix}
$(msg -bar)
1. Abra BBR, reemplace, hay un error de reemplazo (despues de reiniciar)
2. Este script solo es compatible con los nucleos de reemplazo de Debian / Ubuntu. OpenVZ y Docker no admiten el reemplazo de los nucleos.
3. Debian reemplaza el proceso del kernel [Desea finalizar el kernel de desinstalacion], seleccione ${Green_font_prefix} NO ${Font_color_suffix}"
	stty erase '^H' && read -p "(Predeterminado: Cancelar):" bbr_num
msg -bar
	[[ -z "${bbr_num}" ]] && echo -e "Cancelado...\n$(msg -bar)" && exit 1
	if [[ ${bbr_num} == "1" ]]; then
		Install_BBR
	elif [[ ${bbr_num} == "2" ]]; then
		Start_BBR
	elif [[ ${bbr_num} == "3" ]]; then
		Stop_BBR
	elif [[ ${bbr_num} == "4" ]]; then
		Status_BBR
	else
		echo -e "${Error} Por favor numero(1-4)" && exit 1
	fi
}
Install_BBR(){
	[[ ${release} = "centos" ]] && echo -e "${Error} Este script de instalacion del sistema CentOS. BBR !" && exit 1
	BBR_installation_status
	bash "${BBR_file}"
}
Start_BBR(){
	BBR_installation_status
	bash "${BBR_file}" start
}
Stop_BBR(){
	BBR_installation_status
	bash "${BBR_file}" stop
}
Status_BBR(){
	BBR_installation_status
	bash "${BBR_file}" status
}
BackUP_ssrr(){
clear
msg -bar
msg -ama "$(fun_trans "HERRAMIENTA DE BACKUP SS-SSRR -BETA")"
msg -bar
msg -azu "CREANDO BACKUP" "RESTAURAR BACKUP"
msg -bar
rm -rf /root/mudb.json > /dev/null 2>&1
cp /usr/local/shadowsocksr/mudb.json /root/mudb.json > /dev/null 2>&1
msg -azu "$(fun_trans "Procedimiento Hecho con Exito, Guardado en:")"
echo -e "\033[1;31mBACKUP > [\033[1;32m/root/mudb.json\033[1;31m]"
msg -bar
}
RestaurarBackUp_ssrr(){
clear
msg -bar
msg -ama "$(fun_trans "HERRAMIENTA DE RESTAURACION SS-SSRR -BETA")"
msg -bar
msg -azu "Recuerde tener minimo una cuenta ya creada"
msg -azu "Copie el archivo mudb.json en la carpeta /root"
read -p "     ►► Presione enter para continuar ◄◄"
msg -bar
msg -azu "$(fun_trans "Procedimiento Hecho con Exito")"
read -p "  ►► Presione enter para Reiniciar Panel SSRR ◄◄"
msg -bar
mv /root/mudb.json /usr/local/shadowsocksr/mudb.json
Restart_SSR
msg -bar
}

# Otros
Other_functions(){
clear
msg -bar
	echo && echo -e "  Que vas a realizar?
$(msg -bar)
  ${Green_font_prefix}1.${Font_color_suffix} Configurar BBR
  ${Green_font_prefix}2.${Font_color_suffix} Velocidad de configuracion (ServerSpeeder)
  ${Green_font_prefix}3.${Font_color_suffix} Configurar LotServer (Rising Parent)
  ${Tip} Sharp / LotServer / BBR no es compatible con OpenVZ!
  ${Tip} Speed y LotServer no pueden coexistir!
————————————
  ${Green_font_prefix}4.${Font_color_suffix} Llave de bloqueo BT/PT/SPAM (iptables)
  ${Green_font_prefix}5.${Font_color_suffix} Llave de desbloqueo BT/PT/SPAM (iptables)
————————————
  ${Green_font_prefix}6.${Font_color_suffix} Cambiar modo de salida de registro ShadowsocksR
  —— Modo bajo o verboso..
  ${Green_font_prefix}7.${Font_color_suffix} Supervisar el estado de ejecucion del servidor ShadowsocksR
  —— NOTA: Esta funcion es adecuada para que el servidor SSR finalice los procesos regulares. Una vez que esta funcion esta habilitada, sera detectada cada minuto. Cuando el proceso no existe, el servidor SSR se inicia automaticamente.
———————————— 
 ${Green_font_prefix}8.${Font_color_suffix} Backup SSRR
 ${Green_font_prefix}9.${Font_color_suffix} Restaurar Backup" && echo
msg -bar
	stty erase '^H' && read -p "(Predeterminado: cancelar):" other_num
	[[ -z "${other_num}" ]] && echo -e "Cancelado...\n$(msg -bar)" && exit 1
	if [[ ${other_num} == "1" ]]; then
		Configure_BBR
	elif [[ ${other_num} == "2" ]]; then
		Configure_Server_Speeder
	elif [[ ${other_num} == "3" ]]; then
		Configure_LotServer
	elif [[ ${other_num} == "4" ]]; then
		BanBTPTSPAM
	elif [[ ${other_num} == "5" ]]; then
		UnBanBTPTSPAM
	elif [[ ${other_num} == "6" ]]; then
		Set_config_connect_verbose_info
	elif [[ ${other_num} == "7" ]]; then
		Set_crontab_monitor_ssr
	elif [[ ${other_num} == "8" ]]; then
		BackUP_ssrr
	elif [[ ${other_num} == "9" ]]; then
		RestaurarBackUp_ssrr
	else
		echo -e "${Error} Por favor numero [1-9]" && exit 1
	fi

}
#Prohibido�BT PT SPAM
BanBTPTSPAM(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ban_iptables.sh && chmod +x ban_iptables.sh && bash ban_iptables.sh banall
	rm -rf ban_iptables.sh
}
#Desbloquear BT PT SPAM
UnBanBTPTSPAM(){
	wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ban_iptables.sh && chmod +x ban_iptables.sh && bash ban_iptables.sh unbanall
	rm -rf ban_iptables.sh
}
Set_config_connect_verbose_info(){
clear
msg -bar
	SSR_installation_status
	[[ ! -e ${jq_file} ]] && echo -e "${Error} JQ parser No, por favor, compruebe!" && exit 1
	connect_verbose_info=`${jq_file} '.connect_verbose_info' ${config_user_file}`
	if [[ ${connect_verbose_info} = "0" ]]; then
		echo && echo -e "Modo de registro actual: ${Green_font_prefix}Registro de errores en modo simple${Font_color_suffix}"
msg -bar
		echo -e "yes para cambiar a ${Green_font_prefix}Modo detallado (registro de conexi�n + registro de errores)${Font_color_suffix}？[y/N]"
msg -bar
		stty erase '^H' && read -p "(Predeterminado: n):" connect_verbose_info_ny
		[[ -z "${connect_verbose_info_ny}" ]] && connect_verbose_info_ny="n"
		if [[ ${connect_verbose_info_ny} == [Yy] ]]; then
			ssr_connect_verbose_info="1"
			Modify_config_connect_verbose_info
			Restart_SSR
		else
			echo && echo "	Cancelado ..." && echo
		fi
	else
		echo && echo -e "Modo de registro actual: ${Green_font_prefix}Modo detallado (conexion de conexion + registro de errores)${Font_color_suffix}"
msg -bar
		echo -e "yes para cambiar a ${Green_font_prefix}Modo simple ${Font_color_suffix}?[y/N]"
		stty erase '^H' && read -p "(Predeterminado: n):" connect_verbose_info_ny
		[[ -z "${connect_verbose_info_ny}" ]] && connect_verbose_info_ny="n"
		if [[ ${connect_verbose_info_ny} == [Yy] ]]; then
			ssr_connect_verbose_info="0"
			Modify_config_connect_verbose_info
			Restart_SSR
		else
			echo && echo "	Cancelado ..." && echo
		fi
	fi
}
Set_crontab_monitor_ssr(){
clear
msg -bar
	SSR_installation_status
	crontab_monitor_ssr_status=$(crontab -l|grep "ssrmu.sh monitor")
	if [[ -z "${crontab_monitor_ssr_status}" ]]; then
		echo && echo -e "Modo de monitoreo actual: ${Green_font_prefix}No monitoreado${Font_color_suffix}"
msg -bar
		echo -e "Ok para abrir ${Green_font_prefix}Servidor ShadowsocksR ejecutando monitoreo de estado${Font_color_suffix} Funcion? (Cuando el proceso R lado SSR R)[Y/n]"
msg -bar
		stty erase '^H' && read -p "(Predeterminado: y):" crontab_monitor_ssr_status_ny
		[[ -z "${crontab_monitor_ssr_status_ny}" ]] && crontab_monitor_ssr_status_ny="y"
		if [[ ${crontab_monitor_ssr_status_ny} == [Yy] ]]; then
			crontab_monitor_ssr_cron_start
		else
			echo && echo "	Cancelado ..." && echo
		fi
	else
		echo && echo -e "Modo de monitoreo actual: ${Green_font_prefix}Abierto${Font_color_suffix}"
msg -bar
		echo -e "Ok para apagar ${Green_font_prefix}Servidor ShadowsocksR ejecutando monitoreo de estado${Font_color_suffix} Funcion? (procesar servidor SSR)[y/N]"
msg -bar
		stty erase '^H' && read -p "(Predeterminado: n):" crontab_monitor_ssr_status_ny
		[[ -z "${crontab_monitor_ssr_status_ny}" ]] && crontab_monitor_ssr_status_ny="n"
		if [[ ${crontab_monitor_ssr_status_ny} == [Yy] ]]; then
			crontab_monitor_ssr_cron_stop
		else
			echo && echo "	Cancelado ..." && echo
		fi
	fi
}
crontab_monitor_ssr(){
	SSR_installation_status
	check_pid
	if [[ -z ${PID} ]]; then
		echo -e "${Error} [$(date "+%Y-%m-%d %H:%M:%S %u %Z")] Detectado que el servidor ShadowsocksR no esta iniciado, inicie..." | tee -a ${ssr_log_file}
		/etc/init.d/ssrmu start
		sleep 1s
		check_pid
		if [[ -z ${PID} ]]; then
			echo -e "${Error} [$(date "+%Y-%m-%d %H:%M:%S %u %Z")] Fallo el inicio del servidor ShadowsocksR..." | tee -a ${ssr_log_file} && exit 1
		else
			echo -e "${Info} [$(date "+%Y-%m-%d %H:%M:%S %u %Z")] Inicio de inicio del servidor ShadowsocksR..." | tee -a ${ssr_log_file} && exit 1
		fi
	else
		echo -e "${Info} [$(date "+%Y-%m-%d %H:%M:%S %u %Z")] El proceso del servidor ShadowsocksR se ejecuta normalmente..." exit 0
	fi
}
crontab_monitor_ssr_cron_start(){
	crontab -l > "$file/crontab.bak"
	sed -i "/ssrmu.sh monitor/d" "$file/crontab.bak"
	echo -e "\n* * * * * /bin/bash $file/ssrmu.sh monitor" >> "$file/crontab.bak"
	crontab "$file/crontab.bak"
	rm -r "$file/crontab.bak"
	cron_config=$(crontab -l | grep "ssrmu.sh monitor")
	if [[ -z ${cron_config} ]]; then
		echo -e "${Error} Fallo el arranque del servidor ShadowsocksR!" && exit 1
	else
		echo -e "${Info} El servidor ShadowsocksR esta ejecutando la monitorizacion del estado con exito!"
	fi
}
crontab_monitor_ssr_cron_stop(){
	crontab -l > "$file/crontab.bak"
	sed -i "/ssrmu.sh monitor/d" "$file/crontab.bak"
	crontab "$file/crontab.bak"
	rm -r "$file/crontab.bak"
	cron_config=$(crontab -l | grep "ssrmu.sh monitor")
	if [[ ! -z ${cron_config} ]]; then
		echo -e "${Error} Fallo la detencion del servidor ShadowsocksR!" && exit 1
	else
		echo -e "${Info} La supervision del estado de ejecucion del servidor de ShadowsocksR se detiene correctamente!"
	fi
}
Update_Shell(){
clear
msg -bar
	echo -e "La version actual es [ ${sh_ver} ], Comienza a detectar la ultima version ..."
	sh_new_ver=$(wget --no-check-certificate -qO- "https://raw.githubusercontent.com/hybtoy/ssrrmu/master/ssrrmu.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
	[[ -z ${sh_new_ver} ]] && sh_new_ver=$(wget --no-check-certificate -qO- "https://raw.githubusercontent.com/hybtoy/ssrrmu/master/ssrrmu.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} Ultima version de deteccion !" && exit 0
	if [[ ${sh_new_ver} != ${sh_ver} ]]; then
		echo -e "Descubrir nueva version[ ${sh_new_ver} ], Esta actualizado?[Y/n]"
msg -bar
		stty erase '^H' && read -p "(Predeterminado: y):" yn
		[[ -z "${yn}" ]] && yn="y"
		if [[ ${yn} == [Yy] ]]; then
			cd "${file}"
			if [[ $sh_new_type == "github" ]]; then
				wget -N --no-check-certificate https://raw.githubusercontent.com/hybtoy/ssrrmu/master/ssrrmu.sh && chmod +x ssrrmu.sh
			fi
			echo -e "El script ha sido actualizado a la ultima version.[ ${sh_new_ver} ] !"
		else
			echo && echo "	Cancelado ..." && echo
		fi
	else
		echo -e "Actualmente es la ultima version.[ ${sh_new_ver} ] !"
	fi
	exit 0

}
# Mostrar el estado del menu
menu_status(){
msg -bar
	if [[ -e ${ssr_folder} ]]; then
		check_pid
		if [[ ! -z "${PID}" ]]; then
			echo -e "         VPS-MX By @Kalix1\n Estado actual: ${Green_font_prefix}Instalado${Font_color_suffix} y ${Green_font_prefix}Iniciado${Font_color_suffix}"
		else
			echo -e " Estado actual: ${Green_font_prefix}Instalado${Font_color_suffix} pero ${Red_font_prefix}no comenzo${Font_color_suffix}"
		fi
		cd "${ssr_folder}"
	else
		echo -e " Estado actual: ${Red_font_prefix}No Instalado${Font_color_suffix}"
	fi
}
check_sys
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} el script no es compatible con el sistema actual ${release} !" && exit 1
action=$1
if [[ "${action}" == "clearall" ]]; then
	Clear_transfer_all
elif [[ "${action}" == "monitor" ]]; then
	crontab_monitor_ssr
else
echo -e "\033[1;37m       =====>>►► 🐲 PANEL VPS•MX 🐲 ◄◄<<=====       \033[1;37m"
msg -bar
echo -e "        Controlador de ShadowSock-R  ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
$(msg -bar)
  ${Green_font_prefix}1.${Font_color_suffix} Instalar ShadowsocksR 
  ${Green_font_prefix}2.${Font_color_suffix} Actualizar ShadowsocksR
  ${Green_font_prefix}3.${Font_color_suffix} Desinstalar ShadowsocksR
  ${Green_font_prefix}4.${Font_color_suffix} Instalar libsodium (chacha20)
—————————————
  ${Green_font_prefix}5.${Font_color_suffix} Verifique la informacion de la cuenta
  ${Green_font_prefix}6.${Font_color_suffix} Mostrar la informacion de conexion 
  ${Green_font_prefix}7.${Font_color_suffix} Agregar/Modificar/Eliminar la configuracion del usuario  
  ${Green_font_prefix}8.${Font_color_suffix} Modificar manualmente la configuracion del usuario
  ${Green_font_prefix}9.${Font_color_suffix} Borrar el trafico usado  
——————————————
 ${Green_font_prefix}10.${Font_color_suffix} Iniciar ShadowsocksR
 ${Green_font_prefix}11.${Font_color_suffix} Detener ShadowsocksR
 ${Green_font_prefix}12.${Font_color_suffix} Reiniciar ShadowsocksR
 ${Green_font_prefix}13.${Font_color_suffix} Verificar Registro de ShadowsocksR
—————————————
 ${Green_font_prefix}14.${Font_color_suffix} Otras Funciones
 ${Green_font_prefix}15.${Font_color_suffix} Actualizar Script 
$(msg -bar)
 ${Green_font_prefix}16.${Font_color_suffix}${Red_font_prefix} SALIR"
	
	menu_status
	msg -bar
    stty erase '^H' && read -p "Porfavor seleccione una opcion [1-16]:" num
	msg -bar
case "$num" in
	1)
	Install_SSR
	;;
	2)
	Update_SSR
	;;
	3)
	Uninstall_SSR
	;;
	4)
	Install_Libsodium
	;;
	5)
	View_User
	;;
	6)
	View_user_connection_info
	;;
	7)
	Modify_Config
	;;
	8)
	Manually_Modify_Config
	;;
	9)
	Clear_transfer
	;;
	10)
	Start_SSR
	;;
	11)
	Stop_SSR
	;;
	12)
	Restart_SSR
	;;
	13)
	View_Log
	;;
	14)
	Other_functions
	;;
	15)
	Update_Shell
	;;
     16)
     exit 1
      ;;
	*)
	echo -e "${Error} Porfavor use numeros del [1-16]"
	msg -bar
	;;
esac
fi
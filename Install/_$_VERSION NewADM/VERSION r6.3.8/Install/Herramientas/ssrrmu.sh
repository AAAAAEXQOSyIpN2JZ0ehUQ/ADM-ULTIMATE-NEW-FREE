#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
SCPfrm="/etc/ger-inst" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
BARRA1="\e[1;30mâž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–\e[0m"
BARRA="\e[0;31m--------------------------------------------------------------------\e[0m"
#=================================================
#	System Required: CentOS 6+/Debian 6+/Ubuntu 14.04+
#	Description: Install the ShadowsocksR mudbjson server
#	Version: 1.0.25
#	Author: Toyo
#       Translator: hybtoy 
#	Blog: https://doub.io/ss-jc60/
#=================================================

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
blue_font_prefix="\e[1;34m" && ama_font_prefix="\e[1;33m" && asul_font_prefix="\e[0;34m" && blan_font_prefix="\e[1;37m"
Info="${Green_font_prefix}[information]${Font_color_suffix}"
Error="${Red_font_prefix}[error]${Font_color_suffix}"
Tip="${Green_font_prefix}[note]${Font_color_suffix}"
Separator_1="â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”â€”"

check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} La cuenta actual no es ROOT (no tiene permiso ROOT), no puede continuar la operación, por favor ${Green_background_prefix} sudo su ${Font_color_suffix} Venga a ROOT (le pedirá que ingrese la contraseña de la cuenta actual después de la ejecución)" && exit 1
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
	[[ ! -e ${ssr_folder} ]] && echo -e "${Error}ShadowsocksR ¡No se encontro la carpeta, por favor verifique" && exit 1
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
#Leer la información de configuración
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
	user_name=$(echo "${user_info_get}"|grep -w "user_name:"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
echo -e "$BARRA"
	port=$(echo "${user_info_get}"|grep -w "port :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
echo -e "$BARRA"
	password=$(echo "${user_info_get}"|grep -w "passwd :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
echo -e "$BARRA"
	method=$(echo "${user_info_get}"|grep -w "method :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
echo -e "$BARRA"
	protocol=$(echo "${user_info_get}"|grep -w "protocol :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
echo -e "$BARRA"
	protocol_param=$(echo "${user_info_get}"|grep -w "protocol_param :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
echo -e "$BARRA"
	[[ -z ${protocol_param} ]] && protocol_param="0(Ilimitado)"
echo -e "$BARRA"
	obfs=$(echo "${user_info_get}"|grep -w "obfs :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
echo -e "$BARRA"
	#transfer_enable=$(echo "${user_info_get}"|grep -w "transfer_enable :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}'|awk -F "ytes" '{print $1}'|sed 's/KB/ KB/;s/MB/ MB/;s/GB/ GB/;s/TB/ TB/;s/PB/ PB/')
	#u=$(echo "${user_info_get}"|grep -w "u :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
	#d=$(echo "${user_info_get}"|grep -w "d :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
	forbidden_port=$(echo "${user_info_get}"|grep -w "Puerto prohibido :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
	[[ -z ${forbidden_port} ]] && forbidden_port="Permitir todo"
echo -e "$BARRA"
	speed_limit_per_con=$(echo "${user_info_get}"|grep -w "speed_limit_per_con :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
echo -e "$BARRA"
	speed_limit_per_user=$(echo "${user_info_get}"|grep -w "speed_limit_per_user :"|sed 's/[[:space:]]//g'|awk -F ":" '{print $NF}')
echo -e "$BARRA"
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
	SSQRcode="http://doub.pw/qr/qr.php?text=${SSurl}"
	ss_link=" SS    Link : ${Green_font_prefix}${SSurl}${Font_color_suffix} \n Codigo QR SS: ${Green_font_prefix}${SSQRcode}${Font_color_suffix}"
}
ssr_link_qr(){
	SSRprotocol=$(echo ${protocol} | sed 's/_compatible//g')
	SSRobfs=$(echo ${obfs} | sed 's/_compatible//g')
	SSRPWDbase64=$(urlsafe_base64 "${password}")
	SSRbase64=$(urlsafe_base64 "${ip}:${port}:${SSRprotocol}:${method}:${SSRobfs}:${SSRPWDbase64}")
	SSRurl="ssr://${SSRbase64}"
	SSRQRcode="http://doub.pw/qr/qr.php?text=${SSRurl}"
	ssr_link=" SSR   Link : ${Red_font_prefix}${SSRurl}${Font_color_suffix} \n Codigo QR SSR: ${Red_font_prefix}${SSRQRcode}${Font_color_suffix} \n "
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
echo -e "$BARRA"
		echo -e "${ama_font_prefix}Por favor ingrese el puerto de usuario para ver la informacion de la cuenta ${Font_color_suffix}"
echo -e "$BARRA1"
		stty erase '^H' && read -p "(Predeterminado: cancelar):" View_user_port
		[[ -z "${View_user_port}" ]] && echo -e "Cancelado ..." && ${SCPfrm}/ssrrmu.sh
		View_user=$(cat "${config_user_mudb_file}"|grep '"port": '"${View_user_port}"',')
		if [[ ! -z ${View_user} ]]; then
			Get_User_info "${View_user_port}"
			View_User_info
			break
		else
			echo -e "${Error} Por favor ingrese el puerto correcto !"
		fi
	done
read -p "Enter para continuar" enter
}
View_User_info(){
	ip=$(cat ${config_user_api_file}|grep "SERVER_PUB_ADDR = "|awk -F "[']" '{print $2}')
	[[ -z "${ip}" ]] && Get_IP
	ss_ssr_determine
	clear && echo -e "$BARRA1"
	echo -e " Usuario [${user_name}] informacion de configuracion:" && echo
echo -e "$BARRA"
	echo -e " ${blan_font_prefix}IP :${Font_color_suffix} ${Green_font_prefix}${ip}${Font_color_suffix}"
echo -e "$BARRA"
	echo -e " ${blan_font_prefix}Puerto :${Font_color_suffix} ${Green_font_prefix}${port}${Font_color_suffix}"
echo -e "$BARRA"
	echo -e " ${blan_font_prefix}Password :${Font_color_suffix} ${Green_font_prefix}${password}${Font_color_suffix}"
echo -e "$BARRA"
	echo -e " ${blan_font_prefix}Encriptacion :${Font_color_suffix} ${Green_font_prefix}${method}${Font_color_suffix}"
echo -e "$BARRA"
	echo -e " ${blan_font_prefix}Protocol :${Font_color_suffix} ${Red_font_prefix}${protocol}${Font_color_suffix}"
echo -e "$BARRA"
	echo -e " ${blan_font_prefix}Obfs :${Font_color_suffix} ${Red_font_prefix}${obfs}${Font_color_suffix}"
echo -e "$BARRA"
	echo -e " ${blan_font_prefix}Limite del dispositivo :${Font_color_suffix} ${Green_font_prefix}${protocol_param}${Font_color_suffix}"
echo -e "$BARRA"
	echo -e " ${blan_font_prefix}Limite de velocidad de subproceso unico :${Font_color_suffix} ${Green_font_prefix}${speed_limit_per_con} KB/S${Font_color_suffix}"
echo -e "$BARRA"
	echo -e " ${blan_font_prefix}Limite total de velocidad del usuario :${Font_color_suffix} ${Green_font_prefix}${speed_limit_per_user} KB/S${Font_color_suffix}"
echo -e "$BARRA"
	echo -e " ${blan_font_prefix}Puerto prohibido :${Font_color_suffix} ${Green_font_prefix}${forbidden_port} ${Font_color_suffix}"
echo -e "$BARRA"
	echo -e " ${blan_font_prefix}Se utiliza el trafico:Carga :${Font_color_suffix} ${Green_font_prefix}${u}${Font_color_suffix} + Descarga: ${Green_font_prefix}${d}${Font_color_suffix} = ${Green_font_prefix}${transfer_enable_Used_2}${Font_color_suffix}"
echo -e "$BARRA"	
       echo -e " ${blan_font_prefix}Trafico restante :${Font_color_suffix} ${Green_font_prefix}${transfer_enable_Used} ${Font_color_suffix}"
echo -e "$BARRA"
	echo -e " ${blan_font_prefix}Trafico total de usuarios :${Font_color_suffix} ${Green_font_prefix}${transfer_enable} ${Font_color_suffix}"
echo -e "$BARRA"
	echo -e "${ss_link}"
echo -e "$BARRA"
	echo -e "${ssr_link}"
echo -e "$BARRA"
	echo -e " ${Tip} ${blan_font_prefix}En el navegador, abra el enlace del codigo QR, puede ver la imagen del codigo QR.${Font_color_suffix}"
 	echo && echo -e "$BARRA1"
}
#Configuración de la información de configuración
Set_config_user(){
echo -e "$BARRA1"
	echo -e "${ama_font_prefix}Por favor ingrese el nombre de usuario que desea configurar ${blan_font_prefix}(${Font_color_suffix}${Red_font_prefix}no repetir${Font_color_suffix}${blan_font_prefix}!)${Font_color_suffix}"
echo -e "$BARRA"
	stty erase '^H' && read -p "(Predeterminado: dankel):" ssr_user
	[[ -z "${ssr_user}" ]] && ssr_user="dankel"
	echo && echo ${Separator_1} && echo -e "${blan_font_prefix}Nombre de usuario :${Font_color_suffix} ${Green_font_prefix}${ssr_user}${Font_color_suffix}" && echo ${Separator_1} && echo
}
Set_config_port(){
echo -e "$BARRA1"
	while true
	do
	echo -e "${ama_font_prefix}Por favor ingrese el puerto de usuario a configurar ${Font_color_suffix}"
echo -e "$BARRA"
	stty erase '^H' && read -p "(Predeterminado: 445):" ssr_port
	[[ -z "$ssr_port" ]] && ssr_port="445"
	expr ${ssr_port} + 0 &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_port} -ge 1 ]] && [[ ${ssr_port} -le 65535 ]]; then
			echo && echo ${Separator_1} && echo -e "${blan_font_prefix}Puerto :${Font_color_suffix} ${Green_font_prefix}${ssr_port}${Font_color_suffix}" && echo ${Separator_1} && echo
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
echo -e "$BARRA1"
	echo -e "${ama_font_prefix}Por favor ingrese la contrasena de usuario que desea configurar${Font_color_suffix}"
echo -e "$BARRA"
	stty erase '^H' && read -p "(Predeterminado: dankel):" ssr_password
	[[ -z "${ssr_password}" ]] && ssr_password="dankel"
	echo && echo ${Separator_1} && echo -e "${blan_font_prefix}contrasena :${Font_color_suffix} ${Green_font_prefix}${ssr_password}${Font_color_suffix}" && echo ${Separator_1} && echo
}
Set_config_method(){
echo -e "$BARRA1"
	echo -e "${ama_font_prefix}Seleccione el metodo de encriptacion del usuario que desea configurar
${BARRA}
 ${Green_font_prefix}[1] >${Font_color_suffix} Ninguno
 ${Green_font_prefix}[2] >${Font_color_suffix} rc4
 ${Green_font_prefix}[3] >${Font_color_suffix} rc4-md5
 ${Green_font_prefix}[4] >${Font_color_suffix} rc4-md5-6
 ${Green_font_prefix}[5] >${Font_color_suffix} aes-128-ctr
 ${Green_font_prefix}[6] >${Font_color_suffix} aes-192-ctr
 ${Green_font_prefix}[7] >${Font_color_suffix} aes-256-ctr
 ${Green_font_prefix}[8] >${Font_color_suffix} aes-128-cfb
 ${Green_font_prefix}[9] >${Font_color_suffix} aes-192-cfb
 ${Green_font_prefix}[10] >${Font_color_suffix} aes-256-cfb
 ${Green_font_prefix}[11] >${Font_color_suffix} aes-128-cfb8
 ${Green_font_prefix}[12] >${Font_color_suffix} aes-192-cfb8
 ${Green_font_prefix}[13] >${Font_color_suffix} aes-256-cfb8
 ${Green_font_prefix}[14] >${Font_color_suffix} salsa20
 ${Green_font_prefix}[15] >${Font_color_suffix} chacha20
 ${Green_font_prefix}[16] >${Font_color_suffix} chacha20-ietf
 
 ${Red_font_prefix}[17] >${Font_color_suffix} xsalsa20
 ${Red_font_prefix}[18] >${Font_color_suffix} xchacha20
${BARRA}
 ${Tip} ${blue_font_prefix}Para salsa20/chacha20-*, Porfavor instale libsodium${Font_color_suffix}"
echo -e "$BARRA1"
	stty erase '^H' && read -p "(Predeterminado: 10. aes-256-cfb):" ssr_method
	[[ -z "${ssr_method}" ]] && ssr_method="10"
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
	echo && echo ${Separator_1} && echo -e "${Green_font_prefix}Encriptacion :${Font_color_suffix} ${Green_font_prefix}${ssr_method}${Font_color_suffix}" && echo ${Separator_1} && echo
}
Set_config_protocol(){
echo -e "$BARRA1"
	echo -e "${ama_font_prefix}Por favor, seleccione el protocolo
${BARRA}
 ${Green_font_prefix}[1] >${Font_color_suffix} origin
 ${Green_font_prefix}[2] >${Font_color_suffix} auth_sha1_v4
 ${Green_font_prefix}[3] >${Font_color_suffix} auth_aes128_md5
 ${Green_font_prefix}[4] >${Font_color_suffix} auth_aes128_sha1
 ${Green_font_prefix}[5] >${Font_color_suffix} auth_chain_a
 ${Green_font_prefix}[6] >${Font_color_suffix} auth_chain_b

 ${Red_font_prefix}[7] >${Font_color_suffix} auth_chain_c
 ${Red_font_prefix}[8] >${Font_color_suffix} auth_chain_d
 ${Red_font_prefix}[9] >${Font_color_suffix} auth_chain_e
 ${Red_font_prefix}[10] >${Font_color_suffix} auth_chain_f
${BARRA}
 ${Tip} ${blue_font_prefix}Si selecciona el protocolo de serie auth_chain_ *, se recomienda establecer el metodo de cifrado en ninguno${Font_color_suffix}"
echo -e "$BARRA1"
	stty erase '^H' && read -p "(Predterminado: 1. origin):" ssr_protocol
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
	echo && echo ${Separator_1} && echo -e "	Protocolo : ${Green_font_prefix}${ssr_protocol}${Font_color_suffix}" && echo ${Separator_1} && echo
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
echo -e "$BARRA1"
	echo -e "${ama_font_prefix}Por favor, seleccione el metodo obfs
${BARRA}
 ${Green_font_prefix}[1] >${Font_color_suffix} plain
 ${Green_font_prefix}[2] >${Font_color_suffix} http_simple
 ${Green_font_prefix}[3] >${Font_color_suffix} http_post
 ${Green_font_prefix}[4] >${Font_color_suffix} random_head
 ${Green_font_prefix}[5] >${Font_color_suffix} tls1.2_ticket_auth
${BARRA}
 ${Tip} ${blue_font_prefix}Si elige tls1.2_ticket_auth, entonces el cliente puede elegir tls1.2_ticket_fastauth!${Font_color_suffix}"
echo -e "$BARRA1"
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
	echo && echo ${Separator_1} && echo -e "${blan_font_prefix}Obfs :${Font_color_suffix} ${Green_font_prefix}${ssr_obfs}${Font_color_suffix}" && echo ${Separator_1} && echo
	if [[ ${ssr_obfs} != "plain" ]]; then
			stty erase '^H' && read -p "Configurar el complemento de protocolo en modo compatible(_compatible)?[Y/n]" ssr_obfs_yn
			[[ -z "${ssr_obfs_yn}" ]] && ssr_obfs_yn="y"
			[[ $ssr_obfs_yn == [Yy] ]] && ssr_obfs=${ssr_obfs}"_compatible"
			echo
	fi
}
Set_config_protocol_param(){
echo -e "$BARRA1"
	while true
	do
	echo -e "${ama_font_prefix}Ingrese la cantidad de dispositivos que desea configurar para limitar${Font_color_suffix} (${Green_font_prefix} auth_*La serie no es compatible con la version original. ${Font_color_suffix})"
echo -e "$BARRA"
	echo -e "${Tip} ${blue_font_prefix}Limite de numero de dispositivos: el numero de clientes que se pueden vincular al mismo tiempo por puerto (modo multipuerto, cada puerto se calcula de forma independiente), el minimo recomendado es 2.${Font_color_suffix}"
echo -e "$BARRA1"
	stty erase '^H' && read -p "(Predeterminado: Ilimitado):" ssr_protocol_param
	[[ -z "$ssr_protocol_param" ]] && ssr_protocol_param="" && echo && break
	expr ${ssr_protocol_param} + 0 &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_protocol_param} -ge 1 ]] && [[ ${ssr_protocol_param} -le 9999 ]]; then
			echo && echo ${Separator_1} && echo -e "${blan_font_prefix}Limite del dispositivo :${Font_color_suffix} ${Green_font_prefix}${ssr_protocol_param}${Font_color_suffix}" && echo ${Separator_1} && echo
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
echo -e "$BARRA1"
	while true
	do
	echo -e "${ama_font_prefix}Introduzca el limite del hilo unico del usuario que se establecera${Font_color_suffix} ${blan_font_prefix}(in KB/S)${Font_color_suffix}"
echo -e "$BARRA"
	stty erase '^H' && read -p "(Predterminado: Ilimitado):" ssr_speed_limit_per_con
	[[ -z "$ssr_speed_limit_per_con" ]] && ssr_speed_limit_per_con=0 && echo && break
	expr ${ssr_speed_limit_per_con} + 0 &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_speed_limit_per_con} -ge 1 ]] && [[ ${ssr_speed_limit_per_con} -le 131072 ]]; then
			echo && echo ${Separator_1} && echo -e "${blan_font_prefix}Limite de velocidad de subproceso unico :${Font_color_suffix} ${Green_font_prefix}${ssr_speed_limit_per_con} KB/S${Font_color_suffix}" && echo ${Separator_1} && echo
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
echo -e "$BARRA1"
	while true
	do
	echo
	echo -e "${ama_font_prefix}Ingrese el limite de velocidad de usuario maximo que desea establecer${Font_color_suffix} ${blan_font_prefix}(in KB/S)${Font_color_suffix}"
echo -e "$BARRA"
	echo -e "${Tip} ${blue_font_prefix}Limite de velocidad del puerto total: el limite de velocidad total de un solo puerto.${Font_color_suffix}"
echo -e "$BARRA1"
	stty erase '^H' && read -p "(Predeterminado: Ilimitado):" ssr_speed_limit_per_user
	[[ -z "$ssr_speed_limit_per_user" ]] && ssr_speed_limit_per_user=0 && echo && break
	expr ${ssr_speed_limit_per_user} + 0 &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_speed_limit_per_user} -ge 1 ]] && [[ ${ssr_speed_limit_per_user} -le 131072 ]]; then
			echo && echo ${Separator_1} && echo -e "${blan_font_prefix}Limite total de velocidad del usuario :S${Font_color_suffix} ${Green_font_prefix}${ssr_speed_limit_per_user} KB/S${Font_color_suffix}" && echo ${Separator_1} && echo
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
echo -e "$BARRA1"
	while true
	do
	echo
	echo -e "${ama_font_prefix}Ingrese la cantidad total de trafico disponible para que el usuario la configureS${Font_color_suffix} ${blan_font_prefix}(en GB, 1-838868 GB)S${Font_color_suffix}"
echo -e "$BARRA"
	stty erase '^H' && read -p "(Predeterminado: Ilimitado):" ssr_transfer
	[[ -z "$ssr_transfer" ]] && ssr_transfer="838868" && echo && break
	expr ${ssr_transfer} + 0 &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_transfer} -ge 1 ]] && [[ ${ssr_transfer} -le 838868 ]]; then
			echo && echo ${Separator_1} && echo -e "${blan_font_prefix}Trafico total de usuarios :${Font_color_suffix} ${Green_font_prefix}${ssr_transfer} GB${Font_color_suffix}" && echo ${Separator_1} && echo
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
echo -e "$BARRA1"
	echo -e "${ama_font_prefix}Puerto prohibido${Font_color_suffix}"
echo -e "$BARRA"
	echo -e "${Tip} ${blue_font_prefix}Puertos prohibidos: por ejemplo, si no permite el acceso al puerto 25, los usuarios no podran acceder al puerto de correo 25 a traves del proxy de SSR. Si 80,443 esta desactivado, los usuarios no podran Acceda a los sitios http/https normalmente.${Font_color_suffix}"
echo -e "$BARRA1"
	stty erase '^H' && read -p "(Predeterminado: permitir todo):" ssr_forbid
	[[ -z "${ssr_forbid}" ]] && ssr_forbid=""
	echo && echo ${Separator_1} && echo -e "${blan_font_prefix}Puerto prohibido :${Font_color_suffix} ${Green_font_prefix}${ssr_forbid}${Font_color_suffix}" && echo ${Separator_1} && echo
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
			[[ "${ssr_port_num}" == "null" ]] && echo -e "${Error}Obtener actualPuerto [${ssr_port}] Numero de filas fallidas!" && exit 1
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
			echo "Cancelado..." && exit 0
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
			echo -e "${Error} ¡La IP del servidor o el nombre de dominio obtenidos fallaron!" && exit 1
		else
			echo -e "${Info} La IP del servidor o el nombre de dominio actualmente configurados es ${Green_font_prefix}${server_pub_addr}${Font_color_suffix}"
		fi
	fi
	echo "${ama_font_prefix}Introduzca la IP del servidor o el nombre de dominio que se mostrara en la configuración del usuario${Font_color_suffix}"
echo -e "$BARRA1"
	stty erase '^H' && read -p "(Predeterminado: Predeterminado:Deteccion automatica de la red externa IP):" ssr_server_pub_addr
	if [[ -z "${ssr_server_pub_addr}" ]]; then
		Get_IP
		if [[ ${ip} == "VPS_IP" ]]; then
			while true
			do
			stty erase '^H' && read -p "${Error} La deteccion automatica de la IP de la red externa fallo, ingrese manualmente la IP del servidor o el nombre de dominio" ssr_server_pub_addr
			if [[ -z "$ssr_server_pub_addr" ]]; then
				echo -e "${Error}¡No puede estar vacio!"
			else
				break
			fi
			done
		else
			ssr_server_pub_addr="${ip}"
		fi
	fi
	echo && echo ${Separator_1} && echo -e "	IP o nombre de dominio: ${Green_font_prefix}${ssr_server_pub_addr}${Font_color_suffix}" && echo ${Separator_1} && echo
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
#Modificar la información de configuración
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
		echo -e "${Info} Acuerdo de usuario modificacion exito ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} (Nota: la configuracion más reciente puede demorar unos 10 segundos)"
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
		echo -e "${Info} Parametros de negociación del usuario (numero de dispositivos limite) modificados correctamente ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} (Nota: puede tomar aproximadamente 10 segundos aplicar la ultima configuracion)"
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
		echo -e "${Error} Usuario Puerto la modificación del limite de velocidad total fallo ${Green_font_prefix}[Port: ${ssr_port}]${Font_color_suffix} " && exit 1
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
	# [[ ! -e "/usr/local/shadowsocksr-manyuser/" ]] && echo -e "${Error} Fallo la descompresión del servidor ShadowsocksR !" && rm -rf manyuser.zip && exit 1
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
			echo -e "${Error} Fallo la descarga de la secuencia de comandos de administración de servicio de ShadowsocksR!" && exit 1
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
	cp -f /usr/share/zoneinfo/America/Mexico_City /etc/localtime
	if [[ ${release} == "centos" ]]; then
		/etc/init.d/crond restart
	else
		/etc/init.d/cron restart
	fi
}
Install_SSR(){
clear
	check_root
	[[ -e ${ssr_folder} ]] && echo -e "${Error} La carpeta ShadowsocksR ha sido creada, por favor verifique (si la instalacion falla, desinstale primero) !" && exit 1
	echo -e "${Info} Comience la configuracion de la cuenta de ShadowsocksR..."
echo -e "$BARRA1"
	Set_user_api_server_pub_addr
	Set_config_all
echo -e "$BARRA1"
	echo -e "${Info} Comience a instalar / configurar las dependencias de ShadowsocksR ..."
	Installation_dependency
echo -e "$BARRA1"
	echo -e "${Info} Iniciar descarga / Instalar ShadowsocksR File ..."
	Download_SSR
echo -e "$BARRA1"
	echo -e "${Info} Iniciar descarga / Instalar ShadowsocksR Service Script(init)..."
	Service_SSR
echo -e "$BARRA1"
	echo -e "${Info} Iniciar descarga / instalar JSNO Parser JQ ..."
	JQ_install
echo -e "$BARRA1"
	echo -e "${Info} Comience a agregar usuario inicial ..."
	Add_port_user "install"
echo -e "$BARRA1"
	echo -e "${Info} Empezar a configurar el firewall de iptables ..."
	Set_iptables
echo -e "$BARRA1"
	echo -e "${Info} Comience a agregar reglas de firewall de iptables ..."
	Add_iptables
echo -e "$BARRA1"
	echo -e "${Info} Comience a guardar las reglas del servidor de seguridad de iptables ..."
	Save_iptables
echo -e "$BARRA1"
	echo -e "${Info} Todos los pasos para iniciar el servicio ShadowsocksR ..."
	Start_SSR
	Get_User_info "${ssr_port}"
	View_User_info
read -p "Enter para continuar" enter
${SCPfrm}/ssrrmu.sh
}
Update_SSR(){
	SSR_installation_status
	# echo -e "Debido a que el bebé roto actualiza el servidor ShadowsocksR, entonces."
	cd ${ssr_folder}
	git pull
	Restart_SSR
${SCPfrm}/ssrrmu.sh
}
Uninstall_SSR(){
	[[ ! -e ${ssr_folder} ]] && echo -e "${Error} ShadowsocksR no esta instalado, por favor, compruebe!" && exit 1
	echo "yes para desinstalar ShadowsocksR[y/N]" && echo
echo -e "$BARRA1" 
	stty erase '^H' && read -p "(Predeterminado: n):" unyn
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
${SCPfrm}/ssrrmu.sh
}
Check_Libsodium_ver(){
	echo -e "${Info} Descargando la ultima version de libsodium"
	Libsodiumr_ver=$(wget -qO- "https://github.com/jedisct1/libsodium/tags"|grep "/jedisct1/libsodium/releases/tag/"|head -1|sed -r 's/.*tag\/(.+)\">.*/\1/')
	[[ -z ${Libsodiumr_ver} ]] && Libsodiumr_ver=${Libsodiumr_ver_backup}
	echo -e "${Info} La ultima version de libsodium es ${Green_font_prefix}${Libsodiumr_ver}${Font_color_suffix} !"
}
Install_Libsodium(){
	if [[ -e ${Libsodiumr_file} ]]; then
		echo -e "${Error} libsodium ya instalado, ¿quieres actualizar?[y/N]"
		stty erase '^H' && read -p "(Default: n):" yn
		[[ -z ${yn} ]] && yn="n"
		if [[ ${yn} == [Nn] ]]; then
			echo "Cancelado..." && exit 1
		fi
	else
		echo -e "${Info} libsodium no instalado, instalacion iniciada ..."
	fi
	Check_Libsodium_ver
	if [[ ${release} == "centos" ]]; then
		yum -y actualización
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
	echo && echo -e "${Info} libsodium Éxito de instalación!" && echo
${SCPfrm}/ssrrmu.sh
}
#Mostrar información de conexión
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
		user_list_all=${user_list_all}"Puerto: ${Green_font_prefix}"${user_port}"${Font_color_suffix}, Usuarios en linea: ${Green_font_prefix}"${user_IP_total}"${Font_color_suffix}, IP vinculada en linea: ${Green_font_prefix}${user_IP}${Font_color_suffix}\n"
		user_IP=""
	done
	echo -e "Total de usuarios: ${Green_background_prefix} "${user_total}" ${Font_color_suffix} Numero total de usuarios en linea: ${Green_background_prefix} "${IP_total}" ${Font_color_suffix} "
	echo -e "${user_list_all}"
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
		user_list_all=${user_list_all}"Puerto: ${Green_font_prefix}"${user_port}"${Font_color_suffix}, El numero total de IPs vinculadas: ${Green_font_prefix}"${user_IP_total}"${Font_color_suffix}, IP vinculada en linea: ${Green_font_prefix}${user_IP}${Font_color_suffix}\n"
		user_IP=""
	done
	echo -e "Total de usuarios: ${Green_background_prefix} "${user_total}" ${Font_color_suffix} Numero total de usuarios en linea: ${Green_background_prefix} "${IP_total}" ${Font_color_suffix} "
	echo -e "${user_list_all}"
}
View_user_connection_info(){
clear
	SSR_installation_status
	echo && echo -e "Seleccione el formato para mostrar :
${BARRA1}
 ${Green_font_prefix}[1] >${Font_color_suffix} ${blan_font_prefix}Mostrar IP${Font_color_suffix} 
${BARRA}
 ${Green_font_prefix}[2] >${Font_color_suffix} ${blan_font_prefix}Mostrar IP + Resolver el nombre DNS${Font_color_suffix}
${BARRA1}
 ${Green_font_prefix}[3] >${Font_color_suffix} ${blan_font_prefix}SALIR (al menu shadowsocksR manager)"
echo -e "$BARRA1"
	stty erase '^H' && read -p "(Predeterminado: 1):" ssr_connection_info
echo -e "$BARRA1"
	[[ -z "${ssr_connection_info}" ]] && ssr_connection_info="1"
	if [[ ${ssr_connection_info} == "1" ]]; then
		View_user_connection_info_1 ""
	elif [[ ${ssr_connection_info} == "2" ]]; then
		echo -e "${Tip} ${blue_font_prefix}Detectar IP (ipip.net)puede llevar mas tiempo si hay muchas IPs${Font_color_suffix}"
       elif [[ ${ssr_connection_info} == "3" ]]; then
              ${SCPfrm}/ssrrmu.sh
echo -e "$BARRA"
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
#Modificar la configuración del usuario
Modify_port(){
echo -e "$BARRA1"
	List_port_user
	while true
	do
		echo -e "Por favor ingrese el usuario (Puerto) que tiene que ser modificado" 
echo -e "$BARRA1"
		stty erase '^H' && read -p "(Predeterminado: cancelar):" ssr_port
		[[ -z "${ssr_port}" ]] && echo -e "Cancelado ..." && exit 1
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
	echo && echo -e "${ama_font_prefix}que quieres hacer?${Font_color_suffix}
${BARRA1}
 ${Green_font_prefix}[1] >${Font_color_suffix}  ${blan_font_prefix}Agregar y configurar usuario${Font_color_suffix}
${BARRA}
 ${Green_font_prefix}[2] >${Font_color_suffix}  ${blan_font_prefix}Eliminar la configuración del usuario${Font_color_suffix}
${BARRA}
${asul_font_prefix}============= ${ama_font_prefix}Modificar la configuracion del usuario ${asul_font_prefix}==============
${BARRA1}
 ${Green_font_prefix}[3] >${Font_color_suffix}  ${blan_font_prefix}Modificar contrasena de usuario${Font_color_suffix}
${BARRA}
 ${Green_font_prefix}[4] >${Font_color_suffix}  ${blan_font_prefix}Modificar el metodo de cifrado${Font_color_suffix}
${BARRA}
 ${Green_font_prefix}[5] >${Font_color_suffix}  ${blan_font_prefix}Modificar el protocolo${Font_color_suffix}
${BARRA}
 ${Green_font_prefix}[6] >${Font_color_suffix}  ${blan_font_prefix}Modificar ofuscacion${Font_color_suffix}
${BARRA}
 ${Green_font_prefix}[7] >${Font_color_suffix}  ${blan_font_prefix}Modificar el limite del dispositivo${Font_color_suffix}
${BARRA}
 ${Green_font_prefix}[8] >${Font_color_suffix}  ${blan_font_prefix}Modificar el limite de velocidad de un solo hilo${Font_color_suffix}
${BARRA}
 ${Green_font_prefix}[9] >${Font_color_suffix}  ${blan_font_prefix}Modificar limite de velocidad total del usuario${Font_color_suffix}
${BARRA}
 ${Green_font_prefix}[10] >${Font_color_suffix} ${blan_font_prefix}Modificar el trafico total del usuario${Font_color_suffix}
${BARRA}
 ${Green_font_prefix}[11] >${Font_color_suffix} ${blan_font_prefix}Modificar los puertos prohibidos del usuario${Font_color_suffix}
${BARRA}
 ${Green_font_prefix}[12] >${Font_color_suffix} ${blan_font_prefix}Modificar la configuracion completa${Font_color_suffix}
${BARRA}
${asul_font_prefix}================ ${ama_font_prefix}Otras Configuraciones ${asul_font_prefix}=================
${BARRA}
 ${Green_font_prefix}[13] >${Font_color_suffix} ${blan_font_prefix}Modificar la IP que se muestra en el perfil del usuario
${BARRA}
 ${Green_font_prefix}[14] >${Font_color_suffix} ${blan_font_prefix}SALIR (al menu shadowsocksR manager)
${BARRA1}
 ${Tip} El nombre de usuario y el puerto del usuario no se pueden modificar. Si necesita modificarlos, use el script para modificar manualmente la funcion !"
echo -e "$BARRA1"
	stty erase '^H' && read -p "(Predeterminado: cancelar):" ssr_modify
	[[ -z "${ssr_modify}" ]] && echo "Cancelado ..." && exit 1
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
      elif [[ ${ssr_modify} == "14" ]]; then
              ${SCPfrm}/ssrrmu.sh
	else
		echo -e "${Error} Ingrese el numero correcto(1-13)" && exit 1
	fi
${SCPfrm}/ssrrmu.sh
}
List_port_user(){
	user_info=$(python mujson_mgr.py -l)
	user_total=$(echo "${user_info}"|wc -l)
	[[ -z ${user_info} ]] && echo -e "${Error} No encontre al usuario, por favor verifica otra vez !" && exit 1
	user_list_all=""
	for((integer = 1; integer <= ${user_total}; integer++))
	do
		user_port=$(echo "${user_info}"|sed -n "${integer}p"|awk '{print $4}')
		user_username=$(echo "${user_info}"|sed -n "${integer}p"|awk '{print $2}'|sed 's/\[//g;s/\]//g')
		Get_User_transfer "${user_port}"
		user_list_all=${user_list_all}"Nombre de usuario: ${Green_font_prefix} "${user_username}"${Font_color_suffix} Port: ${Green_font_prefix}"${user_port}"${Font_color_suffix} Uso del trafico (Usado + restante = total): ${Green_font_prefix}${transfer_enable_Used_2}${Font_color_suffix} + ${Green_font_prefix}${transfer_enable_Used}${Font_color_suffix} = ${Green_font_prefix}${transfer_enable}${Font_color_suffix}\n\n"
	done
	echo && echo -e "Numero total de usuarios ${Green_background_prefix} "${user_total}" ${Font_color_suffix}"
echo -e "$BARRA"
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
				echo -e "${Info} Usuario agregado exitosamente ${Green_font_prefix}[Nombre de usuario: ${ssr_user} , Puerto: ${ssr_port}]${Font_color_suffix} "
				echo
				stty erase '^H' && read -p "Continuar para agregar la configuracion del usuario?[Y/n]:" addyn
				[[ -z ${addyn} ]] && addyn="y"
				if [[ ${addyn} == [Nn] ]]; then
					Get_User_info "${ssr_port}"
					View_User_info
					break
				else
					echo -e "${Info} Continuar agregando configuración de usuario ..."
				fi
			fi
		done
	fi
}
Del_port_user(){
clear
echo -e "$BARRA1"

	List_port_user
	while true
	do
		echo -e "Por favor ingrese el usuario que desea ingresar a Puerto"
echo -e "$BARRA"
		stty erase '^H' && read -p "(Predeterminado:Cancelar):" del_user_port
		[[ -z "${del_user_port}" ]] && echo -e "Cancelado ..." && exit 1
		del_user=$(cat "${config_user_mudb_file}"|grep '"puerto": '"${del_user_port}"',')
		if [[ ! -z ${del_user} ]]; then
			port=${del_user_port}
			match_del=$(python mujson_mgr.py -d -p "${del_user_port}"|grep -w "eliminar usuario ")
			if [[ -z "${match_del}" ]]; then
				echo -e "${Error} La eliminacion del usuario fallo ${Green_font_prefix}[Puerto: ${del_user_port}]${Font_color_suffix} "
			else
				Del_iptables
				Save_iptables
				echo -e "${Info} Usuario eliminado exitosamente ${Green_font_prefix}[Puerto: ${del_user_port}]${Font_color_suffix} "
			fi
			break
		else
			echo -e "${Error} Puerto Introduzca el Puerto correcto!"
		fi
	done
}
Manually_Modify_Config(){
clear
echo -e "$BARRA1"
	SSR_installation_status
	nano ${config_user_mudb_file}
	echo "Si reiniciar ShadowsocksR ahora?[Y/n]" && echo
echo -e "$BARRA"
	stty erase '^H' && read -p "(Predeterminado: y):" yn
	[[ -z ${yn} ]] && yn="y"
	if [[ ${yn} == [Yy] ]]; then
		Restart_SSR
	fi
${SCPfrm}/ssrrmu.sh
}
Clear_transfer(){
clear
echo -e "$BARRA1"
	SSR_installation_status
	echo && echo -e "que quieres hacer?
${BARRA1}
 ${Green_font_prefix}[1] >${Font_color_suffix}  ${blan_font_prefix}Borrar el trafico de un solo usuario
${BARRA}
 ${Green_font_prefix}[2] >${Font_color_suffix}  ${blan_font_prefix}Borrar todo el trafico de usuarios (irreparable)
${BARRA}
 ${Green_font_prefix}[3] >${Font_color_suffix}  ${blan_font_prefix}Todo el trafico de usuarios se borra en el inicio
${BARRA}
 ${Green_font_prefix}[4] >${Font_color_suffix}  ${blan_font_prefix}Deja de cronometrar todo el trafico de usuarios
${BARRA}
 ${Green_font_prefix}[5] >${Font_color_suffix}  ${blan_font_prefix}Modificar la sincronizacion de todo el trafico de usuarios
${BARRA}
 ${Green_font_prefix}[6] >${Font_color_suffix}  ${blan_font_prefix}SALIR (al menu shadwsocksR manager)"
echo -e "$BARRA1"
	stty erase '^H' && read -p "(Predeterminado:Cancelar):" ssr_modify
	[[ -z "${ssr_modify}" ]] && echo "Cancelado ..." && exit 1
	if [[ ${ssr_modify} == "1" ]]; then
		Clear_transfer_one
	elif [[ ${ssr_modify} == "2" ]]; then
echo -e "$BARRA"
		echo "Esta seguro de que desea borrar todo el trafico de usuario[y/N]" && echo
echo -e "$BARRA"
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
       elif [[ ${ssr_modify} == "6" ]]; then
              ${SCPfrm}/ssrrmu.sh
	else
		echo -e "${Error} Por favor numero de (1-5)" && exit 1
	fi
${SCPfrm}/ssrrmu.sh
}
Clear_transfer_one(){
clear
echo -e "$BARRA1"
	List_port_user
	while true
	do
		echo -e "Por favor ingrese el usuario que desea de Puerto"
echo -e "$BARRA"
		stty erase '^H' && read -p "(Predeterminado: Cancelar):" Clear_transfer_user_port
		[[ -z "${Clear_transfer_user_port}" ]] && echo -e "Cancelado ..." && exit 1
		Clear_transfer_user=$(cat "${config_user_mudb_file}"|grep '"Puerto": '"${Clear_transfer_user_port}"',')
		if [[ ! -z ${Clear_transfer_user} ]]; then
			match_clear=$(python mujson_mgr.py -c -p "${Clear_transfer_user_port}"|grep -w "clear user ")
			if [[ -z "${match_clear}" ]]; then
				echo -e "${Error} El usuario ha utilizado el trafico borrado fallido ${Green_font_prefix}[Port: ${Clear_transfer_user_port}]${Font_color_suffix} "
			else
				echo -e "${Info} El usuario ha utilizado el trafico para borrar con exito ${Green_font_prefix}[Port: ${Clear_transfer_user_port}]${Font_color_suffix} "
			fi
			break
		else
			echo -e "${Error} Puerto Introduzca el Puerto correcto!"
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
 ${Green_font_prefix} 0 2 1 * * ${Font_color_suffix} Representante 1er, 2:00, claro, trafico usado.
${BARRA}
 ${Green_font_prefix} 0 2 15 * * ${Font_color_suffix} Representativo El 1 ° 2} representa el 15 ° 2:00 minutos Punto de flujo usado despejado 0 minutos Borrar flujo usado
${BARRA}
 ${Green_font_prefix} 0 2 */7 * * ${Font_color_suffix} Representante 7 días 2: 0 minutos despeja el trafico usado.
${BARRA}
 ${Green_font_prefix} 0 2 * * 0 ${Font_color_suffix} Representa todos los domingos (7) para despejar el trafico utilizado.
${BARRA}
 ${Green_font_prefix} 0 2 * * 3 ${Font_color_suffix} Representante (3) Flujo de trafico usado despejado"
echo -e "$BARRA"
	stty erase '^H' && read -p "(Default: 0 2 1 * * 1 de cada mes 2:00):" Crontab_time
	[[ -z "${Crontab_time}" ]] && Crontab_time="0 2 1 * *"
}
Start_SSR(){
clear
	SSR_installation_status
	check_pid
	[[ ! -z ${PID} ]] && echo -e "${Error} ShadowsocksR se esta ejecutando!" && exit 1
	/etc/init.d/ssrmu start
${SCPfrm}/ssrrmu.sh
}
Stop_SSR(){
clear
	SSR_installation_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} ¡ShadowsocksR no esta funcionando!" && exit 1
	/etc/init.d/ssrmu stop
${SCPfrm}/ssrrmu.sh
}
Restart_SSR(){
clear
	SSR_installation_status
	check_pid
	[[ ! -z ${PID} ]] && /etc/init.d/ssrmu stop
	/etc/init.d/ssrmu start
${SCPfrm}/ssrrmu.sh
}
View_Log(){
	SSR_installation_status
	[[ ! -e ${ssr_log_file} ]] && echo -e "${Error} ¡El registro de ShadowsocksR no existe!" && exit 1
	echo && echo -e "${Tip} Presione ${Red_font_prefix}Ctrl+C ${Font_color_suffix} Registro de registro de terminacion" && echo
	tail -f ${ssr_log_file}
${SCPfrm}/ssrrmu.sh
}
#Afilado
Configure_Server_Speeder(){
clear
echo -e "$BARRA1"
	echo && echo -e " ${ama_font_prefix}Que vas a hacer
${BARRA1}
 ${Green_font_prefix}[1] >${Font_color_suffix} ${blan_font_prefix}Velocidad aguda
${BARRA}
 ${Green_font_prefix}[2] >${Font_color_suffix} ${blan_font_prefix}Velocidad aguda sharp
${asul_font_prefix}==================================================================
 ${Green_font_prefix}[3] >${Font_color_suffix} ${blan_font_prefix}Velocidad media
${BARRA}
 ${Green_font_prefix}[4] >${Font_color_suffix} ${blan_font_prefix}Velocidad media sharp
${asul_font_prefix}==================================================================
 ${Green_font_prefix}[5] >${Font_color_suffix} ${blan_font_prefix}Reinicie la velocidad aguda / sharp
${BARRA}
 ${Green_font_prefix}[6] >${Font_color_suffix} ${blan_font_prefix}Estado aguda / sharp
${BARRA}
 ${Green_font_prefix}[7] >${Font_color_suffix} ${blan_font_prefix}SALIR (al menu shadowsocksR manager)
 ${BARRA}
${Tip} Sharp y LotServer no se pueden instalar / iniciar al mismo tiempo"
echo -e "$BARRA1"
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
       elif [[ ${server_speeder_num} == "7" ]]; then       
              ${SCPfrm}/ssrrmu.sh
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
echo -e "$BARRA1"
	echo "yes para desinstalar Speed ??Speed ??(Server Speeder)[y/N]" && echo
echo -e "$BARRA"
	stty erase '^H' && read -p "(Predeterminado: n):" unyn
	[[ -z ${unyn} ]] && echo && echo "Cancelado ..." && exit 1
	if [[ ${unyn} == [Yy] ]]; then
		chattr -i /serverspeeder/etc/apx*
		/serverspeeder/bin/serverSpeeder.sh uninstall -f
		echo && echo "Server Speeder ¡Desinstalacion completa!" && echo
	fi
}
# LotServer
Configure_LotServer(){
clear
echo -e "$BARRA1"
	echo && echo -e "${ama_font_prefix}Que vas a hacer?
${BARRA}
 ${Green_font_prefix}[1] >${Font_color_suffix} ${blan_font_prefix}Instalar LotServer
${BARRA}
 ${Green_font_prefix}[2] >${Font_color_suffix} ${blan_font_prefix}Desinstalar LotServer
${BARRA}
 ${Green_font_prefix}[3] >${Font_color_suffix} ${blan_font_prefix}Iniciar LotServer
${BARRA}
 ${Green_font_prefix}[4] >${Font_color_suffix} ${blan_font_prefix}Detener LotServer
${BARRA}
 ${Green_font_prefix}[5] >${Font_color_suffix} ${blan_font_prefix}Reiniciar LotServer
${BARRA}
 ${Green_font_prefix}[6] >${Font_color_suffix} ${blan_font_prefix}Ver el estado de LotServer
${BARRA}
 ${Green_font_prefix}[7] >${Font_color_suffix} ${blan_font_prefix}SALIR (al menu shadowsocks manager)
${BARRA1}
${Tip} ${blue_font_prefix}Sharp y LotServer no se pueden instalar / iniciar al mismo tiempo"
echo -e "$BARRA1"

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
       elif [[ ${lotserver_num} == "7" ]]; then
              ${SCPfrm}/ssrrmu.sh
	else
		echo -e "${Error} Por favor numero(1-6)" && exit 1
	fi
}
Install_LotServer(){
	[[ -e ${LotServer_file} ]] && echo -e "${Error} LotServer está instalado!" && exit 1
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
echo -e "$BARRA1"
	echo "Desinstalar Para desinstalar LotServer[y/N]" && echo
echo -e "$BARRA"
	stty erase '^H' && read -p "(Predeterminado: n):" unyn
echo -e "$BARRA"
	[[ -z ${unyn} ]] && echo && echo "Cancelado ..." && exit 1
	if [[ ${unyn} == [Yy] ]]; then
		wget --no-check-certificate -qO /tmp/appex.sh "https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh" && bash /tmp/appex.sh 'uninstall'
		echo && echo "La desinstalacion de LotServer esta completa!" && echo
	fi
}
# BBR
Configure_BBR(){
clear
echo -e "$BARRA1"
	echo && echo -e "  ${ama_font_prefix}Que vas a hacer?
${BARRA}	
 ${Green_font_prefix}[1] >${Font_color_suffix} ${blan_font_prefix}Instalar BBR
${BARRA}
 ${Green_font_prefix}[2] >${Font_color_suffix} ${blan_font_prefix}Iniciar BBR
${BARRA}
 ${Green_font_prefix}[3] >${Font_color_suffix} ${blan_font_prefix}Dejar de BBR
${BARRA}
 ${Green_font_prefix}[4] >${Font_color_suffix} ${blan_font_prefix}Ver el estado de BBR
${BARRA}
 ${Green_font_prefix}[5] >${Font_color_suffix} ${blan_font_prefix}SALIR (al menu shadowsocks manager)"
echo -e "$BARRA"
echo -e "${Green_font_prefix} [Por favor, preste atencion antes de la instalacion] ${Font_color_suffix}
${BARRA1}
${blue_font_prefix}1. Abra BBR, reemplace, hay un error de reemplazo (despues de reiniciar)
${BARRA}
${blue_font_prefix}2. Este script solo es compatible con los nucleos de reemplazo de Debian / Ubuntu. OpenVZ y Docker no admiten el reemplazo de los nucleos.
${BARRA}
${blue_font_prefix}3. Debian reemplaza el proceso del kernel [¿Desea finalizar el kernel de desinstalacion], seleccione ${Green_font_prefix} NO ${Font_color_suffix}"
echo -e "$BARRA1"
	stty erase '^H' && read -p "(Predeterminado: Cancelar):" bbr_num
echo -e "$BARRA1"
	[[ -z "${bbr_num}" ]] && echo "Cancelado..." && exit 1
	if [[ ${bbr_num} == "1" ]]; then
		Install_BBR
	elif [[ ${bbr_num} == "2" ]]; then
		Start_BBR
	elif [[ ${bbr_num} == "3" ]]; then
		Stop_BBR
	elif [[ ${bbr_num} == "4" ]]; then
		Status_BBR
       elif [[ ${bbr_num} == "5" ]]; then
             ${SCPfrm}/ssrrmu.sh
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
# Otros
Other_functions(){
clear
echo -e "$BARRA1"
	echo && echo -e "  ${ama_font_prefix}Que vas a hacer?
${BARRA1}	
  ${Green_font_prefix}[1].${Font_color_suffix} ${blan_font_prefix}Configurar BBR
${BARRA}
  ${Green_font_prefix}[2].${Font_color_suffix} ${blan_font_prefix}Velocidad de configuracion (ServerSpeeder)
${BARRA}
  ${Green_font_prefix}[3].${Font_color_suffix} ${blan_font_prefix}Configurar LotServer (Rising Parent)
${BARRA}
${asul_font_prefix}==================================================================
  ${Green_font_prefix}[4].${Font_color_suffix} ${blan_font_prefix}Llave de bloqueo BT/PT/SPAM (iptables)
${BARRA}
  ${Green_font_prefix}[5].${Font_color_suffix} ${blan_font_prefix}Llave de desbloqueo BT/PT/SPAM (iptables)
${asul_font_prefix}==================================================================
  ${Green_font_prefix}[6].${Font_color_suffix} ${blan_font_prefix}Cambiar modo de salida de registro ShadowsocksR (Modo bajo o verboso)
${BARRA}
  ${Green_font_prefix}[7].${Font_color_suffix} ${blan_font_prefix}Supervisar el estado de ejecucion del servidor ShadowsocksR
${BARRA}
  ${Green_font_prefix}[8].${Font_color_suffix} ${blan_font_prefix}SALIR (al menu shadowsocks manager)
${BARRA1}
${Tip} ${blue_font_prefix}Sharp / LotServer / BBR no es compatible con OpenVZ!
${Tip} ${blue_font_prefix}Y Speed y LotServer no pueden coexistir!
${BARRA}
${Tip} ${blue_font_prefix}Opcion  7:Esta funcion es adecuada para que el servidor SSR finalice los procesos regulares. Una vez que esta funcion esta habilitada, sera detectada cada minuto. Cuando el proceso no existe, el servidor SSR se inicia automaticamente." && echo
echo -e "$BARRA1"
	stty erase '^H' && read -p "(Predeterminado: cancelar):" other_num
	[[ -z "${other_num}" ]] && echo "Cancelado..." && exit 1
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
              ${SCPfrm}/ssrrmu.sh
	else
		echo -e "${Error} Por favor numero [1-7]" && exit 1
	fi
${SCPfrm}/ssrrmu.sh
}
#ProhibidoBT PT SPAM
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
echo -e "$BARRA"
	SSR_installation_status
	[[ ! -e ${jq_file} ]] && echo -e "${Error} JQ parser No, por favor, compruebe!" && exit 1
	connect_verbose_info=`${jq_file} '.connect_verbose_info' ${config_user_file}`
	if [[ ${connect_verbose_info} = "0" ]]; then
		echo && echo -e "${blan_font_prefix}Modo de registro actual:${Font_color_suffix} ${Green_font_prefix}Registro de errores en modo simple${Font_color_suffix}"
echo -e "$BARRA"
		echo -e "[yes] ${blan_font_prefix}para cambiar a ${Green_font_prefix}Modo detallado (registro de conexion + registro de errores)${Font_color_suffix}ï¼Ÿ[y/N]"
echo -e "$BARRA"
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
		echo && echo -e "${blan_font_prefix}Modo de registro actual:${Font_color_suffix} ${Green_font_prefix}Modo detallado (conexion de conexion + registro de errores)${Font_color_suffix}"
echo -e "$BARRA"
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
echo -e "$BARRA"
	SSR_installation_status
	crontab_monitor_ssr_status=$(crontab -l|grep "ssrmu.sh monitor")
	if [[ -z "${crontab_monitor_ssr_status}" ]]; then
		echo && echo -e "${blan_font_prefix}Modo de monitoreo actual:${Font_color_suffix} ${Green_font_prefix}No monitoreado${Font_color_suffix}"
echo -e "$BARRA"
		echo -e "[yes] ${blan_font_prefix}para abrir${Font_color_suffix} ${Green_font_prefix}Servidor ShadowsocksR ejecutando monitoreo de estado${Font_color_suffix} ${blan_font_prefix}Funcion?${Font_color_suffix}"
              echo -e "${blan_font_prefix}(Cuando el proceso R lado SSR R)[Y/n]${Font_color_suffix}"

echo -e "$BARRA1"
		stty erase '^H' && read -p "(Predeterminado: y):" crontab_monitor_ssr_status_ny
		[[ -z "${crontab_monitor_ssr_status_ny}" ]] && crontab_monitor_ssr_status_ny="y"
		if [[ ${crontab_monitor_ssr_status_ny} == [Yy] ]]; then
			crontab_monitor_ssr_cron_start
		else
			echo && echo "	Cancelado ..." && echo
		fi
	else
		echo && echo -e "Modo de monitoreo actual: ${Green_font_prefix}Abierto${Font_color_suffix}"
echo -e "$BARRA"
		echo -e "yes para apagar ${Green_font_prefix}Servidor ShadowsocksR ejecutando monitoreo de estado${Font_color_suffix} Funcion? (procesar servidor SSR)[y/N]"
echo -e "$BARRA"
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
			echo -e "${Error} [$(date "+%Y-%m-%d %H:%M:%S %u %Z")] Falló el inicio del servidor ShadowsocksR..." | tee -a ${ssr_log_file} && exit 1
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
		echo -e "${Error} Falló el arranque del servidor ShadowsocksR!" && exit 1
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
		echo -e "${Error} Falló la detencion del servidor ShadowsocksR!" && exit 1
	else
		echo -e "${Info} La supervision del estado de ejecucion del servidor de ShadowsocksR se detiene correctamente!"
	fi
}
Update_Shell(){
clear
echo -e "$BARRA1"
	echo -e "${blan_font_prefix}La version actual es${Font_color_suffix} [ ${sh_ver} ], ${blan_font_prefix}Comenzamos a detectar la ultima version ...${Font_color_suffix}"
	sh_new_ver=$(wget --no-check-certificate -qO- "https://raw.githubusercontent.com/hybtoy/ssrrmu/master/ssrrmu.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
	[[ -z ${sh_new_ver} ]] && sh_new_ver=$(wget --no-check-certificate -qO- "https://raw.githubusercontent.com/hybtoy/ssrrmu/master/ssrrmu.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} Ultima version de deteccion !" && exit 0
	if [[ ${sh_new_ver} != ${sh_ver} ]]; then
		echo -e "${blan_font_prefix}Descubrir nueva version[ ${sh_new_ver} ], ¿Esta actualizado?${Font_color_suffix}[Y/n]"
echo -e "$BARRA1"
		stty erase '^H' && read -p "(Predeterminado: y):" yn
		[[ -z "${yn}" ]] && yn="y"
		if [[ ${yn} == [Yy] ]]; then
			cd "${file}"
			if [[ $sh_new_type == "github" ]]; then
				wget -N --no-check-certificate https://raw.githubusercontent.com/hybtoy/ssrrmu/master/ssrrmu.sh && chmod +x ssrrmu.sh
			fi
echo -e "$BARRA1"
			echo -e "El script ha sido actualizado a la ultima version.[ ${sh_new_ver} ] !${Font_color_suffix}"
		else
			echo && echo "	Cancelado ..." && echo
		fi
	else
echo -e "$BARRA"
		echo -e "${blan_font_prefix}Actualmente es la ultima version.[ ${sh_new_ver} ] !${Font_color_suffix}"
	fi
echo -e "$BARRA1"
	read -p "Enter para continuar" enter && ${SCPfrm}/ssrrmu.sh
${SCPfrm}/ssrrmu.sh
}
# Mostrar el estado del menú
menu_status(){
echo -e "$BARRA1"
	if [[ -e ${ssr_folder} ]]; then
		check_pid
		if [[ ! -z "${PID}" ]]; then
			echo -e " Estado actual: ${Green_font_prefix}Instalado${Font_color_suffix} y ${Green_font_prefix}Iniciado${Font_color_suffix}"
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
clear
	echo -e "  ${blue_font_prefix}ShadowsocksR Manager NEW ADMIN-DANKELTHAHER${Font_color_suffix}  ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
${BARRA1}

  ${Green_font_prefix}[1] >${Font_color_suffix} ${blan_font_prefix}Instalar ShadowsocksR 
${BARRA}
  ${Green_font_prefix}[2] >${Font_color_suffix} ${blan_font_prefix}Actualizar ShadowsocksR${Font_color_suffix}
${BARRA}
  ${Green_font_prefix}[3] >${Font_color_suffix} ${blan_font_prefix}Desinstalar ShadowsocksR${Font_color_suffix}
${BARRA}
  ${Green_font_prefix}[4] >${Font_color_suffix} ${blan_font_prefix}Instalar libsodium (chacha20)${Font_color_suffix}
${BARRA}
${asul_font_prefix}=======================${ama_font_prefix}CONFIGURAR USUARIOS${asul_font_prefix}==========================
${BARRA}
  ${Green_font_prefix}[5] >${Font_color_suffix} ${blan_font_prefix}Verifique la informacion de la cuenta${Font_color_suffix}
${BARRA}
  ${Green_font_prefix}[6] >${Font_color_suffix} ${blan_font_prefix}Mostrar la informacion de conexion${Font_color_suffix} 
${BARRA}
  ${Green_font_prefix}[7] >${Font_color_suffix} ${blan_font_prefix}Agregar/Modificar/Eliminar la configuracion del usuario${Font_color_suffix}  
${BARRA}
  ${Green_font_prefix}[8] >${Font_color_suffix} ${blan_font_prefix}Modificar manualmente la configuracion del usuario${Font_color_suffix}
${BARRA}
  ${Green_font_prefix}[9] >${Font_color_suffix} ${blan_font_prefix}Borrar el trafico usado${Font_color_suffix}
${BARRA}
${asul_font_prefix}======================${ama_font_prefix}SERVICIOS SHADOWSOCKSR${asul_font_prefix}========================
${BARRA}
 ${Green_font_prefix} [10] >${Font_color_suffix} ${blan_font_prefix}Iniciar ShadowsocksR${Font_color_suffix}
${BARRA}
 ${Green_font_prefix} [11] >${Font_color_suffix} ${blan_font_prefix}Detener ShadowsocksR${Font_color_suffix}
${BARRA}
 ${Green_font_prefix} [12] >${Font_color_suffix} ${blan_font_prefix}Reiniciar ShadowsocksR${Font_color_suffix}
${BARRA}
 ${Green_font_prefix} [13] >${Font_color_suffix} ${blan_font_prefix}Verificar registro de ShadowsocksR${Font_color_suffix}
${BARRA}
${asul_font_prefix}========================${ama_font_prefix}FUNCIONES EXTRA${asul_font_prefix}============================
${BARRA}
 ${Green_font_prefix} [14] >${Font_color_suffix} ${blan_font_prefix}Otras Funciones${Font_color_suffix}
${BARRA}
 ${Green_font_prefix} [15] >${Font_color_suffix} ${blan_font_prefix}Actualizar script${Font_color_suffix} 
${BARRA1}
${Green_font_prefix}  [16] >${Font_color_suffix} ${blan_font_prefix}SALIR${Font_color_suffix}
 "
	menu_status
	echo && stty erase '^H' && read -p "Porfavor seleccione una opcion [1-16]:" num
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
         exit
         ;;
	*)
	echo -e "${Error} Porfavor use numeros del [1-16]"
	;;
esac
fi
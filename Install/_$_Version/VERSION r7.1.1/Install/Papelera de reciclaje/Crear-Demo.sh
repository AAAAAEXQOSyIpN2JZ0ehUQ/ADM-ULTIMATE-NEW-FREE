#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

#CARPETAS
mkdir /etc/adm > /dev/null 2> /dev/null
mkdir /etc/adm/usuarios > /dev/null 2> /dev/null

#IP
IP="/etc/MEUIPADM"

tmpusr () {
time="$1"
timer=$(( $time * 60 ))
timer2="'$timer's"
echo "#!/bin/bash
sleep $timer2
kill"' $(ps -u '"$2 |awk '{print"' $1'"}') 1> /dev/null 2> /dev/null
userdel --force $2
rm -rf /tmp/$2
exit" > /tmp/$2
}

tmpusr2 () {
time="$1"
timer=$(( $time * 60 ))
timer2="'$timer's"
echo "#!/bin/bash
sleep $timer2
kill=$(dropb | grep "$2" | awk '{print $2}')
kill $kill
userdel --force $2
rm -rf /tmp/$2
exit" > /tmp/$2
}

echo -e "\033[1;36m $(fun_trans "CREAR USUARIO POR TIEMPOS [Minutos] ")"
echo -e "\033[1;36m $(fun_trans "Ruta Usuario") : ${cor[2]} /etc/adm/usuarios"
echo -e "$barra"
echo -e "${cor[3]} $(fun_trans "Los Usuarios que cres en esta extencion se eliminaran")"
echo -e "${cor[3]} $(fun_trans "automaticamete pasando el tiempo designado")"
msg -bar2

echo -e "${cor[2]}[1] • \033[1;97mNombre del usuario:\033[0;37m"; read -p " " name
if [[ -z $name ]]
then
echo "No a digitado el Nuevo Usuario"
exit
fi
if cat /etc/passwd |grep $name: |grep -vi [a-z]$name |grep -v [0-9]$name > /dev/null
then
echo -e "${cor[2]} [!OK] Usuario $name ya existe\033[0m"
exit
fi
echo -e "${cor[2]}[2] • \033[1;97mContraseña para usuario $name:\033[0;37m"; read -p " " pass
echo -e "${cor[2]}[3] • \033[1;97mTiempo de Duración En Minutos:\033[0;37m"; read -p " " tmp
if [ "$tmp" = "" ]; then
tmp="30"
echo -e "\033[1;32mFue Definido 30 minutos Por Defecto!\033[0m"
msg -bar2
sleep 2s
fi
useradd -M -s /bin/false $name
(echo $pass; echo $pass)|passwd $name 2>/dev/null
touch /tmp/$name
tmpusr $tmp $name
chmod 777 /tmp/$name
touch /tmp/cmd
chmod 777 /tmp/cmd
echo "nohup /tmp/$name & >/dev/null" > /tmp/cmd
/tmp/cmd 2>/dev/null 1>/dev/null
rm -rf /tmp/cmd
touch /etc/adm/usuarios/$name
echo "senha: $pass" >> /etc/adm/usuarios/$name
echo "data: ($tmp)Minutos" >> /etc/adm/usuarios/$name
msg -bar2
echo -e " ${cor[2]} [!OK] \033[1;33m¡¡Usuario Creado!! ${cor[4]}[NEW-ADM]\033[0m"
msg -bar2
echo -e " \033[1;36mUsuario: \033[0m$name"
echo -e " \033[1;36mContraseña: \033[0m$pass"
echo -e " \033[1;36mMinutos de duración: \033[0m$tmp"
echo -e " \033[1;36mLimite de Coneción: \033[0mIlimitado"
echo -e " \033[1;36mIP: \033[0m$(cat /etc/MEUIPADM)"
msg -bar2
exit
fi0-9]$name > /dev/null
then
echo -e "\033[1;31mUsuario $name ya existe\033[0m"
exit
fi
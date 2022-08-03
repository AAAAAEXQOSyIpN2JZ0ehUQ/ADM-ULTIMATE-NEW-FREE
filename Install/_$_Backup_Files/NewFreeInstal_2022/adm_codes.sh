#!/bin/bash
# Funcoes de Selecao e Interacao com usuario
function err_fun () {
  local ERROR="$1"
  local MSG="$2"
  case ${ERROR} in
    1) msg -verm "Usuario Nulo";;
    2) msg -verm "Usuario Com Nome Muito Curto";;
    3) msg -verm "Usuario Com Nome Muito Grande";;
    4) msg -verm "Senha Nula";;
    5) msg -verm "Senha Muito Curta";;
    6) msg -verm "Senha Muito Grande";;
    7) msg -verm "Duracao Nula";;
    8) msg -verm "Duracao invalida utilize numeros";;
    9) msg -verm "Duracao maxima e de um ano";;
    10) msg -verm "Usuario inexistente";;
    11) msg -verm "Limite Nulo";;
    12) msg -verm "Limite invalido utilize numeros";;
    13) msg -verm "Limite maximo e de 999";;
    14) msg -verm "Usuario Ja Existe";;
    15) msg -verm "Dados nao inseridos ou inseridos erroneamente";;
    16) msg -verm "Valor Digitado e Nulo";;
    17) msg -verm "Digite um Valor Numerico";;
    18) msg -verm "Valor Muito Alto";;
    19) msg -verm "Porta em Uso";;
    20) sys_msg "$(msg -verm "Selecione opcoes entre"): [0-${MSG}]";;
    21) msg -verm "Selecione Sim, ou Selecione Nao Apenas com as Iniciais";;
    22) msg -verm "Digite um IP valido";;
    23) msg -verm "Selecione uma Porta listada e Ativa";;
    24) msg -verm "Host Nula";;
    25) msg -verm "Host ja Existe";;
    26) msg -verm "Host nao Existe";;
    27) msg -verm "A host deve iniciar com .";;
  esac
  msg -verm "Aperte ENTER Para Continuar"
  msg -bar
  read
  fun_up 5
}
function fun_selectopt () {
  local MAX_OPT="$1"
  local ENTRY
  while :
  do
    msg -ne "Selecione a Opcao"
    sys_msg -ne ": "
    read ENTRY
    if [[ -z "${ENTRY}" ]]; then
      err_fun 20 ${MAX_OPT} && continue
    elif [[ ! "${ENTRY}" =~ ^[0-9]+$ ]]; then
      err_fun 20 ${MAX_OPT} && continue
    elif [[ "${ENTRY}" -gt "${MAX_OPT}" ]]; then
      err_fun 20 ${MAX_OPT} && continue
    elif [[ "${ENTRY}" -lt "0" ]]; then
      err_fun 20 ${MAX_OPT} && continue
    else
      break
    fi
  done
  RETORNO="${ENTRY}"
}
function name_user () {
  local nomeuser
  while :
  do
    msg -ne "Nome Do Usuario"
    read -p ": " nomeuser
    nomeuser="$(sys_msg $nomeuser|sed -e 's/[^a-z0-9 -]//ig')"
    if [[ "${nomeuser}" = +([0-9]) ]]; then
    nomeuser=$(user_id ${nomeuser})
    fi
    if [[ -z ${nomeuser} ]]; then
      err_fun 1 && continue
    elif [[ "${#nomeuser}" -lt "4" ]]; then
      err_fun 2 && continue
    elif [[ "${#nomeuser}" -gt "24" ]]; then
      err_fun 3 && continue
    else
      break
    fi
  done
  RETORNO="${nomeuser}"
}
function name_user_exist () {
  local nameuser
  while :
  do
    name_user && local nameuser="$RETORNO"
    cat /etc/passwd |grep ${nameuser}: |grep -vi [a-z]${nameuser} |grep -v [0-9]${nameuser} >/dev/null 2>&1
    if [[ $? = 0 ]]; then
    break
    else
    err_fun 10
    fi
  done
  RETORNO="${nameuser}"
}
function name_user_new () {
  local nameuser
  while :
  do
    name_user && local nameuser="$RETORNO"
    cat /etc/passwd |grep ${nameuser}: |grep -vi [a-z]${nameuser} |grep -v [0-9]${nameuser} >/dev/null 2>&1
    if [[ $? = 1 ]]; then
      break
    else
      err_fun 14
    fi
  done
  RETORNO="${nameuser}"
}
function pass_user () {
  local senhauser
  while :
  do
    msg -ne "Senha Novo Usuario"
    read -p ": " senhauser
    if [[ -z ${senhauser} ]]; then
      err_fun 4 && continue
    elif [[ "${#senhauser}" -lt "6" ]]; then
      err_fun 5 && continue
    elif [[ "${#senhauser}" -gt "20" ]]; then
      err_fun 6 && continue
    else
      break
    fi
  done
  RETORNO="${senhauser}"
}
function date_user () {
  local diasuser
  while :
  do
    msg -ne "Tempo de Duracao do Novo Usuario"
    read -p ": " diasuser
    if [[ -z "${diasuser}" ]]; then
      err_fun 7 && continue
    elif [[ "${diasuser}" != +([0-9]) ]]; then
      err_fun 8 && continue
    elif [[ "${diasuser}" -gt "360" ]]; then
      err_fun 9 && continue
    else
      break
    fi
  done
  RETORNO="${diasuser}"
}
function limit_user () {
  local limiteuser
  while :
  do
    msg -ne "Limite de Conexao do Novo Usuario"
    read -p ": " limiteuser
    if [[ -z "$limiteuser" ]]; then
      err_fun 11 && continue
    elif [[ "$limiteuser" != +([0-9]) ]]; then
      err_fun 12 && continue
    elif [[ "$limiteuser" -gt "999" ]]; then
      err_fun 13 && continue
    else
      break
    fi
  done
  RETORNO="${limiteuser}"
}
function select_port () {
  local VAR
  while :
  do
    msg -ne "Selecione a Porta"
    read -p ": " VAR
    if [[ -z "${VAR}" ]]; then
      err_fun 16 && continue
    elif [[ "${VAR}" != +([0-9]) ]]; then
      err_fun 17 && continue
    elif [[ "${VAR}" -gt "999999" ]]; then
      err_fun 18 && continue
    elif [[ ! -z "$(fun_listports|grep -w "${VAR}")" ]]; then
      err_fun 19 && continue
    else
      break
    fi
  done
  RETORNO="${VAR}"
}
function select_port_invertido () {
  local VAR
  while :
  do
    msg -ne "Selecione a Porta"
    read -p ": " VAR
    if [[ -z "${VAR}" ]]; then
      err_fun 16 && continue
    elif [[ "${VAR}" != +([0-9]) ]]; then
      err_fun 17 && continue
    elif [[ "${VAR}" -gt "999999" ]]; then
      err_fun 18 && continue
    elif [[ -z "$(fun_listports|grep -w "${VAR}")" ]]; then
      err_fun 23 && continue
    else
      break
    fi
  done
  RETORNO="${VAR}"
}
function fun_yesno () {
  local ENTRY
  while :
  do
    sys_msg -ne "$(msg -ama "Selecione") [Y/N]: "
    read ENTRY
    if [[ "${ENTRY}" != @(s|S|y|Y|n|N) ]]; then
      err_fun 21
    else
      break
    fi
  done
  RETORNO="${ENTRY}"
}
function select_uip () {
  local MIP="$(fun_ip)"
  local ENTRY
  sys_msg "$(msg -ama "Seu IP esta Correto?"): ${MIP}"
  while :
  do
    read -p "Confirm IP: " -e -i $MIP ENTRY
    if [[ -z ${ENTRY} ]]; then
      err_fun 22
    else
      break
    fi
  done
  RETORNO="${ENTRY}"
}
# Funcoes Principais ADM-Manager
function fun_global_var () {
  SCPdir="/etc/adm_manager" && [[ ! -d ${SCPdir} ]] && mkdir ${SCPdir}
  SCPusr="${SCPdir}/gerenciador" && [[ ! -d ${SCPusr} ]] && mkdir ${SCPusr}
  SCPfrm="${SCPdir}/ferramentas" && [[ ! -d ${SCPfrm} ]] && mkdir ${SCPfrm}
  SCPinst="${SCPdir}/adicionais" && [[ ! -d ${SCPinst} ]] && mkdir ${SCPinst}
  SCPdatabase="${SCPdir}/database" && [[ ! -d ${SCPdatabase} ]] && mkdir ${SCPdatabase}
  SCPlang="${SCPdir}/lang" && [[ ! -e ${SCPlang} ]] && sys_msg "pt" > ${SCPlang}
  SCPonlines="${SCPdir}/onlines.txt"
  SCPexpired="${SCPdir}/expireds.txt"
  SCPmsg="${SCPdir}/message.txt"
  ADMcores="${SCPdir}/color"
  SCPidioma="${SCPdir}/idioma"
  USRdatabase="${SCPusr}/usuarios"
  export PATH="/bin:/snap/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}
# Menus do ADM-Manager
function fun_Cabecalho () {
  msg -bar
  msg -ama "ADM-MANAGER OFICIAL FEITO POR 8TH"
  msg -bar
  msg -azu "PORTAS ATIVAS E INFORMACOES DO SERVIDOR"
  msg -bar
  fun_ports
  msg -bar
  sys_msg "$(msg -ne "SISTEMA OPERACIONAL"): $(sys_msg "$(fun_system)")"
  sys_msg "$(msg -ne "ENDERECO DA MAQUINA"): $(sys_msg "$(fun_ip)")"
  # Verificacoes Gerais Script
  [[ -e "${SCPexpired}" ]] && sys_msg "$(msg -ne "USUARIOS EXPIRADOS"): $(sys_msg "$(cat ${SCPexpired})")"
  if [[ -e "${SCPonlines}" ]]; then
    local LINE
    local ON="0"
    for LINE in $(cat ${SCPonlines}); do
      let ON=ON+${LINE}
    done
    sys_msg "$(msg -ne "USUARIOS ONLINE"): $(sys_msg "${ON}")"
  fi
  [[ -e "${SCPmsg}" ]] && sys_msg "$(msg -ne "MENSAGEM"): $(sys_msg "$(cat ${SCPmsg})")"
  # Menu Principal
  msg -bar
  sys_msg "$(msg -ne "GERENCIADOR"): $(msg -verd "ADM-MANAGER-2022-V1.0")"
  msg -bar
}
function fun_main_user () {
  clear
  fun_Cabecalho
  sys_msg -ne "\033[1;32m [1] > " && msg -azu "CRIAR USUARIO"
  sys_msg -ne "\033[1;32m [2] > " && msg -azu "REMOVER USUARIO"
  sys_msg -ne "\033[1;32m [3] > " && msg -azu "BLOQUEIO DE USUARIO"
  sys_msg -ne "\033[1;32m [4] > " && msg -azu "RENOVAR USUARIO"
  sys_msg -ne "\033[1;32m [5] > " && msg -azu "DETALHES DE USUARIOS"
  sys_msg -ne "\033[1;32m [6] > " && msg -azu "MONITORAR USUARIOS"
  sys_msg -ne "\033[1;32m [7] > " && msg -azu "ELIMINAR EXPIRADOS"
  sys_msg -ne "\033[1;32m [0] > " && msg -bra "VOLTAR AO MENU"
  msg -bar
  fun_selectopt 7 && local SELECT="$RETORNO"
  fun_up 1
  case ${SELECT} in
    0) fun_up 1 && return 8;;
    1) new_user;;
    2) remove_user;;
    3) block_user;;
    4) renew_user;;
    5) info_users;;
    6) monit_user;;
    7) rm_vencidos;;
  esac
}
function fun_main_recursos () {
  local BADVPN=$(ps x|grep badvpn|grep -v grep|awk '{print $1}')
  local F2B=$(dpkg -l|grep fail2ban|grep ii|wc -l)
  if [[ -z "${BADVPN}" ]]; then
    local PID3=$(msg -azu "ATIVAR BADVPN")
  else
    local PID3=$(msg -red "REMOVER BADVPN")
  fi
  if [[ `grep -c "^#ADM" /etc/sysctl.conf` -eq 0 ]]; then
    local PID4="$(msg -azu "ATIVAR TCPSPEED")"
  else
    local PID4="$(msg -red "REMOVER TCPSPEED")"
  fi
  if [ -e /etc/squid/squid.conf.bak ]; then
    local PID5="$(msg -red "REMOVER SQUIDCACHE")"
  elif [ -e /etc/squid3/squid.conf.bak ]; then
    local PID5="$(msg -red "REMOVER SQUIDCACHE")"
  else
    local PID5="$(msg -azu "ATIVAR SQUIDCACHE")"
  fi
  if [[ ${F2B} -gt "0" ]]; then
    local PID7="$(msg -ama "MENU FAIL2BAN")"
  else
    local PID7="$(msg -azu "CONFIGURAR FAIL2BAN")"
  fi
  clear
  fun_Cabecalho
  sys_msg -ne "\033[1;32m [1] > " && msg -azu "BACKUP DE USUARIOS"
  sys_msg -ne "\033[1;32m [2] > " && msg -azu "CONFIGURAR BANNER SSH"
  sys_msg -ne "\033[1;32m [3] > " && sys_msg -e "${PID3}"
  sys_msg -ne "\033[1;32m [4] > " && sys_msg -e "${PID4}"
  sys_msg -ne "\033[1;32m [5] > " && sys_msg -e "${PID5}"
  sys_msg -ne "\033[1;32m [6] > " && msg -azu "CONFIGURAR BLOCKTORRENT"
  sys_msg -ne "\033[1;32m [7] > " && sys_msg -e "${PID7}"
  sys_msg -ne "\033[1;32m [8] > " && msg -azu "PERSONALIZAR CORES SCRIPT"
  sys_msg -ne "\033[1;32m [0] > " && msg -bra "VOLTAR AO MENU"
  msg -bar
  fun_selectopt 9 && local SELECT="$RETORNO"
  fun_up 1
  case ${SELECT} in
    0) fun_up 1 && return 8;;
    1) fun_backup;;
    2) fun_baner;;
    3) fun_badvpn;;
    4) fun_tcpspeed;;
    5) fun_Squidcache;;
    6) fun_torrent;;
    7) fun_fail2ban;;
    8) fun_troca_cor;;
    9) fun_update;;
  esac
}
function fun_main () {
  local PID7=$(ps aux|grep "ADM_VERIFY"|grep adm_codes.sh|awk '{print $2}')
  if [[ ! -z ${PID7} ]]; then
    local OPT7="$(msg -red "PARAR VERIFICACOES E LIMITER")"
  else
    local OPT7="$(msg -azu "INICIAR VERIFICACOES E LIMITER")"
  fi
  clear
  fun_Cabecalho
  sys_msg -ne "\033[1;32m [1] > " && msg -azu "GERENCIAR USUARIOS"
  sys_msg -ne "\033[1;32m [2] > " && msg -azu "MENU DE RECURSOS"
  sys_msg -ne "\033[1;32m [3] > " && msg -azu "MENU DE INSTALACAO"
  sys_msg -ne "\033[1;32m [4] > " && msg -azu "MENU DE SCRIPTS"
  sys_msg -ne "\033[1;32m [5] > " && msg -azu "TROCAR IDIOMA"
  sys_msg -ne "\033[1;32m [6] > " && sys_msg -e "${OPT7}"
  sys_msg -ne "\033[1;32m [7] > " && msg -verm "DESINSTALAR"
  sys_msg -ne "\033[1;32m [0] > " && msg -bra "SAIR DO MENU"
  msg -bar
  fun_selectopt 7 && local SELECT="$RETORNO"
  case ${SELECT} in
    1) fun_main_user;;
    2) fun_main_recursos;;
    3) fun_main_install;;
    4) fun_personalizado;;
    5) fun_changelang;;
    6) verify_start;;
    7) fun_uninstall;;
    0) return 9;;
  esac
}
function fun_main_install () {
  if [[ -e /etc/default/dropbear ]]; then
    local DROPBEAR="$(msg -red "DESINSTALAR DROPBEAR")"
  else
    local DROPBEAR="$(msg -azu "INSTALAR DROPBEAR")"
  fi
  if [[ -e /etc/openvpn/openvpn.conf ]]; then
    local OPENVPN="$(msg -ama "MENU OPENVPN")"
  else
    local OPENVPN="$(msg -azu "INSTALAR OPENVPN")"
  fi
  if [[ -e /etc/squid/squid.conf ]]; then
    local SQUID="$(msg -ama "MENU SQUID")"
  elif [[ -e /etc/squid3/squid.conf ]]; then
    local SQUID="$(msg -ama "MENU SQUID")"
  else
    local SQUID="$(msg -azu "INSTALAR SQUID")"
  fi
  if [[ -e /etc/shadowsocks.json ]]; then
    local SHADOWSOCKS="$(msg -red "DESINSTALAR SHADOWSOCKS")"
  else
    local SHADOWSOCKS="$(msg -azu "INSTALAR SHADOWSOCKS")"
  fi
  if [[ -e /etc/stunnel/stunnel.conf ]]; then
    local STUNNEL="$(msg -red "DESINSTALAR SSL STUNNEL")"
  else
    local STUNNEL="$(msg -azu "INSTALAR SSL STUNNEL")"
  fi
  clear
  fun_Cabecalho
  sys_msg -ne "\033[1;32m [1] > " && sys_msg "${DROPBEAR}"
  sys_msg -ne "\033[1;32m [2] > " && sys_msg "${OPENVPN}"
  sys_msg -ne "\033[1;32m [3] > " && sys_msg "${SQUID}"
  sys_msg -ne "\033[1;32m [4] > " && sys_msg "${SHADOWSOCKS}"
  sys_msg -ne "\033[1;32m [5] > " && sys_msg "${STUNNEL}"
  sys_msg -ne "\033[1;32m [6] > " && msg -ama "MENU PYTHON PROXY"
  sys_msg -ne "\033[1;32m [0] > " && msg -bra "VOLTAR AO MENU"
  msg -bar
  fun_selectopt 6 && local SELECT="$RETORNO"
  fun_up 1
  case ${SELECT} in
    0) fun_up 1 && return 8;;
    1) fun_dropbear;;
    2) fun_menuopenvpn;;
    3) fun_squidmenu;;
    4) fun_shadowsocks;;
    5) fun_sslstunnel;;
    6) fun_menupython;;
  esac
}
function fun_menuopenvpn () {
  local OPENBAR
  local OPENVPNDIR="/etc/openvpn"
  local OPENVPNCONF="${OPENVPNDIR}/openvpn.conf"
  if [[ -e ${OPENVPNCONF} ]]; then
    msg -bar
    msg -ne "OPENVPN INSTALADO"
    [[ $(fun_listports|grep -w "openvpn") ]] && sys_msg "\033[1;32m [Online]" || sys_msg "\033[1;31m [Offline]"
    msg -bar
  else
    fun_openvpn
    return 0
  fi
  sys_msg -ne "\033[1;32m [1] > " && msg -azu "REMOVER OPENVPN"
  sys_msg -ne "\033[1;32m [2] > " && msg -azu "EDITAR CLIENTE OPENVPN"
  sys_msg -ne "\033[1;32m [3] > " && msg -azu "TROCAR HOSTS OPENVPN"
  sys_msg -ne "\033[1;32m [4] > " && msg -azu "START/STOP OPENVPN"
  sys_msg -ne "\033[1;32m [0] > " && msg -bra "VOLTAR AO MENU"
  msg -bar
  fun_selectopt 4 && local SELECT="$RETORNO"
  case ${SELECT} in
    0) return 8;;
    1)
    msg -bar
    msg -ama "REMOVENDO OPENVPN"
    msg -bar
    local VAR
    local MODULES="/etc/modules"
    local SHARE="/usr/share/doc/openvpn"
    fun_bar "apt-get remove --purge -y openvpn openvpn-blacklist"
    VAR=$(cat ${MODULES}|grep -v tun)
    sys_msg "${VAR}" > ${MODULES}
    rm -rf ${OPENVPNDIR}
    rm -rf ${SHARE}*
    rm -rf ${OPENVPNCONF}
    ps x|grep openvpn|grep -v grep|awk '{print $1}'|while read pid; do
      kill -9 $pid > /dev/null 2>&1
    done
    killall openvpn > /dev/null 2>&1
    msg -bar
    msg -ama "Procedimento Concluido"
    return 0;;
    2)
    nano /etc/openvpn/client-common.txt
    return 0;;
    3)
    fun_edithost
    ;;
    4)
    openvpn_starts
    msg -ama "Sucesso Procedimento Feito"
    return 0
    ;;
 esac
}
function fun_squidmenu () {
  local SELECTION
  local var_squid
  local SQUIDPORT
  local PAYLOADS="/etc/payloads"
  local OPENPAYLOADS="/etc/opendns"
  local IP=$(fun_ip)
  if [[ -e /etc/squid/squid.conf ]]; then
    var_squid="/etc/squid/squid.conf"
  elif [[ -e /etc/squid3/squid.conf ]]; then
    var_squid="/etc/squid3/squid.conf"
  fi
  if [[ $var_squid ]]; then
    local TMPS="/tmp/h.temp"
    local hos
    sys_msg -ne "\033[1;32m [1] > " && msg -azu "Colocar Host no Proxy Squid"
    sys_msg -ne "\033[1;32m [2] > " && msg -azu "Remover Host do Proxy Squid"
    sys_msg -ne "\033[1;32m [3] > " && msg -azu "Desinstalar o Proxy Squid"
    sys_msg -ne "\033[1;32m [0] > " && msg -bra "Voltar ao menu"
    msg -bar
    fun_selectopt 3 && SELECTION="$RETORNO"
    case ${SELECTION} in
    0) return 8;;
    1)
      msg -ama "Hosts Atuais Dentro do Squid"
      msg -bar
      cat ${PAYLOADS} | awk -F "/" '{print $1,$2,$3,$4}'
      msg -bar
      msg -ama "Digite uma HOST e Comece com ."
      local HOST
      while :
      do
        msg -ne "Digite a Nova Host" && read -p ":" hos
        HOST="${hos}/"
        if [[ -z ${hos} ]]; then
          err_fun 24
          continue
        elif [[ "$(cat ${PAYLOADS}|grep ${HOST}|wc -l)" -gt "0" ]]; then
          err_fun 25
          continue
        elif [[ ${hos} != \.* ]]; then
          err_fun 27
        else
          break
        fi
      done
      sys_msg "${HOST}" >> ${PAYLOADS}
      grep -v "^$" ${PAYLOADS} > ${TMPS}
      mv ${TMPS} ${PAYLOADS}
      msg -bar
      cat ${PAYLOADS} | awk -F "/" '{print $1,$2,$3,$4}'
      sys_msg "$(msg -ama "host"): ${HOST} $(msg -ama "Adicionada com Sucesso")"
      if [[ ! -f "/etc/init.d/squid" ]]; then
        service squid3 reload >/dev/null 2>&1 &
        service squid3 restart >/dev/null 2>&1 &
      else
        /etc/init.d/squid reload >/dev/null 2>&1 &
        service squid restart >/dev/null 2>&1 &
      fi
      return 0;;
    2)
      msg -ama "Hosts Atuais Dentro do Squid"
      msg -bar
      cat ${PAYLOADS} | awk -F "/" '{print $1,$2,$3,$4}'
      msg -bar
      msg -ama "Digite uma HOST e Comece com ."
      local HOST
      while :
      do
        msg -ne "Digite a Host" && read -p ":" hos
        HOST="${hos}/"
        if [[ -z ${hos} ]]; then
          err_fun 24
          continue
        elif [[ "$(cat ${PAYLOADS}|grep ${HOST}|wc -l)" -eq "0" ]]; then
          err_fun 26
          continue
        elif [[ ${hos} != \.* ]]; then
          err_fun 27
        else
          break
        fi
      done
        grep -v "^${HOST}" ${PAYLOADS} > ${TMPS}
        mv ${TMPS} ${PAYLOADS}
        msg -bar
        cat ${PAYLOADS} | awk -F "/" '{print $1,$2,$3,$4}'
        sys_msg "$(msg -ama "host"): ${HOST} $(msg -ama "Removida Com Sucesso")"
        if [[ ! -f "/etc/init.d/squid" ]]; then
          service squid3 reload >/dev/null 2>&1 &
          service squid3 restart >/dev/null 2>&1 &
        else
          /etc/init.d/squid reload >/dev/null 2>&1 &
          service squid restart >/dev/null 2>&1 &
        fi
      return 0;;
    3)
      msg -ama "REMOVENDO SQUID"
      msg -bar
      service squid stop > /dev/null 2>&1 &
      fun_bar "apt-get remove squid3 -y"
      msg -ama "Procedimento Concluido"
      [[ -e $var_squid ]] && rm $var_squid
      return 0;;
    esac
  else
    fun_squidinstall
  fi
}
function fun_personalizado () {
  clear
  fun_Cabecalho
  local SCRIPT
  local ARRAY
  sys_msg -ne "\033[1;32m [1] > " && msg -azu "ADICIONAR SCRIPT PERSONALIZADO"
  sys_msg -ne "\033[1;32m [2] > " && msg -azu "REMOVER SCRIPT PERSONALIZADO"
  local OPT="2"
  for SCRIPT in $(ls ${SCPinst}); do
    let OPT++
    sys_msg -ne "\033[1;32m [${OPT}] > " && sys_msg "$(msg -azu "SCRIPT") - [${SCRIPT}]"
    ARRAY[${OPT}]="${SCRIPT}"
  done
  sys_msg -ne "\033[1;32m [0] > " && msg -bra "VOLTAR AO MENU"
  msg -bar
  fun_selectopt ${OPT} && local SELECT="$RETORNO"
  case ${SELECT} in
    0) fun_up 1 && return 8;;
    1) fun_addscript;;
    2) fun_rmvscript;;
    *)
    if [[ -e "${SCPinst}/${ARRAY[$SELECT]}" ]]; then
      local EXE=$(sys_msg ${ARRAY[$SELECT]}|cut -d'.' -f2)
      case ${EXE} in
        sh) bash ${SCPinst}/${ARRAY[$SELECT]};;
        py) python3 ${SCPinst}/${ARRAY[$SELECT]};;
      esac
    fi
    ;;
  esac
}
function fun_menupython () {
  local MSG_SKS MSG_GTN
  local PIDSOCKS=$(ps x|grep -w "PyProxy.py"|grep -v "grep"|awk -F "pts" '{print $1}')
  local PIDGTELL=$(ps x|grep -w "Gettunel.py"|grep -v "grep"|awk -F "pts" '{print $1}')
  if [[ ! -z ${PIDSOCKS} ]]; then
    MSG_SKS="$(msg -red "DESATIVAR PROXY SOCKS")"
  else
    MSG_SKS="$(msg -azu "ATIVAR PROXY SOCKS")"
  fi
  if [[ ! -z ${PIDGTELL} ]]; then
    MSG_GTN="$(msg -red "DESATIVAR PROXY GETTUNEL")"
  else
    MSG_GTN="$(msg -azu "ATIVAR PROXY GETTUNEL")"
  fi
  sys_msg -ne "\033[1;32m [1] > " && sys_msg -e "${MSG_SKS}"
  sys_msg -ne "\033[1;32m [2] > " && sys_msg -e "${MSG_GTN}"
  sys_msg -ne "\033[1;32m [0] > " && msg -bra "VOLTAR AO MENU"
  msg -bar
  fun_selectopt 2 && local SELECT="$RETORNO"
  case ${SELECT} in
    0) return 0;;
    1) fun_python_proxy;;
    2) fun_getunel_proxy;;
  esac
}
# Ofuscador de Mensagem
function fun_ofus () {
  local TXTOFUS
  local TXT
  local NUM=$(expr length $1)
  for((i=1; i<${NUM}+1; i++)); do
  TXT[$i]=$(sys_msg "$1"|cut -b $i)
  case ${TXT[$i]} in
  "w")
  TXT[$i]="8";;
  "8")
  TXT[$i]="w";;
  ".")
  TXT[$i]="+";;
  "+")
  TXT[$i]=".";;
  "1")
  TXT[$i]="@";;
  "@")
  TXT[$i]="1";;
  "2")
  TXT[$i]="?";;
  "?")
  TXT[$i]="2";;
  "3")
  TXT[$i]="%";;
  "%")
  TXT[$i]="3";;
  "/")
  TXT[$i]="K";;
  "K")
  TXT[$i]="/";;
  esac
  TXTOFUS+="${TXT[$i]}"
  done
  sys_msg "$TXTOFUS"|rev
}
# Verifica Informaçoes do Sistema
function fun_system () {
  local system=$(sys_msg $(cat -n /etc/issue |grep 1 |cut -d' ' -f6,7,8 |sed 's/1//' |sed 's/      //'))
  sys_msg $system|awk '{print $1, $2}'
}
function fun_ip () {
  local MEU_IP
  if [[ -e /etc/ADM_IP_BACKUP ]]; then
    sys_msg "$(cat /etc/ADM_IP_BACKUP)"
  else
    MEU_IP=$(ip addr|grep 'inet'|grep -v inet6|grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|head -1)
    if [[ $MEU_IP = "127.0.0.1" ]]; then
      MEU_IP=$(wget -qO- ipv4.icanhazip.com)
    elif [[ ! $MEU_IP  ]]; then
      MEU_IP=$(wget -qO- ipv4.icanhazip.com)
    fi
    sys_msg "$MEU_IP" > /etc/ADM_IP_BACKUP
  fi
}
function fun_ports () {
  local portasVAR=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
  local NOREPEAT
  local reQ
  local Port
  while read port; do
    reQ=$(sys_msg ${port}|awk '{print $1}')
    Port=$(sys_msg {$port} | awk '{print $9}' | awk -F ":" '{print $2}')
    [[ $(sys_msg ${NOREPEAT}|grep -w "${Port}") ]] && continue
    NOREPEAT+="${Port}\n"
    case ${reQ} in
      squid|squid3)
      [[ -z ${SQD} ]] && local SQD="\033[1;31mSQUID: \033[1;32m"
      local SQD+="${Port} ";;
      apache|apache2)
      [[ -z ${APC} ]] && local APC="\033[1;31mAPACHE: \033[1;32m"
      local APC+="${Port} ";;
      ssh|sshd)
      [[ -z ${SSH} ]] && local SSH="\033[1;31mSSH: \033[1;32m"
      local SSH+="${Port} ";;
      dropbear)
      [[ -z ${DPB} ]] && local DPB="\033[1;31mDROPBEAR: \033[1;32m"
      local DPB+="${Port} ";;
      openvpn)
      [[ -z ${OVPN} ]] && local OVPN="\033[1;31mOPENVPN: \033[1;32m"
      local OVPN+="${Port} ";;
      python|python3)
      [[ -z ${PY3} ]] && local PY3="\033[1;31mSOCKS: \033[1;32m"
      local PY3+="${Port} ";;
      ss-server|ssserver)
      [[ -z ${SS} ]] && local SS="\033[1;31mSHADOWSOCKS: \033[1;32m"
      local SS+="${Port} ";;
      stunnel4)
      [[ -z ${SSL} ]] && local SSL="\033[1;31mSTUNNEL: \033[1;32m"
      local SSL+="${Port} ";;
    esac
  done <<< "${portasVAR}"
  [[ ! -z ${SQD} ]] && sys_msg ${SQD}
  [[ ! -z ${APC} ]] && sys_msg ${APC}
  [[ ! -z ${SSH} ]] && sys_msg ${SSH}
  [[ ! -z ${DPB} ]] && sys_msg ${DPB}
  [[ ! -z ${OVPN} ]] && sys_msg ${OVPN}
  [[ ! -z ${SS} ]] && sys_msg ${SS}
  [[ ! -z ${PY3} ]] && sys_msg ${PY3}
  [[ ! -z ${SSL} ]] && sys_msg ${SSL}
}
function fun_listports () {
  local PORTS=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
  local RETURN
  local P1
  local P2
  while read PORT; do
    P1="$(sys_msg ${PORT}|awk '{print $1}')"
    P2="$(sys_msg ${PORT}|awk '{print $9}'|awk -F ":" '{print $2}')"
    [[ "$(sys_msg ${RETURN}|grep -w "${P1} ${P2}")" ]] && continue
    RETURN+="${P1} ${P2}\n"
  done <<< ${PORTS}
  sys_msg "${RETURN}"
}
# Verifica Auto_run
function auto_run () {
  if [[ -e /etc/bash.bashrc-bakup ]]; then
    sys_msg "[on]"
  elif [[ -e /etc/bash.bashrc ]]; then
    sys_msg "[off]"
  fi
}
# Retorno de Linha
function fun_up () {
  if [[ -z ${1} ]]; then
  local cont="1"
  else
  local cont="${1}"
  fi
  for i in $(seq 1 ${cont}); do
    tput cuu1 && tput dl1
  done
}
function fun_changelang () {
  sys_msg -ne "\033[1;32m [1] > " && msg -azu "en English"
  sys_msg -ne "\033[1;32m [2] > " && msg -azu "fr Franch"
  sys_msg -ne "\033[1;32m [3] > " && msg -azu "de German"
  sys_msg -ne "\033[1;32m [4] > " && msg -azu "it Italian"
  sys_msg -ne "\033[1;32m [5] > " && msg -azu "pl Polish"
  sys_msg -ne "\033[1;32m [6] > " && msg -azu "pt Portuguese"
  sys_msg -ne "\033[1;32m [7] > " && msg -azu "es Spanish"
  sys_msg -ne "\033[1;32m [8] > " && msg -azu "tr Turkish"
  sys_msg -ne "\033[1;32m [0] > " && msg -bra "Voltar ao Menu"
  msg -bar
  fun_selectopt 8 && local SELECT="$RETORNO"
  case ${SELECT} in
  0) return;;
  1) local NEWLANG="en";;
  2) local NEWLANG="fr";;
  3) local NEWLANG="de";;
  4) local NEWLANG="it";;
  5) local NEWLANG="pl";;
  6) local NEWLANG="pt";;
  7) local NEWLANG="es";;
  8) local NEWLANG="tr";;
  esac
  sys_msg "${NEWLANG}" > ${SCPlang}
  [[ -e ${SCPidioma} ]] && rm ${SCPidioma}
  msg -ama "Sucesso Idioma Trocado, Bom Proveito"
  msg -ama "Lembre-se a Primeira Execussao do Script"
  msg -ama "Ficara bem Lenta devido ao Processo de Traduçao."
}
# Funcoes Textos
function fun_trans () {
  local texto
  declare -A texto
  local TXT="$@"
  local LANGG=$(cat ${SCPlang})
  if [[ "${LANGG}" = "pt" ]]; then
    sys_msg "${TXT}"
  else
    if [[ ! -e /bin/adm-translate ]]; then
      wget -O /bin/adm-translate git.io/trans && chmod +x /bin/adm-translate
    fi
    [[ ! -e "${SCPidioma}" ]] && sys_msg '#!/bin/bash' > ${SCPidioma}
    source ${SCPidioma}
    if [[ -z ${texto[$@]} ]]; then
      local TRADUCTION=$(adm-translate pt:${LANGG} -no-ansi -b "${TXT}" 2>/dev/null)
      local ARRAY=$(sys_msg "${TRADUCTION}"|tr "'" " ")
      sys_msg "texto[$@]='${ARRAY}'" >> ${SCPidioma}
      source ${SCPidioma} && sys_msg "${texto[$@]}"
    else
      sys_msg "${texto[$@]}"
    fi
  fi
}
function sys_msg () {
  local PARAM="$1"
  case $PARAM in
  -azu) shift && echo -e "\e[1m\033[1;36m${@}\e[0m";;
  -verm) shift && echo -e "\e[1m\033[1;31m${@}\e[0m";;
  -ve) shift && echo -e "\e[1m\033[1;32m${@}\e[0m";;
  -ama) shift && echo -e "\e[1m\033[1;33m${@}\e[0m";;
  -e) shift && echo -e "\e[1m\033[1;37m${@}\e[0m";;
  -ne) shift && echo -ne "${@}";;
  *) echo -e "${@}";;
  esac
}
function msg () {
  local PARAM="$1" && shift
  [[ ! -z "$@" ]] && local TEXT="$(fun_trans "$@")"
  local COLOR
  local NEGRITO="\e[1m"
  local SEMCOR="\e[0m"
  local i=0
  local BAR="======================================================"
  if [[ ! -e ${ADMcores} ]]; then
    COLOR[0]="\033[1;37m" #BRAN='\033[1;37m'
    COLOR[1]="\e[31m" #VERMELHO='\e[31m'
    COLOR[2]="\e[32m" #VERDE='\e[32m'
    COLOR[3]="\e[33m" #AMARELO='\e[33m'
    COLOR[4]="\e[34m" #AZUL='\e[34m'
    COLOR[5]="\e[35m" #MAGENTA='\e[35m'
    COLOR[6]="\033[1;36m" #MAG='\033[1;36m'
  else
    for number in $(cat $ADMcores); do
      case $number in
        1) COLOR[$i]="\033[1;37m";;
        2) COLOR[$i]="\e[31m";;
        3) COLOR[$i]="\e[32m";;
        4) COLOR[$i]="\e[33m";;
        5) COLOR[$i]="\e[34m";;
        6) COLOR[$i]="\e[35m";;
        7) COLOR[$i]="\033[1;36m";;
      esac
      let i++
    done
  fi
  case ${PARAM} in
    -ne) echo -ne "${SEMCOR}${COLOR[1]}${NEGRITO}${TEXT}${SEMCOR}";;
    -nebra) echo -ne "${SEMCOR}${COLOR[0]}${NEGRITO}${TEXT}${SEMCOR}";;
    -neama) echo -ne "${SEMCOR}${COLOR[3]}${NEGRITO}${TEXT}${SEMCOR}";;
    -ama) echo -e "${SEMCOR}${COLOR[3]}${NEGRITO}${TEXT}${SEMCOR}";;
    -verm) echo -e "${SEMCOR}${COLOR[3]}${NEGRITO}[!] ${COLOR[1]}${TEXT}${SEMCOR}";;
    -red) echo -e "${SEMCOR}${COLOR[3]}${NEGRITO}${COLOR[1]}${TEXT}${SEMCOR}";;
    -azu) echo -e "${SEMCOR}${COLOR[6]}${NEGRITO}${TEXT}${SEMCOR}";;
    -verd) echo -e "${SEMCOR}${COLOR[2]}${NEGRITO}${TEXT}${SEMCOR}";;
    -bra)  echo -e "${SEMCOR}${COLOR[0]}${NEGRITO}${TEXT}${SEMCOR}";;
    "-bar2"|"-bar") echo -e "${SEMCOR}${COLOR[4]}${BAR}${SEMCOR}";;
  esac
}
# Funcao Troca de Cores
function fun_troca_cor () {
  local cores
  local i="1"
  local SELECT
  msg -ama "Ola esse e o Gerenciador de Cores"
  msg -bar
  msg -ama "Selecione 7 cores:"
  sys_msg '\033[1;37m [1] ###\033[0m'
  sys_msg '\e[31m [2] ###\033[0m'
  sys_msg '\e[32m [3] ###\033[0m'
  sys_msg '\e[33m [4] ###\033[0m'
  sys_msg '\e[34m [5] ###\033[0m'
  sys_msg '\e[35m [6] ###\033[0m'
  sys_msg '\033[1;36m [7] ###\033[0m'
  msg -bar
  while [[ "${i}" -le "7" ]]; do
    msg -ne "$(fun_trans "Digite a Cor") [$i]: " && read SELECT
    if [[ ${SELECT} = @([1-7]) ]]; then
      cores+="$SELECT "
      let i++
    else
      fun_up
    fi
  done
  sys_msg "$cores" > ${ADMcores}
  msg -ama "Novas Cores Configuradas"
}
# Gerenciamento de Usuarios
# Funcao DataBase Usuarios
function data_base () {
  local USUARIO SENHA DATA LIMITE BLOQUEIO ONLINE
  local DIRETORIO="${SCPdatabase}"
  local ARG="$1" && shift
  USUARIO="$1" && shift
  [[ -z ${USUARIO} ]] && return 1
  case $ARG in
  -add)
  SENHA="$1" && shift
  [[ -z ${SENHA} ]] && return 1
  DATA="$1" && shift
  [[ -z ${DATA} ]] && return 1
  LIMITE="$1" && shift
  [[ -z ${LIMITE} ]] && return 1
  BLOQUEIO="$1" && shift
  [[ -z ${BLOQUEIO} ]] && return 1
  ONLINE="$1" && shift
  [[ -z ${ONLINE} ]] && ONLINE="0"
  sys_msg "${USUARIO};${SENHA};${DATA};${LIMITE};${BLOQUEIO};${ONLINE}" > ${DIRETORIO}/${USUARIO};;
  -rmv)
  [[ -e ${DIRETORIO}/${USUARIO} ]] && rm ${DIRETORIO}/${USUARIO};;
  -show)
  [[ ! -e ${DIRETORIO}/${USUARIO} ]] && return 1
  IFS=";" && read USUARIO SENHA DATA LIMITE BLOQUEIO ONLINE <<< "$(cat ${DIRETORIO}/${USUARIO})" && unset IFS
  sys_msg "${USUARIO} ${SENHA} ${DATA} ${LIMITE} ${BLOQUEIO} ${ONLINE}";;
  esac
}
# Funcoes de Consulta
function fun_listuser () {
  awk -F : '$3 > 900 { print $1 }' /etc/passwd | grep -v "nobody" |grep -vi polkitd |grep -vi system-|grep -vi systemd-
}
function info_users () {
  local RETORNO
  for u in `fun_listuser`; do
    read USER PASS DATE LIMIT BLOCK TIME <<< $(data_base -show $u)
    local EXP=$(date "+%F" -d " + ${DATE} days")
    [[ -z ${USER} ]] && continue
    msg -neama "Usuario"
    sys_msg -ne ": "
    sys_msg -ne "$USER "
    msg -neama "Senha"
    sys_msg -ne ": "
    sys_msg -ne "$PASS "
    msg -neama "Limite"
    sys_msg -ne ": "
    sys_msg "$LIMIT "
    msg -neama "Vencimento"
    sys_msg -ne ": "
    sys_msg -ne "$EXP "
    msg -neama "Situacao"
    sys_msg -ne ": "
    if [[ ${BLOCK} = "0" ]]; then
    msg -verd "Desbloqueado"
    else
    msg -red "Bloqueado"
    fi
    msg -bar
    RETORNO="True"
  done
  if [[ $RETORNO = "True" ]]; then
    msg -ama "Usuarios Atualmente Ativos e Cadastrados Pelo ADM"
  else
    msg -ama "Nao Existem Usuarios Ativos e Cadastrados Pelo ADM"
  fi
}
function mostrar_usuarios () {
  local USERS
  local i
  local us
  for u in `fun_listuser`; do
    USERS+="$u "
  done
  USERS=(${USERS})
  if [[ -z ${USERS[@]} ]]; then
    msg -verm "Nenhum Usuario Cadastrado"
    msg -bar
    return 1
  else
    msg -ama "Usuarios Atualmente Ativos no Servidor"
    msg -bar
    i=0
    for us in $(sys_msg ${USERS[@]}); do
      sys_msg -ne "\033[1;32m [$i] > " && sys_msg "\033[1;33m${us}"
      let i++
    done
    msg -bar
  fi
}
function mostrar_usuarios_block () {
  local us
  local USERS="$(fun_listuser)"
  local USER PASS DATE LIMIT BLOCK TIME
  if [[ -z ${USERS[@]} ]]; then
    msg -verm "Nenhum Usuario Cadastrado"
    msg -bar
    return 1
  else
    msg -ama "Usuarios Atualmente Ativos no Servidor"
    msg -bar
    local i=0
    for us in `fun_listuser`; do
      read USER PASS DATE LIMIT BLOCK TIME <<< $(data_base -show ${us})
      sys_msg -ne "\033[1;32m [$i] > " && sys_msg -ne "\033[1;33m${us} "
      if [[ ${BLOCK} = "0" ]]; then
        msg -verd "Desbloqueado"
      else
        msg -red "Bloqueado"
      fi
    let i++
    done
    msg -bar
  fi
}
function user_id () {
  local ID="$1"
  local RETURN
  local i="0"
  for u in `fun_listuser`; do
    RETURN="${u}"
    [[ "${i}" = "${ID}" ]] && break || let i++
  done
  sys_msg "${RETURN}"
}
# Funcoes Criacao de Usuario
function fun_addopenvpn () {
  local USER="$1"
  local PASS="$2"
  local OVPNFILE="${HOME}/${USER}.ovpn"
  usermod -p $(openssl passwd -1 ${PASS}) ${USER}
  msg -ama "Criar Arquivo Openvpn"
  fun_yesno && local RESPOST="$RETORNO"
  if [[ ${RESPOST} = @(s|S|y|Y) ]]; then
    cp /etc/openvpn/client-common.txt ${OVPNFILE}
    sys_msg "<key>" >> ${OVPNFILE}
    sys_msg "$(cat /etc/openvpn/client-key.pem)" >> ${OVPNFILE}
    sys_msg "</key>" >> ${OVPNFILE}
    sys_msg "<cert>" >> ${OVPNFILE}
    sys_msg "$(cat /etc/openvpn/client-cert.pem)" >> ${OVPNFILE}
    sys_msg "</cert>" >> ${OVPNFILE}
    sys_msg "<ca>" >> ${OVPNFILE}
    sys_msg "$(cat /etc/openvpn/ca.pem)" >> ${OVPNFILE}
    sys_msg "</ca>" >> ${OVPNFILE}
    msg -ama "Colocar Autenticacao de Usuario no Arquivo"
    fun_yesno && local RESPOST="$RETORNO"
    if [[ ${RESPOST} = @(y|Y|s|S) ]]; then
      sed -i "s;auth-user-pass;<auth-user-pass>\n${USER}\n${PASS}\n</auth-user-pass>;g" ${OVPNFILE}
    fi
    msg -bar
    msg -ne "Arquivo Criado"
    sys_msg "- [${OVPNFILE}]" 
    msg -bar
  fi
}
function add_user () {
  local NAME=$1
  local PASS=$2
  local DAYS=$3
  local LIMIT=$4
  local BLOCK=$5
  local VALID=$(date '+%C%y-%m-%d' -d " +${DAYS} days")
  local DATEXP=$(date "+%F" -d " + ${DAYS} days")
  cat /etc/passwd |grep ${NAME}: |grep -vi [a-z]${NAME} |grep -v [0-9]${NAME} >/dev/null 2>&1 && return 1
  useradd -M -s /bin/false ${NAME} -e ${VALID} >/dev/null 2>&1 && (sys_msg ${PASS}; sys_msg ${PASS}) | passwd ${NAME} >/dev/null 2>&1
  if [[ $? = "0" ]]; then
    data_base -add "${NAME}" "${PASS}" "${DAYS}" "${LIMIT}" "${BLOCK}" "0"
    if [[ $(dpkg --get-selections|grep -w "openvpn"|head -1) ]]; then
      if [[ -e /etc/openvpn/openvpn-status.log ]]; then
        fun_addopenvpn "${NAME}" "${PASS}"
      fi
    fi
    msg -ama "Usuario Criado Com Sucesso"
  else
    msg -verm "Erro, Usuario nao criado"
    userdel --force ${NAME} && return 1 
  fi
}
function new_user () {
  local RETORNO
  mostrar_usuarios
  name_user_new && local NAMEUSER="$RETORNO"
  pass_user && local PASSUSER="$RETORNO"
  date_user && local DATEUSER="$RETORNO"
  limit_user && local LIMIUSER="$RETORNO"
  local BLOQUEIO="0"
  fun_up 4
  msg -ne "IP do Servidor" && sys_msg -ne ":" && sys_msg "$(fun_ip)"
  msg -ne "Usuario" && sys_msg -ne ":" && sys_msg "${NAMEUSER}"
  msg -ne "Senha" && sys_msg -ne ":" && sys_msg "${PASSUSER}"
  msg -ne "Dias Duracao" && sys_msg -ne ":" && sys_msg "${DATEUSER}"
  msg -ne "Data de Expiracao" && sys_msg -ne ":" && sys_msg "$(date "+%F" -d " + $DATEUSER days")"
  msg -ne "Limite de Conexao" && sys_msg -ne ":" && sys_msg "$LIMIUSER"
  msg -bar
  add_user "${NAMEUSER}" "${PASSUSER}" "${DATEUSER}" "${LIMIUSER}" "${BLOQUEIO}"
}
# Funcoes Remocao de Usuario
function rm_user () {
  local USERNAME="$1"
  msg -ne "Apagando Usuario"
  sys_msg -ne ":"
  sys_msg -ne " [${USERNAME}] - "
  userdel --force "${USERNAME}" >/dev/null 2>&1
  if [[ $? = "0" ]]; then
  msg -verd "Sucesso"
  data_base -rmv "${USERNAME}"
  else
  msg -verm "Falha"
  return 1
  fi
}
function remove_user () {
  mostrar_usuarios
  if [[ $? = 1 ]]; then
    msg -ama "Voce nao Possui Usuarios Para Remover"
    return 0
  fi
  msg -verm "atencao este processo e irreversivel" && msg -bar
  name_user_exist && local NAMEUSER="$RETORNO"
  msg -ne "Usuario Selecionado" && sys_msg -ne ": " && sys_msg "${NAMEUSER}"
  rm_user "${NAMEUSER}"
}
# Funcoes Bloqueio e Desbloqueio de Usuarios
function block_user () {
  local USER PASS DATE LIMIT BLOCK
  msg -ama "Aqui voce pode bloquear ou desbloquear um usuario"
  msg -ama "Informe o nome do usuario"
  msg -bar
  mostrar_usuarios_block
  if [[ $? = 1 ]]; then
    msg -ama "Voce nao Possui Usuarios Para Bloquear ou Desbloquear"
    return 0
  fi
  name_user_exist && local NAMEUSER="$RETORNO"
  read USER PASS DATE LIMIT BLOCK TIME <<< $(data_base -show ${NAMEUSER})
  msg -ne "Usuario"
  sys_msg -ne ": "
  sys_msg -ne "${USER} "
  if [[ ${BLOCK} = "0" ]]; then
    data_base -add "${USER}" "${PASS}" "${DATE}" "${LIMIT}" "1" "${TIME}"
    usermod -L "${USER}" &>/dev/null && msg -verd "Bloqueado com Sucesso"
  elif [[ ${BLOCK} = "1" ]]; then
    data_base -add "${USER}" "${PASS}" "${DATE}" "${LIMIT}" "0" "${TIME}"
    usermod -U "${USER}" &>/dev/null && msg -verd "Desbloqueado com Sucesso"
  fi
}
# Funcoes Renovacao de usuarios
function renew_user_fun () {
  local USER="$1"
  local DATE="$2"
  local datexp=$(date "+%F" -d " + ${DATE} days")
  local valid=$(date '+%C%y-%m-%d' -d " + ${DATE} days")
  chage -E ${valid} ${USER} >/dev/null 2>&1 
  if [[ $? = "0" ]]; then
    return 0
  else
    return 1
  fi
}
function renew_user () {
  local DIASUSER NAMEUSER PASS DATE LIMIT BLOCK
  msg -ama "Selecione ou Digite o Nome do Usuario"
  msg -bar
  mostrar_usuarios
  if [[ $? = 1 ]]; then
    msg -ama "Voce nao Possui Usuarios Para Renovar"
    return 0
  fi
  name_user_exist && local NAMEUSER="$RETORNO"
  read NAMEUSER PASS DATE LIMIT BLOCK TIME <<< $(data_base -show ${NAMEUSER})
  while :
  do
    msg -ne "Novo Tempo de Duracao de"
    sys_msg -ne " "
    sys_msg -ne "${NAMEUSER}"
    read -p ": " DIASUSER
    if [[ -z "${DIASUSER}" ]]; then
      err_fun 7 && continue
    elif [[ "${DIASUSER}" != +([0-9]) ]]; then
      err_fun 8 && continue
    elif [[ "${DIASUSER}" -gt "360" ]]; then
      err_fun 9 && continue
    else
      break
    fi
  done
  msg -bar
  renew_user_fun "${NAMEUSER}" "${DIASUSER}"
  if [[ $? = 0 ]]; then
    data_base -add "${NAMEUSER}" "${PASS}" "${DIASUSER}" "${LIMIT}" "${BLOCK}" "${TIME}"
    msg -ama "Usuario Modificado Com Sucesso"
  else
    msg -verm "Erro, Usuario nao Modificado"
  fi
}
# Funcoes de Monitoramento de Usuarios
# Funcao de Calculo de Dados
function fun_hour () {
  local PARM="$1"
  local HOURS=$(($PARM/3600))
  local MINUTES=$((($PARM-$HOURS*3600)/60))
  local SECONDS=$(($PARM%60))
  local TIME="${HOURS}h:${MINUTES}m:${SECONDS}s"
  sys_msg "${TIME}"
}
function fun_byte () {
  local B="$1"
  [[ "$B" -lt 1024 ]] && sys_msg "${B} bytes" && return 0
  KB=$(((B+512)/1024))
  [[ "$KB" -lt 1024 ]] && sys_msg "${KB} Kb" && return 0
  MB=$(((KB+512)/1024))
  [[ "$MB" -lt 1024 ]] && sys_msg "${MB} Mb" && return 0
  GB=$(((MB+512)/1024))
  [[ "$GB" -lt 1024 ]] && sys_msg "${GB} Gb" && return 0
  sys_msg $(((GB+512)/1024)) terabytes
}
# Funcao de Pids
function dropbear_pids () {
  local DROPBEAR_PORT=`ps aux|grep dropbear|awk NR==1|awk '{print $17;}'`
  [[ -z $DROPBEAR_PORT ]] && return 1
  local LOG="/var/log/auth.log"
  local LOGUINS="Password auth succeeded"
  local LOGUIN
  local PIDEND
  local USER
  local PIDS
  local PORT
  local PID
  local RET
  for PORT in ${DROPBEAR_PORT}; do
    for PIDS in $(ps ax|grep dropbear|grep "${PORT}"|awk -F" " '{print $1}'); do
      PIDEND=`grep ${PIDS} ${LOG}|grep "${LOGUINS}"|awk -F" " '{print $3}'|awk 'END{print $NF}'`
      if [[ ${PIDEND} ]]; then
        LOGUIN="$(grep ${PIDS} ${LOG}|grep "${PIDEND}"|grep "$LOGUINS")"
        USER="$(sys_msg ${LOGUIN} |awk -F" " '{print $10}' | sed -r "s/'//g")"
        [[ -z ${USER} ]] && continue
        RET="$(sys_msg ${LOGUIN} |awk -F" " '{print $2"-"$1,$3}')"
        PID="${PIDS}"
        sys_msg "${USER} ${PID} ${RET}"
      fi      
    done
  done
}
function openvpn_pids () {
  local RECIVED
  local USER
  local LINE
  local SEND
  local HOUR
  local RCV
  local SND
  local ID
  local _
  [[ ! -e "/etc/openvpn/openvpn-status.log" ]] && return 1
  for USER in `fun_listuser|sed -e 's/[^a-z0-9 -]//ig'`; do
    [[ ! $(sed -n "/^${USER},/p" /etc/openvpn/openvpn-status.log) ]] && continue
    RECIVED[${USER}]="0"
    SEND[${USER}]="0"
    IFS="," && while read _ ID RCV SND _; do
      let RECIVED[${USER}]=RECIVED[${USER}]+${RCV}
      let SEND[${USER}]=SEND[${USER}]+${SND}
      ID[${USER}]="${ID}"
    done <<< "$(sed -n "/^${USER},/p" /etc/openvpn/openvpn-status.log)" && unset IFS
    sys_msg "${USER} ${ID[${USER}]} ${RECIVED[${USER}]} ${SEND[${USER}]}"
  done
}
# Funcao Monitor
function monit_user () {
  local _ USER ONLINE PID OUTPUT
  local MENU="$(printf '%-19s' "USER")$(printf '%-19s' "CONNECTION")TIME/ON"
  msg -verm "Monitor de Conexoes de Usuarios"
  msg -bar
  sys_msg -ama "${MENU}"
  msg -bar
  local USERX=$(fun_listuser)
  if [[ -z ${USERX} ]]; then
    msg -ama "Nao Existe Usuarios Para Monitorar"
  else
    for USER in `fun_listuser`; do
      PID="0"
      [[ $(dpkg --get-selections|grep -w "openssh"|head -1) ]] && let PID=PID+$(ps aux|grep -v grep|grep sshd|grep -w "${USER}"|grep -v root|wc -l)
      [[ $(dpkg --get-selections|grep -w "dropbear"|head -1) ]] && let PID=PID+$(dropbear_pids|grep -w "${USER}"|wc -l)
      [[ $(dpkg --get-selections|grep -w "openvpn"|head -1) ]] && let PID=PID+$(openvpn_pids|grep -w "${USER}"|wc -l)
      OUTPUT="$(printf '%-19s' "${USER}")"
      read USER _ _ _ _ ONLINE <<< "$(data_base -show ${USER})"
      [[ "${PID}" -gt "0" ]] && OUTPUT+="$(printf '%-19s' "${PID} Online")" || OUTPUT+="$(printf '%-19s' "Offline")"
      [[ -z "${ONLINE}" ]] && OUTPUT+="\033[01;31mUNLIMITED" || OUTPUT+="\033[01;32m$(fun_hour ${ONLINE})"
      sys_msg -ama "$OUTPUT"
    done
  fi
}
function rm_vencidos () {
  local DATA RETORNO
  local MENU="$(printf '%-20s' "USER")$(printf '%-20s' "VALID")$(printf "STATUS")"
  msg -verm "Ferramenta de Remocao de Usuarios Vencidos"
  msg -bar
  sys_msg -ama "${MENU}"
  msg -bar
  local USERX=$(fun_listuser)
  if [[ -z ${USERX} ]]; then
    msg -ama "Nao Existe Usuarios Para Remover"
  else
    for USER in ${USERX}; do
      DATA=$(chage -l "${USER}"|grep -i co|awk -F ":" '{print $2}')
      if [[ "${DATA}" = " never" ]]; then
        RETORNO="$(printf '%-20s' "${USER}")$(printf '%-20s' "UNLIMITED")"
        RETORNO+="\033[01;32mPASS"
      elif [[ "$(date +%s --date="${DATA}")" -lt "$(date +%s)" ]]; then
        RETORNO="$(printf '%-20s' "${USER}")$(printf '%-20s' "EXPIRED")"
        rm_user ${USER} >/dev/null 2>&1 && RETORNO+="\033[01;32mDELETED" || RETORNO+="\033[01;31mFAIL"
      else
        RETORNO="$(printf '%-20s' "${USER}")$(printf '%-20s' "OK")"
        RETORNO+="\033[01;32mPASS"
      fi
      sys_msg -ama "${RETORNO}"
    done
  fi
}
# Funcoes de Agregar Recursos
function remove_ferramenta () {
  local SELECT
  local SCRIPT
  local ARQS
  local i=1
  local ITENS=$(ls ${SCPfrm})
  msg -verm "ATENCAO"
  msg -ama "Esse Processo Nao Podera ser Desfeito"
  msg -ama "Selecione a Ferramenta que Deseja Remover"
  msg -bar
  if [[ -z ${ITENS} ]]; then
    msg -verm "Voce nao tem Ferramentas para Remover"
    msg -bar
  else
    for ARQS in ${ITENS}; do
      SCRIPT[$i]="${ARQS}"
      sys_msg -ne "\033[1;32m [$i] > " && msg -azu "${ARQS}"
      let i++
    done
  fi
  sys_msg -ne "\033[1;32m [0] > " && msg -bra "VOLTAR"
  SCRIPT[0]="voltar"
  msg -bar
  while true; do
    msg -ne "Selecione a Opcao"
    sys_msg -ne ": "
    read SELECT
    [[ -z "${SCRIPT[${SELECT}]}" ]] && fun_up 1 && continue
    [[ -z "${SELECT}" ]] && fun_up 1 && continue
    break
  done
  [[ -e "${SCPfrm}/${SCRIPT[$SELECT]}" ]] && rm ${SCPfrm}/${SCRIPT[$SELECT]}
  return 0
}
function agregar_ferramenta () {
  local LINK
  local REC
  msg -verm "ATENCAO"
  msg -ama "Digite o link Para o Novo Recurso"
  sys_msg "Ex: www.dropbox.com/openscript/script.sh"
  msg -bar
  while [[ -z $LINK ]]; do
    msg -ne "Digite o Link"
    sys_msg -ne ": "
    read LINK
    fun_up 1
  done
  sys_msg -ne "Verificando link"
  sys_msg -ne ": "
  curl "$LINK" > /dev/null 2>&1
  if [[ $? = "0" ]]; then
    msg -ama "Link Valido"
    REC=$(sys_msg $LINK|awk -F"/" '{print $NF}')
    msg -ne "Recebendo Recurso"
    sys_msg -ne ": "
    sys_msg -ne "[$REC] - "
    wget -O ${SCPfrm}/${REC} $LINK > /dev/null 2>&1 && sleep 1s
    if [[ -e ${SCPfrm}/${REC} ]]; then
      sys_msg -ve "SUCESS!"
      chmod +x ${SCPfrm}/${REC}
    else
      sys_msg -verm "FAIL!"
    fi
  fi
}
# Fucoes de Recursos
function fun_update () {
  LINK1="https://www.dropbox.com/s/w5u4qfnyrcv38d2/adm_codes.sh?dl=0"
  wget -O ${SCPusr}/adm_codes.sh ${LINK1} -o /dev/null 2>&1
  chmod +x ${SCPusr}/adm_codes.sh
  msg -bar
  msg -ama "SUCESSO"
  msg -bar 
  exit 0
}
function fun_uninstall () {
  msg -ama "Tem Certeza que deseja remover o Script"
  msg -ama "Este Processo e Irreversivel"
  msg -bar
  local SERVICE
  local ID
  fun_yesno && local UNINST="${RETORNO}"
  if [[ ${UNINST} = @(s|S|y|Y) ]]; then
    local SERVICES="$(fun_listports|cut -d' ' -f1)"
    [[ -d ${SCPdir} ]] && rm -rf ${SCPdir}
    for SERVICE in ${SERVICES}; do
      case ${SERVICE} in
        openvpn) local OPENVPN="True";;
        ss-server) local SHADOWSOCKS="True";;
        dropbear) local DROPBEAR="True";;
        stunnel4) local STUNNEL="True";;
        squid) local SQUID="True";;
      esac
    done
    if [[ $SQUID -eq "True" ]]; then
      fun_bar "apt-get remove squid3 -y"
      fun_bar "apt-get remove squid -y"
      [[ -d /etc/squid ]] && rm -rf /etc/squid
      [[ -d /etc/squid3 ]] && rm -rf /etc/squid3
    fi
    if [[ $DROPBEAR -eq "True" ]]; then
      fun_bar "apt-get remove dropbear -y"
      [[ -e /etc/default/dropbear ]] && rm /etc/default/dropbear
    fi
    if [[ $OPENVPN -eq "True" ]]; then
      fun_bar "apt-get remove --purge -y openvpn openvpn-blacklist"
      local VAR=$(cat /etc/modules|grep -v tun) && sys_msg "${VAR}" > /etc/modules
      [[ -d /usr/share/doc/openvpn ]] && rm -rf /usr/share/doc/openvpn
      [[ -d /etc/openvpn ]] && rm -rf /etc/openvpn
    fi
    if [[ $SHADOWSOCKS -eq "True" ]]; then
      fun_bar "apt-get remove --purge -y shadowsocks-libev"
      [[ -e /etc/shadowsocks.json ]] && rm /etc/shadowsocks.json
    fi
    if [[ $STUNNEL -eq "True" ]]; then
      fun_bar "apt-get purge stunnel4 -y"
      [[ -d /etc/stunnel ]] && rm -rf /etc/stunnel
    fi
    for SERVICE in $(ls /etc/init.d); do
      service ${SERVICE} restart > /dev/null 2>&1 &
    done
    sys_msg "Removido Com Sucesso"
    exit 0
  else
    msg -ama "Remocao Cancelada"
  fi
}
function fun_badvpn () {
  local BADVPN=$(ps x|grep badvpn|grep -v grep|awk '{print $1}')
  if [[ -z "${BADVPN}" ]]; then
    msg -ama "Inicializando Badvpn"
    msg -bar
    if [[ ! -e "/bin/badvpn-udpgw" ]]; then
      wget -O /bin/badvpn-udpgw https://www.dropbox.com/s/nxf5s1lffmbikwq/badvpn-udpgw >/dev/null 2>&1 && sleep 2s
      [[ -e "/bin/badvpn-udpgw" ]] && chmod +x /bin/badvpn-udpgw
    fi
    screen -dmS screen /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10
    [[ "$(ps x|grep badvpn|grep -v grep|awk '{print $1}')" ]] && msg -ama "Sucesso" || msg -ama "Falhou"
  else
    msg -ama "Parando Badvpn"
    msg -bar
    kill -9 $(ps x | grep badvpn | grep -v grep | awk '{print $1'}) > /dev/null 2>&1
    killall badvpn-udpgw > /dev/null 2>&1
    [[ ! "$(ps x | grep badvpn | grep -v grep | awk '{print $1}')" ]] && msg -ama "Sucesso" || msg -ama "Falhou"
  fi
}
function fun_tcpspeed () {
  msg -ama "Esta Configuracao Melhora a Velocidade de Conexao"
  if [[ `grep -c "^#ADM" /etc/sysctl.conf` -eq 0 ]]; then
    msg -ama "Ativando TCPSpeed"
    msg -bar
    sys_msg "#ADM" >> /etc/sysctl.conf
    sys_msg "net.ipv4.tcp_window_scaling = 1
    net.core.rmem_max = 16777216
    net.core.wmem_max = 16777216
    net.ipv4.tcp_rmem = 4096 87380 16777216
    net.ipv4.tcp_wmem = 4096 16384 16777216
    net.ipv4.tcp_low_latency = 1
    net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf > /dev/null 2>&1 && msg -ama "TCPSpeed Ativo Com Sucesso" || msg -verm "TCPSpeed Ativacao Falhou"
  else
    msg -ama "Desativando TCPSpeed"
    msg -bar
    grep -v "^#ADM
    net.ipv4.tcp_window_scaling = 1
    net.core.rmem_max = 16777216
    net.core.wmem_max = 16777216
    net.ipv4.tcp_rmem = 4096 87380 16777216
    net.ipv4.tcp_wmem = 4096 16384 16777216
    net.ipv4.tcp_low_latency = 1
    net.ipv4.tcp_slow_start_after_idle = 0" /etc/sysctl.conf > /tmp/syscl
    mv -f /tmp/syscl /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf > /dev/null 2>&1 && msg -ama "TCPSpeed Removido Com Sucesso" || msg -verm "TCPSpeed Remocao Falhou"
  fi
}
function fun_Squidcache () {
  msg -ama "Squid Cache, Aplica cache no squid"
  msg -ama "melhora a velocidade do squid"
  msg -bar
  local SQUIDCONF
  local NEWCONF="#CACHE DO SQUID\ncache_mem 200 MB\nmaximum_object_size_in_memory 32 KB\nmaximum_object_size 1024 MB\nminimum_object_size 0 KB\ncache_swap_low 90\ncache_swap_high 95"
  if [ -e /etc/squid/squid.conf ]; then
    NEWCONF+="\ncache_dir ufs /var/spool/squid 100 16 256\naccess_log /var/log/squid/access.log squid"
    local SQUIDDIR="/etc/squid/squid.conf"
  elif [ -e /etc/squid3/squid.conf ]; then
    NEWCONF+="\ncache_dir ufs /var/spool/squid3 100 16 256\naccess_log /var/log/squid3/access.log squid"
    local SQUIDDIR="/etc/squid3/squid.conf"
  else
    msg -ama "Seu sistema nao possui um squid"
    msg -bar
    return 1
  fi
  local BACKUP="${SQUIDDIR}.bak"
  if [[ `grep -c "^#CACHE DO SQUID" ${SQUIDDIR}` -gt 0 ]]; then
    if [[ -e "${BACKUP}" ]]; then
      msg -ama "Cache squid identificado"
      msg -ama "Restaurando Configuracao"
      msg -bar
      mv -f "${BACKUP}" "${SQUIDDIR}" && msg -ama "Squid Restaurado Com Sucesso" || msg -verm "Restauracao Squid Falhou"
      service squid restart > /dev/null 2>&1 &
      service squid3 restart > /dev/null 2>&1 &
    fi
  else
    msg -ama "squid identificado em sua maquina"
    msg -ama "Aplicando Cache Squid"
    msg -bar
    while read SQUIDCONF; do
      [[ "${SQUIDCONF}" != "cache deny all" ]] && NEWCONF+="\n${SQUIDCONF}"
    done < ${SQUIDDIR}
    cp "${SQUIDDIR}" "${BACKUP}"
    sys_msg "${NEWCONF}" > "${SQUIDDIR}" && msg -ama "Squid Cache Instalado Com Sucesso" || msg -verm "Instalacao Squid cache Falhou"
    service squid restart > /dev/null 2>&1 &
    service squid3 restart > /dev/null 2>&1 &
  fi
}
function fun_torrent () {
  msg -ama "Essas configuracoes so Devem ser adicionadas"
  msg -ama "apos a vps estar totalmente configurada"
  msg -verm "Este Processo e irreversivel"
  msg -bar
  local SELECT
  while :
  do
    msg -ne "Deseja Prosseguir?"
    sys_msg -ne "[S/N]: "
    read SELECT
    fun_up
    if [[ ${SELECT} = @(s|S|y|Y) ]]; then
      msg -ama "Prosseguindo Instalacao"
      break
    else
      msg -ama "Instalacao Cancelada"
      return 1
    fi
  done
  [[ $(iptables -h|wc -l) -lt 5 ]] && apt-get install iptables -y > /dev/null 2>-1
  local PORT
  local NIC=$(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1)
  local CONFIG
  local IPLOCAL="$(fun_ip)"
  local AQUIVO="/tmp/iptables"
  CONFIG="iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT\n"
  CONFIG+="iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT\n"
  CONFIG+="iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT\n"
  CONFIG+="iptables -t filter -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT\n"
  #libera DNS
  CONFIG+="iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW -j ACCEPT\n"
  CONFIG+="iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT\n"
  #Liberar DHCP
  CONFIG+="iptables -A OUTPUT -p tcp --dport 67 -m state --state NEW -j ACCEPT\n"
  CONFIG+="iptables -A OUTPUT -p udp --dport 67 -m state --state NEW -j ACCEPT\n"
  #Liberando Servicos Ativos
  while read PORT; do
    CONFIG+="iptables -A INPUT -p tcp --dport ${PORT} -j ACCEPT\n"
    CONFIG+="iptables -A INPUT -p udp --dport ${PORT} -j ACCEPT\n"
    CONFIG+="iptables -A OUTPUT -p tcp --dport ${PORT} -j ACCEPT\n"
    CONFIG+="iptables -A OUTPUT -p udp --dport ${PORT} -j ACCEPT\n"
    CONFIG+="iptables -A FORWARD -p tcp --dport ${PORT} -j ACCEPT\n"
    CONFIG+="iptables -A FORWARD -p udp --dport ${PORT} -j ACCEPT\n"
    CONFIG+="iptables -A OUTPUT -p tcp -d ${IPLOCAL} --dport ${PORT} -m state --state NEW -j ACCEPT\n"
    CONFIG+="iptables -A OUTPUT -p udp -d ${IPLOCAL} --dport ${PORT} -m state --state NEW -j ACCEPT\n"
  done <<< "$(fun_listports|awk '{print $2}')"
  #Bloqueando Ping
  CONFIG+="iptables -A INPUT -p icmp --icmp-type sys_msg-request -j DROP\n"
  #Liberar WEBMIN
  CONFIG+="iptables -A INPUT -p tcp --dport 10000 -j ACCEPT\n"
  CONFIG+="iptables -A OUTPUT -p tcp --dport 10000 -j ACCEPT\n"
  #Bloqueando torrent
  CONFIG+="iptables -t nat -A PREROUTING -i ${NIC} -p tcp --dport 6881:6889 -j DNAT --to-dest ${IPLOCAL}\n"
  CONFIG+="iptables -A FORWARD -p tcp -i ${NIC} --dport 6881:6889 -d ${IPLOCAL} -j REJECT\n"
  CONFIG+="iptables -A OUTPUT -p tcp --dport 6881:6889 -j DROP\n"
  CONFIG+="iptables -A OUTPUT -p udp --dport 6881:6889 -j DROP\n"
  CONFIG+="iptables -A FORWARD -m string --algo bm --string 'BitTorrent' -j DROP\n"
  CONFIG+="iptables -A FORWARD -m string --algo bm --string 'BitTorrent protocol' -j DROP\n"
  CONFIG+="iptables -A FORWARD -m string --algo bm --string 'peer_id=' -j DROP\n"
  CONFIG+="iptables -A FORWARD -m string --algo bm --string '.torrent' -j DROP\n"
  CONFIG+="iptables -A FORWARD -m string --algo bm --string 'announce.php?passkey=' -j DROP\n"
  CONFIG+="iptables -A FORWARD -m string --algo bm --string 'torrent' -j DROP\n"
  CONFIG+="iptables -A FORWARD -m string --algo bm --string 'announce' -j DROP\n"
  CONFIG+="iptables -A FORWARD -m string --algo bm --string 'info_hash' -j DROP\n"
  CONFIG+="iptables -A FORWARD -m string --algo bm --string 'get_peers' -j DROP\n"
  CONFIG+="iptables -A FORWARD -m string --algo bm --string 'announce_peer'  -j DROP\n"
  CONFIG+="iptables -A FORWARD -m string --algo bm --string 'find_node' -j DROP\n"
  sys_msg "${CONFIG}" > ${AQUIVO} && chmod +x ${AQUIVO}
  ${AQUIVO} && rm ${AQUIVO}
  msg -ama "Processo concluido com Sucesso"
}
function fun_baner_Cabecalho () {
  msg -bar
  sys_msg -ne " \033[1;32m[1] >\033[1;32m ### " && msg -ama "Verde"
  sys_msg -ne " \033[1;32m[2] >\033[1;31m ### " && msg -ama "Vermelho"
  sys_msg -ne " \033[1;32m[3] >\033[1;34m ### " && msg -ama "Azul"
  sys_msg -ne " \033[1;32m[4] >\033[1;33m ### " && msg -ama "Amarelo"
  sys_msg -ne " \033[1;32m[5] >\033[1;35m ### " && msg -ama "Roxo"
  msg -bar
}
function fun_baner_Message () {
  local MESSAGE
  while :
  do
    msg -ne "digite a mensagem do banner"
    sys_msg -ne ": "
    read MESSAGE
    if [[ -z ${MESSAGE} ]]; then
      err_fun 15
    else
      break
    fi
  done
  RETURN="${MESSAGE}"
}
function fun_baner_Cores () {
  local DIR="$1"
  while :
  do    
    msg -ne "Perfeito Agora a Cor"
    sys_msg -ne ": "
    read COR
    case ${COR} in
      1)
      sys_msg '<font color="green">' >> ${DIR} && break;;
      2)
      sys_msg '<font color="red">' >> ${DIR} && break;;
      3)
      sys_msg '<font color="blue">' >> ${DIR} && break;;
      4)
      sys_msg '<font color="yellow">' >> ${DIR} && break;;
      5)
      sys_msg '<font color="purple">' >> ${DIR} && break;;
      *)
      err_fun 15;;
    esac
  done
}
function fun_baner () {
  local BANNERBAK="/etc/ssh/sshd.bak"
  local BANNERDIR="/etc/bannerssh"
  local SSHD="/etc/ssh/sshd_config"
  local RETURN MESSAGE COR
  msg -ama "Bem vindo esse e o instalador do banner"
  msg -ama "Agora Vamos Adicionar a Mensagem Principal do Banner"
  msg -bar
  if [[ ! $(cat ${SSHD}|grep "Banner ${BANNERDIR}") ]]; then
    cat ${SSHD}|grep -v "Banner" > ${BANNERBAK} && mv -f ${BANNERBAK} ${SSHD}
    sys_msg "Banner ${BANNERDIR}" >> ${SSHD}
  fi
  fun_baner_Message && MESSAGE="${RETURN}"
  fun_baner_Cabecalho
  sys_msg '<h1><font>=============================</font></h1>' > ${BANNERDIR}
  sys_msg "<h1>" >> ${BANNERDIR}
  fun_baner_Cores ${BANNERDIR}
  sys_msg "${MESSAGE}" >> ${BANNERDIR}
  sys_msg '</font></h1>' >> ${BANNERDIR}
  msg -bar
  msg -ama "Agora Vamos Adicionar as Mensagens Secundarias"
  while :
  do
    fun_baner_Message && MESSAGE="${RETURN}"
    fun_baner_Cabecalho
    sys_msg "<h6>" >> ${BANNERDIR}
    fun_baner_Cores ${BANNERDIR}
    sys_msg "${MESSAGE}" >> ${BANNERDIR}
    sys_msg "</h6></font>" >> ${BANNERDIR}
    msg -ne "Adicionar Outra Mensagem"
    sys_msg -ne "[S/N]: "
    read RETURN
    [[ ${RETURN} = @(s|S|y|Y) ]] || break
  done
  sys_msg '<h1><font>=============================</font></h1>' >> ${BANNERDIR}
  service ssh restart > /dev/null 2>&1 &
  service sshd restart >/dev/null 2>&1 &
  service dropbear restart > /dev/null 2>&1 &
  msg -bar
  msg -ama "Banner Adicionado com Sucesso"
}
function fun_backup () {
  local US USUARIO SENHA DATA LIMITE BLOQUEIO ONLINE OPT
  local DIRETORIO="${SCPdatabase}"
  local BACKUP="$HOME/Usuarios.bak"
  sys_msg -ne "\033[1;32m [1] > " && msg -azu "CRIAR BACKUP"
  sys_msg -ne "\033[1;32m [2] > " && msg -azu "RESTAURAR BACKUP"
  sys_msg -ne "\033[1;32m [0] > " && msg -bra "VOLTAR AO MENU"
  msg -bar
  fun_selectopt 2 && local OPT="$RETORNO"
  if [[ ${OPT} = "0" ]]; then
    return 0
  elif [[ ${OPT} = "1" ]]; then
  msg -ama "Gerando Arquivo Backup Aguarde"
  [[ -e ${BACKUP} ]] && rm ${BACKUP}
    for US in $(ls ${SCPdatabase}); do
      sys_msg -ne "Usuario: ${US}"
      if [[ -e ${BACKUP} ]]; then
        cat ${DIRETORIO}/${US} >> ${BACKUP} && sys_msg -ve " [SUCESS]" || sys_msg -verm " [FAIL]"
      else
        cat ${DIRETORIO}/${US} > ${BACKUP} && sys_msg -ve " [SUCESS]" || sys_msg -verm " [FAIL]"
      fi
    done
    msg -bar
    msg -ama "Backup Criado com Sucesso"
    sys_msg "o Backup esta: [${BACKUP}]"
    msg -ama "Agora e so Restaurar ele em Outra maquina"
  elif [[ ${OPT} = "2" ]]; then
    if [[ ! -e ${BACKUP} ]]; then
      msg -ama "Para Realizar um Backup o Arquivo deve Estar no Formato Abaixo"
      sys_msg "o Backup deve Estar desta Forma: [${BACKUP}]"
      msg -ama "Tente Novamente"
      return 1
    fi
    IFS=";" && while read USUARIO SENHA DATA LIMITE BLOQUEIO ONLINE; do
      sys_msg "User: ${USUARIO} Pass: ${SENHA} Day: ${DATA} Limit: ${LIMITE}"
      add_user "${USUARIO}" "${SENHA}" "${DATA}" "${LIMITE}" "${BLOQUEIO}"
    done <<< "$(cat ${BACKUP})" && unset IFS
    msg -ama "Backup Restaurado com Sucesso"
  fi
}
function fun_fail2ban () {
  declare -A PIDS
  local PIDS PORT PROXYPORTS
  PIDS[fail2ban]=$(dpkg -l|grep fail2ban|grep ii|wc -l)
  PIDS[apache]=$(dpkg -l|grep apache2|grep ii|wc -l)
  PIDS[squid]=$(dpkg -l|grep squid|grep ii|wc -l)
  PIDS[dropbear]=$(dpkg -l|grep dropbear|grep ii|wc -l)
  PIDS[openssh]=$(dpkg -l|grep openssh|grep ii|wc -l)
  local SELECTION
  local HOMEF2B="$HOME/fail2ban"
  local JAILCONF="/etc/fail2ban/jail.local"
  msg -ama "Esse e o Fail2ban Protection"
  msg -ama "Otimo para proteger contra ataques de DDos"
  msg -bar
  if [[ ${PIDS[fail2ban]} -gt "0" ]]; then
    sys_msg -ne "\033[1;32m [1] > " && msg -azu "Desinstalar Fail2ban"
    sys_msg -ne "\033[1;32m [2] > " && msg -azu "Olhar o log"
    sys_msg -ne "\033[1;32m [0] > " && msg -azu "Voltar ao Menu"
    msg -bar
    while [[ ${SELECTION} != @(0|1|2) ]]; do
      msg -ne "Selecione a Opcao"
      sys_msg -ne ": "
      read SELECTION
      fun_up 1
    done
    case ${SELECTION} in
      0)
      return 0;;
      1)
      fun_bar "apt-get remove fail2ban -y"
      rm ${JAILCONF}
      msg -ama "Fail2ban Removido Com Sucesso";;
      2)
      cat /var/log/fail2ban.log;;
    esac
  return 0
  fi
  msg -ama "Deseja Instalar o Fail2ban"
  msg -bar
  while [[ ${SELECTION} != @(s|S|y|Y|n|N) ]]; do
    msg -ne "Selecione a Opcao"
    sys_msg -ne " [S/N]: "
    read SELECTION
    fun_up 1
  done
  if [[ "${SELECTION}" = @(s|S|y|Y) ]]; then
    msg -ama "Instalando Fail2ban"
    fun_bar "apt-get install fail2ban -y"
    wget -O ${HOMEF2B} https://www.dropbox.com/s/qtz4aihjnwpth7y/fail2ban-0.9.4.tar.gz?dl=0 > /dev/null 2>&1
    tar -xf ${HOMEF2B} > /dev/null 2>&1
    python ${HOMEF2B}-0.9.4/setup.py install > /dev/null 2>&1
    sys_msg '[INCLUDES]' > ${JAILCONF}
    sys_msg 'before = paths-debian.conf' >> ${JAILCONF}
    sys_msg '[DEFAULT]' >> ${JAILCONF}
    sys_msg 'ignoreip = 127.0.0.1/8' >> ${JAILCONF}
    sys_msg '# ignorecommand = /path/to/command <ip>' >> ${JAILCONF}
    sys_msg 'ignorecommand =' >> ${JAILCONF}
    sys_msg 'bantime  = 1036800' >> ${JAILCONF}
    sys_msg 'findtime  = 3600' >> ${JAILCONF}
    sys_msg 'maxretry = 5' >> ${JAILCONF}
    sys_msg 'backend = auto' >> ${JAILCONF}
    sys_msg 'usedns = warn' >> ${JAILCONF}
    sys_msg 'logencoding = auto' >> ${JAILCONF}
    sys_msg 'enabled = false' >> ${JAILCONF}
    sys_msg 'filter = %(__name__)s' >> ${JAILCONF}
    sys_msg 'destemail = root@localhost' >> ${JAILCONF}
    sys_msg 'sender = root@localhost' >> ${JAILCONF}
    sys_msg 'mta = sendmail' >> ${JAILCONF}
    sys_msg 'protocol = tcp' >> ${JAILCONF}
    sys_msg 'chain = INPUT' >> ${JAILCONF}
    sys_msg 'port = 0:65535' >> ${JAILCONF}
    sys_msg 'fail2ban_agent = Fail2Ban/%(fail2ban_version)s' >> ${JAILCONF}
    sys_msg 'banaction = iptables-multiport' >> ${JAILCONF}
    sys_msg 'banaction_allports = iptables-allports' >> ${JAILCONF}
    sys_msg 'action_ = %(banaction)s[name=%(__name__)s, bantime="%(bantime)s", port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]' >> ${JAILCONF}
    sys_msg 'action_mw = %(banaction)s[name=%(__name__)s, bantime="%(bantime)s", port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]' >> ${JAILCONF}
    sys_msg '            %(mta)s-whois[name=%(__name__)s, sender="%(sender)s", dest="%(destemail)s", protocol="%(protocol)s", chain="%(chain)s"]' >> ${JAILCONF}
    sys_msg 'action_mwl = %(banaction)s[name=%(__name__)s, bantime="%(bantime)s", port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]' >> ${JAILCONF}
    sys_msg '             %(mta)s-whois-lines[name=%(__name__)s, sender="%(sender)s", dest="%(destemail)s", logpath=%(logpath)s, chain="%(chain)s"]' >> ${JAILCONF}
    sys_msg 'action_xarf = %(banaction)s[name=%(__name__)s, bantime="%(bantime)s", port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]' >> ${JAILCONF}
    sys_msg '             xarf-login-attack[service=%(__name__)s, sender="%(sender)s", logpath=%(logpath)s, port="%(port)s"]' >> ${JAILCONF}
    sys_msg 'action_cf_mwl = cloudflare[cfuser="%(cfemail)s", cftoken="%(cfapikey)s"]' >> ${JAILCONF}
    sys_msg '                %(mta)s-whois-lines[name=%(__name__)s, sender="%(sender)s", dest="%(destemail)s", logpath=%(logpath)s, chain="%(chain)s"]' >> ${JAILCONF}
    sys_msg 'action_blocklist_de  = blocklist_de[email="%(sender)s", service=%(filter)s, apikey="%(blocklist_de_apikey)s", agent="%(fail2ban_agent)s"]' >> ${JAILCONF}
    sys_msg 'action_badips = badips.py[category="%(__name__)s", banaction="%(banaction)s", agent="%(fail2ban_agent)s"]' >> ${JAILCONF}
    sys_msg 'action_badips_report = badips[category="%(__name__)s", agent="%(fail2ban_agent)s"]' >> ${JAILCONF}
    sys_msg 'action = %(action_)s' >> ${JAILCONF}
    msg -ama "Fail2ban sera ativo nas Seguintes Portas e Servicos"
    fun_ports
    sys_msg '[sshd]' >> ${JAILCONF}
    [[ ${PIDS[openssh]} -gt "0" ]] && sys_msg 'enabled = true' >> ${JAILCONF}
    sys_msg 'port    = ssh' >> ${JAILCONF}
    sys_msg 'logpath = %(sshd_log)s' >> ${JAILCONF}
    sys_msg 'backend = %(sshd_backend)s' >> ${JAILCONF}
    sys_msg '[sshd-ddos]' >> ${JAILCONF}
    [[ ${PIDS[openssh]} -gt "0" ]] && sys_msg 'enabled = true' >> ${JAILCONF}
    sys_msg 'port    = ssh' >> ${JAILCONF}
    sys_msg 'logpath = %(sshd_log)s' >> ${JAILCONF}
    sys_msg 'backend = %(sshd_backend)s' >> ${JAILCONF}
    sys_msg '[squid]' >> ${JAILCONF}
    if [[ ${PIDS[squid]} -gt "0" ]]; then
      local SQUIDPORTS="$(fun_listports|grep s|awk '{print $2}')"
      for PORT in ${SQUIDPORTS}; do
        [[ -z ${PROXYPORTS} ]] && PROXYPORTS="${PORT}" || PROXYPORTS+=",${PORT}"
      done
      sys_msg 'enabled = true' >> ${JAILCONF}
      sys_msg "port     =  ${PROXYPORTS}" >> ${JAILCONF}      
    else
      sys_msg 'port     =  ' >> ${JAILCONF}
    fi
    sys_msg 'logpath = /var/log/squid/access.log' >> ${JAILCONF}
    sys_msg '[dropbear]' >> ${JAILCONF}
    [[ ${PIDS[dropbear]} -gt "0" ]] && sys_msg 'enabled = true' >> ${JAILCONF}
    sys_msg 'port     = ssh' >> ${JAILCONF}
    sys_msg 'logpath  = %(dropbear_log)s' >> ${JAILCONF}
    sys_msg 'backend  = %(dropbear_backend)s' >> ${JAILCONF}
    sys_msg '[apache-auth]' >> ${JAILCONF}
    [[ ${PIDS[apache]} -gt "0" ]] && sys_msg 'enabled = true' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = %(apache_error_log)s' >> ${JAILCONF}
    sys_msg '[selinux-ssh]' >> ${JAILCONF}
    sys_msg 'port     = ssh' >> ${JAILCONF}
    sys_msg 'logpath  = %(auditd_log)s' >> ${JAILCONF}
    sys_msg '[apache-badbots]' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = %(apache_access_log)s' >> ${JAILCONF}
    sys_msg 'bantime  = 172800' >> ${JAILCONF}
    sys_msg 'maxretry = 1' >> ${JAILCONF}
    sys_msg '[apache-noscript]' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = %(apache_error_log)s' >> ${JAILCONF}
    sys_msg '[apache-overflows]' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = %(apache_error_log)s' >> ${JAILCONF}
    sys_msg 'maxretry = 2' >> ${JAILCONF}
    sys_msg '[apache-nohome]' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = %(apache_error_log)s' >> ${JAILCONF}
    sys_msg 'maxretry = 2' >> ${JAILCONF}
    sys_msg '[apache-botsearch]' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = %(apache_error_log)s' >> ${JAILCONF}
    sys_msg 'maxretry = 2' >> ${JAILCONF}
    sys_msg '[apache-fakegooglebot]' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = %(apache_access_log)s' >> ${JAILCONF}
    sys_msg 'maxretry = 1' >> ${JAILCONF}
    sys_msg 'ignorecommand = %(ignorecommands_dir)s/apache-fakegooglebot <ip>' >> ${JAILCONF}
    sys_msg '[apache-modsecurity]' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = %(apache_error_log)s' >> ${JAILCONF}
    sys_msg 'maxretry = 2' >> ${JAILCONF}
    sys_msg '[apache-shellshock]' >> ${JAILCONF}
    sys_msg 'port    = http,https' >> ${JAILCONF}
    sys_msg 'logpath = %(apache_error_log)s' >> ${JAILCONF}
    sys_msg 'maxretry = 1' >> ${JAILCONF}
    sys_msg '[openhab-auth]' >> ${JAILCONF}
    sys_msg 'filter = openhab' >> ${JAILCONF}
    sys_msg 'action = iptables-allports[name=NoAuthFailures]' >> ${JAILCONF}
    sys_msg 'logpath = /opt/openhab/logs/request.log' >> ${JAILCONF}
    sys_msg '[nginx-http-auth]' >> ${JAILCONF}
    sys_msg 'port    = http,https' >> ${JAILCONF}
    sys_msg 'logpath = %(nginx_error_log)s' >> ${JAILCONF}
    sys_msg '[nginx-limit-req]' >> ${JAILCONF}
    sys_msg 'port    = http,https' >> ${JAILCONF}
    sys_msg 'logpath = %(nginx_error_log)s' >> ${JAILCONF}
    sys_msg '[nginx-botsearch]' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = %(nginx_error_log)s' >> ${JAILCONF}
    sys_msg 'maxretry = 2' >> ${JAILCONF}
    sys_msg '[php-url-fopen]' >> ${JAILCONF}
    sys_msg 'port    = http,https' >> ${JAILCONF}
    sys_msg 'logpath = %(nginx_access_log)s' >> ${JAILCONF}
    sys_msg '          %(apache_access_log)s' >> ${JAILCONF}
    sys_msg '[suhosin]' >> ${JAILCONF}
    sys_msg 'port    = http,https' >> ${JAILCONF}
    sys_msg 'logpath = %(suhosin_log)s' >> ${JAILCONF}
    sys_msg '[lighttpd-auth]' >> ${JAILCONF}
    sys_msg 'port    = http,https' >> ${JAILCONF}
    sys_msg 'logpath = %(lighttpd_error_log)s' >> ${JAILCONF}
    sys_msg '[roundcube-auth]' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = %(roundcube_errors_log)s' >> ${JAILCONF}
    sys_msg '[openwebmail]' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = /var/log/openwebmail.log' >> ${JAILCONF}
    sys_msg '[horde]' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = /var/log/horde/horde.log' >> ${JAILCONF}
    sys_msg '[groupoffice]' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = /home/groupoffice/log/info.log' >> ${JAILCONF}
    sys_msg '[sogo-auth]' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = /var/log/sogo/sogo.log' >> ${JAILCONF}
    sys_msg '[tine20]' >> ${JAILCONF}
    sys_msg 'logpath  = /var/log/tine20/tine20.log' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg '[drupal-auth]' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = %(syslog_daemon)s' >> ${JAILCONF}
    sys_msg 'backend  = %(syslog_backend)s' >> ${JAILCONF}
    sys_msg '[guacamole]' >> ${JAILCONF}
    sys_msg 'port     = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = /var/log/tomcat*/catalina.out' >> ${JAILCONF}
    sys_msg '[monit]' >> ${JAILCONF}
    sys_msg '#Ban clients brute-forcing the monit gui login' >> ${JAILCONF}
    sys_msg 'port = 2812' >> ${JAILCONF}
    sys_msg 'logpath  = /var/log/monit' >> ${JAILCONF}
    sys_msg '[webmin-auth]' >> ${JAILCONF}
    sys_msg 'port    = 10000' >> ${JAILCONF}
    sys_msg 'logpath = %(syslog_authpriv)s' >> ${JAILCONF}
    sys_msg 'backend = %(syslog_backend)s' >> ${JAILCONF}
    sys_msg '[froxlor-auth]' >> ${JAILCONF}
    sys_msg 'port    = http,https' >> ${JAILCONF}
    sys_msg 'logpath  = %(syslog_authpriv)s' >> ${JAILCONF}
    sys_msg 'backend  = %(syslog_backend)s' >> ${JAILCONF}
    sys_msg '[3proxy]' >> ${JAILCONF}
    sys_msg 'port    = 3128' >> ${JAILCONF}
    sys_msg 'logpath = /var/log/3proxy.log' >> ${JAILCONF}
    sys_msg '[proftpd]' >> ${JAILCONF}
    sys_msg 'port     = ftp,ftp-data,ftps,ftps-data' >> ${JAILCONF}
    sys_msg 'logpath  = %(proftpd_log)s' >> ${JAILCONF}
    sys_msg 'backend  = %(proftpd_backend)s' >> ${JAILCONF}
    sys_msg '[pure-ftpd]' >> ${JAILCONF}
    sys_msg 'port     = ftp,ftp-data,ftps,ftps-data' >> ${JAILCONF}
    sys_msg 'logpath  = %(pureftpd_log)s' >> ${JAILCONF}
    sys_msg 'backend  = %(pureftpd_backend)s' >> ${JAILCONF}
    sys_msg '[gssftpd]' >> ${JAILCONF}
    sys_msg 'port     = ftp,ftp-data,ftps,ftps-data' >> ${JAILCONF}
    sys_msg 'logpath  = %(syslog_daemon)s' >> ${JAILCONF}
    sys_msg 'backend  = %(syslog_backend)s' >> ${JAILCONF}
    sys_msg '[wuftpd]' >> ${JAILCONF}
    sys_msg 'port     = ftp,ftp-data,ftps,ftps-data' >> ${JAILCONF}
    sys_msg 'logpath  = %(wuftpd_log)s' >> ${JAILCONF}
    sys_msg 'backend  = %(wuftpd_backend)s' >> ${JAILCONF}
    sys_msg '[vsftpd]' >> ${JAILCONF}
    sys_msg 'port     = ftp,ftp-data,ftps,ftps-data' >> ${JAILCONF}
    sys_msg 'logpath  = %(vsftpd_log)s' >> ${JAILCONF}
    sys_msg '[assp]' >> ${JAILCONF}
    sys_msg 'port     = smtp,465,submission' >> ${JAILCONF}
    sys_msg 'logpath  = /root/path/to/assp/logs/maillog.txt' >> ${JAILCONF}
    sys_msg '[courier-smtp]' >> ${JAILCONF}
    sys_msg 'port     = smtp,465,submission' >> ${JAILCONF}
    sys_msg 'logpath  = %(syslog_mail)s' >> ${JAILCONF}
    sys_msg 'backend  = %(syslog_backend)s' >> ${JAILCONF}
    sys_msg '[postfix]' >> ${JAILCONF}
    sys_msg 'port     = smtp,465,submission' >> ${JAILCONF}
    sys_msg 'logpath  = %(postfix_log)s' >> ${JAILCONF}
    sys_msg 'backend  = %(postfix_backend)s' >> ${JAILCONF}
    sys_msg '[postfix-rbl]' >> ${JAILCONF}
    sys_msg 'port     = smtp,465,submission' >> ${JAILCONF}
    sys_msg 'logpath  = %(postfix_log)s' >> ${JAILCONF}
    sys_msg 'backend  = %(postfix_backend)s' >> ${JAILCONF}
    sys_msg 'maxretry = 1' >> ${JAILCONF}
    sys_msg '[sendmail-auth]' >> ${JAILCONF}
    sys_msg 'port    = submission,465,smtp' >> ${JAILCONF}
    sys_msg 'logpath = %(syslog_mail)s' >> ${JAILCONF}
    sys_msg 'backend = %(syslog_backend)s' >> ${JAILCONF}
    sys_msg '[sendmail-reject]' >> ${JAILCONF}
    sys_msg 'port     = smtp,465,submission' >> ${JAILCONF}
    sys_msg 'logpath  = %(syslog_mail)s' >> ${JAILCONF}
    sys_msg 'backend  = %(syslog_backend)s' >> ${JAILCONF}
    sys_msg '[qmail-rbl]' >> ${JAILCONF}
    sys_msg 'filter  = qmail' >> ${JAILCONF}
    sys_msg 'port    = smtp,465,submission' >> ${JAILCONF}
    sys_msg 'logpath = /service/qmail/log/main/current' >> ${JAILCONF}
    sys_msg '[dovecot]' >> ${JAILCONF}
    sys_msg 'port    = pop3,pop3s,imap,imaps,submission,465,sieve' >> ${JAILCONF}
    sys_msg 'logpath = %(dovecot_log)s' >> ${JAILCONF}
    sys_msg 'backend = %(dovecot_backend)s' >> ${JAILCONF}
    sys_msg '[sieve]' >> ${JAILCONF}
    sys_msg 'port   = smtp,465,submission' >> ${JAILCONF}
    sys_msg 'logpath = %(dovecot_log)s' >> ${JAILCONF}
    sys_msg 'backend = %(dovecot_backend)s' >> ${JAILCONF}
    sys_msg '[solid-pop3d]' >> ${JAILCONF}
    sys_msg 'port    = pop3,pop3s' >> ${JAILCONF}
    sys_msg 'logpath = %(solidpop3d_log)s' >> ${JAILCONF}
    sys_msg '[exim]' >> ${JAILCONF}
    sys_msg 'port   = smtp,465,submission' >> ${JAILCONF}
    sys_msg 'logpath = %(exim_main_log)s' >> ${JAILCONF}
    sys_msg '[exim-spam]' >> ${JAILCONF}
    sys_msg 'port   = smtp,465,submission' >> ${JAILCONF}
    sys_msg 'logpath = %(exim_main_log)s' >> ${JAILCONF}
    sys_msg '[kerio]' >> ${JAILCONF}
    sys_msg 'port    = imap,smtp,imaps,465' >> ${JAILCONF}
    sys_msg 'logpath = /opt/kerio/mailserver/store/logs/security.log' >> ${JAILCONF}
    sys_msg '[courier-auth]' >> ${JAILCONF}
    sys_msg 'port     = smtp,465,submission,imap3,imaps,pop3,pop3s' >> ${JAILCONF}
    sys_msg 'logpath  = %(syslog_mail)s' >> ${JAILCONF}
    sys_msg 'backend  = %(syslog_backend)s' >> ${JAILCONF}
    sys_msg '[postfix-sasl]' >> ${JAILCONF}
    sys_msg 'port     = smtp,465,submission,imap3,imaps,pop3,pop3s' >> ${JAILCONF}
    sys_msg 'logpath  = %(postfix_log)s' >> ${JAILCONF}
    sys_msg 'backend  = %(postfix_backend)s' >> ${JAILCONF}
    sys_msg '[perdition]' >> ${JAILCONF}
    sys_msg 'port   = imap3,imaps,pop3,pop3s' >> ${JAILCONF}
    sys_msg 'logpath = %(syslog_mail)s' >> ${JAILCONF}
    sys_msg 'backend = %(syslog_backend)s' >> ${JAILCONF}
    sys_msg '[squirrelmail]' >> ${JAILCONF}
    sys_msg 'port = smtp,465,submission,imap2,imap3,imaps,pop3,pop3s,http,https,socks' >> ${JAILCONF}
    sys_msg 'logpath = /var/lib/squirrelmail/prefs/squirrelmail_access_log' >> ${JAILCONF}
    sys_msg '[cyrus-imap]' >> ${JAILCONF}
    sys_msg 'port   = imap3,imaps' >> ${JAILCONF}
    sys_msg 'logpath = %(syslog_mail)s' >> ${JAILCONF}
    sys_msg 'backend = %(syslog_backend)s' >> ${JAILCONF}
    sys_msg '[uwimap-auth]' >> ${JAILCONF}
    sys_msg 'port   = imap3,imaps' >> ${JAILCONF}
    sys_msg 'logpath = %(syslog_mail)s' >> ${JAILCONF}
    sys_msg 'backend = %(syslog_backend)s' >> ${JAILCONF}
    sys_msg '[named-refused]' >> ${JAILCONF}
    sys_msg 'port     = domain,953' >> ${JAILCONF}
    sys_msg 'logpath  = /var/log/named/security.log' >> ${JAILCONF}
    sys_msg '[nsd]' >> ${JAILCONF}
    sys_msg 'port     = 53' >> ${JAILCONF}
    sys_msg 'action   = %(banaction)s[name=%(__name__)s-tcp, port="%(port)s", protocol="tcp", chain="%(chain)s", actname=%(banaction)s-tcp]' >> ${JAILCONF}
    sys_msg '           %(banaction)s[name=%(__name__)s-udp, port="%(port)s", protocol="udp", chain="%(chain)s", actname=%(banaction)s-udp]' >> ${JAILCONF}
    sys_msg 'logpath = /var/log/nsd.log' >> ${JAILCONF}
    sys_msg '[asterisk]' >> ${JAILCONF}
    sys_msg 'port     = 5060,5061' >> ${JAILCONF}
    sys_msg 'action   = %(banaction)s[name=%(__name__)s-tcp, port="%(port)s", protocol="tcp", chain="%(chain)s", actname=%(banaction)s-tcp]' >> ${JAILCONF}
    sys_msg '           %(banaction)s[name=%(__name__)s-udp, port="%(port)s", protocol="udp", chain="%(chain)s", actname=%(banaction)s-udp]' >> ${JAILCONF}
    sys_msg '           %(mta)s-whois[name=%(__name__)s, dest="%(destemail)s"]' >> ${JAILCONF}
    sys_msg 'logpath  = /var/log/asterisk/messages' >> ${JAILCONF}
    sys_msg 'maxretry = 10' >> ${JAILCONF}
    sys_msg '[freeswitch]' >> ${JAILCONF}
    sys_msg 'port     = 5060,5061' >> ${JAILCONF}
    sys_msg 'action   = %(banaction)s[name=%(__name__)s-tcp, port="%(port)s", protocol="tcp", chain="%(chain)s", actname=%(banaction)s-tcp]' >> ${JAILCONF}
    sys_msg '           %(banaction)s[name=%(__name__)s-udp, port="%(port)s", protocol="udp", chain="%(chain)s", actname=%(banaction)s-udp]' >> ${JAILCONF}
    sys_msg '           %(mta)s-whois[name=%(__name__)s, dest="%(destemail)s"]' >> ${JAILCONF}
    sys_msg 'logpath  = /var/log/freeswitch.log' >> ${JAILCONF}
    sys_msg 'maxretry = 10' >> ${JAILCONF}
    sys_msg '[mysqld-auth]' >> ${JAILCONF}
    sys_msg 'port     = 3306' >> ${JAILCONF}
    sys_msg 'logpath  = %(mysql_log)s' >> ${JAILCONF}
    sys_msg 'backend  = %(mysql_backend)s' >> ${JAILCONF}
    sys_msg '[recidive]' >> ${JAILCONF}
    sys_msg 'logpath  = /var/log/fail2ban.log' >> ${JAILCONF}
    sys_msg 'banaction = %(banaction_allports)s' >> ${JAILCONF}
    sys_msg 'bantime  = 604800  ; 1 week' >> ${JAILCONF}
    sys_msg 'findtime = 86400   ; 1 day' >> ${JAILCONF}
    sys_msg '[pam-generic]' >> ${JAILCONF}
    sys_msg 'banaction = %(banaction_allports)s' >> ${JAILCONF}
    sys_msg 'logpath  = %(syslog_authpriv)s' >> ${JAILCONF}
    sys_msg 'backend  = %(syslog_backend)s' >> ${JAILCONF}
    sys_msg '[xinetd-fail]' >> ${JAILCONF}
    sys_msg 'banaction = iptables-multiport-log' >> ${JAILCONF}
    sys_msg 'logpath   = %(syslog_daemon)s' >> ${JAILCONF}
    sys_msg 'backend   = %(syslog_backend)s' >> ${JAILCONF}
    sys_msg 'maxretry  = 2' >> ${JAILCONF}
    sys_msg '[stunnel]' >> ${JAILCONF}
    sys_msg 'logpath = /var/log/stunnel4/stunnel.log' >> ${JAILCONF}
    sys_msg '[ejabberd-auth]' >> ${JAILCONF}
    sys_msg 'port    = 5222' >> ${JAILCONF}
    sys_msg 'logpath = /var/log/ejabberd/ejabberd.log' >> ${JAILCONF}
    sys_msg '[counter-strike]' >> ${JAILCONF}
    sys_msg 'logpath = /opt/cstrike/logs/L[0-9]*.log' >> ${JAILCONF}
    sys_msg 'tcpport = 27030,27031,27032,27033,27034,27035,27036,27037,27038,27039' >> ${JAILCONF}
    sys_msg 'udpport = 1200,27000,27001,27002,27003,27004,27005,27006,27007,27008,27009,27010,27011,27012,27013,27014,27015' >> ${JAILCONF}
    sys_msg 'action  = %(banaction)s[name=%(__name__)s-tcp, port="%(tcpport)s", protocol="tcp", chain="%(chain)s", actname=%(banaction)s-tcp]' >> ${JAILCONF}
    sys_msg '           %(banaction)s[name=%(__name__)s-udp, port="%(udpport)s", protocol="udp", chain="%(chain)s", actname=%(banaction)s-udp]' >> ${JAILCONF}
    sys_msg '[nagios]' >> ${JAILCONF}
    sys_msg 'logpath  = %(syslog_daemon)s     ; nrpe.cfg may define a different log_facility' >> ${JAILCONF}
    sys_msg 'backend  = %(syslog_backend)s' >> ${JAILCONF}
    sys_msg 'maxretry = 1' >> ${JAILCONF}
    sys_msg '[directadmin]' >> ${JAILCONF}
    sys_msg 'logpath = /var/log/directadmin/login.log' >> ${JAILCONF}
    sys_msg 'port = 2222' >> ${JAILCONF}
    sys_msg '[portsentry]' >> ${JAILCONF}
    sys_msg 'logpath  = /var/lib/portsentry/portsentry.history' >> ${JAILCONF}
    sys_msg 'maxretry = 1' >> ${JAILCONF}
    sys_msg '[pass2allow-ftp]' >> ${JAILCONF}
    sys_msg '# this pass2allow example allows FTP traffic after successful HTTP authentication' >> ${JAILCONF}
    sys_msg 'port         = ftp,ftp-data,ftps,ftps-data' >> ${JAILCONF}
    sys_msg '# knocking_url variable must be overridden to some secret value in filter.d/apache-pass.local' >> ${JAILCONF}
    sys_msg 'filter       = apache-pass' >> ${JAILCONF}
    sys_msg '# access log of the website with HTTP auth' >> ${JAILCONF}
    sys_msg 'logpath      = %(apache_access_log)s' >> ${JAILCONF}
    sys_msg 'blocktype    = RETURN' >> ${JAILCONF}
    sys_msg 'returntype   = DROP' >> ${JAILCONF}
    sys_msg 'bantime      = 3600' >> ${JAILCONF}
    sys_msg 'maxretry     = 1' >> ${JAILCONF}
    sys_msg 'findtime     = 1' >> ${JAILCONF}
    sys_msg '[murmur]' >> ${JAILCONF}
    sys_msg 'port     = 64738' >> ${JAILCONF}
    sys_msg 'action   = %(banaction)s[name=%(__name__)s-tcp, port="%(port)s", protocol=tcp, chain="%(chain)s", actname=%(banaction)s-tcp]' >> ${JAILCONF}
    sys_msg '           %(banaction)s[name=%(__name__)s-udp, port="%(port)s", protocol=udp, chain="%(chain)s", actname=%(banaction)s-udp]' >> ${JAILCONF}
    sys_msg 'logpath  = /var/log/mumble-server/mumble-server.log' >> ${JAILCONF}
    sys_msg '[screensharingd]' >> ${JAILCONF}
    sys_msg 'logpath  = /var/log/system.log' >> ${JAILCONF}
    sys_msg 'logencoding = utf-8' >> ${JAILCONF}
    sys_msg '[haproxy-http-auth]' >> ${JAILCONF}
    sys_msg 'logpath  = /var/log/haproxy.log' >> ${JAILCONF}
    [[ -e ${HOMEF2B} ]] && rm ${HOMEF2B}
    [[ -d ${HOMEF2B}-0.9.4 ]] && rm -rf ${HOMEF2B}-0.9.4
    service fail2ban restart
    msg -bar
    msg -ama "Instalado Com Sucesso"
  fi
}
function fun_eth () {
  local tx rx sshsn
  local eth=$(ifconfig | grep -v inet6 | grep -v lo | grep -v 127.0.0.1 | grep "encap:Ethernet" | awk '{print $1}')
  if [[ $eth != "" ]]; then
    fun -bar
    msg -ama "Aplicar Sistema Para Melhorar Pacotes Ssh?"
    msg -ama "Opcao Para Usuarios Avancados"
    fun -bar
    while :
    do
      sys_msg -ne "Instalar Sisteme de Melhora de Pacotes [S/N]: "
      read sshsn
      fun_up 1
      [[ "$sshsn" = @(s|S|y|Y|n|N) ]] && break
    done
    if [[ "$sshsn" = @(s|S|y|Y) ]]; then
      msg -ama "Correcao de problemas de pacotes no SSH"
      msg -ama "Qual A Taxa RX"
      while :
      do
        sys_msg -ne "[ 1 - 999999999 ]: "
        read rx
        fun_up 1
        if [[ -z "${rx}" ]]; then
          fun_up 1
          err_fun 16 && continue
        elif [[ "${rx}" != +([0-9]) ]]; then
          fun_up 1
          err_fun 17 && continue
        elif [[ "${rx}" -gt "999999999" ]]; then
          fun_up 1
          err_fun 18 && continue
        else
          break
        fi
      done
      msg -ama "Qual A Taxa TX"
      while :
      do
        sys_msg -ne "[ 1 - 999999999 ]: "
        read tx
        if [[ -z "${tx}" ]]; then
          fun_up 1
          err_fun 16 && continue
        elif [[ "${tx}" != +([0-9]) ]]; then
          fun_up 1
          err_fun 17 && continue
        elif [[ "${tx}" -gt "999999999" ]]; then
          fun_up 1
          err_fun 18 && continue
        else
          break
        fi
      done
      apt-get install ethtool -y > /dev/null 2>&1
      ethtool -G $eth rx $rx tx $tx > /dev/null 2>&1 && msg -ama "Sucesso Correcao Aplicada com Exito" || msg -verm "Erro Correcao ETH nao Aplicada"
    fi
  else
  msg -ama "eth-tool nao compativel"
  fi
}
function fun_allowports () {
  for UF in $(fun_listports|awk '{print $2}'); do
    ufw allow ${UF} > /dev/null 2>&1
  done
}
function fun_addscript () {
  msg -verm "ATENCAO"
  msg -ama "nao introduza uma key de atualizacao aqui"
  msg -ama "Digite o link Para o Novo Recurso"
  msg -ama "Ex: www.dropbox.com/openvpn-gestor"
  msg -bar
  local Key
  while [[ -z $Key ]]; do
    sys_msg -ne "[Link]: " && read Key
    fun_up 1
  done
  sys_msg "$(msg -ama "Verificando link"): ${Key}"
  curl "${Key}" &> /dev/null
  if [[ $? = "0" ]]; then
    msg -verd "Link Valido"
    local REC=$(sys_msg ${Key}|awk -F"/" '{print $NF}')
    sys_msg "$(msg -ama "Recebendo Recurso"): \033[1;31m[$REC]"
    wget -O ${SCPinst}/${REC} ${Key} &>/dev/null && msg -verd "Arquivo Recebido" || msg -verm "Falha ao Receber"
    [[ -e ${SCPinst}/${REC} ]] && chmod +x ${SCPinst}/${REC} 
  fi
}
function fun_rmvscript () {
  local arqs script selection
  local i=0
  local ITENS=$(ls ${SCPinst})
  msg -verm "ATENCAO"
  msg -ama "Esse Processo Nao Podera ser Desfeito"
  msg -ama "Selecione a Ferramenta que Deseja Remover"
  msg -bar
  if [[ -z ${ITENS} ]]; then
    msg -verm "Ops, Voce nao tem Ferramentas para Remover"
    msg -bar
    return 0
  else
    for arqs in $ITENS; do
      let i++
      sys_msg -ne "\033[1;32m [$i] > " && sys_msg "$(msg -ama "SCRIPT") - [${arqs}]"
      script[$i]="$arqs"
    done
  fi
  sys_msg -ne "\033[1;32m [0] > " && msg -bra "VOLTAR AO MENU"
  msg -bar
  fun_selectopt ${i} && local SELECT="$RETORNO"
  if [[ ${SELECT} = "0" ]]; then
    return 0
  else
    if [[ -e "${SCPinst}/${script[$SELECT]}" ]]; then
      rm ${SCPinst}/${script[$SELECT]}
      sys_msg "$(msg -ama "SCRIPT REMOVIDO COM SUCESSO") - [${script[$SELECT]}]"
    fi
  fi
}
# Funcoes Complementares
function fun_bar () {
  local PID="/tmp/$RANDOM"
  local Thread="/tmp/Thread.sh"
  local VAR="\033[1;33m[\033[1;31m"
  local FIN="\033[1;33m]\033[0m"
  echo '#!/bin/bash' > ${Thread}
  echo "$@" >> ${Thread}
  echo "touch ${PID}" >> ${Thread}
  chmod +x ${Thread}
  screen -dmS Thread ${Thread}
  while :
    do
    for loop in $(seq 1 30); do
      VAR+="#"
      echo -e "${VAR}${FIN}"
      sleep 0.1s
      fun_up 1
    done
    if [[ -e ${PID} ]]; then
      rm ${PID}
      rm ${Thread}
      echo -e "${VAR}${FIN} -\033[1;32m 100%\033[0m"
      break
    else
      VAR="\033[1;33m[\033[1;31m"
    fi
  done
}
# Instalador Dropbear
function fun_dropbear () {
  local PT
  local RESPOST
  local RETORNO
  local DROPBEAR="/etc/default/dropbear"
  msg -bar
  msg -ama "INSTALADOR DROPBEAR ADM-ULTIMATE"
  msg -bar
  if [[ -e ${DROPBEAR} ]]; then
    msg -ama "Tem Certeza que Deseja Remover Dropbear"
    fun_yesno && RESPOST="${RETORNO}"
    if [[ "${RESPOST}" = @(s|S|y|Y) ]]; then
      msg -verm "Removendo Dropbear"
      service dropbear stop & >/dev/null 2>&1
      fun_bar "apt-get remove dropbear -y"
      msg -ama "Removido Com Sucesso"
      [[ -e ${DROPBEAR} ]] && rm ${DROPBEAR}
    fi
  else
    local UF PORTS
    local SSHD="/etc/ssh/sshd_config"
    local BANNER="/etc/bannerssh"
    msg -ama "Selecione Portas Para sua Instalacao"
    sys_msg "\033[1;32m22 80 81 82 85 90 201 2020 8080 9090\033[1;37m"
    msg -bar
    while :
    do
      select_port && PORTS+="${RETORNO} "
      msg -ama "Adicionar Outra Porta?"
      fun_yesno && RESPOST="${RETORNO}"
      fun_up 3
      [[ "${RESPOST}" = @(n|N) ]] && break
    done
    fun_up 1
    for PT in ${PORTS}; do
      sys_msg "$(msg -ne "Porta"): [${PT}] - OK"
    done
    msg -bar
    msg -ama "Instalando dropbear"
    fun_bar "apt-get install dropbear -y"
    [[ ! $(cat /etc/shells|grep "/bin/false") ]] && sys_msg "/bin/false" >> /etc/shells
    [[ ! -e ${BANNER} ]] && sys_msg "" > ${BANNER}
    msg -ama "Modificando SSHD"
    if [[ -e "${SSHD}" ]]; then
      sys_msg "Port 22" > ${SSHD}
      sys_msg "Protocol 2" >> ${SSHD}
      sys_msg "KeyRegenerationInterval 3600" >> ${SSHD}
      sys_msg "ServerKeyBits 1024" >> ${SSHD}
      sys_msg "SyslogFacility AUTH" >> ${SSHD}
      sys_msg "LogLevel INFO" >> ${SSHD}
      sys_msg "LoginGraceTime 120" >> ${SSHD}
      sys_msg "PermitRootLogin yes" >> ${SSHD}
      sys_msg "StrictModes yes" >> ${SSHD}
      sys_msg "RSAAuthentication yes" >> ${SSHD}
      sys_msg "PubkeyAuthentication yes" >> ${SSHD}
      sys_msg "IgnoreRhosts yes" >> ${SSHD}
      sys_msg "RhostsRSAAuthentication no" >> ${SSHD}
      sys_msg "HostbasedAuthentication no" >> ${SSHD}
      sys_msg "PermitEmptyPasswords no" >> ${SSHD}
      sys_msg "ChallengeResponseAuthentication no" >> ${SSHD}
      sys_msg "PasswordAuthentication yes" >> ${SSHD}
      sys_msg "X11Forwarding yes" >> ${SSHD}
      sys_msg "X11DisplayOffset 10" >> ${SSHD}
      sys_msg "PrintMotd no" >> ${SSHD}
      sys_msg "PrintLastLog yes" >> ${SSHD}
      sys_msg "TCPKeepAlive yes" >> ${SSHD}
      sys_msg "AcceptEnv LANG LC_*" >> ${SSHD}
      sys_msg "Subsystem sftp /usr/lib/openssh/sftp-server" >> ${SSHD}
      sys_msg "UsePAM yes" >> ${SSHD}
    fi
    msg -ama "Configurando Dropbear"
    sys_msg "NO_START=0" > ${DROPBEAR}
    sys_msg 'DROPBEAR_EXTRA_ARGS="VAR"' >> ${DROPBEAR}
    sys_msg 'DROPBEAR_BANNER="/etc/bannerssh"' >> ${DROPBEAR}
    sys_msg "DROPBEAR_RECEIVE_WINDOW=65536" >> ${DROPBEAR}
    for PT in ${PORTS}; do
      sed -i "s/VAR/-p ${PT} VAR/g" ${DROPBEAR}
    done
    sed -i "s/VAR//g" ${DROPBEAR}
    fun_eth
    service ssh restart > /dev/null 2>&1
    service dropbear restart > /dev/null 2>&1
    fun_allowports
    msg -ama "Configurado Com Sucesso"
  fi
}
function fun_adddns () {
  msg -ama "CONFIGURACAO HOST DNS OPENVPN"
  msg -bar
  local DDNS
  msg -ama "Adicionar HOST?"
  while [[ ${DDNS} != @(n|N) ]]; do
    fun_yesno && DDNS="${RETORNO}"
    if [[ ${DDNS} = @(s|S|y|Y) ]]; then
      local SELECTION
      local TEMP="/tmp/file"
      local HOSTOVPN="/etc/opendns"
      local HOST="/etc/hosts"
      msg -ama "Digite o HOST DNS que deseja Adicionar"
      while :
      do
        msg -ne "Digite o Endereco do Host"
        sys_msg -ne " [www.host.com]: "
        read SELECTION      
        curl "${SELECTION}" > /dev/null 2>&1
        if [[ $? = "0" ]]; then
          msg -ne "Adicionado Host"
          sys_msg -ve " [${SELECTION}]: "
          break
        else
          msg -verm "Host Invalido" && read
        fi
        fun_up 3
      done
      if [[ -e ${HOSTOVPN} ]]; then
        grep -v "${SELECTION}" ${HOST} > ${TEMP}
        mv -f ${TEMP} ${HOST}
        grep -v "${SELECTION}" ${HOSTOVPN} > ${TEMP}
        sys_msg "${SELECTION}" >> ${TEMP}
        mv -f ${TEMP} ${HOSTOVPN}
      else
        sys_msg "${SELECTION}" >> ${HOSTOVPN}
      fi
      sed -i "/127.0.0.1[[:blank:]]\+localhost/a 127.0.0.1 ${SELECTION}" ${HOST}
      sed -i "/remote ${IP} ${PORT} ${PROTOCOL}/a remote ${SELECTION} ${PORT} ${PROTOCOL}" /etc/openvpn/client-common.txt
    fi
  done
  msg -ama "Configuracoes Aplicadas"
}
function openvpn_starts () {
  local DIR="/etc/openvpn"
  if [[ -z $(ps x|grep openvpn|grep -v grep|awk '{print $1}') ]]; then
    cd ${DIR} && screen -dmS openvpn openvpn --config "${DIR}/openvpn.conf" && msg -ama "OPENVPN INICIADO COM SUCESSO!"
    cd ${HOME}
  else
    for pids in $(ps x|grep openvpn|grep -v grep|awk '{print $1}'); do
      kill -9 ${pids}
    done
    msg -ama "OPENVPN ENCERRADO COM SUCESSO!"
  fi
}
function fun_openvpn () {
  msg -ama "Este e o Instalador Openvpn ADM"
  msg -ama "Fazendo uma Breve Verificacao na Maquina."
  if [[ ! -e /dev/net/tun ]]; then
    msg -verm "Seu Sistema Nao e Compativel com OPENVPN"
  fi
  if [[ -e /etc/debian_version ]]; then
    local INIT="/etc/init.d/openvpn_starts"
    local CIPHER DNS PROTOCOL RETORNO PORT NAME VERSION ID ID_LIKE PRETTY_NAME VERSION_ID HOME_URL SUPPORT_URL BUG_REPORT_URL PRIVACY_POLICY_URL VERSION_CODENAME UBUNTU_CODENAME
    local OS="debian"
    local TMP="/tmp/output"
    local IPTABLES='/etc/iptables/iptables.rules'
    local SYSCTL='/etc/sysctl.conf'
    local IP="$(fun_ip)"
    local OPENVPNCONF="/etc/openvpn/openvpn.conf"
    [[ ! -d /etc/iptables ]] && mkdir /etc/iptables
    [[ ! -d /etc/openvpn ]] && mkdir /etc/openvpn
    [[ ! -e $IPTABLES ]] && touch $IPTABLES
    source /etc/os-release
  else
    msg -ama "Somente maquinas Debian ou Ubuntu sao Suportadas"
    msg -bar
    return 1
  fi
  local NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
  msg -ama "Sistema Preparado Para Receber o OPENVPN"
  msg -bar
  sys_msg "deb http://build.openvpn.net/debian/openvpn/stable ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/openvpn-aptrepo.list
  wget -O ${TMP} https://swupdate.openvpn.net/repos/repo-public.gpg > /dev/null 2>&1
  apt-key add ${TMP} > /dev/null 2>&1 && rm ${TMP}
  msg -ama "Responda as perguntas para iniciar a instalacao"
  msg -ama "Responda corretamente"
  msg -ama "Primeiro precisamos do ip de sua maquina, este ip esta correto?"
  msg -ama "Precione Enter se Estiver Tudo ok"
  select_uip && local IP="$RETORNO"
  sys_msg "$(msg -ne "Qual porta voce deseja usar?") 443, 1194..."
  select_port && local PORT="${RETORNO}"
  msg -ama "Qual protocolo voce deseja para as conexoes OPENVPN?"
  msg -ama "A menos que o UDP esteja bloqueado, voce nao deve usar o TCP (mais lento)"
  while [[ $PROTOCOL != @(UDP|TCP) ]]; do
    read -p "Protocol [UDP/TCP]: " -e -i TCP PROTOCOL
  done
  [[ $PROTOCOL = "UDP" ]] && PROTOCOL=udp
  [[ $PROTOCOL = "TCP" ]] && PROTOCOL=tcp
  msg -ama "Qual DNS voce deseja usar?"
  msg -bar
  sys_msg -ne "\033[1;32m [0] > " && msg -azu "Usar padroes do sistema"
  sys_msg -ne "\033[1;32m [1] > " && msg -azu "Cloudflare"
  sys_msg -ne "\033[1;32m [2] > " && msg -azu "Quad"
  sys_msg -ne "\033[1;32m [3] > " && msg -azu "FDN"
  sys_msg -ne "\033[1;32m [4] > " && msg -azu "DNS.WATCH"
  sys_msg -ne "\033[1;32m [5] > " && msg -azu "OpenDNS"
  sys_msg -ne "\033[1;32m [6] > " && msg -azu "Google DNS"
  sys_msg -ne "\033[1;32m [7] > " && msg -azu "Yandex Basic"
  sys_msg -ne "\033[1;32m [8] > " && msg -azu "AdGuard DNS"
  msg -bar
  fun_selectopt 8 && local SELECT="$RETORNO"
  declare -A DNS
  case ${SELECT} in
    0)
    local i=0
    local LINE
    for LINE in $(grep -v '#' /etc/resolv.conf|grep 'nameserver'|grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'); do
      DNS[$i]='push "dhcp-option DNS '
      DNS[$i]+="${LINE}"
      DNS[$i]+='"'
      let i++
    done
    [[ ! "${DNS[0]}" ]] && DNS[0]='push "dhcp-option DNS 8.8.8.8"'
    [[ ! "${DNS[1]}" ]] && DNS[1]='push "dhcp-option DNS 8.8.4.4"';;
    1)
    DNS[0]='push "dhcp-option DNS 1.0.0.1"'
    DNS[1]='push "dhcp-option DNS 1.1.1.1"';;
    2)
    DNS[0]='push "dhcp-option DNS 9.9.9.9"'
    DNS[1]='push "dhcp-option DNS 1.1.1.1"';;
    3)
    DNS[0]='push "dhcp-option DNS 80.67.169.40"'
    DNS[1]='push "dhcp-option DNS 80.67.169.12"';;
    4)
    DNS[0]='push "dhcp-option DNS 84.200.69.80"'
    DNS[1]='push "dhcp-option DNS 84.200.70.40"';;
    5)
    DNS[0]='push "dhcp-option DNS 208.67.222.222"'
    DNS[1]='push "dhcp-option DNS 208.67.220.220"';;
    6)
    DNS[0]='push "dhcp-option DNS 8.8.8.8"'
    DNS[1]='push "dhcp-option DNS 8.8.4.4"';;
    7)
    DNS[0]='push "dhcp-option DNS 77.88.8.8"'
    DNS[1]='push "dhcp-option DNS 77.88.8.1"';;
    8)
    DNS[0]='push "dhcp-option DNS 176.103.130.130"'
    DNS[1]='push "dhcp-option DNS 176.103.130.131"';;
  esac
  #CIPHER
  msg -bar
  msg -ama "Escolha qual codificacao voce deseja usar para o canal de dados:"
  msg -bar
  sys_msg -ne "\033[1;32m [0] > " && msg -azu "AES-128-CBC"
  sys_msg -ne "\033[1;32m [1] > " && msg -azu "AES-192-CBC"
  sys_msg -ne "\033[1;32m [2] > " && msg -azu "AES-256-CBC"
  sys_msg -ne "\033[1;32m [3] > " && msg -azu "CAMELLIA-128-CBC"
  sys_msg -ne "\033[1;32m [4] > " && msg -azu "CAMELLIA-192-CBC"
  sys_msg -ne "\033[1;32m [5] > " && msg -azu "CAMELLIA-256-CBC"
  sys_msg -ne "\033[1;32m [6] > " && msg -azu "SEED-CBC"
  msg -bar
  fun_selectopt 6 && local CIPHER="$RETORNO"
  case ${CIPHER} in
    0) CIPHER="cipher AES-128-CBC";;
    1) CIPHER="cipher AES-192-CBC";;
    2) CIPHER="cipher AES-256-CBC";;
    3) CIPHER="cipher CAMELLIA-128-CBC";;
    4) CIPHER="cipher CAMELLIA-192-CBC";;
    5) CIPHER="cipher CAMELLIA-256-CBC";;
    6) CIPHER="cipher SEED-CBC";;
  esac
  msg -bar
  msg -ama "Estamos prontos para configurar seu servidor OpenVPN"
  msg -verm "Atualizando"
  fun_bar "apt-get update -q"
  msg -verm "Instalando openvpn curl openssl"
  fun_bar "apt-get install -qy openvpn curl"
  fun_bar "apt-get install openssl -y"
  sys_msg 01 > /etc/openvpn/ca.srl
  sys_msg "port ${PORT}" > ${OPENVPNCONF}
  sys_msg "proto ${PROTOCOL}" >> ${OPENVPNCONF}  
  # Certificados
  sys_msg 'key /etc/openvpn/client-key.pem' >> ${OPENVPNCONF}
  sys_msg 'ca /etc/openvpn/ca.pem' >> ${OPENVPNCONF}
  sys_msg 'cert /etc/openvpn/client-cert.pem' >> ${OPENVPNCONF}
  sys_msg 'dh /etc/openvpn/dh.pem' >> ${OPENVPNCONF}
  sys_msg 'server 10.8.0.0 255.255.255.0' >> ${OPENVPNCONF}
  sys_msg 'verb 3' >> ${OPENVPNCONF}
  sys_msg 'duplicate-cn' >> ${OPENVPNCONF}
  sys_msg 'keepalive 10 120' >> ${OPENVPNCONF}
  sys_msg 'dev tun' >> ${OPENVPNCONF}
  sys_msg 'persist-key' >> ${OPENVPNCONF}
  sys_msg 'persist-tun' >> ${OPENVPNCONF}
  sys_msg 'comp-lzo' >> ${OPENVPNCONF}
  sys_msg 'float' >> ${OPENVPNCONF}
  sys_msg 'push "redirect-gateway def1 bypass-dhcp"' >> ${OPENVPNCONF}
  sys_msg "${DNS[0]}" >> ${OPENVPNCONF}
  sys_msg "${DNS[1]}" >> ${OPENVPNCONF}
  sys_msg 'user nobody' >> ${OPENVPNCONF}
  sys_msg 'group nogroup' >> ${OPENVPNCONF}
  sys_msg "${CIPHER}" >> ${OPENVPNCONF}
  sys_msg "proto ${PROTOCOL}" >> ${OPENVPNCONF}
  sys_msg 'allow-compression yes' >> ${OPENVPNCONF}
  sys_msg 'status openvpn-status.log' >> ${OPENVPNCONF}
  local PLUGIN=$(locate openvpn-plugin-auth-pam.so|head -1)
  if [[ ! -z $(sys_msg ${PLUGIN}) ]]; then
    sys_msg 'client-to-client' >> ${OPENVPNCONF}
    sys_msg 'verify-client-cert none' >> ${OPENVPNCONF}
    sys_msg 'username-as-common-name' >> ${OPENVPNCONF}
    sys_msg "plugin $PLUGIN openvpn" >> ${OPENVPNCONF}
  fi
  updatedb
  msg -verm "Gerando Certificados"
  while [[ ! -e /etc/openvpn/ca-key.pem || -z $(cat /etc/openvpn/ca-key.pem) ]]; do
    openssl genrsa -out /etc/openvpn/ca-key.pem 2048 &>/dev/null
  done
  chmod 600 /etc/openvpn/ca-key.pem &>/dev/null
  while [[ ! -e /etc/openvpn/ca-csr.pem || -z $(cat /etc/openvpn/ca-csr.pem) ]]; do
    openssl req -new -key /etc/openvpn/ca-key.pem -out /etc/openvpn/ca-csr.pem -subj /CN=OpenVPN-CA/ &>/dev/null
  done
  while [[ ! -e /etc/openvpn/ca.pem || -z $(cat /etc/openvpn/ca.pem) ]]; do
    openssl x509 -req -in /etc/openvpn/ca-csr.pem -out /etc/openvpn/ca.pem -signkey /etc/openvpn/ca-key.pem -days 365 &>/dev/null
  done
  while [[ ! -e /etc/openvpn/dh.pem || -z $(cat /etc/openvpn/dh.pem) ]]; do
    openssl dhparam -out /etc/openvpn/dh.pem 2048 &>/dev/null
  done
  while [[ ! -e /etc/openvpn/client-key.pem || -z $(cat /etc/openvpn/client-key.pem) ]]; do
    openssl genrsa -out /etc/openvpn/client-key.pem 2048 &>/dev/null
  done
  chmod 600 /etc/openvpn/client-key.pem
  while [[ ! -e /etc/openvpn/client-csr.pem || -z $(cat /etc/openvpn/client-csr.pem) ]]; do
    openssl req -new -key /etc/openvpn/client-key.pem -out /etc/openvpn/client-csr.pem -subj /CN=OpenVPN-Client/ &>/dev/null
  done
  while [[ ! -e /etc/openvpn/client-cert.pem || -z $(cat /etc/openvpn/client-cert.pem) ]]; do
    openssl x509 -req -in /etc/openvpn/client-csr.pem -out /etc/openvpn/client-cert.pem -CA /etc/openvpn/ca.pem -CAkey /etc/openvpn/ca-key.pem -days 365 &>/dev/null
  done
  local PROXY_PORT
  msg -bar
  msg -ama "Agora Precisamos da Porta Que Esta Seu Proxy"
  msg -bar
  sys_msg "$(msg -ne "Qual porta voce deseja usar?"): 80, 8080..."
  select_port_invertido && PROXY_PORT="${RETORNO}"
  sys_msg '# OVPN_ACCESS_SERVER_PROFILE=ADM-2022' > /etc/openvpn/client-common.txt
  sys_msg 'client' >> /etc/openvpn/client-common.txt
  sys_msg 'nobind' >> /etc/openvpn/client-common.txt
  sys_msg 'dev tun' >> /etc/openvpn/client-common.txt
  sys_msg 'redirect-gateway def1 bypass-dhcp' >> /etc/openvpn/client-common.txt
  sys_msg 'remote-random' >> /etc/openvpn/client-common.txt
  sys_msg "remote ${IP} ${PORT} ${PROTOCOL}" >> /etc/openvpn/client-common.txt
  sys_msg "http-proxy ${IP} ${PROXY_PORT}" >> /etc/openvpn/client-common.txt
  sys_msg "$CIPHER" >> /etc/openvpn/client-common.txt
  sys_msg 'comp-lzo yes' >> /etc/openvpn/client-common.txt
  sys_msg 'keepalive 10 20' >> /etc/openvpn/client-common.txt
  sys_msg 'float' >> /etc/openvpn/client-common.txt
  sys_msg 'auth-user-pass' >> /etc/openvpn/client-common.txt
  if [[ ! -f /proc/user_beancounters ]]; then
    local INTIP=$(ip a | awk -F"[ /]+" '/global/ && !/127.0/ {print $3; exit}')
    local N_INT=$(ip a |awk -v sip="${INTIP}" '$0 ~ sip { print $7}')
    iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o ${N_INT} -j MASQUERADE
  else
    iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to-source ${IP}
  fi
  iptables-save > /etc/iptables.conf
  sys_msg '#!/bin/sh' > /etc/network/if-up.d/iptables
  sys_msg 'iptables-restore < /etc/iptables.conf' >> /etc/network/if-up.d/iptables
  chmod +x /etc/network/if-up.d/iptables
  sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
  sys_msg 1 > /proc/sys/net/ipv4/ip_forward
  if pgrep firewalld; then
    if [[ "${PROTOCOL}" = 'udp' ]]; then
      firewall-cmd --zone=public --add-port=${PORT}/udp
      firewall-cmd --permanent --zone=public --add-port=${PORT}/udp
    elif [[ "${PROTOCOL}" = 'tcp' ]]; then
      firewall-cmd --zone=public --add-port=${PORT}/tcp
      firewall-cmd --permanent --zone=public --add-port=${PORT}/tcp
    fi
    firewall-cmd --zone=trusted --add-source=10.8.0.0/24
    firewall-cmd --permanent --zone=trusted --add-source=10.8.0.0/24
  fi
  if iptables -L -n | grep -qE 'REJECT|DROP'; then
    if [[ "${PROTOCOL}" = 'udp' ]]; then
      iptables -I INPUT -p udp --dport ${PORT} -j ACCEPT
    elif [[ "${PROTOCOL}" = 'tcp' ]]; then
      iptables -I INPUT -p tcp --dport ${PORT} -j ACCEPT
    fi
    iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT
    iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables-save > ${IPTABLES}
  fi
  if hash sestatus 2>/dev/null; then
    if sestatus | grep "Current mode" | grep -qs "enforcing"; then
      if [[ "${PORT}" != '1194' ]]; then
        if ! hash semanage 2>/dev/null; then
          apt-get install policycoreutils-python-utils -y
        fi
        if [[ "${PROTOCOL}" = 'udp' ]]; then
          semanage port -a -t openvpn_port_t -p udp ${PORT}
        elif [[ "${PROTOCOL}" = 'tcp' ]]; then
          semanage port -a -t openvpn_port_t -p tcp ${PORT}
        fi
      fi
    fi
  fi
  #Liberando DNS
  fun_adddns
  #Enables
  if pgrep systemd-journal; then
    sed -i 's|LimitNPROC|#LimitNPROC|' /lib/systemd/system/openvpn\@.service
    sed -i 's|/etc/openvpn/server|/etc/openvpn|' /lib/systemd/system/openvpn\@.service
    sed -i 's|%i.conf|server.conf|' /lib/systemd/system/openvpn\@.service
    systemctl restart openvpn > /dev/null 2>&1
    systemctl enable openvpn > /dev/null 2>&1
  fi
  service squid restart > /dev/null 2>&1
  service squid3 restart > /dev/null 2>&1
  #Liberar Portas
  fun_allowports
  sys_msg '#!/bin/bash' > ${INIT}
  sys_msg 'cd /etc/openvpn' >> ${INIT}
  sys_msg 'screen -dmS openvpn openvpn --config /etc/openvpn/openvpn.conf' >> ${INIT}
  sys_msg 'cd $HOME' >> ${INIT}
  chmod +x ${INIT}
  update-rc.d openvpn_starts defaults
  openvpn_starts
  msg -bar
  msg -ama "$(fun_trans "Openvpn Configurado Com Sucesso!")"
  msg -ama "$(fun_trans "Agora So Criar Um Usuario Para Gerar um Cliente!")"
}
function fun_squidinstall () {
  local PT
  local SQUIDPORT
  msg -ama "INSTALADOR SQUID ADM-ULTIMATE"
  msg -bar
  select_uip && local IP="${RETORNO}"
  msg -ama "Agora Escolha as Portas que Deseja No Squid"
  while :
    do
    select_port && SQUIDPORT+="${RETORNO} "
    msg -ama "Adicionar Outra Porta?"
    fun_yesno && RESPOST="${RETORNO}"
    fun_up 3
    [[ "${RESPOST}" = @(n|N) ]] && break
  done
  fun_up 1
  for PT in ${PORTS}; do
    sys_msg "$(msg -ne "Porta"): [${PT}] - OK"
  done
  msg -bar
  msg -ama "INSTALANDO SQUID"
  msg -bar
  fun_bar "apt-get install squid3 -y"
  msg -bar
  msg -ama "INICIANDO CONFIGURACAO"
  msg -bar
  if [[ -d /etc/squid ]]; then
    var_squid="/etc/squid/squid.conf"
  elif [[ -d /etc/squid3 ]]; then
    var_squid="/etc/squid3/squid.conf"
  fi
  sys_msg ".bookclaro.com.br/\n.claro.com.ar/\n.claro.com.br/\n.claro.com.co/\n.claro.com.ec/\n.claro.com.gt/\n.cloudfront.net/\n.claro.com.ni/\n.claro.com.pe/\n.claro.com.sv/\n.claro.cr/\n.clarocurtas.com.br/\n.claroideas.com/\n.claroideias.com.br/\n.claromusica.com/\n.clarosomdechamada.com.br/\n.clarovideo.com/\n.facebook.net/\n.facebook.com/\n.netclaro.com.br/\n.oi.com.br/\n.oimusica.com.br/\n.speedtest.net/\n.tim.com.br/\n.timanamaria.com.br/\n.vivo.com.br/\n.rdio.com/\n.compute-1.amazonaws.com/\n.portalrecarga.vivo.com.br/\n.vivo.ddivulga.com/" > ${PAYLOADS}
  [[ ! -e ${OPENPAYLOADS} ]] && touch ${OPENPAYLOADS}
  msg -ama "Agora Escolha Uma Conf Para Seu Proxy"
  msg -bar
  sys_msg -ne "\033[1;32m [0] > " && msg -azu "SQUID COMUM"
  sys_msg -ne "\033[1;32m [1] > " && msg -bra "SQUID CUSTOMIZADO"
  msg -bar
  fun_selectopt 1 && local ACLS="$RETORNO"
  sys_msg "#ConfiguracaoSquiD" > ${var_squid}
  # Auth
  # msg -bar
  # sys_msg -ne "\033[1;32m [1] > " && msg -azu "SQUID SEM AUTENTICACAO"
  # sys_msg -ne "\033[1;32m [2] > " && msg -bra "SQUID COM AUTENTICACAO"
  # msg -bar
  # unset SELECTION
  # while [[ ${SELECTION} != @(1|2) ]]; do
  #   msg -ne "Selecione a Opcao"
  #   sys_msg -ne ": "
  #   read SELECTION
  #   fun_up
  # done
  # if [[ ${SELECTION} = "2" ]]; then
  #   local AUTH=$(dpkg -L squid|grep ncsa_auth|head -1)
  #   if [[ ! -z ${AUTH} ]]; then
  #     name_user && local NAME="$RETORNO"
  #     pass_user && local PASS="$RETORNO"
  #     (sys_msg ${PASS}; sys_msg ${PASS}) | htpasswd -c /etc/squid/squid_passwd ${NAME} >/dev/null 2>&1
  #     sys_msg "auth_param basic program ${AUTH} /etc/squid/squid_passwd" >> ${var_squid}
  #     sys_msg "auth_param basic children 5" >> ${var_squid}
  #     sys_msg "auth_param basic realm Squid proxy-caching web server" >> ${var_squid}
  #     sys_msg "auth_param basic casesensitive off" >> ${var_squid}
  #   fi
  # fi
  sys_msg "acl url1 dstdomain ${IP}" >> ${var_squid}
  sys_msg "acl url2 dstdomain 127.0.0.1" >> ${var_squid}
  sys_msg "acl url5 dstdomain localhost" >> ${var_squid}
  sys_msg "acl url3 url_regex '/etc/payloads'" >> ${var_squid}
  sys_msg "acl url4 url_regex '/etc/opendns'" >> ${var_squid}
  [[ ! -z ${AUTH} ]] && sys_msg "acl auth proxy_auth REQUIRED" >> ${var_squid}
  case ${ACLS} in
    0)
      sys_msg "acl all src 0.0.0.0/0" >> ${var_squid}
      sys_msg "http_access allow url1" >> ${var_squid}
      sys_msg "http_access allow url2" >> ${var_squid}
      sys_msg "http_access allow url3" >> ${var_squid}
      sys_msg "http_access allow url4" >> ${var_squid}
      sys_msg "http_access allow url5" >> ${var_squid}
      [[ ! -z ${AUTH} ]] && sys_msg "http_access allow auth" >> ${var_squid}
      sys_msg "http_access deny all" >> ${var_squid}
      sys_msg "#portas" >> ${var_squid}
    ;;
    1)
      sys_msg "acl accept1 dstdomain GET" >> ${var_squid}
      sys_msg "acl accept2 dstdomain POST" >> ${var_squid}
      sys_msg "acl accept3 dstdomain OPTIONS" >> ${var_squid}
      sys_msg "acl accept4 dstdomain CONNECT" >> ${var_squid}
      sys_msg "acl accept5 dstdomain PUT" >> ${var_squid}
      sys_msg "acl accept6 dstdomain HEAD" >> ${var_squid}
      sys_msg "acl accept7 dstdomain TRACE" >> ${var_squid}
      sys_msg "acl accept8 dstdomain OPTIONS" >> ${var_squid}
      sys_msg "acl accept9 dstdomain PATCH" >> ${var_squid}
      sys_msg "acl accept10 dstdomain PROPATCH" >> ${var_squid}
      sys_msg "acl accept11 dstdomain DELETE" >> ${var_squid}
      sys_msg "acl accept12 dstdomain REQUEST" >> ${var_squid}
      sys_msg "acl accept13 dstdomain METHOD" >> ${var_squid}
      sys_msg "acl accept14 dstdomain NETDATA" >> ${var_squid}
      sys_msg "acl accept15 dstdomain MOVE" >> ${var_squid}
      sys_msg "acl all src 0.0.0.0/0" >> ${var_squid}
      sys_msg "http_access allow url1" >> ${var_squid}
      sys_msg "http_access allow url2" >> ${var_squid}
      sys_msg "http_access allow url3" >> ${var_squid}
      sys_msg "http_access allow url4" >> ${var_squid}
      sys_msg "http_access allow url5" >> ${var_squid}
      sys_msg "http_access allow accept1" >> ${var_squid}
      sys_msg "http_access allow accept2" >> ${var_squid}
      sys_msg "http_access allow accept3" >> ${var_squid}
      sys_msg "http_access allow accept4" >> ${var_squid}
      sys_msg "http_access allow accept5" >> ${var_squid}
      sys_msg "http_access allow accept6" >> ${var_squid}
      sys_msg "http_access allow accept7" >> ${var_squid}
      sys_msg "http_access allow accept8" >> ${var_squid}
      sys_msg "http_access allow accept9" >> ${var_squid}
      sys_msg "http_access allow accept10" >> ${var_squid}
      sys_msg "http_access allow accept11" >> ${var_squid}
      sys_msg "http_access allow accept12" >> ${var_squid}
      sys_msg "http_access allow accept13" >> ${var_squid}
      sys_msg "http_access allow accept14" >> ${var_squid}
      sys_msg "http_access allow accept15" >> ${var_squid}
      [[ ! -z ${AUTH} ]] && sys_msg "http_access allow auth" >> ${var_squid}
      sys_msg "http_access deny all" >> ${var_squid}
      sys_msg "# Request Headers Forcing" >> ${var_squid}
      sys_msg "request_header_access Allow allow all" >> ${var_squid}
      sys_msg "request_header_access Authorization allow all" >> ${var_squid}
      sys_msg "request_header_access WWW-Authenticate allow all" >> ${var_squid}
      sys_msg "request_header_access Proxy-Authorization allow all" >> ${var_squid}
      sys_msg "request_header_access Proxy-Authenticate allow all" >> ${var_squid}
      sys_msg "request_header_access Cache-Control allow all" >> ${var_squid}
      sys_msg "request_header_access Content-Encoding allow all" >> ${var_squid}
      sys_msg "request_header_access Content-Length allow all" >> ${var_squid}
      sys_msg "request_header_access Content-Type allow all" >> ${var_squid}
      sys_msg "request_header_access Date allow all" >> ${var_squid}
      sys_msg "request_header_access Expires allow all" >> ${var_squid}
      sys_msg "request_header_access Host allow all" >> ${var_squid}
      sys_msg "request_header_access If-Modified-Since allow all" >> ${var_squid}
      sys_msg "request_header_access Last-Modified allow all" >> ${var_squid}
      sys_msg "request_header_access Location allow all" >> ${var_squid}
      sys_msg "request_header_access Pragma allow all" >> ${var_squid}
      sys_msg "request_header_access Accept allow all" >> ${var_squid}
      sys_msg "request_header_access Accept-Charset allow all" >> ${var_squid}
      sys_msg "request_header_access Accept-Encoding allow all" >> ${var_squid}
      sys_msg "request_header_access Accept-Language allow all" >> ${var_squid}
      sys_msg "request_header_access Content-Language allow all" >> ${var_squid}
      sys_msg "request_header_access Mime-Version allow all" >> ${var_squid}
      sys_msg "request_header_access Retry-After allow all" >> ${var_squid}
      sys_msg "request_header_access Title allow all" >> ${var_squid}
      sys_msg "request_header_access Connection allow all" >> ${var_squid}
      sys_msg "request_header_access Proxy-Connection allow all" >> ${var_squid}
      sys_msg "request_header_access User-Agent allow all" >> ${var_squid}
      sys_msg "request_header_access Cookie allow all" >> ${var_squid}
      sys_msg "#request_header_access All deny all" >> ${var_squid}
      sys_msg "# Response Headers Spoofing" >> ${var_squid}
      sys_msg "#reply_header_access Via deny all" >> ${var_squid}
      sys_msg "#reply_header_access X-Cache deny all" >> ${var_squid}
      sys_msg "#reply_header_access X-Cache-Lookup deny all" >> ${var_squid}
      sys_msg "#portas" >> ${var_squid}
    ;;
  esac
  for PT in ${SQUIDPORT}; do
    sys_msg "http_port ${PT}" >> ${var_squid}
  done
  sys_msg "#nome" >> ${var_squid}
  sys_msg "visible_hostname ADM-MANAGER" >> ${var_squid}
  sys_msg "via off" >> ${var_squid}
  sys_msg "forwarded_for off" >> ${var_squid}
  sys_msg "pipeline_prefetch off" >> ${var_squid}
  fun_eth
  msg -ne "REINICIANDO SERVICOS"
  squid3 -k reconfigure > /dev/null 2>&1
  service ssh restart > /dev/null 2>&1
  service squid restart > /dev/null 2>&1
  service squid3 restart > /dev/null 2>&1
  sys_msg " \033[1;32m[OK]"
  msg -bar
  msg -ama "SQUID CONFIGURADO"
  fun_allowports
}
function fun_shadowsocks () {
  if [[ -e /etc/shadowsocks.json ]]; then
    msg -ama "REMOVENDO SHADOWSOCKS"
    if [[ $(ps x|grep ss-server|grep -v grep|awk '{print $1}') ]]; then
      for PID in $(ps x|grep ss-server|grep -v grep|awk '{print $1}'); do
        kill -9 $PID > /dev/null 2>&1
      done
      ss-server -c /etc/shadowsocks.json -d stop > /dev/null 2>&1
      killall ss-server > /dev/null 2>&1
    fi
    fun_bar "sleep 5s"
    msg -ama "SHADOWSOCKS REMOVIDO COM SUCESSO"
    rm /etc/shadowsocks.json
    return 0
  else
    msg -ama "INSTALANDO SHADOWSOCKS"
    local cript
    local s
    while :
    do
      msg -ama "Selecione uma Criptografia"
      msg -bar
      local encript=(aes-256-gcm aes-192-gcm aes-128-gcm aes-256-ctr aes-192-ctr aes-128-ctr aes-256-cfb aes-192-cfb aes-128-cfb camellia-128-cfb camellia-192-cfb camellia-256-cfb chacha20-ietf-poly1305 chacha20-ietf chacha20 rc4-md5)
      for ((s=0; s<${#encript[@]}; s++)); do
        sys_msg -ne "\033[1;32m [${s}] > " && sys_msg -azu "${encript[${s}]}"
      done
      msg -bar
      while :
      do
        msg -ne "Qual Criptografia? Escolha uma Opcao"
        sys_msg -ne ": "
        read -e -i 0 cript
        if [[ ${encript[$cript]} ]]; then
          break
        else
          msg -verm "Opcao Invalida"
          fun_up 1
        fi
      done
      local METHOD="${encript[$cript]}"
      if [[ ${METHOD} != "" ]]; then
        break
      else
        msg -verm "Opcao Invalida"
        fun_up 1
      fi
    done
    local SHADOWCONF="/etc/shadowsocks.json"
    msg -ama "Agora Escolha a Portas que Deseja No SHADOWSOCKS"
    select_port && local SHADOWPORT="${RETORNO}"
    sys_msg -ve "$(msg -ne "Porta") [${RETORNO}] - OK"
    msg -bar
    msg -ama "Digite a Senha Shadowsocks"
    pass_user && local PASS="${RETORNO}"
    msg -ama "Qual DNS voce deseja usar?"
    msg -bar
    sys_msg -ne "\033[1;32m [0] > " && msg -azu "Usar padroes do sistema"
    sys_msg -ne "\033[1;32m [1] > " && msg -azu "Cloudflare"
    sys_msg -ne "\033[1;32m [2] > " && msg -azu "Quad"
    sys_msg -ne "\033[1;32m [3] > " && msg -azu "FDN"
    sys_msg -ne "\033[1;32m [4] > " && msg -azu "DNS.WATCH"
    sys_msg -ne "\033[1;32m [5] > " && msg -azu "OpenDNS"
    sys_msg -ne "\033[1;32m [6] > " && msg -azu "Google DNS"
    sys_msg -ne "\033[1;32m [7] > " && msg -azu "Yandex Basic"
    sys_msg -ne "\033[1;32m [8] > " && msg -azu "AdGuard DNS"
    msg -bar
    fun_selectopt 6 && local SELEC="$RETORNO"
    case ${SELEC} in
      0) local LINE
      for LINE in $(grep -v '#' /etc/resolv.conf|grep 'nameserver'|grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'); do
        DNS="${LINE}"
      done
      [[ ! "${DNS}" ]] && DNS='8.8.8.8';;
      1) DNS='1.0.0.1';;
      2) DNS='1.1.1.1';;
      3) DNS='80.67.169.40';;
      4) DNS='84.200.69.80';;
      5) DNS='208.67.222.222';;
      6) DNS='8.8.8.8';;
      7) DNS='77.88.8.8';;
      8) DNS='176.103.130.130';;
    esac
    msg -ama "Instalando"
    msg -bar
    msg -ama "Atualizando Python"
    fun_bar 'apt-get install python-pip python-m2crypto -y'
    msg -ama "Adicionando Bibliotecas"
    fun_bar 'pip install shadowsocks'
    msg -ama "Instalando SS-Server"
    fun_bar 'apt-get install shadowsocks-libev -y'
    msg -ama "Configurando"
    sys_msg -ne '{\n"server":["' > ${SHADOWCONF}
    sys_msg -ne '[::0]","0.0.0.0"],\n' >> ${SHADOWCONF}
    sys_msg -ne '"mode":"tcp_and_udp",' >> ${SHADOWCONF}
    sys_msg -ne '\n"server_port":' >> ${SHADOWCONF}
    sys_msg -ne "${SHADOWPORT},\n" >> ${SHADOWCONF}
    sys_msg -ne '"local_port":1080,\n"password":"' >> ${SHADOWCONF}
    sys_msg -ne "${PASS}" >> ${SHADOWCONF}
    sys_msg -ne '",\n"timeout":600,\n"nameserver":"' >> ${SHADOWCONF}
    sys_msg -ne "${DNS}" >> ${SHADOWCONF}
    sys_msg -ne '",\n"method":"' >> ${SHADOWCONF}
    sys_msg -ne "${METHOD}" >> ${SHADOWCONF}
    sys_msg -ne '"\n}' >> ${SHADOWCONF}
    msg -bar
    msg -ama "INICIANDO SS-SERVER"
    screen -dmS SHADOWSOKS ss-server -c /etc/shadowsocks.json > /dev/null 2>&1
    fun_allowports
    [[ $(ps x |grep ss-server|grep -v grep) ]] && msg -verd "Iniciado" || msg -verm "erro"
  fi
}
function fun_sslstunnel () {
  local SSLDIR="/etc/stunnel"
  local SSLCONF="${SSLDIR}/stunnel.conf"
  local ENABLEARQ="/etc/default/stunnel4"
  if [[ -e ${SSLCONF} ]]; then
    msg -azu "SSL Instalado, Confirma Remocao?"
    fun_yesno && local RESP="$RETORNO"
    if [[ ${RESP} = @(s|S|y|Y) ]]; then
      msg -azu "Removendo SSL Stunnel"
      msg -bar
      killall stunnel4 > /dev/null 2>&1
      fun_bar "apt-get purge stunnel4 -y"
      [[ -d ${SSLDIR} ]] && rm -rf ${SSLDIR}
      msg -bar
      msg -ama "Removido Com Sucesso"
    else
      msg -bar
      msg -ama "Operacao Cancelada"
    fi
  else
    msg -bar
    msg -azu "INSTALADOR SSL"
    msg -bar
    sys_msg -ne "\033[1;32m [1] > " && msg -azu "INSTALACAO PERSONALIZADA (PADRAO)"
    sys_msg -ne "\033[1;32m [2] > " && msg -azu "INSTALACAO AUTOMATICA SSL+PROXY 443+80"
    sys_msg -ne "\033[1;32m [3] > " && msg -azu "INSTALACAO AUTOMATICA SSL+SSH 443+22"
    sys_msg -ne "\033[1;32m [0] > " && msg -bra "VOLTAR AO MENU"
    msg -bar
    fun_selectopt 3 && local SELECT="$RETORNO"
    case ${SELECT} in
      0) return 1;;
      2) local SERVERPORT="80" && local LISTENPORT="443";;
      3) local SERVERPORT="22" && local LISTENPORT="443";;
      1) msg -azu "Escolhendo Portas Para SSL Stunnel"
      msg -bar
      msg -ama "Selecione Uma Porta De Redirecionamento Interna"
      msg -ama "Ou seja, uma Porta no Seu Servidor Para o SSL"
      msg -bar
      select_port_invertido && local SERVERPORT="$RETORNO"
      msg -ama "Agora Precisamos Saber Qual Porta o SSL, Vai Escutar"
      select_port && local LISTENPORT="$RETORNO";;
    esac
    msg -ama "Instalando SSL"
    msg -bar
    fun_bar "apt-get install stunnel4 -y"
    [[ ! -d ${SSLDIR} ]] && mkdir ${SSLDIR}
    sys_msg "cert = /etc/stunnel/stunnel.pem\nclient = no\nsocket = a:SO_REUSEADDR=1\nsocket = l:TCP_NODELAY=1\nsocket = r:TCP_NODELAY=1\n\n[stunnel]\nconnect = 127.0.0.1:${SERVERPORT}\naccept = ${LISTENPORT}" > ${SSLCONF}
    openssl genrsa -out key.pem 2048 > /dev/null 2>&1
    (sys_msg br; sys_msg br; sys_msg uss; sys_msg speed; sys_msg adm; sys_msg ultimate; sys_msg @admultimate)|openssl req -new -x509 -key key.pem -out cert.pem -days 1095 > /dev/null 2>&1
    cat key.pem cert.pem >> ${SSLDIR}/stunnel.pem
    sed -i 's/ENABLED=0/ENABLED=1/g' ${ENABLEARQ}
    service stunnel4 restart > /dev/null 2>&1
    fun_allowports
    msg -bar
    msg -ama "Instalado Com Sucesso"
  fi
}
function fun_getunel_proxy () {
  local PROXY_LINK="https://www.dropbox.com/s/fwh9cewg0gmxebe/Gettunel.py?dl=0"
  local PROXY_ARQ="/bin/Gettunel.py"
  local PROXY_PASS="${SCPdatabase}/pwd.pwd"
  local PIDSOCKS=$(ps x|grep -w "Gettunel.py"|grep -v "grep"|awk -F "pts" '{print $1}'|awk '{print $1}')
  msg -bar 
  if [[ -z ${PIDSOCKS} ]]; then
    if [[ ! -e ${PROXY_ARQ} ]]; then
      wget -O ${PROXY_ARQ} ${PROXY_LINK} &>/dev/null
      chmod +x ${PROXY_ARQ}
    fi
    msg -ama "Ativador Proxy Gettunel"
    msg -ama "Selecione a Porta que deseja rodar o proxy"
    select_port && local PORT="$RETORNO"
    sys_msg "$(msg -ama "Porta"): ${PORT} ok"
    msg -ama "Agora Digite a Senha que deseja rodar no proxy"
    pass_user && local PASS="$RETORNO"
    sys_msg "$(msg -ama "Senha Selecionada"): ${PASS}"
    sys_msg "master=${PASS}" > ${PROXY_PASS}
    local PTS SVC
    while read SVC PTS; do
      sys_msg "127.0.0.1:${PTS}=${SVC}" >> ${PROXY_PASS}
    done <<< "$(fun_listports)"
    screen -dmS Gettunel python3 ${PROXY_ARQ} -b "0.0.0.0:${PORT}" -p "${PROXY_PASS}"
    msg -verd "Proxy Gettunel Iniciado Com Sucesso"
  else
    local PID
    msg -ama "Parando Proxy Gettunel"
    for PID in ${PIDSOCKS}; do
      kill -9 ${PID}
    done
    msg -verd "Proxy Parado Com Sucesso"
  fi
}
function fun_python_proxy () {
  local PROXY_LINK="https://www.dropbox.com/s/a3rv7fcr9yy1ppg/PyProxy.py?dl=0"
  local PROXY_ARQ="/bin/PyProxy.py"
  local PIDSOCKS=$(ps x|grep -w "PyProxy.py"|grep -v "grep"|awk -F "pts" '{print $1}'|awk '{print $1}')
  msg -bar 
  if [[ -z ${PIDSOCKS} ]]; then
    if [[ ! -e ${PROXY_ARQ} ]]; then
      wget -O ${PROXY_ARQ} ${PROXY_LINK} &>/dev/null
      chmod +x ${PROXY_ARQ}
    fi
    msg -ama "Ativador Proxy Socks"
    msg -ama "Selecione a Porta que deseja rodar o proxy"
    select_port && local PORT="$RETORNO"
    sys_msg "$(msg -ama "Porta"): ${PORT} ok"
    screen -dmS PyProxy python3 ${PROXY_ARQ} ${PORT}
    msg -verd "Proxy Iniciado Com Sucesso"
  else
    local PID
    msg -ama "Parando Proxy Socks"
    for PID in ${PIDSOCKS}; do
      kill -9 ${PID}
    done
    msg -verd "Proxy Parado Com Sucesso"
  fi
}
# Verificacão de Usuarios e Bloqueio de Conexao
function fun_killssh () {
  local TTY=$(tty | sed 's/\/dev\///g')
  local PID 
  local USER="$@"
  for PID in $(ps U "${USER}" | grep -vw "${TTY}" | awk '{print $1}'); do
    [[ ! -z ${PID} ]] && kill -9 "${PID}" > /dev/null 2>&1
  done
  for PID in $(dropbear_pids|grep -w "${USER}"); do
    [[ ! -z ${PID} ]] && kill -9 "${PID}" > /dev/null 2>&1
  done

  for PID in $(openvpn_pids|grep -w "${USER}"); do
      [[ ! -z ${PID} ]] && kill -9 "${PID}" > /dev/null 2>&1
  done
}
function fun_scanuser () {
  local USER="$1"
  local _ SENHA DATA ONLINE PID LIMIT BLOQUEIO
  PID="0"
  [[ $(dpkg --get-selections|grep -w "openssh"|head -1) ]] && let PID=PID+$(ps aux|grep -v grep|grep sshd|grep -w "${USER}"|grep -v root|wc -l)
  [[ $(dpkg --get-selections|grep -w "dropbear"|head -1) ]] && let PID=PID+$(dropbear_pids|grep -w "${USER}"|wc -l)
  [[ $(dpkg --get-selections|grep -w "openvpn"|head -1) ]] && let PID=PID+$(openvpn_pids|grep -w "${USER}"|wc -l)
  read USER SENHA DATA LIMIT BLOQUEIO ONLINE <<< "$(data_base -show ${USER})"
  [[ -z ${LIMIT} ]] && LIMIT="999"
  [[ -z ${ONLINE} ]] && ONLINE="0"
  [[ "${PID}" -gt "0" ]] && let ONLINE=(ONLINE+10)
  if [[ "${PID}" -gt "${LIMIT}" ]]; then
    fun_killssh ${USER}
  fi
  sys_msg "${PID}" >> "${SCPonlines}"
  data_base -add "${USER}" "${SENHA}" "${DATA}" "${LIMIT}" "${BLOQUEIO}" "${ONLINE}"
}
function fun_verify () {
  local USER
  while :
  do
    for USER in `fun_listuser`; do
      sys_msg -e "SCAN ${USER}"
      fun_scanuser "${USER}" &
    done
  sleep 10s
  [[ -e ${SCPonlines} ]] && rm ${SCPonlines}
  done
}
function verify_start () {
  local PID=$(ps aux|grep "ADM_VERIFY"|grep adm_codes.sh|awk '{print $2}')
  if [[ ! -z ${PID} ]]; then
    local PIDS
    for PIDS in ${PID}; do
      kill -9 ${PIDS}
    done
    msg -bar
    msg -ama "VERIFICOES E LIMITER PARADO COM SUCESSO"
    [[ -e ${SCPonlines} ]] && rm ${SCPonlines}
  else
    msg -bar
    screen -dmS ADM_VERIFY ${SCPusr}/adm_codes.sh verify
    msg -ama "VERIFICOES E LIMITER INICIADO COM SUCESSO"
  fi
}
fun_global_var
if [[ $1 = "verify" ]];then
  fun_verify
else
  while :
    do
    fun_main
    if [[ $? = "9" ]]; then
      break
    else
      msg -bar
      msg -ama "Enter Para Continuar"
      msg -bar
      read
    fi
  done
fi
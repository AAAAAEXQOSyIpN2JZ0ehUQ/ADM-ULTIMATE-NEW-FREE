#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

fun_bar () {
comando[0]="$1"
comando[1]="$2"
 (
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} -y > /dev/null 2>&1
${comando[1]} -y > /dev/null 2>&1
touch $HOME/fim
 ) > /dev/null 2>&1 &
echo -ne "\033[1;33m ["
while true; do
   for((i=0; i<10; i++)); do
   echo -ne "\033[1;31m##"
   sleep 0.1s
   done
   [[ -e $HOME/fim ]] && rm $HOME/fim && break
   echo -e "\033[1;33m]"
   sleep 1s
   tput cuu1
   tput dl1
   echo -ne "\033[1;33m ["
done
echo -e "\033[1;33m]\033[1;31m -\033[1;32m 100%\033[1;37m"
}

fun_scan () {
clear
clear
msg -bar
msg -ama "$(fun_trans "EXTRACTOR HOST & SSL ")"
msg -bar
echo -ne "\033[1;37mDigite o dominio: "; read HOST
echo -e "\033[1;32m"
tput cuu1 && tput dl1
tput cuu1 && tput dl1
bash_scan () {
list=`wget -O - $1 -q | grep -i "href=['|\"]" | sed "s/^.*href=['|\"]//" | awk -F"[\"|']" '{print $1}' | sort -u`
for url in $list
do
	if [ ${#url} -ge 4 -a ${url:0:4} = "http" ];then
		newlist="$newlist\n$url"
	elif [ -n $url -a ${url:0:1} = "/" ];then
		newlist="$newlist\n$1$url"
	else
		newlist="$newlist\n$1"/"$url"
	fi
done
echo -e "\e[1;32m $newlist\e[0m " | sort -u | sort
echo -e "$newlist " | sort -u | sort > lista-host.txt
echo
}
bash_scan $HOST
}

fun_status () {
# status host
clear
clear
msg -bar
msg -ama "$(fun_trans "SHOWING HOSTS STATUS ")"
msg -bar
echo -e "\e[1;32m"
while read LINE; do
  curl -o /dev/null --silent --head --write-out '%{http_code}' "$LINE"
  echo ' '$LINE
done < lista-host.txt
echo
}

fun_payloads () {
# bash payloads
clear
clear
msg -bar
msg -ama "$(fun_trans "GENERATE PAYLOADT")"
msg -bar
echo -ne "\033[1;37mDigite o dominio: "; read host
tput cuu1 && tput dl1
echo -e "\033[1;33m"
echo "CONNECT free.facebook.com;$host;internet.org;c.whatsapp.net@[host_port] [protocol][crlf][delay_split]GET http://free.facebook.com;$host;internet.org;c.whatsapp.net/ HTTP/1.1[crlf]Host: free.facebook.com;$host;internet.org;c.whatsapp.net[crlf]X-Online-Host: free.facebook.com;$host;internet.org;c.whatsapp.net[crlf]X-Forward-Host: free.facebook.com;$host;internet.org;c.whatsapp.net[crlf]X-Forwarded-For: free.facebook.com;$host;internet.org;c.whatsapp.net[crlf]Connection: Keep-Alive[crlf][crlf]"
echo ""
echo "GET http://$host/ HTTP/1.1[crlf]Host: $host[crlf]User-Agent: Yes[crlf]Accept-Encoding: gzip,deflate[crlf]Accept-Charset: ISO-8859-1,utf-8;q=0.7,;q=0.7[crlf]Connection: Basic[crlf]Referer: $host[crlf]Cookie: $host [crlf]Proxy-Connection: Keep-Alive[crlf][crlf][netData][crlf][crlf][crlf]"
echo ""
echo GET http://$host/ HTTP/1.1[crlf]Host: $host[crlf]X-Online-Host: $host[crlf]X-Forward-Host: $host[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][crlf][delay_split]CONNECT [host_port] [protocol][crlf][crlf]
echo ""
echo GET http://$host/ HTTP/1.1[crlf]Host: $host[crlf]X-Online-Host: $host[crlf]X-Forward-Host: $host[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][crlf]
echo ""
echo CONNECT [host_port] [protocol][crlf]Host: $host[crlf]X-Online-Host: $host[crlf]X-Forward-Host: $host[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][crlf]
echo ""
echo GET http://$host/ HTTP/1.1[crlf]Host: $host[crlf]X-Online-Host: $host[crlf]X-Forward-Host: $host[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][crlf][delay_split]CONNECT [host_port] [protocol][crlf][crlf]
echo ""
echo CONNECT $host@[host_port] [protocol][crlf][delay_split]HEAD http://$host/ HTTP/1.1[crlf]Host: $host[crlf]X-Online-Host: $host[crlf]X-Forward-Host: $host[crlf]X-Forwarded-For: $host[crlf]Connection: Keep-Alive[crlf][crlf]
echo ""
echo "GET http://free.facebook.com;$host;internet.org;c.whatsapp.net/ HTTP/1.1[crlf]Host: free.facebook.com;$host;internet.org;c.whatsapp.net[crlf]X-Online-Host: free.facebook.com;$host;internet.org;c.whatsapp.net[crlf]X-Forward-Host: free.facebook.com;$host;internet.org;c.whatsapp.net[crlf]X-Forwarded-For: free.facebook.com;$host;internet.org;c.whatsapp.net[crlf]Connection: Keep-Alive[crlf][crlf"
echo ""
echo CONNECT [host_port]@$host [protocol][crlf][delay_split]GET http://$host/ HTTP/1.1[crlf]Host: $host[crlf]X-Online-Host: $host[crlf]X-Forward-Host: $host[crlf]X-Forwarded-For: $host[crlf]Connection: Keep-Alive[crlf][crlf]
echo ""
echo GET http://$host/ HTTP/1.1[crlf][crlf]Host: $host[crlf]Connection: Keep-Alive[crlf]Content-Type: text[crlf]Cache-Control: no-cache[crlf]Connection: close[crlf]Content-Lenght: 20624[crlf][crlf][realData][crlf][crlf]
echo ""
echo [method] $host:443 HTTP/1.1[lf]CONNECT [host_port] [protocol][lf][lf]GET http://$host/ HTTP/1.1\nHost: $host\nConnection: close\nConnection: close\nUser-Agent:[ua][lf]Proxy-Connection: Keep-Alive[lf][host][crlf][lf][delay_split]CONNECT [host_port] [protocol][lf][lf]CONNECT [host_port] [protocol][crlf][realData][crlf][crlf] 
echo ""
echo [immutable][method][host_port][delay_split]GET http://$host HTTP/1.1[netData][crlf]HTTP:mip:80[crlf]X-GreenArrow-MtaID: smtp1-1[crlf]CONNECT http://$host/ HTTP/1.1[crlf]CONNECT http://$host/ HTTP/1.0[crlf][split]CONNECT http://$host/ HTTP/1.1[crlf]CONNECT http://$host/ HTTP/1.1[crlf][crlf]
echo ""
echo "[method][host_port]?[split]GET http://$host:80/[crlf][crlf]get [host_port]?[split]OPTIONS http://$host/[crlf]Connection: Keep-Alive[crlf]User-Agent: Mozilla/5.0 (Android; Mobile; rv:35.0) Gecko/35.0 Firefox/35.0[crlf]CONNECT [host_port] [crlf]GET [host_port]?[split]get http://$host/[crlf][crlf][method] mip:80[split]GET $host/[crlf][crlf]: Cache-Control:no-store,no-cache,must-revalidate,post-check=0,pre-check=0[crlf]Connection:close[crlf]CONNECT [host_port]?[split]GET http://$host:/[crlf][crlf]POST [host_port]?[split]GET $host:/[crlf]Content-Length: 999999999\r\n\r\n "
echo ""
echo GET http://$host/ HTTP/1.1[lf]Host: $host User-Agent: Yes Connection: close Proxy-Connection: Keep-Alive [crlf][crlf]CONNECT [host_port][protocol][crlf][crlf][immutable] 
echo ""
echo "GET http://$host/ HTTP/1.1[crlf]Host: $host[crlf] Access-Control-Allow-Credentials: true, true[lf] Access-Control-Allow-Headers: X-Requested-With,Content-Type, X-Requested-With,Content-Type[lf] Access-Control-Allow-Methods: GET,PUT,OPTIONS,POST,DELETE, GET,PUT,OPTIONS,POST,DELETE[lf] Age: 8, 8[lf] Cache-Control: max-age=86400[lf] public[lf] Connection: keep-alive[lf] Content-Type: text/html; charset=UTF-8[crlf]Content-Length: 9999999999999[crlf]UseDNS: Yes[crlf]Vary: Accept-Encoding[crlf][raw][crlf][crlf][crlf]"
echo ""
echo GET http://$host/ HTTP/1.1 Host: $host/ User-Agent: Yes Connection: close Proxy-Connection: update [crlf][crlf][netData][crlf][crlf][crlf] 
echo ""
echo "GET http://$host/ HTTP/1.1[crlf]Host: $host[crlf]Content-Type: text/html; charset=iso-8859-1[crlf]Connection: close[crlf][crlf][crlf]User-Agent: [ua][crlf][crlf]Referer: $host[crlf]Cookie: $host[crlf]Proxy-Connection: Keep-Alive [crlf][crlf]CONNECT [host_port] [protocol][crlf][crlf][crlf]"
echo ""
echo "GET http://$host/ HTTP/1.1 Host: $host Upgrade-Insecure-Requests: 1 User-Agent: Mozilla/5.0 (Linux; Android 5.1; LG-X220 Build/LMY47I) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.83 Mobile Safari/537.36 Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8 Referer: http://$host Accept-Encoding: gzip, deflate, sdch Accept-Language: pt-BR,pt;q=0.8,en-US;q=0.6,en;q=0.4 Cookie: _ga=GA1.2.2045323091.1494102805; _gid=GA1.2.1482137697.1494102805; tfp=80bcf53934df3482b37b54c954bd53ab; tpctmp=1494102806975; pnahc=0; _parsely_visitor={%22id%22:%22719d5f49-e168-4c56-b7c7-afdce6daef18%22%2C%22session_count%22:1%2C%22last_session_ts%22:1494102810109}; sc_is_visitor_unique=rx10046506.1494105143.4F070B22E5E94FC564C94CB6DE2D8F78.1.1.1.1.1.1.1.1.1 Connection: close Proxy-Connection: Keep-Alive [crlf][netData][crlf][crlf][crlf]" 
echo ""
echo "GET http://$host[crlf] HTTP/1.1[crlf]Host: $host[crlf]User-Agent: [ua][crlf]Connection: close [crlf] Referer:http://$host[crlf] Content-Type: text/html; charset=iso-8859-1[crlf]Content-Length:0[crlf]Accept: text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5[crlf][raw][crlf][crlf]" 
echo ""
echo "GET https://$host/ HTTP/1.1 Host: $host[crlf]User-Agent: Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13 Accept-Language: en-us,en;q=0.5 Accept-Encoding: gzip,deflate Accept-Charset: ISO-8859-1,utf-8;q=0.7,;q=0.7 Keep-Alive: 115 Connection: keep-alive Referer: $host Cookie: $host Proxy-Connection: Keep-Alive [crlf][crlf][netData][crlf] [crlf][crlf]"
echo ""
echo GET [host_port]@$host HTTP/1.1[crlf]X-Real-IP:mip[crlf]X-Forwarded-For:http://$host/ http://$host/[crlf]X-Forwarded-Port:$host[crlf]X-Forwarded-Proto:http[crlf]Connection:Keep-Alive[crlf][crlf][instant_split]CONNECT [ssh]HTTP/1.0[crlf][crlf] 
echo ""
echo GET http://$host/[host_port][method]HTTP/1.1[crlf]$host[lf]HEAD http://$host[protocol][crlf]Host: $host [crlf] 
echo ""
echo CONNECT http://$host/ HTTP/1.1[crlf]Host: $host[crlf]X-Online-Host: $host[crlf]Proxy-Connection: keep-alive[crlf]Connection: keep-alive[crlf][crlf][method] [host_port] [protocol][crlf]Proxy-Authorization: [auth][crlf]Proxy-Connection: keep-alive[crlf]Connection: keep-alive[crlf][crlf]
echo ""
echo "[method] [host_port] [protocol][crlf]Proxy-Connection: keep-alive[crlf]Connection: keep-alive[crlf][crlf][split_delay]MOVE http://$host/ HTTP/1.1[crlf]Host: $host[crlf]X-Online-Host: $host[crlf]Proxy-Connection: keep-alive[crlf]Connection: keep-alive[crlf][crlf]"
echo ""
echo [method] [host_port] [protocol][crlf]Proxy-Authorization: [auth][crlf]Proxy-Connection: keep-alive[crlf]Connection: keep-alive[crlf][crlf]
echo ""
echo "MOVE http://$host/ HTTP/1.0[crlf]Host: $host[crlf]X-Online-Host: $host[crlf]Proxy-Connection: keep-alive[crlf]Connection: keep-alive[crlf][crlf][method] [host_port] [protocol][crlf]Proxy-Authorization: [auth][crlf]Proxy-Connection: keep-alive[crlf]Connection: keep-alive[crlf][crlf]"
echo ""
echo "GET /datos-por-demanda/ HTTP/1.1 9999999999\r\n\r\nConnection: Keep-Alive[auth]\r\n\r\nHost: $host:80\r\n\r\nConnection: Keep-Alive[auth]Content-Length: 999999999\r\n\r\nHost: $host:80[crlf][crlf]Accept-Encoding: gzip[crlf][crlf]Content-Length: 999999999[crlf][crlf]"
echo ""
echo "GET http://$host/ HTTP/1.1[crlf]Host: $host[crlf]User-Agent: [ua][lf][host]@$host [protocol][lf][lf]"
echo ""
echo "CONNECT [host_port]HTTP/1.0[host][lf][cr]GET $host HTTP/1.1
Connection: Close keep-alive
Content-Length: 9999999999
[crlf][crlf][netData][crlf] [host_port]GET http://$host HTTP/1.0[lf]"
echo ""
echo "GET http://$host[crlf] HTTP/1.1[crlf]Host: $host[crlf]User-Agent: [ua][crlf]Connection: close [crlf] kkReferer:http://$host[crlf] Content-Type: text/html; charset=iso-8859-1[crlf]Content-Length:0[crlf]Accept: text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5[crlf][raw][crlf] [crlf]"
echo ""
echo "CONNECT [host_port][protocol][crlf][delay_split]GET http://$host/ HTTP/1.1[crlf]Host: $host[crlf]Connection: Keep-Alive[crlf]x-amz-id-2: +bnliBcDYxWL++PEO8kRY18ng+fHsuiIINYg/e8YrGUJLYLK3RJ6ko7OUiYCMNIiWMzHPmTYUrE=[crlf]User-Agent: [ua][crlf][crlf][split][raw]"
echo ""
echo CONNECT [host_port]@$host [protocol][crlf]Host: $host[crlf]X-Online-Host: $host[crlf]X-Forward-Host: $host[crlf]X-Forwarded-For: $host[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf]CONNECT [host_port] [protocol][crlf][crlf]
echo ""
}

clear
clear
msg -bar
msg -ama "$(fun_trans "STATUS DE HOST") [Extractor]"
msg -bar
echo -ne "$(msg -verd "[0]") $(msg -verm2 ">") " && msg -bra "$(fun_trans "VOLTAR")"
echo -ne "$(msg -verd "[1]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "EXTRACTOR HOST & SSL")"
echo -ne "$(msg -verd "[2]") $(msg -verm2 ">") " && msg -azu "PAYLOAD $(fun_trans "SHOW WEB STATUS")"
echo -ne "$(msg -verd "[3]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "Editar lista-host.txt") \033[1;31m(comand nano)"
echo -ne "$(msg -verd "[4]") $(msg -verm2 ">") " && msg -azu "$(fun_trans "GENERATE PAYLOAD")"
msg -bar
# FIM
selection=$(selection_fun 4)
case ${selection} in
1)fun_scan;;
2)fun_status;;
3)
   nano /root/lista-host.txt
   return 0;;
4)fun_payloads;;
0)exit;;
esac
msg -bar
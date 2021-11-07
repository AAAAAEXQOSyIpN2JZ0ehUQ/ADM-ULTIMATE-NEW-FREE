#!/bin/bash
gerar_pays () {
echo 'GET http://mhost/ HTTP/1.1[crlf][raw][crlf] [crlf][crlf]
CONNECT mhost@[host_port] HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forwarded-For: mhost[crlf]User-Agent: [ua][crlf][crlf]
CONNECT mhost@[host_port] HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forwarded-For: mhost[crlf]User-Agent: [ua][crlf] [crlf][crlf]
CONNECT [host_port]@mhost HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forwarded-For: mhost[crlf]User-Agent: [ua][crlf][crlf]
CONNECT [host_port]@mhost HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forwarded-For: mhost[crlf]User-Agent: [ua][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forwarded-For: mhost[crlf]User-Agent: [ua][crlf][crlf]CONNECT [host_port]@mhost [protocol][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forwarded-For: mhost[crlf]User-Agent: [ua][crlf][crlf]CONNECT [host_port]@mhost [protocol][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forwarded-For: mhost[crlf]User-Agent: [ua][crlf][crlf]CONNECT mhost@[host_port] [protocol][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forwarded-For: mhost[crlf]User-Agent: [ua][crlf][crlf]CONNECT mhost@[host_port] [protocol][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]User-Agent: [ua][crlf][crlf]CONNECT mhost@[host_port] [protocol][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]User-Agent: [ua][crlf][crlf]CONNECT mhost@[host_port] [protocol][crlf] [crlf]
CONNECT mhost@[host_port] HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]User-Agent: [ua][crlf][crlf]
CONNECT mhost@[host_port] HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]User-Agent: [ua][crlf] [crlf]
CONNECT mhost@[host_port] HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]Referer: mhost[crlf][crlf]
CONNECT mhost@[host_port] HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]Referer: mhost[crlf] [crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf][crlf]CONNECT mhost@[host_port] [protocol][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf][crlf]CONNECT mhost@[host_port] [protocol][crlf] [crlf][crlf]
GET mhost@[host_port] [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf][crlf]
GET mhost@[host_port] [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf] [crlf][crlf]
GET [host_port]@mhost [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf][crlf]
GET [host_port]@mhost [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf] [crlf][crlf]
CONNECT [host_port]@mhost [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]Connection: Keep-Alive[crlf][crlf]
CONNECT [host_port]@mhost [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]Connection: Keep-Alive[crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]Connection: Keep-Alive[crlf][crlf][raw][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]Connection: Keep-Alive[crlf][crlf][raw][crlf] [crlf][crlf]
CONNECT [host_port] HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][crlf]
CONNECT [host_port] HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]User-Agent: [ua][crlf][crlf][split][raw][crlf][crlf]CONNECT mhost:443 HTTP/1.1[crlf][raw][crlf][crlf]GET http://mhost/ HTTP/1.0[crlf]Host: mhost[crlf]Proxy-Authorization: basic: mhost[crlf]User-Agent: [ua][crlf]Connection: close[crlf]Proxy-Connection: Keep-Alive [crlf]Host: [host][crlf][crlf][split][raw][crlf][crlf]GET http://mhost/ HTTP/1.0[crlf]Host: mhost/[crlf][crlf]CONNECT [host_port] HTTP/1.0[crlf][crlf][realData][crlf][crlf]
[method] mhost:443 HTTP/1.1[crlf][raw][crlf][crlf]GET http://mhost/ HTTP/1.1\nHost: mhost\nConnection: close\nConnection: close\nUser-Agent:[ua][crlf]Proxy-Connection: Keep-Alive[crlf]Host: [host][crlf][crlf][delay_split][raw][crlf][crlf][raw][crlf][realData][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]User-Agent: KDDI[crlf]Host: [host][crlf][crlf][raw][raw][crlf][raw][crlf][raw][crlf][crlf]DELETE http://mhost/ HTTP/1.1[crlf]Host: m.opera.com[crlf]Proxy-Authorization: basic: *[crlf]User-Agent: KDDI[crlf]Connection: close[crlf]Proxy-Connection: Direct[crlf]Host: [host][crlf][crlf][raw][raw][crlf][crlf][raw][method] http://mhost[port] HTTP/1.1[crlf]Host: [host][crlf][crlf]CONNECT [host] [protocol][crlf][crlf][CONNECT [host] [protocol][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][crlf][netData][crlf][instant_split]MOVE http://mhost[delay_split][crlf][crlf][netData][crlf][instant_split]MOVE http://mhost[delay_split][crlf][crlf][netData][crlf][instant_split]MOVE http://mhost[delay_split][crlf][crlf]X-Online-Host: mhost[crlf]Packet Length: Authorization[crlf]Packet Content: Authorization[crlf]Transfer-Encoding: chunked[crlf]Referer: mhost[crlf][crlf]
[crlf][crlf]CONNECT [host_port]@mhost/ [protocol][crlf][delay_split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]User-Agent: [ua][crlf]CONNECT [host]@mhost/ [protocol][crlf][crlf]
[method] [host_port] [protocol] [delay_split]GET http://mhost/ HTTP/1.1[netData][crlf]GET mip:80[crlf]X-GreenArrow-MtaID: smtp1-1[crlf]CONNECT http://mhost/ HTTP/1.1[crlf]CONNECT http://mhost/ HTTP/1.0[crlf][split]CONNECT http://mhost/ HTTP/1.1[crlf]CONNECT http://mhost/ HTTP/1.1[crlf][crlf][method] [host_port] [protocol]?[split]GET http://mhost:8080/[crlf][crlf]GET [host_port] [protocol]?[split]OPTIONS http://mhost/[crlf]Connection: Keep-Alive[crlf]User-Agent: Mozilla/5.0 (Android; Mobile; rv:35.0) Gecko/35.0 Firefox/35.0[crlf]CONNECT [host_port] [protocol] [crlf]GET [host_port] [protocol]?[split]GET http://mhost/[crlf][crlf][method] mip:80[split]GET mhost/[crlf][crlf]: Cache-Control:no-store,no-cache,must-revalidate,post-check=0,pre-check=0[crlf]Connection:close[crlf]CONNECT [host_port] [protocol]?[split]GET http://mhost:/[crlf][crlf]POST [host_port] [protocol]?[split]GET[crlf]mhost:/[crlf]Content-Length: 999999999[crlf][crlf]
GET [host_port] [protocol][crlf][delay_split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]Referer: mhost[crlf]X-Online-Host: mhost[crlf]X-Forward-Host: mhost[crlf]X-Forwarded-For: mhost[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][raw][crlf][crlf]
CONNECT [host_port] [protocol]GET http://mhost/ [protocol][crlf][split]GET mhost/ HTTP/1.1[crlf][crlf]
CONNECT [host_port] [protocol]GET http://mhost/ [protocol][crlf][split]GET http://mhost/ HTTP/1.1[crlf]Host: navegue.vivo.ddivulga.com/pacote[crlf][crlf]CONNECT [host_port] [protocol]GET http://mhost/ [protocol][crlf][split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][crlf]CONNECT [host_port] [protocol]GET http://mhost/ [protocol][crlf][split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][crlf]CONNECT [host_port] [protocol]GET http://mhost/ [protocol][crlf][split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][crlf]CONNECT [host_port] [protocol]GET http://mhost/ [protocol][crlf][split]CONNECT [host_port]@mhost/ [protocol][crlf]Host: mhost/[crlf]GET mhost/ HTTP/1.1[crlf]HEAD mhost/ HTTP/1.1[crlf]TRACE mhost/ HTTP/1.1[crlf]OPTIONS mhost/ HTTP/1.1[crlf]PATCH mhost/ HTTP/1.1[crlf]PROPATCH mhost/ HTTP/1.1[crlf]DELETE mhost/ HTTP/1.1[crlf]PUT mhost/ HTTP/1.1[crlf]Host: mhost/[crlf]Host: mhost/[crlf]X-Forward-Host: mhost[crlf]X-Forwarded-For: mhost[crlf]X-Forwarded-For: mhost[protocol][crlf][crlf]
[raw][split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost/[crlf]X-Forward-Host: mhost/[crlf]Connection: Keep-Alive[crlf]Connection: Close[crlf]User-Agent: [ua][crlf][crlf]
[raw][split]GET mhost/ HTTP/1.1[crlf] [crlf][crlf]
CONNECT [host_port]@mhost/ [protocol][crlf][instant_split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]GET mhost/[crlf]Connection: close Keep-Alive[crlf]User-Agent: [ua][crlf][crlf][raw][crlf][crlf]
[raw][split]GET mhost/ HTTP/1.1[crlf][crlf]
GET [host_port] [protocol][instant_split]GET http://mhost/ HTTP/1.1[crlf][crlf]
GET [host_port] [protocol][crlf][delay_split]CONNECT http://mhost/ HTTP/1.1[crlf][crlf]
CONNECT [host_port] [protocol] [instant_split]GET http://mhost/ HTTP/1.1[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][crlf][instant_split]GET http://mhost/ HTTP/1.1[crlf]User-Agent: [ua][crlf][crlf]
GET http://mhost/ HTTP/2.0[auth][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forward-Host: mhost[crlf]X-Forwarded-For: mhost[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf]CONNECT [host_port] [protocol] [auth][crlf][crlf][delay_split][raw][crlf]JAZZ http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forward-Host: mhost[crlf]X-Forwarded-For: mhost[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][raw][crlf][crlf][delay_split]CONNECT [host_port] [protocol] [method][crlf] [crlf][crlf]
CONNECT [host_port] [protocol][crlf]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][crlf]X-Online-Host: mhost[crlf][crlf]X-Forward-Host: mhost[crlf]User-Agent: Mozilla/5.0 (X11; U; Linux x86_64; en-gb) AppleWebKit/534.35 (KHTML, like Gecko) Chrome/11.0.696.65 Safari/534.35 Puffin/2.9174AP[crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost/ [crlf]User-Agent: Yes[crlf]Connection: close[crlf]Proxy-Connection: Keep-Alive[crlf][crlf][raw][crlf][crlf]
GET [host_port] [protocol][crlf][split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][raw][crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf]Connection: close[crlf]Proxy-connection: Keep-Alive[crlf]Proxy-Authorization: Basic[crlf]UseDNS: Yes[crlf]Cache-Control: no-cache[crlf][raw][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf] Access-Control-Allow-Credentials: true, true[crlf] Access-Control-Allow-Headers: X-Requested-With,Content-Type, X-Requested-With,Content-Type[crlf]  Access-Control-Allow-Methods: GET,PUT,OPTIONS,POST,DELETE, GET,PUT,OPTIONS,POST,DELETE[crlf]  Age: 8, 8[crlf] Cache-Control: max-age=86400[crlf] public[crlf] Connection: keep-alive[crlf] Content-Type: text/html; charset=UTF-8[crlf]Content-Length: 9999999999999[crlf]UseDNS: Yes[crlf]Vary: Accept-Encoding[crlf][raw][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf] Access-Control-Allow-Credentials: true, true[crlf] Access-Control-Allow-Headers: X-Requested-With,Content-Type, X-Requested-With,Content-Type[crlf]  Access-Control-Allow-Methods: GET,PUT,OPTIONS,POST,DELETE, GET,PUT,OPTIONS,POST,DELETE[crlf]  Age: 8, 8[crlf] Cache-Control: max-age=86400[crlf] public[crlf] Connection: keep-alive[crlf] Content-Type: text/html; charset=UTF-8[crlf]Content-Length: 9999999999999[crlf]Vary: Accept-Encoding[crlf][raw][crlf] [crlf][crlf]
[netData][split][raw][crlf]Host: mhost[crlf]Connection: Keep-Alive[crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost/[crlf]User-Agent: Yes[crlf]Connection: close[crlf]Proxy-Connection: update[crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]host: http://mhost/[crlf]Connection: close update[crlf]User-Agent: [ua][crlf][crlf][raw][crlf][crlf] [crlf][crlf]
[raw][crlf][split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][raw][crlf][crlf]User-Agent: [ua][crlf]Connection: Close[crlf]Proxy-connection: Close[crlf]Proxy-Authorization: Basic[crlf]Cache-Control: no-cache[crlf]Connection: Keep-Alive[crlf][raw][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]Content-Type: text/html; charset=iso-8859-1[crlf]Connection: close[crlf][crlf]User-Agent: [ua][crlf][crlf]Referer: mhost[crlf]Cookie: mhost[crlf]Proxy-Connection: Keep-Alive [crlf][crlf][raw][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]Upgrade-Insecure-Requests: 1[crlf]User-Agent: Mozilla/5.0 (Linux; Android 5.1; LG-X220 Build/LMY47I) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.83 Mobile Safari/537.36[crlf]Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8[crlf]Referer: http://mhost[crlf]Accept-Encoding: gzip, deflate, sdch[crlf]Accept-Language: pt-BR,pt;q=0.8,en-US;q=0.6,en;q=0.4[crlf]Cookie: _ga=GA1.2.2045323091.1494102805; _gid=GA1.2.1482137697.1494102805; tfp=80bcf53934df3482b37b54c954bd53ab; tpctmp=1494102806975; pnahc=0; _parsely_visitor={%22id%22:%22719d5f49-e168-4c56-b7c7-afdce6daef18%22%2C%22session_count%22:1%2C%22last_session_ts%22:1494102810109}; sc_is_visitor_unique=rx10046506.1494105143.4F070B22E5E94FC564C94CB6DE2D8F78.1.1.1.1.1.1.1.1.1[crlf][crlf]Connection: close[crlf]Proxy-Connection: Keep-Alive[crlf][netData][crlf] [crlf][crlf]
GET [host_port] [protocol][crlf][split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][raw][crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf]Connection: close[crlf]Proxy-connection: Keep-Alive[crlf]Proxy-Authorization: Basic[crlf]Cache-Control: no-cache[crlf][raw][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]User-Agent: [ua][crlf]Connection: close [crlf]Referer:http://mhost[crlf]Content-Type: text/html; charset=iso-8859-1[crlf]Content-Length:0[crlf]Accept: text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5[crlf][raw][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]User-Agent: null[crlf]Connection: close[crlf]Proxy-Connection: x-online-host[crlf][crlf] CONNECT [host_port] [protocol] [netData][crlf]Content-Length: 130 [crlf][crlf]
[raw][crlf][delay_split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf]Connection: close[crlf][crlf]User-Agent: Yes[crlf]Accept-Encoding: gzip,deflate[crlf]Accept-Charset: ISO-8859-1,utf-8;q=0.7,;q=0.7[crlf]Connection: Basic[crlf]Referer: mhost[crlf]Cookie: mhost/ [crlf]Proxy-Connection: Keep-Alive[crlf][crlf][netData][crlf] [crlf][crlf]
[raw][crlf][delay_split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf]Connection: close[crlf]Accept-Language: en-us,en;q=0.5[crlf]Accept-Encoding: gzip,deflate[crlf]Accept-Charset: ISO-8859-1,utf-8;q=0.7,;q=0.7[crlf]Keep-Alive: 115[crlf]Connection: keep-alive[crlf]Referer: mhost[crlf]Cookie: mhost/ Proxy-Connection: Keep-Alive[crlf][crlf][netData][crlf] [crlf][crlf]
[raw][crlf][delay_split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf]Connection: close[crlf]Proxy-connection: Keep-Alive[crlf]Proxy-Authorization: Basic[crlf]Cache-Control: no-cache[crlf][raw][crlf] [crlf][crlf]
[raw][crlf][delay_split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf]Connection: close[crlf][crlf][raw][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][crlf][netData][crlf] [crlf][crlf]CONNECT [host_port][method]HTTP/1.1[crlf]HEAD http://mhost/ [protocol][crlf]Host: mhost[crlf][crlf]DELETE http://mhost/ HTTP/1.1[crlf][crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][crlf][method] [host_port]@mip [crlf][crlf]http://mhost/ HTTP/1.1[crlf]mip[crlf][crlf] [crlf][crlf]http://mhost/ HTTP/1.1[crlf]Host@mip[crlf][crlf] [crlf][crlf] http://mhost/ HTTP/1.1[crlf]Host mhost/[crlf][crlf][netData][crlf] [crlf][crlf] http://mhost/ HTTP/1.1[crlf] [crlf][crlf][netData][crlf] [crlf][crlf] http://mhost/ HTTP/1.1[cr][crlf] [crlf][crlf][netData][cr][crlf] [crlf][crlf]CONNECT mip:22@http://mhost/ HTTP/1.1[crlf] [crlf][crlf][netData][crlf] [crlf][crlf]
CONNECT [host_port]@mhost/ HTTP/1.1[crlf][crlf]CONNECT http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Forwarded-For: mhost[crlf]Connection: close[crlf]User-Agent: [ua][crlf]Proxy-connection: Keep-Alive[crlf]Proxy-Authorization: Basic[crlf]Cache-Control : no-cache[crlf][crlf]
CONNECT [host_port]@mhost/ HTTP/1.0[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Forwarded-For: mhost[crlf]Connection: close[crlf]User-Agent: [ua][crlf]Proxy-connection: Keep-Alive[crlf]Proxy-Authorization: Basic[crlf]Cache-Control : no-cache[crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]User-Agent: Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13[crlf]Accept-Language: en-us,en;q=0.5[crlf]Accept-Encoding: gzip,deflate[crlf]Accept-Charset: ISO-8859-1,utf-8;q=0.7,;q=0.7[crlf]Keep-Alive: 115[crlf]Connection: keep-alive[crlf]Referer: mhost[crlf]Cookie: mhost/ Proxy-Connection: Keep-Alive [crlf][crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]User-Agent: Yes[crlf]Accept-Encoding: gzip,deflate[crlf]Accept-Charset: ISO-8859-1,utf-8;q=0.7,;q=0.7[crlf]Connection: Basic[crlf]Referer: mhost[crlf]Cookie: mhost/ [crlf]Proxy-Connection: Keep-Alive[crlf][crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forward-Host: mhost[crlf]X-Forwarded-For: mhost[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][crlf][delay_split]CONNECT [host_port]@mhost/ [protocol][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]DATA: 2048B[crlf]Host: mhost[crlf]User-Agent: Yes[crlf]Connection: close[crlf]Accept-Encoding: gzip[crlf]Non-Buffer: true[crlf]Proxy: false[crlf][crlf][netData][crlf] [crlf][crlf]
GET [host_port] [protocol][crlf][delay_split]CONNECT http://mhost/ HTTP/1.1[crlf]Host: http://mhost/[crlf]X-Online-Host: mhost[crlf]X-Forward-Host: http://mhost[crlf]X-Forwarded-For: mhost[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][raw][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]Cache-Control=max-age=0[crlf][crlf][raw][crlf] [crlf][crlf]
CONNECT [host_port]@mhost/ [protocol][crlf]X-Online-Host: mhost[crlf][crlf][raw][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Referer: mhost[crlf]GET /HTTP/1.1[crlf]Host: mhost[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][raw][crlf][crlf][raw][crlf]Referer: mhost[crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]Connection: close Keep-Alive[crlf]User-Agent: [ua][crlf][crlf][raw][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forward-Host: mhost[crlf]Connection: Keep-Alive[crlf][crlf][split]CONNECT mhost@[host_port] [protocol][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]Connection: Keep-Alive[crlf][crlf][realData][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]Connection: Keep-Alive[crlf][raw][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf][crlf]CONNECT mhost/ [protocol][crlf][crlf]
[raw][crlf]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]CONNECT mhost/ [protocol][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][crlf][raw][crlf][crlf]
GET [host_port]@mhost/ HTTP/1.1[crlf]X-Real-IP:mip[crlf]X-Forwarded-For:http://mhost/ http://mhost/[crlf]X-Forwarded-Port:mhost[crlf]X-Forwarded-Proto:http[crlf]Connection:Keep-Alive[crlf][crlf][instant_split][raw][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host:mhost[crlf][crlf][split][realData][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]Connection: Keep-Alive[crlf][crlf][realData][crlf]CONNECT mhost/ HTTP/1.1[crlf][crlf]
CONNECT [host_port] HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forward-Host: mhost[crlf]User-Agent: [ua][crlf][raw][crlf][crlf]
[raw][crlf]GET http://mhost/ [protocol][crlf][split]mhost:/ HTTP/1.1[crlf]Host: mhost:[crlf]X-Forward-Host: mhost:[crlf][raw][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf][crlf]Connection: close[crlf][crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host:http://mhost[crlf][crlf][netData][crlf] [crlf][crlf] 
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][crlf][realData][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf]Connection: close[crlf][raw][crlf] [crlf][crlf]
GET http://mhost/[crlf]X-Forward-Host: mhost[crlf][crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf][crlf]Host: mhost[crlf]X-Forward-Host: mhost[crlf][crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf][crlf]Host: mhost[crlf][crlf]CONNECT mhost/ [protocol][crlf] [crlf][crlf]
GET http://mhost/ [method] [host_port] HTTP/1.1[crlf]mhost[crlf]HEAD http://mhost/ [protocol][crlf]Host: mhost/ [crlf][crlf]
GET http://mhost/ [method] [host_port] HTTP/1.1[crlf]Forward-Host: mhost[crlf]HEAD http://mhost/ [protocol][crlf]Host: mhost/ [crlf][crlf]
GET http://mhost/ [method] [host_port] HTTP/1.1[crlf]Connection: http://mhost[crlf]HEAD http://mhost/ [protocol][crlf]Host: mhost/ [crlf][crlf]
GET http://mhost/ [method] [host_port] HTTP/1.1[crlf]CONNECT mhost@[host_port] [protocol][crlf]HEAD http://mhost/ [protocol][crlf]Host: mhost/ [crlf][crlf]
GET http://mhost/ [method] [host_port] HTTP/1.1[crlf]Connection: Keep-Alive[crlf]mhost@[host_port][crlf]HEAD http://mhost/ [protocol][crlf]Host: mhost/ [crlf][crlf]
GET http://mhost/ [method] [host_port] HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forwarded-For: mhost[crlf][netdata][crlf] [crlf]GET mhost/ [protocol][crlf]User-Agent: [ua][crlf][raw][crlf][crlf]
GET http://mhost/ [method] [host_port] HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forwarded-For: mhost[crlf][crlf]User-Agent: [ua][crlf][raw][crlf][crlf]
GET http://mhost/ [method] [host_port] HTTP/1.1[crlf][crlf][split]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]X-Forwarded-For: mhost[crlf][crlf]User-Agent: [ua][crlf]Connection: close[crlf][raw][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf][crlf]Host: mhost[crlf][crlf][raw][crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf][crlf]Host: mhost[crlf][crlf]CONNECT mhost@[host_port] [protocol][crlf][raw][crlf] [crlf][crlf]
GET http://mhost/ [method] [host_port] HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]Connection: Keep-Alive[crlf][crlf]
GET http://mhost/ [method] [host_port] HTTP/1.1[crlf][crlf]CONNECT http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]Connection: Keep-Alive[crlf][crlf]
GET http://mhost/ [method] [host_port] HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]Connection: Keep-Alive[crlf]Connection: close[crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]Connection: Keep-Alive[crlf][crlf]CONNECT mhost@[host_port] [protocol][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]CONNECT mhost@[host_port] [protocol][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf][crlf]CONNECT http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]Connection: Keep-Alive[crlf]Connection: close[crlf][netdata][crlf] [crlf][split]Connection: close[crlf]Content-Lenght: 20624[crlf][crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]Connection: Keep-Alive[crlf]Content-Type: text[crlf]Cache-Control: no-cache[crlf]Connection: close[crlf]Content-Lenght: 20624[crlf][crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]mhost[crlf]Host:mhost[crlf][crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf][crlf]Host: mhost[crlf][crlf][realData][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Content-Type: text[crlf]Cache-Control: no-cache[crlf]Connection: close[crlf]Content-Lenght: 20624[crlf][crlf]HEAD http://mhost/ [protocol][crlf]Host: mhost/ [crlf]CONNECT mhost/  [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf][crlf]Content-Type: text[crlf]Cache-Control: no-cache[crlf]Connection: close[crlf]Content-Lenght: 20624[crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf][crlf]host: mhost[crlf][crlf][realData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf][crlf]Host: mhost/ [crlf]Content-Type: text[crlf]Cache-Control: no-cache[crlf]Connection: close[crlf]Content-Lenght: 20624[crlf][crlf][raw][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf][crlf]Host: mhost[crlf]Connection: Keep-Alive[crlf]Content-Type: text[crlf]Cache-Control: no-cache[crlf]Connection: close[crlf]Content-Lenght: 20624[crlf][crlf][realData][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf][crlf]Host: mhost[crlf][crlf]CONNECT mhost/ [protocol][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]mhost[crlf]Host: mhost[crlf][crlf]CONNECT mhost/ [crlf][raw][crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]mhost[crlf]Host: mhost[crlf]Content-Type: text[crlf]Cache-Control: no-cache[crlf]Connection: close[crlf]Content-Lenght: 20624[crlf][crlf]CONNECT [host_port][crlf]CONNECT mhost/ [crlf][crlf][cr]
[realData][crlf][split]GET http://mhost/  HTTP/1.1[crlf][crlf]Host: mhost[crlf]X-Online-Host: mhost[crlf]Connection: Keep-Alive[crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]mhost[crlf]Host: mhost[crlf][crlf]CONNECT [host_port][crlf]GET mhost/ [crlf][crlf]
CONNECT [host_port]@mhost/ HTTP/1.1[crlf][crlf]GET http://mhost/ [protocol][crlf]Host: mhost[crlf]X-Forward-Host: mhost[crlf][raw][crlf][crlf]
[raw][crlf][cr][crlf]X-Online-Host: mhost[crlf]Connection: [crlf]User-Agent: [ua][crlf]Content-Lenght: 99999999999[crlf][crlf]
[raw][crlf]X-Online-Host: mhost/ HTTP/1.1[crlf]Host: mhost[crlf][crlf][raw][crlf]X-Online-Host: mhost[crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Authorization: Basic: Connection: X-Forward-Keep-AliveX-Online-Host: mhost[crlf][crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]host:frontend.claro.com.br[crlf]Content-Type: text[crlf]Cache-Control: no-cache[crlf]Connection: close[crlf]Content-Lenght: 20624[crlf][crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][crlf][raw][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][crlf][netData][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: Multibanco.com.br[crlf][crlf][raw][crlf] [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Host: mhost/ [crlf][crlf][raw][crlf]CONNECT [crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf] Proxy-Authorization: Basic:Connection: X-Forward-Keep-AliveX-Online-Host:[crlf][crlf][netData][crlf] [crlf][crlf]
CONNECT [host_port]@mhost/ [protocol][crlf][instant_split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][crlf]
CONNECT [host_port]@mhost/ [protocol][crlf]Host: mhost[crlf][crlf]
[raw][crlf]X-Online-Host: mhost[crlf][crlf][raw][crlf]X-Online-Host: mhost/ [crlf][crlf]
[raw][crlf]X-Online-Host: http://mhost[crlf][crlf]CONNECT[host_port] [protocol][crlf]X-Online-Host: mhost/ [crlf][crlf]
CONNECT [host_port]@mhost/ HTTP/1.1[crlf]CONNECT mip:443 [crlf][crlf]
CONNECT [host_port]@mhost/ [protocol][crlf]Host: mhost[crlf]X-Forwarded-For: mhost[crlf][crlf][split]GET mhost/ HTTP/1.1[cr][crlf][raw][crlf] [crlf][crlf]
CONNECT [host_port]@mhost/ [protocol][crlf][delay_split]GET http://mhost/ HTTP/1.1[crlf]Host:mhost[crlf][crlf]
CONNECT [host_port]@mhost/ [protocol][crlf][instant_split]GET http://mhost/ HTTP/1.1[crlf]Host: mhost[crlf][crlf]
GET http://mhost/ HTTP/1.1[crlf]Content-Type: text[crlf]Cache-Control: no-cache[crlf]Connection: close[crlf]Content-Lenght: 20624[crlf]GET mip:443@mhost/ HTTP/1.1[crlf][crlf]
CONNECT [host_port]@mhost/ [protocol][crlf]Host: mhost[crlf]X-Forwarded-For: mhost/ User-Agent: Yes[crlf]Connection: close[crlf]Proxy-Connection: Keep-Alive Connection: Transfer-Encoding[crlf] [protocol][crlf]User-Agent: [ua][crlf][raw][auth][crlf][crlf][netData][crlf] [crlf][crlf]
[raw][crlf]Host: mhost[crlf]GET http://mhost/ HTTP/1.1[crlf]X-Online-Host: mhost[crlf][crlf]' > $HOME/$1
}
injector_fun(){
#$0 lista ip porta
if [[ -e /usr/bin/python3 ]]; then
PY="/usr/bin/python3"
elif [[ -e /bin/python3 ]]; then
PY="/bin/python3"
else
apt-get install python3 -y > /dev/null 2>&1
apt-get install python3 pip -y > /dev/null 2>&1
return 1
fi
$PY -x << PYTHON
import socket,os,sys
class injector:
 def __init__(self, payload, conn):
  self.payload = payload
  self.conn = conn
 def iniciar(self):  
  print(repr("Payload: "+self.payload))
  self.conn.send(self.payload.encode())
  status = self.conn.recv(1024).split('\n'.encode())[0]
  aux = status
  print('Status: '+str(status))
  self.conn.close()
class gerarPay:
 def __init__(self, payload):
  self.payload = payload
 def pay(self):
  aux = self.payload.replace('[crlf]','\r\n')
  aux = aux.replace('[lf]','\n')
  aux = aux.replace('[cr]','\r')
  aux = aux.replace('[method]','CONNECT')
  aux = aux.replace('[host_port]','$2:22')
  aux = aux.replace('[host]','$2')
  aux = aux.replace('[port]','22')
  aux = aux.replace('[netData]','CONNECT $2:22 HTTP/1.0')
  aux = aux.replace('[realData]','CONNECT $2:22 HTTP/1.0')
  aux = aux.replace('[raw]','CONNECT $2:22 HTTP/1.0')
  aux = aux.replace('[protocol]','HTTP/1.0')  
  return(aux)
class ListPay:
 def __init__(self, arg):
  self.list = arg
 def EnviarPay(self):
  _pay = self.list
  self.conn  = socket.create_connection(("$2","$3"))
  _PAY_ = gerarPay(_pay).pay()
  a = injector(_PAY_,self.conn)
  a.iniciar()
def main():
 sta = ListPay("$1")
 sta.EnviarPay()
if(__name__=='__main__'):
 main()
PYTHON
}
echo -ne "Digite um Host Alvo: " && read valor1 # Entrada Host
echo -ne "Agora, Digite um PROXY:PORT: " && read svar # Entrada proxy
valor2="$(echo $svar|cut -d':' -f1)" #Entrada IP
port="$(echo $svar|cut -d':' -f2)" #Porta
retorno="GET CONNECT PUT OPTIONS DELETE HEAD PATCH POST"
i=1
for ech in $retorno; do
ech_ret="[$i] $ech" && let i++
while [[ ${#ech_ret} -lt "15" ]]; do ech_ret=$ech_ret' '; done
NUM=$[ $i & 1 ]
if [[ $NUM = 0 ]]; then
reto+="$ech_ret"
else
echo -e "$reto $ech_ret"
unset reto
fi
done
echo -ne "Escola o Metodo de Requisicao: " && read valor3 #Metodo Requisicao
echo -e "[1] realData
[2] netData
[3] raw"
echo -ne "Escolha o Metodo de Conexao: " && read valor4 #Metodo Conexao
case $valor3 in
    1)req="GET";;
    2)req="CONNECT";;
    3)req="PUT";;
    4)req="OPTIONS";;
    5)req="DELETE";;
    6)req="HEAD";;
    7)req="PATCH";;
    8)req="POST";;
    *)req="GET";;
esac
case $valor4 in
     1)in="realData";;
     2)in="netData";;
     3)in="raw";;
     *)in="netData";;
esac
gerar_pays Payloads.txt
sed -i "s;realData;abc;g" $HOME/Payloads.txt
sed -i "s;netData;abc;g" $HOME/Payloads.txt
sed -i "s;raw;abc;g" $HOME/Payloads.txt
sed -i "s;abc;$in;g" $HOME/Payloads.txt
sed -i "s;GET;$req;g" $HOME/Payloads.txt
sed -i "s;get;$req;g" $HOME/Payloads.txt
sed -i "s;mhost;$valor1;g" $HOME/Payloads.txt
sed -i "s;mip;$valor2;g" $HOME/Payloads.txt
echo -e "Payloads Geradas... Testando..."
barra="\033[0;34m================================================================================"
echo -e "$barra"
while read payload; do
#echo -e "\033[1;31mTestando Payload:\033[1;33m$payload"
echo -e "\033[1;31mPAYLOAD NO INJECTOR:\n $payload\n"
retorn=$(injector_fun "$payload" $valor2 $port)
echo -e "\033[1;33m $(echo -e $retorn|grep -v Status)"
echo -e "\033[1;32m$(echo -e $retorn|grep Status)"
echo -e "$barra"
done < $HOME/Payloads.txt
echo -e "\033[1;33m PAYLOADS TESTADO CON SUCESSO!\033[0m"
echo -e "$barra"
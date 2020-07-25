#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;32m" [3]="\033[1;36m" [4]="\033[1;31m" [5]="\033[1;33m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

fun_bar () {
comando="$1"
 _=$(
$comando > /dev/null 2>&1
) & > /dev/null
pid=$!
while [[ -d /proc/$pid ]]; do
echo -ne " \033[1;33m["
   for((i=0; i<10; i++)); do
   echo -ne "\033[1;31m##"
   sleep 0.2
   done
echo -ne "\033[1;33m]"
sleep 1s
echo
tput cuu1 && tput dl1
done
echo -e " \033[1;33m[\033[1;31m####################\033[1;33m] - \033[1;32m100%\033[0m"
sleep 1s
}

echo -e "${cor[5]} $(fun_trans "Esta herramienta le cambia y da color al status de conexión")"

echo -e "$barra"
if [[ ! -e /usr/bin/python ]]; then
echo -e "${cor[5]} $(fun_trans "Introduca Estos Comandos En La Terminal")"
echo -e "apt-get install python -y"
echo -e "apt-get install python pip -y"
exit
fi
echo -e "${cor[0]} $(fun_trans "INICIANDO PROXY PYTHON COLOR PUBLICO")"
echo -e "$barra"
echo -ne "${cor[0]} $(fun_trans "Introduzca puerto"): "
read port
while [[ -z $FMSG || $FMSG = @(s|S|y|Y) ]]; do
echo -e "$barra"
echo -ne "\033[1;37m $(fun_trans "Introduzca Un Mensaje De Conexion"): "
read mensage
echo -e "$barra"
echo -e "\033[1;37m $(fun_trans "Seleccione El Color De Mensaje"): "
echo -e " "
cat << Eof
[ 1 ]  -- #ff183f -- Rojo
[ 2 ]  -- #3fff18 -- Verde
[ 3 ]  -- #6518ff -- Morado
[ 4 ]  -- #ff6518 -- Naranja
[ 5 ]  -- #18ffd9 -- Cyan
[ 6 ]  -- #ffd700 -- Amarillo
[ 7 ]  -- #1e90ff -- Azul
[ 8 ]  -- #000000 -- Negro
[ 9 ]  -- #00ff7f -- Agua marina
[ 10 ] -- #8b4513 -- Cafe
Eof
echo -e " "
read -p "Opcion: " cor
case $cor in
"1")corx="<span style='color: #ff183f;'>${mensage}</span>";;
"2")corx="<span style='color: #3fff18;'>${mensage}</span>";;
"3")corx="<span style='color: #6518ff;'>${mensage}</span>";;
"4")corx="<span style='color: #ff6518;'>${mensage}</span>";;
"5")corx="<span style='color: #18ffd9;'>${mensage}</span>";;
"6")corx="<span style='color: #ffd700;'>${mensage}</span>";;
"7")corx="<span style='color: #1e90ff;'>${mensage}</span>";;
"8")corx="<span style='color: #000000;'>${mensage}</span>";;
"9")corx="<span style='color: #00ff7f;'>${mensage}</span>";;
"10")corx="<span style='color: #8b4513;'>${mensage}</span>";;
*)corx="<span style='color: #ff183f;'>${mensage}</span>";;
esac
if [[ ! -z ${RETORNO} ]]; then
RETORNO="${RETORNO} ${corx}"
else
RETORNO="${corx}"
fi
echo -e "$barra"
echo -ne "${cor[5]} $(fun_trans "Adicionar Mensagem Secundaria")? [S/N]: "
read FMSG
done
echo -e "$barra"
read -p "Enter para confirmar..."
# Inicializando o Proxy
(
/usr/bin/python -x << PYTHON
# -*- coding: utf-8 -*-
import socket, threading, thread, select, signal, sys, time, getopt

LISTENING_ADDR = '0.0.0.0'
LISTENING_PORT = int("$port")
PASS = str("$ipdns")
BUFLEN = 4096 * 4
TIMEOUT = 60
DEFAULT_HOST = '127.0.0.1:443'
msg = "HTTP/1.1 200 <strong>($RETORNO)</strong>\r\nContent-length: 0\r\n\r\nHTTP/1.1 200 !!!conexion exitosa!!!\r\n\r\n"
RESPONSE = str(msg)

class Server(threading.Thread):
    def __init__(self, host, port):
        threading.Thread.__init__(self)
        self.running = False
        self.host = host
        self.port = port
        self.threads = []
        self.threadsLock = threading.Lock()
        self.logLock = threading.Lock()

    def run(self):
        self.soc = socket.socket(socket.AF_INET)
        self.soc.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.soc.settimeout(2)
        self.soc.bind((self.host, self.port))
        self.soc.listen(0)
        self.running = True

        try:
            while self.running:
                try:
                    c, addr = self.soc.accept()
                    c.setblocking(1)
                except socket.timeout:
                    continue

                conn = ConnectionHandler(c, self, addr)
                conn.start()
                self.addConn(conn)
        finally:
            self.running = False
            self.soc.close()

    def printLog(self, log):
        self.logLock.acquire()
        print log
        self.logLock.release()

    def addConn(self, conn):
        try:
            self.threadsLock.acquire()
            if self.running:
                self.threads.append(conn)
        finally:
            self.threadsLock.release()

    def removeConn(self, conn):
        try:
            self.threadsLock.acquire()
            self.threads.remove(conn)
        finally:
            self.threadsLock.release()

    def close(self):
        try:
            self.running = False
            self.threadsLock.acquire()

            threads = list(self.threads)
            for c in threads:
                c.close()
        finally:
            self.threadsLock.release()


class ConnectionHandler(threading.Thread):
    def __init__(self, socClient, server, addr):
        threading.Thread.__init__(self)
        self.clientClosed = False
        self.targetClosed = True
        self.client = socClient
        self.client_buffer = ''
        self.server = server
        self.log = 'Connection: ' + str(addr)

    def close(self):
        try:
            if not self.clientClosed:
                self.client.shutdown(socket.SHUT_RDWR)
                self.client.close()
        except:
            pass
        finally:
            self.clientClosed = True

        try:
            if not self.targetClosed:
                self.target.shutdown(socket.SHUT_RDWR)
                self.target.close()
        except:
            pass
        finally:
            self.targetClosed = True

    def run(self):
        try:
            self.client_buffer = self.client.recv(BUFLEN)

            hostPort = self.findHeader(self.client_buffer, 'X-Real-Host')

            if hostPort == '':
                hostPort = DEFAULT_HOST

            split = self.findHeader(self.client_buffer, 'X-Split')

            if split != '':
                self.client.recv(BUFLEN)

            if hostPort != '':
                passwd = self.findHeader(self.client_buffer, 'X-Pass')
				
                if len(PASS) != 0 and passwd == PASS:
                    self.method_CONNECT(hostPort)
                elif len(PASS) != 0 and passwd != PASS:
                    self.client.send('HTTP/1.1 400 WrongPass!\r\n\r\n')
                elif hostPort.startswith('127.0.0.1') or hostPort.startswith('localhost'):
                    self.method_CONNECT(hostPort)
                else:
                    self.client.send('HTTP/1.1 403 Forbidden!\r\n\r\n')
            else:
                print '- No X-Real-Host!'
                self.client.send('HTTP/1.1 400 NoXRealHost!\r\n\r\n')

        except Exception as e:
            self.log += ' - error: ' + e.strerror
            self.server.printLog(self.log)
	    pass
        finally:
            self.close()
            self.server.removeConn(self)

    def findHeader(self, head, header):
        aux = head.find(header + ': ')

        if aux == -1:
            return ''

        aux = head.find(':', aux)
        head = head[aux+2:]
        aux = head.find('\r\n')

        if aux == -1:
            return ''

        return head[:aux];

    def connect_target(self, host):
        i = host.find(':')
        if i != -1:
            port = int(host[i+1:])
            host = host[:i]
        else:
            if self.method=='CONNECT':
                port = 443
            else:
                port = 80
                port = 8080
                port = 8799
                port = 3128

        (soc_family, soc_type, proto, _, address) = socket.getaddrinfo(host, port)[0]

        self.target = socket.socket(soc_family, soc_type, proto)
        self.targetClosed = False
        self.target.connect(address)

    def method_CONNECT(self, path):
        self.log += ' - CONNECT ' + path

        self.connect_target(path)
        self.client.sendall(RESPONSE)
        self.client_buffer = ''

        self.server.printLog(self.log)
        self.doCONNECT()

    def doCONNECT(self):
        socs = [self.client, self.target]
        count = 0
        error = False
        while True:
            count += 1
            (recv, _, err) = select.select(socs, [], socs, 3)
            if err:
                error = True
            if recv:
                for in_ in recv:
		    try:
                        data = in_.recv(BUFLEN)
                        if data:
			    if in_ is self.target:
				self.client.send(data)
                            else:
                                while data:
                                    byte = self.target.send(data)
                                    data = data[byte:]

                            count = 0
			else:
			    break
		    except:
                        error = True
                        break
            if count == TIMEOUT:
                error = True

            if error:
                break

def main(host=LISTENING_ADDR, port=LISTENING_PORT):

    print "\n:-------PythonProxy-------:\n"
    print "Listening addr: " + LISTENING_ADDR
    print "Listening port: " + str(LISTENING_PORT) + "\n"
    print ":-------------------------:\n"

    server = Server(LISTENING_ADDR, LISTENING_PORT)
    server.start()

    while True:
        try:
            time.sleep(2)
        except KeyboardInterrupt:
            print 'Stopping...'
            server.close()
            break

if __name__ == '__main__':
    main()
PYTHON
) > $HOME/proxy.log &
echo -e "$barra"
echo "Proxy Iniciado Con Exito"
echo "Listen 0.0.0.0:${port} ..."
echo -e "$barra"
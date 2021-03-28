#!/usr/bin/python3
# encoding: utf-8
import socket,threading,os,json,sys
from base64 import b64decode as cdf
from base64 import b64encode as cdd
h = []
h.append(b'0VUIA==')
if sys.platform[:9] == 'linux-arm':
    CFGF=os.getcwd()+'/conf.cfg'
else:
    CFGF=os.getcwd()+'/conf.cfg'
class Proxy:
    def ativar(self,lhost,lport,rhost,rport,bypass,host):
        proxy = socket.socket()
        proxy.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1)
        proxy.bind((lhost,lport))
        proxy.listen(0)
        while True:
            cliente, endereco = proxy.accept()
            Handler(cliente,rhost,rport,bypass,host).start()
h.append(b'UVFAvMS4xDQpNOiBkDQoNCg==')
class Handler(threading.Thread):
    def __init__(self,ab,rhost,rport,b,hd):
        threading.Thread.__init__(self)
        self.ab    = ab
        self.r     = rhost
        self.p     = rport
        self.b     = b
        self.hd    = hd
    def run(self):
        print('\033[01;32m? Conectando...?\033[01;37m')
        try:
            ab = cc((self.r,self.p))
            snd = ab.sendall
            snd(cdf(b'R'+h[0])+cdf(self.b[:1].encode()+self.hd.encode())+cdf(b'IEh'+h[1]))
            psr = ab.recv(16384)
            if psr:
                HandlerL(self.ab,ab).start()
                ab = cc((self.r,self.p))
                ed = ab.sendall
                ed(cdf(b'R'+h[0])+cdf(self.b[:1].encode()+self.hd.encode())+cdf(b'IE'+h[2]))
                print(' \n')
                print('\033[01;32m? Conectado ?\n')
                print('\033[01;37mBom Uso!\n')
                while True:
                    try:
                        code = self.ab.recv(2048)
                        if not code: break
                        ed(code)
                    except:
                        self.ab.close()
                        ab.close()
                        break
            else:
                print('\033[01;31m[!!!] Erro, Host Nao Responde... [!!!]\033[01;37m')
                print('\033[01;31m[!!!] Ou O Server Esta Indispinivel... [!!!]')
                self.ab.close()
                ab.close()
        except socket.error as err:
            self.ab.close()
            print('\033[01;31m[!] Erro: {}'.format(err))
h.append(b'hUVFAvMS4xDQpNOiB1DQpDb25')
class HandlerL(threading.Thread):
    def __init__(self,s1,s2):
        threading.Thread.__init__(self)
        self.s1 = s1
        self.s2 = s2
    def run(self):
        while True:
            try:
                tr = self.s2.recv(16384)
                if not tr: break
                self.s1.send(tr)
            except:
                break
        try:
            self.s1.close()
            self.s2.close()
        except:
            pass
from socket import create_connection as cc
h[2] = h[2]+b'0ZW50LUxlbmd0aDogOTk5OTk5OTk5OTkNCg0K'
if __name__ == '__main__':
    def lembrar(cfg):
        try:
            a = open(CFGF,'w')
            cfg['smpr'] = 1
            a.write(json.dumps(cfg,sort_keys=False,indent=4))
            a.close()
        except IOError:
            print('\033[01;31m[!] Configuracoes Nao Carregadas')
    def configurar():
        while True:
            servidor = input('[$] Selecione Um Servidor:\n[1] - 127.0.0.1\n[2] - Novo Servidor\nSelect: \033[01;33m')
            print('\033[01;37m')            
            if servidor == '1':
                servidor = servidor='192.168.0.1'
                break
            if servidor == '2':
                servidor = servidor=input('Digite o Server: \033[01;33m')
                break
            else:
                print('\033[01;31m[!] Server Invalido\033[01;37m')
        while True:
            porta = int(input('\033[01;31m[$] Porta do Servidor:\033[01;33m '))
            print('\033[01;37m')
            if porta != '':
                break
            else:
                print('\033[01;31m[!] Porta Invalida\033[01;37m')
        while True:
            hh = input('\033[01;31m[$] Host Header:\033[01;33m ').replace(' ','')
            print('\033[01;37m')
            if hh:
                if hh[:7] != 'http://' and hh[:8] != 'https://':
                    hh = cdd(b'http://'+hh.encode()).decode()
                else:
                    hh = cdd(hh.encode()).decode()
                break
        while True:
            r = input('\033[01;31m[!] Salvar Configuracoes? [s/n]:\033[01;33m ')
            print('\033[01;37m')
            if r == 's':
                try:
                    a = open(CFGF,'w')
                    cfg = {}
                    cfg['servidor'] = servidor
                    cfg['porta'] = porta
                    cfg['header'] = hh[1:]
                    cfg['kbp'] = hh[:2]
                except IOError:
                    print('\033[01;31m[!] Configuracoes Nao Foram Salvas.')
                else:
                    cfg['smpr'] = 0
                    a.write(json.dumps(cfg,sort_keys=False,indent=4))
                    a.close()
                break
            elif r == 'n':
                break
            elif r != 's' and r != 'n':
                print('[!] Digite \'s\' ou \'n\'' )
        return servidor,porta,hh[:3],hh[1:]
    os.system("clear")
    lhost = '127.0.0.1'
    lport = 3387
    try:
        handler = Proxy()
        print('\033[01;32m[- PYTHON CLIENT CONNECT -]\033[01;37m\n')
        try:
            cfg = json.loads(open(CFGF,'r').read())
            if cfg['servidor'] and cfg['porta'] and cfg['header'] and cfg['kbp']:
                try:
                    if cfg['smpr']:
                        servidor = cfg['servidor']
                        porta = int(cfg['porta'])
                        hh = cfg['header']
                        b = cfg['kbp']
                    else:
                        rs = input('\033[01;36m[$] Carregar Configuracoes Anteriores? [s/n]:\033[01;33m ')
                        print('\033[01;37m')
                        while True:
                            if rs == 's':
                                servidor = cfg['servidor']
                                porta = int(cfg['porta'])
                                hh = cfg['header']
                                b = cfg['kbp']                               
                                print('\033[01;37m')
                                break
                            elif rs == 'n':
                                cfg = configurar()
                                servidor = cfg[0]
                                porta = cfg[1]
                                b = cfg[2]
                                hh = cfg[3]
                                break
                            elif rs != 'n' and rs != 's':
                                rs = input('[$] Digite \'s\' ou \'n\':\033[01;33m ')
                                print('\033[01;37m')
                except:
                    rs = input('\033[01;36m[$] Carregar Configuracoes Anteriores? [s/n]:\033[01;33m ')
                    print('\033[01;37m')
                    while True:
                        if rs == 's':
                            servidor = cfg['servidor']
                            porta = int(cfg['porta'])
                            hh = cfg['header']
                            b = cfg['kbp']
                            break
                        elif rs == 'n':
                            cfg = configurar()
                            servidor = cfg[0]
                            porta = cfg[1]
                            b = cfg[2]
                            hh = cfg[3]
                            break
                        elif rs != 'n' and rs != 's':
                            rs = input('[$] IMPUT \'s\' ou \'n\': ')
                            print('\033[01;37m')
        except:
            cfg = configurar()
            servidor = cfg[0]
            porta = cfg[1]
            b = cfg[2]
            hh = cfg[3]
        print('\033[01;34m[- SCRIPT STARTED ------]\033[01;37m')
        print('[$][ SSH : {}:{}'.format(lhost,lport))
        print('[$][ Server  : {}:{}'.format(servidor,str(porta)))
        print('\n[--------------------------------]\n')
        handler.ativar(lhost,lport,servidor,porta,b,hh)
    except socket.error as err:
        print('\033[01;31m[~ ERRO ~]\n{}\033[0m'.format(err))
    except KeyboardInterrupt:
        print('\033[01;37m\n[!] EXITING...\033[0m')
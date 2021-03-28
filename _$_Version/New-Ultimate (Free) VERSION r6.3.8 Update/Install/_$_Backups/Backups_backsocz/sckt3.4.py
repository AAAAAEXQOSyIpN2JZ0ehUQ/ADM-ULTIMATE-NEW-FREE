# File: s (Python 3.4)

import socket
import threading
from sys import argv
SESSOES = { }

def CriarSessao(endereco, sessao):
    SESSOES[endereco] = sessao


def UsarSessao(endereco):
    
    try:
        sessao = SESSOES[endereco]
    except:
        return False

    del SESSOES[endereco]
    return sessao


class Proxy:
    __qualname__ = 'Proxy'
    
    def ativar(self, lhost, lport, MSG):
        proxy = socket.socket()
        proxy.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        proxy.bind((lhost, lport))
        proxy.listen(0)
        while None:
            (cliente, endereco) = proxy.accept()
            Master(cliente, endereco[0], MSG).start()



def Master():
    '''Master'''
    __qualname__ = 'Master'
    
    def __init__(self, cliente, endereco, MSG):
        threading.Thread.__init__(self)
        self.cliente = cliente
        self.endereco = endereco
        self.MSG = MSG

    
    def run(self):
        
        try:
            req = b''
            req = self.cliente.recv(1024)
        except:
            pass

        if req:
            pay = req.split(b'\r\n')
            n = 0
            acao = b''
            while n < len(pay):
                if pay[n].split(b': ')[0] == b'X-Action' or pay[n].split(b': ')[0] == b'M':
                    acao = pay[n].split(b': ')[1]
                n = n + 1
            if req[:4] == b'SSH-':
                
                try:
                    self.ssh = socket.create_connection(('127.0.0.1', 443))
                    self.cliente.settimeout(180)
                    self.ssh.send(req)
                    HandlerL(self.cliente, self.ssh).start()
                    while None:
                        
                        try:
                            dados = self.ssh.recv(16384)
                            if not dados:
                                break
                            self.cliente.send(dados)
                        continue
                        break
                        continue

                    self.cliente.close()
                    self.ssh.close()

            elif acao == b'':
                
                try:
                    self.cliente.sendall(b'HTTP/1.1 200 ' + self.MSG + b'\r\nServer: EduSSHBypasser\r\nContent-Length: 0\r\n\r\n')
                    MSimples(self.cliente).start()
                self.cliente.close()

            elif acao == b'create':
                
                try:
                    self.cliente.sendall(b'HTTP/1.1 200 Created\r\nServer: EduSSHBypasser\r\nX-Id: 0\r\nConnection: close\r\n\r\n')
                    GetTunnel(self.cliente, self.endereco).start()
                self.cliente.close()

            elif acao == b'complete':
                
                try:
                    self.cliente.sendall(b'HTTP/1.1 200 Completed\r\nServer: EduSSHBypasser\r\nConnection: close\r\n\r\n')
                    CriarSessao(self.endereco, self.cliente)
                self.cliente.close()

            elif acao == b'u':
                TOH(self.cliente, self.endereco).start()
            elif acao == b'd':
                
                try:
                    self.cliente.send(b'HTTP/1.1 200 ' + self.MSG + b'\r\nServer: EduSSHBypasser\r\nConnection: close\r\n\r\n')
                    CriarSessao(self.endereco, self.cliente)
                self.cliente.close()

            
        else:
            self.cliente.close()


Master = <NODE:28>(Master, 'Master', threading.Thread)

def MSimples():
    '''MSimples'''
    __qualname__ = 'MSimples'
    
    def __init__(self, cliente):
        threading.Thread.__init__(self)
        self.cliente = cliente

    
    def run(self):
        dados = ''
        l = 0
        while l < 4:
            l = l + 1
            
            try:
                dados = self.cliente.recv(1024)
                if not dados:
                    break
            except:
                break

            if dados[:4] == b'SSH-':
                
                try:
                    self.ssh = socket.create_connection(('127.0.0.1', 443))
                    self.cliente.settimeout(180)
                    self.ssh.send(dados)
                except:
                    break

                HandlerL(self.cliente, self.ssh).start()
                while None:
                    
                    try:
                        dados = self.ssh.recv(16384)
                        if not dados:
                            break
                        self.cliente.send(dados)
                    continue
                    break
                    continue

                continue
            
            try:
                self.cliente.sendall(b'HTTP/1.1 200 ~EduSSH~\r\n\r\n')
            continue
            break
            continue

        
        try:
            self.cliente.close()
            self.ssh.close()
        except:
            pass



MSimples = <NODE:28>(MSimples, 'MSimples', threading.Thread)

def GetTunnel():
    '''GetTunnel'''
    __qualname__ = 'GetTunnel'
    
    def __init__(self, cliente, endereco):
        threading.Thread.__init__(self)
        self.cliente = cliente
        self.endereco = endereco

    
    def run(self):
        
        try:
            req = self.cliente.recv(1024)
        except:
            pass

        if req:
            pay = req.split(b'\r\n')
            n = 1
            acao = b''
            while n < len(pay) - 1:
                if pay[n].split(b': ')[0] == b'X-Action':
                    acao = pay[n].split(b': ')[1]
                n = n + 1
            if acao == b'data':
                cliente = b''
                ssh = b''
                
                try:
                    self.cliente.settimeout(180)
                    ssh = socket.create_connection(('127.0.0.1', 443))
                    cliente = UsarSessao(self.endereco)
                    cliente.settimeout(180)
                    if cliente and ssh:
                        HandlerL(self.cliente, ssh).start()
                        while None:
                            
                            try:
                                dados = self.ssh.recv(16384)
                                if not dados:
                                    break
                                cliente.send(dados)
                            continue
                            break
                            continue

                        
                        try:
                            self.ssh.close()
                            cliente.close()

                self.cliente.close()

            else:
                self.cliente.close()


GetTunnel = <NODE:28>(GetTunnel, 'GetTunnel', threading.Thread)

def TOH():
    '''TOH'''
    __qualname__ = 'TOH'
    
    def __init__(self, cliente, endereco):
        threading.Thread.__init__(self)
        self.tohu = cliente
        self.endereco = endereco

    
    def run(self):
        
        try:
            dados = self.tohu.recv(1024)
        except:
            pass

        if dados[:4] == b'SSH-':
            
            try:
                self.ssh = socket.create_connection(('127.0.0.1', 443))
                self.tohu.settimeout(180)
                self.tohd = UsarSessao(self.endereco)
                self.tohd.settimeout(180)
                self.ssh.send(dados)
                HandlerL(self.tohu, self.ssh).start()
                while None:
                    
                    try:
                        dados = self.ssh.recv(16384)
                        if not dados:
                            break
                        self.tohd.send(dados)
                    continue
                    break
                    continue


        
        try:
            self.tohu.close()
            self.tohd.close()
            self.ssh.close()
        except:
            pass



TOH = <NODE:28>(TOH, 'TOH', threading.Thread)

def HandlerL():
    '''HandlerL'''
    __qualname__ = 'HandlerL'
    
    def __init__(self, s1, s2):
        threading.Thread.__init__(self)
        self.s1 = s1
        self.s2 = s2

    
    def run(self):
        while None:
            
            try:
                dados = self.s1.recv(2048)
                if not dados:
                    break
                self.s2.send(dados)
            continue
            break
            continue

        
        try:
            self.s1.close()
            self.s2.close()
        except:
            pass



HandlerL = <NODE:28>(HandlerL, 'HandlerL', threading.Thread)
if __name__ == '__main__':
    
    try:
        lhost = '0.0.0.0'
        lport = int(argv[1])
        MSG = str(argv[2]).encode()
    except:
        print('Execute: sckt [porta] [mensagem]')

    if lport and MSG:
        
        try:
            servidor = Proxy()
            print('[~ SERVIDOR ~]\nEndereco: {}:{}'.format(lhost, lport))
            servidor.ativar(lhost, lport, MSG)
        except socket.error:
            err = None
            
            try:
                print('[~ ERRO ~]\n{}'.format(err))
            finally:
                err = None
                del err

        except KeyboardInterrupt:
            print('\n[!] Encerrando...')
        

    print('Execute: sckt [porta] [mensagem]')

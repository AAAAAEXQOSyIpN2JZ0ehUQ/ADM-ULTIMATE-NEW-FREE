#!/usr/bin/env python
from urllib2 import *
from platform import system
import sys
def clear():
    if system() == 'Linux':
        os.system("clear")
    if system() == 'Windows':
        os.system('cls')
        os.system('color a')
    else:
        pass
def slowprint(s):
    for c in s + '\n':
        sys.stdout.write(c)
        sys.stdout.flush()
        time.sleep(4. / 100)
def menu():
   print''' \033[01;33mNET TOOLS TARGET \033[01;32m[New-ADM]
\033[0;34m====================================================== 
 \033[01;32m[1] > \033[1;36mBUSQUEDA DE DNS
 \033[01;32m[2] > \033[1;36mINFORMACION DEL SITIO
 \033[01;32m[3] > \033[1;36mIP INVERSA
 \033[01;32m[4] > \033[1;36mDETECTAR IP GLOBAL
 \033[01;32m[5} > \033[1;36mBUSQUEDA DE SUBRED
 \033[01;32m[6] > \033[1;36mESCANEAR PUERTOS
 \033[01;32m[7] > \033[1;36mEXTRAER ENLACES
 \033[01;32m[8] > \033[1;36mZONA DE TRANSFERENCIA
 \033[01;32m[9] > \033[1;36mENCABEZADO HTTP
 \033[01;32m[10] > \033[1;36mBUSCADOR DE HOST
 \033[01;32m[0] > \033[1;37mVOLVER
\033[0;34m======================================================'''

menu()
def ext():
           exit()

def  select():
  try:
    joker = input("\033[1;37mSeleccione una opcion:\033[01;0m ")
    if joker == 2:
      dz = raw_input('\033[1;37mPon la url de la pagina web:\033[1;36m')
      whois = "http://api.hackertarget.com/whois/?q=" + dz
      dev = urlopen(whois).read()
      print (dev)
      ext()
    elif joker == 3:
      dz = raw_input('\033[1;37mPon la url de la pagina web :\033[1;36m')
      revrse = "http://api.hackertarget.com/reverseiplookup/?q=" + dz
      lookup = urlopen(revrse).read()
      print (lookup)
      ext()
    elif joker == 1:
      dz = raw_input('\033[1;37mPon la url de la pagina web :\033[1;36m')
      dns = "http://api.hackertarget.com/dnslookup/?q=" + dz
      joker = urlopen(dns).read()
      print (joker)
      ext()
    elif joker == 4:
      dz = raw_input('\033[1;37mPon la url de la pagina web :\033[1;36m')
      geo = "http://api.hackertarget.com/geoip/?q=" + dz
      ip = urlopen(geo).read()
      print (ip)
      ext()
    elif joker == 5:
      dz = raw_input('\033[1;37mPon la url de la pagina web :\033[1;36m')
      sub = "http://api.hackertarget.com/subnetcalc/?q=" + dz
      net = urlopen(sub).read()
      print (net)
      ext()
    elif joker == 6:
      dz = raw_input('\033[1;37mPon la url de la pagina web :\033[1;36m')
      port = "http://api.hackertarget.com/nmap/?q=" + dz
      scan = urlopen(port).read()
      print (scan)
      ext()
    elif joker == 7:
      dz = raw_input('\033[1;37mPon la url de la pagina web :\033[1;36m')
      get = "https://api.hackertarget.com/pagelinks/?q=" + dz
      page = urlopen(get).read()
      print(page)
      ext()
    elif joker == 8:
      dz = raw_input('\033[1;37mPon la url de la pagina web :\033[1;36m')
      zon = "http://api.hackertarget.com/zonetransfer/?q=" + dz
      tran = urlopen(zon).read()
      print (tran)
      ext()
    elif joker == 9:
      dz = raw_input('\033[1;37mPon la url de la pagina web :\033[1;36m')
      hea = "http://api.hackertarget.com/httpheaders/?q=" + dz
      der =  urlopen(hea).read()
      print (der)
      ext()
    elif joker == 10:
      dz = raw_input('\033[1;37mPon la url de la pagina web :\033[1;36m')
      host = "http://api.hackertarget.com/hostsearch/?q=" + dz
      finder = urlopen(host).read()
      print (finder)
      ext()
    elif joker == 0:
      ext()
  except:
      ext()
select()
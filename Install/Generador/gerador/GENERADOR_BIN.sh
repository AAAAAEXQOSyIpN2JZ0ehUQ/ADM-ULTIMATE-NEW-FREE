#!/bin/bash
# Bin _ Gen #OFC
link_bin="https://www.dropbox.com/s/37psc5yx7060y22/generadorcc.py?dl=0"
[[ ! -e /usr/bin/generadorcc.py ]] && wget -O /usr/bin/generadorcc.py ${link_bin} > /dev/null && chmod +x /usr/bin/generadorcc.py
msg -ama "$(fun_trans "GERADOR DE BINS OFICIAL")"
msg -bar
msg -ne "$(fun_trans "Digite a bin"): " && read UsrBin
while [[ ${#UsrBin} -lt 16 ]]; do
UsrBin+="x"
done
msg -ne "$(fun_trans "Quantas Bins Quer Gerar"): " && read GerBin
[[ $GerBin != +([0-9]) ]] && GerBin=10
[[ -z $GerBin ]] && GerBin=10
msg -bar
python /usr/bin/generadorcc.py -b ${UsrBin} -u ${GerBin} -d -c
msg -bar
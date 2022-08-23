#!/usr/bin/bash

txt () { # Sistema de Traducao
echo "$@"
}
fun_alterar() { # Arquivo # Campo_busca_para_definir_a_linha # Novo_campo
ARQUIVO="$1" ; LINHA=$(grep -n "$2" $ARQUIVO|head -1|awk -F: 'END{print$1}')
sed -i "${LINHA}s/.*/$3/" $ARQUIVO
}
fun_unir() { # coloca _ entre os espaçamentos do texto.
local quant_param=${#@} ; local line=($@) l; local RET
for((i=0;i<$((${quant_param}-1));i++)); do RET+="${line[$i]}_" ; done
RET+="${line[$(($quant_param-1))]}" && echo $RET
}
menu () { # Menu com Dialog OPT=MSG
[[ -z $@ ]] && return
if [[ "$1" = -[Tt] ]]; then
local TITLE="$(txt $2)" && shift ; shift
else 
local TITLE="$(txt Escolha As Seguintes Opcoes)"
fi
local line ; local opt1 ; local opt2
while [[ "$@" ]]; do
IFS="=" && read opt1 opt2 <<< "$1" && unset IFS
opt1=$opt1 && opt2=$(fun_unir $(txt $opt2))
line+="$opt1 '$opt2' "
shift
done
dialog --stdout --title "$(txt Selecione...)" --menu "$TITLE"  0 0 0 \
$line
case $? in
0)return 0;; # Ok
1)return 1;; # Cancelar
2)return 1;; # Help
255)return 1;; # Esc
*)return 1;;
esac
} 
fun_pergunta () { # Cria Um Box De Pergunta Usando Dialog
local IMPUT=$(fun_unir $(txt $@))
dialog --stdout --inputbox "$IMPUT" 0 0
case $? in
0)return 0;; # Ok
1)return 1;; # Cancelar
2)return 1;; # Help
255)return 1;; # Esc
*)return 1;;
esac
}
box_arq (){ # Cria um Box Apartir de Um Arquivo "arq" "texto"
local ENT=("$@") ; local ARQ="${ENT[0]}" ; local TI="${ENT[@]:1}"
[[ -z "$TI" ]] && local TI="$(txt Mensagem)" || local TI=$(fun_unir $(txt $TI))
dialog --stdout --title "${TI}" --textbox "${ARQ}" 0 0
}
box () { # Cria Um Box Apartir De Um Texto
local ENT=("$@") ; local TITLE=$(fun_unir $(txt ${ENT[0]})) ; local IMPUT="$(txt ${ENT[@]:1})"
dialog --stdout --title "${TITLE}" --msgbox "${IMPUT}" 0 0
}
read_var () { # 1 Parametro e a Pergunta do Read
local VAR ; local READ=$(fun_unir $(txt $@))
while [[ -z $VAR || ${#VAR} -lt 5 ]]; do
if [[ ! -z "$VAR" ]]; then # MANDA MENSAGEM DE ERRO
   [[ "${#VAR}" -lt 5 ]] && box "$(txt ERRO)" "$(txt POR FAVOR DIGITE MAIS DE 5 CARACTERES)"
fi
VAR=$(fun_pergunta $READ) || return 1
done
VAR=$(fun_unir $VAR) && echo "$VAR"
}
read_var_num () { # 1 Parametro e a Pergunta do Read
local VAR ; local READ=$(fun_unir $(txt $@))
while [[ -z $VAR ]] || [[ ${#VAR} -lt 1 ]] || [[ "$VAR" != ?(+|-)+([0-9]) ]]; do
if [[ ! -z "$VAR" ]]; then # MANDA MENSAGEM DE ERRO
    if [[ "${#VAR}" -lt 6 ]]; then box "$(txt ERRO)" "$(txt POR FAVOR DIGITE AO MENOS 1 NUMERO)"
    else [[ "$VAR" != ?(+|-)+([0-9]) ]] && box "$(txt ERRO)" "$(txt POR FAVOR DIGITE APENAS NUMEROS)"
    fi
fi
VAR=$(fun_pergunta $READ) || return 1
done
VAR=$(fun_unir $VAR) && echo "$VAR"
}
fun_bar () { # $1 = Titulo, $2 = Mensagem $3 = %%
local TITLE=$(fun_unir $(txt $1)) ; local MSG=$(fun_unir $(txt $2)) ; local PERCENT=$3
dialog --title "${TITLE}" --gauge "${MSG}" 8 40 0 <<< "${PERCENT}"
}


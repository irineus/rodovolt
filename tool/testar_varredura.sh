#!/usr/bin/env bash
# tool/testar_varredura.sh — prova negativa do tool/varrer_segredos.sh.
#
# Monta, num diretório temporário, um arquivo por categoria com um segredo FALSO (as strings
# são concatenadas em tempo de execução para que o repositório nunca contenha um valor que
# pareça real) e exige que a varredura REPROVE cada um. Depois exige que um diretório limpo
# (com VIN mascarado e sem GPS) PASSE. Sai 0 só se as duas metades se comportarem.
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VARREDURA="$RAIZ/tool/varrer_segredos.sh"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
falhas=0

a() { printf '%s' "$@"; }   # concatena pedaços
x() { printf "%0${1}d" 0 | tr 0 "$2"; }  # repete um caractere

caso() { # $1 = nome, $2 = arquivo, $3 = conteúdo
  # $4 = trecho do motivo que a varredura tem de citar (reprovar pelo motivo errado não vale)
  local d="$tmp/$1" saida; mkdir -p "$d"; printf '%s\n' "$3" > "$d/$2"
  if saida="$(bash "$VARREDURA" "$d" 2>&1)"; then
    echo "FALHOU: '$1' passou na varredura (deveria reprovar)"; falhas=$((falhas + 1))
  elif ! grep -q -- "$4" <<< "$saida"; then
    echo "FALHOU: '$1' reprovado pelo motivo errado (esperado: $4)"; echo "$saida"; falhas=$((falhas + 1))
  else
    echo "ok: '$1' reprovado ($4)"
  fi
}

caso token-github   cfg.dart  "const t = '$(a gh p_)$(x 36 A)';" "token do GitHub"
caso chave-google   cfg.dart  "const k = '$(a AI za)$(x 35 b)';" "chave de API do Google"
caso chave-aws      cfg.txt   "$(a AK IA)$(x 16 Q)" "chave de acesso AWS"
caso chave-anthropic cfg.txt  "$(a sk- ant-)$(x 30 z)" "chave da API da Anthropic"
caso chave-privada  id.txt    "$(a '-----BEGIN ' 'PRIVATE KEY-----')" "chave privada"
caso senha-literal  app.yaml  "$(a pass word): \"$(x 12 k)\"" "atribuição literal"
caso token-notion   mcp.json  "{\"auth\": \"$(a ntn _)$(x 44 c)\"}" "token de integração do Notion"
caso vin-aberto     log.csv   "vin,odometro
$(a LGW EF6A5 XR)H123456,12345" "VIN sem máscara"
caso gps-coluna     viagem.csv "tempo,latitude,longitude,soc
1,0,0,80" "coluna de GPS"
caso gps-valores    viagem.csv "tempo,a,b,soc
1,$(a -23. 550520),$(a -46. 633308),80" "par de coordenadas"
caso arquivo-env    .env      "X=1" "arquivo .env"
caso keystore       upload.jks "binario-falso" "nunca entra"

# metade positiva: um diretório limpo tem de passar
limpo="$tmp/limpo"; mkdir -p "$limpo"
printf 'vin,odometro\nLGW**************,12345\n' > "$limpo/log.csv"
printf 'const preco = 129900; // centavos\n' > "$limpo/a.dart"
if bash "$VARREDURA" "$limpo" >/dev/null 2>&1; then
  echo "ok: diretório limpo passou"
else
  echo "FALHOU: diretório limpo foi reprovado (falso positivo)"; bash "$VARREDURA" "$limpo"; falhas=$((falhas + 1))
fi

[ "$falhas" -eq 0 ] && { echo "testar_varredura: TODOS OS CASOS OK"; exit 0; }
echo "testar_varredura: $falhas caso(s) com problema"; exit 1

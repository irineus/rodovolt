#!/usr/bin/env bash
# tool/varrer_segredos.sh — portão de segredos e de dados pessoais do carro.
#
# Varre os arquivos versionados (git ls-files) — ou os do diretório passado como argumento —
# atrás de:
#   1. arquivos que nunca podem entrar (keystore, .env, google-services.json...);
#   2. padrões de credencial (tokens GitHub/Google/AWS/Anthropic/OpenAI/Notion/Slack, chave
#      privada, JWT, atribuição de senha/token/segredo com valor literal);
#   3. dados reais do carro: VIN de 17 caracteres sem máscara e coordenadas GPS em fixtures.
#
# Sai 0 se limpo, 1 se achou algo (lista arquivo:linha e o motivo, sem repetir o valor
# inteiro do segredo). O par `tool/testar_varredura.sh` é a prova negativa: monta segredos
# FALSOS em tempo de execução e exige que este script reprove.
#
# Uso:
#   bash tool/varrer_segredos.sh            # arquivos versionados do repo
#   bash tool/varrer_segredos.sh <dir>      # todos os arquivos de <dir> (usado no teste)
set -uo pipefail

ESTE_SCRIPT="tool/varrer_segredos.sh"
achados=0

reportar() { # $1 = arquivo:linha, $2 = motivo
  printf 'SEGREDO? %s — %s\n' "$1" "$2"
  achados=$((achados + 1))
}

if [ $# -ge 1 ]; then
  base="$1"
  mapfile -t arquivos < <(cd "$base" && find . -type f -not -path './.git/*' | sed 's|^\./||')
else
  base="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "ERRO: fora de um repo git e sem diretório" >&2; exit 2; }
  mapfile -t arquivos < <(cd "$base" && git ls-files)
fi

# ---------------------------------------------------------- 1. nomes proibidos
for f in "${arquivos[@]}"; do
  case "$(basename "$f")" in
    *.jks|*.keystore|*.p12|*.pem|*.key|key.properties|google-services.json|GoogleService-Info.plist|settings.local.json)
      reportar "$f" "tipo de arquivo que nunca entra no repo" ;;
    .env|.env.*)
      reportar "$f" "arquivo .env" ;;
  esac
done

# ------------------------------------------------------- 2. padrões de segredo
# Formato: "regex<TAB>motivo". Regex em ERE do GNU grep, sensível a maiúsculas.
padroes=$(cat <<'EOF'
gh[pousr]_[A-Za-z0-9]{36,}	token do GitHub
github_pat_[A-Za-z0-9_]{60,}	token fine-grained do GitHub
AIza[0-9A-Za-z_-]{35}	chave de API do Google
AKIA[0-9A-Z]{16}	chave de acesso AWS
sk-ant-[A-Za-z0-9_-]{20,}	chave da API da Anthropic
sk-(proj-)?[A-Za-z0-9]{32,}	chave de API estilo OpenAI
(secret_[A-Za-z0-9]{43}|ntn_[A-Za-z0-9]{40,})	token de integração do Notion
xox[abprs]-[A-Za-z0-9-]{10,}	token do Slack
-----BEGIN ([A-Z]+ )?PRIVATE KEY-----	chave privada
eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}	JWT
(senha|password|passwd|secret|segredo|token|api_?key|apikey)["']?[[:space:]]*[:=][[:space:]]*["'][^"'[:space:]]{8,}["']	atribuição literal de credencial
EOF
)

for f in "${arquivos[@]}"; do
  [ "$f" = "$ESTE_SCRIPT" ] && continue
  caminho="$base/$f"
  [ -f "$caminho" ] || continue
  grep -Iq . "$caminho" 2>/dev/null || continue   # pula binário e vazio
  while IFS=$'\t' read -r regex motivo; do
    [ -z "$regex" ] && continue
    while IFS= read -r linha; do
      [ -n "$linha" ] && reportar "$f:$linha" "$motivo"
    done < <(grep -nIE -- "$regex" "$caminho" 2>/dev/null | cut -d: -f1)
  done <<< "$padroes"
done

# ------------------------------------------------ 3. dados reais do carro
# VIN: 17 caracteres [A-HJ-NPR-Z0-9] (sem I, O, Q), com ao menos um dígito e uma letra,
# delimitado. Máscara aceita: qualquer '*' dentro dos 17 (ex.: LGW**************).
for f in "${arquivos[@]}"; do
  [ "$f" = "$ESTE_SCRIPT" ] && continue
  caminho="$base/$f"
  [ -f "$caminho" ] || continue
  grep -Iq . "$caminho" 2>/dev/null || continue
  while IFS= read -r ocorr; do
    n="${ocorr%%:*}"; vin="${ocorr#*:}"
    if [[ "$vin" =~ [0-9] && "$vin" =~ [A-Z] ]]; then
      reportar "$f:$n" "VIN sem máscara (${vin:0:3}…)"
    fi
  done < <(grep -noE '(^|[^A-Za-z0-9])[A-HJ-NPR-Z0-9]{17}([^A-Za-z0-9]|$)' "$caminho" 2>/dev/null \
           | sed -E 's/^([0-9]+):[^A-HJ-NPR-Z0-9]?([A-HJ-NPR-Z0-9]{17}).*/\1:\2/')
done

# GPS: em CSV de fixture, coluna de coordenada no cabeçalho ou par lat,lon com 4+ decimais.
for f in "${arquivos[@]}"; do
  case "$f" in
    *.csv|*.CSV|*.tsv|*.txt|*.json|*.log)
      caminho="$base/$f"; [ -f "$caminho" ] || continue
      if head -n 5 "$caminho" | grep -qiE '(^|[,;	"])(lat|latitude|lon|lng|longitude|gps[^,;	]*)([,;	"]|$)'; then
        reportar "$f:1" "coluna de GPS no cabeçalho"
      fi
      while IFS= read -r n; do
        [ -n "$n" ] && reportar "$f:$n" "par de coordenadas GPS"
      done < <(grep -nE -- '-?[0-9]{1,2}\.[0-9]{4,}[[:space:]]*[,;	][[:space:]]*-?[0-9]{1,3}\.[0-9]{4,}' "$caminho" 2>/dev/null | cut -d: -f1 | head -n 5)
      ;;
  esac
done

echo "varredura: ${#arquivos[@]} arquivo(s) verificados em $base"
if [ "$achados" -gt 0 ]; then
  echo "REPROVADO: $achados achado(s). Remova o dado (e reescreva o histórico se já foi commitado)."
  exit 1
fi
echo "LIMPO: nenhum segredo, VIN sem máscara ou coordenada GPS encontrado."
exit 0

# Ambientes de desenvolvimento do SincroVolt

Três ambientes, cada um com um papel, no mesmo modelo do Desmalha. O que vale para os
três é o **verificador**: ele lê as versões que o repo declara (`.fvmrc`,
`tool/setup_env.sh`, `build.gradle.kts`) e diz se a máquina bate.

| Ambiente | Para quê | Como se monta |
|---|---|---|
| **Nuvem** (Claude Code, Ubuntu 24.04) | núcleo, `analyze`, testes, docs | ambiente `SincroVolt` com `tool/setup_env.sh` como setup script |
| **Windows** + Galaxy S26 Ultra | UI, hot reload, Bluetooth real com o ELM327 | seção 2 |
| **CI** (GitHub Actions, `verify`) | portão de merge | `.github/workflows/verify.yml` |

> ⚠️ **A versão do Flutter não muda aqui.** O pin vive no `.fvmrc` (**3.44.7**) e no
> `tool/setup_env.sh`; só muda por card registrado no board.

---

## 1. Nuvem (sessões do Claude Code)

**Ambiente:** `SincroVolt` (pessoal), criado em claude.ai/code → seletor de ambiente →
**New environment**.

| Campo | Valor |
|---|---|
| Name | `SincroVolt` |
| Network access | **Limited**, com **Allow package managers** marcado |
| Allowed domains | `drive.usercontent.google.com` |
| Environment variables | nenhuma |
| Setup script | conteúdo de `tool/setup_env.sh` (**Choose file**) |

**Por que esses hosts.** Medido num Ubuntu 24.04 limpo com proxy registrando cada
conexão (EVAPP-36): o bootstrap sem Android só acessa **`storage.googleapis.com`**
(tarball do Flutter) e **`pub.dev`** (FVM e pacotes), ambos no allowlist padrão do
"Allow package managers". O único host fora do padrão é
**`drive.usercontent.google.com`**, usado para baixar logs grandes do Drive (EVAPP-7).
GitHub passa pelo proxy próprio da sessão e o Notion é conector (não passa pelo
allowlist). O Flutter ainda tenta `www.google-analytics.com` (telemetria) e a falha é
inofensiva — não libere esse host.

Números da medição (16/11/2026): setup do zero **118 s** (abaixo do limite de ~5 min para
o ambiente entrar em cache); `pub get` dentro do repo 33 s; re-execução 2 s.

**O setup script roda antes da sessão, como root e sem o repo garantido.** Por isso o
`tool/setup_env.sh` tem todas as versões dentro dele, não depende do repo, e cria links em
`/usr/local/bin` para `flutter`, `dart` e `fvm`. O ambiente fica em cache por ~7 dias; mudar
o script ou os hosts reconstrói o cache.

⚠️ **Não defina `FVM_CACHE_PATH`.** O Flutter fica no cache padrão do FVM (`~/fvm`). Na
primeira versão do script, com `FVM_CACHE_PATH` customizado, uma shell sem a variável fez
o `fvm` clonar um segundo Flutter do `github.com` — medido no mesmo teste e corrigido.

Na sessão:
```
bash tool/setup_env.sh          # idempotente: no ambiente em cache só faz pub get
fvm dart run tool/verificar_ambiente.dart --sem-android
cd packages/sincrovolt_core && fvm dart test
cd apps/sincrovolt_app && fvm flutter analyze && fvm flutter test
```
Se um download falhar, o script para e diz o domínio. Reporte o domínio; não use mirror.

Build de APK na nuvem é opcional: `SINCROVOLT_COM_ANDROID=1 bash tool/setup_env.sh`
instala JDK 17 e Android SDK (precisa de `dl.google.com`, `maven.google.com` e
`services.gradle.org`, todos no allowlist padrão).

## 2. Windows + Galaxy S26 Ultra

Máquina de UI. O `tool/setup_env.sh` é só Linux; no Windows o SDK Android vem do Android
Studio. O passo a passo detalhado de instalação (JDK 17, Android Studio, FVM 4.1.2 por
binário, variáveis, plugins da IDE) é o mesmo do Desmalha (`docs/ambiente-windows.md`
daquele repo); se a máquina já roda o Desmalha, ela já roda o SincroVolt.

### 2.1 Conferir a máquina (PowerShell, na raiz do repo)

```powershell
fvm install
fvm dart run tool/verificar_ambiente.dart
```
Saída esperada no fim: `Ambiente OK — 0 aviso(s).` (avisos sobre o `flutter` do PATH
são aceitáveis se você sempre usa `fvm flutter`).

### 2.2 Galaxy S26 Ultra por depuração por Wi-Fi

Nomes de menu da One UI em PT-BR, conferidos num S26 Ultra (Android 17) em 16/11/2026.
Fora da Samsung o item costuma se chamar "Depuração sem fio".

1. No celular: **Configurações → Sobre o telefone → Informações do software** → toque 7
   vezes em **Número de compilação** (ativa as Opções do desenvolvedor).
2. **Configurações → Opções do desenvolvedor → Depuração → Depuração por Wi-Fi** → ligar
   (toque no texto, não só na chave, para abrir a tela). Celular e PC na mesma rede Wi-Fi.
3. Toque em **Parear o dispositivo com um código de pareamento**. Abre uma janela com o
   **código de 6 dígitos** (gerado pelo celular, muda a cada abertura) e um **IP:porta de
   pareamento**. Deixe a janela aberta.
4. No PowerShell, com o IP:porta **dessa janela**:
   ```powershell
   adb pair 192.168.1.2:39921
   ```
   Em `Enter pairing code:` digite os 6 dígitos. Esperado:
   `Successfully paired to 192.168.1.2:39921 [guid=adb-…]`.
5. Depois de pareado, o PC aparece em **Dispositivos pareados** como "Conectados no
   momento": o adb conecta sozinho (mDNS), **sem `adb connect`**. Confira:
   ```powershell
   adb devices
   ```
   Esperado: uma linha `adb-<serial>-<sufixo>._adb-tls-connect._tcp  device`.
   Se a lista vier vazia, conecte à mão pelo **Endereço IP e porta** do topo da tela
   **Depuração por Wi-Fi** (outra porta, a de conexão). Não faça os dois: o aparelho
   aparece duplicado e o `flutter run` passa a perguntar qual usar.
6. Conferir com o aparelho como alvo obrigatório:
   ```powershell
   fvm dart run tool/verificar_ambiente.dart --android
   ```
   Esperado no fim: `[ok]    Dispositivo Android: SM S948B (…)` e
   `Ambiente OK — 0 aviso(s).`

### 2.3 Rodar o app com hot reload

O Edge também aparece como dispositivo (web), então diga qual é o alvo. O `-d` aceita o
começo do id que o `adb devices` mostrou:

```powershell
cd apps\sincrovolt_app
fvm flutter run -d adb-
```
Com o app aberto no celular, edite `lib/main.dart` (ex.: o texto do título), salve e
aperte `r` no terminal. Esperado: `Reloaded 1 of N libraries in ...ms` e a mudança na tela
sem o app reiniciar. `R` faz hot restart; `q` sai.

Bluetooth Clássico com o ELM327 só funciona em aparelho real — nunca no emulador.

## 3. CI — `verify`

`.github/workflows/verify.yml` roda em todo PR e em push na `main`, num `ubuntu-24.04`:
bootstrap (`tool/setup_env.sh`), verificador `--sem-android`, prova negativa e varredura
de segredos, `analyze --fatal-infos` e testes do núcleo e do app. É o **portão de merge**:
PR com `verify` vermelho não entra.

Para virar portão de verdade, a `main` precisa de uma regra exigindo o check `verify`
(configuração do GitHub, feita pelo dono do repo).

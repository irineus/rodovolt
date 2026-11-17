# Convenções do SincroVolt

> **Estado:** provisório. As convenções oficiais são o card **EVAPP-22** (Fase 04), ainda
> não executado. Aqui está só o que **já foi decidido** em outros cards ou é regra
> permanente do `CLAUDE.md`. O resto está marcado como "a definir" com o card que decide.

## Já em vigor

| Assunto | Convenção | Origem |
|---|---|---|
| ID de card | `EVAPP-n` (board no Notion) | board |
| Branch | `evapp-<n>-<slug-curto>` (ex.: `evapp-35-repo-claude-md`) | skill do board |
| Commit | Conventional Commits; rodapé com `EVAPP-<n>` | skill do board |
| PR | Um PR por card; o card só fecha com PR aberto e merge oferecido | CLAUDE.md, regra 6 |
| Dinheiro | Centavos em `int`. Nunca `double`/float | CLAUDE.md, regra 5 |
| Pacote do app | `com.sincrovolt.app` | EVAPP-20 |
| Estrutura | `apps/sincrovolt_app` (Flutter) + `packages/sincrovolt_core` (Dart puro) | EVAPP-24 |
| Toolchain | Flutter pinado no `.fvmrc`; comandos sempre via `fvm` | EVAPP-24 |
| Dependências | Checagem de licença antes de entrar | CLAUDE.md, regra 8 |
| Fixtures | Sem GPS, VIN mascarado; logs brutos fora do repo | CLAUDE.md, regra 3 |

## A definir no EVAPP-22

- Idioma dos identificadores no código (PT-BR × inglês) e dos nomes de teste.
- Unidades internas de energia, distância, volume e tempo (inteiros e escala).
- Formato de data/hora persistida (civil × instante, fuso).
- Estilo de lint (`analysis_options.yaml`) e formatação.
- Estratégia de merge (squash × rebase) e proteção da `main`.
- Formato da máscara de VIN definitivo.

## A definir no EVAPP-23

- Taxonomia de eventos e categorias de custo.

---
name: proximo-card
description: Avança o board do Rodovolt (app de gestão de carros eletrificados) no Notion — próximo card, iniciar, concluir, bloquear, status do board, criar card. Use para "próximo card", "o que fazer agora", "concluí o card", "status do board" e qualquer pedido de consultar ou atualizar o board deste projeto.
---

# Board do Rodovolt no Notion

Versão de repositório da skill de conta `proximo-card-carros-eletrificados`. As duas
devem dizer a mesma coisa. **Se divergirem, vale esta (versionada no repo)**, salvo o que
a página Decisões vigentes disser em contrário; avise o usuário da divergência em uma
linha, para ele atualizar a skill da conta. Ex.: a skill da conta ainda chama o produto de
"Voltis" (nome superado no EVAPP-20) — use "Rodovolt".

Numa sessão aberta fora da pasta do repo, `/proximo-card` não aparece na lista de skills:
leia este arquivo direto.

**Pré-requisito:** ferramentas do Notion MCP na sessão. Se não aparecerem, procure-as
(tool search por "notion fetch", "notion query data sources", "notion update page",
"notion create pages"). Se ainda assim não existirem, diga: "o conector do Notion não
está habilitado nesta sessão" e pare. Nunca improvise o estado do board de memória.

## Identificadores fixos

| Item | Valor |
|---|---|
| Hub do projeto | `4192f3f4-b9b2-8191-85f0-d600496d3948` |
| **Decisões vigentes** | `4192f3f4-b9b2-815d-9edd-e62dd9777e76` |
| Database (board) | `https://app.notion.com/p/4192f3f4b9b281599124d4424b911ba8` |
| **Data source** | `collection://4192f3f4-b9b2-8177-9778-000bee7e5444` |

Não confundir com o board do Desmalha. Nunca tocar em outro database do workspace.

## Leitura obrigatória antes de tudo

`notion-fetch` na página **Decisões vigentes**. Em conflito com o `CLAUDE.md`, com o
documento de concepção ou com a memória, **ela vence**. Se a leitura falhar, diga isso
antes de seguir.

## Propriedades do board (valores exatos — o Notion cria opção nova se não bater)

- `Card` (título); `ID` = `EVAPP-n` (na SQL: `"userDefined:ID"`, só o número, só leitura)
- `Ordem` (número, saltos de 10); `Fase`: "01. Concepção e Validação", "02. Prova de Conceito (Haval H6 GT)", "03. Análise e Requisitos", "04. Nomenclatura e Domínio", "05. Arquitetura", "06. Design (UX/UI)", "07. Setup e Infraestrutura", "08. Implementação — Núcleo e Backend", "09. Implementação — App Mobile", "10. Integrações e Automação", "11. Testes e Qualidade", "12. Lançamento", "13. Pós-lançamento"
- `Status`: "A fazer", "Em andamento", "Bloqueado", "Concluído"
- `Prioridade`: "Alta", "Média", "Baixa"; `Tipo`: "Pesquisa", "Decisão (ADR)", "Prova de conceito", "Especificação", "Implementação", "Teste", "Operação"
- `Onde`: "Claude.ai", "Claude Code", "No carro", "Externo"
- `Notas` (texto, resumo vivo), `PR` (url), `Concluído em` (data: `date:Concluído em:start`)

O corpo do card tem Objetivo, Escopo, **Critérios de aceite** (checklist = definição de
pronto) e Depende de.

## 1. Próximo card

Regra: "Em andamento" antes de tudo; depois "A fazer" de **menor Ordem** (a Ordem já
embute dependência e prioridade). Ignorar "Bloqueado" e "Concluído".

```sql
SELECT url, "userDefined:ID" AS id, "Ordem", "Card", "Fase", "Status", "Prioridade", "Tipo", "Onde", "Notas"
FROM "collection://4192f3f4-b9b2-8177-9778-000bee7e5444"
WHERE "Status" IN ('A fazer', 'Em andamento')
ORDER BY CASE "Status" WHEN 'Em andamento' THEN 0 ELSE 1 END, "Ordem" ASC
LIMIT 5
```

Depois `notion-fetch` no primeiro card. Apresentar `EVAPP-n — título`, Fase, Tipo, Onde,
objetivo e critérios de aceite; os 2–3 seguintes em uma linha. Avisar se o "Onde" não
combina com esta ferramenta e se algum "Depende de" não está concluído (oferecer
Bloqueado). Perguntar se marca "Em andamento"; se sim, atualizar e renomear a sessão.

## 2. Executar

- **Claude Code:** branch `evapp-<n>-<slug>`; Conventional Commits com `EVAPP-<n>` no
  rodapé; seguir o `CLAUDE.md`. Antes de dar por pronto: análise estática, testes e build
  verdes **na sessão**, `tool/varrer_segredos.sh` limpo e todo teste-portão novo visto
  falhando uma vez. Abrir o PR e oferecer o merge.
- **No carro:** passo a passo curto e numerado; **só comandos OBD de leitura** — nunca modo
  `04`, escrita, codificação ou reset de módulo.
- **Claude.ai / Externo:** o resultado vai para a página de Resultado do card.

## 3. Concluir (sempre, sem o usuário pedir)

1. Conferir os critérios de aceite um a um. Critério pendente = card não concluído: dizer
   o que falta e manter "Em andamento" (estado de sessão `parcial`) ou propor card novo.
2. Marcar no corpo os critérios atendidos (`update_content`, `- [ ]` → `- [x]`).
3. Resultado longo: subpágina **"Resultado: título (mm/aaaa)"** com
   `parent: {page_id: <id do card>}`. Nunca página solta na raiz.
4. Card: `Notas` (1–3 linhas + link), `Status = "Concluído"`, `date:Concluído em:start` =
   hoje, `PR` = link do PR. **Notas é sobrescrito**: ler o valor atual e reenviar completo.
5. **Decisões vigentes** com `update_content` (nunca `replace_content`), na seção certa
   (1 Produto, 2 Arquitetura e stack, 3 Fontes de dados, 4 Regras de negócio, 5 Riscos,
   6 Pendências, 7 Decisões superadas), com data e `EVAPP-n`; decisão substituída vai para
   "Decisões superadas" com o motivo; sempre uma linha em "Histórico".
6. Propagar: cards futuros afetados ganham nota de reescopo; cards bloqueados por este
   podem voltar a "A fazer".
7. Renomear a sessão; oferecer PR e merge; parar e dizer qual seria o próximo card.

## 4. Status do board

```sql
SELECT "Fase", COUNT(*) AS total,
  SUM(CASE WHEN "Status" = 'Concluído' THEN 1 ELSE 0 END) AS concluidos,
  SUM(CASE WHEN "Status" = 'Em andamento' THEN 1 ELSE 0 END) AS andamento,
  SUM(CASE WHEN "Status" = 'Bloqueado' THEN 1 ELSE 0 END) AS bloqueados
FROM "collection://4192f3f4-b9b2-8177-9778-000bee7e5444"
GROUP BY "Fase" ORDER BY "Fase"
```

## 5. Criar card

`notion-create-pages` com `parent: {data_source_id: "4192f3f4-b9b2-8177-9778-000bee7e5444"}`.
Ordem livre entre o card de que depende e o seguinte (conferir antes); Notas com
`Origem: EVAPP-n`; corpo com Objetivo, Critérios de aceite e Depende de. No markdown do
Notion, não escrever palavra entre sinais de menor/maior (vira tag).

## 6. Bloquear

`Status = "Bloqueado"` e Notas começando por `BLOQUEADO por: <motivo ou EVAPP-n>`.

## Nome da sessão

Formato: `Rodovolt · EVAPP-n — <título curto> (<estado>)`, estados `em andamento`,
`concluído`, `bloqueado`, `parcial`. Sessão sem card: `Rodovolt · <o que foi feito>`.
Renomear com `get_session`/`set_session_title` quando existirem; senão, sugerir o título
ao usuário em uma linha no fim da resposta.

## Proibições

Nunca deletar cards. Nunca tocar em outros databases. Segredos nunca no Notion, no repo
ou em sessão de nuvem. IDs de página em UUID hifenizado nas atualizações.

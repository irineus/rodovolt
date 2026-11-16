# Rodovolt

App mobile de gestão de carros eletrificados (BEV, PHEV e HEV) no Brasil: anota recargas,
abastecimentos e manutenção, lê o carro pelo OBD-II (só leitura) e calcula custo, consumo e
saúde da bateria. Android-primeiro, em Flutter.

- **Planejamento:** board e Decisões vigentes no Notion (projeto "App Carros Eletrificados").
- **Trabalhar no repo:** leia o [`CLAUDE.md`](CLAUDE.md); no Claude Code, `/proximo-card`.
- **Ambiente:** [`docs/ambiente.md`](docs/ambiente.md) — nuvem, Windows com o Galaxy S26 e CI.
- **Convenções e glossário:** [`docs/convencoes.md`](docs/convencoes.md),
  [`docs/glossario.md`](docs/glossario.md).

Repositório **público**. Segredos, logs brutos do carro, VIN e localização nunca entram aqui
(`tool/varrer_segredos.sh` barra no CI).

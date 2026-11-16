# Glossário do Rodovolt

> **Estado:** provisório. O glossário oficial (linguagem ubíqua) é o card **EVAPP-21**
> (Fase 04), ainda não executado. Abaixo, só os termos que **já aparecem em decisões
> registradas** (Decisões vigentes, EVAPP-6, EVAPP-7, EVAPP-24). O EVAPP-21 revisa esta
> lista, decide o nome em PT-BR de cada conceito no código e na UI, e remove esta nota.

## Veículo e tipos

| Termo | Significado | Origem |
|---|---|---|
| BEV | Veículo 100% elétrico a bateria | concepção |
| PHEV | Híbrido plug-in (recarrega na tomada) — ex.: Haval H6 GT | concepção |
| HEV | Híbrido não plugável | concepção |
| VIN | Número de identificação do veículo (17 caracteres). Em fixture, sempre mascarado | EVAPP-6 |

## Bateria (BMS)

| Termo | Significado | Origem |
|---|---|---|
| BMS | Sistema de gerenciamento da bateria de tração | EVAPP-7 |
| SoC | Estado de carga (% da capacidade atual). No OBD padrão: PID `5B` | EVAPP-7 |
| SoH | Estado de saúde (% da capacidade original) — lido do BMS do H6 GT | EVAPP-7 |
| SoE | Estado de energia (energia disponível) | EVAPP-7 |
| Célula / módulo | H6 GT: 84 células em 6 módulos × 14 | EVAPP-7 |

## OBD-II e adaptador

| Termo | Significado | Origem |
|---|---|---|
| OBD-II | Porta e protocolo de diagnóstico. **Uso só de leitura** no Rodovolt | concepção |
| ELM327 | Chip/adaptador que traduz comandos AT e OBD; o de referência é o KONNWEI v1.5 | EVAPP-6 |
| PID | Identificador de parâmetro lido do carro (ex.: `01A6` = hodômetro, `9A` = tensão/corrente) | EVAPP-6/7 |
| Modo 22 | Leitura de dados proprietários por identificador (UDS ReadDataByIdentifier) | EVAPP-7 |
| SPP | Perfil serial do Bluetooth Clássico (RFCOMM), usado pelo ELM327 | EVAPP-24 |
| BLE | Bluetooth de baixa energia | EVAPP-24 |
| DTC | Código de falha. **Ler** é permitido; apagar (modo `04`) é proibido | concepção |
| ECM / VCU / HCU / OBC | Módulos: motor, veículo, híbrido, carregador embarcado | EVAPP-7 |

## A definir no EVAPP-21

- Recarga × carga × abastecimento (termo único no código e na UI).
- Evento, Viagem, Trajeto, Sessão de recarga.
- Custo, tarifa, preço por kWh, preço por litro.
- Fonte de dados / conector / camada.
- Leitura de bateria, perfil de PIDs.

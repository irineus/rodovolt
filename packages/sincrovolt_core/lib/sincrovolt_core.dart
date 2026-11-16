/// Núcleo do SincroVolt em Dart puro (decisão do EVAPP-24).
///
/// Aqui entram o parser ELM327/PIDs, o motor de custos e as regras de negócio, todos
/// testáveis com `dart test` sem Android SDK. O app (`apps/sincrovolt_app`) só orquestra e
/// apresenta. Esqueleto criado no EVAPP-36: ainda sem lógica de domínio.
library;

/// Identificador do pacote, usado pelo teste de fumaça do esqueleto.
const String nomeDoNucleo = 'sincrovolt_core';

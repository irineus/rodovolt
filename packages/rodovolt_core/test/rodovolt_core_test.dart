import 'package:rodovolt_core/rodovolt_core.dart';
import 'package:test/test.dart';

void main() {
  test('o núcleo carrega sem Flutter', () {
    expect(nomeDoNucleo, 'PROVA NEGATIVA — este teste tem de falhar no CI');
  });
}

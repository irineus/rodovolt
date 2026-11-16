import 'package:rodovolt_core/rodovolt_core.dart';
import 'package:test/test.dart';

void main() {
  test('o núcleo carrega sem Flutter', () {
    expect(nomeDoNucleo, 'rodovolt_core');
  });
}

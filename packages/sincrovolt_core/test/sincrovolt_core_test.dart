import 'package:sincrovolt_core/sincrovolt_core.dart';
import 'package:test/test.dart';

void main() {
  test('o núcleo carrega sem Flutter', () {
    expect(nomeDoNucleo, 'sincrovolt_core');
  });
}

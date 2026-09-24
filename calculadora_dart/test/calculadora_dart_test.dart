import 'package:calculadora_dart/calculadora_dart.dart';
import 'package:test/test.dart';

void main() {
  test('Evaluar expresión combinada con jerarquía', () {
    // 4 - 5 + (3 * 6) = 4 - 5 + 18 = 17
    expect(evaluarExpresion('4 - 5 + 3 * 6'), 17);
  });

  test('Evaluar expresión con paréntesis', () {
    // (4 - 5 + 3) * 6 = 2 * 6 = 12
    expect(evaluarExpresion('(4 - 5 + 3) * 6'), 12);
  });

  test('Prueba de división simple', () {
    expect(evaluarExpresion('20 / 4'), 5.0);
  });
} 
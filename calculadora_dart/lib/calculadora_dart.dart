import 'package:expressions/expressions.dart';

double sumar(double a, double b) => a + b;
double restar(double a, double b) => a - b;
double multiplicar(double a, double b) => a * b;

double dividir(double a, double b) {
  if (b == 0) {
    throw ArgumentError('Error: No es posible dividir entre cero.');
  }
  return a / b;
}

/// Evalúa una cadena de texto matemática respetando precedencia de operadores
num evaluarExpresion(String formula) {
  // Limpiar espacios y preparar la expresión
  final expression = Expression.parse(formula);
  const evaluator = ExpressionEvaluator();
  
  final resultado = evaluator.eval(expression, {});
  
  if (resultado is num) {
    if (resultado.isInfinite || resultado.isNaN) {
      throw ArgumentError('Error matemático: División entre cero.');
    }
    return resultado;
  }
  
  throw ArgumentError('No se pudo resolver la expresión.');
} 
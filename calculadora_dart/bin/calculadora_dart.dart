import 'dart:io';
import 'package:calculadora_dart/calculadora_dart.dart' as calc;

void limpiarPantalla() {
  stdout.write('\x1B[2J\x1B[0;0H');
}

void renderizarInterfaz(String usuario, String pantalla, {List<String>? historial}) {
  limpiarPantalla();
  
  // Limitar y alinear texto del display a 19 caracteres
  String display = pantalla.length > 19 
      ? pantalla.substring(pantalla.length - 19) 
      : pantalla.padLeft(19);

  // Colores ANSI
  const reset = '\x1B[0m';
  const cyan = '\x1B[36m';
  const pink = '\x1B[32m';
  const yellow = '\x1B[33m';
  const gray = '\x1B[90m';

  print('$cyan╔══════════════════════════════════════════════╗$reset');
  print('$cyan║           CALCULADORA ANA  v1.0         ║$reset');
  print('$cyan╚══════════════════════════════════════════════╝$reset');
  print('$gray Sesión activa:$reset $yellow$usuario$reset\n');

  print('''  .-----------------------.
  |  ___________________  |
  | | $pink$display$reset | |
  | |___________________| |
  |  ___  ___  ___   ___  |
  | [ 7 ][ 8 ][ 9 ] [ + ] |
  | [ 4 ][ 5 ][ 6 ] [ - ] |
  | [ 1 ][ 2 ][ 3 ] [ * ] |
  | [ . ][ 0 ][ = ] [ / ] |
  '-----------------------'
''');

  if (historial != null && historial.isNotEmpty) {
    print('$gray── Últimos cálculos ────────────────────────$reset');
    for (var item in historial.reversed.take(3)) {
      print(' $gray•$reset $item');
    }
    print('');
  }
}

void main(List<String> arguments) {
  limpiarPantalla();
  print('╔══════════════════════════════════════════════╗');
  print('║           CALCULADORA ANA v1.0         ║');
  print('╚══════════════════════════════════════════════╝\n');

  bool sesionActiva = true;

  while (sesionActiva) {
    stdout.write('Ingrese su nombre para iniciar sesión (o "salir"): ');
    String nombre = stdin.readLineSync()?.trim() ?? '';

    if (nombre.toLowerCase() == 'salir') {
      print('\nCerrando aplicación...');
      break;
    }

    if (nombre.isEmpty) nombre = 'Desarrollador';
    
    List<String> historial = [];
    bool operando = true;

    while (operando) {
      renderizarInterfaz(nombre, historial.isEmpty ? '0' : historial.last.split('=').last.trim(), historial: historial);

      print('Opciones:');
      print(' [1] Resolver expresión matemática (ej: 4 - 5 + 3 * 6)');
      print(' [2] Cambiar de usuario');
      print(' [3] Salir');
      stdout.write('\nSeleccione una opción: ');

      String? opcion = stdin.readLineSync()?.trim();

      if (opcion == '3') {
        operando = false;
        sesionActiva = false;
        limpiarPantalla();
        print('¡Hasta luego, $nombre!\n');
        break;
      }

      if (opcion == '2') {
        operando = false;
        limpiarPantalla();
        break;
      }

      if (opcion == '1') {
        stdout.write('\nIngrese la fórmula: ');
        String expresion = stdin.readLineSync()?.trim() ?? '';

        if (expresion.isEmpty) continue;

        try {
          final res = calc.evaluarExpresion(expresion);
          historial.add('$expresion = $res');
        } catch (e) {
          renderizarInterfaz(nombre, 'ERR: SYNTAX', historial: historial);
          print('\x1B[31m[!] Error en la expresión:\x1B[0m $e');
          stdout.write('\nPresione ENTER para continuar...');
          stdin.readLineSync();
        }
      }
    }
  }
} 
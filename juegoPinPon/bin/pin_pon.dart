// main.dart
import 'dart:async';
import 'dart:io';

import 'package:pin_pon/dificultad.dart';
import 'package:pin_pon/entities.dart';
import 'package:pin_pon/game_config.dart';
import 'package:pin_pon/iapingpong.dart';
import 'package:pin_pon/input.dart';
import 'package:pin_pon/pin_pon.dart';
import 'package:pin_pon/render.dart';

void main() {
  // Limpiar pantalla y ocultar cursor al iniciar
  stdout.write('\x1B[2J\x1B[?25l');

  stdout.write(saludo());

  // Mostrar menú con la opción de salida
  print('\n=== SELECCIONA EL MODO DE JUEGO ===');
  print('1. Jugador vs Jugador (Local)');
  print('2. Jugador vs Computadora (IA)');
  print('3. Salir del juego');
  stdout.write('Elige una opción (1, 2 o 3): ');

  String? opcion = stdin.readLineSync()?.trim();

  if (opcion == '3' || opcion == null) {
    restaurarTerminal();
    print('\n¡Saliendo del juego. Hasta luego!\n');
    exit(0);
  }

  bool modoIA = (opcion == '2');

  // Limpiar pantalla de nuevo para arrancar limpio
  stdout.write('\x1B[2J');

  final ia = IAPingPong(Dificultad.facil);

  final pelota = Pelota(x: GameConfig.ancho ~/ 2, y: GameConfig.alto ~/ 2);

  final j1 = Paleta(x: 2, y: 8, alto: GameConfig.tamanoPaleta);
  final j2 = Paleta(
    x: GameConfig.ancho - 3,
    y: 8,
    alto: GameConfig.tamanoPaleta,
  );

  int puntajeJ1 = 0;
  int puntajeJ2 = 0;

  // Bandera para controlar la pausa
  bool enPausa = false;

  // Manejo de controles
  configurarTeclado((tecla) {
    // Si está en pausa, solo permite reanudar con 'p' o salir con 'q'
    if (tecla == 'p') {
      enPausa = !enPausa;
      return;
    }

    if (tecla == 'q') {
      restaurarTerminal();
      print('\n¡Juego terminado!\n');
      exit(0);
    }

    // Si está pausado, ignoramos el movimiento de las paletas
    if (enPausa) return;

    if (tecla == 'w') j1.moverArriba();
    if (tecla == 's') j1.moverAbajo(GameConfig.alto);

    if (!modoIA) {
      if (tecla == 'i') j2.moverArriba();
      if (tecla == 'k') j2.moverAbajo(GameConfig.alto);
    }
  });

  Timer.periodic(GameConfig.frameRate, (timer) {
    // Si el juego está en pausa, no ejecutamos la lógica ni redibujamos
    if (enPausa) return;

    // 1. Mover pelota
    pelota.mover();

    // 2. Si está activo el modo IA, la computadora mueve la Paleta 2
    if (modoIA) {
      ia.moverPaleta(j2, pelota);
    }

    // 3. Colisiones
    if (pelota.y <= 0 || pelota.y >= GameConfig.alto - 1) {
      pelota.rebotarY();
    }

    if (pelota.x == j1.x + 1 &&
        (pelota.y >= j1.y && pelota.y < j1.y + j1.alto)) {
      pelota.rebotarX();
    }

    if (pelota.x == j2.x - 1 &&
        (pelota.y >= j2.y && pelota.y < j2.y + j2.alto)) {
      pelota.rebotarX();
    }

    if (pelota.x <= 0) {
      puntajeJ2++;
      pelota.reiniciar(GameConfig.ancho ~/ 2, GameConfig.alto ~/ 2);
    } else if (pelota.x >= GameConfig.ancho - 1) {
      puntajeJ1++;
      pelota.reiniciar(GameConfig.ancho ~/ 2, GameConfig.alto ~/ 2);
    }

    Renderer.dibujar(pelota, j1, j2, puntajeJ1, puntajeJ2);
  });
}

void restaurarTerminal() {
  stdout.write('\x1B[?25h'); // Mostrar cursor
  stdin.lineMode = true;
  stdin.echoMode = true;
}

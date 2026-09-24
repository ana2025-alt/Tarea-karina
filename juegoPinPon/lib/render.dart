// renderer.dart
import 'dart:io';

import 'entities.dart';
import 'game_config.dart';

class Renderer {
  static void dibujar(Pelota pelota, Paleta j1, Paleta j2, int p1, int p2) {
    final buffer = StringBuffer();

    // Mover cursor al origen (1,1) sin parpadeo
    buffer.write('\x1B[H');

    // Color base morado para la mesa
    buffer.write('\x1B[35m');

    // Marcador elegante
    buffer.writeln(
      '  JUGADOR 1: $p1  VS  JUGADOR 2: $p2  '.padLeft(
        20 + (GameConfig.ancho ~/ 2),
      ),
    );

    // Borde superior con esquinas estilizadas
    buffer.writeln('╔${'═' * (GameConfig.ancho - 2)}╗');

    for (int y = 0; y < GameConfig.alto; y++) {
      buffer.write('║'); // Borde lateral izquierdo
      for (int x = 1; x < GameConfig.ancho - 1; x++) {
        if (x == pelota.x && y == pelota.y) {
          buffer.write('\x1B[33mO\x1B[35m'); // Pelota amarilla
        } else if (x == j1.x && y >= j1.y && y < j1.y + j1.alto) {
          buffer.write('\x1B[32m█\x1B[35m'); // Paleta 1 sólida verde
        } else if (x == j2.x && y >= j2.y && y < j2.y + j2.alto) {
          buffer.write('\x1B[36m█\x1B[35m'); // Paleta 2 sólida cian
        } else if (x == GameConfig.ancho ~/ 2) {
          buffer.write('│'); // Red central punteada
        } else {
          buffer.write(' ');
        }
      }
      buffer.writeln('║'); // Borde lateral derecho
    }

    // Borde inferior con esquinas estilizadas
    buffer.writeln('╚${'═' * (GameConfig.ancho - 2)}╝');

    // Restaurar colores de la terminal
    buffer.write('\x1B[0m');

    stdout.write(buffer.toString());
  }
}

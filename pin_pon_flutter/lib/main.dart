import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const PinPonApp());
}

enum ModoJuego { unJugador, dosJugadores }

enum Dificultad {
  facil(velocidadBase: 0.006, velocidadIa: 0.005),
  medio(velocidadBase: 0.010, velocidadIa: 0.009),
  dificil(velocidadBase: 0.016, velocidadIa: 0.014);

  final double velocidadBase;
  final double velocidadIa;
  const Dificultad({required this.velocidadBase, required this.velocidadIa});
}

class DatosPartida {
  final String nombreJugador1;
  final String nombreJugador2;
  final ModoJuego modo;
  final Dificultad dificultad;

  DatosPartida({
    required this.nombreJugador1,
    required this.nombreJugador2,
    required this.modo,
    required this.dificultad,
  });
}

class PinPonApp extends StatelessWidget {
  const PinPonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pin Pon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const MenuScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// MENÚ DE CONFIGURACIÓN
// ---------------------------------------------------------------------------
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _j1Controller = TextEditingController(
    text: 'Jugador 1',
  );
  final TextEditingController _j2Controller = TextEditingController(
    text: 'Jugador 2',
  );
  ModoJuego _modo = ModoJuego.unJugador;
  Dificultad _dificultad = Dificultad.medio;

  @override
  void dispose() {
    _j1Controller.dispose();
    _j2Controller.dispose();
    super.dispose();
  }

  void _iniciar() {
    if (!_formKey.currentState!.validate()) return;

    final datos = DatosPartida(
      nombreJugador1: _j1Controller.text.trim(),
      nombreJugador2: _modo == ModoJuego.unJugador
          ? 'Computadora'
          : _j2Controller.text.trim(),
      modo: _modo,
      dificultad: _dificultad,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen(datos: datos)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pin Pon Flutter'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Configura la Partida',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Modo de Juego',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SegmentedButton<ModoJuego>(
                  segments: const [
                    ButtonSegment(
                      value: ModoJuego.unJugador,
                      label: Text('1P vs PC'),
                    ),
                    ButtonSegment(
                      value: ModoJuego.dosJugadores,
                      label: Text('2 Jugadores'),
                    ),
                  ],
                  selected: {_modo},
                  onSelectionChanged: (val) =>
                      setState(() => _modo = val.first),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _j1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Nombre Jugador 1 (Abajo: Teclas A / D)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person, color: Colors.cyanAccent),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa un nombre'
                      : null,
                ),
                const SizedBox(height: 16),
                if (_modo == ModoJuego.dosJugadores) ...[
                  TextFormField(
                    controller: _j2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Nombre Jugador 2 (Arriba: Teclas J / L)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person, color: Colors.redAccent),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingresa un nombre'
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Dificultad de la Pelota',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Dificultad>(
                  value: _dificultad,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  dropdownColor: const Color(0xFF1E293B),
                  items: Dificultad.values.map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Text(d.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (nueva) {
                    if (nueva != null) setState(() => _dificultad = nueva);
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'JUGAR',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _iniciar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TABLERO CON FÍSICAS ESTABLES Y CONTROL POR TECLADO
// ---------------------------------------------------------------------------
class GameScreen extends StatefulWidget {
  final DatosPartida datos;
  const GameScreen({super.key, required this.datos});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final FocusNode _focusNode = FocusNode();

  final double paddleWidth = 0.28;
  final double ballSize = 16.0;
  final int puntosParaGanar = 5;

  double ballX = 0.5;
  double ballY = 0.5;
  double ballVx = 0.008;
  double ballVy = 0.008;

  double p1X = 0.5;
  double p2X = 0.5;

  int p1Score = 0;
  int p2Score = 0;
  bool isPlaying = false;
  String? ganador;

  // Seguimiento de teclas pulsadas
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (isPlaying && ganador == null) {
        _procesarTeclado();
        _actualizarFisicas();
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _procesarTeclado() {
    const double paso = 0.018;

    // Jugador 1: Teclas A / D o flechas izquierda / derecha
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      p1X = (p1X - paso).clamp(paddleWidth / 2, 1.0 - (paddleWidth / 2));
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      p1X = (p1X + paso).clamp(paddleWidth / 2, 1.0 - (paddleWidth / 2));
    }

    // Jugador 2 (modo 2 jugadores): Teclas J / L
    if (widget.datos.modo == ModoJuego.dosJugadores) {
      if (_pressedKeys.contains(LogicalKeyboardKey.keyJ)) {
        p2X = (p2X - paso).clamp(paddleWidth / 2, 1.0 - (paddleWidth / 2));
      }
      if (_pressedKeys.contains(LogicalKeyboardKey.keyL)) {
        p2X = (p2X + paso).clamp(paddleWidth / 2, 1.0 - (paddleWidth / 2));
      }
    }
  }

  void _lanzarPelota({bool haciaP1 = true}) {
    ballX = 0.5;
    ballY = 0.5;
    final rand = Random();
    final vBase = widget.datos.dificultad.velocidadBase;

    ballVy = haciaP1 ? vBase : -vBase;
    final signo = rand.nextBool() ? 1.0 : -1.0;
    ballVx = signo * (vBase * (0.6 + rand.nextDouble() * 0.4));
  }

  void _actualizarFisicas() {
    setState(() {
      ballX += ballVx;
      ballY += ballVy;

      // 1. Rebote en paredes laterales
      if (ballX <= 0.02) {
        ballX = 0.02;
        ballVx = ballVx.abs();
      } else if (ballX >= 0.98) {
        ballX = 0.98;
        ballVx = -ballVx.abs();
      }

      // 2. IA para Jugador 2 en modo 1P
      if (widget.datos.modo == ModoJuego.unJugador) {
        final speedIa = widget.datos.dificultad.velocidadIa;
        if (p2X < ballX) {
          p2X = min(p2X + speedIa, ballX);
        } else if (p2X > ballX) {
          p2X = max(p2X - speedIa, ballX);
        }
        p2X = p2X.clamp(paddleWidth / 2, 1.0 - (paddleWidth / 2));
      }

      // 3. Colisión Paleta 1 (Abajo) con rebote seguro hacia arriba
      if (ballY >= 0.90 && ballY <= 0.93 && ballVy > 0) {
        final dist = ballX - p1X;
        if (dist.abs() <= paddleWidth / 2) {
          ballVy = -ballVy.abs(); // Asegura cambio de dirección inmediato
          ballVx =
              (dist / (paddleWidth / 2)) *
              widget.datos.dificultad.velocidadBase *
              1.1;
          ballY = 0.89; // Evita solapamiento repetitivo
        }
      }

      // 4. Colisión Paleta 2 (Arriba) con rebote seguro hacia abajo
      if (ballY <= 0.10 && ballY >= 0.07 && ballVy < 0) {
        final dist = ballX - p2X;
        if (dist.abs() <= paddleWidth / 2) {
          ballVy = ballVy.abs(); // Asegura rebote hacia abajo
          ballVx =
              (dist / (paddleWidth / 2)) *
              widget.datos.dificultad.velocidadBase *
              1.1;
          ballY = 0.11; // Evita solapamiento repetitivo
        }
      }

      // 5. Verificación de puntos
      if (ballY > 1.02) {
        p2Score++;
        if (p2Score >= puntosParaGanar) {
          _terminarPartida(widget.datos.nombreJugador2);
        } else {
          _lanzarPelota(haciaP1: true);
        }
      } else if (ballY < -0.02) {
        p1Score++;
        if (p1Score >= puntosParaGanar) {
          _terminarPartida(widget.datos.nombreJugador1);
        } else {
          _lanzarPelota(haciaP1: false);
        }
      }
    });
  }

  void _terminarPartida(String nombreGanador) {
    _ticker.stop();
    setState(() {
      isPlaying = false;
      ganador = nombreGanador;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('¡Fin del Juego!', textAlign: TextAlign.center),
        content: Text(
          '🏆 Ganador: $nombreGanador\n\nMarcador:\n${widget.datos.nombreJugador1}: $p1Score\n${widget.datos.nombreJugador2}: $p2Score',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Menú'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                p1Score = 0;
                p2Score = 0;
                ganador = null;
              });
              _togglePlay();
            },
            child: const Text('Revancha'),
          ),
        ],
      ),
    );
  }

  void _togglePlay() {
    if (isPlaying) {
      _ticker.stop();
      setState(() => isPlaying = false);
    } else {
      if (ganador != null) return;
      _lanzarPelota();
      if (!_ticker.isTicking) _ticker.start();
      setState(() => isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          _pressedKeys.add(event.logicalKey);
          if (event.logicalKey == LogicalKeyboardKey.space) {
            _togglePlay();
          }
        } else if (event is KeyUpEvent) {
          _pressedKeys.remove(event.logicalKey);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          title: Text(
            '${widget.datos.nombreJugador1} vs ${widget.datos.nombreJugador2}',
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.datos.nombreJugador2}: $p2Score',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'A $puntosParaGanar Pts',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  Text(
                    '${widget.datos.nombreJugador1}: $p1Score',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;

                  return Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020617),
                      border: Border.all(
                        color: Colors.cyan.withOpacity(0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(height: 1.5, color: Colors.white12),
                        ),

                        // Pelota
                        Positioned(
                          left: (ballX * w) - (ballSize / 2),
                          top: (ballY * h) - (ballSize / 2),
                          child: Container(
                            width: ballSize,
                            height: ballSize,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        // Paleta Superior
                        Positioned(
                          left: (p2X - paddleWidth / 2) * w,
                          top: h * 0.05,
                          child: Container(
                            width: paddleWidth * w,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),

                        // Paleta Inferior
                        Positioned(
                          left: (p1X - paddleWidth / 2) * w,
                          top: h * 0.92,
                          child: Container(
                            width: paddleWidth * w,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),

                        // Control táctil J2 (Arriba)
                        if (widget.datos.modo == ModoJuego.dosJugadores)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: h * 0.5,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onHorizontalDragUpdate: (d) {
                                if (!isPlaying) return;
                                setState(() {
                                  p2X = (p2X + d.delta.dx / w).clamp(
                                    paddleWidth / 2,
                                    1.0 - (paddleWidth / 2),
                                  );
                                });
                              },
                            ),
                          ),

                        // Control táctil J1 (Abajo)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: h * 0.5,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onHorizontalDragUpdate: (d) {
                              if (!isPlaying) return;
                              setState(() {
                                p1X = (p1X + d.delta.dx / w).clamp(
                                  paddleWidth / 2,
                                  1.0 - (paddleWidth / 2),
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
              child: ElevatedButton.icon(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(
                  isPlaying ? 'Pausar (Space)' : 'Jugar (Space)',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPlaying ? Colors.amber[800] : Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 14,
                  ),
                ),
                onPressed: _togglePlay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

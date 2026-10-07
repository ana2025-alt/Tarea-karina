# Prácticas en Dart & Flutter

Este repositorio contiene proyectos desarrollados como parte de las prácticas académicas, abarcando aplicaciones en consola con Dart y su evolución a entornos gráficos interactivos utilizando Flutter.

---

## 📁 Estructura del Repositorio

* **`calculadora_dart/`**: Aplicación de consola en Dart para operaciones matemáticas básicas.
* **`juegoPinPon/`**: Implementación original del clásico juego Pin Pon (Pong) ejecutado en consola mediante caracteres ASCII, selección de dificultad e IA autónoma.
* **`juego_pin_pon_flutter/`**: Versión gráfica, responsiva y multiplataforma del juego Pin Pon desarrollada con Flutter.

---

## 🏓 Juego Pin Pon (Versión Flutter)

Una adaptación gráfica del juego clásico que preserva toda la lógica original de consola, añadiendo soporte táctil, controles por teclado físico, aceleración progresiva de la pelota y selector interactivo de modos.

### ✨ Características Principales
* **Modos de Juego:**
  * **1P vs Computadora:** Enfréntate a la IA configurada con diferentes rangos de reacción.
  * **2 Jugadores (Local):** Modo competitivo en la misma pantalla/teclado.
* **Selector de Dificultad:**
  * **Fácil:** Velocidad reducida y mayor margen de error de la IA.
  * **Medio:** Ritmo de juego balanceado.
  * **Difícil:** Velocidad alta y reacción instantánea de la IA.
* **Físicas Dinámicas:** La pelota ajusta su ángulo según el punto de impacto en la paleta e incrementa su aceleración progresivamente en cada raquetazo.
* **Sistema de Victoria:** Partidas a 5 puntos con marcador en tiempo real y ventana de diálogo con opción de revancha o retorno al menú.

---

### 🎮 Controles de Juego

| Acción | Jugador 1 (Paleta Inferior / Azul) | Jugador 2 (Paleta Superior / Roja) |
| :--- | :---: | :---: |
| **Mover a la Izquierda** | Tecla `A` o Flecha `←` | Tecla `J` |
| **Mover a la Derecha** | Tecla `D` o Flecha `→` | Tecla `L` |
| **Control Táctil / Mouse** | Arrastrar en la mitad inferior | Arrastrar en la mitad superior |
| **Pausar / Reanudar** | `Barra Espaciadora` o botón en pantalla | `Barra Espaciadora` o botón en pantalla |

---

### 🚀 Cómo Ejecutar el Proyecto Flutter

1. Asegúrate de tener instalado el SDK de Flutter.
2. Ingresa a la carpeta del proyecto:
   ```bash
   cd juego_pin_pon_flutter 


   Descarga las dependencias:

Bash
flutter pub get 

Bash
flutter run -d chrome
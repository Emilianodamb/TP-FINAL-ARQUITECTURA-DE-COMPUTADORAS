# TP-FINAL-ARQUITECTURA-DE-COMPUTADORAS
# Detonación de Bomba con PIC16F84A (Assembler)

## Resumen

Trabajo Práctico Final desarrollado en **2025** para la materia **Arquitectura de Computadoras** de la **Universidad Nacional de Lanús (UNLa)**.

El proyecto consiste en el desarrollo de un programa en **Assembler** para el microcontrolador **PIC16F84A**, encargado de controlar un circuito electrónico simulado en **Proteus**.

Para el desarrollo del código se utilizó **MPLAB**, mientras que la simulación y validación del circuito se realizó en **Proteus**, permitiendo comprobar el funcionamiento del sistema antes de su ejecución sobre hardware real.

### Tecnologías utilizadas

* Assembler
* Microcontrolador PIC16F84A
* MPLAB IDE
* Proteus Design Suite

### Conceptos aplicados

* Arquitectura Harvard.
* Programación de microcontroladores.
* Manipulación de registros y puertos de entrada/salida (I/O).
* Configuración de puertos digitales.
* Control de periféricos mediante señales digitales.
* Manejo de displays de 7 segmentos.
* Lectura de entradas digitales (botón).
* Generación de retardos (delays) mediante ciclos de instrucción.
* Implementación de subrutinas.
* Tablas de búsqueda utilizando `RETLW`.
* Control del flujo de ejecución mediante saltos condicionales.
* Antirrebote (debouncing) por software.
* Simulación de circuitos electrónicos.

## Consigna

El objetivo del trabajo fue desarrollar un programa que controlara un circuito basado en un **PIC16F84A**, simulando la detonación de una bomba mediante una cuenta regresiva.

### Requisitos funcionales

* Esperar la pulsación de un botón para iniciar la secuencia.
* Mostrar una cuenta regresiva desde **9 hasta 0** en un display de 7 segmentos.
* Emitir un sonido corto antes de pasar al siguiente número de la cuenta.
* Activar la detonación al finalizar la cuenta regresiva.
* Mantener el sistema detenido después de la explosión, sin reiniciarse automáticamente.
* Respetar la asignación de pines del circuito provisto.
* Implementar toda la lógica en lenguaje Assembler para el PIC16F84A.

## Funcionamiento

Una vez presionado el botón de inicio, el microcontrolador verifica la señal para evitar rebotes (debouncing) y comienza la cuenta regresiva.

Durante cada segundo se muestra el número correspondiente en el display de 7 segmentos y se genera un pitido mediante un buzzer. Al llegar a cero, se activa el speaker simulando la explosión y el programa finaliza ejecutando la instrucción `SLEEP`, dejando el microcontrolador detenido hasta que se reinicie la alimentación del circuito.


/* ----------------------------------------------------------
* UNIVERSIDAD DEL VALLE DE GUATEMALA
* Organización de computadoras y Assembler
* Ciclo 1 - 2024
*
* NOMBRE:   main.s
* AUTORES:    June Herrera Watanabe 231038, Fernando Mendoza 19644, Jorge Chupina 22213
* FECHA:    mayo 26, 2024
* DESCRIPCIÓN:
*       Gusanito temario 12 Proyecto 4 Assembler.
 ------------------------------------------------------------- */

.syntax unified
.cpu cortex-m4
.thumb

.equ RCC_BASE, 0x40023800        // Dirección base del RCC
.equ AHB1ENR_OFFSET, 0x30        // Desplazamiento del registro de habilitación AHB1
.equ RCC_AHB1ENR, (RCC_BASE + AHB1ENR_OFFSET) // Dirección del registro de habilitación AHB1 del RCC
.equ GPIOA_EN, (1 << 0)          // Habilitar reloj para GPIOA (establecer bit 0)
.equ GPIOC_EN, (1 << 2)          // Habilitar reloj para GPIOC (establecer bit 2)
.equ GPIOA_BASE, 0x40020000      // Dirección base de GPIOA
.equ GPIOA_MODER, (GPIOA_BASE + 0x00)  // Desplazamiento del registro MODER de GPIOA
.equ GPIOA_ODR, (GPIOA_BASE + 0x14)  // Desplazamiento del registro ODR de GPIOA
.equ GPIOC_BASE, 0x40020800      // Dirección base de GPIOC
.equ GPIOC_MODER, (GPIOC_BASE + 0x00)  // Desplazamiento del registro MODER de GPIOC
.equ GPIOC_IDR, (GPIOC_BASE + 0x10)  // Desplazamiento del registro IDR de GPIOC
.equ GPIOC_PUPDR, (GPIOC_BASE + 0x0C) // Desplazamiento del registro PUPDR de GPIOC

.equ    DISP1, (1 << 6) | (1 << 4) | (1 << 1)
.equ    DISP2, (1 << 4) | (1 << 6) | (1 << 0)
.equ    DISP3, (1 << 6) | (1 << 0) | (1 << 9)
.equ    DISP4, (1 << 0) | (1 << 9) | (1 << 8)
.equ    DISP5, (1 << 9) | (1 << 8) | (1 << 7)
.equ    DISP6, (1 << 8) | (1 << 7) | (1 << 0)
.equ    DISP7, (1 << 7) | (1 << 0) | (1 << 1)
.equ    DISP8, (1 << 0) | (1 << 1) | (1 << 4)

.data
    gusanito: .word DISP1, DISP2, DISP3, DISP4, DISP5, DISP6, DISP7, DISP8  // Datos del patrón LED

.text
    .global __main

__main:
    ldr r0, =RCC_AHB1ENR            // Cargar la dirección de RCC_AHB1ENR en r0
    ldr r1, [r0]                    // Cargar el valor en la dirección encontrada en r0 en r1
    orr r1, #GPIOA_EN               // Habilitar reloj para GPIOA
    orr r1, #GPIOC_EN               // Habilitar reloj para GPIOC
    str r1, [r0]                    // Almacenar el contenido en r1 en la dirección encontrada en r0

    ldr r0, =GPIOA_MODER            // Cargar la dirección de GPIOA_MODER en r0
    ldr r1, [r0]                    // Cargar el valor actual de GPIOA_MODER en r1
    bic r1, r1, #(0x3 << 0)         // Limpiar bits 1:0 (PA0) para configurar como salida
    bic r1, r1, #(0x3 << 2)         // Limpiar bits 3:2 (PA1) para configurar como salida
    bic r1, r1, #(0x3 << 8)         // Limpiar bits 9:8 (PA4) para configurar como salida
    bic r1, r1, #(0x3 << 12)        // Limpiar bits 13:12 (PA6) para configurar como salida
    bic r1, r1, #(0x3 << 14)        // Limpiar bits 15:14 (PA7) para configurar como salida
    bic r1, r1, #(0x3 << 16)        // Limpiar bits 17:16 (PA8) para configurar como salida
    bic r1, r1, #(0x3 << 18)        // Limpiar bits 19:18 (PA9) para configurar como salida
    orr r1, r1, #(0x1 << 0)         // Configurar PA0 como salida (01)
    orr r1, r1, #(0x1 << 2)         // Configurar PA1 como salida (01)
    orr r1, r1, #(0x1 << 8)         // Configurar PA4 como salida (01)
    orr r1, r1, #(0x1 << 12)        // Configurar PA6 como salida (01)
    orr r1, r1, #(0x1 << 14)        // Configurar PA7 como salida (01)
    orr r1, r1, #(0x1 << 16)        // Configurar PA8 como salida (01)
    orr r1, r1, #(0x1 << 18)        // Configurar PA9 como salida (01)
    str r1, [r0]                    // Escribir el valor actualizado a GPIOA_MODER

    ldr r0, =GPIOC_MODER            // Cargar la dirección de GPIOC_MODER en r0
    ldr r1, [r0]                    // Cargar el valor actual de GPIOC_MODER en r1
    bic r1, r1, #(3 << 2)           // Limpiar bits 3:2 (PC1) para configurar como entrada (00)
    str r1, [r0]                    // Escribir el valor actualizado a GPIOC_MODER

    mov r4, #0                      // Inicializar r4 (índice para el arreglo gusanito) en 0

    b awaitbton                     // Saltar a la etiqueta awaitbton

awaitbton:
    ldr r0, =GPIOC_IDR              // Cargar la dirección de GPIOC_IDR en r0
    ldr r1, [r0]                    // Cargar el valor de GPIOC_IDR en r1
    tst r1, #(1 << 1)               // Probar el bit 1 (PC1) del valor leído
    bne btonDebounce                // Si el bit está activo, saltar a btonDebounce
    b awaitbton                     // Si no, repetir awaitbton

loop:
    ldr r0, =gusanito               // Cargar la dirección de gusanito en r0
    ldr r1, [r0, r4]                // Cargar el valor del arreglo gusanito en el índice r4 en r1

    ldr r0, =GPIOA_ODR              // Cargar la dirección de GPIOA_ODR en r0
    str r1, [r0]                    // Escribir el valor de r1 en GPIOA_ODR (actualizar LEDs)

    add r4, #4                      // Incrementar r4 (índice para gusanito)
    cmp r4, #32                     // Comparar r4 con 32
    bne delay                       // Si r4 no es 32, saltar a delay
    mov r4, #0                      // Si r4 es 32, reiniciarlo a 0

delay:
    ldr r5, =2000000                // Cargar 2000000 en r5 (contador de retardo)
    b delay_loop                    // Saltar a la etiqueta delay_loop

delay_loop:
    ldr r0, =GPIOC_IDR              // Cargar la dirección de GPIOC_IDR en r0
    ldr r1, [r0]                    // Cargar el valor de GPIOC_IDR en r1
    tst r1, #(1 << 1)               // Probar el bit 1 (PC1) del valor leído
    bne reiniciar                   // Si el bit está activo, saltar a reiniciar

    subs r5, #1                     // Restar 1 de r5
    bne delay_loop                  // Si r5 no es 0, saltar a delay_loop

    b loop                          // Saltar a la etiqueta loop (repetir proceso)



debounceDelay:
    subs r5, #1                     // Restar 1 de r5
    bne debounceDelay               // Si r5 no es 0, saltar a debounceDelay

    b loop                          // Saltar a la etiqueta loop

btonDebounce:
    ldr r5, =9000000                // Cargar 9000000 en r5 (contador de retardo)
    b debounceDelay                 // Saltar a debounceDelay

reiniciarDelay:
    subs r5, #1                     // Restar 1 de r5
    bne reiniciarDelay              // Si r5 no es 0, saltar a reiniciarDelay

    b awaitbton                     // Saltar a la etiqueta awaitbton

reiniciar:
    ldr r0, =GPIOA_ODR              // Cargar la dirección de GPIOA_ODR en r0
    mov r1, #0                      // Cargar 0 en r1
    str r1, [r0]                    // Escribir 0 en GPIOA_ODR para apagar todos los LEDs
    ldr r5, =5000000                // Cargar 5000000 en r5 (contador de retardo)
    mov r4, #0                      // Reiniciar r4 a 0
    b reiniciarDelay                // Saltar a reiniciarDelay

/* ----------------------------------------------------------
* UNIVERSIDAD DEL VALLE DE GUATEMALA
* Organización de computadoras y Assembler
* Ciclo 1 - 2024
*
* NOMBRE:   main.s
* AUTOR:    June Herrera Watanabe 231038
* FECHA:    mayo 8, 2024
* DESCRIPCIÓN:
*       Calcula las áreas de 3 circulos diferentes.
*
*       R0 apunta al inicio del arreglo de radios.
*       R1 apunta al inicio del arreglo resultados.
*       R2 es el contador del ciclo.
*		R3 es el valor de PI.
*		R4 guarda el valor del área por cada ciclo.
 ------------------------------------------------------------- */

.syntax unified
.cpu cortex-m4
.thumb

.equ RCC_BASE, 0x40023800        // Dirección base del RCC
.equ AHB1ENR_OFFSET, 0x30              // Desplazamiento del registro de habilitación AHB1
.equ RCC_AHB1ENR, (RCC_BASE + AHB1ENR_OFFSET) // Dirección del registro de habilitación AHB1 del RCC
.equ GPIOA_EN, (1 << 0)          // Habilitar reloj para GPIOA (establecer bit 0)
.equ GPIOC_EN, (1 << 2)          // Habilitar reloj para GPIOC (establecer bit 1)
.equ GPIOA_BASE, 0x40020000  // Base address of GPIOA
.equ GPIOA_MODER, (GPIOA_BASE + 0x00)  // Offset for GPIOA mode register
.equ GPIOA_ODR, (GPIOA_BASE + 0x14)  // Offset for GPIOA output data register
.equ GPIOC_BASE, 0x40020800  // Base address of GPIOC
.equ GPIOC_MODER, (GPIOC_BASE + 0x00)  // Offset for GPIOC mode register
.equ GPIOC_IDR, (GPIOC_BASE + 0x10)  // Offset for GPIOC input data register

.equ    DISP1,       (1 << 6) | (1 << 4) | (1 << 1)
.equ    DISP2,       (1 << 4) | (1 << 6) | (1 << 0)
.equ    DISP3,       (1 << 6) | (1 << 0) | (1 << 9)
.equ    DISP4,       (1 << 0) | (1 << 9) | (1 << 8)
.equ    DISP5,       (1 << 9) | (1 << 8) | (1 << 7)
.equ    DISP6,       (1 << 8) | (1 << 7) | (1 << 0)
.equ    DISP7,       (1 << 7) | (1 << 0) | (1 << 1)
.equ    DISP8,       (1 << 0) | (1 << 1) | (1 << 4)

.data
    gusanito: .word DISP1, DISP2, DISP3, DISP4, DISP5, DISP6, DISP7, DISP8  // LED pattern data

.text
    .global __main

__main:
	// Cargar la dirección de RCC_AHB1ENR en r0
    ldr r0, =RCC_AHB1ENR
    // Cargar el valor en la dirección encontrada en r0 en r1
    ldr r1, [r0]
    // Habilitar reloj para GPIOA y GPIOC
    orr r1, #GPIOA_EN
    orr r1, #GPIOC_EN
    // Almacenar el contenido en r1 en la dirección encontrada en r0
    str r1, [r0]

    ldr r0, =GPIOA_MODER          // Load address of GPIOA_MODER into r0
    ldr r1, [r0]                  // Load the current value of GPIOA_MODER into r1
    bic r1, r1, #(0x3 << 0)       // Clear bits 1:0 (PA0) to set as output
    bic r1, r1, #(0x3 << 2)       // Clear bits 3:2 (PA1) to set as output
    bic r1, r1, #(0x3 << 8)       // Clear bits 9:8 (PA4) to set as output
    bic r1, r1, #(0x3 << 12)      // Clear bits 13:12 (PA6) to set as output
    bic r1, r1, #(0x3 << 14)      // Clear bits 15:14 (PA7) to set as output
    bic r1, r1, #(0x3 << 16)      // Clear bits 17:16 (PA8) to set as output
    bic r1, r1, #(0x3 << 18)      // Clear bits 19:18 (PA9) to set as output
    orr r1, r1, #(0x1 << 0)       // Set PA0 as output (01)
    orr r1, r1, #(0x1 << 2)       // Set PA1 as output (01)
    orr r1, r1, #(0x1 << 8)       // Set PA4 as output (01)
    orr r1, r1, #(0x1 << 12)      // Set PA6 as output (01)
    orr r1, r1, #(0x1 << 14)      // Set PA7 as output (01)
    orr r1, r1, #(0x1 << 16)      // Set PA8 as output (01)
    orr r1, r1, #(0x1 << 18)      // Set PA9 as output (01)
    str r1, [r0]                  // Write back the updated value to GPIOA_MODER

    ldr r0, =GPIOC_MODER          // Load address of GPIOC_MODER into r0
    ldr r1, [r0]                  // Load the current value of GPIOC_MODER into r1
    bic R1, R1, #(3 << 26)           // Clear bits 27:26 (PC13) to set as input (00)
    str r1, [r0]                  // Write back the updated value to GPIOC_MODER

    mov r4, #0                    // Initialize r4 (index for gusanito array) to 0

    b awaitbton

awaitbton:
	// Leer el estado del botón
    ldr r0, =GPIOC_IDR
    ldr r1, [r0]
    tst r1, #(1 << 13)
    beq loop
    b awaitbton

loop:
    ldr r0, =gusanito             // Load address of gusanito into r0
    ldr r1, [r0, r4]             // Load byte from gusanito at index r4 into r1

    ldr r0, =GPIOA_ODR            // Load address of GPIOA_ODR into r0
    str r1, [r0]                  // Write the value from r1 to GPIOA_ODR (update LEDs)

    add r4, #4                    // Increment r4 (index for gusanito)
    cmp r4, #32                    // Compare r4 with 8
    bne delay                     // If r4 is not 8, branch to delay
    mov r4, #0                    // If r4 is 8, reset it to 0

delay:
    ldr r5, =5000000                // Load 1500 into r5 (delay counter)
    b delay_loop

delay_loop:
    subs r5, #1                   // Subtract 1 from r5
    bne delay_loop                // If r5 is not 0, branch to delay_loop

    b loop                        // Branch to loop (repeat process)

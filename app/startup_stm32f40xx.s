    .syntax unified
    .cpu cortex-m4
    .fpu softvfp
    .thumb

    .global  g_pfnVectors
    .global  Default_Handler

    .section  .text.Reset_Handler
    .weak  Reset_Handler
    .type  Reset_Handler, %function

Reset_Handler:
.if 0
    /* disable irq */
    cpsid i
.else
    /* only NMI exception is allowed */
    movs r1,1
    msr faultmask, r1
.endif
    bl  main

    .size  Reset_Handler, .-Reset_Handler

    .section  .text.Default_Handler,"ax",%progbits

Default_Handler:
Infinite_Loop:
    b  Infinite_Loop

    .size  Default_Handler, .-Default_Handler

    .section  .isr_vector,"a",%progbits
    .type  g_pfnVectors, %object
    .size  g_pfnVectors, .-g_pfnVectors

    /* IVT */

g_pfnVectors:
    .word  _estack
    .word  Reset_Handler
    .word  NMI_Handler

.if 0
    .word  HardFault_Handler
    .word  MemManage_Handler
    .word  BusFault_Handler
    .word  UsageFault_Handler

    .word  0
    .word  0
    .word  0
    .word  0
    .word  SVC_Handler
    .word  DebugMon_Handler
    .word  0
    .word  PendSV_Handler
    .word  SysTick_Handler

    /* External Interrupts */
    /* ... removed ... */
.endif

    /* Week aliases to the Default_Handler: */

    .weak      NMI_Handler
    .thumb_set NMI_Handler,Default_Handler

.if 0
    .weak      HardFault_Handler
    .thumb_set HardFault_Handler,Default_Handler

    .weak      MemManage_Handler
    .thumb_set MemManage_Handler,Default_Handler

    .weak      BusFault_Handler
    .thumb_set BusFault_Handler,Default_Handler

    .weak      UsageFault_Handler
    .thumb_set UsageFault_Handler,Default_Handler

    .weak      SVC_Handler
    .thumb_set SVC_Handler,Default_Handler

    .weak      DebugMon_Handler
    .thumb_set DebugMon_Handler,Default_Handler

    .weak      PendSV_Handler
    .thumb_set PendSV_Handler,Default_Handler

    .weak      SysTick_Handler
    .thumb_set SysTick_Handler,Default_Handler
.endif

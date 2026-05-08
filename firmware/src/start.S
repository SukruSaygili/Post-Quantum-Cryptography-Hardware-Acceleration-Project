/*****************************************************************************/
/* This assembly script is used for initialisation.                          */
/*****************************************************************************/
.global start

.section .init, "ax"

start:
  /* Zero-initialize all registers (except x0 which is hardwired to 0) */
  /* We also skip x2 (sp) for now, as we set it immediately after */
  addi x1, zero, 0
  addi x3, zero, 0
  addi x4, zero, 0
  addi x5, zero, 0
  addi x6, zero, 0
  addi x7, zero, 0
  addi x8, zero, 0
  addi x9, zero, 0
  addi x10, zero, 0
  addi x11, zero, 0
  addi x12, zero, 0
  addi x13, zero, 0
  addi x14, zero, 0
  addi x15, zero, 0
  addi x16, zero, 0
  addi x17, zero, 0
  addi x18, zero, 0
  addi x19, zero, 0
  addi x20, zero, 0
  addi x21, zero, 0
  addi x22, zero, 0
  addi x23, zero, 0
  addi x24, zero, 0
  addi x25, zero, 0
  addi x26, zero, 0
  addi x27, zero, 0
  addi x28, zero, 0
  addi x29, zero, 0
  addi x30, zero, 0
  addi x31, zero, 0

  /* Set stack pointer using the linker script symbol! */
  /* This guarantees it points to the very top of the RAM */
  la sp, __stack_top

  /* Clear the BSS section (Initialize variables to 0) */
  la a0, __bss_start    /* a0 = start address of BSS */
  la a1, __bss_end      /* a1 = end address of BSS */
  bge a0, a1, end_bss   /* If start >= end, BSS is empty, skip loop */

clear_bss_loop:
  sw zero, 0(a0)        /* Write 0 (32-bits) to address in a0 */
  addi a0, a0, 4        /* Move forward 4 bytes */
  blt a0, a1, clear_bss_loop /* Loop if we haven't reached the end */
end_bss:

  /* Call main function in C */
  jal ra, main

  /* Infinite loop if main ever returns */
end:
  j end
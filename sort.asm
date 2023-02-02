/*
 * c128lib (c) 2023
 * https://github.com/c128lib/framework
 */

#import "chipset/lib/vic2.asm"

#importonce
.filenamespace c128lib

.namespace Sort {
}

/*
  Sort an array with bubble sort algorithm.
  Fast mode can be switched on/off while algorithm
  is running. Fast mode can also be enabled before
  macro is called.

  Params:
  arrayAddress - memory address of array
  arraySize - array size
  switchToFastModeWhileRunning - if true, fast mode
    will be enabled at start and disabled at end.
*/
.macro BubbleSort(arrayAddress, arraySize, switchToFastModeWhileRunning) {
  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

start:
    ldx #arraySize

sort_loop:
    ldy #0

inner_loop:
    lda arrayAddress, y
    cmp arrayAddress + 1, y
    bcc NoSwap
    pha
    lda arrayAddress + 1, y
    sta arrayAddress, y
    pla
    sta arrayAddress + 1, y
 
  NoSwap:
    iny
    cpy #arraySize - 1
    bne inner_loop
    dex
    bne sort_loop

  .if (switchToFastModeWhileRunning == true) {
    dec c128lib.Vic2.CLKRATE
  }
}

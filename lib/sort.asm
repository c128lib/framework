/**
 * @brief Sort module
 * @details Macros for array sorting.
 *
 * @copyright MIT Licensed
 * @date 2023
 */

#importonce
.filenamespace c128lib

.namespace Sort {
}

/**
  Sort a 8-bit value array with bubble sort algorithm.
  Sorted array will be available in the same source
  address.
  Fast mode can be switched on/off while algorithm
  is running.

  @param arrayAddress Memory address of array
  @param arraySize Array size
  @param switchToFastModeWhileRunning If true, fast mode
    will be enabled at start and disabled at end

  @remark Registers .A, .X and .Y will be modified

  @note Use c128lib_BubbleSort in sort-global.asm

  @since 0.1.0
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
.assert "BubbleSort($beef, 3, false)", { BubbleSort($beef, 3, false) },
{
  ldx #3; ldy #0; lda $beef,y; cmp $bef0, y; bcc *+13; pha;
  lda $bef0, y; sta $beef, y; pla; sta $bef0, y; iny
  cpy #2; bne *-22; dex; bne *-27
}
.assert "BubbleSort($beef, 3, true)", { BubbleSort($beef, 3, true) },
{
  lda #1; sta $d030
  ldx #3; ldy #0; lda $beef,y; cmp $bef0, y; bcc *+13; pha;
  lda $bef0, y; sta $beef, y; pla; sta $bef0, y; iny
  cpy #2; bne *-22; dex; bne *-27;
  dec $d030
}

#import "chipset/lib/vic2.asm"

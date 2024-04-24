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
 * @brief This macro implements the Bubble Sort algorithm.
 *
 * @param[inout] arrayAddress The starting address of the array to be sorted.
 * @param[in] arraySize The size of the array to be sorted.
 * @param[in] switchToFastModeWhileRunning If true, the macro will switch to 8502 fast mode.
 *
 * @details This macro sorts an array in ascending order using the Bubble Sort algorithm. 
 *          If 'switchToFastModeWhileRunning' is true, the macro will switch to 8502 fast mode while running.
 *          This can be beneficial for larger arrays.
 *
 * @note The sorted array is available at the same memory address as the input array.
 *       The macro modifies the .A, .X, and .Y registers. If you're using these registers elsewhere in your code, 
 *       you'll need to save their values before calling this macro and restore them afterward.
 *
 * @remark Use c128lib_BubbleSort in sort-global.asm
 *
 * @since 0.1.0
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

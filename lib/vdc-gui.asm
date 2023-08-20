/**
 * @brief Gui module
 * @details Macros for generating Gui
 *
 * @copyright MIT Licensed
 * @date 2023
 */

#importonce
.filenamespace c128lib

.namespace Gui {
}

.macro CreateWindow(x, y, width, height) {

#if !VDC_CREATEWINDOW
    .error "You should use #define VDC_CREATEWINDOW"
#else
#define VDC_POKE
    /* Top left corner */
    lda #85
    sta VDC_Poke.value
    lda #<(VDC_RowColToAddress(x, y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(x, y))
    sta VDC_Poke.address + 1
    jsr VDC_Poke

    /* Left border */
    lda #66
    sta VDC_Poke.value
    ldy #height - 2
  !:
    c128lib_add16(80, VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    /* Bottom left corner */
    lda #74
    sta VDC_Poke.value
    jsr VDC_Poke

    /* Bottom border */
    lda #67
    sta VDC_Poke.value
    ldy #width-2
  !:
    c128lib_inc16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    /* Bottom right corner */
    lda #75
    sta VDC_Poke.value
    jsr VDC_Poke

    /* Right border */
    lda #66
    sta VDC_Poke.value
    ldy #height - 2
  !:
    c128lib_sub16(80, VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    /* Top right corner */
    lda #73
    sta VDC_Poke.value
    jsr VDC_Poke

    /* Top border */
    lda #67
    sta VDC_Poke.value
    ldy #width-3
  !:
    c128lib_dec16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-
#endif    
}
.macro CreateWindowWithTitle(x, y, width, height, text, length) {
    .errorif (length < 1), "Length must be greater than 1"
    .errorif (length > width -2), "Length must be lower than width - 2"

    CreateWindow(x, y, width, height)

    c128lib_WriteToVdcMemoryByCoordinates(text, x+2, y+1, length)
}
.asserterror "CreateWindowWithTitle(50, 1, 20, 10, $beef, 0)", { CreateWindowWithTitle(50, 1, 20, 10, $beef, 0) }
.asserterror "CreateWindowWithTitle(50, 1, 20, 10, $beef, 19)", { CreateWindowWithTitle(50, 1, 20, 10, $beef, 19) }

/* Function returns a VDC memory address for a given row and column */
.function VDC_RowColToAddress(x, y) {
  .var addr = y * 80 + x;

  .if (addr > -1 && addr < 2000)
    .return addr
  else
    .return -1;
}

#if VDC_POKE
VDC_Poke: {
    ldx #c128lib.Vdc.CURRENT_MEMORY_HIGH_ADDRESS
    lda address + 1
    c128lib_WriteVdc()

    inx
    lda address
    c128lib_WriteVdc()

    ldx #c128lib.Vdc.MEMORY_READ_WRITE
    lda value
    c128lib_WriteVdc()

    rts

    address: .word $0000
    value: .byte $00
}
#endif

#import "common/lib/math-global.asm"
#import "chipset/lib/vdc-global.asm"

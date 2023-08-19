
.function VDC_RowColToAddress(x, y) {
	/* Function returns a VDC memory address for a given row and column */

	.var addr = y * 80 + x;

	.if (addr > -1 && addr < 2000)
		.return addr
	else
		.return -1;
}

c128lib_BasicUpstart128($1c10)

* = $1c10

Entry: {
  .label x = 2;
  .label y = 2;
  .label width = 40;
  .label height = 10
  // $1c10-$2cba                  = $10aa = 4266
  // $1c10-$2303 (with jsr)       = $06f3 = 1779
  // $1c10-$2141 (with some opt)  = $0531 = 1329
  // $1c10-$1d14 (with loops)     = $0104 =  260

    /* Top left corner */
    lda #85
    sta VDC_Poke.value
    lda #<(VDC_RowColToAddress(x, y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(x, y))
    sta VDC_Poke.address + 1
    jsr VDC_Poke

    /* Top right corner */
    lda #73
    sta VDC_Poke.value
    lda #<(VDC_RowColToAddress(x + width - 1, y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(x + width - 1, y))
    sta VDC_Poke.address + 1
    jsr VDC_Poke

    /* Top border */
    lda #67
    sta VDC_Poke.value
    lda #<(VDC_RowColToAddress(x, y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(x, y))
    sta VDC_Poke.address + 1

    ldy #width-2
  !:
    c128lib_inc16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    /* Bottom border */
    lda #<(VDC_RowColToAddress(x, y + height-1))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(x, y + height-1))
    sta VDC_Poke.address + 1

    ldy #width-2
  !:
    c128lib_inc16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-
    
    /* Left border */
    lda #66
    sta VDC_Poke.value
    lda #<(VDC_RowColToAddress(x, y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(x, y))
    sta VDC_Poke.address + 1

    ldy #height - 2
  !:
    c128lib_add16(80, VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    /* Right border */
    lda #66
    sta VDC_Poke.value
    lda #<(VDC_RowColToAddress(x + width-1, y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(x + width-1, y))
    sta VDC_Poke.address + 1

    ldy #height - 2
  !:
    c128lib_add16(80, VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

  	// /* Bottom left and right corners */
    lda #74
    sta VDC_Poke.value
    lda #<(VDC_RowColToAddress(x, y + height-1))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(x, y + height-1))
    sta VDC_Poke.address + 1
    jsr VDC_Poke

    lda #75
    sta VDC_Poke.value
    lda #<(VDC_RowColToAddress(x + width-1, y + height-1))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(x + width-1, y + height-1))
    sta VDC_Poke.address + 1
    jsr VDC_Poke

    rts
}

VDC_Poke: {
    ldx #c128lib.Vdc.CURRENT_MEMORY_HIGH_ADDRESS
    lda address + 1
    c128lib_WriteVdc()
    
    // ldx #c128lib.Vdc.CURRENT_MEMORY_LOW_ADDRESS
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

.macro VDC_Poke(address, value) {
    ldx #c128lib.Vdc.CURRENT_MEMORY_HIGH_ADDRESS
    lda #>address
    c128lib_WriteVdc()
    
    // ldx #c128lib.Vdc.CURRENT_MEMORY_LOW_ADDRESS
    inx
    lda #<address
    c128lib_WriteVdc()
    
    ldx #c128lib.Vdc.MEMORY_READ_WRITE
    lda #value
    c128lib_WriteVdc()
}

#import "common/lib/common-global.asm"
#import "common/lib/math-global.asm"
#import "chipset/lib/vdc.asm"
#import "chipset/lib/vdc-global.asm"

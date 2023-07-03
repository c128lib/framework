/**
 * @brief Z80 related macros
 * @details This module contains macros for running
 * z80 code at request inside 8502 assembly program.
 *
 * @copyright MIT Licensed
 * @date 2023
 */

#importonce
.filenamespace c128lib

/** 
  Prepare 8502 processor for z80 activation. This macro will
  setup JP instruction and address where Z80 should jump and
  then activate the processor. It also setup Mmu correctly.
  At the end, Mmu is set to previous status.

  @param[in] z80CodeAddress Address where Z80 code is stored

  @remark Register .A will be changed.
  @sa PreZ80Code, PostZ80Code

  @note Use c128lib_RunZ80Code in z80-global.asm

  @attention Code must be preceded with bytes provided from
  PreZ80Code. Also, the bytes provided by must be
  added to the code PostZ80Code.

  @since 0.2.0
*/
.macro RunZ80Code(z80CodeAddress) {
    sei                   // Disable interrupts

    lda c128lib.Mmu.LOAD_CONFIGURATION
    pha                   // Save LOAD_CONFIGURATION status
    lda #$c3              // Set JP opcode
    sta $ffee
    lda #<z80CodeAddress  // Set JP address into $ffee (hi-byte)
    sta $ffef
    lda #>z80CodeAddress  // Set JP address into $ffef (lo-byte)
    sta $fff0
    lda c128lib.Mmu.MODE_CONFIG
    pha                   // Save MODE_CONFIG status

    c128lib_SetModeConfig(c128lib.Mmu.CPU_Z80 | c128lib.Mmu.FASTSERIALINPUT | c128lib.Mmu.GAME_HI | c128lib.Mmu.EXROM_HI | c128lib.Mmu.COLS_40)

    // Here, z80 is running, waiting for return

    nop
    pla
    sta c128lib.Mmu.MODE_CONFIG
    pla
    sta c128lib.Mmu.LOAD_CONFIGURATION
    cli                   // Enable interrupts
}

/** 
  Generates z80 pre-code, in order to setup environment for
  correct z80 code running.

  @remark Register .A of z80 processor will be changed.
  @sa PostZ80Code

  @note Use c128lib_PreZ80Code in z80-global.asm

  @attention This macro must be run before writing the code
  that will be executed on z80.

  @since 0.2.0
*/
.macro PreZ80Code() {
    .byte $3e, $3f        // LD A, #$3F - load up the #$3f byte, for mmu cr
    .byte $32, $00, $ff   // LD ($FF00),A - set the mmu configuration register mirror with #$3f
}

/** 
  Generates z80 post-code, in order to guarantee that
  z80 jumps to routine to reactivate 6502.

  @remark Register .A of z80 processor will be changed.
  @sa PreZ80Code

  @note Use c128lib_PostZ80Code in z80-global.asm

  @attention This macro must be run after writing the code
  that will be executed on z80.

  @since 0.2.0
*/
.macro PostZ80Code() {
    .byte $c3, $e0, $ff   // JP $FFE0 - jump to the bootlink routine in the Z-80 ROM, 8502 is switched on there.
}

#import "chipset/lib/mmu-global.asm"

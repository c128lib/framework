/**
 * @brief Z80 related macros
 * @details This module contains macros for running
 * z80 code at request inside 8502 assembly program.
 *
 * @copyright MIT Licensed
 * @date 2023
 */

#importonce

#import "z80.asm"

.filenamespace c128lib

/** 
  Prepare 8502 processor for z80 activation. This macro will
  setup JP instruction and address where Z80 should jump and
  then activate the processor. It also setup Mmu correctly.
  At the end, Mmu is set to previous status.

  @param[in] z80CodeAddress Address where Z80 code is stored

  @remark Register .A will be changed.
  @sa c128lib_PreZ80Code, c128lib_PostZ80Code

  @attention Code must be preceded with bytes provided from
  c128lib_PreZ80Code. Also, the bytes provided by must be
  added to the code c128lib_PostZ80Code.

  @since 0.2.0
*/
.macro @c128lib_RunZ80Code(z80CodeAddress) { RunZ80Code(z80CodeAddress) }

/** 
  Generates z80 pre-code, in order to setup environment for
  correct z80 code running.

  @remark Register .A of z80 processor will be changed.
  @sa c128lib_PostZ80Code

  @attention This macro must be run before writing the code
  that will be executed on z80.

  @since 0.2.0
*/
.macro c128lib_PreZ80Code() { PreZ80Code() }

/** 
  Generates z80 post-code, in order to guarantee that
  z80 jumps to routine to reactivate 6502.

  @sa c128lib_PreZ80Code

  @attention This macro must be run after writing the code
  that will be executed on z80.

  @since 0.2.0
*/
.macro c128lib_PostZ80Code() { PostZ80Code() }

/**
 * @brief Random number generator module
 * @details Macros for generating random and pseudo random numbers
 *
 * @link https://c128lib.github.io/framework/
 * @details c128lib - Framework
 * @endlink
 *
 * @copyright MIT Licensed
 * @date 2023
 */

#import "chipset/lib/sid.asm"

#importonce
.filenamespace c128lib

.namespace Random {
}

/**
  Generates a random number starting from a given seed.
  It's not a real random number generator but generates
  a pseudo random number. By passing the same seed, it will
  generate always the same number. It is guaranteed to create a 
  sequence touching every element from 0 to $ff just once.
  Seed must be provided in accumulator and can be from 0 to $ff.
  Output number will be available in the accumulator.

  @remark Register .A must contain seed and will contain
    pseudo random number generated.
    Flags N, Z and C will be affected.

  @since 0.1.0
*/
.macro PseudoRandom() {
    beq doEor
    asl
    beq noEor
    bcc noEor
doEor:
    eor #$1d
noEor:
}

/**
  Init random number generator based on the Sid chip. When used,
  voice 3 of Sid chip can't be used for playback sounds.

  @remark Register .A will be changed.
    Flags N and Z will be affected.
  @sa GetRandomNumberFromSid
  @since 0.1.0
*/
.macro InitSid() {
    lda #$FF 
    sta c128lib.Sid.VOICE3_FREQ_REGISTER_LOW
    sta c128lib.Sid.VOICE3_FREQ_REGISTER_HI
    lda #$80 
    sta c128lib.Sid.VOICE3_CONTROL_REGISTER
}

/**
  Get a new random number from the Sid chip and puts it
  into the .A register. Random numbers are continuously
  generated so each call gives a new random number.
  Generetor must be initialized with InitSid().

  @remark Register .A will be changed.
    Flags N and Z will be affected.
  @sa InitSid
  @since 0.1.0
*/
.macro GetRandomNumberFromSid() {
    lda c128lib.Sid.VOICE3_OSCILLATOR
}

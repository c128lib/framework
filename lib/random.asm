/*
 * c128lib (c) 2023
 * https://github.com/c128lib/framework
 */

#import "chipset/lib/sid.asm"

#importonce
.filenamespace c128lib

.namespace Random {
}

/*
  Generates a random number starting from a given seed.
  It's not a real random number generator but generates
  a pseudo random number. By passing the same seed, it will
  generate always the same number. It is guaranteed to create a 
  sequence touching every element just once.
  Seed must be provided in accumulator and can be from 0 to $ff.
  Output number will be available in the accumulator.

  Params:
  .A - Seed
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

/*
  Init random number generator based on the Sid chip. When used,
  voice 3 of Sid chip can't be used for playback sounds.
*/
.macro InitSid() {
    lda #$FF 
    sta c128lib.Sid.VOICE3_FREQ_REGISTER_LOW
    sta c128lib.Sid.VOICE3_FREQ_REGISTER_HI
    lda #$80 
    sta c128lib.Sid.VOICE3_CONTROL_REGISTER
}

/*
  Get a new random number from the Sid chip and puts it
  into the .A register. Random numbers are continuously
  generated so each call gives a new random number.
*/
.macro GetRandomNumberFromSid() {
    lda c128lib.Sid.VOICE3_OSCILLATOR
}

/*
 * c128lib (c) 2023
 * https://github.com/c128lib/framework
 */

// #import "chipset/lib/vic2.asm"

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

#import "random.asm"
#importonce
.filenamespace c128lib

.macro @c128lib_PseudoRandom() { PseudoRandom() }
.macro @c128lib_InitSid() { InitSid() }
.macro @c128lib_GetRandomNumberFromSid() { GetRandomNumberFromSid() }

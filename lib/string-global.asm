#import "string.asm"
#importonce
.filenamespace c128lib

.macro @c128lib_StringCompare(string1Address, string2Address, switchToFastModeWhileRunning) { StringCompare(string1Address, string2Address, switchToFastModeWhileRunning) }
.macro @c128lib_StringLength(stringAddress, switchToFastModeWhileRunning) { StringLength(stringAddress, switchToFastModeWhileRunning) }

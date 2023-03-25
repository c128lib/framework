#import "string.asm"
#importonce
.filenamespace c128lib

.macro @c128lib_StringCompare(string1Address, string2Address, switchToFastModeWhileRunning) { StringCompare(string1Address, string2Address, switchToFastModeWhileRunning) }
.macro @c128lib_StringLength(stringAddress, switchToFastModeWhileRunning) { StringLength(stringAddress, switchToFastModeWhileRunning) }
.macro @c128lib_StringCopy(sourceAddress, destinationAddress, switchToFastModeWhileRunning) { StringCopy(sourceAddress, destinationAddress, switchToFastModeWhileRunning) }
.macro @c128lib_StringCopyLeft(sourceAddress, destinationAddress, numChars, switchToFastModeWhileRunning) { StringCopyLeft(sourceAddress, destinationAddress, numChars, switchToFastModeWhileRunning) }
.macro @c128lib_StringCopyRight(sourceAddress, destinationAddress, sourceStrLength, numChars, switchToFastModeWhileRunning) { StringCopyRight(sourceAddress, destinationAddress, sourceStrLength, numChars, switchToFastModeWhileRunning) }
.macro @c128lib_StringCopyMid(sourceAddress, destinationAddress, startPos, numChars, switchToFastModeWhileRunning) { StringCopyMid(sourceAddress, destinationAddress, startPos, numChars, switchToFastModeWhileRunning) }
.macro @c128lib_StringConcatenate(string1Address, string2Address, string1Length, switchToFastModeWhileRunning) { StringConcatenate(string1Address, string2Address, string1Length, switchToFastModeWhileRunning) }

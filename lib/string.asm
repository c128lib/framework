/*
 * c128lib (c) 2023
 * https://github.com/c128lib/framework
 */

#import "chipset/lib/vic2.asm"

#importonce
.filenamespace c128lib

/*
  The strings are a maximum of 255 bytes long and are null terminated. The null character 
  makes the interal storage a max of 256 bytes.

  Notes:
    When the carry flag is set, a programmer can repeat these macro for strings longer than
    256 chars.  The programmer would call the macros as many times as the number of bytes
    needed for memory allocation of the string. 
    In this way, a programmer can create a string data type with length longer than 255.  
    In this case, multiple bytes could be used to represent a long string, with each byte 
    holding 256 characters, excluding the terminator (#0), except for the last byte which 
    must be terminated. The implementation of how many bytes to allocate to the string is 
    up to the programmer. Last byte must be terminated at index 255 or less.

    Examples will be given in the official documentation.
*/

.namespace String {
}

/*
  StringCompare - Compare two strings. 
    
    The zero flag is set to 1 if the strings are  identical and to 0 if the strings are not
    identical. 

    If both strings are equal up to the maximum 255 bytes, then the carry flag is set, whether 
    both strings are 255 chars long or greater.  If greater, one can call the routine another 
    time knowing that the carry flag is set and continue comparing the next 255 chars.
    
  Params:
    string1Address - address of string1
    string2Address - address of string2
    switchToFastModeWhileRunning - if true, fast mode
      will be enabled at start and disabled at end.

*/
.macro StringCompare(string1Address, string2Address, switchToFastModeWhileRunning) {

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  begin:
    clc                 
    ldx #0                    // Start at first character (index 0) and count to 254

  compare:
    lda string1Address, x
    cmp string2Address, x     // Compare 2 characters
    bne end                   // Exit if characters are not equal
                              // Z will be set to 0 on exit
                              // Else (characters are equal), but both characters could be null
    cmp #0                    // Test for end of both strings (null)
    beq end                   // Exit if both characters are 0 (null)
                              // Z will be set to 1 on exit (strings are equal)
                              // Else there may be more characters to compare if max not reached
    cpx #$FE                  // Hit the max 255 chars? We don't care about byte 256 (we expect null)
                              // Z will bet set to 1 (strings are equal up to 255 bytes)
    beq max_reached           // Handle maximum strings, set carry flag if needed
    inx                       // Next character
    jmp compare               // Loop
 
  max_reached:
    sec

  end:

  .if (switchToFastModeWhileRunning == true) {
    dec c128lib.Vic2.CLKRATE
  }
    
}

/*
  StringLength - Find the length of a string. 
  
    Returns the length of a string in Y, preserves X

  Params:
    Inputs: 
      stringAddress - address of string
      switchToFastModeWhileRunning - if true, fast mode will be enabled at start and disabled 
                                     at end.
    Outputs:
      Registers:
        Y - length of the string at address stringAddress
      Flags:
        C - Is set if length of source string is greater than 255
        Z - Will be set to 1, either because null character found, or overflow in Y 
            occured 
  
  Postconditions: 
    Y register will contain the length of the string, which is also the
    address offset to the eol character, the null character (0). The Z flag will always
    be set to 1.  The C flag will be 0 if length <= 255, otherwise 1.  The routine
    terminates after 256 loops.

*/
.macro StringLength(stringAddress, switchToFastModeWhileRunning) {

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  begin:
    clc
    ldy #0

  strln:	
    lda stringAddress, y
    beq end
    iny
    bne strln

  end:


  .if (switchToFastModeWhileRunning == true) {
    dec c128lib.Vic2.CLKRATE
  }
}

/*
  StringCopy - Copies a string from a source address to a destination address

  Params:
    Inputs:
      sourceAddress - address of source string
      destinationAddress - destination address for copied string
      switchToFastModeWhileRunning - if true, fast mode will be enabled at start and disabled 
                                     at end.
    Outputs:
      Flags:
        C - Is set if length of source string is greater than 255
        Z - Will be set to 1, either because null character found, or overflow in Y 
            occured 
    
  Postconditions:
      1. destinationAddress will point to a string the same as the
         string pointed to by sourceAddress
      2  Y register will contain the length of the string, which is also the
         address offset to the eol character, the null character (0). The Z flag will always
         be set to 1.  The C flag will be 0 if length <= 255, otherwise 1.  The routine
         terminates after 256 loops.

*/
.macro StringCopy(sourceAddress, destinationAddress, switchToFastModeWhileRunning) {

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  begin:
    clc
    ldy #0

  copystr:	
    lda sourceAddress, y
    sta destinationAddress, y		
    beq end                       // stop when null is hit
    iny
    beq end                       // stop when overflow in Y occured, C flag will be set
    bne copystr

  end:

  .if (switchToFastModeWhileRunning == true) {
    dec c128lib.Vic2.CLKRATE
  }

}

.macro StringCopyLeft(sourceAddress, destinationAddress, numChars, switchToFastModeWhileRunning) {

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  begin:
    sec
  	ldy #0

  copyleft:
  	lda sourceAddress, y
    sta destinationAddress, y
    beq end
    iny
    cpy numChars
    bcc copyleft
    lda #0			      //Terminate the new string
    sta destinationAddress, y

  end:

  .if (switchToFastModeWhileRunning == true) {
    dec c128lib.Vic2.CLKRATE
  }
}

.macro StringCopyRight(sourceAddress, destinationAddress, sourceStrLength, numChars, switchToFastModeWhileRunning) {

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  begin:
    ldy sourceStrLength               // start at end of string
    beq end                           // if strLength is 0, just end
    dey                               // indexing starts from 0, so subract 1 from length

    ldx numChars                      // x will hold index of destination string
    beq end                           // if numChars is 0, just end
    lda #0                            // null character
    sta destinationAddress, x         // terminate the new string
    dex                               // indexing starts from 0, so subtract 1 from numChars


  copyright:
  	lda sourceAddress, y              // load next character (moving right)
    sta destinationAddress, x         // copy character (staring from right, moving right)
    dey                               // next character
    dex                               // next position in destination string
    bpl copyright                     // loop as long as x >= 0

  end:

  .if (switchToFastModeWhileRunning == true) {
    dec c128lib.Vic2.CLKRATE
  } 

}

.macro StringCopyMid(sourceAddress, destinationAddress, startPos, numChars, switchToFastModeWhileRunning) {

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  begin:
    ldy startPos                    // Staring positiion of source string (0 indexed)
    ldx #0                          // Destination string index - 0 to numChars-1

  copymid:
    lda sourceAddress, y           // load next character
    sta destinationAddress, x      // store character to destination string
    inx                            // set position for next character
    cpx numChars                   
    beq end                        // went past end of destination string?

  end:
    lda #0                         // null character
    sta destinationAddress, x      // terminate destination string

  .if (switchToFastModeWhileRunning == true) {
    dec c128lib.Vic2.CLKRATE
  } 

}




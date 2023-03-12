/*
 * c128lib (c) 2023
 * https://github.com/c128lib/framework
 */

#import "chipset/lib/vic2.asm"

#importonce
.filenamespace c128lib

/*
  The strings are a maximum of 255 bytes long and are null terminated. The null character 
  makes the interal storage a max of 256 bytes.  For strings 256 bytes and longer,
  these macros can be repeated for each set of 256 bytes.

  Notes:
    When a post condition is that the carry is set, a programmer can repeat these macros 
    for strings 256 chars or longer.  The programmer would call the macros as many times 
    as the number of 256-byte strings needed for memory allocation of the string. 
    In this way, a programmer can create a string data type with length longer than 255.  
    In this case, multiple 256-byte strings could be used to represent a long string, with 
    each 256-byte string holding 256 characters, excluding the terminator (#0), except for 
    the last byte 256-byte string which must be terminated at 255.

    Examples will be given in the official documentation.
*/

.namespace String {
}

/*
  StringCompare - Compare two strings. 
    
    Determine if 2 strings are equal.
    
  Params:
    string1Address - address of string1
    string2Address - address of string2
    switchToFastModeWhileRunning - if true, fast mode will be enabled at start and disabled at end.
  
  Postconditions: 
    1) The zero flag is set if the strings are identical and cleared otherwise.
       In either case, the carry flag is cleared
    2) If both strings are equal up to 256 bytes, and no terminator is found then the carry 
       flag and zero flag are set; otherwise they are both cleared
    3) When substrings of the 2 strings are equal, starting from the beginning, the X register
       will contain the index of the end of the substrings.
    4) If the strings are equal, the X register will contain their lengths. 

*/
.macro StringCompare(string1Address, string2Address, switchToFastModeWhileRunning) {

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  begin:
    clc                 
    ldx #0                    // Start at first character (index 0) and count to 255

  compare:
    lda string1Address, x
    cmp string2Address, x     // Compare 2 characters
    bne comp_end              // Exit if characters are not equal
                              // Z will be set to 0 on exit
                              // Else (characters are equal), but both characters could be null
    cmp #0                    // Test for end of both strings (null)
    beq comp_end              // Exit if both characters are 0 (null)
                              // Z will be set to 1 on exit (strings are equal)
                              // Else there may be more characters to compare
    inx                       // Next character
    beq no_terminator         // Loop if x = 255 or less, otherwise end (Z flag is 1, C flag is 1)
    jmp compare         

  comp_end:                   // Z flag is 1 if equal, Z flag is 0 if not equal
    clc                       // Ensure C flag is 0 in both cases

  no_terminator:              // If branched to here, then Z flag is 1, C flag is 1

  end:                        // end = no_terminator, here for readibility


  .if (switchToFastModeWhileRunning == true) {
    dec c128lib.Vic2.CLKRATE
  }
    
}

/*
  StringLength - Find the length of a string. 
  
    Returns the length of a string in Y, preserves X

  Params:
      stringAddress - address of string
      switchToFastModeWhileRunning - if true, fast mode will be enabled at start and disabled 
                                     at end.
  
  Postconditions: 
    Y register will contain the length of the string, which is also the
    address offset to null character (0). The Z flag will always
    be set to 1.  The C flag will be 0 if length <= 255, otherwise 1.  The routine
    terminates after 256 loops.

    Registers:
      Y - length of the string at address stringAddress
    Flags:
      C - Is set if length of source string is greater than 255
      Z - Will be set to 1, either because null character found, or overflow in Y 
          occured 

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
    beq strln_end                   // Hit terminator, Z=1, C=0
    iny
    beq no_terminator               // y > 255, Z=1, C=0
    jmp strln

  no_terminator:
    sec                             // y > 255, Z=1, C=1

  strln_end:                       // Hit terminator, Z=1, C=0
  
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

    
  Postconditions:
      1. destinationAddress will point to a string the same as the
         string pointed to by sourceAddress
      2  Y register will contain the length of the string, which is also the
         address offset to the eol character, the null character (0). The Z flag will always
         be set to 1.  The C flag will be 0 if length <= 255, otherwise 1.  The routine
         terminates after 256 loops.
      
      Flags:
        C - Is set if length of source string is greater than 255
        Z - Will be set to 1, either because null character found, or overflow in Y 
            occured 

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
    beq copy_end                       // Hit terminator, Z=1, C=0
    iny
    beq no_terminator                  // y > 255, Z=1, C=0
    jmp copystr

  no_terminator:
    sec                               // y > 255, Z=1, C=1

  copy_end:

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




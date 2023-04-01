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

  String addresses can be absolute addresses or post-indexed indirect, "(Zero-Page), Y".
  To be clear, if passing a zero-page address, it is implied that the address is an
  indirect address that will be post-indexed by Y by the macro.  So, the zero page 
  address will hold the absolute address (small endian) of the string.
  Only pass the zero-page address without brackets, such as $FA.  Last usable zero-page
  address for post-indexed indirect addressing mode is $FE, so do not pass $FF.

  Numeric parameters must be an address.  That is, store the number in an address (zero-page
  or 16-bit) and then pass the address to the parameter.  In the comments, these parameters 
  will be dereferenced by the *, as in C notation.  For example, numChars is the address, and
  *numChars is the value stored at address numChars.

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
  .label STRING_SRC = $FA
  .label STRING_TRG = $FC  
}

/*
  StringCompare - Compare two strings. 
    
    Determine if 2 strings are equal.
    
  Params:
    string1Address - address of string1
    string2Address - address of string2
    switchToFastModeWhileRunning - if true, fast mode will be enabled at start and disabled at end.
  
  Preconditions:
    1) string1Address, string2Address must be a 16-bit address or 8-bit zero-page address
       holding the address of the string
    2) Zero-page address must not be greater than $FE, or error

  Postconditions: 
    1) The zero flag is set if the strings are identical and cleared otherwise.
       In either case, the carry flag is cleared
    2) If both strings are equal up to 256 bytes, and no terminator is found then the carry 
       flag and zero flag are set and Y=0; otherwise they are both cleared
    3) When substrings of the 2 strings are equal, starting from the beginning, the Y register
       will contain the index of the end of the substrings.
    4) If the strings are equal, the Y register will contain their lengths. 
    5) The contents at string1Address and string2Address are left unchanged.

*/
.macro StringCompare(string1Address, string2Address, switchToFastModeWhileRunning) {

  .if (string1Address == $FF) {
    .error "error: @c128lib_StringCompare(): string1Address cannot be $FF"
  }

  .if (string2Address == $FF) {
    .error "error: @c128lib_StringCompare(): string2Address cannot be $FF"
  } 

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  begin:
    clc                 
    ldy #0                    // Start at first character (index 0) and count to 255

  compare:
    .if (string1Address <= $FE) {  // (Zero-Page),Y Mode 
      lda (string1Address), y
    } else {
      lda string1Address, y
    }
    .if (string2Address <= $FE) {
      cmp (string2Address), y     // Compare 2 characters
    } else {
      cmp string2Address, y     // Compare 2 characters
    }

    bne comp_end              // Exit if characters are not equal
                              // Z will be set to 0 on exit
                              // Else (characters are equal), but both characters could be null
    cmp #0                    // Test for end of both strings (null)
    beq comp_end              // Exit if both characters are 0 (null)
                              // Z will be set to 1 on exit (strings are equal)
                              // Else there may be more characters to compare
    iny                       // Next character
    beq no_terminator         // Loop if y = 255 or less, otherwise end (Z flag is 1, C flag is 1)
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
  
    Returns the length of a string in Y

  Params:
      stringAddress - address of string
      switchToFastModeWhileRunning - if true, fast mode will be enabled at start and disabled 
                                     at end.
  
  Preconditions:
    1) stringAddress must be a 16-bit address or 8-bit zero-page address
       holding the address of the string
    2) Zero-page address must not be greater than $FE, or error

  Postconditions: 
    1) Y register will contain the length of the string, which is also the
       address offset to null character (0). 
    2) Z will be set to 1, either because null character found, or overflow in Y 
       occured 
    3) The C flag will be 0 if length <= 255, otherwise 1.  
    4) If C flag is set, Y=0.  This also indicates the string is 256 bytes or longer 
    5) The routine terminates after 256 loops.
    6) The contents at stringAddress are left unchanged.
*/
.macro StringLength(stringAddress, switchToFastModeWhileRunning) {

  .if (stringAddress == $FF) {
    .error "error: @c128lib_StringLength(): stringAddress cannot be $FF"
  }

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  begin:
    clc
    ldy #0

  strln:	
    .if (stringAddress <= $FE) {  // (Zero-Page),Y Mode 
      lda (stringAddress), y
    }else {
      lda stringAddress, y
    }
    
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

  Preconditions:
    1. sourceAddress,destinationAddress must be a 16-bit address or 8-bit zero-page address
       holding the address of the string
    2. Zero-page address must not be greater than $FE, or error
    
  Postconditions:
    1. destinationAddress will point to a string the same as the
       string pointed to by sourceAddress
    2. Y register will contain the length of the string, which is also the
       address offset to the eol character, the null character (0). 
    3. The Z flag will be set to 1, either because null character found, or overflow in Y 
       occured   
    4. The C flag will be 0 if length <= 255, otherwise 1.  
    5. If C flag is set, Y=0.  This also indicates the string is 256 bytes or longer 
    6. The routine terminates after 256 loops.
    7. The contents at sourceAddress are left unchanged.
*/
.macro StringCopy(sourceAddress, destinationAddress, switchToFastModeWhileRunning) {

  .if (sourceAddress == $FF) {
    .error "error: @c128lib_StringCopy(): sourceAddress cannot be $FF"
  }

  .if (destinationAddress == $FF) {
    .error "error: @c128lib_StringCopy(): destinationAddress cannot be $FF"
  }

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  begin:
    ldy #0

  copystr:	
    .if (sourceAddress <= $FE) {  // (Zero-Page),Y Mode 
      lda (sourceAddress), y
    }else {
      lda sourceAddress, y
    }
    .if (destinationAddress <= $FE) {  // (Zero-Page),Y Mode 
      sta (destinationAddress), y	
    }else{
      sta destinationAddress, y
    }	
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

/*
  StringCopyLeft - Copies a left substring of length *numChars from a source address to a 
                   destination address. 

  Params:
    Inputs:
      sourceAddress                - address of source string
      destinationAddress           - destination address for copied substring
      numChars                     - address storing the number of characters 
                                     from left to copy
      switchToFastModeWhileRunning - if true, fast mode will be enabled at start and disabled 
                                     at end.

  Preconditions:
    1. *numChars <= 255
    2. sourceAddress,destinationAddress must be a 16-bit address or 8-bit zero-page address
       holding the address of the string
    3. Zero-page address must not be greater than $FE, or error

  Postconditions:
    1. destinationAddress will point to a string that is equal to the
       string pointed to by sourceAddress
    2. The contents at numChars is left unchanged
    3. The contents at sourceAddress are left unchanged.
*/
.macro StringCopyLeft(sourceAddress, destinationAddress, numChars, switchToFastModeWhileRunning) {

  .if (sourceAddress == $FF) {
    .error "error: @c128lib_StringCopyLeft(): sourceAddress cannot be $FF"
  }

  .if (destinationAddress == $FF) {
    .error "error: @c128lib_StringCopyLeft(): destinationAddress cannot be $FF"
  }

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  begin:
  	ldy #0

  copyleft:
    .if (sourceAddress <= $FE) {
      lda (sourceAddress), y
    }else{
      lda sourceAddress, y
    }
    .if (destinationAddress <= $FE) {
      sta (destinationAddress), y
    }else{
      sta destinationAddress, y
    }  	
    beq end_copy                 // If A = terminator = 0, end ==> string is shorter than *numChars
    iny                          // Next character 
    cpy numChars                 // Check y = *numChars
    bne copyleft                 // Continue copying if y < *numChars, elseif y = *numChars step out of loop
    lda #0			                 // Completed the copy, terminate the new string
    .if (destinationAddress <= $FE) {
      sta (destinationAddress), y
    }else{
      sta destinationAddress, y
    }  	

  end_copy:

  .if (switchToFastModeWhileRunning == true) {
    dec c128lib.Vic2.CLKRATE
  }
}

/*
  StringCopyRight - Copies a right substring of length *numChars from a source address to a 
                    destination address. 

  Params:
    Inputs:
      sourceAddress                - address of source string
      destinationAddress           - destination address for copied substring
      sourceStrLength              - address storing the length of source string 
                                     (required for performance, use StringLength())
      numChars                     - address storing the number of characters from right to copy
      switchToFastModeWhileRunning - if true, fast mode will be enabled at start and disabled 
                                     at end.

  Preconditions:
    1. *sourceStrLength <= 255
    2. *numChars <= 255
    3. sourceAddress,destinationAddress must be a 16-bit address or 8-bit zero-page address
       holding the address of the string
    4. Zero-page address must not be greater than $FE, or error
  Postconditions:
    1. destinationAddress will point to a substring that is equal to the
       right substring of length *numChars pointed to by sourceAddress
    2. The contents at sourceAddress will be left unchanged.
    3. The contents at numChars will be left unchanged.
*/
.macro StringCopyRight(sourceAddress, destinationAddress, sourceStrLength, numChars, switchToFastModeWhileRunning) {

  .if (sourceAddress == $FF) {
    .error "error: @c128lib_StringCopyRight(): sourceAddress cannot be $FF"
  }

  .if (destinationAddress == $FF) {
    .error "error: @c128lib_StringCopyRight(): destinationAddress cannot be $FF"
  }

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  begin:
    clc

    ldy sourceStrLength               // start at end of string
    beq end                           // if strLength is 0, just end
    dey                               // indexing starts from 0, so subract 1 from length

    ldx numChars                      // x will hold index of destination string
    beq end                           // if *numChars is 0, just end
    lda #0                            // null character
    .if (destinationAddress <= $FE) {
      sta (destinationAddress), x         // terminate the new string
    }
    else{
      sta destinationAddress, x         // terminate the new string
    }
    dex                               // indexing starts from 0, so subtract 1 from *numChars


  copyright:
    .if (sourceAddress <= $FE) {
      lda (sourceAddress), y              // load next character (moving right)
    }else{
      lda sourceAddress, y              // load next character (moving right)
    }
  	.if (destinationAddress <= $FE) {
      sta (destinationAddress), x         // copy character (staring from right, moving right)
    }else{
      sta destinationAddress, x         // copy character (staring from right, moving right)
    }
    dey                               // next character
    dex                               // next position in destination string
    cpx #$FF                          // Gone past 0? 
    bne copyright                     // loop as long as x >= 0

  end:

  .if (switchToFastModeWhileRunning == true) {
    dec c128lib.Vic2.CLKRATE
  } 

}

/*
  StringCopyMid -   Copies a substring of a string, starting from a given index, and of length numChars 
                    from a source address to a destination address. 

  Params:
    Inputs:
      sourceAddress                - address of source string
      destinationAddress           - destination address for copied substring
      startPos                     - address to starting position of the substring
      numChars                     - address to the number of characters from the 
                                     starting position of the substring
      switchToFastModeWhileRunning - if true, fast mode will be enabled at start and disabled 
                                     at end.

  Preconditions:
    1. *startPos <= 255
    2. *numChars <= 255
    3. *startPos + *numChars <= 255
    4. sourceAddress,destinationAddress must be a 16-bit address or 8-bit zero-page address
       holding the address of the string
    5. Zero-page address must not be greater than $FE, or error
  Postconditions:
    1. destinationAddress will point to a substring that is equal to the
       substring defined by the start position and length of the string
       at sourceAddress
    2. The contents at sourceAddress will remain unchanged.
    3. The contents at startPos will remain unchanged.
    4. The contents at numChars will remain unchanged.
*/
.macro StringCopyMid(sourceAddress, destinationAddress, startPos, numChars, switchToFastModeWhileRunning) {

  .if (sourceAddress == $FF) {
    .error "error: @c128lib_StringCopyMid(): sourceAddress cannot be $FF"
  }

  .if (destinationAddress == $FF) {
    .error "error: @c128lib_StringCopyMid(): destinationAddress cannot be $FF"
  }

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  begin:
    ldy startPos                   // Staring position of source string (0 indexed)
    ldx #0                         // Destination string index - 0 to *numChars-1

  copymid:
    .if (sourceAddress <= $FE) {
      lda (sourceAddress), y           // load next character
    }else{
      lda sourceAddress, y           // load next character
    }
    .if (destinationAddress <= $FE) {
      sta (destinationAddress), x      // store character to destination string
    }else{
      sta destinationAddress, x      // store character to destination string
    }
    iny                            // set position for next source character
    beq end                        // end of source string, so stop
    inx                            // set position for next target character
    cpx numChars                   
    beq end                        // went past end of destination string?

  end:
    lda #0                            // null character
    .if (destinationAddress <= $FE) {
      sta (destinationAddress), x     // terminate destination string
    }else{
      sta destinationAddress, x      // terminate destination string
    }  

  .if (switchToFastModeWhileRunning == true) {
    dec c128lib.Vic2.CLKRATE
  } 

}

/*
  StringConcatenate - Concatenat string2 to string1.  The resultng string
                      will be located at the address of string1.

  Params:
    Inputs:
      string1Address               - address of first string
      string2Address               - address of second string
      string1Length                - address to the length of string1 
                                    (required for performance, use StringLength())
      switchToFastModeWhileRunning - if true, fast mode will be enabled at start and disabled 
                                     at end.

  Preconditions:
    1. *string1Length <= 255
    2. string1Address,string2Address must be a 16-bit address or 8-bit zero-page address
       holding the address of the string
    3. Zero-page address must not be greater than $FE, or error
  Postconditions:
    1. The resultng string will be located at the address of string1 (string1Address)
    2. If the length of string2 is greater than 256, only the first 256 characters will
       be concatented.
    3. The contents at string2Address will remain unchanged.
    4. The contents at string1Length will remain unchanged.
*/
.macro StringConcatenate(string1Address, string2Address, string1Length, switchToFastModeWhileRunning) {

  .if (string1Address == $FF) {
    .error "error: @c128lib_StringConcatenate(): string1Address cannot be $FF"
  }

  .if (string2Address == $FF) {
    .error "error: @c128lib_StringConcatenate(): string2Address cannot be $FF"
  }

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  begin:

   .if (string1Address <= $FE){  // User is sending zero-page address for indirect indexing.
    /* Store what's in string1Address and string1Address+1 on the stack temporarily,
       as we will be changing the contents.  The original contents will be restored at the end. */
    lda string1Address+1   //high byte first
    pha
    lda string1Address     //low byte last
    pha

   }else{ // We'll store the absolute address at zero page, so that we can add an offest to this address.
    /* Store what's in our zero-page STRING_TRG and STRING_TRG+1 on the stack temporarily,
       as we will be changing the contents.  The original contents will be restored at the end. */
    lda String.STRING_TRG+1   //high byte first
    pha
    lda String.STRING_TRG     //low byte last
    pha
    
    lda #<string1Address
    sta String.STRING_TRG
    lda #>string1Address
    sta String.STRING_TRG+1
   }

  move_pointer_to_end:
    clc
    .if (string1Address <= $FE) {
      lda string1Address            // hold low byte of string1 address 
      adc string1Length             // add length
      sta string1Address            // update low byte
      lda string1Address+1          // hold high byte of string1 address
      adc #0                        // adding the carry if any
      sta string1Address+1          // pointer is now at end of the string
    }else{
      lda String.STRING_TRG         // hold low byte of string1 address 
      adc string1Length             // add length
      sta String.STRING_TRG         // update low byte
      lda String.STRING_TRG+1       // hold high byte of string1 address
      adc #0                        // adding the carry if any
      sta String.STRING_TRG+1       // pointer is now at end of the string
    }


  concat:
    ldy #0

  copystr:	
    .if (string2Address <= $FE){
      lda (string2Address), y       // Post-Indexed Indirect, "(Zero-Page),Y"
    }else{
      lda string2Address, y         // absolute, y
    }
    .if (string1Address <= $FE){
      sta (string1Address), y	
    }else{
      sta (String.STRING_TRG), y	
    }

    beq copy_end                       // Hit terminator, Z=1, C=0
    iny
    beq no_terminator                  // y > 255, Z=1, C=0
    jmp copystr

  no_terminator:
    sec                               // y > 255, Z=1, C=1

  copy_end:

   .if (string1Address <= $FE){  // User is sending zero-page address for indirect indexing.
    // restore user-referenced zero-page addresses as originally set by user.
    pla
    sta string1Address   
    pla
    lda string1Address+1     

   }else{ // User sent absolute address
    // restore these zero-page addresses to the state they were at before calling the routine.
    pla
    sta String.STRING_TRG
    pla
    sta String.STRING_TRG+1
   }

  .if (switchToFastModeWhileRunning == true) {
    dec c128lib.Vic2.CLKRATE
  } 

}


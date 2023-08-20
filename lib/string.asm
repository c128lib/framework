/**
 * @brief String manipulation module
 * @details The strings are a maximum of 255 bytes long and are null terminated. The null character 
 * makes the interal storage a max of 256 bytes.  For strings 256 bytes and longer,
 * these macros can be repeated for each set of 256 bytes.
 *
 * String addresses can be absolute addresses or post-indexed indirect, "(Zero-Page), Y".
 * To be clear, if passing a zero-page address, it is implied that the address is an
 * indirect address that will be post-indexed by Y by the macro.  So, the zero page 
 * address will hold the absolute address (small endian) of the string.
 * Only pass the zero-page address without brackets, such as $FA.  Last usable zero-page
 * address for post-indexed indirect addressing mode is $FE, so do not pass $FF.
 *
 * Numeric parameters must be an address.  That is, store the number in an address (zero-page
 * or 16-bit) and then pass the address to the parameter.  In the comments, these parameters 
 * will be dereferenced by the *, as in C notation.  For example, numChars is the address, and
 * numChars is the value stored at address numChars.
 *
 * Notes:
 * When a post condition is that the carry is set, a programmer can repeat these macros 
 * for strings 256 chars or longer.  The programmer would call the macros as many times 
 * as the number of 256-byte strings needed for memory allocation of the string. 
 * In this way, a programmer can create a string data type with length longer than 255.  
 * In this case, multiple 256-byte strings could be used to represent a long string, with 
 * each 256-byte string holding 256 characters, excluding the terminator (#0), except for 
 * the last byte 256-byte string which must be terminated at 255.
 *
 * Examples will be given in the official documentation.
 *
 * @copyright MIT Licensed
 * @date 2023
 */

#importonce
.filenamespace c128lib

.namespace String {
  .label ZP_SRC = $FA
  .label ZP_TRG = $FC  
}

/**
  Push an address, stored in the zero page, to the stack
*/
.pseudocommand zpPush zpAddress {
    lda zpAddress.getValue()+1   // lda zpAddress+1 // high byte first
    pha
    lda zpAddress                // low byte last
    pha
}

/**
  Pull an address from the stack to the zero page
*/
.pseudocommand zpPull zpAddress {
    pla
    sta zpAddress                 // low byte first
    pla
    sta zpAddress.getValue()+1    // sta zpAddress+1   //high byte last
}

/**
  Load an absolute address into the zero page.
*/
.pseudocommand zpLoadAddress absAddress:zpAddress {
    lda CmdArgument(AT_IMMEDIATE, <absAddress.getValue()) // lda #<absAddress  //low byte first
    sta zpAddress
    lda CmdArgument(AT_IMMEDIATE, >absAddress.getValue()) // lda #>absAddress  //high byte second
    sta zpAddress.getValue()+1                            // sta zpAddress+1  
}

/* 
  Move a pointer, stored in the zero page, by offset
*/
.pseudocommand zpMove zpAddress:offset {
      clc
      lda zpAddress               // hold low byte
      adc offset                  // add offset
      sta zpAddress               // update low byte
      lda zpAddress.getValue()+1  // lda zpAddress+1          // hold high byte 
      adc #0                      // adding the carry if any
      sta zpAddress.getValue()+1  // sta zpAddress+1          // pointer is now at new address 
}

/**
  Determine if two strings are equal.
    
  @param[in] string1Address Address of string1
  @param[in] string2Address Address of string2
  @param[in] switchToFastModeWhileRunning If true, fast mode will be enabled at start and disabled at end.
  
  @remark Registers .A and .Y will be modified.
  @remark Flags N, Z and C will be affected.

  @note Use c128lib_StringCompare in string-global.asm

  @pre
    1. string1Address, string2Address must be a 16-bit address or 8-bit zero-page address
       holding the address of the string
    2. Zero-page address must not be greater than $FE, or error

  @post 
    1. The zero flag is set if the strings are identical and cleared otherwise.
       In either case, the carry flag is cleared
    2. If both strings are equal up to 256 bytes, and no terminator is found then the carry 
       flag and zero flag are set and Y=0; otherwise they are both cleared
    3. When substrings of the 2 strings are equal, starting from the beginning, the Y register
       will contain the index of the end of the substrings.
    4. If the strings are equal, the Y register will contain their lengths. 
    5. The contents at string1Address and string2Address are left unchanged.

  @since 0.1.0
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

/**
  Find the length of a string. 

  @param[in] stringAddress Address of string
  @param[in] switchToFastModeWhileRunning If true, fast mode will be enabled at start and disabled 
    at end.

  @remark Registers .A and .Y will be modified.
  @remark Flags N, Z and C will be affected.

  @note Use c128lib_StringLength in string-global.asm

  @pre
    1. stringAddress must be a 16-bit address or 8-bit zero-page address
       holding the address of the string
    2. Zero-page address must not be greater than $FE, or error

  @post
    1. Y register will contain the length of the string, which is also the
       address offset to null character (0). 
    2. Z will be set to 1, either because null character found, or overflow in Y 
       occured 
    3. The C flag will be 0 if length <= 255, otherwise 1.  
    4. If C flag is set, Y=0.  This also indicates the string is 256 bytes or longer 
    5. The routine terminates after 256 loops.
    6. The contents at stringAddress are left unchanged.

  @since 0.1.0
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

/**
  Copies a string from a source address to a destination address

  @param[in] sourceAddress Address of source string
  @param[out] destinationAddress Destination address for copied string
  @param[in] switchToFastModeWhileRunning If true, fast mode will be enabled at start and disabled 
    at end.

  @remark Registers .A and .Y will be modified.
  @remark Flags N, Z and C will be affected.

  @note Use c128lib_StringCopy in string-global.asm

  @pre
    1. sourceAddress,destinationAddress must be a 16-bit address or 8-bit zero-page address
       holding the address of the string

    2. Zero-page address must not be greater than $FE, or error
    
  @post 
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

  @since 0.1.0
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

/**
  Copies a left substring of length *numChars from a source address to a 
  destination address. 

  @param[in] sourceAddress Address of source string
  @param[out] destinationAddress Destination address for copied substring
  @param[in] numChars Address storing the number of characters 
    from left to copy
  @param[in] switchToFastModeWhileRunning If true, fast mode will be enabled at start and disabled 
    at end.

  @remark Registers .A and .Y will be modified.
  @remark Flags N, Z and C will be affected.

  @note Use c128lib_StringCopyLeft in string-global.asm

  @pre
    1. *numChars <= 255
    2. sourceAddress,destinationAddress must be a 16-bit address or 8-bit zero-page address
       holding the address of the string
    3. Zero-page address must not be greater than $FE, or error

  @post 
    1. destinationAddress will point to a string that is equal to the
       string pointed to by sourceAddress
    2. The contents at numChars is left unchanged
    3. The contents at sourceAddress are left unchanged.

  @since 0.1.0
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

/**
  Copies a right substring of length *numChars from a source address to a 
  destination address. 

  @param[in] sourceAddress Address of source string
  @param[out] destinationAddress Destination address for copied substring
  @param[in] sourceStrLength Address storing the length of source string 
    (required for performance, use StringLength())
  @param[in] numChars Address storing the number of characters from right to copy
  @param[in] switchToFastModeWhileRunning If true, fast mode will be enabled at start and disabled 
    at end.

  @remark Registers .A and .Y will be modified.
  @remark Flags N, Z and C will be affected.

  @note Use c128lib_StringCopyRight in string-global.asm

  @pre
    1. *sourceStrLength <= 255
    2. *numChars <= 255
    3. sourceAddress,destinationAddress must be a 16-bit address or 8-bit zero-page address
       holding the address of the string
    4. Zero-page address must not be greater than $FE, or error

  @post 
    1. destinationAddress will point to a substring that is equal to the
       right substring of length *numChars pointed to by sourceAddress
    2. The contents at sourceAddress will be left unchanged.
    3. The contents at sourceStrLength will be left unchanged.
    4. The contents at numChars will be left unchanged.

  @since 0.1.0
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

  jmp begin

  startPos:
    .byte  0

  begin:
    lda sourceStrLength
    cmp numChars
    bcs get_startpos                  // if *sourceStrLength >= *numChars, all normal
    sta numChars                      // else, set *numChars = *sourceStrLength

  get_startpos:    
    sec
    sbc numChars                      // get starting position of source string 
    sta startPos
  
    StringCopyMid(sourceAddress, destinationAddress, startPos, numChars, switchToFastModeWhileRunning)

}

/**
  Copies a substring of a string, starting from a given index, and of length numChars 
  from a source address to a destination address. 

  @param[in] sourceAddress Address of source string
  @param[out] destinationAddress Destination address for copied substring
  @param[in] startPos Address of memory holding starting position of the substring,
    where the first postion is 0
  @param[in] numChars Address of memory holding the number of characters from the 
    starting position of the substring
  @param[in] switchToFastModeWhileRunning If true, fast mode will be enabled at start and disabled 
    at end.

  @remark Registers .A and .Y will be modified.
  @remark Flags N, Z and C will be affected.

  @note Use c128lib_StringCopyMid in string-global.asm

  @pre
    1. *startPos <= 255
    2. *numChars <= 255
    3. *startPos + *numChars <= 255
    4. sourceAddress,destinationAddress must be a 16-bit address or 8-bit zero-page address
       holding the address of the string
    5. Zero-page address must not be greater than $FE, or error

  @post 
    1. destinationAddress will point to a substring that is equal to the
       substring defined by the start position and length of the string
       at sourceAddress
    2. The contents at sourceAddress will remain unchanged.
    3. The contents at startPos will remain unchanged.
    4. The contents at numChars will remain unchanged.

  @since 0.1.0
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

   .if (sourceAddress <= $FE){  // User is sending zero-page address for indirect indexing.
      /* Store what's in string1Address and string1Address+1 on the stack temporarily,
          as we will be changing the contents.  The original contents will be restored at the end. */   
      zpPush sourceAddress                             // push address stored in zero page to the stack.
      zpMove sourceAddress : startPos                  // move pointer by offset <startPos>
      StringCopyLeft(sourceAddress, destinationAddress, numChars, switchToFastModeWhileRunning)
   }else{ // need zero-page to do some math
      zpPush String.ZP_SRC                             // save what's in String.ZP_SRC to restore later
      zpLoadAddress sourceAddress : String.ZP_SRC      // load absolute address into zero page
      zpMove String.ZP_SRC : startPos                  // move pointer by offset <startPos>
      StringCopyLeft(String.ZP_SRC, destinationAddress, numChars, switchToFastModeWhileRunning)
   }

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  .if (sourceAddress <= $FE){  
    zpPull sourceAddress                             // pull orginal address back to the zero page
  }else{
    zpPull String.ZP_SRC                             // restore String.ZP_SRC
  }

  .if (switchToFastModeWhileRunning == true) {
    dec c128lib.Vic2.CLKRATE
  } 
}

/**
  Concatenate string2 to string1. The resulting string
  will be located at the address of string1.

  @param[inout] string1Address Address of first string
  @param[in] string2Address Address of second string
  @param[in] string1Length Address to the length of string1 
    (required for performance, use StringLength())
  @param[in] switchToFastModeWhileRunning If true, fast mode will be enabled at start and disabled 
    at end.

  @remark Registers .A and .Y will be modified.
  @remark Flags N, Z and C will be affected.

  @note Use c128lib_StringConcatenate in string-global.asm

  @pre
    1. *string1Length <= 255
    2. string1Address,string2Address must be a 16-bit address or 8-bit zero-page address
       holding the address of the string
    3. Zero-page address must not be greater than $FE, or error

  @post 
    1. The resultng string will be located at the address of string1 (string1Address)
    2. If the length of string2 is greater than 256, only the first 256 characters will
       be concatented.
    3. The contents at string2Address will remain unchanged.
    4. The contents at string1Length will remain unchanged.

  @since 0.1.0
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
      zpPush string1Address                             // push address stored in zero page to the stack.
      zpMove string1Address : string1Length             // move pointer to end of string
      StringCopy(string2Address, string1Address, switchToFastModeWhileRunning)
      
   }else{ // need zero-page to do some math
      zpPush String.ZP_TRG                              // save what's in String.ZP_TRG to restore later
      zpLoadAddress string1Address : String.ZP_TRG      // load absolute address into zero page
      zpMove String.ZP_TRG : string1Length              // move pointer to end of string
      StringCopy(string2Address, String.ZP_TRG, switchToFastModeWhileRunning)
   }

  .if (switchToFastModeWhileRunning == true) {
    lda #1
    sta c128lib.Vic2.CLKRATE
  }

  .if (string1Address <= $FE){  
    zpPull string1Address                            // pull orginal address back to the zero page
  }else{
    zpPull String.ZP_TRG                             // restore String.ZP_TRG
  }

  .if (switchToFastModeWhileRunning == true) {
    dec c128lib.Vic2.CLKRATE
  } 

}

/**
  Convert an 8-bit integer to an ASCII string.

  @param[in]  int8Arg           Immediate value or address of 8-bit integer
  @param[out] stringAddressArg  Address of ASCII string representation of int8Arg

  @remark Registers .A, .X, and .Y will be modified.
  @remark Flags N, Z and C will be affected.

  @note Use c128lib_Int8ToString in string-global.asm

  @pre
    1. int8Arg can only accept arguments of immediate mode or absolute mode addressing.
       That is, pass only arguments like #201 or addressOfInt
    2. Macro will assume 8-bit value for int8Arg. 

  @post 
    1. stringAddressArg will point to 3 byte ASCII string.
    2. Leading zeros will be maintained in the 3 byte string, such as "001" or "023".
    3. Macro will assume that string is formally defined by user and null terminated.

  @since 0.2.0
*/

.pseudocommand Int8ToString int8Arg:stringAddressArg {

  .var stringAddress  //Address value of argument stringAddressArg

  .print "int8Arg = " + int8Arg                   //For debugging purposes
  .print "int8 Value = " + int8Arg.getValue()     //For debugging purposes
  .print "stringAddressArg = " + stringAddressArg //For debuggin purposes

  .if (!(int8Arg.getType()==AT_IMMEDIATE || // Like #10
       int8Arg.getType()==AT_ABSOLUTE ))    // Like $1000
       {
        .error "@c128lib_Int8ToString: Argument int8Arg can only have addressing modes immediate or absolute."
       }   

  .if (stringAddressArg.getType()==AT_ABSOLUTE) // Like $1000 
      {
        .eval stringAddress = stringAddressArg.getValue()
        .print "stringAddress = " + stringAddress
      } 
  else 
      {
        .error "@c128lib_Int8ToString: Argument stringAddressArg can only have addressing mode absolute."
      }

  jmp begin

  holdA:
    .byte 0                 // To hold .A for next loop if subtraction is negative

  subtrahend:
    .byte 100, 10, 1        // Subtrahend used for subtraction at each decimal place

  begin:
    ldx #48                 // ASCII "0"
    ldy #0                  // Offset for subtrahend (0-2) 
    sec                     // C = 1

  check_zero:               // check if int8 = 0
    lda int8Arg  
    cmp #0                
    beq do_zero             // if 0, use faster code

  subtract_subtrahend:
    sta holdA               // hold .A for next loop
  next_subtrahend:  
    sec                     // C = 1      
    sbc subtrahend,y        // Subtract subtrahend
    inx                     // Increment weight of decimal place by 1
    bcs subtract_subtrahend // If not negative, continue loop

    dex                     // Once .A becomes negative, .X is off by 1, so decrement
    txa                     // stx doesn't support ABSOLUTE,Y
    sta stringAddress,y     // Store decimal place's value at next byte in string
  
    ldx #48                 // Reset .X to ASCII "0" for next decimal place
    iny                     // Next subtrahend
    lda holdA               // Restore .A from previous pass, which was negative

    cpy #2                  // No need to continue if we're at 1's decimal place.
    bne next_subtrahend     // If not at 1's decimal place, continue loop

    clc                     
    adc #48                 // Simply add ASCII 48 ("0") to value at 1's decimal place
    sta stringAddress,y     // Store decimal place's value at next byte in string
    
    jmp end                 // Finished

  do_zero:                  // Fast code for 0 integer
    txa                     // stx doesn't support ABSOLUTE,Y
    sta stringAddress,y   
    iny                   
    cpy #3                
    bne do_zero

  end:

}

#import "chipset/lib/vic2.asm"

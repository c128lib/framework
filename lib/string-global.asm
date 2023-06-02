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

/**
  Determine if two strings are equal.
    
  @param[in] string1Address Address of string1
  @param[in] string2Address Address of string2
  @param[in] switchToFastModeWhileRunning If true, fast mode will be enabled at start and disabled at end.
  
  @remark Registers .A and .Y will be modified.
  @remark Flags N, Z and C will be affected.

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
.macro @c128lib_StringCompare(string1Address, string2Address, switchToFastModeWhileRunning) { StringCompare(string1Address, string2Address, switchToFastModeWhileRunning) }

/**
  Find the length of a string. 

  @param[in] stringAddress Address of string
  @param[in] switchToFastModeWhileRunning If true, fast mode will be enabled at start and disabled 
    at end.

  @remark Registers .A and .Y will be modified.
  @remark Flags N, Z and C will be affected.

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
.macro @c128lib_StringLength(stringAddress, switchToFastModeWhileRunning) { StringLength(stringAddress, switchToFastModeWhileRunning) }

/**
  Copies a string from a source address to a destination address

  @param[in] sourceAddress Address of source string
  @param[out] destinationAddress Destination address for copied string
  @param[in] switchToFastModeWhileRunning If true, fast mode will be enabled at start and disabled 
    at end.

  @remark Registers .A and .Y will be modified.
  @remark Flags N, Z and C will be affected.

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
.macro @c128lib_StringCopy(sourceAddress, destinationAddress, switchToFastModeWhileRunning) { StringCopy(sourceAddress, destinationAddress, switchToFastModeWhileRunning) }

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
.macro @c128lib_StringCopyLeft(sourceAddress, destinationAddress, numChars, switchToFastModeWhileRunning) { StringCopyLeft(sourceAddress, destinationAddress, numChars, switchToFastModeWhileRunning) }

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
.macro @c128lib_StringCopyRight(sourceAddress, destinationAddress, sourceStrLength, numChars, switchToFastModeWhileRunning) { StringCopyRight(sourceAddress, destinationAddress, sourceStrLength, numChars, switchToFastModeWhileRunning) }

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
.macro @c128lib_StringCopyMid(sourceAddress, destinationAddress, startPos, numChars, switchToFastModeWhileRunning) { StringCopyMid(sourceAddress, destinationAddress, startPos, numChars, switchToFastModeWhileRunning) }

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
.macro @c128lib_StringConcatenate(string1Address, string2Address, string1Length, switchToFastModeWhileRunning) { StringConcatenate(string1Address, string2Address, string1Length, switchToFastModeWhileRunning) }

#import "string.asm"

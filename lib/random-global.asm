/**
 * @brief Random number generator module
 * @details This module contains a bunch of macros for
 * random number generation. There are mainly two
 * types of generetions: random and pseudo-random
 * Pseudo-random generator creates random numbers inside
 * a sequence based on alghorithm.
 * Random generator try to create an unpredictable number
 * sequence.
 *
 * Random number generator must be initialized before use.
 *
 * @copyright MIT Licensed
 * @date 2023
 */

#importonce
.filenamespace c128lib

/**
 * @brief This macro generates a pseudo-random number.
 *
 * @details The macro uses the Linear Feedback Shift Register (LFSR) method to generate a pseudo-random number.
 * It is guaranteed to create a sequence touching every element from 0 to $ff just once.
 * Seed must be provided in accumulator and can be from 0 to $ff. Output number will be available in the accumulator. 
 * It performs an arithmetic shift left (ASL) on the accumulator. If the result is zero or if the carry flag is set, 
 * it skips the exclusive OR (EOR) operation. Otherwise, it performs the EOR operation with the hexadecimal value 0x1D.
 *
 * @note The generated pseudo-random number is stored in the accumulator (.A register).
 *
 * @remark Register .A must contain seed and will contain pseudo random number generated.
 *         Flags N, Z and C will be affected.
 *
 * @remark Use c128lib_PseudoRandom in random-global.asm
 *
 * @since 0.1.0
 */
.macro @c128lib_PseudoRandom() { PseudoRandom() }

/**
 * Init random number generator based on the Sid chip. When used,
 * voice 3 of Sid chip can't be used for playback sounds.
 *
 * @remark Register .A will be changed.
 *   Flags N and Z will be affected.
 * @sa c128lib_GetRandomNumberFromSid
 *
 * @since 0.1.0
 */
.macro @c128lib_InitSid() { InitSid() }

/**
 * Get a new random number from the Sid chip and puts it
 * into the .A register. Random numbers are continuously
 * generated so each call gives a new random number.
 * Generetor must be initialized with InitSid().
 *
 * @remark Register .A will be changed.
 *   Flags N and Z will be affected.
 * @sa c128lib_InitSid
 *
 * @since 0.1.0
 */
.macro @c128lib_GetRandomNumberFromSid() { GetRandomNumberFromSid() }

#import "random.asm"

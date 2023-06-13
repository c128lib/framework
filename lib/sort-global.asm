/**
 * @brief Sort module
 * @details Macros for array sorting.
 *
 * @copyright MIT Licensed
 * @date 2023
 */

#importonce
.filenamespace c128lib

/**
  Sort a 8-bit value array with bubble sort algorithm.
  Sorted array will be available in the same source
  address.
  Fast mode can be switched on/off while algorithm
  is running.

  @param[inout] arrayAddress Memory address of array
  @param[in] arraySize Array size
  @param[in] switchToFastModeWhileRunning If true, fast mode
    will be enabled at start and disabled at end

  @remark Registers .A, .X and .Y will be modified

  @since 0.1.0
*/
.macro @c128lib_BubbleSort(indirizzoArray, dimensioneArray, switchToFastModeWhileRunning) { BubbleSort(indirizzoArray, dimensioneArray, switchToFastModeWhileRunning) }

#import "sort.asm"

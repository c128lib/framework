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
 * @brief This macro implements the Bubble Sort algorithm.
 *
 * @param[inout] arrayAddress The starting address of the array to be sorted.
 * @param[in] arraySize The size of the array to be sorted.
 * @param[in] switchToFastModeWhileRunning If true, the macro will switch to 8502 fast mode.
 *
 * @details This macro sorts an array in ascending order using the Bubble Sort algorithm. 
 *          If 'switchToFastModeWhileRunning' is true, the macro will switch to 8502 fast mode while running.
 *          This can be beneficial for larger arrays.
 *
 * @note The sorted array is available at the same memory address as the input array.
 *       The macro modifies the .A, .X, and .Y registers. If you're using these registers elsewhere in your code, 
 *       you'll need to save their values before calling this macro and restore them afterward.
 *
 * @since 0.1.0
 */
.macro @c128lib_BubbleSort(indirizzoArray, dimensioneArray, switchToFastModeWhileRunning) { BubbleSort(indirizzoArray, dimensioneArray, switchToFastModeWhileRunning) }

#import "sort.asm"

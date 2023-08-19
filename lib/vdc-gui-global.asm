/**
 * @brief Gui module
 * @details Macros for generating Gui
 *
 * @copyright MIT Licensed
 * @date 2023
 */

#importonce
.filenamespace c128lib

.macro @c128lib_CreateWindow(x, y, width, height) { CreateWindow(x, y, width, height) }

#import "vdc-gui.asm"

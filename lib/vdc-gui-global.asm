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
.macro @c128lib_CreateWindowWithTitle(x, y, width, height, title, length) { CreateWindowWithTitle(x, y, width, height, title, length) }

#import "vdc-gui.asm"

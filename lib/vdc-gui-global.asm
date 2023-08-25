/**
 * @brief Gui module
 * @details Macros for generating Gui
 *
 * @copyright MIT Licensed
 * @date 2023
 */

#importonce
.filenamespace c128lib

/**
  Draws a window in Vdc screen with rounded corner

  @param[in] x Starting column
  @param[in] y Starting row
  @param[in] width Window width
  @param[in] height Window height

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @since 0.2.0
*/
.macro @c128lib_CreateWindow(x, y, width, height) { CreateWindow(x, y, width, height) }
/**
  Draws a window in Vdc screen with rounded corner and prints a title in
  first row

  @param[in] x Starting column
  @param[in] y Starting row
  @param[in] width Window width
  @param[in] height Window height
  @param[in] text Title string address
  @param[in] length Title string length

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @since 0.2.0
*/
.macro @c128lib_CreateWindowWithTitle(x, y, width, height, text, length) { CreateWindowWithTitle(x, y, width, height, text, length) }
/**
  Print a label at coordinates

  @param[in] x Starting column
  @param[in] y Starting row
  @param[in] text Label string address
  @param[in] length Label string length

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @since 0.2.0
*/
.macro @c128lib_Label(x, y, text, length) { Label(x, y, text, length) }

#import "vdc-gui.asm"

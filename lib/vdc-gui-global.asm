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
  Draws a window in Vdc screen with rounded corner and prints a title in
  first row. Title screen and border color is set with specified argument

  @param[in] x Starting column
  @param[in] y Starting row
  @param[in] width Window width
  @param[in] height Window height
  @param[in] text Title string address
  @param[in] length Title string length
  @param[in] color Vdc color code and attribute

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @since 0.2.0
*/
.macro @c128lib_CreateWindowWithTitleColor(x, y, width, height, text, length, color) { CreateWindowWithTitleColor(x, y, width, height, text, length, color) }
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
/**
  Print a label at coordinates with specified color

  @param[in] x Starting column
  @param[in] y Starting row
  @param[in] text Label string address
  @param[in] length Label string length
  @param[in] color Vdc color code and attribute

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @since 0.2.0
*/
.macro @c128lib_LabelWithColor(x, y, text, length, color) { LabelWithColor(x, y, text, length, color) }
/**
  Set color in attribute memory for specified coordinates

  @param[in] x Starting column
  @param[in] y Starting row
  @param[in] color Vdc color code and attribute
  @param[in] length Label string length

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @since 0.2.0
*/
.macro @c128lib_Color(x, y, color, length) { Color(x, y, color, length) }

#import "vdc-gui.asm"

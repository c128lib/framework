/**
 * @brief Gui module
 * @details Macros for generating Gui
 *
 * @copyright Copyright (c) 2023 c128lib - https://github.com/c128lib
 *
 * MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
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

.macro @c128lib_ProgressBar(x, y, width, step, position) { ProgressBar(x, y, width, step, position) }

#import "vdc-gui.asm"

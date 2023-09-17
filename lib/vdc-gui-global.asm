/*
 * Vdc gui module
 *
 * Copyright (c) 2023 c128lib - https://github.com/c128lib
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
 */

#importonce
.filenamespace c128lib

/**
  Draws a window in Vdc screen

  @param[in] position Starting (x,y) position window
  @param[in] size Window (x,y) size
  @param[in] windowTitle Defines window title
  @param[in] windowParameters Defines window parameters

  @see WindowParameters

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @code
    c128lib_Window(
      Point(10, 3),
      Size(20, 10),
      WindowParameters(
        LabelText(Title, 15),   // Set title
        WindowBorders(),        // Use default borders
        true))                  // Make window opaque
  @endcode

  @code
    c128lib_Window(
      Point(10, 3),
      Size(20, 10),
      WindowParameters(
        LabelText(null, 0),     // Don't set title
        WindowBorders(85, 66, 74, 67, 75, 66, 73, 67), // Use custom chars for borders
        false))                 // Make window transparent
  @endcode

  @attention Don't overlap window with color and window without color.
  Strange color behavior occour.

  @since 0.2.0
*/
.macro @c128lib_Window(position, size, windowTitle, windowParameters) { Window(position, size, windowTitle, windowParameters) }
/**
  Draws a window in Vdc screen with specific color

  @param[in] position Starting (x,y) position window
  @param[in] size Window (x,y) size
  @param[in] windowTitle Defines window title
  @param[in] windowParameters Defines window parameters
  @param[in] color Defines which color to use

  @see WindowParameters

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @note Use colors defined in chipset/Vdc

  @code
    c128lib_WindowWithColor(
      Point(10, 3),
      Size(20, 10),
      WindowParameters(
        LabelText(Title, 15),   // Set title
        WindowBorders(),        // Use default borders
        true),                  // Make window opaque
        c128lib.Vdc.VDC_LIGHT_YELLOW) // Set color
  @endcode

  @code
    c128lib_WindowWithColor(
      Point(10, 3),
      Size(20, 10),
      WindowParameters(
        10, 3, 20, 10,          // Set window size
        LabelText(null, 0),     // Don't set title
        WindowBorders(85, 66, 74, 67, 75, 66, 73, 67), // Use custom chars for borders
        false),                 // Make window transparent
        c128lib.Vdc.VDC_LIGHT_YELLOW) // Set color
  @endcode

  @attention Don't overlap window with color and window without color.
  Strange color behavior occour.

  @since 0.2.0
*/
.macro @c128lib_WindowWithColor(position, size, windowTitle, windowParameters, color) { WindowWithColor(position, size, windowTitle, windowParameters, color) }

/**
  Print a label at coordinates

  @param[in] position Starting (x, y) label position
  @param[in] label Label definition

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @since 0.2.0
*/
.macro @c128lib_Label(position, label) { Label(position, label) }
/**
  Set color in attribute memory for specified coordinates

  @param[in] position Coloring (x,y) starting position
  @param[in] color Vdc color code and attribute
  @param[in] length Label string length

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @since 0.2.0
*/
.macro @c128lib_Color(position, color, length) { Color(position, color, length) }
/**
  Print a label at coordinates with specified color

  @param[in] position Starting (x, y) label position
  @param[in] label Label definition
  @param[in] color Vdc color code and attribute

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @since 0.2.0
*/
.macro @c128lib_LabelWithColor(position, label, color) { LabelWithColor(position, label, color) }

/**
  Prints a progress bar at coordinates

  @param[in] position Starting (x, y) progress bar position
  @param[in] progressBarParameters Defines progress bar parameters

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @see ProgressBarParameters

  @code
    c128lib_ProgressBar(
      Point(0, 0),
      ProgressBarParameters(
        12,           // Set progress bar width
        5, 2,         // Set step count and current position
        ProgressBarStyle(58, 59, 87, 88)) // Set custom style
    );
  @endcode

  @code
    c128lib_ProgressBar(
      Point(0, 3),
      ProgressBarParameters(
        12,           // Set progress bar position and width
        5, 4,         // Set step count and current position
        ProgressBarStyle()) // Set default style
    );
  @endcode

  @since 0.2.0
*/
.macro @c128lib_ProgressBar(position, progressBarParameters) { ProgressBar(position, progressBarParameters) }

/**
  Print a button at coordinates

  @param[in] position Button (x,y) position
  @param[in] label Button label definition

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @code
    c128lib_Button(
      Point(45, 9),
      ButtonParameters(
        LabelText(Title, 2)
        ));
  @endcode

  @since 0.2.0
*/
.macro @c128lib_Button(position, label) { Button(position, label) }

/**
  Print a slim button at coordinates. It's a single line button instead of three.

  @param[in] position Button (x,y) position
  @param[in] label Button label definition

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @code
    c128lib_SlimButton(
      Point(45, 9),
      ButtonParameters(
        LabelText(Si, 2)
        ));
  @endcode

  @since 0.2.0
*/
.macro @c128lib_SlimButton(position, label) { SlimButton(position, label) }

#import "vdc-gui.asm"

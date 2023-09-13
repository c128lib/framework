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

  @param[in] windowParameters Defines window parameters

  @see WindowParameters

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @code
    c128lib_Window(
      WindowParameters(
        10, 3, 20, 10,          // Set window size
        WindowTitle(Title, 15), // Set title
        WindowBorders(),        // Use default borders
        true))                  // Make window opaque
  @endcode

  @code
    c128lib_Window(
      WindowParameters(
        10, 3, 20, 10,          // Set window size
        WindowTitle(null, 0),   // Don't set title
        WindowBorders(85, 66, 74, 67, 75, 66, 73, 67), // Use custom chars for borders
        false))                 // Make window transparent
  @endcode

  @attention Don't overlap window with color and window without color.
  Strange color behavior occour.

  @since 0.2.0
*/
.macro @c128lib_Window(windowParameters) { Window(windowParameters) }
/**
  Draws a window in Vdc screen with specific color

  @param[in] windowParameters Defines window parameters
  @param[in] color Defines which color to use

  @see WindowParameters

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @note Use colors defined in chipset/Vdc

  @code
    c128lib_WindowWithColor(
      WindowParameters(
        10, 3, 20, 10,          // Set window size
        WindowTitle(Title, 15), // Set title
        WindowBorders(),        // Use default borders
        true),                  // Make window opaque
        c128lib.Vdc.VDC_LIGHT_YELLOW) // Set color
  @endcode

  @code
    c128lib_WindowWithColor(
      WindowParameters(
        10, 3, 20, 10,          // Set window size
        WindowTitle(null, 0),   // Don't set title
        WindowBorders(85, 66, 74, 67, 75, 66, 73, 67), // Use custom chars for borders
        false),                 // Make window transparent
        c128lib.Vdc.VDC_LIGHT_YELLOW) // Set color
  @endcode

  @attention Don't overlap window with color and window without color.
  Strange color behavior occour.

  @since 0.2.0
*/
.macro @c128lib_WindowWithColor(windowParameters, color) { WindowWithColor(windowParameters, color) }

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

/**
  Prints a progress bar at coordinates

  @param[in] progressBarParameters Defines progress bar parameters

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @see ProgressBarParameters

  @code
    c128lib_ProgressBar( 
      ProgressBarParameters(
        0, 0, 12,     // Set progress bar position and width
        5, 2,         // Set step count and current position
        ProgressBarStyle(58, 59, 87, 88)) // Set custom style
    );
  @endcode

  @code
    c128lib_ProgressBar(
      ProgressBarParameters(
        0, 3, 12,     // Set progress bar position and width
        5, 4,         // Set step count and current position
        ProgressBarStyle()) // Set default style
    );
  @endcode

  @since 0.2.0
*/
.macro @c128lib_ProgressBar(progressBarParameters) { ProgressBar(progressBarParameters) }

/**
  Print a button at coordinates

  @param[in] buttonParameters Defines button parameters

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @code
    c128lib_Button(
      ButtonParameters(
        45, 9,
        WindowTitle(Title, 2)
        ));
  @endcode

  @since 0.2.0
*/
.macro @c128lib_Button(buttonParameters) { Button(buttonParameters) }

/**
  Print a slim button at coordinates. It's a single line button instead of three.

  @param[in] buttonParameters Defines slim button parameters

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @code
    c128lib_SlimButton(
      ButtonParameters(
        45, 20,
        WindowTitle(Si, 2)
        ));
  @endcode

  @since 0.2.0
*/
.macro @c128lib_SlimButton(buttonParameters) { SlimButton(buttonParameters) }

#import "vdc-gui.asm"

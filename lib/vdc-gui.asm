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

.namespace Gui {
}

/**
  Struct for defining window creation parametes
*/
.struct @WindowParameters {
  /** Custom border style definition */
  borderStyle,
  /** Windows opacity control */
  isOpaque
}

/**
  Struct for defining custom window border. If no custom border is needed,
  creation macro will use a default charset.
*/
.struct @WindowBorders {
  TopLeft, Left, BottomLeft, Bottom, BottomRight, Right, TopRight, Top
}

/**
  Struct for defining window creation parametes. If no title is required,
  length must be 0.
*/
.struct @LabelText {
  label, length
}

.struct @ProgressBarParameters {
  /** Progressbar width */
  width,
  /** Steps count (included starting and ending step) */
  steps,
  /** Current progress position */
  position,
  /** Progressbar border style */
  progressBarStyle
}

.struct @ProgressBarStyle {
  /** Char used for line before step*/
  lineBeforeStep,
  /** Char used for line after step */
  lineAfterStep,
  /** Char used for step point equal or lower to position */
  pointBeforeStep,
  /** Char used for step point greater than position */
  pointAfterStep
}

.struct @Point {
  /** Column value */
  x,
  /** Row value */
  y
}

.struct @Size {
  /** Control width */
  width,
  /** Control height */
  height
}

/**
  Draws a window in Vdc screen

  @param[in] position Starting (x,y) position window
  @param[in] size Window (x,y) size
  @param[in] windowTitle Defines window title
  @param[in] windowParameters Defines window parameters

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @note Use c128lib_CreateWindow in vdc-gui-global.asm

  @since 0.2.0
*/
.macro Window(position, size, windowTitle, windowParameters) {
    .errorif (position.x < 0), "X must be greater than 0"
    .errorif (position.y < 0), "Y must be greater than 0"
    .errorif (size.width < 1), "Width must be greater than 1"
    .errorif (size.height < 1), "Height must be greater than 1"
    .errorif (position.x > 78), "X must be lower than 78"
    .errorif (position.y > 23), "Y must be lower than 23"
    .errorif (position.x + size.width > 80), "Right window boundary must be lower than 80"
    .errorif (position.y + size.height > 25), "Bottom window boundary must be lower than 25"
#if !VDC_CREATEWINDOW
    .error "You should use #define VDC_CREATEWINDOW"
#else
  .var borderStyleNow = windowParameters.borderStyle

  // If no custom border set, take default border
  .if (windowParameters.borderStyle.TopLeft == null) {
    .eval borderStyleNow = WindowBorders(85, 66, 74, 67, 75, 66, 73, 67)
  }

#define VDC_POKE
    lda #borderStyleNow.TopLeft
    sta VDC_Poke.value
    lda #<(VDC_RowColToAddress(position.x, position.y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(position.x, position.y))
    sta VDC_Poke.address + 1
    jsr VDC_Poke

    lda #borderStyleNow.Left
    sta VDC_Poke.value
    ldy #size.height - 1
  !:
    c128lib_add16(80, VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    lda #borderStyleNow.BottomLeft
    sta VDC_Poke.value
    jsr VDC_Poke

    lda #borderStyleNow.Bottom
    sta VDC_Poke.value
    ldy #size.width - 2
  !:
    c128lib_inc16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    lda #borderStyleNow.BottomRight
    sta VDC_Poke.value
    jsr VDC_Poke

    lda #borderStyleNow.Right
    sta VDC_Poke.value
    ldy #size.height - 1
  !:
    c128lib_sub16(80, VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    lda #borderStyleNow.TopRight
    sta VDC_Poke.value
    jsr VDC_Poke

    lda #borderStyleNow.Top
    sta VDC_Poke.value
    ldy #size.width - 3
  !:
    c128lib_dec16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

  .var rowStartingOpacity = position.y + 2
  .var rowsOpacity = size.height - 3

  // Draws title if needed
  .if (windowTitle.length > 0) {
  // Draws black background for first row
    lda #32
    sta VDC_Poke.value
    lda #<(VDC_RowColToAddress(position.x, position.y + 1))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(position.x, position.y + 1))
    sta VDC_Poke.address + 1

    ldy #size.width - 3
  !:
    c128lib_inc16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    Label(Point(position.x + 2, position.y + 1), windowTitle)
  } else {
    .eval rowStartingOpacity = position.y + 1
    .eval rowsOpacity = size.height - 2
  }

  // Draws opaque background if needed
  .if (windowParameters.isOpaque) {
    lda #102
    sta VDC_Poke.value
    lda #<(VDC_RowColToAddress(position.x, rowStartingOpacity))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(position.x, rowStartingOpacity))
    sta VDC_Poke.address + 1

    ldx #rowsOpacity
  !NewRow:

    ldy #size.width - 3
  !:
    c128lib_inc16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    c128lib_add16(80 - size.width + 3, VDC_Poke.address)

    dex
    bne !NewRow-
  }
#endif
}

/**
  Draws a window in Vdc screen with specific color

  @param[in] position Starting (x,y) position window
  @param[in] size Window (x,y) size
  @param[in] windowTitle Defines window title
  @param[in] windowParameters Defines window parameters
  @param[in] color Defines which color to use

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @note Use colors defined in chipset/Vdc

  @note Use c128lib_WindowWithColor in vdc-gui-global.asm

  @since 0.2.0
*/
.macro WindowWithColor(position, size, windowTitle, windowParameters, color) {
#if !VDC_CREATEWINDOW
    .error "You should use #define VDC_CREATEWINDOW"
#else
    Window(position, size, windowTitle, windowParameters)

    // Set window border color
    BorderColor(
      Point(position.x, position.y),
      Size(size.width, size.height),
      color)

  .var rowStartingOpacity = position.y + 2
  .var rowsOpacity = size.height - 3

  // Set window title color if needed
  .if (windowTitle.length > 0) {
    Color(Point(position.x + 2, position.y + 1),
      color,
      windowTitle.length)
  } else {
    .eval rowStartingOpacity = position.y + 1
    .eval rowsOpacity = size.height - 2
  }

  // Set window background color if needed
  .if (windowParameters.isOpaque) {
    lda #color
    sta VDC_Poke.value
    lda #<(VDC_RowColToAttributeAddress(position.x, rowStartingOpacity))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAttributeAddress(position.x, rowStartingOpacity))
    sta VDC_Poke.address + 1

    ldx #rowsOpacity
  !NewRow:

    ldy #size.width - 3
  !:
    c128lib_inc16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    c128lib_add16(80 - size.width + 3, VDC_Poke.address)

    dex
    bne !NewRow-
  }
#endif
}

.macro BorderColor(position, size, color) {
#if !VDC_CREATEWINDOW
    .error "You should use #define VDC_CREATEWINDOW"
#else
    lda #color
    sta VDC_Poke.value

    // Set x,y color
    lda #<(VDC_RowColToAttributeAddress(position.x, position.y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAttributeAddress(position.x, position.y))
    sta VDC_Poke.address + 1
    jsr VDC_Poke

    // Set left border up to last row
    ldy #size.height - 1
  !:
    c128lib_add16(80, VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    // Set bottom border color
    ldy #size.width - 2
  !:
    c128lib_inc16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    // Set right border up to first row
    ldy #size.height - 1
  !:
    c128lib_sub16(80, VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    ldy #size.width - 3
  !:
    c128lib_dec16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-
#endif
}

/**
  Print a label at coordinates

  @param[in] position Starting (x, y) position
  @param[in] label Label definition

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @note Use c128lib_Label in vdc-gui-global.asm

  @since 0.2.0
*/
.macro Label(position, label) {
    .errorif (position.x < 0), "X must be greater than 0"
    .errorif (position.y < 0), "Y must be greater than 0"
    c128lib_WriteToVdcMemoryByCoordinates(label.label, position.x, position.y, label.length)
}
.asserterror "Label(Point(-1, 1), $beef, 10)", { Label(Point(-1, 1), $beef, 10) }
.asserterror "Label(Point(1, -1), $beef, 10)", { Label(Point(1, -1), $beef, 10) }

/**
  Set color in attribute memory for specified coordinates

  @param[in] position Coloring (x,y) starting position
  @param[in] color Vdc color code and attribute
  @param[in] length Label string length

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @note Use c128lib_Color in vdc-gui-global.asm

  @since 0.2.0
*/
.macro Color(position, color, length) {
#if !VDC_CREATEWINDOW
    .error "You should use #define VDC_CREATEWINDOW"
#else
    lda #color
    sta VDC_Poke.value
    lda #<(VDC_RowColToAttributeAddress(position.x - 1, position.y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAttributeAddress(position.x - 1, position.y))
    sta VDC_Poke.address + 1
    ldy #length
  !:
    c128lib_inc16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-
#endif
}

/**
  Print a label at coordinates with specified color

  @param[in] position Starting (x, y) label position
  @param[in] label Label definition
  @param[in] color Vdc color code and attribute

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @note Use c128lib_LabelWithColor in vdc-gui-global.asm

  @since 0.2.0
*/
.macro LabelWithColor(position, label, color) {
    Label(position, label)
    Color(position, color, label.length)
}

/**
  Prints a progress bar at coordinates

  @param[in] position Starting (x, y) progress bar position
  @param[in] progressBarParameters Defines progress bar parameters

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @note Use c128lib_ProgressBar in vdc-gui-global.asm

  @since 0.2.0
*/
.macro ProgressBar(position, progressBarParameters) {
    .errorif (position.x < 0), "X must be greater than 0"
    .errorif (position.y < 0), "Y must be greater than 0"
    .errorif (progressBarParameters.width < 2), "Width must be greater than 2"
    .errorif (progressBarParameters.steps < 2), "Step must be greater or equal to 2"
    .errorif (progressBarParameters.position < 1), "Position must be greater or equal to 1"
    .errorif (progressBarParameters.position > progressBarParameters.steps), "Position must be lower or equal to step"
    .errorif (position.x > 78), "X must be lower than 78"
    .errorif (position.y > 24), "Y must be lower than 25"
    .errorif (progressBarParameters.x + progressBarParameters.width > 80), "Right window boundary must be lower than 80"

#if !VDC_CREATEWINDOW
    .error "You should use #define VDC_CREATEWINDOW"
#else

  .var progressBarStyleNow = progressBarParameters.progressBarStyle

  // If no custom style set, take default
  .if (progressBarParameters.progressBarStyle.lineBeforeStep == null) {
    .eval progressBarStyleNow = ProgressBarStyle(61, 45, 81, 87)
  }

    lda #<(VDC_RowColToAddress(position.x, position.y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(position.x, position.y))
    sta VDC_Poke.address + 1

    .var lineEdge = round((progressBarParameters.width / (progressBarParameters.steps - 1)) * (progressBarParameters.position - 1))

    .if (lineEdge >= 1) {
      lda #progressBarStyleNow.lineBeforeStep
      sta VDC_Poke.value
      ldy #lineEdge - 1
    !:
      c128lib_inc16(VDC_Poke.address)
      jsr VDC_Poke
      dey
      bne !-
    }

    .eval lineEdge = progressBarParameters.width - lineEdge
    .if (lineEdge > 0) {
      lda #progressBarStyleNow.lineAfterStep
      sta VDC_Poke.value
      ldy #lineEdge
    !:
      c128lib_inc16(VDC_Poke.address)

      jsr VDC_Poke
      dey
      bne !-
    }

    lda #progressBarStyleNow.pointBeforeStep
    sta VDC_Poke.value
    .for (var i = 0; i < progressBarParameters.position; i++) {
      .var stepCount = (progressBarParameters.width / (progressBarParameters.steps - 1)) * i

      lda #<(VDC_RowColToAddress(stepCount + position.x, position.y))
      sta VDC_Poke.address
      lda #>(VDC_RowColToAddress(stepCount + position.x, position.y))
      sta VDC_Poke.address + 1

      jsr VDC_Poke
    }

    lda #progressBarStyleNow.pointAfterStep
    sta VDC_Poke.value
    .for (var i = progressBarParameters.position; i < progressBarParameters.steps; i++) {
      .var stepCount = (progressBarParameters.width / (progressBarParameters.steps - 1)) * i

      lda #<(VDC_RowColToAddress(stepCount + position.x, position.y))
      sta VDC_Poke.address
      lda #>(VDC_RowColToAddress(stepCount + position.x, position.y))
      sta VDC_Poke.address + 1

      jsr VDC_Poke
    }
#endif
}

/**
  Print a button at coordinates

  @param[in] position Button (x,y) position
  @param[in] label Button label definition

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @note Use c128lib_Button in vdc-gui-global.asm

  @since 0.2.0
*/
.macro Button(position, label) {
    .errorif (position.x + label.length + 3 > 80), "Button right border must be lower than 80"

    Window(
      position,
      Size(label.length + 5, 3),
      LabelText(label.title, label.length),
      WindowParameters(
        WindowBorders(), false))
}
.asserterror "Button(Point(60, 1), LabelText($beef, 18))", { Button(Point(60, 1), LabelText($beef, 18)) }

/**
  Print a slim button at coordinates. It's a single line button instead of three.

  @param[in] position Button (x,y) position
  @param[in] label Button label definition

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @note Use c128lib_SlimButton in vdc-gui-global.asm

  @since 0.2.0
*/
.macro SlimButton(position, label) {
    .errorif (position.x + label.length + 3 > 80), "SlimButton right border must be lower than 80"

#define VDC_POKE
    lda #<(VDC_RowColToAddress(position.x, position.y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(position.x, position.y))
    sta VDC_Poke.address + 1

    lda #27
    sta VDC_Poke.value
    jsr VDC_Poke
    c128lib_inc16(VDC_Poke.address)
    lda #32
    sta VDC_Poke.value
    jsr VDC_Poke
    Label(Point(position.x+2, position.y), label);
    lda #<(VDC_RowColToAddress(position.x + label.length + 2, position.y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(position.x + label.length + 2, position.y))
    sta VDC_Poke.address + 1
    lda #32
    sta VDC_Poke.value
    jsr VDC_Poke
    c128lib_inc16(VDC_Poke.address)
    lda #29
    sta VDC_Poke.value
    jsr VDC_Poke
}
.asserterror "SlimButton(Point(60, 1), LabelText($beef, 18))", { SlimButton(Point(60, 1), LabelText($beef, 18)) }

/* Function returns a VDC memory address for a given row and column */
.function VDC_RowColToAddress(x, y) {
  .var addr = y * 80 + x;

  .if (addr > -1 && addr < 2000)
    .return addr
  else
    .return -1;
}

/* Function returns a VDC attribute memory address for a given row and column */
.function VDC_RowColToAttributeAddress(x, y) {
  .var addr = y * 80 + x + $0800;

  .if (addr > 1999 && addr < 4048)
    .return addr
  else
    .return -1;
}

#if VDC_POKE
VDC_Poke: {
    txa
    pha
    ldx #c128lib.Vdc.CURRENT_MEMORY_HIGH_ADDRESS
    lda address + 1
    c128lib_WriteVdc()

    inx
    lda address
    c128lib_WriteVdc()

    ldx #c128lib.Vdc.MEMORY_READ_WRITE
    lda value
    c128lib_WriteVdc()

    pla
    tax
    rts

    address: .word $0000
    value: .byte $00
}
#endif

#import "common/lib/math-global.asm"
#import "chipset/lib/vdc-global.asm"

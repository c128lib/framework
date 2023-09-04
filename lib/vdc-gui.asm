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
  /** Column where window starts */
  x,
  /** Row where window starts */
  y,
  /** Window width */
  width,
  /** Window height */
  height,
  /** Window title definition */
  windowTitle,
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
.struct @WindowTitle {
  title, length
}

/**
  Draws a window in Vdc screen

  @param[in] windowParameters Defines window parameters

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @note Use c128lib_CreateWindow in vdc-gui-global.asm

  @since 0.2.0
*/
.macro Window(windowParameters) {
    .errorif (windowParameters.x < 0), "X must be greater than 0"
    .errorif (windowParameters.y < 0), "Y must be greater than 0"
    .errorif (windowParameters.width < 1), "Width must be greater than 1"
    .errorif (windowParameters.height < 1), "Height must be greater than 1"
    .errorif (windowParameters.x > 78), "X must be lower than 78"
    .errorif (windowParameters.y > 23), "Y must be lower than 23"
    .errorif (windowParameters.x + windowParameters.width > 80), "Right window boundary must be lower than 80"
    .errorif (windowParameters.y + windowParameters.height > 25), "Bottom window boundary must be lower than 25"
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
    lda #<(VDC_RowColToAddress(windowParameters.x, windowParameters.y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(windowParameters.x, windowParameters.y))
    sta VDC_Poke.address + 1
    jsr VDC_Poke

    lda #borderStyleNow.Left
    sta VDC_Poke.value
    ldy #windowParameters.height - 2
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
    ldy #windowParameters.width - 2
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
    ldy #windowParameters.height - 2
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
    ldy #windowParameters.width - 3
  !:
    c128lib_dec16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

  .var rowStartingOpacity = windowParameters.y + 2
  .var rowsOpacity = windowParameters.height - 4

  // Draws title if needed
  .if (windowParameters.windowTitle.length > 0) {
    Label(windowParameters.x + 2, windowParameters.y + 1,
      windowParameters.windowTitle.title, windowParameters.windowTitle.length)
  } else {
    .eval rowStartingOpacity = windowParameters.y + 1
    .eval rowsOpacity = windowParameters.height - 3
  }

  // Draws opaque background if needed
  .if (windowParameters.isOpaque) {
    lda #102
    sta VDC_Poke.value
    lda #<(VDC_RowColToAddress(windowParameters.x, rowStartingOpacity))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(windowParameters.x, rowStartingOpacity))
    sta VDC_Poke.address + 1

    ldx #rowsOpacity
  !NewRow:

    ldy #windowParameters.width - 3
  !:
    c128lib_inc16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    c128lib_add16(80 - windowParameters.width + 3, VDC_Poke.address)

    dex
    bne !NewRow-
  }
#endif
}

/**
  Draws a window in Vdc screen with specific color

  @param[in] windowParameters Defines window parameters
  @param[in] color Defines which color to use

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @note Use colors defined in chipset/Vdc

  @note Use c128lib_WindowWithColor in vdc-gui-global.asm

  @since 0.2.0
*/
.macro WindowWithColor(windowParameters, color) {
#if !VDC_CREATEWINDOW
    .error "You should use #define VDC_CREATEWINDOW"
#else
    Window(windowParameters)

    // Set window border color
    BorderColor(
      windowParameters.x,
      windowParameters.y,
      windowParameters.width,
      windowParameters.height,
      color)

  .var rowStartingOpacity = windowParameters.y + 2
  .var rowsOpacity = windowParameters.height - 4

  // Set window title color if needed
  .if (windowParameters.windowTitle.length > 0) {
    Color(
      windowParameters.x + 2,
      windowParameters.y + 1,
      color,
      windowParameters.windowTitle.length)
  } else {
    .eval rowStartingOpacity = windowParameters.y + 1
    .eval rowsOpacity = windowParameters.height - 3
  }

  // Set window background color if needed
  .if (windowParameters.isOpaque) {
    lda #color
    sta VDC_Poke.value
    lda #<(VDC_RowColToAttributeAddress(windowParameters.x, rowStartingOpacity))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAttributeAddress(windowParameters.x, rowStartingOpacity))
    sta VDC_Poke.address + 1

    ldx #rowsOpacity
  !NewRow:

    ldy #windowParameters.width - 3
  !:
    c128lib_inc16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    c128lib_add16(80 - windowParameters.width + 3, VDC_Poke.address)

    dex
    bne !NewRow-
  }
#endif
}

.macro BorderColor(x, y, width, height, color) {
#if !VDC_CREATEWINDOW
    .error "You should use #define VDC_CREATEWINDOW"
#else
    c128lib_PositionAttrXy(x, y)
    lda #color
    sta VDC_Poke.value

    lda #<(VDC_RowColToAttributeAddress(x, y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAttributeAddress(x, y))
    sta VDC_Poke.address + 1
    jsr VDC_Poke

    ldy #height - 2
  !:
    c128lib_add16(80, VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    ldy #width-2
  !:
    c128lib_inc16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    ldy #height - 2
  !:
    c128lib_sub16(80, VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    ldy #width-3
  !:
    c128lib_dec16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-
#endif
}



// .asserterror "CreateWindow(-1, 1, 20, 10)", { CreateWindow(-1, 1, 20, 10) }
// .asserterror "CreateWindow(1, -1, 20, 10)", { CreateWindow(1, -1, 20, 10) }
// .asserterror "CreateWindow(1, 1, 0, 10)", { CreateWindow(1, 1, 0, 10) }
// .asserterror "CreateWindow(1, 1, 20, 0)", { CreateWindow(1, 1, 20, 0) }
// .asserterror "CreateWindow(79, 1, 20, 10)", { CreateWindow(79, 1, 20, 10) }
// .asserterror "CreateWindow(1, 24, 20, 10)", { CreateWindow(1, 24, 20, 10) }
// .asserterror "CreateWindow(50, 4, 31, 10)", { CreateWindow(50, 4, 31, 10) }
// .asserterror "CreateWindow(10, 4, 31, 22)", { CreateWindow(10, 4, 31, 22) }

// .asserterror "CreateWindowWithTitle(50, 1, 20, 10, $beef, 0)", { CreateWindowWithTitle(50, 1, 20, 10, $beef, 0) }
// .asserterror "CreateWindowWithTitle(50, 1, 20, 10, $beef, 19)", { CreateWindowWithTitle(50, 1, 20, 10, $beef, 19) }

/**
  Print a label at coordinates

  @param[in] x Starting column
  @param[in] y Starting row
  @param[in] text Label string address
  @param[in] length Label string length

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @note Use c128lib_Label in vdc-gui-global.asm

  @since 0.2.0
*/
.macro Label(x, y, text, length) {
    .errorif (x < 0), "X must be greater than 0"
    .errorif (y < 0), "Y must be greater than 0"
    c128lib_WriteToVdcMemoryByCoordinates(text, x, y, length)
}
.asserterror "Label(-1, 1, $beef, 10)", { Label(-1, 1, $beef, 10) }
.asserterror "Label(1, -1, $beef, 10)", { Label(1, -1, $beef, 10) }

/**
  Set color in attribute memory for specified coordinates

  @param[in] x Starting column
  @param[in] y Starting row
  @param[in] color Vdc color code and attribute
  @param[in] length Label string length

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @note Use c128lib_Color in vdc-gui-global.asm

  @since 0.2.0
*/
.macro Color(x, y, color, length) {
#if !VDC_CREATEWINDOW
    .error "You should use #define VDC_CREATEWINDOW"
#else
    c128lib_PositionAttrXy(x, y)
    lda #color
    sta VDC_Poke.value
    lda #<(VDC_RowColToAttributeAddress(x - 1, y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAttributeAddress(x - 1, y))
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

  @param[in] x Starting column
  @param[in] y Starting row
  @param[in] text Label string address
  @param[in] length Label string length
  @param[in] color Vdc color code and attribute

  @remark Register .A, .X and .Y will be modified.
  Flags N, Z and C will be affected.

  @note Use c128lib_LabelWithColor in vdc-gui-global.asm

  @since 0.2.0
*/
.macro LabelWithColor(x, y, text, length, color) {
    Label(x, y, text, length)
    Color(x, y, color, length)
}

.macro ProgressBar(x, y, width, step, position) {
    .errorif (x < 0), "X must be greater or equal to 0"
    .errorif (y < 0), "Y must be greater or equal to 0"
    .errorif (width < 1), "Width must be greater than 1"
    .errorif (step < 2), "Step must be greater or equal to 2"
    .errorif (position < 0), "Position must be greater or equal to 0"
    .errorif (position > step), "Position must be equal or lower than step"
    .errorif (x > 78), "X must be lower than 78"
    .errorif (y > 23), "Y must be lower than 23"
    .errorif (x + width > 80), "Right window boundary must be lower than 80"

#if !VDC_CREATEWINDOW
    .error "You should use #define VDC_CREATEWINDOW"
#else
    lda #<(VDC_RowColToAddress(x, y))
    sta VDC_Poke.address
    lda #>(VDC_RowColToAddress(x, y))
    sta VDC_Poke.address + 1

    lda #67
    sta VDC_Poke.value
    ldy #width-2
  !:
    c128lib_inc16(VDC_Poke.address)

    jsr VDC_Poke
    dey
    bne !-

    lda #87
    sta VDC_Poke.value

    .var stepPosition = (width - 1) / (step - 1)

    ldy #step
  !:
    cpy #position
    beq !Change+
    jmp !Print+
  !Change:
    lda #81
    sta VDC_Poke.value
    lda #$ea
    sta !Change-
    sta !Change-+1
    sta !Change-+2
    sta !Change-+3
    sta !Change-+4

  !Print:
    jsr VDC_Poke
    c128lib_sub16(stepPosition, VDC_Poke.address)

    dey
    bne !-
#endif
}

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

#import "128spec/lib/128spec.asm"

sfspec: 
  init_spec() 

    describe("Int8ToString - Pass Immediate")

    it("Immediate Integer 222 to String"); {
      // Arrange

      // Act
      c128lib_Int8ToString #222 : asciiString

      // Assert
      :_print_string(stringLabel)
      :_print_string(asciiString)
      assert_bytes_equal stringLength : asciiString : asciiStringChallenge_222
    }

    it("Immediate Integer 45 to String"); {
      // Arrange

      // Act
      c128lib_Int8ToString #45 : asciiString

      // Assert
      :_print_string(stringLabel)
      :_print_string(asciiString)
      assert_bytes_equal stringLength : asciiString : asciiStringChallenge_045 
    }

    it("Immediate Integer 8 to String"); {
      // Arrange

      // Act
      c128lib_Int8ToString #8 : asciiString

      // Assert
      :_print_string(stringLabel)
      :_print_string(asciiString)
      assert_bytes_equal stringLength : asciiString : asciiStringChallenge_008 
    }

    it("Immediate Integer 0 to String"); {
      // Arrange

      // Act
      c128lib_Int8ToString #0 : asciiString

      // Assert
      :_print_string(stringLabel)
      :_print_string(asciiString)
      assert_bytes_equal stringLength : asciiString : asciiStringChallenge_000 
    }
  
    // describe("Int8ToString - Pass By Address")

    it("Int (Abs.Add) 222 to String"); {
      // Arrange

      // Act
      c128lib_Int8ToString int8_222 : asciiString

      // Assert
      :_print_string(stringLabel)
      :_print_string(asciiString)
      assert_bytes_equal stringLength : asciiString : asciiStringChallenge_222 
    }

    it("Int (Abs.Add) 45 to String"); {
      // Arrange

      // Act
      c128lib_Int8ToString int8_45 : asciiString

      // Assert
      :_print_string(stringLabel)
      :_print_string(asciiString)
      assert_bytes_equal stringLength : asciiString : asciiStringChallenge_045 
    }

    it("Int (Abs.Add) 8 to String"); {
      // Arrange

      // Act
      c128lib_Int8ToString int8_8 : asciiString

      // Assert
      :_print_string(stringLabel)
      :_print_string(asciiString)
      assert_bytes_equal stringLength : asciiString : asciiStringChallenge_008
      _print_string(asciiString)
    }

    it("Int (Abs.Add) 0 to String"); {
      // Arrange

      // Act
      c128lib_Int8ToString int8_0 : asciiString

      // Assert
      :_print_string(stringLabel)
      :_print_string(asciiString)
      assert_bytes_equal stringLength : asciiString : asciiStringChallenge_000
    }

  finish_spec()

* = * "Data"
.label stringLength = 4
asciiString: .byte 0,0,0,0 // 3 byte string, null terminated = 4 bytes

int8_222: .byte 222
int8_45: .byte 45
int8_8: .byte 8
int8_0: .byte 0

asciiStringChallenge_222: .byte 50,50,50,0 // ASCII "222"
asciiStringChallenge_045: .byte 48,52,53,0 // ASCII "045"
asciiStringChallenge_008: .byte 48,48,56,0 // ASCII "008"
asciiStringChallenge_000: .byte 48,48,48,0 // ASCII "000"

stringLabel: .text "INTEGER PRINTED TO SCREEN " 
             .byte 0

#import "../lib/string-global.asm"

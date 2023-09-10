#import "128spec/lib/128spec.asm"

sfspec: 
  init_spec() 
  
    describe("Int16ToString")

    it("Integer 65535 to String"); {
      // Arrange

      // Act
      c128lib_Int16ToString(int16_65535, asciiString, true)

      // Assert
      _print_string(stringLabel)
      _print_string(asciiString)
      assert_bytes_equal stringLength : asciiString : asciiStringChallenge_65535 
    }

    it("Integer 1023 to String"); {
      // Arrange

      // Act
      c128lib_Int16ToString(int16_01023, asciiString, true)

      // Assert
      _print_string(stringLabel)
      _print_string(asciiString)
      assert_bytes_equal stringLength : asciiString : asciiStringChallenge_01023 
    }

    it("Integer 222 to String"); {
      // Arrange

      // Act
      c128lib_Int16ToString(int16_00222, asciiString, true)

      // Assert
      _print_string(stringLabel)
      _print_string(asciiString)
      assert_bytes_equal stringLength : asciiString : asciiStringChallenge_00222 
    }

    it("Integer 45 to String"); {
      // Arrange

      // Act
      c128lib_Int16ToString(int16_00045, asciiString, true)

      // Assert
      _print_string(stringLabel)
      _print_string(asciiString)
      assert_bytes_equal stringLength : asciiString : asciiStringChallenge_00045 
    }

    it("Integer 8 to String"); {
      // Arrange

      // Act
      c128lib_Int16ToString(int16_00008, asciiString, true)

      // Assert
      _print_string(stringLabel)
      _print_string(asciiString)
      assert_bytes_equal stringLength : asciiString : asciiStringChallenge_00008
    }

    it("Integer 0 to String"); {
      // Arrange

      // Act
      c128lib_Int16ToString(int16_00000, asciiString, true)

      // Assert
      _print_string(stringLabel)
      _print_string(asciiString)
      assert_bytes_equal stringLength : asciiString : asciiStringChallenge_00000
    }

  finish_spec()

* = * "Data"
.label stringLength = 6
asciiString: .byte 0,0,0,0,0,0 // 5 byte string, null terminated = 6 bytes

int16_65535: .word 65535
int16_01023: .word 1023
int16_00222: .word 222
int16_00045: .word 45
int16_00008: .word 8
int16_00000: .word 0

asciiStringChallenge_65535: .byte 54,53,53,51,53,0 // ASCII "65535"
asciiStringChallenge_01023: .byte 48,49,48,50,51,0 // ASCII "01023"
asciiStringChallenge_00222: .byte 48,48,50,50,50,0 // ASCII "00222"
asciiStringChallenge_00045: .byte 48,48,48,52,53,0 // ASCII "00045"
asciiStringChallenge_00008: .byte 48,48,48,48,56,0 // ASCII "00008"
asciiStringChallenge_00000: .byte 48,48,48,48,48,0 // ASCII "00000"

stringLabel: .text "INTEGER PRINTED TO SCREEN " 
             .byte 0

#import "../lib/string-global.asm"

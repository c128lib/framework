#import "128spec/lib/128spec.asm"

sfspec: 
  init_spec() 

    describe("PseudoRandom")

    it("From zero"); {
      // Arrange
      lda #0

      // Act
      c128lib_PseudoRandom()

      // Assert
      sta number1
      SetValue8Bit(expected, $1d)
      assert_bytes_equal 1: number1: expected 
    }

  finish_spec()

* = * "Data"
number1: .byte 0
expected: .byte 0

#import "../lib/random-global.asm"

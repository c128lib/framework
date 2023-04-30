#import "128spec/lib/128spec.asm"

sfspec: 
  init_spec() 

    describe("BubbleSort")

    it("Inverted array"); {
      // Arrange

      // Act
      c128lib_BubbleSort(arrayInverted, arrayInvertedSize, false)

      // Assert
      assert_bytes_equal arrayInvertedSize: arrayInverted: arrayOrderedChallenge 
    }

    it("Random array"); {
      // Arrange

      // Act
      c128lib_BubbleSort(arrayRandom, arrayRandomSize, false)

      // Assert
      assert_bytes_equal arrayRandomSize: arrayRandom: arrayOrderedChallenge 
    }

    it("Ordeded array"); {
      // Arrange

      // Act
      c128lib_BubbleSort(arrayOrdered, arrayOrderedSize, false)

      // Assert
      assert_bytes_equal arrayOrderedSize: arrayOrdered: arrayOrderedChallenge 
    }

  finish_spec()

* = * "Data"
.label arrayInvertedSize = 10
arrayInverted: .fill arrayInvertedSize, arrayInvertedSize-(i+1)

.label arrayRandomSize = 10
arrayRandom: .byte 7, 6, 3, 5, 1, 0, 2, 4, 8, 9

.label arrayOrderedSize = 10
arrayOrdered: .fill arrayOrderedSize, i

.label arrayOrderedChallengeSize = 10
arrayOrderedChallenge: .fill arrayOrderedChallengeSize, i

.macro SetValue8Bit(variable, value) {
  lda #value
  sta variable
}
.macro SetValue16Bit(variable, value) {
  lda #<value
  sta variable
  lda #>value
  sta variable + 1
}

#import "../lib/sort-global.asm"


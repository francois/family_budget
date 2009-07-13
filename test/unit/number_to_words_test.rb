require "test_helper"

class NumberToWordsTest < ActiveSupport::TestCase
  def self.should_convert(number, words)
    should "convert #{number} to #{words.inspect}" do
      assert_equal words, NumberToWords.number_to_words(number)
    end
  end

  should_convert 0, "zero"
end

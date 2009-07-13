require "test_helper"

class NumberToWordsTest < ActiveSupport::TestCase
  {
       0 => "zero",          1 => "one",               2 => "two",                      3 => "three",         4 => "four",
       5 => "five",          6 => "six",               7 => "seven",                    8 => "eight",         9 => "nine",
      10 => "ten",          11 => "eleven",           12 => "twelve",                  13 => "thirteen",     14 => "fourteen",
      15 => "fifteen",      16 => "sixteen",          17 => "seventeen",               18 => "eighteen",     19 => "nineteen",
      20 => "twenty",       21 => "twenty one",       22 => "twenty two",              33 => "thirty three", 44 => "fourty four",
      55 => "fifty five",   66 => "sixty six",        77 => "seventy seven",           88 => "eighty eight", 99 => "ninety nine",
     100 => "one hundred", 101 => "one hundred one", 122 => "one hundred twenty two", 999 => "nine hundred ninety nine",
     309 => "three hundred nine",
     563 => "five hundred sixty three",
     708 => "seven hundred eight",
      -1 => "minus one",
     -23 => "minus twenty three",
    -356 => "minus three hundred fifty six",
    1000 => "one thousand",
    1234 => "one thousand two hundred thirty four",
    9999 => "nine thousand nine hundred ninety nine",
  }.each do |number, words|
    should "convert #{number} to #{words.inspect}" do
      assert_equal words, NumberToWords.number_to_words(number)
    end
  end
end

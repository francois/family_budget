module NumberToWords
  extend self

  SINGLES  = %w(zero one two three four five six seven eight nine)
  TEENS    = %w(ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen)
  TENS     = %w(twenty thirty fourty fifty sixty seventy eighty ninety)
  HUNDREDS = %w(hundred thousand)

  def number_to_words(number, zero_as_text=true)
    num    = number.abs
    result = case num
             when 1000..9999
               SINGLES[num / 1000] + " " + HUNDREDS[1] + " " + number_to_words(num % 1000, false)
             when 100..999
               SINGLES[num / 100] + " " + HUNDREDS[0] + " " + number_to_words(num % 100, false)
             when 20..99
               TENS[(num / 10) - 2] + " " + number_to_words(num % 10, false)
             when 10..19
               TEENS[num - 10]
             when 0..9
               if num.zero? then
                 if zero_as_text then
                   "zero"
                 else
                   ""
                 end
               else
                 SINGLES[num]
               end
             else
               raise OutOfBoundsException, "This converter can only convert 0 to 99999, negative or positive.  Received #{number}"
             end.strip
    number < 0 ? "minus #{result}" : result
  end

  class OutOfBoundsException < ArgumentError; end
end

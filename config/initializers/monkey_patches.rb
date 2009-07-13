# TODO: Find a way to turn off stemming without resorting to a dirty trick
class Classifier::Base
  def stemmer
    @stemmer ||= NoopStemmer.new
  end

  # An implementation of the stemmer which returns the same word
  class NoopStemmer
    def stem(word)
      word
    end
  end
end

module CoreExt
  # Copied and adapted from
  # http://recursive.ca/hutch/2007/11/22/a-little-unnecessary-smalltalk-envy/
  # Bob Huntchison
  module Smalltalk
    module Object
      # yield self when it is non nil.
      def if_not_nil(&block)
        yield(self) if block
      end

      # yield to the block if self is nil
      def if_nil(&block)
        self
      end
    end

    module NilClass
      # yield self when it is non nil.
      def if_not_nil(&block)
        nil
      end

      # yield to the block if self is nil
      def if_nil(&block)
        yield if block
      end
    end
  end
end

Object.send :include, CoreExt::Smalltalk::Object
NilClass.send :include, CoreExt::Smalltalk::NilClass

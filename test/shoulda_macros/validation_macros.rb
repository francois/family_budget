module ValidationMacros
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def should_have_valid_fixtures(klass=self)
      should "have all valid fixtures" do
        klass.name.sub("Test", "").constantize.all.each do |object|
          assert object.valid?, "Fixture #{object.inspect} is invalid"
        end
      end
    end
  end
end

Test::Unit::TestCase.send :include, ValidationMacros

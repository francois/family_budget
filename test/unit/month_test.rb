require File.dirname(__FILE__) + "/../test_helper"

class MonthTest < Test::Unit::TestCase
  context "A month" do
    setup do
      @month = Month.new
    end

    context "without a family or date or year/month" do
      should "be invalid" do
        assert !@month.valid?
      end
    end

    context "with a family and date" do
      setup do
        @month.attributes = {:family => families(:beausoleil), :date => Date.today}
      end

      should "be valid" do
        assert_valid @month
      end

      should "have a year of Today" do
        assert_equal Date.today.year, @month.year
      end

      should "have a month of Today" do
        assert_equal Date.today.month, @month.month
      end
    end
  end

  context "A valid month" do
    setup do
      @month = Month.new(:family => families(:beausoleil), :date => Date.today)
    end

    context "calling #budgets" do
      setup do
        @budgets = @month.budgets
      end

      should "return budget instances that match the family" do
        assert @budgets.all? {|b| b.family == families(:beausoleil)}
      end
    end
  end
end

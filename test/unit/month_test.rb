require 'test_helper'

class MonthTest < ActiveSupport::TestCase
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

    context "where a budget exists for this month" do
      setup do
        @period = Date.today.at_beginning_of_month
        @budget = families(:beausoleil).budgets.create!(:year => @period.year, :month => @period.month, :account => accounts(:cell_phone_service), :amount => 2000)
      end

      context "calling #budgets" do
        setup do
          @budgets = @month.budgets
        end

        should "return budget instances that match the family" do
          assert @budgets.all? {|b| b.family == families(:beausoleil)}
        end

        should "include a NEW budget instance for the salary account for the current year and month" do
          assert @budgets.detect {|b| b.account == accounts(:salary) && b.year == @period.year && b.month == @period.month}.new_record?
        end

        should "include the existing budget instance for the cell phone service account for the current year and month" do
          assert !@budgets.detect {|b| b.account == accounts(:cell_phone_service) && b.year == @period.year && b.month == @period.month}.new_record?
        end

        should "return budget instances for all expense and income accounts" do
          assert_equal families(:beausoleil).accounts.incomes.count + families(:beausoleil).accounts.expenses.count, @budgets.length
        end
      end
    end
  end
end

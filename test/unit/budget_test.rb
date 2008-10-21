require File.dirname(__FILE__) + '/../test_helper'

class BudgetTest < ActiveSupport::TestCase
  should_have_valid_fixtures
  should_require_attributes :family_id, :account_id, :year, :month
  should_only_allow_numeric_values_for :year, :month, :amount
  should_ensure_value_in_range :year, (2000..2100)
  should_ensure_value_in_range :month, (1 .. 12)
  should_protect_attributes :family_id, :account_id

  context "A new budget" do
    setup do
      @budget = Budget.new
    end

    should "have a default amount of 0" do
      assert @budget.amount.zero?
    end
  end
end

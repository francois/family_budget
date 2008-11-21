require File.dirname(__FILE__) + '/../test_helper'

class BudgetTest < ActiveSupport::TestCase
  should_have_valid_fixtures
  should_require_attributes :family_id, :account_id
  should_only_allow_numeric_values_for :amount
  should_protect_attributes :family_id, :account_id
  should_allow_attributes :family, :account, :year, :month

  context "A budget" do
    setup do
      @budget = families(:beausoleil).budgets.build(:account => accounts(:cell_phone_service), :amount => 200)
    end

    context "with year and month" do
      setup do
        @budget.year   = 2009
        @budget.month  = 7
      end

      context "on save" do
        setup do
          @budget.save!
        end

        should_change "@budget.starting_on", :to => Date.new(2009, 7, 1)
      end
    end
  end

  context "A new empty budget" do
    setup do
      @budget = Budget.new
    end

    should "have a default amount of 0" do
      assert @budget.amount.zero?
    end
  end
end

require File.dirname(__FILE__) + '/../test_helper'

class FamilyTest < ActiveSupport::TestCase
  should_have_valid_fixtures
  should_require_attributes :name
  should_require_unique_attributes :name
  should_protect_attributes :family_ids, :budget_ids, :people_ids, :salt
  should_have_many :accounts, :budgets, :people, :bank_accounts, :bank_transactions

  context "A new family" do
    setup do
      @family = Family.new(:name => "Katherine")
    end

    context "on save" do
      setup do
        @family.save!
      end

      should_change "@family.salt"
      should_change "@family.salt", :to => /^[\da-f]{128}$/i

      context "on subsequent save" do
        setup do
          @family.name = "Ekatherina"
          @family.save!
        end

        should_not_change "@family.salt"
      end
    end
  end
end

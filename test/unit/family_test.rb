require File.dirname(__FILE__) + '/../test_helper'

class FamilyTest < ActiveSupport::TestCase
  should_have_valid_fixtures
  should_require_attributes :name
  should_require_unique_attributes :name
  should_protect_attributes :family_ids, :budget_ids, :people_ids
  should_have_many :accounts, :budgets, :people, :bank_accounts, :transactions
end

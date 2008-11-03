require File.dirname(__FILE__) + '/../test_helper'

class BankAccountTest < Test::Unit::TestCase
  should_have_valid_fixtures
  should_require_attributes :family_id, :account_id, :bank_number, :account_number
  should_protect_attributes :family_id, :account_id
  should_allow_attributes :family, :account, :bank_number, :account_number
  should_belong_to :account, :family
  should_have_many :transactions
end

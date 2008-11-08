require "generator"

class Import
  attr_accessor :family, :data

  def initialize(params={})
    params.each_pair do |attr, value|
      send("#{attr}=", value) if respond_to?("#{attr}=")
    end
  end

  def create_bank_accounts!
    accounts.each do |account|
      bank_account = bank_account_of(account)
      bank_account.save! if bank_account.new_record?
    end
  end

  def create_transactions!
    accounts.each do |account|
      bank_account = bank_account_of(account)
      account.transactions.each do |txn|
        transaction = family.transactions.find_or_initialize_by_fitid(txn.number)
        transaction.update_attributes!(:bank_account => bank_account, :amount => txn.amount, :name => txn.name, :memo => txn.memo, :posted_on => txn.timestamp) if transaction.new_record?
      end
    end
  end

  private
  def assert_family_present
    raise ArgumentError, "No family assigned to #{inspect}" unless family
  end

  def bank_account_of(account)
    family.bank_accounts.find_or_create_by_bank_number_and_account_number(account.bank_id, account.number)
  end

  def accounts
    assert_family_present
    @accounts ||= QuickenParser.parse(data)
  end
end

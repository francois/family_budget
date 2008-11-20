class Import
  attr_accessor :family, :data

  def initialize(params={})
    params.each_pair do |attr, value|
      send("#{attr}=", value)
    end
  end

  def process!
    accounts.each do |account|
      bank_account = bank_account_of(account)
      raise "Could not find account with #{account.inspect}" if bank_account.nil?
      account.transactions.each do |txn|
        bank_transaction = family.bank_transactions.find_or_initialize_by_fitid(txn.number)
        bank_transaction.update_attributes!(:bank_account => bank_account, :amount => txn.amount, :name => txn.name, :memo => txn.memo, :posted_on => txn.timestamp) if bank_transaction.new_record?
      end
    end
  end

  private
  def assert_family_present
    raise ArgumentError, "No family assigned to #{inspect}" unless family
  end

  def bank_account_of(account)
    bank_account = BankAccount.find_by_family_and_bank_number_and_account_number(family, account.bank_id, account.number)
    bank_account = family.bank_accounts.create!(:bank_number => account.bank_id, :account_number => account.number) if bank_account.blank?
    bank_account
  end

  def accounts
    assert_family_present
    @accounts ||= QuickenParser.parse(data)
  end
end

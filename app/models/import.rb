require "generator"

class Import
  attr_accessor :family, :data

  def initialize(params={})
    params.each_pair do |attr, value|
      send("#{attr}=", value) if respond_to?("#{attr}=")
    end
  end

  def create_bank_accounts!
    assert_family_present

    bankids = @data.scan(/<BANKID>(.+(?=<|$))/)
    acctids = @data.scan(/<ACCTID>(.+(?=<|$))/)
    SyncEnumerator.new(bankids.first, acctids.first).each do |bankid, acctid|
      bank_account = family.bank_accounts.find_or_initialize_by_bank_number_and_account_number(bankid, acctid)
      bank_account.save! if bank_account.new_record?
    end
  end

  def create_transactions!
    
  end

  private
  def assert_family_present
    raise ArgumentError, "No family assigned to #{inspect}" unless family
  end
end

require "quicken_parser"

class Import < ActiveRecord::Base
  belongs_to :family
  has_many :bank_transactions

  attr_accessor :data, :format
  attr_accessible :data, :format
  validates_presence_of :family_id

  # Returns the number of *new* bank transactions that were added.
  def process!
    raise ArgumentError, "No family assigned" unless family

    before_num = family.bank_transactions.count
    accounts.each do |account|
      bank_account = bank_account_of(account)
      raise "Could not find account with #{account.inspect}" if bank_account.nil?
      account.transactions.each do |txn|
        bank_transaction = family.bank_transactions.find_or_initialize_by_fitid(txn.number)
        bank_transaction.update_attributes!(:bank_account => bank_account, :amount => txn.amount.to_s, :name => txn.name, :memo => txn.memo, :posted_on => txn.timestamp) if bank_transaction.new_record?
      end
    end
    
    family.bank_transactions.count - before_num
  end

  private
  def bank_account_of(account)
    bank_account = BankAccount.find_by_family_and_bank_number_and_account_number(family, account.bank_id, account.number)
    bank_account = family.bank_accounts.create!(:bank_number => account.bank_id, :account_number => account.number) if bank_account.blank?
    bank_account
  end

  def accounts
    @accounts ||= QuickenParser.parse(data)
  end
end

class BankAccount < ActiveRecord::Base
  belongs_to :account
  belongs_to :family
  validates_presence_of :family_id
  attr_accessible :family, :account, :bank_number, :account_number
  has_many :bank_transactions, :dependent => :destroy

  attr_accessor :account_number

  before_save :generate_salted_account_number
  before_save :generate_display_account_number
  before_destroy :destroy_associated_transfers

  def to_s
    account ? account.name : display_account_number
  end

  class << self
    def find_by_family_and_bank_number_and_account_number(family, bank, number)
      family.bank_accounts.find_by_bank_number_and_salted_account_number(bank, family.encrypt(number))
    end
  end
  protected
  def generate_salted_account_number
    return if self.account_number.blank?
    self.salted_account_number = self.family.encrypt(self.account_number)
  end

  def generate_display_account_number
    return if self.account_number.blank?
    self.display_account_number = account_number.gsub(/^(.)(.*)(.{4})$/) do |match|
      "%s%s%s" % [$1, "*" * $2.length, $3]
    end

    # In an effort to have more security, overwrite the characters of
    # the account number with garbage, so a memory dump shouldn't
    # reveal the credit card number
    self.account_number.gsub!(/./, '*')

    # For our own purposes, reset the account number to nil so we dont' attempt to reformat the value again
    self.account_number = nil
  end

  def destroy_associated_transfers
    self.family.transfers.in_debit_accounts(self.account).each(&:destroy)
    self.family.transfers.in_credit_accounts(self.account).each(&:destroy)
  end
end

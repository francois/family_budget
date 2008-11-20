class BankAccount < ActiveRecord::Base
  belongs_to :account
  belongs_to :family
  validates_presence_of :family_id
  attr_accessible :family, :account, :bank_number, :account_number
  has_many :bank_transactions

  attr_accessor :account_number

  before_save :generate_salted_account_number
  before_save :generate_display_account_number

  def to_s
    account ? account.name : display_account_number
  end

  class << self
    def find_by_family_and_account_number(family, number)
      family.bank_accounts.find_by_salted_account_number(family.encrypt(number))
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
end

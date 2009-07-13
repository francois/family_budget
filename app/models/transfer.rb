class Transfer < ActiveRecord::Base
  class MulitpleBankTransactionsNotHandledYet < RuntimeError; end

  belongs_to :family
  belongs_to :debit_account, :class_name => "Account"
  belongs_to :credit_account, :class_name => "Account"
  has_and_belongs_to_many :bank_transactions

  before_validation :copy_amount_from_bank_transactions
  before_validation :copy_posted_on_from_bank_transactions
  before_validation :normalize_accounts_with_bank_transactions
  after_validation :swap_accounts_on_negative_amount
  validates_presence_of :family_id, :posted_on, :debit_account_id, :credit_account_id
  validate :presence_of_bank_transactions_or_debit_and_credit_account
  validate :no_transfer_between_same_accounts
  after_save :clear_associated_bank_transaction_auto_accounts

  attr_accessible :debit_account, :credit_account, :bank_transaction, :posted_on, :description, :amount

  named_scope :within_period, lambda {|period| {:conditions => {:posted_on => period}}}
  named_scope :in_debit_accounts, lambda {|accounts| {:conditions => {:debit_account_id => accounts}}}
  named_scope :in_credit_accounts, lambda {|accounts| {:conditions => {:credit_account_id => accounts}}}
  named_scope :group_amounts_by_period, :select => "TO_CHAR(posted_on, 'YYYY-MM-01') AS period, SUM(amount) AS amount",
                                        :group => "TO_CHAR(posted_on, 'YYYY-MM-01')"
  named_scope :in_year_month, lambda {|year, month|
    starting = Date.new(year, month, 1)
    ending = (starting >> 1) - 1
    {:conditions => {:posted_on => starting .. ending}}}
  named_scope :in_period, lambda {|period|
    case period
    when /^(\d{4})-?(\d{2})/
      year, month = $1.to_i, $2.to_i
      start = Date.new(year, month, 1)
      {:conditions => ["posted_on BETWEEN ? AND ?", start, (start >> 1) - 1]}
    when /^(\d{4})/
      year = $1.to_i
      {:conditions => ["posted_on BETWEEN ? AND ?", Date.new(year, 1, 1), Date.new(year, 12, 31)]}
    else
      {}
    end
  }
  named_scope :for_account, lambda {|account| {:conditions => ["debit_account_id = :account_id OR credit_account_id = :account_id", {:account_id => account.id}]}}
  named_scope :by_posted_on, :order => "posted_on DESC"

  def period
    read_attribute(:period) || posted_on.at_beginning_of_month.to_date
  end

  protected
  def copy_amount_from_bank_transactions
    return if self.bank_transactions.empty?
    return unless self.amount.blank?
    self.amount = self.bank_transactions.map(&:amount).min
  end

  def copy_posted_on_from_bank_transactions
    return if self.bank_transactions.empty?
    self.posted_on = self.bank_transactions.map(&:posted_on).min
  end

  def swap_accounts_on_negative_amount
    return if self.amount.blank? || self.amount >= 0
    self.amount = self.amount.abs
    self.credit_account, self.debit_account = self.debit_account, self.credit_account
  end

  def normalize_accounts_with_bank_transactions
    return if [self.credit_account, self.debit_account].all?
    return if self.bank_transactions.empty?

    case self.bank_transactions.length
    when 1
      if self.amount < 0 then
        # Reducing the asset's value (withdrawing money from the account)
        self.credit_account = self.bank_transactions.first.account
        self.amount         = self.amount.abs
      else
        # Increasing the asset's value (depositing money into the account)
        self.debit_account, self.credit_account = self.bank_transactions.first.account, self.debit_account
      end
    when 2
      bt0 = self.bank_transactions.first
      bt1 = self.bank_transactions.last
      if bt0.amount < 0 then
        self.debit_account, self.credit_account = bt0.account, bt1.account
      else
        self.debit_account, self.credit_account = bt1.account, bt0.account
      end
    else
      decreases, increases                 = self.bank_transactions.partition {|bt| bt.amount < 0}
      decrease_accounts, increase_accounts = decreases.map(&:account).uniq, increases.map(&:account).uniq
      decrease_amount, increase_amount     = decreases.map(&:amount).sum.abs, increases.map(&:amount).sum
      if decrease_amount == increase_amount && [decrease_accounts, increase_accounts].map(&:length).all? {|l| l == 1} then
        increase_account, decrease_account      = increase_accounts.first, decrease_accounts.first
        self.debit_account, self.credit_account = increase_account, decrease_account

        # Ensure the amounts will be swapped later, if need be
        self.amount = increase_account.asset? ? -increase_amount : increase_amount
      else
        raise "Not handled"
      end
    end
  end

  def presence_of_bank_transactions_or_debit_and_credit_account
    if self.bank_transactions.empty? then
      errors.add_on_blank("debit_account_id")
      errors.add_on_blank("credit_account_id")
    elsif self.bank_transactions.length == 1 then
      errors.add_on_blank("debit_account_id")
    # elsif self.bank_transactions.length > 2 then
    #   errors.add_to_base("Cannot handle multiple bank transations at this time -- call François")
    end
  end

  def no_transfer_between_same_accounts
    return unless debit_account == credit_account
    errors.add("debit_account_id", "cannot be the same as the credit account")
    errors.add("credit_account_id", "cannot be the same as the debit account")
  end

  def clear_associated_bank_transaction_auto_accounts
    self.bank_transactions.each(&:clear_auto_account!)
  end
end

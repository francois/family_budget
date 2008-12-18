class BankTransaction < ActiveRecord::Base
  belongs_to :family
  belongs_to :bank_account
  delegate :account, :to => :bank_account
  has_and_belongs_to_many :transfers

  attr_accessible :family, :bank_account, :debit_account, :credit_account, :fitid, :amount, :name, :memo, :posted_on, :bank_transactions

  validates_numericality_of :amount
  validates_presence_of :family_id, :bank_account_id, :posted_on, :name, :fitid, :amount
  validates_uniqueness_of :fitid, :scope => :family_id

  named_scope :with_name_or_memo_like, lambda {|text|
    string = "%#{text}%"
    {:conditions => ["LOWER(name) LIKE ? OR LOWER(memo) LIKE ?", string, string]}}
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

  named_scope :on_bank_account, lambda {|bank_account| {:conditions => {:bank_account_id => bank_account.id}}}
  named_scope :by_posted_on, :order => "posted_on"
  named_scope :pending, :select => "#{table_name}.*", :joins => "LEFT JOIN bank_transactions_transfers btt ON btt.bank_transaction_id = bank_transactions.id", :conditions => "btt.bank_transaction_id IS NULL AND #{table_name}.ignored_at IS NULL"

  def ignore!
    update_attribute(:ignored_at, Time.now.utc)
  end
end

require "classifier"
require "digest/sha1"

class Family < ActiveRecord::Base
  has_many :people, :dependent => :destroy
  has_many :transfers, :dependent => :destroy
  has_many :accounts, :order => "name", :dependent => :destroy
  has_many :budgets, :order => "account_id, starting_on", :dependent => :destroy
  has_many :bank_accounts
  has_many :bank_transactions
  has_many :imports

  validates_presence_of :name
  validates_uniqueness_of :name

  before_create :generate_salt
  before_save :update_classifier

  attr_accessible :name

  def classification_possibilities(bank_transaction, limit=3)
    classifications = classifier.classifications(classifier_text(bank_transaction)).reject {|category, score| score.infinite?}
    options         = classifications.sort_by(&:last).last(limit)
    names           = options.map(&:first).map(&:to_s)
    accnts          = self.accounts.all(:conditions => {:name => names})
    accnts.sort_by {|account| names.index(account.name)}
  end

  def classify_transaction(bank_transaction)
    classification_possibilities(bank_transaction, 1).last
  end

  def new_classifier
    income_or_expense_accounts = self.accounts.incomes + self.accounts.expenses
    Classifier::Bayes.new(:categories => income_or_expense_accounts.map(&:name))
  end

  def classifier
    @classifier ||= if self.classifier_dump.blank? then
                      logger.debug {"==> Instantiating new Classifier for #{self}"}
                      new_classifier
                    else
                      logger.debug {"==> Reusing existing Classifier instance for #{self}"}
                      Marshal.load(Base64.decode64(self.classifier_dump))
                    end
  end

  def to_s
    name
  end

  def clear_classifier
    @classifier = self.classifier_dump = nil
  end

  def retrain
    self.clear_classifier
    accounts = self.accounts.index_by(&:id)
    self.bank_transactions.all(:include => %w(transfers bank_account)).each do |bt|
      next unless bt.transfers.length == 1
      transfer = bt.transfers.first
      id = if transfer.debit_account_id == bt.bank_account.account_id then
             transfer.credit_account_id
           else
             transfer.debit_account_id
           end
      account = accounts[id]
      next unless account.income? || account.expense?
      train_classifier(bt, account)
    end
    save
  end

  def train_classifier(bank_transaction, account=nil)
    transfer = bank_transaction.transfers.first
    unless account
      account = if transfer.debit_account == bank_transaction.account then
                  transfer.credit_account
                else
                  transfer.debit_account
                end
    end

    text = classifier_text(bank_transaction)
    logger.debug {"==> Training #{text.inspect} => #{account.name}"}
    self.classifier.train(account.name, text)
  end

  def classifier_text(bank_transaction)
    text = []
    text << bank_transaction.name.to_s.gsub(/\W+/, " ")
    text << bank_transaction.memo.to_s.gsub(/\W+/, " ")
    text << NumberToWords.number_to_words(bank_transaction.amount)
    text << NumberToWords.number_to_words(bank_transaction.posted_on.day)
    text << NumberToWords.number_to_words(bank_transaction.posted_on.month)
    text << NumberToWords.number_to_words(bank_transaction.posted_on.year)
    text << bank_transaction.account.name if bank_transaction.account
    text.join(" ")
  end

  def encrypt(*args)
    raise ArgumentError, "No salt defined in the family -- can't encrypt!" if salt.blank?
    args.flatten!
    args.compact!
    args.unshift(salt)
    Digest::SHA1.hexdigest("--%s--" % args.join("--"))
  end

  def budget_for(year, month)
    returning({}) do |hash|
      self.budgets.for_period(year, month).each {|budget| hash[budget.account] = budget}
      budgeted_accounts = hash.keys
      budgetable_accounts = self.accounts.expenses + self.accounts.incomes
      budgetable_accounts.delete_if {|a| budgeted_accounts.include?(a)}
      budgetable_accounts.each {|account| hash[account] = self.budgets.build(:account => account, :year => year, :month => month, :amount => 0)}
    end.values
  end

  def income_amounts_in_dates(range)
    amounts_in_dates(transfers.in_credit_accounts(accounts.purposes(Account::Income)), range)
  end

  def expense_amounts_in_dates(range)
    amounts_in_dates(transfers.in_debit_accounts(accounts.purposes(Account::Expense)), range)
  end

  protected
  def generate_salt
    self.salt = ActiveSupport::SecureRandom.hex(64)
  end

  def amounts_in_dates(root, range)
    starting_on, ending_on = range.first, range.last
    starting_on = starting_on.beginning_of_month.to_date
    ending_on   = (ending_on.beginning_of_month >> 1).to_date
    data = root.within_period(starting_on .. ending_on).group_amounts_by_period.inject({}) do |memo, transfer|
      memo[Date.parse(transfer.period)] = transfer.amount.to_f
      memo
    end
    date = starting_on
    while date < ending_on
      data[date] = 0 unless data.has_key?(date)
      date = date >> 1
    end
    data.sort
  end

  def update_classifier
    logger.debug {"==> Updating classifier: #{classifier_dump_changed?}"}
    self.classifier_dump = Base64.encode64(Marshal.dump(self.classifier))
  end
end

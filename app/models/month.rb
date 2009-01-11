class Month
  attr_accessor :family, :year, :month

  def initialize(params={})
    self.attributes = params
  end

  def attributes=(params)
    params.each do |key, val|
      send("#{key}=", val)
    end
  end

  def date=(date)
    @year, @month = date.year, date.month
  end

  def valid?
    !(@family.blank? || [@year, @month].all?(&:blank?))
  end

  def errors
    @errors ||= ActiveRecord::Errors.new(self)
  end

  def budgets
    return @budgets if @budgets
    budgets          = @family.budgets.for_period(@year, @month)
    income_accounts  = @family.accounts.incomes.all
    expense_accounts = @family.accounts.expenses.all
    accounts = (income_accounts + expense_accounts).inject(Hash.new) do |memo, account|
      memo[account] = budgets.detect {|b| b.account == account} || @family.budgets.build(:year => @year, :month => @month, :account => account)
      memo
    end
    @budgets = accounts.values
  end
end

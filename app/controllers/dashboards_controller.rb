class DashboardsController < ApplicationController
  helper_method :current_period, :most_active_expense_accounts, :most_active_income_accounts, :total_incomes_amount, :total_expenses_amount

  def show
#    historical_expenses = Transfer.find(:all, :select => "DATE_FORMAT(posted_on, '%Y-%m-01') period, SUM(amount) amount", :group => "DATE_FORMAT(posted_on, '%Y-%m-01')", :conditions => ["debit_account_id IN (?)", current_family.accounts.purposes(Account::Expense)]).inject({}) {|memo, t| memo[Date.parse(t.period)] = Float(t.amount); memo}
#    historical_incomes = Transfer.find(:all, :select => "DATE_FORMAT(posted_on, '%Y-%m-01') period, SUM(amount) amount", :group => "DATE_FORMAT(posted_on, '%Y-%m-01')", :conditions => ["credit_account_id IN (?)", current_family.accounts.purposes(Account::Income)]).inject({}) {|memo, t| memo[Date.parse(t.period)] = Float(t.amount); memo}
    @historical_expenses, @historical_incomes = [], []
#    start_period = current_period << 12
#    12.times do |index|
#      period = start_period >> (index + 1)
#      @historical_expenses << (historical_expenses[period] || 0)
#      @historical_incomes << (historical_incomes[period] || 0)
#    end
  end

  protected
  def current_period
    @current_period ||= if params[:period].blank? then
                          current_date.beginning_of_month.to_date
                        else
                          params[:period].gsub(/\D/, "")
                        end
  end

  def most_active_expense_accounts
    @most_active_expense_accounts ||= current_family.accounts.most_active_expense_in_period(current_period)
  end

  def total_expenses_amount
    @total_expense_amount ||= most_active_expense_accounts.map(&:amount).map(&:to_f).sum
  end

  def most_active_income_accounts
    @most_active_income_accounts ||= current_family.accounts.most_active_income_in_period(current_period)
  end

  def total_incomes_amount
    @total_income_amount ||= most_active_income_accounts.map(&:amount).map(&:to_f).sum
  end
end

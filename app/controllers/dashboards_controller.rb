class DashboardsController < ApplicationController
  helper_method :current_period

  def show
    @period = params[:period]
    @period = current_period.strftime("%Y-%m") if @period.blank?
    root = Account.in_period(@period)
    @top_expenses = root.purposes(Account::Expense).by_most_debited.paginate(:per_page => 10, :page => 1, :conditions => {:family_id => current_family})
    @sum_of_expenses = @top_expenses.map(&:amount).map(&:to_f).sum
    @top_incomes = root.purposes(Account::Income).by_most_credited.paginate(:per_page => 10, :page => 1, :conditions => {:family_id => current_family})
    @sum_of_incomes = @top_incomes.map(&:amount).map(&:to_f).sum

    historical_expenses = Transfer.find(:all, :select => "DATE_FORMAT(posted_on, '%Y-%m-01') period, SUM(amount) amount", :group => "DATE_FORMAT(posted_on, '%Y-%m-01')", :conditions => ["debit_account_id IN (?)", current_family.accounts.purposes(Account::Expense)]).inject({}) {|memo, t| memo[Date.parse(t.period)] = Float(t.amount); memo}
    historical_incomes = Transfer.find(:all, :select => "DATE_FORMAT(posted_on, '%Y-%m-01') period, SUM(amount) amount", :group => "DATE_FORMAT(posted_on, '%Y-%m-01')", :conditions => ["credit_account_id IN (?)", current_family.accounts.purposes(Account::Income)]).inject({}) {|memo, t| memo[Date.parse(t.period)] = Float(t.amount); memo}
    @historical_expenses, @historical_incomes = [], []
    start_period = current_period << 12
    12.times do |index|
      period = start_period >> (index + 1)
      @historical_expenses << (historical_expenses[period] || 0)
      @historical_incomes << (historical_incomes[period] || 0)
    end
  end

  protected
  def current_period
    @current_period ||= current_date.beginning_of_month.to_date
  end
end

class BudgetsController < ApplicationController
  def show
    @budget_date = Date.today
    @budget_year, @budget_month = budget_date.year, budget_date.month
    @budget_date = Date.new(@budget_year, @budget_month+1, 1)
    @periods = [@budget_date, @budget_date << 1, @budget_date << 2]

    @income_accounts = current_family.accounts.incomes
    @income_budgets = @income_accounts.inject(Hash.new {|h,k| h[k] = []}) do |h, account|
      @periods.each do |period|
        h[account] << current_family.budgets.for_account_year_month(account, period.year, period.month)
      end
      h
    end

    @expense_accounts = current_family.accounts.expenses
    @expense_budgets = @expense_accounts.inject(Hash.new {|h,k| h[k] = []}) do |h, account|
      @periods.each do |period|
        h[account] << current_family.budgets.for_account_year_month(account, period.year, period.month)
      end
      h
    end
  end

  protected
  attr_reader :budget_date, :budget_year, :budget_month
  helper_method :budget_date, :budget_year, :budget_month
end

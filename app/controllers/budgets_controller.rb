class BudgetsController < ApplicationController
  before_filter :load_budget_date

  attr_reader :budget_date, :budget_year, :budget_month
  helper_method :budget_date, :budget_year, :budget_month

  def show
    @periods = [@budget_date, @budget_date << 1, @budget_date << 2]

    @income_accounts  = current_family.accounts.incomes
    @expense_accounts = current_family.accounts.expenses
  end

  def update
    Budget.transaction do
      params[:budget].each do |account_id, amount|
        amount = amount.blank? ? "0" : amount
        budget = current_family.budgets.find_or_initialize_by_account_id_and_starting_on(account_id, budget_date)
        budget.update_attributes!(:amount => amount)
      end
    end

    redirect_to budget_path
  end

  protected
  def load_budget_date
    if params[:date] then
      @budget_date = Date.parse(params[:date])
    else
      @budget_date = current_date.at_beginning_of_month.to_date
      @budget_date = @budget_date >> 1 if @budget_date.day > 7
    end

    @budget_year, @budget_month = budget_date.year, budget_date.month
  end
end

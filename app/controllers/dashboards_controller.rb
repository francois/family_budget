class DashboardsController < ApplicationController
  helper_method :current_period, :most_active_expense_accounts, :most_active_income_accounts, :total_incomes_amount, :total_expenses_amount, :total_expenses_per_period, :total_incomes_per_period, :dates_for_period

  def show
    render
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

  def total_expenses_per_period(count=12)
    @total_expenses_per_period ||= current_family.expense_amounts_in_dates(dates_for_period).map(&:last)
  end

  def total_incomes_per_period(count=12)
    @total_incomes_per_period ||= current_family.income_amounts_in_dates(dates_for_period).map(&:last)
  end

  def dates_for_period(count=12)
    start, stop = (current_date << count - 1), (current_date >> 1).at_beginning_of_month.to_date
    returning([]) do |dates|
      while start < stop
        dates << start.at_beginning_of_month.to_date
        start = start >> 1
      end
    end
  end
end

class DashboardsController < ApplicationController
  skip_before_filter :login_required, :only => %w(show)

  helper_method :current_period, :most_active_expense_accounts, :most_active_income_accounts, :total_incomes_amount, :total_expenses_amount, :total_expenses_per_period, :total_incomes_per_period, :dates_for_period

  def show
    if logged_in? then
      @previous_period = current_period << 1
      @next_period     = current_period >> 1
      render :action => :show
    else
      render :action => :welcome
    end
  end

  protected
  def current_period
    @current_period ||= if params[:period].blank? then
                          current_date.beginning_of_month.to_date
                        else
                          md = params[:period].gsub(/\D/, "").match(/\A(\d{4})(\d{2})\Z/)
                          Date.new(md[1].to_i, md[2].to_i, 1)
                        end
  end

  def most_active_expense_accounts
    @most_active_expense_accounts ||= current_family.accounts.most_active_expense_in_period(current_period).paginate(:per_page => 10, :page => 1)
  end

  def total_expenses_amount
    @total_expense_amount ||= most_active_expense_accounts.map(&:amount).map(&:to_f).sum
  end

  def most_active_income_accounts
    @most_active_income_accounts ||= current_family.accounts.most_active_income_in_period(current_period).paginate(:per_page => 10, :page => 1)
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

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
    logger.debug {[@top_expenses, @sum_of_expenses, @top_incomes, @sum_of_incomes].to_yaml}
  end

  protected
  def current_period
    @current_period ||= current_date
  end
end

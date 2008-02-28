class WelcomesController < ApplicationController
  def show
    if current_family.accounts.empty? then
      @account = current_family.accounts.build
      @purposes = Account::ValidPurposes
      render :action => :no_accounts
    else
      @assets = current_family.accounts.assets
      @liabilities = current_family.accounts.liabilities
      @equities = current_family.accounts.equities
      @incomes = current_family.accounts.incomes
      @expenses = current_family.accounts.expenses

      @bought = current_family.transfers.build
      @reimbursed = current_family.transfers.build
      @paid = current_family.transfers.build
      @received = current_family.transfers.build
    end
  end

  protected
  def authorized?
    logged_in?
  end

  def access_denied
    render :action => :unauthenticated
  end
end

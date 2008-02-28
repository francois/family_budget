class WelcomesController < ApplicationController
  before_filter :login_required

  def show
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

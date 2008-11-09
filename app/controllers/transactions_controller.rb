class TransactionsController < ApplicationController
  helper_method :transactions, :transaction, :accounts, :income_and_expense_accounts

  def index
  end

  protected
  def transactions
    @transactions ||= current_family.transactions.by_posted_on
  end

  def transation
    @transactions ||= current_family.transactions.find(params[:id])
  end

  def accounts
    @accounts ||= current_family.accounts
  end

  def income_and_expense_accounts
    @accounts ||= current_family.accounts.purposes(Account::Income, Account::Expense).by_type_and_name
  end
end

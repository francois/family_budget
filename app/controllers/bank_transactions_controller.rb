class BankTransactionsController < ApplicationController
  helper_method :bank_transactions, :bank_transaction, :accounts, :income_and_expense_accounts

  def index
  end

  def create
  end

  protected
  def bank_transactions
    @bank_transactions ||= current_family.bank_transactions.pending.by_posted_on
  end

  def bank_transaction
    @bank_transactions ||= current_family.bank_transactions.find(params[:id])
  end

  def accounts
    @accounts ||= current_family.accounts
  end

  def income_and_expense_accounts
    @accounts ||= current_family.accounts.purposes(Account::Income, Account::Expense).by_type_and_name
  end
end

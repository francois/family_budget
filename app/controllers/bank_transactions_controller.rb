class BankTransactionsController < ApplicationController
  helper_method :bank_transactions, :bank_transaction, :accounts, :income_and_expense_accounts, :bank_accounts

  def index
    @period = params[:period]
    @bank_account_id = params[:bank_account_id]
    root = current_family.bank_transactions.pending.by_posted_on
    root = root.in_period(params[:period]) unless params[:period].blank?
    root = root.on_bank_account(current_family.bank_accounts.find(params[:bank_account_id])) unless params[:bank_account_id].blank?
    @bank_transactions = root.paginate(:per_page => 200, :page => params[:page])
  end

  def create
  end

  protected
  def bank_transactions
    @bank_transactions ||= current_family.bank_transactions.pending.by_posted_on.paginate(:per_page => 200, :page => params[:page])
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

  def bank_accounts
    @bank_accounts ||= current_family.bank_accounts
  end
end

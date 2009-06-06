class BankTransactionsController < ApplicationController
  helper_method :bank_transactions, :bank_transaction, :accounts, :income_and_expense_accounts, :bank_accounts

  def index
    @period          = params[:period]
    @bank_account_id = params[:bank_account_id]
    @text            = params[:text]
    @processed       = params[:processed] == "1"

    root = current_family.bank_transactions.by_posted_on
    root = root.pending unless @processed
    root = root.in_period(@period) unless @period.blank?
    root = root.on_bank_account(current_family.bank_accounts.find(@bank_account_id)) unless @bank_account_id.blank?
    root = root.with_name_or_memo_like(@text) unless @text.blank?
    @bank_transactions = root.paginate(:per_page => 200, :page => params[:page])
  end

  def create
  end

  def update
    bank_transaction.unignore!
    respond_to :js
  end

  def destroy
    bank_transaction.ignore!
    respond_to do |format|
      format.html { redirect_to(budget_account_url(bank_transaction.account) }
      format.js
    end
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

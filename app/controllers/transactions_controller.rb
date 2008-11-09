class TransactionsController < ApplicationController
  helper_method :transactions, :transaction, :accounts

  def index
  end

  protected
  def transactions
    @transactions ||= current_family.transactions
  end

  def transation
    @transactions ||= current_family.transactions.find(params[:id])
  end

  def accounts
    @accounts ||= current_family.accounts
  end
end

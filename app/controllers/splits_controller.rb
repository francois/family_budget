class SplitsController < ApplicationController
  helper_method :bank_transaction, :expense_accounts

  def edit
    render
  end

  def update
    @split = Split.new(:bank_transaction => bank_transaction, :account_ids => params[:account_id], :amounts => params[:amount], :family => current_family)
    @split.save!

    flash[:notice] = "#{@split.transfers.length} transferts fûrent créés"
    redirect_to bank_transactions_path
  end

  protected
  def bank_transaction
    @bank_transaction ||= current_family.bank_transactions.find(params[:id])
  end

  def expense_accounts
    @accounts ||= current_family.accounts.expenses
  end
end

class SplitsController < ApplicationController
  helper_method :split, :bank_transaction, :expense_accounts

  def edit
    render
  end

  def update
    if split.save then
      flash[:notice] = "#{split.transfers.length} transferts fûrent créés"
      redirect_to bank_transactions_path
    else
      render :action => :edit
    end
  end

  protected
  def split
    ps = params[:split].nil? ? {} : params[:split]
    @split ||= Split.new(:bank_transaction => bank_transaction, :account_ids => ps[:account_id], :amounts => ps[:amount], :family => current_family)
  end

  def bank_transaction
    @bank_transaction ||= current_family.bank_transactions.find(params[:id])
  end

  def expense_accounts
    @accounts ||= current_family.accounts.expenses
  end
end

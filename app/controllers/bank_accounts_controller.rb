class BankAccountsController < ApplicationController
  helper_method :bank_account, :bank_accounts, :accounts

  def index
    respond_to do |wants|
      wants.html
      wants.js { render :json => bank_accounts, :content_type => "text/javascript" }
    end
  end

  def show
    respond_to do |wants|
      wants.js { render :json => bank_account, :content_type => "text/javascript" }
    end
  end

  def edit
    respond_to do |wants|
      wants.html
    end
  end

  def update
    transform_account!
    bank_account.update_attributes!(params[:bank_account])
    flash[:notice] = "Compte #{bank_account} mis à jour"
    redirect_to bank_accounts_path
  end

  def destroy
    bank_account.destroy
    flash[:notice] = "Le compte #{bank_account.display_account_number} a été détruit"
    redirect_to bank_accounts_path
  end

  protected
  def bank_accounts
    @bank_accounts ||= current_family.bank_accounts
  end

  def bank_account
    @bank_account ||= current_family.bank_accounts.find(params[:id])
  end

  def accounts
    @accounts ||= current_family.accounts.assets + current_family.accounts.liabilities
  end

  def transform_account!
    params[:bank_account][:account] = current_family.accounts.find(params[:bank_account].delete(:account))
  end
end

class ImportsController < ApplicationController
  ssl_required :new, :create
  before_filter :load_import, :only => %w(show update destroy)

  def new
    render
  end

  def create
    @import = current_family.imports.build(params[:import])
    Import.transaction do
      @num_transactions = @import.process!
    end
    flash[:notice] = "#{@num_transactions} transactions banquaires ont été ajoutées"
    redirect_to @import
  end

  def show
    @bank_transactions = @import.bank_transactions.all(:include => :auto_account).dup
    @bank_transactions.delete_if {|bt| bt.auto_account_id.nil?}
    @bank_transactions = @bank_transactions.group_by(&:auto_account)
    return redirect_to(transfers_path) if @bank_transactions.empty?
  end

  def update
    case
    when params[:account_id]
      @account = current_family.accounts.find(params[:account_id])
      BankTransaction.transaction do
        @import.bank_transactions.all(:include => :auto_account, :conditions => {:auto_account_id => @account.id}).each do |bt|
          transfer = current_family.transfers.build(:posted_on => current_date, :debit_account => @account)
          transfer.bank_transactions << bt
          transfer.save!
        end
      end
    when params[:bank_transaction_id]
      @bank_transaction = current_family.bank_transactions.find(params[:bank_transaction_id])
      transfer = current_family.transfers.build(:posted_on => current_date, :debit_account => @bank_transaction.auto_account)
      transfer.bank_transactions << @bank_transaction
      transfer.save!
    else
      raise ArgumentError, "Did not find either :account_id or :bank_transaction_id"
    end

    redirect_to @import
  end

  def destroy
    @bank_transaction = current_family.bank_transactions.find(params[:bank_transaction_id])
    @bank_transaction.update_attribute(:auto_account, nil)
    redirect_to @import
  end

  protected
  def load_import
    @import = current_family.imports.find(params[:id])
  end
end

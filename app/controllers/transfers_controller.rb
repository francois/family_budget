class TransfersController < ApplicationController
  helper_method :transfers, :transfer, :accounts, :bank_transaction

  def index
    respond_to do |format|
      format.html
    end
  end

  def new
    @transfer = transfer

    respond_to do |format|
      format.html
    end
  end

  def edit
    render
  end

  def create
    transfer.debit_account     = current_family.accounts.find_by_id(params[:transfer][:debit_account_id])
    transfer.credit_account    = current_family.accounts.find_by_id(params[:transfer][:credit_account_id])
    transfer.bank_transactions << current_family.bank_transactions.find_all_by_id(params[:transfer][:bank_transaction_id])
    transfer.posted_on         = current_date
    Transfer.transaction do
      respond_to do |format|
        if transfer.save
          flash_message = "Transféré #{transfer.amount} de #{transfer.debit_account} à #{transfer.credit_account}, en date du #{transfer.posted_on}"
          format.html do
            flash[:notice] = flash_message
            redirect_to transfers_path 
          end
          format.js do
            flash.now[:notice] = flash_message
            render
          end
        else
          format.html { render :action => "new" }
          format.js { render :action => "new" }
        end
      end
    end
  end

  def update
    respond_to do |format|
      if transfer.update_attributes(params[:transfer])
        flash[:notice] = "Transfer mis à jour"
        format.html { redirect_to transfers_path }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    transfer.destroy

    respond_to do |format|
      flash_message = "Transfer détruit"
      format.html do
        flash[:notice] = flash_message
        redirect_to transfers_path
      end
      format.js do
        flash.now[:notice] = flash_message
        render
      end
    end
  end

  protected
  def transfers
    @transfers ||= current_family.transfers.all
  end

  def transfer
    @transfer ||= params.has_key?(:id) ? current_family.transfers.find(params[:id]) : current_family.transfers.build(params[:transfer])
  end

  def accounts
    @accounts ||= current_family.accounts.all
  end

  def bank_transaction
    @bank_transaction ||= current_family.bank_transactions.find(params[:transfer][:bank_transaction_id])
  end
end

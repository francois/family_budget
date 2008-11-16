class TransfersController < ApplicationController
  helper_method :transfers, :transfer, :accounts

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
    transfer.debit_account  = current_family.accounts.find_by_id(params[:transfer][:debit_account_id])
    transfer.credit_account = current_family.accounts.find_by_id(params[:transfer][:credit_account_id])
    transfer.transaction    = current_family.transactions.find_by_id(params[:transfer][:transaction_id])
    transfer.posted_on      = current_date
    Transfer.transaction do
      respond_to do |format|
        if transfer.save
          flash[:notice] = "Transféré #{transfer.amount} de #{transfer.debit_account} à #{transfer.credit_account}, en date du #{transfer.posted_on}"
          format.html { redirect_to transfers_path }
        else
          transfer.save!
          format.html { render :action => "new" }
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
      flash[:notice] = "Transfer détruit"
      format.html { redirect_to transfers_path }
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
end

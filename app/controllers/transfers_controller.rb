class TransfersController < ApplicationController
  before_filter :load_transfer, :only => %w(show edit update destroy)
  before_filter :load_accounts, :only => %w(new edit)

  def index
    @transfers = current_family.transfers.find(:all, :order => "posted_on, created_at")

    respond_to do |format|
      format.html
    end
  end

  def new
    @transfer = current_family.transfers.build

    respond_to do |format|
      format.html
    end
  end

  def edit
    render
  end

  def create
    @transfer = current_family.transfers.build(params[:transfer])
    @transfer.posted_on = current_date
    respond_to do |format|
      if @transfer.save
        flash[:notice] = 'Transfer was successfully created.'
        format.html { redirect_to welcome_path }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @transfer.update_attributes(params[:transfer])
        flash[:notice] = 'Transfer was successfully updated.'
        format.html { redirect_to transfers_path }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @transfer.destroy

    respond_to do |format|
      format.html { redirect_to transfers_path }
    end
  end

  protected
  def load_transfer
    @transfer = current_family.transfers.find(params[:id])
  end

  def load_accounts
    @accounts = current_family.accounts.find(:all).map {|a| [a.name, a.id]}
  end
end

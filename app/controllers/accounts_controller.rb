class AccountsController < ApplicationController
  before_filter :load_account, :only => %w(show edit update destroy)
  before_filter :load_purposes, :only => %w(index new edit)

  def index
    @purpose = params[:purpose]
    return redirect_to(accounts_path) if @purpose.blank? and params.has_key?(:purpose)

    options = Hash.new
    options[:conditions] = ["purpose = ?", @purpose] unless @purpose.blank?
    options[:order] = "name"
    @accounts = current_family.accounts.find(:all, options)

    @purposes.unshift ["Tous", ""]
    respond_to do |format|
      format.html
    end
  end

  def new
    @account = current_family.accounts.build

    respond_to do |format|
      format.html
    end
  end

  def edit
    render
  end

  def create
    @account = current_family.accounts.build(params[:account])

    respond_to do |format|
      if @account.save
        flash[:notice] = 'Account was successfully created.'
        format.html { redirect_to(@account) }
      else
        load_purposes
        format.html { render :action => "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @account.update_attributes(params[:account])
        flash[:notice] = 'Account was successfully updated.'
        format.html { redirect_to(@account) }
      else
        load_purposes
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @account.destroy

    respond_to do |format|
      format.html { redirect_to(accounts_url) }
    end
  end

  protected
  def load_account
    @account = current_family.accounts.find(params[:id])
  end

  def load_purposes
    @purposes = Account::ValidPurposes
  end
end

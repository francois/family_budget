class AccountsController < ApplicationController
  before_filter :load_account, :only => %w(show edit update destroy)
  before_filter :load_purposes, :only => %w(new edit)

  def index
    @accounts = Account.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @account = Account.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    render
  end

  def create
    @account = Account.new(params[:account])

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
    @account = Account.find(params[:id])
  end

  def load_purposes
    @purposes = Account::ValidPurposes
  end
end

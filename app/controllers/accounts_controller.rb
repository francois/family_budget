class AccountsController < ApplicationController
  before_filter :load_account, :only => %w(show edit update destroy)
  before_filter :load_purposes, :only => %w(index new edit)

  def index
    @purpose = params[:purpose]
    return redirect_to(accounts_path) if @purpose.blank? and params.has_key?(:purpose)

    @accounts = current_family.accounts.purposes(@purpose.blank? ? Account::ValidPurposes : @purpose)

    @purposes.unshift ["Tous", ""]
    respond_to do |format|
      format.html
    end
  end

  def show
    accounts          = current_family.accounts.all(:order => "name")
    @next_account     = accounts[accounts.index(@account) + 1]
    @previous_account = accounts[accounts.index(@account) - 1]

    # Can't seem to find another way to do it, so go with the flow...
    # We need to ensure we have a date object for each period we're interested in
    @dates = []
    (11.months.ago.to_date .. (Date.today >> 1)).step(31) do |date|
      @dates << date.at_beginning_of_month.to_date
    end
  end

  def new
    @account = current_family.accounts.build(:purpose => params[:purpose])

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
        flash[:notice] = "Compte créé"
        format.html { redirect_to new_account_path(:purpose => @account.purpose) }
      else
        load_purposes
        format.html { render :action => "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @account.update_attributes(params[:account])
        flash[:notice] = "Compte modifié"
        format.html { redirect_to accounts_path }
      else
        load_purposes
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @account.destroy

    respond_to do |format|
      flash[:notice] = "Compte détruit"
      format.html { redirect_to accounts_path }
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

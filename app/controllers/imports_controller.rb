class ImportsController < ApplicationController
  ssl_required :new, :create

  def new
  end

  def create
    @import = Import.new(params[:import])
    @import.family = current_family
    num_transactions = @import.process!
    flash[:notice] = "#{num_transactions} transactions banquaires ont été ajoutées"
    redirect_to bank_transactions_url
  end
end

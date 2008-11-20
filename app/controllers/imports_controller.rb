class ImportsController < ApplicationController
  ssl_required :new, :create

  def new
  end

  def create
    @import = Import.new(params[:import])
    @import.family = current_family
    @import.process!
    redirect_to bank_transactions_url
  end
end

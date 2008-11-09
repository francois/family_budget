class ImportsController < ApplicationController
  def new
  end

  def create
    @import = Import.new(params[:import])
    @import.family = current_family
    @import.process!
    redirect_to transactions_url
  end
end

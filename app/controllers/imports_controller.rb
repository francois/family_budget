class ImportsController < ApplicationController
  def new
  end

  def create
    redirect_to transactions_url
  end
end

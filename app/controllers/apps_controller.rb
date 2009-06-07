class AppsController < ApplicationController
  before_filter :login_required
  layout false
  ssl_required :show

  def show
    respond_to :html, :js
  end
end

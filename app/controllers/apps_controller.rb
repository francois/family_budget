class AppsController < ApplicationController
  before_filter :login_required
  layout false
  ssl_required :show

  def show
    render
  end
end

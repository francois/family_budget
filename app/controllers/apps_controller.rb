class AppsController < ApplicationController
  before_filter :login_required
  layout false

  def show
    render
  end
end

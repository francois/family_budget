class WelcomesController < ApplicationController
  caches_page :show

  def show
  end

  protected
  def authorized?
    logged_in?
  end

  def access_denied
    render :action => :unauthenticated
  end
end

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all
  helper_method :current_family, :current_date

  before_filter :login_required
  before_filter :load_family
  before_filter :load_date

  protected
  def load_family
    @_current_family ||= self.current_person.family if logged_in?
  end

  def current_family
    @_current_family
  end

  def load_date
    @_current_date = session[:current_date] || Date.today
  end

  def current_date=(date)
    @_current_date = date.to_date
  end

  def current_date
    @_current_date
  end
end

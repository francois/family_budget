class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all
  helper_method :current_family

  before_filter :login_required
  before_filter :load_family

  protected
  def load_family
    @_current_family ||= self.current_person.family if logged_in?
  end

  def current_family
    @_current_family
  end
end

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ExceptionNotifiable
  include SslRequirement

  helper :all
  helper_method :current_family

  before_filter :login_required

  protected
  def current_family
    @_current_family ||= self.current_person.family if logged_in?
  end
end

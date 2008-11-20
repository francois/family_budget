class ApplicationController < ActionController::Base
  include SslRequirement
  include AuthenticatedSystem
  include ExceptionNotifiable

  helper :all
  helper_method :current_family, :current_date

  before_filter :login_required

  protected
  def current_family
    @_current_family ||= self.current_person.family if logged_in?
  end

  def current_date
    current_time.to_date
  end

  def current_time
    timezone.utc_to_local(Time.now.utc)
  end

  def timezone
    TZInfo::Timezone.get("America/Montreal")
  end
end

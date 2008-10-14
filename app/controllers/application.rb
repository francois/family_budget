class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ExceptionNotifiable

  helper :all
  helper_method :current_family, :current_date, :to_local_time, :to_utc_time, :current_timezone

  before_filter :load_date
  before_filter :login_required

  protected
  def current_family
    @_current_family ||= self.current_person.family if logged_in?
  end

  def load_date
    @_current_utc_date = session[:current_date] || Date.today
  end

  def current_utc_date=(date)
    @_current_utc_date = session[:current_date] = date.to_date
  end

  def current_utc_date
    @_current_utc_date
  end

  def current_date
    utc_to_local(current_utc_date).to_date
  end

  def current_date=(local_date)
    self.current_utc_date = local_to_utc(local_date)
  end

  def utc_to_local(utc_time)
    current_timezone.utc_to_local(utc_time.to_time)
  end

  def local_to_utc(local_time)
    current_timezone.local_to_utc(local_time.to_time)
  end

  def current_timezone
    @_current_timezone ||= TZInfo::Timezone.get("America/Montreal")
  end
end

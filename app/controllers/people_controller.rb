class PeopleController < ApplicationController
  skip_before_filter :login_required, :only => %w(new create)

  def new
    render
  end

  def create
    cookies.delete :auth_token
    reset_session
    @person = Person.new(params[:person])
    if @person.save then
      self.current_person = @person
      redirect_back_or_default("/")
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => "new"
    end
  end
end

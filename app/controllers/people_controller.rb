class PeopleController < ApplicationController
  skip_before_filter :login_required, :only => %w(new create)

  def new
    @family = Family.new
    @person = Person.new
    render
  end

  def create
    cookies.delete :auth_token
    reset_session
    Family.transaction do
      @family = Family.create!(params[:family])
      @person = @family.people.build(params[:person])
      if @person.save then
        self.current_person = @person
        redirect_back_or_default("/")
        flash[:notice] = "Thanks for signing up!"
      else
        render :action => "new"
      end
    end
  end
end

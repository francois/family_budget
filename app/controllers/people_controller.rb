class PeopleController < ApplicationController
  skip_before_filter :login_required, :only => %w(new create)
  before_filter :load_person, :only => %w(show edit update destroy)

  def index
    @people = current_family.people
  end

  def new
    @family = Family.new
    @person = Person.new
  end

  def create
    cookies.delete :auth_token
    reset_session
    Family.transaction do
      @family = if current_family then
                  current_family
                else
                  Family.create!(params[:family])
                end
      @person = @family.people.build(params[:person])
      if @person.save then
        self.current_person = @person
        redirect_back_or_default("/")
        flash[:notice] = "Merci de vous être enregistré!"
      else
        render :action => "new"
      end
    end
  end

  def edit
    render
  end

  def update
    if @person.update_attributes(params[:person]) then
      flash[:notice] = "Membre de la famille mis à jour"
      redirect_to people_path
    else
      render :action => :edit
    end
  end

  def destroy
    @person.destroy
    flash[:notice] = "Membre de famille détruit"
    redirect_to people_path
  end

  protected
  def load_person
    @person = current_family.people.find(params[:id])
  end
end

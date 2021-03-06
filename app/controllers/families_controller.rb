class FamiliesController < ApplicationController
  before_filter :load_family, :only => %w(show edit update destroy)

  def index
    @families = Family.find(:all)
  end

  def new
    @family = Family.new
  end

  def create
    @family = Family.new(params[:family])
    if @family.save then
      flash[:notice] = "Famille créée"
      redirect_to families_path
    else
      render :action => :new
    end
  end

  def edit
    render
  end

  def update
    if @family.update_attributes(params[:family]) then
      flash[:notice] = "Famille mise à jour"
      redirect_to families_path
    else
      render :action => :edit
    end
  end

  def destroy
    @family.destroy
    flash[:notice] = "Famille détruite"
    redirect_to families_path
  end

  protected
  def load_family
    @family = Family.find(params[:id])
  end

  def authorized?
    current_person.admin?
  end

  def access_denied
    render :status => "404 Not Found", :file => File.join(RAILS_ROOT, "public", "404.html")
  end
end

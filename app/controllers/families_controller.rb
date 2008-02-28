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
      flash[:notice] = "Family created"
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
      flash[:notice] = "Family updated"
      redirect_to families_path
    else
      render :action => :edit
    end
  end

  def destroy
    @family.destroy
    flash[:notice] = "Family destroyed"
    redirect_to families_path
  end

  protected
  def load_family
    @family = Family.find(params[:id])
  end
end

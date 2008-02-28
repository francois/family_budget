class TransfersController < ApplicationController
  def index
    @transfers = Transfer.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @transfer = Transfer.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    render
  end

  def create
    respond_to do |format|
      if @transfer.save
        flash[:notice] = 'Transfer was successfully created.'
        format.html { redirect_to(@transfer) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @transfer.update_attributes(params[:transfer])
        flash[:notice] = 'Transfer was successfully updated.'
        format.html { redirect_to(@transfer) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @transfer.destroy

    respond_to do |format|
      format.html { redirect_to(transfers_url) }
    end
  end

  protected
  def load_transfer
    @transfer = Transfer.find(params[:id])
  end
end

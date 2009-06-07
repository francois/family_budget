class ObjectsController < ApplicationController
  def update
    sleep 1.5
    case params[:object][:value]
    when '200s'
      render :json => {:success => true}
    when '200f'
      render :json => {:success => false, :errors => ["Mask is invalid", "Mask should have length greater than 1"]}
    when /^\d+$/
      render :text => "Response code as asked for", :status => params[:object][:value].to_i
    else
      render :text => "Invalid request value", :status => 400
    end
  end
end

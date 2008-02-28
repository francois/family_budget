class SessionsController < ApplicationController
  skip_before_filter :login_required

  def new
    render
  end

  def create
    self.current_person = Person.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1" then
        self.current_person.remember_me
        cookies[:auth_token] = { :value => self.current_person.remember_token , :expires => self.current_person.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      render :action => 'new'
    end
  end

  def update
    self.current_date = Date.parse(params[:session][:current_date])
    respond_to do |format|
      format.html { redirect_to_back_or_default("/") }
      format.js
    end
  end

  def destroy
    self.current_person.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default("/")
  end
end

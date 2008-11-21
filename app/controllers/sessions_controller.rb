class SessionsController < ApplicationController
  skip_before_filter :login_required, :except => %w(destroy)
  ssl_required :new, :create

  def new
    render
  end

  def create
    self.current_person = Person.authenticate(params[:login], params[:password])
    if logged_in? then
      if params[:remember_me] == "1" then
        self.current_person.remember_me
        cookies[:auth_token] = { :value => self.current_person.remember_token , :expires => self.current_person.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:message] = "Vous avez ouvert une session"
    else
      flash.now[:error] = "Soit le nom d'utilisateur ou le mot de passe est incorrect.  Essayez à nouveau."
      render :action => 'new'
    end
  end

  def destroy
    self.current_person.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "Votre session à été détruite"
    redirect_back_or_default("/")
  end
end

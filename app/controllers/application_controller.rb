class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def require_login
    unless logged_in?
    	flash[:warning] = "Please login to continue"
    	session[:return_to] = request.url
    	redirect_to :controller => "users", :action => "login" # halts request cycle
    	# redirect_to '/users/welcome'
    end    
  end

  def current_user
    session[:user]
  end

  def logged_in?
  	!current_user.nil?
  end

  def redirect_to_stored
    if return_to = session[:return_to]
      session[:return_to]=nil
      redirect_to return_to
    else
      redirect_to :controller => "users", :action => "welcome"
    end
  end
end

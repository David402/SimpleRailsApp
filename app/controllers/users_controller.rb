class UsersController < ApplicationController

	before_action :require_login, only: [:welcome, :edit, :forgot_password, :hidden]

	def create
    @user = User.new(user_permit_params)
  end

  private

  def user_permit_params
    params.require(:user).permit(:username, :email, :password)
  end

  # -------------------------------------------------------------
  public
  def signup
  	unless request.post?
  		return;
  	end

		@user = User.new(user_permit_params)

  	# Check if the new user is valid
  	if (@user.save)
  		session[:user] = User.authenticate(@user.username, @user.password)
  		flash[:message] = "Signup successful"
  		# redirect to welcome page
  		redirect_to :action => "welcome"
  	else
  		flash[:warning] = "Signup unsuccessful"
  	end
  end

  def login
  	unless request.post?
  		return
  	end

  	# Check if 'username' and 'password' is correct
  	session[:user] = User.authenticate(params[:user][:username], params[:user][:password])
  	if (session[:user])
  		flash[:message] = "Login successful"
  		redirect_to_stored
  	else
  		flash[:warning] = "Login unsuccessful"
  	end
  end

  def edit
  end

  def forgot_password
  	unless request.post?
  		return
  	end

  	u = User.find_by_email(params[:user][:email])
      if u and u.send_new_password
        flash[:message] = "A new password has been sent by email."
        redirect_to :action=>'login'
      else
        flash[:warning] = "Couldn't send password"
      end
  end

  def change_password
  	@user=session[:user]
    if request.post?
      @user.update_attributes(:password=>params[:user][:password])
      if @user.save
        flash[:message] = "Password Changed"
      end
    end
  end

  def welcome
  end
end

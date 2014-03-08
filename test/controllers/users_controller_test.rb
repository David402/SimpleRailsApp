require 'test_helper'

# Re-raise errors caught by the controller.
# class UsersController
#   def rescue_action(e) 
#     raise e 
#   end
# end

class UsersControllerTest < ActionController::TestCase

  self.use_instantiated_fixtures  = true

  fixtures :users

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
  end



  def test_auth_bob
    #check we can login
    post :login, :user => { :username => "bob", :password => "test" }
    assert_not_nil session[:user]
    assert_equal @bob, session[:user]
    assert_response :redirect
    assert_redirected_to :action=>'welcome'
  end

  def test_signup
    #check we can signup and then login
    post :signup, :user => { :username => "newbob", :password => "newpassword", :email => "newbob@mcbob.com" }
    assert_response :redirect
    assert_not_nil session[:user]
    assert_redirected_to :action=>'welcome'
  end

  def test_bad_signup
    #check we can't signup without all required fields
    post :signup, :user => { :username => "newbob", :password => "newpassword", :email => "newbobgmail.com" }
    assert_response :success
    # assert(record.errors.invalid?("user", "password", "email"))
    # assert_invalid_column_on_record "user", "password", "email"
    assert_template "users/signup"
    assert_nil session[:user]

    post :signup, :user => { :username => "yo", :password => "newpassword", :email => "newbob@mcbob.com"}
    assert_response :success
    # assert_invalid_column_on_record "user", "username"
    assert_template "users/signup"
    assert_nil session[:user]
  end

  def test_invalid_login
    #can't login with incorrect password
    post :login, :user=> { :username => "bob", :password => "not_correct" }
    assert_response :success
    assert_nil session[:user]
    assert flash[:warning]
    assert_template "users/login"
  end

  # def test_login_logoff
  #   login
  #   post :login, :user=>{ :username => "bob", :password => "test"}
  #   assert_response :redirect
  #   assert_not_nil session[:user]
  #   then logoff
  #   get :logout
  #   assert_response :redirect
  #   assert_nil session[:user]
  #   assert_redirected_to :action=>'login'
  # end

  def test_forgot_password
    #we can login
    post :login, :user=>{ :username => "bob", :password => "test"}
    assert_response :redirect
    assert_not_nil session[:user]
    #logout
    # get :logout
    # assert_response :redirect
    # assert_nil session[:user]
    #enter an email that doesn't exist
    post :forgot_password, :user => {:email=>"notauser@doesntexist.com"}
    assert_response :success
    assert_template "users/forgot_password"
    assert flash[:warning]
    #enter bobs email
    post :forgot_password, :user => {:email=>"bob@foo.com"}   
    assert_response :redirect
    assert flash[:message]
    assert_redirected_to :action=>'login'
  end

  def test_login_required
    #can't access welcome if not logged in
    get :welcome
    assert flash[:warning]
    assert_response :redirect
    assert_redirected_to :action=>'login'
    #login
    post :login, :user=>{ :username => "bob", :password => "test"}
    assert_response :redirect
    assert_not_nil session[:user]
    #can access it now
    get :welcome
    assert_response :success
    assert_template "users/welcome"
  end

  def test_change_password
    #can login
    post :login, :user=>{ :username => "bob", :password => "test"}
    assert_response :redirect
    assert_not_nil session[:user]
    #try to change password
    #empty password
    post :change_password, :user=>{ :password => ""}
    assert_response :success
    # TODO: how to verify user's password changed failure
    # assert_invalid_column_on_record "user", "password"
    #success - password changed
    post :change_password, :user=>{ :password => "newpass"}
    assert_response :success
    assert flash[:message]
    assert_template "users/change_password"
    #logout
    # get :logout
    # assert_response :redirect
    # assert_not_nil session[:user]
    #old password no longer works
    post :login, :user=> { :username => "bob", :password => "test" }
    assert_response :success
    assert_nil session[:user]
    assert flash[:warning]
    assert_template "users/login"
    #new password works
    post :login, :user=>{ :username => "bob", :password => "newpass"}
    assert_response :redirect
    assert_not_nil session[:user]
  end

  def test_return_to
    #cant access hidden without being logged in
    get :hidden
    assert flash[:warning]
    assert_response :redirect
    assert_redirected_to :action=>'login'
    assert_not_nil session[:return_to]
    #login
    post :login, :user=>{ :username => "bob", :password => "test"}
    assert_response :redirect
    #redirected to hidden instead of default welcome
    # assert_redirected_to "users/hidden"
    # assert_nil session[:return_to]
    # assert_not_nil session[:user]
    # assert flash[:message]
    #logout and login again
    # get :logout
    # assert_nil session[:user]
    # post :login, :user=>{ :username => "bob", :password => "test"}
    # assert_response :redirect
    #this time we were redirected to welcome
    # assert_redirected_to :action=>'welcome'
  end
end

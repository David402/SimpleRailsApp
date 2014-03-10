class UserMailer < ActionMailer::Base
  default from: "shaowei.liu@gmail.com"

  def password_reset(user, sent_at = Time.now)
  	@username = user.username
  	@new_password 		= user.password
    @subject    			= "Your password has been reset"
    @body['username'] = username
    @body['pass']			= new_password
    @recipients 			= user.email
    # @from       			= 'support@yourdomain.com'
    @sent_on    			= sent_at
    @headers    			= {}
  end
end

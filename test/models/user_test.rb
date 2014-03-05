require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  self.use_instantiated_fixtures = true
  fixtures :users

  def test_auth
  	# check that we can username we a valid user 
    assert_equal  @bob, User.authenticate("bob", "test")
    #wrong username
    assert_nil    User.authenticate("nonbob", "test")
    #wrong password
    assert_nil    User.authenticate("bob", "wrongpass")
    #wrong username and pass
    assert_nil    User.authenticate("nonbob", "wrongpass")
  end

	def test_passwordchange
    # check success
    assert_equal @longbob, User.authenticate("longbob", "longtest")
    #change password
    @longbob.password = "nonbobpasswd"
    assert @longbob.save
    #new password works
    assert_equal @longbob, User.authenticate("longbob", "nonbobpasswd")
    #old pasword doesn't work anymore
    assert_nil   User.authenticate("longbob", "longtest")
    #change back again
    @longbob.password = "longtest"
    assert @longbob.save
    assert_equal @longbob, User.authenticate("longbob", "longtest")
    assert_nil   User.authenticate("longbob", "nonbobpasswd")
  end

  def test_disallowed_passwords
    #check thaat we can't create a user with any of the disallowed paswords
    u = User.new    
    u.username = "nonbob"
    u.email = "nonbob@gmail.com"
    #too short
    u.password = "tiny" 
    assert !u.save     
    assert u.invalid?
    #too long
    u.password = "hugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge"
    assert !u.save     
    assert u.invalid?
    #empty
    u.password = ""
    assert !u.save    
    assert u.invalid?
    #ok
    u.password = "bobs_secure_password"
    assert u.save     
    assert u.errors.empty? 
    assert u.valid?
  end

  def test_bad_usernames
    #check we cant create a user with an invalid username
    u = User.new  
    u.password = "bobs_secure_password"
    u.email = "okbob@gmail.com"
    #too short
    u.username = "x"
    assert !u.save     
    assert u.invalid?
    #too long
    u.username = "hugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhug"
    assert !u.save     
    assert u.invalid?
    #empty
    u.username = ""
    assert !u.save
    assert u.invalid?
    #ok
    u.username = "okbob"
    assert u.save  
    assert u.valid?
    #no email
    u.email=nil   
    assert !u.save     
    assert u.invalid?
    #invalid email
    u.email='notavalidemail'   
    assert !u.save     
    assert u.invalid?
    #ok
    u.email="validbob@gmail.com"
    assert u.save  
    assert u.valid?
  end


  def test_collision
    #check can't create new user with existing username
    u = User.new
    u.username = "alice"
    u.password = "bobs_secure_password"
    assert !u.save
    assert u.invalid?
  end


  def test_create
    #check create works and we can authenticate after creation
    u = User.new
    u.username = "nonexistingbob"
    u.password = "bobs_secure_password"
    u.email    = "nonexistingbob@gmail.com"  
    assert_not_nil u.salt
    assert u.save
    assert_equal 10, u.salt.length
    assert_equal u, User.authenticate(u.username, u.password)

    u = User.new(:username => "newbob", :password => "newpassword", :email => "newbob@gmail.com" )
    assert_not_nil u.salt
    assert_not_nil u.password
    assert_not_nil u.hashed_password
    assert u.save 
    assert_equal u, User.authenticate(u.username, u.password)

  end

  def test_send_new_password
    #check user authenticates
    assert_equal  @bob, User.authenticate("bob", "test")    

    #send new password
    sent = @bob.send_new_password
    assert_not_nil sent

    #old password no longer workd
    assert_nil User.authenticate("bob", "test")

    # TODO: Notification email is not supported now, need to
    # add later.
    
    #email sent...
    # assert_equal "Your password is ...", sent.subject

    #... to bob
    # assert_equal @bob.email, sent.to[0]
    # assert_match Regexp.new("Your username is bob."), sent.body

    #can authenticate with the new password
    # new_pass = $1 if Regexp.new("Your new password is (\\w+).") =~ sent.body 
    # assert_not_nil new_pass
    # assert_equal  @bob, User.authenticate("bob", new_pass)    
  end

  def test_rand_str
    new_pass = User.random_string(10)
    assert_not_nil new_pass
    assert_equal 10, new_pass.length
  end

  def test_sha1
    u=User.new
    u.username = "nonexistingbob"
    u.email = "nonexistingbob@gmail.com"  
    u.salt = "1000"
    u.password = "bobs_secure_password"
    assert u.save   
    assert_equal 'b1d27036d59f9499d403f90e0bcf43281adaa844', u.hashed_password
    assert_equal 'b1d27036d59f9499d403f90e0bcf43281adaa844', User.encrypt("bobs_secure_password", "1000")
  end

  # def test_protected_attributes
  #   #check attributes are protected
  #   u = User.new(:id=>999999, :salt=>"I-want-to-set-my-salt", :username => "badbob", :password => "newpassword", :email => "badbob@gmail.com" )
  #   assert u.save
  #   assert_not_equal 999999, u.id
  #   assert_not_equal "I-want-to-set-my-salt", u.salt

  #   u.update_attributes(:id=>999999, :salt=>"I-want-to-set-my-salt", :username => "verybadbob")
  #   assert u.save
  #   assert_not_equal 999999, u.id
  #   assert_not_equal "I-want-to-set-my-salt", u.salt
  #   assert_equal "verybadbob", u.username
  # end
end
require 'digest/sha1'

class User < ActiveRecord::Base
	validates :username, length: { within: 3..40 }
	validates :password, length: { within: 6..40 }
	validates :username, :email, :password, :salt, presence: true
	validates :username, :email, uniqueness: true
	validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/, message: "Invalid email" }


	# -----------------------------------------------
	# Attributes

	# This makes sure that users can’t set them by sending 
	# a post request - you have to update them in the model. 
	# For example if you extended this model to include a 
	# roles field that specified if a user was an admin or 
	# normal user it would be important to specify that 
	# field as protected. Any field that you don’t want 
	# to be updatable from your web forms should be protected.

	# TODO: change to "strong_parameters"
	# attr_protected :id, :salt
	
	# Non-persisted temporary instance variables
	attr_accessor :password

	# -----------------------------------------------
	# Accessors

	def password= pass
		@password=pass
		puts "pass #{pass}"
		self.salt = User.random_string(10) if !self.salt?
		puts "salt #{self.salt}"
		self.hashed_password = User.encrypt(@password, self.salt)
	end
	
	# -----------------------------------------------
	# Public interface
	public
	def send_new_password
		new_pass = User.random_string(10)
		self.password = new_pass

		# Save user model with new password into DB
		self.save

		UserMailer.password_reset(self)
	end
	def self.authenticate(username, pass)
		u = find{ |u| u.username == username }
		return nil if u.nil?
		return u if User.encrypt(pass, u.salt) == u.hashed_password
		nil
	end

	# ----------------------------------
	# Protected method
	protected
	def self.random_string length
		#generate a random password consisting of strings and digits
   	chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
   	newpass = ""
   	1.upto(length) { |i| newpass << chars[rand(chars.size-1)] }
   	return newpass
	end

	def self.encrypt(pass, salt)
		Digest::SHA1.hexdigest(pass+salt)
	end
	
end

module SimpleApi
class SinatraApp < Sinatra::Base
	post '/users/signup' do
		puts "params #{params}"
		puts "username #{params["username"]}"
		puts "password #{params["password"]}"
		u = User.new
		u.username = params["username"]
		puts u
		u.password = params["password"]
		u.email    = params[:email]

		u.save
		user = User.authenticate(u.username, u.password)
		puts "user: #{user}"
		if user
			json("status: ok")
		else
			error_json("Invalid username or password.")
		end
		
	end

	post '/users/login' do
		puts "params #{params}"
		u = User.authenticate(params[:username], params[:password])
		if u
			json("status: ok") 
		else
			error_json("Incorrect username or password.")
		end
		
	end
end
end
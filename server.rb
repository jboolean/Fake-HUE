require 'sinatra'
require 'json'
require_relative 'errors'

set :public_folder, 'public'
set :static, true

helpers do
	def protect!
		authorized_users = ["julianboilen"]
		if !authorized_users.include? params[:username]
			halt [(UnauthorizedUser.new).to_hash("")].to_json
			#TODO: Get the address being called somehow
		end
	end
	def getName(id)
		settings.to[id].puts ({"command" => "name"}.to_json)
		settings.to[id].flush

		JSON.parse(settings.from[1].gets)["name"]
	end

end
configure do
	set :to, Hash.new
	set :from, Hash.new

	settings.to[1] =	open("pipes/1-to", "w+")
	settings.from[1]=	open("pipes/1-from", "r+")
end
#GETTING STARTED
###################
post '/api' do
	#TODO add users if link button is pressed
end

#LIGHTS API
##################

#1.1 Get All Lights
get '/api/:username/lights' do
	protect!

	output = Hash.new
	settings.from.each_key { |k| output[k.to_s] = {"name" => getName(k)} }
	output.to_json
end

get '/api/:username/lights/:id' do
	protect!
	getName(params[:id].to_i).to_json
end

#1.2 get now light
#sim: just say no scan
get '/api/:username/lights/new' do
	{"lastscan" => "none"}.to_json
end


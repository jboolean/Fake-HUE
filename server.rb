require 'sinatra'
require 'json'
require 'securerandom'
require_relative 'errors'
require_relative 'config'

set :public_folder, 'public'
set :static, true

helpers do
	def protect!
		if !settings.bridge_config.authorized? params[:username]
			halt [(UnauthorizedUser.new).to_hash("")].to_json
			#TODO: Get the address being called somehow
		end
	end
	def noLightError
		id = params[:id].to_i
		unless settings.to.has_key?(id) then
			halt [ResourceNotAvailable.new("/lights/#{id}").to_hash].to_json
		end
	end
	def getName(id)
		settings.to[id].puts ({"command" => "name"}.to_json)
		settings.to[id].flush

		JSON.parse(settings.from[id].gets)["name"]
	end
	def getAll(id)
		settings.to[id].puts ({"command" => "all"}.to_json)
		settings.to[id].flush

		JSON.parse(settings.from[id].gets)["all"]
	end
	def rename(id, name)
		settings.to[id].puts ({"command" => "put", "name" => name}.to_json)
		settings.to[id].flush

		JSON.parse(settings.from[id].gets)["put"]
	end
		

end
configure do
	set :environment, :production
	set :port, 80
	set :to, Hash.new
	set :from, Hash.new
	set :bridge_config, BridgeConfig.new

	settings.to[1] =	open("pipes/1-to", "w+")
	settings.from[1]=	open("pipes/1-from", "r+")
	settings.bridge_config.add_user("julianboilen", "developer")
end
#ERRORS, ETC.
##############
not_found do
	url = request.path_info
	status 200#odd they do this, but they do
	#not exactly the correct url, close enough
	puts "ERROR: No page at #{url} using #{request.request_method}"
	[ResourceNotAvailable.new(url).to_hash].to_json
end
before do
	url = request.path_info
	puts "ACCESSING: #{url}"
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

#1.2 get now light
#sim: just say no scan
get '/api/:username/lights/new' do
	protect!
	{"lastscan" => "none"}.to_json
end

#1.4 Get light attributes and state
get '/api/:username/lights/:id' do
	protect!
	noLightError()
	getAll(params[:id].to_i).to_json
end

#1.3 search for lights
#sim: not important

#1.5 Set light attributes (rename)
put '/api/:username/lights/:id' do
	protect!
	noLightError
	data = request.body.read
	data = JSON.parse(data)
	rename(params[:id].to_i, data["name"]).to_json
end

#1.6 Set light state
put '/api/:username/lights/:id/state' do
	protect!
	noLightError
	data = JSON.parse(request.body.read)
	id = params[:id].to_i
	settings.to[id].puts ({"command" => "put state", "state" => data}.to_json)
	settings.to[id].flush

	JSON.parse(settings.from[id].gets)["put state"].to_json
end

#CONFIGURATON
#############

#4.1 Create user
post '/api' do
	puts "hiiiiui"
	data = JSON.parse(request.body.read)
	unless data.has_key?("username")
		data["username"] = SecureRandom.uuid
	end
	settings.bridge_config.add_user(data["username"], data["devicetype"])
	["success" => data].to_json
end

get '/api/nupnp' do
	[
	    {
		"id"=>"001788fffe0923cb",
		"internalipaddress"=>"192.168.1.3",
		"macaddress"=>"00:17:88:09:23:cb"
	    }
	].to_json
end
#4.5 Get full state
get '/api/:username' do
	protect!
	response = Hash.new
	lights = Hash.new
	settings.to.each_key do |k|
		lights[k] = getAll(k)
	end
	response["lights"] = lights
	response["groups"] = Hash.new
	response["config"] = settings.bridge_config.to_hash
	response["schedules"] = Hash.new
	response.to_json
end
		


require 'sinatra'
require 'json'
require 'securerandom'
require_relative 'errors'
require_relative 'config'
require './LightHardwareController'
require './light'
require './light_commander'
require 'socket'
require 'ipaddr'

Thread.new do
#sspd advertiser
MULTICAST_ADDR = "239.255.255.250"
BIND_ADDR = "0.0.0.0"
PORT = 1900
socket = UDPSocket.new

membership = IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new(BIND_ADDR).hton

socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership)
socket.setsockopt(:SOL_SOCKET, :SO_REUSEPORT, 1)

socket.bind(BIND_ADDR, PORT)

loop do
	puts "ready to recieve"
  message, _ = socket.recvfrom(255)
  puts message
end
end
helpers do
	def protect!
		if !settings.bridge_config.authorized? params[:username]
			halt [(UnauthorizedUser.new).to_hash("")].to_json
			#TODO: Get the address being called somehow
		end
	end
	def noLightError
		id = params[:id].to_i
		if settings.commanders[id].nil?
			halt [ResourceNotAvailable.new("/lights/#{id}").to_hash].to_json
		end
	end
	def rename(id, name)
		settings.commanders[id].light.name = name

		[{"success" => {"/lights/#{id}/name" => name}}]
	end
		

end
configure do
	set :public_folder, 'public'
	set :static, true
	if settings.production?
		set :port, 80
		set :bridge_config, BridgeConfig.new
	end

	set :bridge_config, BridgeConfig.new

	#create commander objects which are used to control the lights at a high level
	hardware = LightHardwareController.new
	set :commanders, Array.new
	(0..3).each do |lampNo|
		light = Light.new(lampNo, "Light #{lampNo}")
		settings.commanders << LightCommander.new(light, hardware)
	end

	settings.bridge_config.add_user("julianboilen", "developer")
	settings.bridge_config.add_user("50a21116-a531-49bf-8aae-5b1cd52a8988", "Ambify")
	settings.bridge_config.add_user("7BCC76B50E9E00F1CD6D420031CAFE02", "HueDisco")
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
	puts "URL: #{url}\nBODY: #{request.body.read}\n"
	request.body.rewind
end



#LIGHTS API
##################

#1.1 Get All Lights
get '/api/:username/lights/?' do
	protect!

	output = Hash.new
	settings.commanders.each_index do |i|
		output[i.to_s] = {"name" => settings.commanders[i].light.name}
	end
	output.to_json
end

#1.2 get new light
#sim: just say no scan
get '/api/:username/lights/new/?' do
	protect!
	{"lastscan" => "none"}.to_json
end

#1.4 Get light attributes and state
get '/api/:username/lights/:id/?' do
	protect!
	noLightError()
	settings.commanders[params[:id].to_i].light.to_hash.to_json
end

#1.3 search for lights
#sim: not important

#1.5 Set light attributes (rename)
put '/api/:username/lights/:id/?' do
	protect!
	noLightError
	data = request.body.read
	data = JSON.parse(data)
	rename(params[:id].to_i, data["name"]).to_json
end

#1.6 Set light state
put '/api/:username/lights/:id/state/?' do
	protect!
	noLightError
	data = JSON.parse(request.body.read)
	id = params[:id].to_i
	result = settings.commanders[id].updateState(data)

	result.to_json
end

#CONFIGURATON
#############

#4.1 Create user
post '/api/?' do
	data = JSON.parse(request.body.read)
	unless data.has_key?("username")
		data["username"] = SecureRandom.uuid
	end
	settings.bridge_config.add_user(data["username"], data["devicetype"])
	#[{"success"=>{"username"=> data["username"]}}].to_json
	"[{\"success\":{\"username\": \"#{data["username"]}\"}}]"
end

get '/api/nupnp/?' do
	[
	    {
		"id"=>"001788fffe0923cb",
		"internalipaddress"=>"129.21.135.16",
		"macaddress"=>"e0:f8:47:0c:77:8c"
	    }
	].to_json
end
#4.5 Get full state
get '/api/:username/?' do
	protect!
	response = Hash.new
	lights = Hash.new
	settings.commanders.each_index do |k|
		lights[k.to_s] = settings.commanders[k].light.to_hash
	end
	response["lights"] = lights
	response["groups"] = Hash.new
	response["config"] = settings.bridge_config.to_hash
	response["schedules"] = Hash.new
	response.to_json
end
		


require_relative 'light'
require 'json'


class LightProcess
	def initialize(light)
		@light = light
	end

	#begin listening and reponding to commands on the pipes
	def listen
		#assumes there are pipes labed with its ID and -to and -from where -to is incoming
		input = open("pipes/#{@light.id}-to", "r+")
		output = open("pipes/#{@light.id}-from", "w+")
		#Takes the hash {"command" => command} and returns {command => result} encoded in json both ways
		#commands are "all" and "name" right now
		while true do 
			line = input.gets
			hash = JSON.parse(line)
			command = hash["command"]
			puts "COMMAND: #{command}"
			case command
			#just get the name
			when "name"
				output.puts ({"name" => @light.name}.to_json)
			#get all info, including state, per the api
			when "all"
				output.puts ({"all" => @light.to_hash}.to_json)
			when "exit"
				break
			#set state - takes a "state" key to a hash of new values
			when "put state"
				result = updateState(hash["state"])
				output.puts ({"put state" => result}.to_json)
			#set attributes (rename) 
			#takes a "name" key to a new name
			when "put"
				output.puts({"put" => updateName(hash["name"])}.to_json)
			else
				puts "ERROR: Invalid command:\n#{command}"
				#TODO this will crash the program, handle nicely??
			end
			output.flush
		end
	end


	#WHERE THE BUSINESS HAPPENS
	#takes a hash of new state attributes and applies them
	#returns a list of hashes with the key "success" with value as a hash of the url to the parameter and the value of the parameter 
	#alternatively, the key can be error and the value a hash with keys type (error code), address, and description (hr text)
	def updateState (new_state_elements)
		output = Array.new
		new_state_elements.each do |k,v|
			#success message
			output << {"success" =>
					{"/lights/#{@light.id}/state/#{k}" => v}
				}
			#actually change the state
			@light.state.send("#{k}=",v)
			#TODO catch exceptions on setting and return errors
		end
		return output
	end
	
	#changes the name and return a success message per the api
	def updateName(newName)
		@light.name=newName
		[{"success" => 
			{"lights/#{@light.id}/name" => newName}
		}]
	end
end #class
#start with ID and Name
light = Light.new(ARGV[0].to_i, ARGV[1])
process = LightProcess.new(light)
process.listen

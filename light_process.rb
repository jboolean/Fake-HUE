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
			when "name"
				output.puts ({"name" => @light.name}.to_json)
			when "all"
				output.puts ({"all" => @light.to_hash}.to_json)
			when "exit"
				break
			when "put state"
				result = updateState(hash["state"])
				output.puts ({"put state" => result}.to_json)
			else
				puts "ERROR: Invalid command:\n#{command}"
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
			output << {"success" =>
					{"/lights/#{@light.id}/state/#{k}" => v}
				}
		end
		return output
	end
end #class
#start with ID and Name
light = Light.new(ARGV[0].to_i, ARGV[1])
process = LightProcess.new(light)
process.listen

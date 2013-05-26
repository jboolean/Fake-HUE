require_relative 'light'
require 'json'

#start with ID and Name
light = Light.new(ARGV[0].to_i, ARGV[1])

#assumes there are pipes labed with its ID and -to and -from where -to is incoming
input = open("pipes/#{light.id}-to", "r+")
output = open("pipes/#{light.id}-from", "w+")
#Takes the hash {"command" => command} and returns {command => result} encoded in json both ways
#commands are "all" and "name" right now
while true do 
	line = input.gets
	command = JSON.parse(line)["command"]
	puts "COMMAND: #{command}"
	case command
	when "name"
		output.puts ({"name" => light.name}.to_json)
	when "all"
		output.puts ({"all" => light.to_hash}.to_json)
	when "exit"
		break
	else
		puts "ERROR: Invalid command:\n#{command}"
	end
	output.flush
end


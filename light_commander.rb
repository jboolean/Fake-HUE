require './state'
require './light'
require './color_converters'
class LightCommander
	include ColorConverters

	attr_reader :state
	attr_reader :light

	#a light object and the common hardware driver
	def initialize(light, hardware)
		@light = light
		#contains the state, name, etc
		@hardware = hardware
	end

	#takes a hash of new state attributes and applies them
	#returns a list of hashes with the key "success" with value as a hash of the url to the parameter and the value of the parameter 
	#alternatively, the key can be error and the value a hash with keys type (error code), address, and description (hr text)

	def updateState (new_state_elements)
		output = Array.new
		#do on first, or lots of things will complain the device is off
		if new_state_elements.has_key?("on")
			@light.state.on = new_state_elements["on"]
			new_state_elements.delete("on")
		end
		new_state_elements.each do |k,v|
			address = "/lights/#{@light.id}/state/#{k}" 
			begin
			@light.state.send("#{k}=",v)
			#success message
			output << {"success" =>
					{address => v}
				}
			rescue HueError => error
			output << error.to_hash(address)
			end
		end
		#puts output.inspect
		updateHardware
		return output
	end

	#changes the name and return a success message per the api
	def updateName(newName)
		@light.name=newName
		[{"success" => 
			{"lights/#{@light.id}/name" => newName}
		}]
	end

	private

	#send the current state to the hardware
	def updateHardware
		if @light.state.on == false
			vals = [0,0,0]
		else
			case @light.state.colormode
			when :hs
				vals = hsbToRgb(@light.state.hue/65535.0, @light.state.sat/255.0, @light.state.bri/255.0)
			when :ct
				vals = ctToRgb(@light.state.ct)
			else
				puts "Mode #{@light.state.colormode} not implemented"
			end
		end
		@hardware.sendColor(@light.id,@light.state.transitiontime, *vals)
	end
end

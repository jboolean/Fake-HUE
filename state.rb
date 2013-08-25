require_relative 'errors'
class State
	attr_accessor :on #Boolean
	attr_reader :colormode #:xy :ct or :hs
	attr_reader :hue #:Integer 0..65535
	attr_reader :sat #Integer 0..255
	attr_reader :bri #Integer 0..255
	attr_reader :xy #[x,y] x,y in 0..1
	attr_reader :ct #Integer, bulb-dependent. about 153..500 for philips
	attr_reader :alert #:none, :select, or :lselect
	attr_accessor :effect # :none or :colorloop
	attr_accessor :reachable #Boolean, always true
	attr_accessor :transitiontime #int, multiple of 100, in ms
	def initialize
		@on = false
		@colormode = :hs
		@hue = 0
		@sat = 255
		@xy = [0.675,0.322]
		@ct = 500
		@alert = :none
		@effect = :none
		@reachable = true
		@bri = 255
		@transitiontime = 4
	end
	def to_hash
		{
			"hue" =>	@hue,
			"on" =>	@on,
			"effect" => @effect.to_s,
			"alert" =>	@alert.to_s,
			"bri" =>	@bri,
			"sat" => 	@sat,
			"ct" => 	@ct,
			"xy" =>	@xy,
			"reachable" => @reachable,
			"colormode" => @colormode.to_s
		}
	end
	def alert=(value)
		newAlert = value.to_sym
		if [:none, :select, :lselect].include?(newAlert)
			@alert=newAlert
		else
			err = InvalidValue.new("alert", value)
			raise err
		end
	end
	def hue=(value)
		if !@on then raise DeviceOff.new("hue") end
		if (0..65535) === value
			@hue = value
			@colormode = :hs
		else
			raise InvalidValue.new("hue", value)
		end
	end
	def sat=(value)
		if !@on then raise DeviceOff.new("sat") end
		if (0..255) === value
			@sat = value
			@colormode = :hs
		else
			raise InvalidValue.new("sat", value)
		end
	end
	def xy=(value)
		if !@on then raise DeviceOff.new("xy") end
		if value.length==2 && (0..1) === value[0] && (0..1) === value[1]
			@xy = xy
			@colormode = :xy
		else	
			raise InvalidValue.new("xy", value)
		end
	end
	def ct=(value)
		if !@on then raise DeviceOff.new("ct") end
		@ct = value
		if value.integer?
			@ct = value
			@colormode = :ct
		else
			raise InvalidValue.new("ct", value)
		end
	end
	def bri=(value)
		if !@on then raise DeviceOff.new("bri") end
		puts @on
		if (0..255) === value
			@bri = value
		else
			raise InvalidValue.new("bri", value)
		end
	end


end

class HueError < StandardError
#if we had abstract classes
#should define a type method and a description method
	attr_reader :type
	def initialize (type, message)
		super(message)
		@type = type
	end
	def description 
		message
	end
	def to_hash(address)
		{ "error" => {
			"type" => type,
			"address" => address,
			"description" => description
		}
		}
	end

end

class NoSuchParameter < HueError
	def initialize(param_name)
		super(6, "parameter, #{param_name}, not available")
	end
end

class InvalidValue < HueError
	def initialize(param_name, value)
		super(7, "invalid value, #{value}, for parameter, #{param_name}")
	end
end

class InvalidJson < HueError
	def initialize
		super(2, "body contains invalid json")
	end
end

class UnauthorizedUser < HueError
	def initialize
		super(1, "unauthorized user")
	end
end


#contains a light's basic state info used in the api.
require_relative 'state'
class Light
	attr_reader	:id #Integer, unique
	attr_accessor	:state #State, not sure if final or updates live
	attr_accessor	:name #String, 0..32, unique
	attr_accessor	:modelid #String 6..6
	attr_accessor	:swversion #String 8..8
	attr_accessor	:pointsymbol #PointSymbol
	attr_reader	:type
	def initialize(_id, _name)
		@id = _id
		@name = _name
		@state = State.new
		#Values are from my Hue
		@modelid = 'LCT001' #TODO: What should this be?
		@swversion = '65003148' #TODO: What should THIS be?
		@type = "Simulated"
		@pointsymbol = PointSymbol.new
	end

	#create a hash in the form of the API. Ready for to_json
	def to_hash
		{
			"state" => @state.to_hash,
			"type" => 	@type,
			"name" =>	@name,
			"modelid" =>	@modelid,
			"swversion" =>	@swversion,
			#"pointsymbol"=> @pointsymbol.to_hash
		}
	end

end

class PointSymbol
#TODO define to_hash for json
#a hash of numbers mapped to "none" in the API docs
	def to_hash
		hash = Hash.new
		hash.default = "none"
		hash
	end
end

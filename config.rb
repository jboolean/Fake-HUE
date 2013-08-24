require_relative 'errors'
class BridgeConfig
	attr_accessor :name
	#mac
	#dhcp
	#ip
	#netmask
	#gateway
	#proxy
	#proxyport
	attr_accessor :utc
	attr_accessor :whitelist
	attr_accessor :swversion
	#swupdate
	#linkbutton
	#portalservices

	def initialize
		@name = "Fake hue"
		@UTC = "2012-10-29T12:00:00"
		@whitelist = Hash.new
		@swversion = "01003372"
		@linkbutton = true;
	end
	def linkbutton
		@linkbutton
	end
	def to_hash
		{
			"name" => @name,
			"mac" => "e0:f8:47:0c:77:8c", #TODO: get real addr
			"dhcp" => true,
			"ipaddress" => "192.168.1.3", #TODO: real ip
			"netmask" => "255.255.255.0",
			"gateway" => "192.168.1.1",
			"proxyaddress" => "",
			"proxyport" => 0,
			"UTC" => @utc,
			"whitelist" => @whitelist,
			"swversion" => @swversion,
			"swupdate" => {"updatestate" => 0, "url" => "", "text" => "", "notify" => false},
			"linkbutton" => linkbutton,
			"portalservices" => false
		}
	end
	def add_user(username, device_type)
		#todo button not pressed
		@whitelist[username] = {"create date" => DateTime.now.strftime("%FT%R"), "name" => device_type}
	end
	def authorized?(username)
		@whitelist.has_key?(username)
	end
end


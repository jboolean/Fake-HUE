require 'rubygems'
require 'datamapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db.db")

class Light
	include DataMapper::Resource

	property :id,	Serial
	has 1, :state
	property :type,	String, :required => true
	property :name, String, :length => 0..32, :unique => true
	property :modelid,	String, :length => 6..6
	property :swversion	String, :length => 8..8
	has 1,	:pointsymbol

end
class State
	include DataMapper::Resource

	property :id, 	Serial

	belongs_to	:light
	property :on, 	Boolean, :required => true
	property :colormode, Enum[:xy, :ct, :hs], :required => true

	property :hue,	Integer
	validates_within :hue,	:set => 0..65535

	property :sat,	Integer
	validates_within :sat,	:set => 0..255

	property :xy, Array
	# TODO: validate length

	property :ct, Integer
	#validation depends on bulb, philips 2012 des 153..500

	property :alert,	Enum[:none, :select, :lselect]
	property :effect,	Enum[:none, :colorloop]
	
	property :reachable, Boolean, :required => true, :default => true

	validates_presense_of :hue,	:if => lambda { |t| t.colormode == :hs}
	validates_presense_of :sat,	:if => lambda { |t| t.colormode == :hs}
	validates_presense_of :ct,	:if => lambda { |t| t.colormode == :ct}
	validates_presense_of :xy,	:if => lambda { |t| t.colormode == :xy}
end
class PointSymbol
	include DataMapper::Resource
	property :id, Serial
	belongs_to	:light
	#for future use
end


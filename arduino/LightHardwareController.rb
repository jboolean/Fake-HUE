#simplest ruby program to read from arduino serial, 
#using the SerialPort gem
#(http://rubygems.org/gems/serialport)

require 'rubygems'
require "serialport"
class LightHardwareController
	#params for serial port
	def initialize(port_str = "/dev/tty.usbmodem12341")  #may be different for you
		baud_rate = 9600
		data_bits = 8
		stop_bits = 1
		parity = SerialPort::NONE

		@sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
	end

	#Send a color. RGB in 0-4095
	def sendColor(r,g,b)
		vals = [r,g,b]
		#header
		2.times{sp.putc(255)}
		#send data
		vals.each do |n|
			@sp.putc(n >> 8)
			@sp.putc(n)
		end
	end

	def close
		@sp.close
	end

	attr_reader :sp
end

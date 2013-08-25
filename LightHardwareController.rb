#simplest ruby program to read from arduino serial, 
#using the SerialPort gem
#(http://rubygems.org/gems/serialport)

require 'rubygems'
require "serialport"
require 'thread'

class LightHardwareController
	#params for serial port
	def initialize(port_str = "/dev/tty.usbmodem12341")  #may be different for you
		baud_rate = 9600
		data_bits = 8
		stop_bits = 1
		parity = SerialPort::NONE

		@sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)

		#prevent packets from being sent at the same time
		@semaphore = Mutex.new
	end

	#Send a color. RGB in 0..1
	#time in multiple of 100ms
	def sendColor(lamp, time, r,g,b)
		@semaphore.synchronize do
		vals = [r,g,b]
		vals.map!{|val|(val*4095).floor}
		puts vals.inspect
		#header
		2.times{sp.putc(255)}
		#send data
		@sp.putc(lamp)
		@sp.putc(time)
		vals.each do |n|
			@sp.putc(n >> 8)
			@sp.putc(n)
		end
		end
	end

	def close
		@sp.close
	end

	attr_reader :sp
end

require './LightHardwareController'

hardware =  LightHardwareController.new
(0..3).each do |lamp|
	(0..2).each do |n|
		vals = [0,0,0]
		vals[n] = 1;
		#3.times {vals << rand(4095)}
		puts vals.inspect
		hardware.sendColor(lamp,4, *vals)
		sleep(0.5)
	end
	hardware.sendColor(lamp, 4, 0,0,0)
end
hardware.close
#while true do
#   while (i = hardware.sp.gets.chomp) do       # see note 2
#	puts i
#	#puts i.class #String
#   end
#end


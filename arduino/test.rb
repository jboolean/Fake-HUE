require './LightHardwareController'

hardware =  LightHardwareController.new

(0..2).each do |n|
	vals = [0,0,0]
	vals[n] = 4095;
	#3.times {vals << rand(4095)}
	puts vals.inspect
	hardware.sendColor(*vals)
	sleep(1)
end
hardware.sendColor(0,0,0)
#while true do
#   while (i = hardware.sp.gets.chomp) do       # see note 2
#	puts i
#	#puts i.class #String
#   end
#end


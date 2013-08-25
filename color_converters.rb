module ColorConverters
	#get an array[3] of red, green and blue
	#all values 0..1
	def hsbToRgb(hue,sat,val)
	#from http://stackoverflow.com/questions/4123998/algorithm-to-switch-between-rgb-and-hsb-color-values
		hue *= 360
		if sat == 0
			r,g,b = val, val, val
		else
			sectorPos = hue / 60.0
			sectorNumber =sectorPos.floor
			
			fractionalSector = sectorPos - sectorNumber

			p,q,t= val * (1 - sat), val * (1 -( sat * fractionalSector)), val * (1 - (sat * (1 - fractionalSector)))

			case sectorNumber
			when 0,6
				r,g,b = val, t, p
			when 1
				r,g,b = q, val, p
			when 2
				r,g,b = p, val, t
			when 3
				r,g,b = p, q, val
			when 4
				r,g,b = t, p, val
			when 5
				r,g,b = val, p, q
			end
		end
		[r,g,b]
	end
	#all values are 0..1
	def xyToRgb(x, y, bri)


		#too much multivariable calcules for right now!
		#this doesn't work
		z = 1.0 - x - y
		y2 = bri
		x2 = (y2 / y) * x
		z2 = (y2 / y) * z

		r = x2 * 3.2410 - y2 * 1.5474 - z2 * 0.4986
		g = -x2 * 0.9692 + y2 * 1.8760 + z2 * 0.0416
		b = x2 * 0.0556 - y2 * 0.2040 + z2 * 1.0570
		[r,g,b].map! {|c|

			c <= 0.0031308 ? 12.92 * c : (1.0 + 0.055) * (c ** (1.0 / 2.4)) - 0.055
		}	
	end
	#color in reciprocal megakelvin
	#from http://www.tannerhelland.com/4435/convert-temperature-rgb-algorithm-code/
	def ctToRgb(rmk)
		temperature = 1000000/rmk
		puts "#{temperature}K\n"
		temperature /= 100

		#red
		if temperature <= 66
			red = 255
		else
			red = temperature - 60
			red = 329.698727446 * (red ** -0.1332047592)
			if red < 0 then red = 0 end
			if red > 255 then red = 255 end
		end

		#green
		if temperature <= 66
			green = temperature
			green = green = 99.4708025861 * Math.log(green) - 161.1195681661
		else
			green = temperature - 60
			green = 288.1221695283 * (green ** -0.0755148492)
		end
		if green < 0 then green = 0 end
		if green > 255 then green = 255 end

		#blue
		if temperature >= 66
			blue = 255
		else
			if temperature <= 19
				blue = 0
			else
				blue = temperature - 10
				blue = 138.5177312231 * Math.log(blue) - 305.0447927307
				if blue < 0 then blue = 0 end
				if blue > 255 then blue = 255 end
			end
		end
		[red, green, blue].map!{|color| color/255}
	end
end

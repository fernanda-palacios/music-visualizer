#generate the x and y coord for 5 rings with 16 lines each
# ouput is of the form:
# ring0_line0_x_start
# ring0_line0_y_start
# ring0_line0_x_end
# ring0_line0_y_end
# ...
# ring0_line15_x_start
# ring0_line15_y_start
# ring0_line15_x_end
# ring0_line15_y_end
# NEWLINE
# ...
# ring4_line0_x_start
# ring4_line0_y_start
# ring4_line0_x_end
# ring4_line0_y_end
# ...
# ring4_line15_x_start
# ring4_line15_y_start
# ring4_line15_x_end
# ring4_line15_y_end


# for a circle with origin (j, k) and radius r:
# x(t) = r cos(t) + j       y(t) = r sin(t) + k

import math

# for a circle with origin (j, k) and radius r:
#   x(t) = r cos(t) + j       y(t) = r sin(t) + k

j = 80
k = 60


for ring in range(0,5):
		if(ring == 0):
			r1=30 
			r2=40
		elif(ring == 1):
			r1=40
			r2=50
		elif(ring == 2):
			r1=50
			r2=60
		elif(ring == 3):
			r1=60
			r2=70					
		else:
			r1=70
			r2=80
		for line in range(0,16):
			print("RING: " + str(ring) +" LINE: "+ str(line))
			x_start = round(r1*math.cos(math.pi/8*line) + j)
			y_start = round(r1*math.sin(math.pi/8*line) +k)
			x_end = round(r2*math.cos(math.pi/8*line) + j)
			y_end = round(r2*math.sin(math.pi/8*line) +k)


			x_start_bin = bin(x_start)[2:]
			y_start_bin = bin(y_start)[2:]
			x_end_bin = bin(x_end)[2:]
			y_end_bin = bin(y_end)[2:]

			x_start_bin = '0'* (8-len(x_start_bin)) + x_start_bin
			y_start_bin = '0'* (8-len(y_start_bin)) + y_start_bin
			x_end_bin = '0'* (8-len(x_end_bin)) + x_end_bin
			y_end_bin = '0'* (8-len(y_end_bin)) + y_end_bin


			print(str(x_start) + ", " + str(x_start_bin))
			print(str(y_start) + ", " + str(y_start_bin))
			print(str(x_end) + ", " + str(x_end_bin))
			print(str(y_end) + ", " + str(y_end_bin))

		print('----------------')




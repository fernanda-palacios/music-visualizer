# Command to run program: 'python3 wav_to_bin.py FILENAME'

# This program takes a .wav 'FILENAME' (without extension) inside wav_files directory
# and create a binary file 'FILENAME_bin'.txt of the form:
# avg absolute value of amplitude during first second (32-bit value)
# avg absolute value of amplitude during second second (32-bit value)
#...
# avg absolute value of amplitude during nth second (32-bit value)


# Print to stdout the number of seconds that were analyzed 
# and the number of values averaged per second


import os
import sys

FILENAME = sys.argv[1] 
MAX_VALUES_PER_SECOND = 9 - 1 # estimated this value by looking at 1s long .wav file

# os.system("od -A d -j 44 -t d2 "  + 'wav_files/' + FILENAME + '.wav > ' +  'txt_files/' + FILENAME + '.txt' )

f_read = open('txt_files/' + FILENAME + ".txt", "r")
f_write = open('txt_files/' + FILENAME + "_bin.txt", "a")


curr_value_num = 1
curr_sum = 0
curr_avg = 0
for line in f_read:
	line = line.split()
	# loop over values in each line
	if(len(line) == 9):
		# skip 0th element
		for i in range (1, 9):

			curr_value = abs(int(line[i]))
			curr_sum += curr_value
			print(curr_value)


			if(curr_value_num == MAX_VALUES_PER_SECOND):
				print("reached max")
				curr_avg = round(curr_sum/MAX_VALUES_PER_SECOND)
				curr_value_num = 1
				curr_sum = 0
				print("avg: " + str(curr_avg))

			else:
				curr_value_num+=1



# check if we still need to write average for last second
if(curr_value_num != 0):
	print("would write one more avg")
	print("sum:", curr_sum)
	curr_avg = round(curr_sum/MAX_VALUES_PER_SECOND)
	print(curr_avg)

f_read.close()
f_write.close()






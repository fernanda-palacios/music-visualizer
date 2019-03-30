# od -A  -j 44 -t d2 door.wav

# take a .wav 'filename' (without extension) inside wav_files directory a
# and create a binary file 'filename_bin'.txt of the form:
# byte1
# byte2
#...
# byten

import os
import sys

FILENAME = sys.argv[1] 

# os.system("od -A d -j 44 -t d2 "  + 'wav_files/' + FILENAME + '.wav > ' +  'txt_files/' + FILENAME + '.txt' )

f_read = open('txt_files/' + FILENAME + ".txt", "r")
f_write = open('txt_files/' + FILENAME + "_bin.txt", "a")


max_num_line = sum(1 for line in open('txt_files/' + FILENAME + ".txt")) - 1
print(max_num_line)

curr_line_num = 0
for line in f_read:
	line = line.split()
	if(len(line) == 9):
		# skip 0th element
		for i in range (1, 9):
			# take absolute value of each number
			curr_value = abs(int(line[i]))
			# convert to binary (32 bits)
			curr_value = bin(curr_value)[2:]
			curr_value = '0'* (32-len(curr_value)) + curr_value
			# append to filename_bin
			f_write.write(curr_value + '\n')
	curr_line_num+=1

f_read.close()
f_write.close()


# expect 4061*8 = 32488 lines (no newline)




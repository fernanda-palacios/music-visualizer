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
import wave

FILENAME = sys.argv[1] 
wf  = wave.open('wav_files/' + FILENAME + '.wav', "rb")
SAMPLE_RATE = int(wf.getframerate())

if(SAMPLE_RATE == 44100):
	# this sample rate requires adjust
	SAMPLE_RATE = 44100*2

MAX_VALUES_PER_SECOND = SAMPLE_RATE - 1

WAV_FILE_PATH = 'wav_files/' + FILENAME + '.wav'


os.system("od -A d -j 44 -t d2 "  + WAV_FILE_PATH+ ' > ' +  'txt_files/' + FILENAME + '.txt' )
f_read = open('txt_files/' + FILENAME + ".txt", "r")
f_write = open('txt_files/' + FILENAME + "_bin.txt", "a")


num_seconds = 0
curr_value_num = 0
curr_sum = 0
curr_avg = 0
for line in f_read:
	line = line.split()
	if(len(line) > 1):
		for i in range (1, len(line)):
			try:
				curr_value = abs(int(line[i]))
				

			except:
				#go to next line
				break
			else:

				curr_value_num+=1
				curr_sum += curr_value

				if(curr_value_num == MAX_VALUES_PER_SECOND):
					curr_avg = round(curr_sum/MAX_VALUES_PER_SECOND)
					print("reached max", " avg:", curr_avg)
					curr_value_num = 0
					curr_sum = 0
					num_seconds+=1


# check if we still need to write average for last second
if(curr_value_num != 0):
	curr_avg = round(curr_sum/curr_value_num)
	print("last avg: ", curr_avg)
	num_seconds+=1


print("number of seconds: ", num_seconds)
print("number of values per second: ", MAX_VALUES_PER_SECOND)

f_read.close()
f_write.close()

from pydub import AudioSegment
import random


#run: python3 change_volume.py > demo_info.txt
song = AudioSegment.from_wav("wav_files/con_calma.wav")

f_write = open('txt_files/'+ "con_calma_demo_bin.txt", "a")


# in seconds
song_length = len(song) / (1000)

remaining_length = song_length
ten_seconds = 10 * 1000

edited_song = song[0:1]


index_to_volume_change = {0: -10, 1: 0, 2: 10}

# loop in 10 second intervals
num_intervals = 0
while(remaining_length >= 10):
	# calculate next interval
	num_intervals+=1
	start_interval = ten_seconds * (num_intervals - 1)
	end_interval = ten_seconds * (num_intervals)

	# change volume of current_interval
	current_interval = song[start_interval:end_interval]
	random_volume = random.randint(0,2)
	edited_song += current_interval + index_to_volume_change[random_volume]

	random_volume_bin = bin(random_volume)[2:]
	random_volume_bin = '0'* (32-len(random_volume_bin)) + random_volume_bin
	f_write.write(str(random_volume_bin) + '\n')

	print(start_interval, "-", end_interval, "volume",random_volume)

	remaining_length= remaining_length - 10


# calculate last interval < 10s
num_intervals+=1
start_interval = ten_seconds * (num_intervals - 1)
end_interval = len(song)

# change volume of last_interval
current_interval = song[start_interval:end_interval]
random_volume = random.randint(0,2)
edited_song += current_interval + index_to_volume_change[random_volume]
f_write.write(str(random_volume_bin))
print(start_interval, "-", end_interval, "volume",random_volume)


print("total miliseconds: ", len(song))
print("total minutes: ", song_length/60)
print("total seconds: ", song_length)
print("remaining seconds: ", remaining_length)


# first_10s = song[:ten_seconds] + 10
edited_song.export("wav_files/con_calma_demo.wav", format="wav")
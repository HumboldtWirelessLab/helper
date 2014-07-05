#!/usr/bin/python
import csv
import sys
import time
import fileinput
import signal
from optparse import OptionParser


def check_args():
	global cfg_max_time
	
	#echo "Translate " --control-file="${CONTROLFILE}" --node-list="${NODELIST}" --used-simulator="${USED_SIMULATOR}" --node-to-click-map="${node_to_clickfile_map[@]}" --node-to-num-map="${node_to_num_map[@]}"
	optParser = OptionParser()
	optParser.add_option("-t", "--max-time", dest="max_time", type="float", help="Maximal simulation time stamp as float (sim duration)")
	(options, args) = optParser.parse_args()

	if not options.max_time:
		optParser.print_help()
		sys.exit(-1)

	cfg_max_time = options.max_time


def signal_handler(signal, frame):
    sys.exit(0)


def update_progress(cur, max):
	progress = float(cur) / max
	bar_len = 40
	filled = int(bar_len * progress)
	unfilled = int(bar_len * (1.0 - progress))
	sys.stdout.write('\r[{0}{1}] {2:.1f}/{3:.1f} {4:.2f}%'.format('#'*(filled), ' '*(unfilled), cur, max, progress * 100))
	sys.stdout.flush()


def decode_error_msg_to_time(line):
	line_array = line.split(' ')
	if len(line_array) <= 2 or line_array[0] != "ERROR": 
		return None

	try:
		result=float(line_array[1])
	except ValueError:
		result=None

	if len(line_array) < 2 or len(line_array[1]) > 20 :
		result=None

	return result

def decode_warn_msg_to_time(line):
	line_array = line.split(' ')
	if len(line_array) <= 2 or line_array[0] != "WARN": 
		return None

	try:
		result=float(line_array[1])
	except ValueError:
		result=None

	if len(line_array) < 2 or len(line_array[1]) > 20 :
		result=None

	return result


def decode_printed_timestamp_to_time(line):
	line_array = line.split(':')
	try:
		result=float(line_array[0])
	except ValueError:
		result=None

	if len(line_array) < 2 or len(line_array[0]) > 20 :
		result=None

	return result


def decode_line_to_time(line):
	result = decode_printed_timestamp_to_time(line)
	if result is not None:
		return result

	result = decode_error_msg_to_time(line)
	if result is not None:
		return result

	result = decode_warn_msg_to_time(line)
	if result is not None:
		return result

	return None


def init_time_measurement():
	global start_time
	start_time = time.time()


def delay_gone():
	global start_time
	is_gone = time.time() - start_time >= 1
	if is_gone:
		start_time = time.time()
	return is_gone 


check_args()
signal.signal(signal.SIGINT, signal_handler)
init_time_measurement()

for line in sys.stdin:
	cur_time = decode_line_to_time(line)
	if cur_time and delay_gone():
		update_progress(cur_time, cfg_max_time)
print
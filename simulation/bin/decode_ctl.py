#!/usr/bin/python
import csv
import sys
import time
from optparse import OptionParser


def check_args():
	global cfg_control_file
	global cfg_node_list
	global cfg_used_simulator
	global cfg_node_to_clickfile_map
	global cfg_node_to_num_map
	global cfg_first_node
	global cfg_last_node
	global cfg_node_mac_map
	global cfg_jist_property_file
	global cfg_tcl_file

	#echo "Translate " --control-file="${CONTROLFILE}" --node-list="${NODELIST}" --used-simulator="${USED_SIMULATOR}" --node-to-click-map="${node_to_clickfile_map[@]}" --node-to-num-map="${node_to_num_map[@]}"
	optParser = OptionParser()
	optParser.add_option("", "--control-file", dest="control_file", help="Input control file (ctl)")
	optParser.add_option("", "--tcl-file", dest="tcl_file", help="TCL output file")
	optParser.add_option("", "--node-list", dest="node_list", help="List of nodes")
	optParser.add_option("", "--used-simulator", dest="used_simulator", help="Used simulator")
	optParser.add_option("", "--node-to-click-map", dest="node_to_clickfile_map", help="list of click files ( used to map node to click file)")
	optParser.add_option("", "--node-to-num-map", dest="node_to_num_map", help="list of nums")
	optParser.add_option("", "--node-name-sed-arg", dest="node_name_sed_arg", help="used to replace FIRSTNODE, LASTNODE by node name")
	optParser.add_option("", "--node-mac-sed-arg", dest="node_mac_sed_arg", help="used to replace node:eth by mac")
	optParser.add_option("", "--jist-property-file", dest="jist_property_file", help="path to jist property file")
	(options, args) = optParser.parse_args()

	if not options.control_file or not options.node_list or \
		not options.used_simulator or not options.node_to_clickfile_map or \
		not options.node_to_num_map or not options.node_name_sed_arg or \
		not options.node_mac_sed_arg or not options.tcl_file:
		optParser.print_help()
		sys.exit(-1)
	
	cfg_control_file = options.control_file
	cfg_used_simulator = options.used_simulator
	cfg_tcl_file = options.tcl_file
	if options.jist_property_file:
		cfg_jist_property_file = options.jist_property_file
	else:
		cfg_jist_property_file = ""
	
	cfg_node_list = options.node_list.split('\n')
	node_to_clickfile_map = options.node_to_clickfile_map.split(" ")
	node_to_num_map = options.node_to_num_map.split(" ")
	len_nodes = len(cfg_node_list)
	len_click = len(node_to_clickfile_map)
	len_nums = len(node_to_num_map)
	if len_nodes != len_nums or len_nodes != len_click:
		print("Invalid input: Length of node-list({0}) needs to match length of click-map({1}) and length of num-map({2}).".format(len_nodes, len_click, len_nums))
		sys.exit(-1)

	cfg_node_to_clickfile_map = dict()
	cfg_node_to_num_map = dict()
	for i, node in enumerate(cfg_node_list):
		cfg_node_to_clickfile_map[node] = node_to_clickfile_map[i]
		cfg_node_to_num_map[node] = int(node_to_num_map[i])

	node_name_sed_list = options.node_name_sed_arg.split("#")
	cfg_first_node = node_name_sed_list[2]
	cfg_last_node = node_name_sed_list[5]

	node_mac_list = options.node_mac_sed_arg.replace("-e s#","").replace("#g","").split()
	cfg_node_mac_map = []
	for e in node_mac_list:
		cfg_node_mac_map.append(tuple(e.split("#")))
	

def print_cfg():
	print("control file      : " + cfg_control_file)
	print("tcl file          : " + cfg_tcl_file)
	print("used simulator    : " + cfg_used_simulator)
	print("FIRSTNODE         : " + cfg_first_node)
	print("LASTNODE          : " + cfg_last_node)
	print("JIST property file: " + cfg_jist_property_file)
	print("list of nodes     :") 
	for e in cfg_node_list:
		print("  " + e)
	print("list of click map : ")
	for key, value in cfg_node_to_clickfile_map.iteritems(): 
		print("  {0} -> {1}".format(key, value))
	print("list of num map : ") 
	for key, value in cfg_node_to_num_map.iteritems(): 
		print("  {0} -> {1}".format(key, value))
	print("list of node-mac-map:")
	for (key, value) in cfg_node_mac_map:
		print("  {0} -> {1}".format(key, value))


def update_progress(cur, max):
	progress = float(cur) / max
	bar_len = 40
	filled = int(bar_len * progress)
	unfilled = int(bar_len * (1.0 - progress))
	sys.stdout.write('\r[{0}{1}] {2}/{3} {4:.2f}%'.format('#'*(filled), ' '*(unfilled), cur, max, progress * 100))
	sys.stdout.flush()


def decode():
	max_lines = len(open(cfg_control_file).readlines())

	with open(cfg_control_file, 'rb') as ctlfile:
		for line_number, row in enumerate(ctlfile):
			if '#' in row:
				continue

			sep_row = row.split()
			if len(sep_row) < 2:
				continue

			# Assignment
			time = sep_row[0]
			node_name = sep_row[1]
			node_dev = sep_row[2]
			mode = sep_row[3]
			element = sep_row[4]
			handler = sep_row[5]
			params_raw = " ".join(sep_row[6::])
			#print("time:{0} node_name:{1} node_dev:{2} mode:{3} element:{4} handler:{5} params:{6}".format(time, node_name, node_dev, mode, element, handler, params_raw))
			
			# Replace pseudo names
			if node_name == "FIRSTNODE":
				node_name = cfg_first_node
			elif node_name == "LASTNODE":
				node_name = cfg_last_node
			
			if node_name == "ALL":
				handler_nodes = cfg_node_list
			else:
				handler_nodes = [node_name]

			for node in handler_nodes:

				if not node in cfg_node_to_clickfile_map:
					continue

				click_file = cfg_node_to_clickfile_map[node]
				node_num = cfg_node_to_num_map[node] - 1

				if time == "":
					continue

				if mode == "write":
					params = params_raw
					for (key, value) in cfg_node_mac_map:
						params = params.replace(key, value)

					if cfg_used_simulator == "ns":
						with open(click_file, 'a') as outputfile:
							new_line="Script(wait {0}, write  {1}.{2} {3});\n".format(time, element, handler, params)
							outputfile.write(new_line)
					else:
						with open(cfg_jist_property_file, 'a') as outputfile:
							new_line="{0},{1},{2},{3},{4},{5},{6};\n".format(time, node_name, node_dev, mode, element, handler, params)
							outputfile.write(new_line)

				elif mode == "read":
					if cfg_used_simulator == "ns":
						with open(click_file, 'a') as outputfile:
							new_line="Script(wait {0}, read {1}.{2});\n".format(time, element, handler)
							outputfile.write(new_line)
					else:
						with open(cfg_jist_property_file, 'a') as outputfile:
							new_line="{0},{1},{2},{3},{4},{5},;\n".format(time, node_name, node_dev, mode, element, handler)
							outputfile.write(new_line)

				elif mode == "move":
					move_mode=sep_row[4]
					move_speed=sep_row[5]
					move_x=sep_row[6]
					move_y=sep_row[7]
					move_z=sep_row[8]
					if cfg_used_simulator == "ns":
						with open(cfg_tcl_file, 'a') as outputfile:
							new_line='$ns_ at {0} "$node_({1}) setdest {2} {3} {4}"\n'.format(time, node_num, move_x, move_y, move_speed)
							outputfile.write(new_line)
					else:
						with open(cfg_jist_property_file, 'a') as outputfile:
							new_line="{0},{1},{2},{3},{4},{5},;\n".format(time, node_name, node_dev, mode, element, handler)
							outputfile.write(new_line)

			if five_secs_gone():
				update_progress(line_number, max_lines)
	print


def init_time_measurement():
	global start_time
	start_time = time.time()


def five_secs_gone():
	global start_time
	is_gone = time.time() - start_time >= 5
	if is_gone:
		start_time = time.time()
	return is_gone 


init_time_measurement()
check_args()
decode()
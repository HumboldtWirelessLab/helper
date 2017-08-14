#!/usr/bin/python
import csv
import sys
import time
import re
from optparse import OptionParser


def check_args():
	global cfg_node_to_x_map
	global cfg_node_to_y_map
	global cfg_node_to_z_map
	
	global cfg_node_mac_map
	global cfg_node_to_num_map
	
	global cfg_tcl_file
	global cfg_clickfile_map_file
	

	#echo "Translate " --control-file="${CONTROLFILE}" --node-list="${NODELIST}" --used-simulator="${USED_SIMULATOR}" --node-to-click-map="${node_to_clickfile_map[@]}" --node-to-num-map="${node_to_num_map[@]}"
	optParser = OptionParser()
	optParser.add_option("", "--tcl-file", dest="tcl_file", help="TCL output file")
	optParser.add_option("", "--node-list-file", dest="node_to_clickfile_map_file", help="file with list of click files ( used to map node to click file)")
	optParser.add_option("", "--node-to-num-map-file", dest="node_to_num_map_file", help="file with list of nums")
	optParser.add_option("", "--node-to-position-map-file", dest="node_to_position_map_file", help="file with list of positions")
	(options, args) = optParser.parse_args()

	if not options.node_to_clickfile_map_file or \
		not options.node_to_num_map_file or not options.node_to_position_map_file or \
		not options.tcl_file:
		optParser.print_help()
		sys.exit(-1)
	

	cfg_tcl_file = options.tcl_file
	cfg_clickfile_map_file = options.node_to_clickfile_map_file

  #clickfilemap
	cfg_node_mac_map = dict()
	cfg_node_to_num_map = dict()

	len_nodes = 0
	
	f = open(options.node_to_num_map_file)
	tsvfile = csv.reader(f, delimiter=' ')
	for line in tsvfile:
		len_nodes = len_nodes + 1
	
		#print("" + line[0] + " : " + line[3]) 
		cfg_node_mac_map[line[0]] = line[2]
		cfg_node_to_num_map[line[0]] = str(int(line[3])-1)
	
	f.close()

  #clickfilemap
	cfg_node_to_x_map = dict()
	cfg_node_to_y_map = dict()
	cfg_node_to_z_map = dict()

	
	f = open(options.node_to_position_map_file)
	#todo: allow multiple spaces as delimiter
	tsvfile = csv.reader(f, delimiter=' ')
	for line in tsvfile:
		cfg_node_to_x_map[line[0]] = line[1]
		cfg_node_to_y_map[line[0]] = line[2]
		if len(line) < 4:
			cfg_node_to_z_map[line[0]] = "0"
		else:
			cfg_node_to_z_map[line[0]] = line[3]

	f.close()


def print_ns():
	f = open(cfg_clickfile_map_file)
	tsvfile = csv.reader(f, delimiter=' ')
	for line in tsvfile:
		#print("" + line[0] + " " + cfg_node_to_num_map[line[0]] + " " + cfg_node_mac_map[line[0]] + " " + cfg_node_to_x_map[line[0]] + " " + cfg_node_to_y_map[line[0]] + " " + cfg_node_to_z_map[line[0]])
		print("set node_name(" + cfg_node_to_num_map[line[0]] + ") \"" + line[0] + "\"")
		print("set node_mac(" + cfg_node_to_num_map[line[0]] + ") \"" + re.sub('-',':',cfg_node_mac_map[line[0]]) + "\"")
		print("set pos_x(" + cfg_node_to_num_map[line[0]] + ") " + cfg_node_to_x_map[line[0]])
		print("set pos_y(" + cfg_node_to_num_map[line[0]] + ") " + cfg_node_to_y_map[line[0]])
		print("set pos_z(" + cfg_node_to_num_map[line[0]] + ") " + cfg_node_to_z_map[line[0]])
		print("set nodelabel(" + cfg_node_to_num_map[line[0]] + ") \"" + line[0] + "." + line[1] + "\"")
		print("set clickfile(" + cfg_node_to_num_map[line[0]] + ") \"" + line[6] + "\"")
	
	
	f.close()

check_args()
print_ns()

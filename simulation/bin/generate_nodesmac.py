#!/usr/bin/python
import csv
import sys
import time
import random
import math
import csv
import re
from optparse import OptionParser


def check_args():
	global cfg_node_list_file
	global cfg_node_table
	global cfg_name2mac
	global len_nodes
	global lines

	optParser = OptionParser()
	optParser.add_option("", "--node-list-file", dest="node_list_file", help="List of nodes")
	optParser.add_option("", "--name2mac", dest="name2mac", help="name2mac")
	(options, args) = optParser.parse_args()
	
	if not options.node_list_file:
		optParser.print_help()
		sys.exit(-1)
	
	
	cfg_node_list_file = options.node_list_file

	if options.name2mac:
		if options.name2mac == "yes":
			cfg_name2mac = 1
		else:
			cfg_name2mac = 0
	else:
		cfg_name2mac = 0
	
	f = open(cfg_node_list_file)
	
	## define csv reader object, assuming delimiter is tab
	tsvfile = csv.reader(f, delimiter=' ')

	lines = []

	## iterate through lines in file
	for line in tsvfile:
		lines.append(line)

	#print "Col1",[line[1] for line in lines]
	
	f.close()
	
	len_nodes = len(lines)
#	if len_nodes < 0 :
#		print("Invalid input: Length of node-list({0}) needs to match length of click-map({1}) and length of num-map({2}).".format(len_nodes, len_click, len_nums))
#		sys.exit(-1)

def print_cfg():
	print("node_list_file    : " + cfg_node_list_file)
	print("cfg_name2mac      : {0}".format(cfg_name2mac))
	print("len               : {0}".format(len_nodes))
	print("list of nodes     :") 
#	for line in lines:
#		print(line[0].rstrip('\n') + " " + line[1].rstrip('\n') )
		

def gen_nodes_mac():
	node_id = 0
	for line in lines:
		node_id = node_id + 1

		if cfg_name2mac == 1:
		  mac = int(re.sub("[a-z]*[A-Z]*", "", line[0]))
		else:
			mac = node_id

		node_id_h = hex(int(math.ceil(mac/256)))[2:]
		if len(node_id_h) == 1:
			node_id_h = "0" + node_id_h

		node_id_l = hex(int(math.ceil(math.fmod(mac,256))))[2:]
		if len(node_id_l) == 1:
			node_id_l = "0" + node_id_l

		print(line[0].rstrip('\n') + " " + line[1].rstrip('\n') + " 00-00-00-00-" + node_id_h + "-"+ node_id_l + " {0}".format(node_id))
		

check_args()
#print_cfg()
gen_nodes_mac()

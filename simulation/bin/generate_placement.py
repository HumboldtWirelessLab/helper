#!/usr/bin/python2
import csv
import sys
import time
import random
import math
from optparse import OptionParser


def check_args():
	global cfg_node_list_file
	global cfg_node_list
	global cfg_placement
	global cfg_sidelen
	global cfg_relative
	global len_nodes

	#echo "Translate " --control-file="${CONTROLFILE}" --node-list="${NODELIST}" --used-simulator="${USED_SIMULATOR}" --node-to-click-map="${node_to_clickfile_map[@]}" --node-to-num-map="${node_to_num_map[@]}"
	optParser = OptionParser()
	optParser.add_option("", "--node-list-file", dest="node_list_file", help="List of nodes")
	optParser.add_option("", "--placement", dest="placement", help="placement")
	optParser.add_option("", "--sidelen", dest="sidelen", type="int", help="sidelen")
	optParser.add_option("", "--relative", dest="relative", type="int", help="relative")
	(options, args) = optParser.parse_args()
	
	if not options.node_list_file or \
		not options.placement or not options.sidelen:
		optParser.print_help()
		sys.exit(-1)
	
	
	cfg_node_list_file = options.node_list_file
	cfg_placement = options.placement
	cfg_sidelen = options.sidelen
	if options.relative:
		cfg_relative = options.relative
	else:
		cfg_relative = 0
	
	f = open(cfg_node_list_file)
	per_row = []
	for line in f:
	    per_row.append(line.split(' '))

	per_column = zip(*per_row)

	node_file_content =  per_column[0]
	f.close()
	
	cfg_node_list = node_file_content
	len_nodes = len(cfg_node_list)
	if len_nodes < 0 :
		print("Invalid input: Length of node-list({0}) needs to match length of click-map({1}) and length of num-map({2}).".format(len_nodes, len_click, len_nums))
		sys.exit(-1)

def print_cfg():
	print("node_list_file    : " + cfg_node_list_file)
	print("placement         : " + cfg_placement)
	print("relative          : {0}".format(cfg_relative))
	print("sidelen           : {0}".format(cfg_sidelen))
	print("list of nodes     :") 
#	for e in cfg_node_list:
#		print("1  " + e.rstrip('\n'))
		

def gen_random():
#	print("placement:") 

	if cfg_relative == 1:
		sidelen = (len_nodes*cfg_sidelen)
	else:
		sidelen = cfg_sidelen

	for e in cfg_node_list:
		x = random.randint(0,sidelen)
		y = random.randint(0,sidelen)
		print(e.rstrip('\n') + " {0} {1} 0".format(x, y))


def gen_grid():
	node_len=math.ceil(math.sqrt(len_nodes))
	noden=0
	
	if cfg_relative == 1:
		sidestep=cfg_sidelen
	else:
		if node_len == 1:
			sidestep=cfg_sidelen
		else:
			sidestep=cfg_sidelen/(node_len-1)

#	print("nodel: {0}  noden: {1} sidesep: {2}".format(node_len, noden,sidestep))

	for e in cfg_node_list:
		x = int(math.ceil(math.trunc(math.fmod(noden,node_len))*sidestep))
		y = int(math.ceil(math.trunc(noden/node_len)*sidestep))
		noden = noden+1
		print(e.rstrip('\n') + " {0} {1} 0".format(x, y))

def gen_grid_rand():
	node_len=math.ceil(math.sqrt(len_nodes))
	noden=0
	
	if cfg_relative == 1:
		sidestep=cfg_sidelen
	else:
		if node_len == 1:
			sidestep=cfg_sidelen
		else:
			sidestep=cfg_sidelen/(node_len-1)

	randstep=int(math.ceil(sidestep/10))
#	print("nodel: {0}  noden: {1} sidesep: {2}".format(node_len, noden,sidestep))

	for e in cfg_node_list:
		x_add = random.randint(0,randstep)
		x = int(math.ceil(math.trunc(math.fmod(noden,node_len))*sidestep)+x_add)
		y_add = random.randint(0,randstep)
		y = int(math.ceil(math.trunc(noden/node_len)*sidestep)+y_add)
		noden = noden+1
		print(e.rstrip('\n') + " {0} {1} 0".format(x, y))

def gen_string():
	noden=0
	
	if cfg_relative == 1:
		sidestep=cfg_sidelen
	else:
		if len_nodes == 1:
			sidestep=cfg_sidelen
		else:
			sidestep=cfg_sidelen/(len_nodes-1)

	y=int(math.ceil(cfg_sidelen/2))

	for e in cfg_node_list:
		x = int(math.trunc(noden*sidestep))
		noden = noden+1
		print(e.rstrip('\n') + " {0} {1} 0".format(x, y))

check_args()
#print_cfg()

if cfg_placement == "random":
	gen_random()

if cfg_placement == "grid":
	gen_grid()

if cfg_placement == "gridrand":
	gen_grid_rand()

if cfg_placement == "string":
	gen_string()

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
	global cfg_nodesmacfile
	global cfg_node_table
	global cfg_mode
	global len_nodes
	global lines

	optParser = OptionParser()
	optParser.add_option("", "--nodesmacfile", dest="nodesmacfile", help="List of nodes")
	optParser.add_option("", "--mode", dest="mode", help="mode")
	(options, args) = optParser.parse_args()
	
	if not options.nodesmacfile:
		optParser.print_help()
		sys.exit(-1)
	
	
	cfg_nodesmacfile = options.nodesmacfile
	cfg_mode = options.mode;

	f = open(cfg_nodesmacfile)

	## define csv reader object, assuming delimiter is tab
	tsvfile = csv.reader(f, delimiter=' ')

	lines = []

	## iterate through lines in file
	for line in tsvfile:
		lines.append(line)
	
	f.close()
	
	len_nodes = len(lines)
#	if len_nodes < 0 :
#		print("Invalid input: Length of node-list({0}) needs to match length of click-map({1}) and length of num-map({2}).".format(len_nodes, len_click, len_nums))
#		sys.exit(-1)

def print_cfg():
	print("node_list_file    : " + cfg_node_list_file)
	print("cfg_mode          : " + cfg_mode)
	print("len               : {0}".format(len_nodes))
	print("list of nodes     :") 
#	for line in lines:
#		print(line[0].rstrip('\n') + " " + line[1].rstrip('\n') )
		

def gen_sedargs():
	node_num = 0

	if cfg_mode == "mac2id":
		for line in lines:
			node_mac = line[2]
			node_id = line[3]

			print(" -e s#" + node_mac + "#" + node_id +"#g"),

	if cfg_mode == "mac2name":
		for line in lines:
			node_mac = line[2]
			node_name = line[0]

			print(" -e s#" + node_mac + "#" + node_name +"#g"),

	if cfg_mode == "name2id":
		for line in lines:
			node_name = line[0]
			node_id = line[3]

			print(" -e s#" + node_name + "#" + node_id +"#g"),

	if cfg_mode == "id2mac":
		for line in lines:
			node_mac = line[2]
			node_id = line[3]

			print(" -e \"s#\(^\|\s\+\)\(" + node_id + "\)\(\s\+\|\$\)#\\1" + node_mac + "\\3#g\""),

	if cfg_mode == "id2name":
		for line in lines:
			node_name = line[0]
			node_id = line[3]

			print(" -e \"s#\(^\|\s\+\)\(" + node_id + "\)\(\s\+\|\$\)#\\1" + node_name + "\\3#g\""),

	if cfg_mode == "nameeth2id":
		for line in lines:
			node_name = line[0]
			node_id = line[3]

			if node_num == 0:
				print("-e s#FIRSTNODE:eth#" + node_id +"#g"),
				node_num = node_num + 1

			print(" -e s#" + node_name + ":eth#" + node_id +"#g"),
  
		print("-e s#LASTNODE:eth#" + node_id +"#g")

	if cfg_mode == "nameeth2mac":
		for line in lines:
			node_name = line[0]
			node_mac = line[2]

			if node_num == 0:
				print("-e s#FIRSTNODE:eth#" + node_mac +"#g"),
				node_num = node_num + 1

			print(" -e s#" + node_name + ":eth#" + node_mac +"#g"),
  
		print("-e s#LASTNODE:eth#" + node_mac +"#g")
		
	if cfg_mode == "specialname2name":
		line = lines[0]
		print("-e s#FIRSTNODE#" + line[0] +"#g"),
		line = lines[len_nodes-1]
		print("-e s#LASTNODE#" + line[0] +"#g")

check_args()
#print_cfg()
gen_sedargs()

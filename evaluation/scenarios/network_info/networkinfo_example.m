show_network_stats('example/graph_psr_1_100.txt','example/result/');
show_network_stats('example/graph_psr_1_1000.txt','example/result/');
partitions('example/graph.txt', 'example/result/');
nodedegree('example/cluster_0.csv', 'example/graph.txt', 'example/result/');

import java.util.Vector;

import org.apache.commons.cli.*;


public class DiscoveryContext {
	
	private int MAX_NODES = 150;
	public int[][] link_matrix;
	
	// to translate nodes names into managable numbers => name_table[idx, name]
	public Vector<String> name_table;
	public Vector<Integer> subgraph;
	
	Options options;
	CommandLine cmd;
	CommandLineParser parser;
	
	public DiscoveryContext() {
		
		link_matrix 	= new int[MAX_NODES][MAX_NODES];
		name_table 		= new Vector<String>();
		subgraph 		= new Vector<Integer>();

	}
	
	public int getGraphSize() {
		return name_table.size();
	}
	
	public int getSubgraphSize() {
		return subgraph.size();
	}
}

import java.util.Vector;


public class DiscoveryContext {

	public int[][] link_matrix;
	
	// to translate nodes names into managable numbers => name_table[idx, name]
	public Vector<String> name_table;
	
	public Vector<Integer> subgraph;
	
	// total number of nodes in main graph
	public int totalNodeNumber;
	public int nodes_left;
	public int trashold_metric;
	public int hop_limit;
	
	public DiscoveryContext(int nodes, String[] params) {
		link_matrix 	= new int[nodes][nodes];
		name_table 		= new Vector<String>();
		subgraph 		= new Vector<Integer>();
		
		trashold_metric = Integer.parseInt(params[0]);		// important for ammonite to get dense but good subgraph
		nodes_left		= Integer.parseInt(params[1]);
		hop_limit 		= Integer.parseInt(params[2]);
	}
	
	public int getGraphSize() {
		return name_table.size();
	}
	
	public int getSubgraphSize() {
		return subgraph.size();
	}
}

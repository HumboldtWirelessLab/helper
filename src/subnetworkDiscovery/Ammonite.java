/*
 * Author: kuehne@informatik.hu-berlin.de
 * Date: Nov 2011
 */


import org.apache.commons.cli.*;

/*
 * In theory the Ammonite-Algorithm tries to discover a dense subgraph within a graph. 
 * The subgraph starts with two nodes and by inductively adding a node which is connected to at least
 * two nodes of the subgraph we continue building little cycles around the former subgraph, thus
 * creating an ammonite-like graph ;)
 */
public class Ammonite implements GenericDiscovery {

	DiscoveryContext ctx;

	String srcFile;
	int requested_nodes;
	
	int nodes_left;
	int trashold_metric;
	int hop_limit;
	
	public Ammonite(String[] args, DiscoveryContext Context) {
		ctx 				= Context;

		// Get the parameters from user
		nodes_left 			= (ctx.cmd.hasOption("nodes")) ? Integer.parseInt(ctx.cmd.getOptionValue("nodes")) : 10;
		trashold_metric 	= (ctx.cmd.hasOption("thrashold-metric")) ? Integer.parseInt(ctx.cmd.getOptionValue("thrashold-metric")) : 1500;
		hop_limit			= (ctx.cmd.hasOption("hop-limit")) ? Integer.parseInt(ctx.cmd.getOptionValue("hop-limit")) : 10;
		
	}
	
	
	/*
	 * This algorithm needs a initial subgraph with  at least two nodes.
	 * This is done by selecting two nodes, either randomly or having some criteria.
	 */
	public void init() {
		
		int node = -1, neighbour_node = -1;
		
		// Initialize subgraph by adding first two anchor nodes. Get first  node with most links
		int count = 0, max = 0;
		for (int i=0;i<ctx.getGraphSize();i++) {
			count = 0;
			for (int j=0;j<ctx.getGraphSize();j++) {
				if(ctx.link_matrix[i][j] != 0) {
					count++;
				}
			}
			if (count > max) {
				node = i;
				max = count;
			}
			
		}

		// Find some neighbour of first anchor node
		for (int u=0; u<ctx.getGraphSize(); u++){
			if (ctx.link_matrix[node][u] > 0 ) neighbour_node = u;
		}
		
		// Add the two nodes
		if (node > -1 && neighbour_node > -1) {
			ctx.subgraph.add(node);
			ctx.subgraph.add(neighbour_node);
			nodes_left -= 2;
		} else {
			System.out.println("ERROR: Initial nodes do not exist.");
			System.exit(1);
		}
	}

	
	public void discover() {
		boolean potential_ammonite_found = false;
		
		for (int v=0;v<ctx.getSubgraphSize(); v++) {
			/*
			 * search for neighbours of i which are not yet member of
			 * subgraph 
			 */
			for (int w=0;w<ctx.getGraphSize(); w++) {
				int v_w_metric = ctx.link_matrix[ctx.subgraph.elementAt(v)][w];
				
				int v_w_subgraph_bestmetric = 10000;
				int best_w = -1;
				
				// test neighbour on membership
				if (v_w_metric != 0 && v_w_metric <= trashold_metric && !ctx.subgraph.contains(w))  {
					
					// test if we find cycles (having one hop only)
					// todo: implement an algo with parametrized search depth
					for (int u=0; u<ctx.getSubgraphSize(); u++){
						
						// get cycle with best metric
						if (ctx.link_matrix[w][ctx.subgraph.elementAt(u)] != 0 &&
								v_w_subgraph_bestmetric > ctx.link_matrix[w][ctx.subgraph.elementAt(u)] ) {
							v_w_subgraph_bestmetric = ctx.link_matrix[w][ctx.subgraph.elementAt(u)];
							best_w = w;
						}
					}
					
					// now, if optimum was found and we still need nodes, then add new (relative) optimal node
					if (best_w != -1 && nodes_left-1>=0) {
						nodes_left--;
						ctx.subgraph.add(best_w);
					}
				}
			}
		}
		
		/*
		 * If subgraph.size() < nodes_left, then try to find at least some close 
		 * nodes without the need to form new cycles
		 */
		if (nodes_left >= 0) {
			for (int u=0; u<ctx.getSubgraphSize(); u++){
				for (int w=0;w<ctx.getGraphSize(); w++) {
					if (nodes_left-1>=0 && 
							ctx.link_matrix[ctx.subgraph.elementAt(u)][w] != 0 && 
							!ctx.subgraph.contains(w)) {
						nodes_left--;
						ctx.subgraph.add(w);
						
						potential_ammonite_found = true;
					}
				}
			}
		}
		
		/*
		 *  By discovering new nodes (without cycles) we possibly found a new "ammonite".
		 *  So lets hunt for new ammonites ... :)
		 */
		if (potential_ammonite_found) discover();
		
	}

	public void finish() {
		for (int u=0; u<ctx.getSubgraphSize(); u++){
			System.out.println(ctx.name_table.elementAt(ctx.subgraph.elementAt(u)));
		}
		
		// System.out.println("");
		// System.out.println("Subgraph "+ ctx.subgraph.size() +" of " + ctx.name_table.size() + ".");
	}
}

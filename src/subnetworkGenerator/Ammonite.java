
/*
 * In theorie the Ammonite-Algorithm tries to discover a dense subgraph within a graph. 
 * The subgraph starts with two nodes and by inductively adding a node which is connected to at least
 * two nodes of the subgraph we continue building little cycles around the former subgraph, thus
 * creating an ammonite-like graph ;)
 */
public class Ammonite implements SubgraphDiscovery {

	SubgraphContext context;
	
	/*
	 * This algorithm needs a initial subgraph with  at least two nodes.
	 * This is done by selecting two nodes, either randomly or having some criteria.
	 */
	public void init(SubgraphContext sgContext) {
		context 	= sgContext;
		
		int node1	= 0;
		int node2	= 0;	
		int init_alg = 1;
		
		/*
		 * Initialize subgraph by adding first two anchor nodes
		 */
		switch (init_alg) {
		case 0: // get first two nodes with most links
			for (int i=0;i<context.getGraphSize();i++) {
				for (int j=0;j<context.getGraphSize();j++) {
					if(context.link_matrix[i][j] != 0) {
						node2=node1;
						node1=i;
					}
				}
			}
			break;
		case 1: // take this two specific nodes
			node1 = context.name_table.indexOf("wgt29");
			node2 = context.name_table.indexOf("wgt201");
			break;
		default: // choose randomly two nodes
			node1 = (int)(Math.random()*(context.getGraphSize()+1));
			node1 = (int)(Math.random()*(context.getGraphSize()+1));
			break;
		}
		
		if (node1 > -1 && node2 > -1) {
			context.subgraph.add(node1);
			context.subgraph.add(node2);
			context.nodes_left -= 2;
		} else {
			System.out.println("ERROR: Initial nodes do not exist.");
			System.exit(1);
		}
	}

	
	public void discover() {
		boolean potential_ammonite_found = false;
		
		for (int v=0;v<context.getSubgraphSize(); v++) {
			/*
			 * search for neighbours of i which are not yet member of
			 * subgraph 
			 */
			for (int w=0;w<context.getGraphSize(); w++) {
				int v_w_metric = context.link_matrix[context.subgraph.elementAt(v)][w];
				
				int v_w_subgraph_bestmetric = 10000;
				int best_w = -1;
				
				// test neighbour on membership
				if (v_w_metric != 0 && v_w_metric <= context.trashold_metric && !context.subgraph.contains(w))  {
					
					// test if we find cycles (having one hop only)
					// todo: implement an algo with parametrized search depth
					for (int u=0; u<context.getSubgraphSize(); u++){
						
						// get cycle with best metric
						if (context.link_matrix[w][context.subgraph.elementAt(u)] != 0 &&
								v_w_subgraph_bestmetric > context.link_matrix[w][context.subgraph.elementAt(u)] ) {
							v_w_subgraph_bestmetric = context.link_matrix[w][context.subgraph.elementAt(u)];
							best_w = w;
						}
					}
					
					// now, if optimum was found and we still need nodes, then add new (relative) optimal node
					if (best_w != -1 && context.nodes_left-1>=0) {
						context.nodes_left--;
						context.subgraph.add(best_w);
					}
				}
			}
		}
		
		/*
		 * If subgraph.size() < nodes_left, then try to find at least some close 
		 * nodes without the need to form new cycles
		 */
		if (context.nodes_left >= 0) {
			for (int u=0; u<context.getSubgraphSize(); u++){
				for (int w=0;w<context.getGraphSize(); w++) {
					if (context.nodes_left-1>=0 && 
							context.link_matrix[context.subgraph.elementAt(u)][w] != 0 && 
							!context.subgraph.contains(w)) {
						context.nodes_left--;
						context.subgraph.add(w);
						
						potential_ammonite_found = true;
					}
				}
			}
		}
		
		/*
		 *  By discovering new nodes (without cycles) we possibly found a new "ammonite".
		 *  So lets try again...
		 */
		if (potential_ammonite_found) discover();
		
	}

	public void finish() {
		for (int u=0; u<context.getSubgraphSize(); u++){
			System.out.println(context.name_table.elementAt(context.subgraph.elementAt(u)));
		}
		System.out.println("");
		
		System.out.println("Subgraph "+ context.subgraph.size() +" of " + context.name_table.size() + ".");
	}
}

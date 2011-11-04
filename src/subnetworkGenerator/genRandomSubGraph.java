
import java.io.*;
import java.util.Vector;

public class genRandomSubGraph {
	
	// number of total nodes
	static int total;
	static int min_metric;
	static int nodes_left;
	static int hop_limit;
	// expecting a network of max 150 nodes
	private static int[][] link_matrix = new int[150][150];
	
	// to translate nodes names into managable numbers => name_table[idx, name]
	private static Vector<String> name_table = new Vector<String>();
	
	private static Vector<Integer> subgraph = new Vector<Integer>();
	
	
	public static void main(String[] args) {

		BufferedReader f;
		int n1, n2;
		
		min_metric = Integer.parseInt(args[0]);
		nodes_left = Integer.parseInt(args[1]);
		hop_limit = Integer.parseInt(args[2]);
				
		System.out.println("ParamTest: "+ min_metric + " " + nodes_left + " " + hop_limit);
		
		try {
			f = new BufferedReader(new FileReader("./src/linksmetric.all"));
			String line = null;
			String[] tmp = new String[3];
			
			// read metric file
			while ( (line = f.readLine() ) != null) {
				tmp = line.split(" ");
				
				// build a name table to give every node an ID (idx)
				if (!name_table.contains(tmp[0])) {
					name_table.add(tmp[0]);
				}
				if (!name_table.contains(tmp[1])) {
					name_table.add(tmp[1]);
				}
				
				n1 = name_table.indexOf(tmp[0]);
				n2 = name_table.indexOf(tmp[1]);
				int metric = Integer.parseInt(tmp[2]);
				
				link_matrix[n1][n2] = metric;
			}
		} catch (IOException x) {
	        System.err.format("IOException: %s%n", x);
		}
		
		total = name_table.size();
		
		// Display link matrix
		for(int i = 0; i<total; i++) {
			for(int j = 0; j<total; j++) {
				//if (link_matrix[i][j] > 0) System.out.println("Testing "+name_table.elementAt(i)+"-"+name_table.elementAt(j)+":"+link_matrix[i][j]);
			}
		}
		
		
		
		// Start generating new subgraph by first searching for cycles
		
		// 1. We need a subgraph consisting of two initial nodes
		// I suppose, we get better results if we take nodes with plenty of neighbours
		// Todo: some algo to find two well connected nodes
		init_subgraph();
		
		// 2. Lets find some cycles to have a dense net.
		find_cycles();
		
		/*
		 * If ||S|| < n, then try to find at least some close 
		 * nodes without the need to form new cycles
		 */
		if (nodes_left >= 0)
			fillup_subgraph();
		
		for (int u=0; u<subgraph.size(); u++){
			System.out.println(name_table.elementAt(subgraph.elementAt(u)));
		}
		System.out.println("");
		
		System.out.println("Subgraph "+ subgraph.size() +" of " + name_table.size() + ".");
	}
	
	// the ammonite algorithm ;)
	private static void find_cycles() {
			
		for (int v=0;v<subgraph.size(); v++) {
			/*
			 * search for neighbours of i which are not yet member of
			 * subgraph 
			 */
			for (int w=0;w<total; w++) {
				int v_w_metric = link_matrix[subgraph.elementAt(v)][w];
				
				int v_w_subgraph_bestmetric = 10000;
				int best_w = -1;
				
				// test neighbour on membership
				if (v_w_metric != 0 && !subgraph.contains(w))  {
					
					// test if we find cycles (having one hop only)
					// todo: implement an algo with parametrized search depth
					for (int u=0; u<subgraph.size(); u++){
						
						// get cycle with best metric
						if (link_matrix[w][subgraph.elementAt(u)] != 0 &&
								v_w_subgraph_bestmetric > link_matrix[w][subgraph.elementAt(u)] ) {
							v_w_subgraph_bestmetric = link_matrix[w][subgraph.elementAt(u)];
							best_w = w;
						}
					}
					
					// now, if optimum was found and we still need nodes, then add new (relative) optimal node
					if (best_w != -1 && nodes_left-1>=0) {
						nodes_left--;
						subgraph.add(best_w);
					}
				}
			}
		}
		
	}
	
	private static void fillup_subgraph() {
		for (int u=0; u<subgraph.size(); u++){
			for (int w=0;w<total; w++) {
				if (nodes_left-1>=0 && 
						link_matrix[subgraph.elementAt(u)][w] != 0 && 
						!subgraph.contains(w)) {
					nodes_left--;
					subgraph.add(w);
				}
			}
		}
	}
	
	private static void init_subgraph() {
		// random
		int init_alg = 1;
		int node1=0, node2=0;
		
		switch (init_alg) {
		case 0: // get first two nodes with most links
			for (int i=0;i<total;i++) {
				for (int j=0;j<total;j++) {
					if(link_matrix[i][j] != 0) {
						node2=node1;
						node1=i;
					}
				}
			}
			break;
		case 1: // take this two specific nodes
			node1 = name_table.indexOf("wgt29");
			node2 = name_table.indexOf("wgt201");
			break;
		default: // choose randomly two nodes
			node1 = (int)(Math.random()*(total+1));
			node1 = (int)(Math.random()*(total+1));
			break;
		}
		
		if (node1 > -1 && node2 > -1) {
			subgraph.add(node1);
			subgraph.add(node2);
			nodes_left -= 2;
		} else {
			System.out.println("ERROR: Initial nodes do not exist.");
			System.exit(1);
		}
	}
}

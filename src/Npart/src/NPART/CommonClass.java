/**
 * @author milic bratislav
 * Humboldt University, Berlin
 * milic@informatik.hu-berlin.de
 *
 * 
 */
package NPART;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

//import cern.jet.random.engine.MersenneTwister;
import org.spaceroots.mantissa.random.MersenneTwister;

final class CommonClass {
	static MersenneTwister mt = new MersenneTwister(); //initialization from time

	static StringBuffer networkModel2Dot(NetworkModel nm, Set markNodes, String name) {
		StringBuffer dotOutput=new StringBuffer(10000);
		String res;
		String src, dst, edge;
		String[] strArray;
		Iterator<String> it=nm.getAllLinks().iterator();
		dotOutput.append("graph TopologySample" + name + "{");
		while(it.hasNext()) {
			res="\t\"";
			strArray=it.next().split(" ");
			src=strArray[0];
			dst=strArray[1];

			res+=src;
			res+="\" -- \"";
			res+=dst;
			res+="\" [";

			res+="] \n";

			if(markNodes.contains(src)) res=res+ "\t\"" + src + "\"[style=filled, color=red]\n";
			if(markNodes.contains(dst)) res=res+ "\t\"" + dst + "\"[style=filled, color=red]\n";

			if(src.compareTo(dst)>0)
				dotOutput.append(res); // produce single links.
		}
		dotOutput.append("}");

		return dotOutput;
	}

	static double distance(double x1, double y1,double x2, double y2){
		return Math.sqrt(Math.pow(x1-x2, 2) + Math.pow(y1-y2, 2));
	}

	/**
	 * @param nm - graph description
	 * @param root - root of the graph (important if we want to select which graph component is of interest 
	 * @return set of id-s of articulation points
	 * 
	 * implementation is standard, over DFS
	 */
	public static Set<String> bridgesTwoWay(NetworkModel nm, int root) {
		Node node;
		DNode dn;
		DNode[] allNodes;
		Iterator<Node> nodes=nm.getNodesList().iterator();
		HashSet<Integer> ap=new HashSet<Integer>();
		HashSet<String> bridges=new HashSet<String>();
		int max=0;

		while(nodes.hasNext()) {
			node=nodes.next();
			if(node.getId()>max) max=node.getId();
		}

		allNodes=new DNode[max+1];
		nodes=nm.getNodesList().iterator();

		while(nodes.hasNext()) {
			node=nodes.next();
			dn=new DNode(node.getId(), 0, 0, node);
			allNodes[dn.id]= dn;
		}
		if(allNodes[root]==null) {
			System.out.println("NULL found when working on root: " + root);
			System.out.println("All nodes " + nm.getNodesList());
			System.exit(1);
		}
		allNodes[root].previous=-1;
		dfs(allNodes, root, 0, ap, bridges);

		//System.out.println("bridges: " + bridges);
		//System.out.println("aps: " + ap);

		return bridges;
	}

	/**
	 * @param nm - graph description 
	 * @return set of bridges, two way (each is present twice: a-b and b-a)
	 * 
	 * implementation is standard, over DFS, works on disconnected graphs as well 
	 * (not only on a single connected component like 
	 * Set<String> bridgesTwoWay(NetworkModel, int)
	 */
	public static Set<String> bridgesTwoWay(NetworkModel nm) {
		Node node;
		DNode dn;
		DNode[] allNodes;
		Iterator<Node> nodes=nm.getNodesList().iterator();
		HashSet<Integer> ap=new HashSet<Integer>();
		HashSet<String> bridges=new HashSet<String>();
		int max=0, root=0, i;
		boolean tempBool, unvisitedNodes=true;

		//max=Node.nextId();
		max=nm.getNodesNo();
		if(max==0) return bridges;
		allNodes=new DNode[max];
		nodes=nm.getNodesList().iterator();

		while(nodes.hasNext()) {
			node=nodes.next();
			dn=new DNode(node.getId(), 0, 0, node);
			allNodes[dn.id]= dn;
		}

		while(unvisitedNodes) {
			for(i=0;i<max;i++) {
				if(!allNodes[i].visited) {
					root=i;
					break;
				}
			}
			allNodes[root].previous=-1;
			dfs(allNodes, root, 0, ap, bridges);

			tempBool=true;
			for(i=0;i<max && tempBool;i++) 
				tempBool=tempBool && allNodes[i].visited;
			unvisitedNodes=!tempBool;
		}

		//System.out.println("bridges: " + bridges.size()/2);
		//System.out.println("aps: " + ap.size());

		return bridges;
	}

	public static Set<Integer> articulationPoints(NetworkModel nm) {
		Node node;
		DNode dn;
		DNode[] allNodes;
		Iterator<Node> nodes=nm.getNodesList().iterator();
		HashSet<Integer> ap=new HashSet<Integer>();
		HashSet<String> bridges=new HashSet<String>();
		int max=0, root=0, i;
		boolean tempBool, unvisitedNodes=true;

		//max=Node.nextId();
		max=nm.getNodesNo();
		if(max==0) return ap;

		allNodes=new DNode[max];
		nodes=nm.getNodesList().iterator();

		while(nodes.hasNext()) {
			node=nodes.next();
			dn=new DNode(node.getId(), 0, 0, node);
			allNodes[dn.id]= dn;
		}

		while(unvisitedNodes) {
			for(i=0;i<max;i++) {
				if(!allNodes[i].visited) {root=allNodes[i].id;break;}
			}

			allNodes[root].previous=-1;
			dfs(allNodes, root, 0, ap, bridges);

			tempBool=true;
			for(i=0;i<max && tempBool;i++) 
				tempBool=tempBool && allNodes[i].visited;
			unvisitedNodes=!tempBool;
		}
		//System.out.println("bridges: " + bridges);
		//System.out.println("aps: " + ap);

		return ap;
	}


	public static Set<Integer> articulationPoints(NetworkModel nm, int root) {
		Node node;
		DNode dn;
		DNode[] allNodes;
		Iterator<Node> nodes=nm.getNodesList().iterator();
		HashSet<Integer> ap=new HashSet<Integer>();
		HashSet<String> bridges=new HashSet<String>();
		int max=0;

		while(nodes.hasNext()) {
			node=nodes.next();
			if(node.getId()>max) max=node.getId();
		}

		nodes=nm.getNodesList().iterator();
		allNodes=new DNode[max+1];

		while(nodes.hasNext()) {
			node=nodes.next();
			dn=new DNode(node.getId(), 0, 0, node);
			allNodes[dn.id]= dn;
		}
		allNodes[root].previous=-1;
		dfs(allNodes, root, 0, ap, bridges);

		//System.out.println("bridges: " + bridges);
		//System.out.println("aps: " + ap);

		return ap;
	}

	public static int nodesVisited(NetworkModel nm, int root) {
		Node node;
		DNode dn;
		DNode[] allNodes;
		Iterator<Node> nodes=nm.getNodesList().iterator();
		HashSet<Integer> ap=new HashSet<Integer>();
		HashSet<String> bridges=new HashSet<String>();
		int max=0;

		while(nodes.hasNext()) {
			node=nodes.next();
			if(node.getId()>max) max=node.getId();
		}

		nodes=nm.getNodesList().iterator();
		allNodes=new DNode[max+1];

		while(nodes.hasNext()) {
			node=nodes.next();
			dn=new DNode(node.getId(), 0, 0, node);
			allNodes[dn.id]= dn;
		}
		allNodes[root].previous=-1;
		dfs(allNodes, root, 0, ap, bridges);

		int k=0;
		nodes=nm.getNodesList().iterator();

		while(nodes.hasNext()) {
			if(allNodes[nodes.next().getId()].visited) k++;
		}
		//System.out.println("bridges: " + bridges);
		//System.out.println("aps: " + ap);

		return k;
	}


	private static int dfs(DNode[] allNodes, int curNode, int time, HashSet<Integer> ap, HashSet<String> bridges) {
		Iterator<Node> nodes;
		Node n;
		int i=0, returned=0;

		allNodes[curNode].visited=true; //visit node
		allNodes[curNode].distance=allNodes[curNode].low=++time;

		nodes=allNodes[curNode].n.getNeighbors().iterator();
		while(nodes.hasNext()) {
			n=nodes.next();
			if(!allNodes[n.getId()].visited) {
				allNodes[n.getId()].previous=curNode;

				//System.out.println("Tree edge: " + curNode + " -> " + n.getId());	
				returned=dfs(allNodes, n.getId(), time, ap, bridges);
				if(returned>allNodes[curNode].distance) {
					bridges.add("" + n.getId() + " " + curNode);
					bridges.add("" + curNode + " " + n.getId());
				}
				if(allNodes[curNode].low > allNodes[n.getId()].low) { 
					allNodes[curNode].low=allNodes[n.getId()].low;	
					//System.out.println("node " + curNode + " sets low value to " + allNodes[curNode].low + " because of " + n.getId());

				}

				if(allNodes[curNode].previous==-1) { // root with multiple children
					i++; if(i>=2) ap.add(curNode);
				} else { 
					if(allNodes[n.getId()].low>=allNodes[curNode].distance) {
						ap.add(curNode);
					}
				}
			} else if(n.getId()!=allNodes[curNode].previous) { //(curNode, n) is a back edge
				if(allNodes[curNode].low > allNodes[n.getId()].distance) {
					allNodes[curNode].low=new Double(allNodes[n.getId()].distance).intValue();
					//System.out.println("node " + curNode + " sets low value to " + allNodes[curNode].low + " because of " + n.getId());
				}
			}
		}
		//System.out.println("Curnode: " + curNode + " distance from root: " + new Double(allNodes[curNode ].distance).intValue() + " lowest back edge: " + allNodes[curNode ].low);
		return allNodes[curNode].low;
	}
}


package Visualize;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author milic
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
final class CommonClass {

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

	static NetworkModel parseNs2Topology(final String topologyFile, double radius) {
		String str;
		NetworkModel nm = new NetworkModel();
		Node n=null;
		int coordinate=0; //x, y, z
		double x, y;

		// typical input: $node_(15) set X_ 1044.1347756877788 
		try {
			BufferedReader in = new BufferedReader(new FileReader(topologyFile));
			while ((str = in.readLine()) != null) {
				if(str.contains("flatgrid")) {  // extract topology size
					String[] sizes=str.split(" ");
					nm.setXArea(new Double(sizes[2]));
					nm.setYArea(new Double(sizes[3]));
				}
				if(!str.contains("$node")) continue;
				if(coordinate==0) {
					//System.out.println("Old node: " + n);
					if(n!=null) nm.addNode(n);
					n=new Node(parseNs2Node(str)); //create node
				}
				if(coordinate==0) n.setX(parseNs2Coordinate(str));
				if(coordinate==1) n.setY(parseNs2Coordinate(str));
				coordinate=(coordinate+1)%3;

			}
			in.close();
		} catch (IOException e) {
			System.out.println("ERROR READING INPUT FILE (in first pass)!");
		}
		nm.addNode(n);
		nm.connectivityGraph(radius);
		return nm;
	}
	private static double parseNs2Coordinate(String s) {
		String [] strArray;
		strArray=s.split(" ");
		return new Double(strArray[3]);
	}
	/**
	 * parse string for node id from two sources
	 * one entry is of form (id=15)
	 * $node_(15) set X_ 1044.1347756877788
	 * other of form (id=1)
	 * P 40.000000 _1_ Topology Set 
	 * @param s
	 * @return
	 */
	static int parseNs2Node(String s) {
		String [] strArray;

		if(s.contains("$node")){
			strArray=s.split("\\)");
			strArray=strArray[0].split("\\(");
			return new Integer(strArray[1]);
		} else if(s.contains("P ")) {
			strArray=s.split("\\_");
			return new Integer(strArray[1]);
		} else return -1;
	}

	private static int nextUnmarkedNode(DNode[] nodes) {
		int res=-1;
		for(int i=0;i<nodes.length;i++)
			if(!nodes[i].visited) {
				res=i; break;
			}
		return res;
	}
}


class DNode implements Comparable {
	int id, previous, camefrom, low; 
	double distance;
	Node n;
	boolean visited;
	Object state;

	/**
	 * @param i - id of node
	 * @param p - previous node for Dijkstra, visited/not visited for searches
	 * @param d - distance for Dijkstra, path length for searches
	 * @param n - node to whom we are adding the functionality
	 */
	public DNode(int i, int p, double d, Node n) { 
		id=i; previous=p; distance=d; this.n=n; visited=false;
	}

	public boolean equals(DNode e) {
		return id==e.id;
	}

	public boolean equals(Node e) {
		return id==e.getId();
	}
	public String toString() {return "("+id+", dist=" + distance +")"; }

	public int compareTo(Object o) {
		DNode d=(DNode)o;
		double dist=this.distance - d.distance;
		if(dist<0) return -1;
		else if (dist>0) return 1;
		else return 0;
	}
}


class Pair { 
	public int parrent, node;

	Pair(int s, int d) {parrent=s;node=d;}

	public String toString() { return "("+parrent+" ,"+node+")";}

	public boolean equals(Pair p) {
		return this.parrent==p.parrent && this.node==p.node;
	}
	public int hashCode() { return (new String(""+parrent+""+node).hashCode()); }
}
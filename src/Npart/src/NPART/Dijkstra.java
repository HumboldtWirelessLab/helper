/**
 * @author milic bratislav
 * Humboldt University, Berlin
 * milic@informatik.hu-berlin.de
 * 
 */

package NPART;

import java.sql.SQLException;
import java.util.Collection;
import java.util.HashSet;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Set;

class DijkstraHOP {

	private DNode[] allNodes;
	private int src;
	private Set bridgeSet;
	private float pathETX;
	private boolean pathWithBridge;
	private int hops;


	public DijkstraHOP(NetworkModel nm, int source) {
		LinkedList S, Q;

		S=new LinkedList();
		Q=new LinkedList();

		Node node, v; //, src, dst;
		DNode dn, u , tmp;
		allNodes=new DNode[nm.getNodesNo()];
		Set neighbors;
		Iterator itNodes=nm.getNodesList().iterator();

		this.src=source;

		//create DNodes, predecessor set to -1, distance set to "infinity", except for source which has dest==0
		while(itNodes.hasNext()) {
			node=(Node)itNodes.next();
			dn=new DNode(node.getId(), -1, nm.getNodesNo()*100000.0, node);
			if(source==dn.id) {dn.distance=0; }
			Q.add(dn);
			try{
				allNodes[dn.id]= dn;
			} catch (Exception e) {System.out.println(e.toString() + "\n ID: " + dn.id);}
		}


		while(Q.size()!=0) {
			java.util.Collections.sort(Q);
//			System.out.println(Q);
			u=(DNode)Q.removeFirst();
//			S.add(u);
//			System.out.println("Node taken: " + u);
			neighbors=u.n.getNeighbors();
			itNodes=neighbors.iterator();
			while(itNodes.hasNext()) {
				v=(Node)itNodes.next(); 
				tmp=allNodes[v.getId()];
				if(tmp.distance > u.distance + 1) {
					tmp.distance= u.distance + 1;
					tmp.previous=u.id;
				}
			}
		}

		this.bridgeSet=CommonClass.bridgesTwoWay(nm);
	}


	/**
	 * calculate the shortest path between source (defined in constructor) and destination 
	 * if it traverses a bridge set the appropriate value
	 * this method is pure mutex: it changes the state of the object 
	 * it returns boolean whether there is path between 2 nodes
	 */
	public boolean pathTo(int destination) {
		Node dst=allNodes[destination].n;
		Node src=allNodes[this.src].n;
		int id, hops=0;
		DNode tmp;
		float totalETX=0;
		float totalProb=1;
		boolean pathContainsBridge=false; 
		// to check whether the bridge condition is satisfied. 

		String searchString;

		id=dst.getId();
		tmp=allNodes[id];
		if(tmp.previous==-1) {return false;} // there is no path between source and destination, network is partitioned

		while(id!=src.getId()) {
			hops++;
			//System.out.println(" " + tmp.id + " -> " + tmp.previous + " : " + tmp.n.getETX(allNodes[tmp.previous].n));
			searchString="" + tmp.id + " " + tmp.previous;
			if(this.bridgeSet.contains(searchString)) pathContainsBridge=true;

			totalETX+=tmp.n.getETX(allNodes[tmp.previous].n);
			totalProb*=1/tmp.n.getETX(allNodes[tmp.previous].n);

			tmp=(DNode)allNodes[tmp.previous];
			id=tmp.id;
		}

		this.hops=hops;
		this.pathETX=totalETX;
		this.pathWithBridge=pathContainsBridge;
		return true;

	}


	public int[] wholePathTo(int destination) {
		Node dst=allNodes[destination].n;
		Node src=allNodes[this.src].n;
		int id, hops=0, i=0;
		DNode tmp;
		int[] consistsOf=new int[allNodes.length];
		id=dst.getId();
		tmp=allNodes[id];
		if(tmp.previous==-1) {return null;} // there is no path between source and destination, network is partitioned

		//System.out.println("source " + src.getId() + " to " + destination );

		consistsOf[i++]=destination;
		while(id!=src.getId()) {
			hops++;
			//System.out.println(" " + tmp.id + " -> " + tmp.previous );
			tmp=(DNode)allNodes[tmp.previous];
			id=tmp.id;
			consistsOf[i++]=tmp.id;
		}

		this.hops=hops;
		//System.out.println("hops " + hops);
		return consistsOf;

	}

	public static void DijkstraPath(NetworkModel nm, int source, int destination) {
		LinkedList S, Q;

		S=new LinkedList();
		Q=new LinkedList();

		Iterator itNodes=nm.getNodesList().iterator();
		Node node, v, src, dst;
		DNode dn, u , tmp;
		DNode[] allNodes=new DNode[nm.getNodesNo()];
		int id;
		Set neighbors;

		while(itNodes.hasNext()) {
			node=(Node)itNodes.next();
			dn=new DNode(node.getId(), -1, nm.getXArea()*10000, node);
			if(source==dn.id) {dn.distance=0; }
			//orderedInsert(Q, dn);
			Q.add(dn);
			try{
				allNodes[dn.id]= dn;
			} catch (Exception e) {System.out.println(e.toString() + "\n ID: " + dn.id);}
		}

		java.util.Collections.sort(Q);

		src=allNodes[source].n;
		dst=allNodes[destination].n;

		while(Q.size()!=0) {
			java.util.Collections.sort(Q);
//			System.out.println(Q);
			u=(DNode)Q.removeFirst();
			S.add(u);
//			System.out.println("Node taken: " + u);
			neighbors=u.n.getNeighbors();
			itNodes=neighbors.iterator();
			while(itNodes.hasNext()) {
				v=(Node)itNodes.next(); 
				tmp=allNodes[v.getId()];
				/*				if(tmp.distance>u.distance+v.distanceTo(u.n)) {
				 tmp.distance= u.distance+v.distanceTo(u.n);
				 tmp.previous=u.id;
				 }*/
				if(tmp.distance>u.distance+1) {
					tmp.distance= u.distance+1;
					tmp.previous=u.id;
				}
			}
		}


//		System.out.println("From" + src.getId() + " To: " + dst.getId());

		id=dst.getId();
		tmp=allNodes[id];
		while(id!=src.getId()) {
			System.out.println(" " + tmp.n.getX() + " " + tmp.n.getY());
			tmp=(DNode)allNodes[tmp.previous];
			id=tmp.id;
		}
		System.out.println(" " + tmp.n.getX() + " " + tmp.n.getY());
	}


	public float getPathETX() {
		return pathETX;
	}


	public boolean isPathWithBridge() {
		return pathWithBridge;
	}


	public int getHops() {
		return hops;
	}
	
	static HashMap<Integer, Integer> statistics;
	
	static {statistics=new HashMap<Integer, Integer>(1000);}
	
	public static void pathStats(NetworkModel nm) {
		int n=nm.getNodesNo();
		int[] nodes=new int[n];
		int [] temp;
		int diam=0;
		for(int i=0; i<n;i++) {
			DijkstraHOP dh=new DijkstraHOP(nm, i);
			for(int j=i;j<n;j++) {
				temp=dh.wholePathTo(j);
				if(temp==null) continue;
				if(dh.hops==0) continue;
				if(dh.hops>diam) diam=dh.hops; //update diameter
				for(int k=0;k<=dh.hops;k++) {
					//System.out.print(temp[k] + " ");
					nodes[temp[k]]++;
				}
			}
		}
		
		for(int k=0;k<n;k++) {
			//System.out.println(nodes[k]);
			Integer t=statistics.remove(nodes[k]);
			int tt;
			if(t==null) tt=0; else tt=t;
			statistics.put(new Integer(nodes[k]), new Integer(tt+1));
		}

		System.out.println("diameter: " + diam);
	}

	public static int graphDiameter(NetworkModel nm) {
		int n=nm.getNodesNo();
		int [] temp;
		int diam=0;
		for(int i=0; i<n;i++) {
			DijkstraHOP dh=new DijkstraHOP(nm, i);
			for(int j=i;j<n;j++) {
				temp=dh.wholePathTo(j);
				if(temp==null) continue;
				if(dh.hops==0) continue;
				if(dh.hops>diam) diam=dh.hops; //update diameter
			}
		}
		
		return diam;
	}

	
	public static void printStats() {
		Iterator<Integer> it=statistics.keySet().iterator();
		while(it.hasNext()) {
			int i=it.next();
			System.out.println("" + i + " " + statistics.get(i));
		}
		statistics=new HashMap<Integer, Integer>(1000); //reset it after printing
	}
	
	public static void main2(String[] args) {
		NetworkModel nm=new NetworkModel();
		double[] propsLeft=new double[3];
		double[] propsRight=new double[3];
		
		propsLeft[0]=0.1;propsLeft[1]=0.99;propsLeft[2]=100;
		propsRight[0]=0.99;propsRight[1]=0.1;propsRight[2]=1.33; //assymetric links test

		Node n1=new Node(), n2=new Node(), n3=new Node(), n4=new Node();

		nm.addNode(n1);nm.addNode(n2);nm.addNode(n3);nm.addNode(n4);

		n1.createLink(n2, propsLeft);
		n2.createLink(n3, propsLeft);
		n2.createLink(n1, propsRight);
		n3.createLink(n2, propsRight);
		n3.createLink(n4, propsRight);
		n4.createLink(n3, propsRight);

		pathStats(nm);
		pathStats(nm);
		printStats();
		/*DijkstraHOP dh=new DijkstraHOP(nm, 0);
		int[] path=dh.wholePathTo(3);
		for(int i=0;i<path.length;i++) System.out.println(path[i]);*/

	}
}


class DijkstraETX {

	private DNode[] allNodes;
	private int src;
	private Set bridgeSet;
	private float pathETX;
	private boolean pathWithBridge;
	private int hops;


	public DijkstraETX(NetworkModel nm, int source) {
		LinkedList S, Q;

		S=new LinkedList();
		Q=new LinkedList();

		Node node, v, src, dst;
		DNode dn, u , tmp;
		allNodes=new DNode[nm.getNodesNo()];
		int id;
		Set neighbors;
		Iterator itNodes=nm.getNodesList().iterator();

		this.src=source;

		//create DNodes, predecessor set to -1, distance set to "infinity", except for source which has dest==0
		while(itNodes.hasNext()) {
			node=(Node)itNodes.next();
			dn=new DNode(node.getId(), -1, nm.getNodesNo()*100000.0, node);
			if(source==dn.id) {dn.distance=0; }
			//orderedInsert(Q, dn);
			Q.add(dn);
			try{
				allNodes[dn.id]= dn;
			} catch (Exception e) {System.out.println(e.toString() + "\n ID: " + dn.id);}
		}


		while(Q.size()!=0) {
			java.util.Collections.sort(Q);
//			System.out.println(Q);
			u=(DNode)Q.removeFirst();
//			S.add(u);
//			System.out.println("Node taken: " + u);
			neighbors=u.n.getNeighbors();
			itNodes=neighbors.iterator();
			while(itNodes.hasNext()) {
				v=(Node)itNodes.next(); 
				tmp=allNodes[v.getId()];
				if(tmp.distance > u.distance + v.getETX(u.n)) {
					tmp.distance= u.distance + v.getETX(u.n);
					tmp.previous=u.id;
				}
			}
		}

		graphCycles gc=new graphCycles(nm);
		this.bridgeSet=gc.bridgeSetTwoWay();

	}


	/**
	 * calculate the shortest path between source (defined in constructor) and destination 
	 * if it traverses a bridge set the appropriate value
	 * this method is pure mutex: it changes the state of the object without returning anything
	 */
	public void pathTo(int destination) {
		Node dst=allNodes[destination].n;
		Node src=allNodes[this.src].n;
		int id, hops=0;
		DNode tmp;
		float totalETX=0;
		double totalProb=1;
		boolean pathContainsBridge=false; 
		// to check whether the bridge condition is satisfied. 

		String searchString;

		id=dst.getId();
		tmp=allNodes[id];
		if(tmp.previous==-1) return; // there is no path between source and destination, network is partitioned

		while(id!=src.getId()) {
			hops++;
			//System.out.println(" " + tmp.id + " -> " + tmp.previous + " : " + tmp.n.getETX(allNodes[tmp.previous].n));
			searchString="" + tmp.id + " " + tmp.previous;
			if(this.bridgeSet.contains(searchString)) pathContainsBridge=true;

			totalETX+=tmp.n.getETX(allNodes[tmp.previous].n);
			totalProb*=1/tmp.n.getETX(allNodes[tmp.previous].n);

			tmp=(DNode)allNodes[tmp.previous];
			id=tmp.id;
		}

		this.hops=hops;
		this.pathETX=totalETX;
		this.pathWithBridge=pathContainsBridge;

	}


	public static void DijkstraPath(NetworkModel nm, int source, int destination) {
		LinkedList S, Q;

		S=new LinkedList();
		Q=new LinkedList();

		Iterator itNodes=nm.getNodesList().iterator();
		Node node, v, src, dst;
		DNode dn, u , tmp;
		DNode[] allNodes=new DNode[nm.getNodesNo()];
		int id;
		Set neighbors;

		while(itNodes.hasNext()) {
			node=(Node)itNodes.next();
			dn=new DNode(node.getId(), -1, nm.getXArea()*10000, node);
			if(source==dn.id) {dn.distance=0; }
			//orderedInsert(Q, dn);
			Q.add(dn);
			try{
				allNodes[dn.id]= dn;
			} catch (Exception e) {System.out.println(e.toString() + "\n ID: " + dn.id);}
		}

		java.util.Collections.sort(Q);

		src=allNodes[source].n;
		dst=allNodes[destination].n;

		while(Q.size()!=0) {
			java.util.Collections.sort(Q);
//			System.out.println(Q);
			u=(DNode)Q.removeFirst();
			S.add(u);
//			System.out.println("Node taken: " + u);
			neighbors=u.n.getNeighbors();
			itNodes=neighbors.iterator();
			while(itNodes.hasNext()) {
				v=(Node)itNodes.next(); 
				tmp=allNodes[v.getId()];
				/*				if(tmp.distance>u.distance+v.distanceTo(u.n)) {
				 tmp.distance= u.distance+v.distanceTo(u.n);
				 tmp.previous=u.id;
				 }*/
				if(tmp.distance>u.distance+1) {
					tmp.distance= u.distance+1;
					tmp.previous=u.id;
				}
			}
		}


//		System.out.println("From" + src.getId() + " To: " + dst.getId());

		id=dst.getId();
		tmp=allNodes[id];
		while(id!=src.getId()) {
			System.out.println(" " + tmp.n.getX() + " " + tmp.n.getY());
			tmp=(DNode)allNodes[tmp.previous];
			id=tmp.id;
		}
		System.out.println(" " + tmp.n.getX() + " " + tmp.n.getY());
	}


	public float getPathETX() {
		return pathETX;
	}


	public boolean isPathWithBridge() {
		return pathWithBridge;
	}


	public int getHops() {
		return hops;
	}
}

/**
 * @author milic
 *
 */
class graphCycles {
	private DNode[] allNodes;

	public graphCycles(NetworkModel nm) {
		Node node;
		DNode dn;
		Iterator itNodes=nm.getNodesList().iterator();

		allNodes=new DNode[nm.getNodesNo()];

		while(itNodes.hasNext()) {
			node=(Node)itNodes.next();
			dn=new DNode(node.getId(), 0, 0, node);
			try{
				allNodes[dn.id]= dn;
			} catch (Exception e) {System.out.println(e.toString() + "\n ID: " + dn.id);}
		}
	}

	public graphCycles(Collection c) {
		Node node;
		DNode dn;
		Iterator itNodes=c.iterator();

		allNodes=new DNode[c.size()];

		while(itNodes.hasNext()) {
			node=(Node)itNodes.next();
			dn=new DNode(node.getId(), 0, 0, node);
			try{
				allNodes[dn.id]= dn;
			} catch (Exception e) {System.out.println(e.toString() + "\n ID: " + dn.id);}
		}
	}

	public void clearMarkings() {
		for(int i=0; i<allNodes.length; i++) {
			if(allNodes[i]==null) continue;
			allNodes[i].distance=0; allNodes[i].previous=0;
		}
	}

	public void allCycles (String type) {
		int i, j;
		Iterator itNeighbors;
		Node n;
		DNode current;

		for(i=0; i<allNodes.length; i++) { //traverse all nodes
			current=(DNode)allNodes[i];
			itNeighbors=current.n.getNeighbors().iterator();
			while(itNeighbors.hasNext()) {
				n=(Node)itNeighbors.next();
				if(current.id>n.getId()) { //to visit all edges only once
					if(type.equalsIgnoreCase("bridgeQuality")) // print quality of bridges 
						if (this.shortestCycle(current.id, n.getId())== -1) //it is a bridge
							System.out.println(current.n.getETX(n));

					if(type.equalsIgnoreCase("noBridgeQuality"))  // print quality (etx) of non-bridges
						if (this.shortestCycle(current.id, n.getId())!= -1) //it isn't a bridge
							System.out.println(current.n.getETX(n));

					if(type.equalsIgnoreCase("cycles")) // print shortest cycle sizes 
						System.out.println(this.shortestCycle(current.id, n.getId())); //it is a bridge
				}
			}
		}

	}

	/*
	 * for bridge connecting noded 2 and 9 it returns two-way set: "2 9" and "9 2"
	 */
	public Set bridgeSetTwoWay() {
		int i, j;
		Iterator itNeighbors;
		Node n;
		DNode current;
		HashSet s=new HashSet();

		for(i=0; i<allNodes.length; i++) { //traverse all nodes
			current=(DNode)allNodes[i];
			itNeighbors=current.n.getNeighbors().iterator();
			while(itNeighbors.hasNext()) {
				n=(Node)itNeighbors.next();
				if(current.id>n.getId()) { //to visit all edges only once
					if(this.shortestCycle(current.id, n.getId())==-1) {
						s.add(new String("" + current.id + " " + n.getId()));
						s.add(new String("" + n.getId() + " " + current.id)); // two way connection
					}
				}
			}
		}
		return s;
	}

	/*
	 * for bridge connecting nodes 2 and 9 it returns one-way set: "2 9" or "9 2"
	 * it is not defined in which order
	 */
	public Set bridgeSetOneWay() {
		int i, j;
		Iterator itNeighbors;
		Node n;
		DNode current;
		HashSet s=new HashSet();

		for(i=0; i<allNodes.length; i++) { //traverse all nodes
			current=(DNode)allNodes[i];
			itNeighbors=current.n.getNeighbors().iterator();
			while(itNeighbors.hasNext()) {
				n=(Node)itNeighbors.next();
				if(current.id>n.getId()) { //to visit all edges only once
					if(this.shortestCycle(current.id, n.getId())==-1) {
						s.add(new String("" + current.id + " " + n.getId()));
					}
				}
			}
		}
		return s;
	}

	/**
	 * @param source - one side of the tested edge
	 * @param destination - other side of the tested edge
	 * @return the length of the cycle between the two, if none, returns negative value (-1 typically)
	 */
	public int shortestCycle(int source, int destination) {
		DNode temp, current, src, dst;
		current=allNodes[source];
		LinkedList ll=new LinkedList();
		Iterator itNeighbors;
		boolean searchInProgress=true;
		double distance=-1; //distance over cycle in number of hops
		double lp[]=new double[3];

		src=allNodes[source];
		dst=allNodes[destination];
		
		lp[0]=src.n.getLQ(dst.n);
		lp[1]=src.n.getILQ(dst.n);
		lp[2]=src.n.getETX(dst.n);
		
		src.n.breakLink(dst.n);
		dst.n.breakLink(src.n); // remove the checked link from connectivity graph

		ll.addFirst(current);
		while(ll.size()>0 && searchInProgress) {
			current=(DNode)(ll.removeFirst());
			current.previous=1; //visited
			itNeighbors=current.n.getNeighbors().iterator();
			//System.out.println("Current: " + current.id);
			while(itNeighbors.hasNext()) {

				temp=allNodes[((Node)(itNeighbors.next())).getId()];
				if(temp.id==destination) {
					searchInProgress=false;
					distance=current.distance+1;
					break; //if the destination node is found, break the search
				}
				if(temp.previous==0) {
					temp.previous=1;
					temp.distance=current.distance+1;
					//System.out.println("Current: " + current.id + " adds node: " + temp.id);
					ll.addLast(temp);
				}

			}
		}
		src.n.createLink(dst.n, lp);
		double tmp;
		tmp=lp[0];
		lp[0]=lp[1];
		lp[1]=tmp;
		dst.n.createLink(src.n, lp);
		this.clearMarkings();
		return new Double(distance).intValue();
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
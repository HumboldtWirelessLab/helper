/**
 * @author milic bratislav
 * Humboldt University, Berlin
 * milic@informatik.hu-berlin.de
 *
 * 
 */

package NPART;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

class LinkStats {
	public double lq, ilq, etx;
	public LinkStats(double a, double b, double c) {
		lq=a; ilq=b; etx=c;
	}
	public LinkStats(double[] a) {
		lq=a[0]; ilq=a[1]; etx=a[2];
		//System.out.println("New link stats: " + lq + ", " + ilq+ ", "+etx);
	}

	public LinkStats(LinkStats ls) {
		lq=ls.lq; ilq=ls.ilq; etx=ls.etx;
		//System.out.println("New link stats: " + lq + ", " + ilq+ ", "+etx);
	}

	public String toString() {
		return "Link stats: " + lq + ", " + ilq+ ", "+etx;
	}

}

public class Node implements Cloneable{

	private static int freeId = 0;    
	//private static boolean flat=true;


	private final static double defaultLinkQuality=0.5;
	/**
	 * control assignments of identifications to nodes
	 * at the moment it is just incrementing sequence
	 * @return new free ID
	 */
	private static int newId(){
		return freeId++;
	}
	public static int nextId() {return freeId;}

	static void resetId() { freeId=0;}
	private int id;
	private Set neighbors=new HashSet();
	private Object state;

	private HashMap<Integer, LinkStats> linkStates=new HashMap<Integer, LinkStats>(10);
	private double x;
	private double y;

	/**
	 * Inits the location for the node
	 * @param xx 
	 * @param yy 
	 */

	public Node() {x=y=0; id=newId();}

	public Node(double xx, double yy) {
		x=xx;
		y=yy;
		id=newId();
	}

	public Node(Node n) { 
		id=n.id; 
		x=n.x; y=n.y;
	} 
	//for cases where we need to have two "same" nodes but different instances
	//Essentially for subgraph manipulations

	public Node(String ip, int nodeId) {
		state=ip;
		id=nodeId;
	}

	public void breakAllLinks() {
		neighbors.clear();
		linkStates.clear();
	}

	public void breakLink(Node n) {
		linkStates.remove(n.getId());
		neighbors.remove(n);
	}

	public Object clone() {
		Object o = null;
		try {
			o = super.clone();
		} catch(CloneNotSupportedException e) {
			System.err.println("MyObject can't clone");
		}
		return o;
	}

	/**
	 * Method creates unidirected link to Node n
	 * @param n - create link from this to Node n
	 */
	public void createLink(Node n) {
		if(!neighbors.contains(n)) { // it is not permitted to add multiple edges between vertices
			neighbors.add(n);
			LinkStats l=new LinkStats(defaultLinkQuality,defaultLinkQuality,1/(defaultLinkQuality*defaultLinkQuality)); //ideal link
			linkStates.put(n.getId(), l);   		
			//System.out.println("Link from: " + this + " to: " + n);
		}
	}

	public void createLink(Node n, double etx) {
		if(!neighbors.contains(n)) { // it is not permited to add multiple edges between vertices
			neighbors.add(n);
			LinkStats l=new LinkStats(-1,-1,etx); // ilegal values for ILQ and LQ to be clear that they are not valid
			linkStates.put(new Integer(n.getId()), l);
			//System.out.println("Link from: " + this + " to: " + n);
		}
	}

	public void createLink(Node n, double[] linkProperties) {
		if(!neighbors.contains(n)) { // it is not permited to add multiple edges between vertices
			neighbors.add(n);
			LinkStats l=new LinkStats(linkProperties);
			linkStates.put(new Integer(n.getId()), l);
			//System.out.println("Link from: " + this + " to: " + n);
		} else System.out.println("Trying to create duplicate link. Ignored.");
	}


	public void createLink(Node n, LinkStats ls) {
		if(!neighbors.contains(n) && !linkStates.containsKey(n.getId())) { // it is not permited to add multiple edges between vertices
			neighbors.add(n);
			LinkStats l=new LinkStats(ls);
			linkStates.put(new Integer(n.getId()), l);
			//System.out.println("Link from: " + this + " to: " + n);
		} else System.out.println("Trying to create duplicate link. Ignored.");
	}

	public int degree() {return neighbors.size();}

	public double distanceTo(Node n) {
		return Math.sqrt(Math.pow(n.x-x,2)+Math.pow(n.y-y,2));
	}

	public boolean equals(Node n){
		return id==n.id;
	}

	public double getETX(Node n) {
		return (linkStates.get(n.getId())).etx;
	}

	/**
	 * @return Returns the id.
	 */
	public int getId() {
		return id;
	}

	public double getILQ(Node n) {
		return ((LinkStats)linkStates.get(n.getId())).ilq;
	}

	public LinkStats getLinkStats(Node n) {
		return (LinkStats)linkStates.get(n.getId());
	}

	public double getLQ(Node n) {
		return (linkStates.get(n.getId())).lq;
	}

	public Iterator getNeighborIterator() {
		return neighbors.iterator();
	}

	public Set getNeighbors() {
		return (Set)((HashSet)neighbors).clone();
	}

	public Object getState(){return state;}


	/**
	 * @return Returns the x.
	 */
	double getX() {
		return x;
	}

	/**
	 * @return Returns the y.
	 */
	double getY() {
		return y;
	}


	/* (non-Javadoc)
	 * @see java.lang.Object#hashCode()
	 */
	public int hashCode() {
		// TODO Auto-generated method stub
		return this.id;
	}

	/**
	 * Tests whether the current node and the Node n are in range. 
	 * Deterministic, radius based solution. (Geometrical graph with fixed threshold). Links are perfect.
	 * To speed it up, Hemming distance is calculated at first to give rough estimation of current distance
	 * @param radius 
	 * @param n Node
	 * @return 
	 */
	boolean inRange(double radius, Node n) {
		boolean inRng=false;
		double xDif=Math.abs(x-n.x);
		double yDif;
		double distance;

		neighbors.remove(n);
		n.neighbors.remove(this);

		yDif=Math.abs(y-n.y);
		distance=xDif+yDif;

		if (distance<2*radius)
			if (distanceTo(n)<radius) {inRng=true; this.createLink(n); n.createLink(this);}
		return inRng;
	}


	public String neighborList() {
		String res=this.toString();
		Node n;
		Iterator<Node> it=neighbors.iterator();
		while(it.hasNext()) {
			n=it.next();
			res=res+" " + n + " link " + n.getLQ(this) + ".";
		}
		return res;
		//return "Neighbors:\n" + neighbors.toString();
	}

	public void newPolarPosition(double radius, double angleFi) {
		x=Math.cos(angleFi)*radius;
		y=Math.sin(angleFi)*radius;
	}

	public void newPolarPosition(double radius, double angleFi, double angleTheta){
		System.out.println("not implemented yet");
	}

	public void newPosition(double xx, double yy, double zz) {
		x=xx;
		y=yy;        
	}

	public void scaleLinkQuality(Node n, double scale){
		LinkStats ls=linkStates.get(n.getId());
		//System.out.println("degrading quality of link "+this.id + "->" + n.id);
		ls.ilq=ls.ilq*scale;
		ls.lq=ls.lq*scale;
		ls.etx=1/(ls.lq*ls.ilq);
	}
	public void setState(Object s) {state=s;}

	public String toString() {
		return "Node ID=" + id + linkStates + " state: " + state  +" Coordinates: x="+x + " y="+y ;
	}
}

/**
 * @author milic bratislav
 * Humboldt University, Berlin
 * milic@informatik.hu-berlin.de
 *
 * 
 */

package NPART;

import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Set;
import java.util.List;

public class NetworkModel {
	final protected static double defaultAlpha=2; // default chanel attenuation

	private static double minSpeed, maxSpeed, pauseTime, duration, gridEdge, tr;
	private static int horizontal, vertical, k;

	private static boolean ppp=false;
	private static boolean rwm=false;   
	private static boolean uniform=true;
	private static boolean gaussian=false;
	private static boolean grid=false;


	public static void setGaussian() { uniform=false; ppp=false; gaussian=true;rwm=false;grid=false;}
	public static void setPPP() { uniform=false; ppp=true;gaussian=false;rwm=false;grid=false;}
	public static void setUniform(){ uniform=true; ppp=false;gaussian=false;rwm=false;grid=false;}
	public static void setRWM(double minS, double maxS, double pauseT, double durat) { 
		uniform=false; ppp=false;gaussian=false;rwm=true;
		minSpeed=minS;
		maxSpeed=maxS;
		pauseTime=pauseT;
		duration=durat;
	}

	public static void setGrid(double gridE, int h, int v) {
		uniform=false;ppp=false;gaussian=false;rwm=false;grid=true;
		gridEdge=gridE;
		horizontal=h;
		vertical=v;
	}

	private double communicationRadius;

	private int eliminated=0; 

	HashMap<Integer, Node> allNodes;
	//private int totalLinks;

	private double xArea, yArea;

	// do not create/calculate network/graph but pre-set it from existing graph/collection
	// if nodes have links they are captured here as well
	public NetworkModel(Collection c) {
		xArea=0; yArea=0; 
		communicationRadius=0;
		Node n;

		allNodes=new HashMap<Integer, Node>(c.size(),1);

		Iterator it=c.iterator();
		while(it.hasNext()) {
			n=(Node)it.next();
			allNodes.put(n.getId(),n); //add all nodes from the collection
		}
	}

	//two dimension case
	public NetworkModel(double xxA, double yyA, int nodes, double r) {
		xArea=xxA; yArea=yyA;
		communicationRadius=r;
		if(grid) nodes=horizontal*vertical;
		allNodes=new HashMap(nodes,1);
		placeNodes(nodes);
	} 

	// empty net model
	public NetworkModel() {
		allNodes=new HashMap();
	} 

	public NetworkModel addNode(Node n) {
		allNodes.put(n.getId(),n);
		return this;
	}

	public double avgDegree() {
		double sum=0;
		Iterator it=allNodes.values().iterator();
		Node n;
		while(it.hasNext()) {
			n=(Node)it.next();
			sum+=n.degree();
		}
		return sum/allNodes.size();
	} 

	public void connectivityGraph(double alpha, double sigma) { //make all the connections in the graph
		HashSet temp=new HashSet(allNodes.values());
		Iterator outer=allNodes.values().iterator();
		Iterator inner;
		Node outNode, inNode; //outer and inner loop

		while(outer.hasNext()){
			outNode=(Node)outer.next(); //take nodes (all) sequentialy)
			temp.remove(outNode); //remove the current from the temp list
			inner=temp.iterator(); 
			while(inner.hasNext()){ //pairwise comparison
				inNode=(Node)inner.next();
				//System.out.println("inner: " + inNode.getId() + " outer: " + outNode.getId());
				outNode.inRange(communicationRadius,inNode); // create link only once for each pair
			}
		}
	} 

	/**
	 * @return 
	 */
	public void createGG() {
		//HashSet newList=(HashSet)allNodes.clone();
		Iterator itListOfNodes=allNodes.values().iterator();
		Node current, curNeighbor, middleNode, possibleWitness;  
		boolean flag;
		double x1, x2, y1, y2, a, b, mx, my, gabrielDistance;
		Iterator neighbors, possibleEliminationList;

		while(itListOfNodes.hasNext()) {
			current=(Node)itListOfNodes.next();

			neighbors=current.getNeighbors().iterator(); //all neighbors

			x1=current.getX();
			y1=current.getY(); //coordinates for x

			while(neighbors.hasNext()) {
				possibleEliminationList=current.getNeighbors().iterator(); // possible witnesses            	

				flag=true; // is the observed edge eliminated already (negation)            	
				curNeighbor=(Node)neighbors.next();  // take a neighbor

				x2=curNeighbor.getX();
				y2=curNeighbor.getY();
				a=(y1-y2)/(x1-x2);
				b=y2- x2*a;
				mx=(x1+x2)/2;
				my=a*mx+b;

				middleNode=new Node(mx, my); //create a node in the middle

				gabrielDistance=current.distanceTo(curNeighbor)/2.0;

				while(flag && (possibleEliminationList.hasNext()) ) { //see whether there are witnesses
					possibleWitness=(Node)possibleEliminationList.next();
					if( (!possibleWitness.equals(curNeighbor)) && (middleNode.distanceTo(possibleWitness)<gabrielDistance) ) {
						current.breakLink(curNeighbor);
						curNeighbor.breakLink(current);
						flag=false;
						eliminated++;
					}
				}

			}

		}
		//System.out.println(edgesToDelete);
		//return newList;
	}     

	public Collection createPartitions() {
		LinkedList freeNodes=new LinkedList(allNodes.values());
		LinkedList partitionList=new LinkedList(); 
		Partition curPart;

		while(freeNodes.size()>0) {
			curPart=new Partition((Node)freeNodes.removeFirst());
			partitionList.add(curPart);
			freeNodes.removeAll(curPart.partitionMembers());

		}

		return partitionList;
	}

	public Collection createRNG() {
		HashSet newList=(HashSet)allNodes.clone();
		Iterator itListOfNodes=allNodes.values().iterator();
		Node current, curNeighbor, possibleWitness;  
		boolean flag;
		double maxDist, dist1, dist2, gabrielDistance;
		Iterator neighbors, possibleEliminationList;

		while(itListOfNodes.hasNext()) {
			current=(Node)itListOfNodes.next();

			neighbors=current.getNeighbors().iterator(); //all neighbors

			while(neighbors.hasNext()) {
				possibleEliminationList=current.getNeighbors().iterator(); // possible witnesses            	

				flag=true; // is the observed edge eliminated already (negation)            	
				curNeighbor=(Node)neighbors.next();  // take a neighbor

				gabrielDistance=current.distanceTo(curNeighbor);

				while(flag && (possibleEliminationList.hasNext()) ) { //see whether there are witnesses
					possibleWitness=(Node)possibleEliminationList.next();
					dist1=current.distanceTo(possibleWitness);
					dist2=curNeighbor.distanceTo(possibleWitness);
					if(dist1>dist2) maxDist=dist1; else maxDist=dist2;
					if( (!possibleWitness.equals(curNeighbor)) && gabrielDistance>maxDist ) {
						current.breakLink(curNeighbor);
						curNeighbor.breakLink(current);
						flag=false;
						eliminated++;
					}
				}
			}
		}
		return newList;
	}

	/**
	 * @return Returns the communicationRadius.
	 */
	public double getCommunicationRadius() {
		return communicationRadius;
	}

	public int getEliminated() {return eliminated;}

	public Collection getNodesList() {
		return allNodes.values();
	}
	/**
	 * @return Returns the nodesNo.
	 */
	public int getNodesNo() {
		return allNodes.size();
	}

	public int getLinkCount() {
		int totalLinks=0;
		LinkedList nodesList=new LinkedList(allNodes.values());
		Node n;

		while(nodesList.size()>0) {
			n=(Node)nodesList.removeFirst();
			totalLinks+=n.getNeighbors().size();
		}
		return totalLinks/2;
	}

	public Set getAllLinks() {
		HashSet links=new HashSet();
		Node n;
		Iterator<Node> nodes, neighbors;

		nodes=this.allNodes.values().iterator();
		while(nodes.hasNext()) {
			n=nodes.next();
			neighbors=n.getNeighborIterator();
			while(neighbors.hasNext()) {
				links.add("" + n.getId() + " " + neighbors.next().getId());
			}
		}
		return links;
	}

	public HashMap getAllLinksStats() {
		HashMap<String, double[]> links=new HashMap<String, double[]>();
		Node n, loopN;
		Iterator<Node> nodes, neighbors;
		String linkName;
		double[] values=new double[3];

		nodes=this.allNodes.values().iterator();
		while(nodes.hasNext()) {
			n=nodes.next();
			neighbors=n.getNeighborIterator();
			while(neighbors.hasNext()) {
				loopN=neighbors.next();
				if(loopN.getId()>n.getId()) continue; // list it only once
				linkName="" + n.getId() + " " + loopN.getId();
				values=new double[3];
				values[0]=n.getLQ(loopN);
				values[1]=n.getILQ(loopN);
				values[2]=n.getETX(loopN);
				links.put(linkName, values);
			}
		}
		return links;
	}

	/**
	 * @return Returns the xArea.
	 */
	double getXArea() {
		return xArea;
	}
	/**
	 * @return Returns the yArea.
	 */
	double getYArea() {
		return yArea;
	}

	private void placeNodes(int nodesNo) {
		if(uniform && !ppp) {placeNodes2Duniform(nodesNo);return;}
		else if(!uniform && ppp) {placeNodes2Dppp(nodesNo); return;}
		else if (!uniform && !ppp & gaussian) {placeNodes2Dgaussian(nodesNo); return;}
		if(rwm) {placeNodesRWM(nodesNo); return;}
		if(grid) {placeNodesGrid(nodesNo); return;}
	}

	private void placeNodes2Dgaussian(int nodesNo){ 
		// radial gaussian, gaussian distribution centered at middle of the area, angle is uniform
		// -> mean is xArea/2, sigma is 1/4 of it (this is beta implementation)
		double gaus;
		double angle;
		double x,y;
		Node n;

		for (int i = 0; i < nodesNo; i++) {
			while(true) {
				// non-uniform with a hole in the middle 
				gaus=0.5 /(0.5+ CommonClass.mt.nextGaussian());

				//gaus=CommonClass.mt.nextGaussian();
				angle=CommonClass.mt.nextDouble()*2*Math.PI;
				x=xArea/2 + gaus*xArea*Math.cos(angle)/2; y=yArea/2 + gaus*yArea*Math.sin(angle)/2;
				if(x<=xArea && y<=yArea && x>=0 && y>=0) {
					n=new Node(x,y);
					allNodes.put(n.getId(),n);
					break;
				}
			}
		}
	}

	private void placeNodes2Dppp(int nodesNo){ 
		int count=nodesNo*100;
		double positionX, positionY, placementAreaX=xArea*10, placementAreaY=yArea*10;
		Node n;

		nodesNo=0;
		for (int i = 0; i < count; i++) {
			positionX=CommonClass.mt.nextDouble()*placementAreaX;
			positionY=CommonClass.mt.nextDouble()*placementAreaY;
			if(positionX<=xArea && positionY<=yArea) {
				n=new Node (positionX, positionY);
				allNodes.put(n.getId(),n);
				nodesNo++;
			}
		}
	}

	private void placeNodes2Duniform(int nodesNo){
		Node n;
		for (int i = 0; i < nodesNo; i++) {
			n=new Node (CommonClass.mt.nextDouble()*xArea, CommonClass.mt.nextDouble()*yArea);
			allNodes.put(n.getId(),n);
		}
	}


	private void placeNodesGrid(int nodesNo){
		Node n;
		double xC, yC; //x coordinate, y coordinate
		yC=0;
		for (int i = 0; i < horizontal; i++) {
			xC=0;
			for(int j=0; j<vertical; j++)
			{
				n=new Node (xC, yC);
				allNodes.put(n.getId(),n);
				xC+=gridEdge;
			}
			yC+=gridEdge;
		}
	}

	private void placeNodesRWM(int nodesNo){ 
		double x1, x2, y1, y2, speed, travelTime=0, elapsedTime=0;
		double sin, cos, spX, spY;
		Node n;

		for (int i = 0; i < nodesNo; i++) {
			travelTime=elapsedTime=0;
			x2=CommonClass.mt.nextDouble()*xArea;
			y2=CommonClass.mt.nextDouble()*yArea; //starting point

			do {
				elapsedTime+=travelTime;
				x1=x2; y1=y2;
				speed=minSpeed + CommonClass.mt.nextDouble()*(maxSpeed-minSpeed);
				x2=CommonClass.mt.nextDouble()*xArea;
				y2=CommonClass.mt.nextDouble()*yArea; //starting point
				travelTime=CommonClass.distance(x1, y1, x2, y2)/speed;
			} while(elapsedTime+travelTime<=duration); // initial movements, pause is IGNORED!

//			System.out.println("" + x1 + " " + y1 + " " + x2 + " " + y2);
//			System.out.println(speed);

			sin=(y2-y1)/CommonClass.distance(x1, y1, x2, y2);
			cos=(x2-x1)/CommonClass.distance(x1, y1, x2, y2); //sinus, cosinus
			spX=speed*cos; // x component of speed
			spY=speed*sin;
			travelTime=duration-elapsedTime; // time to travel before the duration elapses
			x2=x1 + spX*travelTime;
			y2=y1 + spY*travelTime;

//			System.out.println("" + x1 + " " + y1 + " " + x2 + " " + y2);
			n=new Node (x2, y2);
			allNodes.put(n.getId(),n);
		}
	}

	public Node getNodeById(int key) {
		return (Node)allNodes.get(key);
	}

	public String toString(){
		String res=new String("Network Model: \n");
		Iterator it=allNodes.values().iterator();
		Node n;
		while(it.hasNext()) {
			n=(Node)it.next();
			res+=n;
			res+="\n";

		}
		return res;
	}
	public void setXArea(double area) {
		xArea = area;
	}
	public void setYArea(double area) {
		yArea = area;
	}
	public void setCommunicationRadius(double communicationRadius) {
		this.communicationRadius = communicationRadius;
	}
} 
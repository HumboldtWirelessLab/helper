package Visualize;


import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Container;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Line2D;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.Collection;
import java.util.HashMap;
import java.util.*;
import java.util.Iterator;
import java.util.Set;

import javax.swing.Box;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JTextField;

/**
 * @author milic
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class DisplayGraph extends JFrame {
	private Collection nodes;
	private Set bridges;
	double x, y;
	static String topologyType;
	double[] parameters;
	private static int xSize=1010, ySize=980;
	private double scale=0;
	private JButton
	buttonNew = new JButton("New topology"),
	buttonSave = new JButton("Save topology to file");

	private JTextField fileField = new JTextField(20);

	private ActionListener actionNew = new ActionListener() {
		public void actionPerformed(ActionEvent e) {
			String name = ((JButton)e.getSource()).getText();
			System.out.println("new topology");
			newTopology();
		}
	};
	private ActionListener actionSave = new ActionListener() {
		public void actionPerformed(ActionEvent e) {
			String name = fileField.getText();
			if(name.length()==0) {System.out.println("NOT SAVED, must provide name for save file."); return;}
			System.out.println("saving file: " + name);
			saveFile(name);
		}
	};

	public void init() {
		Box bh = Box.createHorizontalBox();
		buttonNew.addActionListener(actionNew);
		buttonSave.addActionListener(actionSave);
		bh.add(buttonNew);
		bh.add(fileField);
		bh.add(buttonSave);
		Container cp = getContentPane();
		cp.add(BorderLayout.SOUTH, bh);
	}

	private void saveFile(String fileName) {
		try{
			// Create file 
			FileWriter fstream = new FileWriter(fileName);
			BufferedWriter out = new BufferedWriter(fstream);
			out.write("set topo [new Topography]\n");
			out.write("$topo load_flatgrid " + x + " " + y + "\n");
			out.write("create-god " +  nodes.size() + " \n");
			out.write("$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) -macType $val(mac)  -ifqType $val(ifq) -ifqLen $val(ifqlen) -antType $val(ant) -propType $val(prop) -phyType $val(netif) -channel  [new $val(chan)] -topoInstance $topo -agentTrace ON -routerTrace OFF -macTrace OFF -movementTrace OFF \n");
			out.write("# nominal radius is " + parameters[3] + "\n");
			out.write("for {set i 0} {$i < " + nodes.size() + "} {incr i} { set node_($i) [$ns_ node] } \n");
			Iterator<Node> it=nodes.iterator();
			Node n;
			while(it.hasNext()) {
				n=it.next();
				out.write("$node_(" + n.getId() + ") set X_ " + n.getX() + "\n");
				out.write("$node_(" + n.getId() + ") set Y_ " + n.getY() + "\n");
				out.write("$node_(" + n.getId() + ") set Z_ " + 0 + "\n");
			}

			//Close the output stream
			out.close();
		}catch (Exception e){//Catch exception if any
			System.err.println("Error: " + e.getMessage());
			System.exit(1);
		}
	}

	public DisplayGraph(double[] parameters) {
		super("Topology");
		this.parameters=parameters;
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setSize(xSize, ySize);

		newTopology(); //it also calls init, paint

		setVisible(true);
		this.setTitle("Scale factor: " + scale);
	}

	public DisplayGraph(NetworkModel nm) {
		super("Topology");
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setSize(xSize, ySize);
		bridges=new HashSet();
		nodes=nm.getNodesList();
		x=nm.getXArea();
		y=nm.getYArea();

//		calculate scale factor
		double maxY=ySize-70;
		double maxX=xSize;
		scale=maxY/nm.getYArea();
		if(maxX/nm.getXArea()<scale) scale=maxX/nm.getXArea();

		init();
		this.setTitle("Scale factor: " + scale);
		setVisible(true);
	}

	public DisplayGraph(NetworkModel nm, Collection<Pair> crossEdges) {
		super("Topology");
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setSize(xSize, ySize);
		bridges=new HashSet();
		nodes=nm.getNodesList();
		x=nm.getXArea();
		y=nm.getYArea();

		Iterator<Pair> it=crossEdges.iterator();
		while(it.hasNext()) {
			Pair p=it.next();
			String s=new String("" + p.node + " " + p.parrent);
			bridges.add(s);
			s=new String("" + p.parrent + " " + p.node);
			bridges.add(s);
		}

//		calculate scale factor
		double maxY=ySize-70;
		double maxX=xSize;
		scale=maxY/nm.getYArea();
		if(maxX/nm.getXArea()<scale) scale=maxX/nm.getXArea();

		init();
		this.setTitle("Scale factor: " + scale);
		setVisible(true);
	}


	public void paint(Graphics g) {
		int shift=30;
		super.paint(g);
		Iterator it=nodes.iterator(), nodeIt;
		Graphics2D g2d = (Graphics2D)g;
		double diameter=5;
		Node n, nn;

		while(it.hasNext()) {
			n=(Node)it.next();
			Ellipse2D.Double circle = new Ellipse2D.Double(scale*(n.getX()-diameter/2)+shift, scale*(n.getY()-diameter/2)+shift, scale*diameter, scale*diameter);
			g2d.fill(circle);
			//if(n.getId()==1) g.setColor( Color.red );
			g2d.drawString(new String("#"+n.getId()), new Double(scale*n.getX()).intValue()+shift, new Double(scale*n.getY()).intValue()+shift);
			g.setColor( Color.black );
			nodeIt=n.getNeighbors().iterator();
			while(nodeIt.hasNext()) {
				nn=(Node)nodeIt.next();
				if(bridges.contains(new String(""+n.getId()+ nn.getId() ) ) || bridges.contains( new String("" + nn.getId() + " " + n.getId()) )) {
					g.setColor( Color.red );
					g2d.draw(new Line2D.Double(scale*n.getX()+shift, scale*n.getY()+shift, scale*nn.getX()+shift, scale*nn.getY()+shift));
					g.setColor( Color.black );
				}
				else
					g2d.draw(new Line2D.Double(scale*n.getX()+shift, scale*n.getY()+shift, scale*nn.getX()+shift, scale*nn.getY()+shift));
			}
		}
	}

	private void newTopology(){
		setVisible(false);
		Node.resetId();
		NetworkModel nm;
		if(parameters==null) {setVisible(true); return;}

		if(topologyType.equalsIgnoreCase("distroT") || topologyType.equalsIgnoreCase("distroRWM") || topologyType.equalsIgnoreCase("distroFF") || topologyType.equalsIgnoreCase("distroL") || topologyType.equalsIgnoreCase("distroFFmain") || topologyType.equalsIgnoreCase("distroLmain") || topologyType.equalsIgnoreCase("distroFFa") || topologyType.equalsIgnoreCase("distroLa")) {
			// generate experimental deployment
			//ExperimentalDeployment ed=new ExperimentalDeployment(new Double(parameters[2]).intValue(), topologyType, parameters[3]);
			nm=new NetworkModel();
			//double badness=ed.createNM(nm);

			//System.out.println("Badness: "+badness);
		}
		else { //generate usual graph
			nm=new NetworkModel(parameters[0], parameters[1], new Double(parameters[2]).intValue(), parameters[3]);
			nm.connectivityGraph(0,0);
		}
		//common part for both topology types

		double avgDeg=nm.avgDegree();
		/*Iterator it=nm.allNodes.values().iterator();
		while(it.hasNext()) {
			Node n=(Node)it.next();
			//System.out.println(n.degree());
		}
		 */


		bridges=CommonClass.bridgesTwoWay(nm);


		int linksTotal=nm.getLinkCount();

		System.out.println("Avg. neighbors: " + avgDeg);
		System.out.println("Avg. links: " + linksTotal);        
		System.out.println("real bridges:" +bridges.size()/2); 
		System.out.println("total nodes:" +nm.getNodesNo()); 

		nodes=nm.getNodesList();

		double maxY=ySize-70;
		double maxX=xSize;

		//calculate scale factor
		scale=maxY/nm.getYArea();
		if(maxX/nm.getXArea()<scale) scale=maxX/nm.getXArea();

		// set topology size
		x=nm.getXArea();
		y=nm.getYArea();
		//System.out.println("x=" + x + " y="+ y);
		init();
		setVisible(true);
	}

	public static void main(String[] args) {
		int i;
		double avgDeg=0, bogus;
		Collection curPartitions;
		Collection GG;
		HashMap tmpMap;
		double[] parameters=new double[5];
		String distribution, graphType;
		DisplayGraph dg1, dg2;


		double linksTotal=0, linksEliminated=0, alpha, sigma;
		double minSpeed, maxSpeed, pauseTime, duration, gridEdge; //for RWM
		int horizontal, vertical;

		gridEdge=minSpeed=maxSpeed=pauseTime=duration=-1;
		horizontal=vertical=-1;

		topologyType=args[0];

		//detect experimental distributions
		if(args[0].equalsIgnoreCase("distroRWM") || args[0].equalsIgnoreCase("distroFF") || args[0].equalsIgnoreCase("distroL") ) {
			int nodes=new Integer(args[1]);
			double radius=new Double(args[2]);
			//ExperimentalDeployment.retries=new Integer(args[3]);
			//ExperimentalDeployment.negativePenalty=new Integer(args[4]);
			//ExperimentalDeployment.setSecondaryMetricWeight(new Double(args[5]));
			parameters=new double[5];
			parameters[0]=parameters[1]=0; // placement size
			parameters[2]=nodes; // node count
			parameters[3]=radius;
			DisplayGraph dg=new DisplayGraph(parameters);
		} else {

			if(args.length<8) { //normal distributions

				System.out.println("Usage: dimensionX, dimensionY, noOfNodes, radius, noOfIterations, distribution (uniform/ppp/gaus/rwm), alpha, sigma");
				System.exit(1);
			}

			for(i=0; i<5; i++) parameters[i]=(new Double(args[i]).doubleValue());

			distribution=args[5];
			alpha=(new Double(args[6]).doubleValue());
			sigma=(new Double(args[7]).doubleValue());

			if(distribution.toLowerCase().equals("uniform")) {
				//	System.out.println("Running UNIFORM model"); 
				NetworkModel.setUniform();
			}
			else if(distribution.toLowerCase().equals("ppp")) {
				//	System.out.println("Running PPP model"); 
				NetworkModel.setPPP();
			}
			else if (distribution.toLowerCase().equals("gaus")) {
				//System.out.println("Running Gaussian model node distribution"); 
				NetworkModel.setGaussian();
			}
			else if (distribution.toLowerCase().equals("grid")) {
				if(args.length!=11) {
					System.out.println("*** FOR GRID MODEL ADDITIONAL PARAMETERS REQUIRED ***");
					System.out.println("Usage: dimensionX dimensionY noOfNodes radius noOfIterations distribution (uniform/ppp/gaus/rwm) alpha sigma gridEdge horizontalNodes verticalNodes");
					System.exit(1);
				}
				gridEdge=(new Double(args[8]).doubleValue());
				horizontal=(new Double(args[9]).intValue());
				vertical=(new Double(args[10]).intValue());

				NetworkModel.setGrid(gridEdge, horizontal, vertical);
			}
			else if (distribution.toLowerCase().equals("rwm")) {
				if(args.length!=12) {
					System.out.println("*** FOR RWM MODEL ADDITIONAL PARAMETERS REQUIRED ***");
					System.out.println("Usage: dimensionX dimensionY noOfNodes radius noOfIterations distribution (uniform/ppp/gaus/rwm) minSpeed maxSpeed Pause durationOfMovementBeforeSnapshot");
					System.exit(1);
				}

				minSpeed=(new Double(args[8]).doubleValue());
				maxSpeed=(new Double(args[9]).doubleValue());
				pauseTime=(new Double(args[10]).doubleValue());
				duration=(new Double(args[11]).doubleValue());

				NetworkModel.setRWM(minSpeed, maxSpeed, pauseTime, duration);
			} 

			String description="" + distribution + " x:" + parameters[0] + " y:" + parameters[1] + " nodes:" + parameters[2] + " r:" + parameters[3];
			description=description + " alpha:" + alpha + " sigma:" + sigma;
			if(distribution.equalsIgnoreCase("rwm")) description= description + " minSpeed:" + minSpeed + " maxSpeed:" + maxSpeed + " pause:" + pauseTime + " duration:" + duration;
			if(distribution.equalsIgnoreCase("grid")) description= description + " gridEdge:" + gridEdge + " horizontal nodes:" + horizontal + " vertical nodes:" + vertical;
			System.out.println(description);

			DisplayGraph dg=new DisplayGraph(parameters);
		} 
	} 



	public static void main111(String[] args) {
		int nodes=200;
		NetworkModel.setUniform();
		NetworkModel nm=new NetworkModel(500,500,200,48);
		nm.connectivityGraph(0, 0);
		Set s=CommonClass.bridgesTwoWay(nm);
		DisplayGraph dg=new DisplayGraph(nm);
	}

} 
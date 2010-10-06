/**
 * @author milic bratislav
 * Humboldt University, Berlin
 * milic@informatik.hu-berlin.de
 *
 * 
 */

package NPART;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Container;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Line2D;
import javax.swing.*;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.HashSet;

import javax.swing.JFrame;

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

	public DisplayGraph(NetworkModel nm, Set br) {
		super("Topology");
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setSize(xSize, ySize);
		bridges=br;
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

	private static String translateSwansId(int n) {
		String rez="0.0." + (n/256)+"."+(n%256);
		return rez;
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
			g2d.drawString(new String(translateSwansId(n.getId())), new Double(scale*n.getX()).intValue()+shift, new Double(scale*n.getY()).intValue()+shift);
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
			NPART ed=new NPART(new Double(parameters[2]).intValue(), topologyType, parameters[3]);
			nm=new NetworkModel();
			double badness=ed.createNM(nm);

			System.out.println("Badness: "+badness);
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

		Collection curPartitions=nm.createPartitions();

		bridges=CommonClass.bridgesTwoWay(nm);


		int linksTotal=nm.getLinkCount();

		System.out.println("Avg. neighbors: " + avgDeg);
		System.out.println("Avg. partitions: " + curPartitions.size());
		System.out.println("Avg. links: " + linksTotal);        
		System.out.println("real bridges:" +bridges.size()/2); 
		System.out.println("total nodes:" +nm.getNodesNo()); 
		System.out.println("diameter: " + DijkstraHOP.graphDiameter(nm));

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

} 
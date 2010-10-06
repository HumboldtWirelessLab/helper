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
import javax.swing.*;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.HashSet;
import java.io.*;

import javax.swing.JFrame;

/**
 * @author milic
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
public class DisplayAndDelete  extends JFrame {
	private Collection nodes;
	private Set bridges;
	double x, y;
	static String topologyType;
	double[] parameters;
	private static int xSize=1010, ySize=980;
	private double scale=0;
	private String filename;
	private JButton	buttonDelete = new JButton("Delete me!");
	private JButton	buttonStay = new JButton("SAVE ME!");

	private ActionListener actionDelete = new ActionListener() {
		public void actionPerformed(ActionEvent e) {
			File f=new File(filename);
			f.delete();
			System.exit(0);
		}
	};

	private ActionListener actionSaveMe = new ActionListener() {
		public void actionPerformed(ActionEvent e) {
			System.exit(0);
		}
	};

	public void init() {
		Box bh = Box.createHorizontalBox();
		buttonDelete.addActionListener(actionDelete);
		buttonStay.addActionListener(actionSaveMe);
		bh.add(buttonDelete);
		bh.add(buttonStay);
		Container cp = getContentPane();
		cp.add(BorderLayout.SOUTH, bh);
	}

	public DisplayAndDelete(NetworkModel nm, Set br, String filename) {
		super("filename");
		this.filename=filename;
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
		this.setTitle("Scale factor: " + scale + " | " + filename);
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
	//FILE name here
	public static void main(String[] args) {

		if(args.length==0) {
			System.out.println("you must specify topology file name. exiting."); System.exit(1);
		}
        //for(int i = 0; i < args.length; i++) {
        for(int i = 0; i < 1; i++) {
            String filename;
           // DisplayGraph dg1;

		    filename=args[i];
		
		    NetworkModel nm=CommonClass.parseNs2Topology(filename, 250);
//		NetworkModel nm=CommonClass.parseNs2Topology(filename, 376.783);
		    Set bridges=CommonClass.bridgesTwoWay(nm);
		
		    DisplayAndDelete dg=new DisplayAndDelete(nm, bridges, filename);
        }
	} 
	
	public static void main2(String[] args) {
		String filename;
		DisplayGraph dg1;

		filename="40berlinRician.placement";
		NetworkModel.setUniform();
		double a=Math.sqrt(3.14 * 250 * 250 * 275.0/4);
		NetworkModel nm=new NetworkModel(a,a,275,250);
		nm.connectivityGraph(250);
		Set bridges=CommonClass.bridgesTwoWay(nm);

		DisplayAndDelete dg=new DisplayAndDelete(nm, bridges, filename);
	} 
} 


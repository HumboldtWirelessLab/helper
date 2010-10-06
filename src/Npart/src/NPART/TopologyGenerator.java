package NPART;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.HashSet;

import jargs.gnu.CmdLineParser;

/**
 * @author milic bratislav
 * Humboldt University, Berlin
 * milic@informatik.hu-berlin.de
 * 
 * http://www.rok.informatik.hu-berlin.de/npart
 * 
 * parse input parameters and produce NPART topologies
 * 
 */
public class TopologyGenerator {
	
	/** Simulation parameters with default values. */
	private static class CommandLineOptions {
		/** Whether to print a usage statement. */
		private boolean help = false;
		/** Number of nodes. */
		private int nodes = 50;
		/** Field dimensions (in meters). */
		private double xDim=100;
		private double yDim=100;

		private boolean useAdaptive=true;
		
		/** Node placement model. */
		private String placement = null;

		/** Output file format, supported .dot and ns2 */
		private String outType=null;
		
		/** number of retries per node placed */
		private int retries = 50;

		private double penalty=5;

		private double radius=250;

		// how many topologies to generate
		private int topologyCount=1;

		private double secondaryW=1.0;
		
		private double reduction=0;

    private String filename = null;
	} // class: CommandLineOptions

	/** Prints a usage statement. */
	private static void showUsage() {
		System.out.println("Usage: java -cp<classpath> NPART.TopologyGenerator [options]");
		System.out.println();
		System.out.println("  -h, --help           print this message");
		System.out.println("  -n, --nodes          number of nodes: n [50] ");
		System.out.println("  -a, --arrange        uniform/uniformConnected/distroFF/distroL");
		System.out.println("  -x, --xDimension     x-dimension of placement area for uniform placements");
		System.out.println("  -y, --yDimension     y-dimension of placement area for uniform placements");
		System.out.println("  -r, --radius         comm. radius (without effects of shadowing/fading!)");
		System.out.println("  -t, --retries        retries parameter of NPART (how many candidates shall be evaluated)");
		System.out.println("  -p, --penalty        penalty for degree overloading");
		System.out.println("  -s, --secondaryWgh   secondary weight parameter for npart");
		System.out.println("  -c, --count          Topology count: how many topologies to generate");
		System.out.println("  -d, --reduction      reduction of pendant node count");
		System.out.println("  -o, --output         output file type: ns2/dot/TabSeparated(ts) [ns2]");
    System.out.println("  -f, --outputfile     filename (if none -> stdout)");

		System.out.println();
	}

	/**
	 * Parses command-line arguments.
	 *
	 * @param args command-line arguments
	 * @return parsed command-line options
	 * @throws CmdLineParser.OptionException if the command-line arguments are not well-formed.
	 */
	private static CommandLineOptions parseCommandLineOptions(String[] args) throws CmdLineParser.OptionException {
		if(args.length==0) {
			args = new String[] { "-h" };
		}
		CmdLineParser parser = new CmdLineParser();
		CmdLineParser.Option opt_help = parser.addBooleanOption('h', "help");
		CmdLineParser.Option opt_nodes = parser.addIntegerOption('n', "nodes");
		CmdLineParser.Option opt_xDim = parser.addDoubleOption('x', "xDimension");
		CmdLineParser.Option opt_yDim = parser.addDoubleOption('y', "yDimension");
		CmdLineParser.Option opt_radius = parser.addDoubleOption('r', "radius");
		CmdLineParser.Option opt_retries = parser.addIntegerOption('t', "retries");
		CmdLineParser.Option opt_penalty = parser.addDoubleOption('p', "penalty");
		CmdLineParser.Option opt_count = parser.addIntegerOption('c', "count");
		CmdLineParser.Option opt_secondaryW = parser.addDoubleOption('s', "secondaryWgh");
		CmdLineParser.Option opt_reduction = parser.addDoubleOption('d', "reduction");
		CmdLineParser.Option opt_placement = parser.addStringOption('a', "arrange");
		CmdLineParser.Option opt_output = parser.addStringOption('o', "output");
		CmdLineParser.Option opt_adaptive = parser.addStringOption('e', "adaptive");
    CmdLineParser.Option opt_output_file = parser.addStringOption('f', "outputfile");
		parser.parse(args);

		CommandLineOptions cmdOpts = new CommandLineOptions();
		// help
		if(parser.getOptionValue(opt_help) != null) {
			cmdOpts.help = true;
            showUsage();
            System.exit(1);
            
		}

		if(parser.getOptionValue(opt_nodes) != null) {
            cmdOpts.nodes = ((Integer)parser.getOptionValue(opt_nodes)).intValue();
		}

		if(parser.getOptionValue(opt_count) != null) {
			cmdOpts.topologyCount = ((Integer)parser.getOptionValue(opt_count)).intValue();
		}

		if(parser.getOptionValue(opt_radius) !=null) {
			cmdOpts.radius=((Double)parser.getOptionValue(opt_radius)).doubleValue();
		}

		if(parser.getOptionValue(opt_output) != null) {
			cmdOpts.outType=(String)parser.getOptionValue(opt_output);
			//System.out.println("out type: " + cmdOpts.outType);
			if(!(cmdOpts.outType.equalsIgnoreCase("ns2") ||
           cmdOpts.outType.equalsIgnoreCase("dot") ||
           cmdOpts.outType.equalsIgnoreCase("ts") )) {
				System.out.println("Output type must be either ns2, dot or ts. Exiting.");
                showUsage();
				System.exit(1);
			}
		} else {
			System.out.println("Output type must be specified (ns2/dot/ts). Exiting.");
			System.exit(1);
		}

    if(parser.getOptionValue(opt_output_file) != null) {
      cmdOpts.filename = (String)parser.getOptionValue(opt_output_file);
    }

		// placement
		if(parser.getOptionValue(opt_placement) != null) {
			cmdOpts.placement=(String)parser.getOptionValue(opt_placement);
			
			if(cmdOpts.placement.equalsIgnoreCase("distroFF") || cmdOpts.placement.equalsIgnoreCase("distroL")) {
				if(cmdOpts.nodes<40) {
					System.out.println("NPART implementation does not support topologies with less than 40 nodes. Exiting.");
					System.exit(1);
				}

				if(parser.getOptionValue(opt_retries) != null) {
					cmdOpts.retries = ((Integer)parser.getOptionValue(opt_retries)).intValue();
				} 

				if(parser.getOptionValue(opt_reduction) !=null) {
					cmdOpts.reduction=((Double)parser.getOptionValue(opt_reduction)).doubleValue();
				}
				
				if(parser.getOptionValue(opt_secondaryW) !=null) {
					cmdOpts.secondaryW=((Double)parser.getOptionValue(opt_secondaryW)).doubleValue();
				}

				if(parser.getOptionValue(opt_penalty) !=null) {
					cmdOpts.penalty=((Double)parser.getOptionValue(opt_penalty)).doubleValue();
				}
			}
		}

		if(parser.getOptionValue(opt_adaptive) !=null) {
			String adapt=(String)parser.getOptionValue(opt_adaptive);
			cmdOpts.useAdaptive=!adapt.equalsIgnoreCase("false");
			NPART.useAdaptive=cmdOpts.useAdaptive;
		}

		if(parser.getOptionValue(opt_xDim) !=null) {
			cmdOpts.xDim=((Double)parser.getOptionValue(opt_xDim)).doubleValue();
		}

		if(parser.getOptionValue(opt_yDim) !=null) {
			cmdOpts.yDim=((Double)parser.getOptionValue(opt_yDim)).doubleValue();
		}

		return cmdOpts;

	} // parseCommandLineOptions


	private Collection nodes;
	private Set bridges;
	double x, y;
	static String topologyType;
	private double scale=0;
	CommandLineOptions options;

	public TopologyGenerator(String[] parameters) {
		try {
			options=parseCommandLineOptions(parameters);
		} catch(Exception e) {throw new RuntimeException(e);}
	}

	// save file in ns2 format
	private void saveFile(String fileName) {
		try{
			// Create file
			FileWriter fstream = new FileWriter(fileName);
			BufferedWriter out = new BufferedWriter(fstream);
			out.write("set topo [new Topography]\n");
			out.write("$topo load_flatgrid " + x + " " + y + "\n");
			out.write("create-god " +  nodes.size() + " \n");
			out.write("$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) -macType $val(mac)  -ifqType $val(ifq) -ifqLen $val(ifqlen) -antType $val(ant) -propType $val(prop) -phyType $val(netif) -channel  [new $val(chan)] -topoInstance $topo -agentTrace ON -routerTrace OFF -macTrace OFF -movementTrace OFF \n");
			out.write("# nominal radius is " + options.radius + "\n");
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

	// save file in tab seperated format
	private void saveFileTabSep(String fileName) {
		try{
			// Create file
      if ( fileName == null ) {
        Node n;
        Iterator<Node> it=nodes.iterator();

        while(it.hasNext()) {
          n=it.next();
          System.out.print("node_" + n.getId() + " " + (int)Math.ceil(n.getX()) + " " + (int)Math.ceil(n.getY()) + " " + (int)0 + "\n");
        }
      } else {
			  FileWriter fstream = new FileWriter(fileName);
        BufferedWriter out = new BufferedWriter(fstream);
        Iterator<Node> it=nodes.iterator();
        Node n;
        while(it.hasNext()) {
          n=it.next();
          out.write("node_" + n.getId() + " " + n.getX() + " " + n.getY() + " " + 0 + "\n");
        }

        //Close the output stream
        out.close();
      }
		}catch (Exception e){//Catch exception if any
			System.err.println("Error: " + e.getMessage());
			System.exit(1);
		}
	}

	private void writeToFile(String fileName, StringBuffer text) {
		try{
			// Create file 
			FileWriter fstream = new FileWriter(fileName);
			BufferedWriter out = new BufferedWriter(fstream);

			out.write(text.toString());
			
			//Close the output stream
			out.close();
		}catch (Exception e){//Catch exception if any
			e.printStackTrace();
			System.exit(1);
		}
	}


	private NetworkModel newTopology(){
		Node.resetId();
		NetworkModel nm;
		Collection curPartitions;
		
		if(options.placement==null) {
			showUsage(); throw new RuntimeException("No placement model specified. Exiting.");
		}
		if(options.placement.equalsIgnoreCase("distroFF") || options.placement.equalsIgnoreCase("distroL")) {
			NPART npart=new NPART(options.nodes, options.placement, options.radius);
			npart.retries=options.retries;
			npart.negativePenalty=options.penalty;
			npart.setSecondaryMetricWeight(options.secondaryW);
			
			nm=new NetworkModel();

			double badness=npart.createNM(nm);
			curPartitions=nm.createPartitions();
			//System.out.println(badness);
		}
		else if(options.placement.equalsIgnoreCase("uniformConnected")){ //generate usual graph
			do {
				Node.resetId();
				NetworkModel.setUniform();
				nm=new NetworkModel(options.xDim, options.yDim, options.nodes, options.radius);
				nm.connectivityGraph(0,0);
				curPartitions=nm.createPartitions();
				//System.out.println("Creating Uniform-connected placement, partitions in this iteration: " + curPartitions.size());
			} while(curPartitions.size()>1);
		} else if(options.placement.equalsIgnoreCase("uniform")){ //generate usual graph
			NetworkModel.setUniform();
			nm=new NetworkModel(options.xDim, options.yDim, options.nodes, options.radius);
			nm.connectivityGraph(0, 0);
		} else throw new RuntimeException("unsupported placement model");

		double avgDeg=nm.avgDegree();

		bridges=CommonClass.bridgesTwoWay(nm);

		//DisplayGraph dg=new DisplayGraph(nm, bridges);
		
		int linksTotal=nm.getLinkCount();
		curPartitions=nm.createPartitions();

		/*
		System.out.println("Avg. neighbors: " + avgDeg);
		System.out.println("Avg. partitions: " + curPartitions.size());
		System.out.println("Avg. links: " + linksTotal);        
		System.out.println("Bridges:" +bridges.size()/2); 
		System.out.println("Nodes:" +nm.getNodesNo()); 
		//System.out.println("diameter: " + DijkstraHOP.graphDiameter(nm));
		*/
		nodes=nm.getNodesList();

		// set topology size
		x=nm.getXArea();
		y=nm.getYArea();
		//System.out.println("x=" + x + " y="+ y)
		return nm;
	}


	public static void main(String[] args) {
		int i;

		TopologyGenerator top=new TopologyGenerator(args);
		if(top.options.reduction!=0) NPART.reduce(top.options.reduction);
		
		for(i=0;i<top.options.topologyCount;i++) {
			NetworkModel nm=top.newTopology();
			
			if(top.options.outType.equalsIgnoreCase("ns2"))
				top.saveFile(top.options.placement + i + ".placement");
			else if (top.options.outType.equalsIgnoreCase("dot")) top.writeToFile(top.options.placement + i + ".dot", CommonClass.networkModel2Dot(nm, new HashSet(), top.options.placement + i));
			else if (top.options.outType.equalsIgnoreCase("ts")) {
        if ( top.options.filename == null )
          top.saveFileTabSep(null);
        else
          top.saveFileTabSep(top.options.filename + i + ".plm");   
      }
		}
	} 
} 


import java.io.*;
import org.apache.commons.cli.*;

public class SubnetworkDiscovery {
	
	public static void main(String[] args) throws ParseException {
		BufferedReader f;
		int tmp_node1, tmp_node2;
		String file;	
		String algo;
		
		DiscoveryContext ctx 	= new DiscoveryContext();
		
		
		
		ctx.options 			= new Options();
		ctx.options.addOption("f", "file", true, "Source file containing lines with two nodes and the link metric.");
		ctx.options.addOption("n", "nodes", true, "Define how many nodes you need.");
		ctx.options.addOption("algo", "algorithm", true, "Choose the discovery algorithm: ammonite, ...");
		ctx.options.addOption("h", "help", false, "Get help.");
		
		// ************************************************************************************************************
		// Define here all the program parameters that are specific for your algorithm
		ctx.options.addOption("t", "thrashold-metric", true, "Define the worst metric in the subnet. Default is 1500.");
		ctx.options.addOption("hop", "hop-limit", true, "Define the maximum hop limit in the subnet. Default is 10.");
		// ************************************************************************************************************
		
		ctx.parser = new PosixParser();
		ctx.cmd = ctx.parser.parse( ctx.options, args);
		
		file = (ctx.cmd.hasOption("f")) ? ctx.cmd.getOptionValue("f") : "linksmetric.all";
		algo = (ctx.cmd.hasOption("algo")) ? ctx.cmd.getOptionValue("algo") : "ammonite";
		
		if (ctx.cmd.hasOption("h")) {
			// automatically generate the help statement
			HelpFormatter formatter = new HelpFormatter();
			formatter.printHelp( "SubnetworkDiscovery", ctx.options );
			System.exit(0);
		}
		
		
		
		try {
			
			f = new BufferedReader(new FileReader(file));
			String line = null;
			String[] tmp = new String[3];
			
			// read metric file
			while ( (line = f.readLine() ) != null) {
				tmp = line.split(" ");
				
				// build a name table to give every node an ID (idx)
				if (!ctx.name_table.contains(tmp[0])) {
					ctx.name_table.add(tmp[0]);
				}
				if (!ctx.name_table.contains(tmp[1])) {
					ctx.name_table.add(tmp[1]);
				}
				
				tmp_node1 = ctx.name_table.indexOf(tmp[0]);
				tmp_node2 = ctx.name_table.indexOf(tmp[1]);
				int metric = Integer.parseInt(tmp[2]);
				
				ctx.link_matrix[tmp_node1][tmp_node2] = metric;
			}
		} catch (IOException x) {
	        System.err.format("IOException: %s%n", x);
		}
		
		int graphSize = ctx.getGraphSize();
		
		// Display link matrix
		for(int i = 0; i<graphSize; i++) {
			for(int j = 0; j<graphSize; j++) {
				//if (context.link_matrix[i][j] > 0) System.out.println("Testing "+context.name_table.elementAt(i)+"-"+context.name_table.elementAt(j)+":"+context.link_matrix[i][j]);
			}
		}
		
		// Start generating new subgraph by first searching for cycles
		GenericDiscovery discovery;
		if (algo == "ammonite")
			discovery = new Ammonite(args, ctx);
		else 
			discovery = new Ammonite(args, ctx);
		
		discovery.init();		
		discovery.discover();
		discovery.finish();

	}
	
	
}

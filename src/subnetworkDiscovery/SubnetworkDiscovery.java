
import java.io.*;
import org.apache.commons.cli.*;

public class SubnetworkDiscovery {
	
	public static void main(String[] args) throws ParseException {
		BufferedReader f;
		int tmp_node1, tmp_node2;
		String file;	
		String algo;
		Options options;
		CommandLine cmd;
		CommandLineParser parser;
		
		DiscoveryContext ctx 	= new DiscoveryContext();
		options 				= new Options();
		
		options.addOption("h", "help", false, "Get help.");
		options.addOption("f", "file", true, "Source file containing lines with two nodes and the link metric.");
		options.addOption("n", "nodes", true, "Define how many nodes you need.");
		options.addOption("algo", "algorithm", true, "Choose the discovery algorithm: ammonite, ...");
		options.addOption("p", "paramlist", true, "Algorithm-specific parameter list. E.g. java SubnetworkDiscovery -algo ammonite --paramlist \"t=10&h=1500\". Also see -algo.");
		
		
		parser 		= new PosixParser();
		cmd 		= parser.parse( options, args);
		
		file 		= cmd.getOptionValue("f","linksmetric.all");
		algo 		= cmd.getOptionValue("algo", "ammonite");
		
		ctx.nodes	= Integer.parseInt(cmd.getOptionValue("nodes", "10"));
		
		// Get parameters for ammonite
		if (cmd.hasOption("paramlist")) {
			
			String[] tmplist = cmd.getOptionValue("paramlist").split("&");
			for (String parameter : tmplist) {
				String[] tmpparam = parameter.split("=");
				ctx.paramlist.put(tmpparam[0], tmpparam[1]);
			}
		} 
		
		if (cmd.hasOption("h")) {
			// automatically generate general help statement
			HelpFormatter formatter = new HelpFormatter();
			formatter.printHelp( "SubnetworkDiscovery", options );
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
		
		GenericDiscovery discovery;
		if (algo == "ammonite")
			discovery = new Ammonite();
		else // default
			discovery = new Ammonite();
		
		discovery.init(ctx);		
		discovery.discover();
		discovery.finish();

	}
	
	
}

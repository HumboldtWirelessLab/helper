import java.util.*;

import jargs.gnu.CmdLineParser;

public class DegreePlacementGenerator {
	
	/** Simulation parameters with default values. */
	private static class CommandLineOptions {
		/** Whether to print a usage statement. */
		private boolean help = false;
		/** Number of nodes. */
		private int nodes = 10;
		/** Field dimensions (in meters). */
		private int xDim=100;
		private int yDim=100;

		private int radius=120;

    private int rand_start = 100;

    private int degree = 4;

	} // class: CommandLineOptions

  CommandLineOptions options;

	/** Prints a usage statement. */
	private static void showUsage() {
		System.out.println("Usage: java -cp<classpath> NPART.TopologyGenerator [options]");
		System.out.println();
		System.out.println("  -h, --help           print this message");
		System.out.println("  -n, --nodes          number of nodes: n [50] ");
		System.out.println("  -x, --xDimension     x-dimension of placement area for uniform placements");
		System.out.println("  -y, --yDimension     y-dimension of placement area for uniform placements");
		System.out.println("  -r, --radius         comm. radius (without effects of shadowing/fading!)");
    System.out.println("  -z, --random         random init");

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
		CmdLineParser.Option opt_xDim = parser.addIntegerOption('x', "xDimension");
		CmdLineParser.Option opt_yDim = parser.addIntegerOption('y', "yDimension");
		CmdLineParser.Option opt_radius = parser.addIntegerOption('r', "radius");
    CmdLineParser.Option opt_degree = parser.addIntegerOption('d', "degree");
    CmdLineParser.Option opt_random = parser.addIntegerOption('z', "random");
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

		if(parser.getOptionValue(opt_radius) !=null) {
			cmdOpts.radius=((Integer)parser.getOptionValue(opt_radius)).intValue();
		}

		if(parser.getOptionValue(opt_xDim) !=null) {
			cmdOpts.xDim=((Integer)parser.getOptionValue(opt_xDim)).intValue();
		}

		if(parser.getOptionValue(opt_yDim) !=null) {
			cmdOpts.yDim=((Integer)parser.getOptionValue(opt_yDim)).intValue();
		}

    if(parser.getOptionValue(opt_random) !=null) {
      cmdOpts.rand_start=((Integer)parser.getOptionValue(opt_random)).intValue();
    }

    if(parser.getOptionValue(opt_degree) !=null) {
      cmdOpts.degree=((Integer)parser.getOptionValue(opt_degree)).intValue();
    }

		return cmdOpts;

	} // parseCommandLineOptions

	public DegreePlacementGenerator(String[] parameters) {
		try {
			options=parseCommandLineOptions(parameters);
		} catch(Exception e) {throw new RuntimeException(e);}
	}

  public void generate() {
    DegreePlacement dp = new DegreePlacement(options.rand_start);
    Random rnd = new Random(options.rand_start);

    dp.initField(options.xDim, options.yDim, 1);
    dp.initDegreeCounter(options.degree);

    DegreePlacement.Position p = dp.getRandPositionWithDegree(0);
    dp.setNodeInField(p._x, p._y, 15);

    for ( int i = 1; i < options.nodes; i++) {
     // System.out.println("N: " + max_degree + " h: " + dp.getMaxDegree());
      int d = rnd.nextInt(Math.min(options.degree,dp.getMaxDegree())) + 1;
      p = dp.getRandPositionWithDegree(d);
      dp.setNodeInField(p._x, p._y, 15);
    }

    dp.printField();
	}


	public static void main(String[] args) {
    DegreePlacementGenerator dpg = new DegreePlacementGenerator(args);
    dpg.generate();

  }
}

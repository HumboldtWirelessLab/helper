
import java.io.*;

public class genRandomSubGraph {
	
	public static void main(String[] args) {
		BufferedReader f;
		int n1, n2;
		
		int MAX_NODES				= 150;
		
		SubgraphContext context 	= new SubgraphContext(MAX_NODES, args);

		try {
			f = new BufferedReader(new FileReader("./src/linksmetric.all"));
			String line = null;
			String[] tmp = new String[3];
			
			// read metric file
			while ( (line = f.readLine() ) != null) {
				tmp = line.split(" ");
				
				// build a name table to give every node an ID (idx)
				if (!context.name_table.contains(tmp[0])) {
					context.name_table.add(tmp[0]);
				}
				if (!context.name_table.contains(tmp[1])) {
					context.name_table.add(tmp[1]);
				}
				
				n1 = context.name_table.indexOf(tmp[0]);
				n2 = context.name_table.indexOf(tmp[1]);
				int metric = Integer.parseInt(tmp[2]);
				
				context.link_matrix[n1][n2] = metric;
			}
		} catch (IOException x) {
	        System.err.format("IOException: %s%n", x);
		}
		
		int graphSize = context.getGraphSize();
		
		// Display link matrix
		for(int i = 0; i<graphSize; i++) {
			for(int j = 0; j<graphSize; j++) {
				//if (context.link_matrix[i][j] > 0) System.out.println("Testing "+context.name_table.elementAt(i)+"-"+context.name_table.elementAt(j)+":"+context.link_matrix[i][j]);
			}
		}
		
		// Start generating new subgraph by first searching for cycles
		Ammonite Ammonite = new Ammonite();
		Ammonite.init(context);		
		Ammonite.discover();
		Ammonite.finish();

	}
	
	
}

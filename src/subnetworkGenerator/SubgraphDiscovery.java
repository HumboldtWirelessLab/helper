
public interface SubgraphDiscovery {
	
	// Do some init-ops
	public void init(SubgraphContext context);
	
	// Here comes the discovery algorithm
	public void discover();
	
	// Do some final stuff with subgraph
	public void finish();
}


public interface GenericDiscovery {
	
	// Do some init-ops
	public void init(DiscoveryContext Context);
	
	// Here comes the discovery algorithm
	public void discover();
	
	// Do some final stuff with subgraph
	public void finish();
}

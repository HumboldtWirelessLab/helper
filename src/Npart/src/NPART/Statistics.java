/*
 * Created on Mar 10, 2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package NPART;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * @author milic bratislav
 * Humboldt University, Berlin
 * milic@informatik.hu-berlin.de
 * 
 */

public class Statistics { // only static members
    private HashMap sizeMap, coverageMap, normalizedSizeMap, normalizedCoverageMap;
    private int iterations=0;
    private int totalSamples=0;
    
    /** Creates a new instance of Statistics */
    public Statistics() {
        sizeMap=new HashMap();
        coverageMap=new HashMap();
    }
    
    public void histograms(final Collection c) { // for any collection which holds objects which implement Sizeable interface
        Iterator it=c.iterator();
        Sizeable curElement;
        int size;
        double coverage;
        
        iterations++;
        while(it.hasNext()) {
            totalSamples++;
            curElement=(Sizeable)it.next();
            size=curElement.size();
            coverage=0; // coverage is eliminated from interfaces
            if(!sizeMap.containsKey(new Integer(size))) {
            	sizeMap.put(new Integer(size), new Integer(1)); // intialize the entry
            	coverageMap.put(new Integer(size), new Double(coverage));
            }
            else {
                Integer oldSize=(Integer)sizeMap.remove(new Integer(size));
                sizeMap.put(new Integer(size), new Integer(oldSize.intValue()+1));
                Double oldCoverage=(Double)coverageMap.remove(new Integer(size));
                coverageMap.put(new Integer(size), new Double(oldCoverage.doubleValue()+coverage));
            }
        }
    }
    
    public void normalizeToOne(){
        Iterator keys=sizeMap.keySet().iterator();
        int iValue;
        double cValue;
        double tSmpls=totalSamples; // for correct division
        Integer indivKey;
        
        normalizedSizeMap=new HashMap(sizeMap.size(), 1);
        normalizedCoverageMap=new HashMap(coverageMap.size(), 1);
        
        while(keys.hasNext()) {
            indivKey=(Integer)keys.next();
            iValue=((Integer)sizeMap.get(indivKey)).intValue();
            cValue=((Double)coverageMap.get(indivKey)).doubleValue();
            normalizedSizeMap.put(indivKey, new Double(iValue/tSmpls));
            normalizedCoverageMap.put(indivKey, new Double(cValue/iValue));
        }
    }
    
    public String toString() {
        return "*** Statistics.toString() is NOT IMPLEMENTED ***";
    }
    
    public static Map sizeHistogram(final Collection c) { // similar to histogramSizeable but static for any collection which holds objects which implement Sizeable interface
        Iterator it=c.iterator();
        Sizeable curElement;
        HashMap hist=new HashMap(c.size()/3);
        int size;
        Integer old;
        
        while(it.hasNext()) {
            curElement=(Sizeable)it.next();
            size=curElement.size();
            if(!hist.containsKey(new Integer(size))) hist.put(new Integer(size), new Integer(1)); // intialize the entry
            else {
                old=(Integer)hist.remove(new Integer(size));
                hist.put(new Integer(size), new Integer(old.intValue()+1));
            }
        }
        return hist;
    }
/**
 * @return Returns the coverageMap.
 */
public HashMap getCoverageMap() {
	return (HashMap) coverageMap.clone();
}
/**
 * @return Returns the normalizedCoverageMap.
 */
public HashMap getNormalizedCoverageMap() {
	return (HashMap)normalizedCoverageMap.clone();
}
/**
 * @return Returns the normalizedSizeMap.
 */
public HashMap getNormalizedSizeMap() {
	return (HashMap)normalizedSizeMap.clone();
}
/**
 * @return Returns the sizeMap.
 */
public HashMap getSizeMap() {
	return (HashMap)sizeMap.clone();
}
	/**
	 * @return Returns the totalSamples.
	 */
	public int getTotalSamples() {
		return totalSamples;
	}
} 

interface Sizeable {
    public int size();
} 
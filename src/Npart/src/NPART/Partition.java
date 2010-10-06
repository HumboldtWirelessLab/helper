/*
 * Created on Mar 10, 2005
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
package NPART;

import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
/**
 *
 * @author milic
 */
public class Partition implements Sizeable{
    private static int lastId=0;
    
    private Collection part;
    private int partId;
    /** Creates a new instance of Partition */
    public Partition() {
        part=new HashSet();
        partId=lastId++;
    }

    public Partition(int size) {
        part=new HashSet(size);
        partId=lastId++;
    }
    
    public Partition(Node n){ //create partition from a node - start from it and connect all other nodes with it
        part=new HashSet();
        partId=lastId++;
        part.add(n);
        extendPartition();
    }

    public boolean addNode(Node n){
        return part.add(n);
    }
    
    public boolean removeNode(Node n) {
        return part.remove(n);
    }
    
    public static Partition join(Partition p1, Partition p2) {
        if (p1.partId<p2.partId) return p1.join(p2);
        else return p2.join(p1);
    }
    
    private Partition join(Partition p) {
        Iterator it = p.part.iterator();
        while(it.hasNext())
            part.add(it.next());
        return this;
    }
    
    private void extendPartition() {
        LinkedList listRemaining=new LinkedList();
        Node curNode;
        
        if(part.size()>0) listRemaining.addAll(part);
        else return;
        
        while(listRemaining.size()>0){
            curNode=(Node)listRemaining.removeFirst();
            part.add(curNode);
            listRemaining.addAll(curNode.getNeighbors());
            listRemaining.removeAll(part);
        }
    }

    public Collection partitionMembers() {
        return part;
    }
    
    public int size() {return part.size();}
    
    public boolean equals(Partition p){return this.partId==p.partId;}
    
    public String toString() {
    	return "Particija " + partId + ": " +part.toString();
    }
} 
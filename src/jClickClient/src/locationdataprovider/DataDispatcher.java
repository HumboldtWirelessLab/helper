package locationdataprovider;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: robert
 * Date: 19.10.2010
 * Time: 20:54:58
 * To change this template use File | Settings | File Templates.
 */
/**
 * Grabs new data from testbed.
 */
public class DataDispatcher extends Thread {
  /*
  1.Anzahl Knoten
  Für jeden Knoten:
  1. Knoten ID (1 bis 255)
  2. Anzahl gesehener Knoten
  Für jeden gesehenen Knoten:
  1. Knoten ID des gesehenen Knoten
  2. Mean RSSI (1 Sek)
  3. Mean RSSI Antenne 1 (1 Sek)
  4. Mean RSSI Antenne 2 (1 Sek)
  5. Anzahl der Pakete (wenn mehr als 255 dann auf 2 Bytes verteilt)
  */

  Boolean semaphore = Boolean.TRUE;

  private byte[] mssg;
  public long lastUpdate = 0;
  private List<ClickNodeInfo> nodes;
  private NodeInfo statsInfo = null;
  private HashMap<String,Integer> nodes_id;

  public DataDispatcher(String nodelist, NodeInfo stats) {
    statsInfo = stats;
    nodes_id = new HashMap<String,Integer>();
    loadNodes(nodelist);
    setInfo(stats, nodes_id);
    printList();
    openNodes();
    startNodes();
    mssg = new byte[1];
    mssg[0] = 0;
  }

  void loadNodes(String filename) {
    nodes = new ArrayList<ClickNodeInfo>();
    String str;

    try {
      BufferedReader in = new BufferedReader(new FileReader(filename));
      while ((str = in.readLine()) != null) {
        if ( ! str.contains("#") ) {
          System.out.println(str);
          String nodeinfo[] = str.split(" ");
          //System.out.println("foo: " + nodeinfo[2] + " bar: " +nodeinfo[3] );
          nodes_id.put(nodeinfo[2], new Integer(nodeinfo[3]));

          ClickNodeInfo cni = new ClickNodeInfo(nodeinfo[0], 7777);
          nodes.add(cni);
        }
      }
      in.close();
    } catch (IOException e) {
      throw new IllegalArgumentException("The infofile " + filename + " does not exist.");
    }
  }

  void setInfo(NodeInfo stats, HashMap<String, Integer> nodeIDs) {
    Iterator<ClickNodeInfo> li = nodes.iterator();
    while ( li.hasNext() ) {
      ClickNodeInfo cni = li.next();
      cni.setStatsInfo(stats);
      cni.setNodeIDs(nodeIDs);
    }
  }

  void openNodes() {
    Iterator<ClickNodeInfo> li = nodes.iterator();
    while ( li.hasNext() ) {
      ClickNodeInfo cli = li.next();
      cli.openConnection();
    }
  }

  void startNodes() {
    Iterator<ClickNodeInfo> li = nodes.iterator();
    while ( li.hasNext() ) {
      ClickNodeInfo cli = li.next();
      cli.start();
    }
  }

  void closeNodes() {
    Iterator<ClickNodeInfo> li = nodes.iterator();
    while ( li.hasNext() ) {
      li.next().closeConnection();
    }
  }

  void printList() {
    for ( int i = 0; i < nodes.size(); i++) {
      ClickNodeInfo cni = nodes.get(i);
      System.out.println(i + " " + cni.nodeName);
    }
  }

  public byte[] getData() {
    synchronized(semaphore) {
      return mssg;
    }
  }

  byte[] getNextData() {
    Vector<byte[]> nodeInfos = new Vector<byte[]>();
    int data_size = 1; //field for number of nodes
    int node_count = 0;

    for ( int i = 0; i < nodes.size(); i++) {
      ClickNodeInfo cni = nodes.get(i);
      byte[] data = cni.getInfo();

      if ( data != null ) {
        nodeInfos.add(data);
        data_size += data.length;
        node_count++;
      }
    }

    //System.out.println(data_size);
    byte[] result = new byte[data_size + 1]; // + 1 for end marker (127)

    result[0] = (byte)node_count;
    int dataIndex = 1;

    for ( int i = 0; i < node_count; i++) {
      byte[] data = nodeInfos.get(i);
      if ( data != null ) {
        System.arraycopy(data, 0, result, dataIndex, data.length);
        dataIndex += data.length;
      }
    }

    result[dataIndex] = (byte)127;

    return result;
  }

  public void setNextData(byte[] newmssg) {

    long storeLast = lastUpdate;
    lastUpdate = System.currentTimeMillis();

    long diff = lastUpdate - storeLast;
    double fps = 1000.0;
    fps /= (double)diff;
    synchronized(semaphore) {
       mssg = newmssg;
    }
    if (false) {
      for (int j = 0; j < mssg.length; j++) {
        byte b = mssg[j];
        System.out.print(b + " ");
      }
      System.out.println();
    }
  }

  public void run() {
    try {
      while (true) {
        setNextData(getNextData());
        Thread.sleep(200); // emulates new data
      }
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
  }
}

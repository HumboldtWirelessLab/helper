package statscollector;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

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

  private byte[] mssg;
  public long lastUpdate = 0;
  private List<ClickNodeInfo> nodes;
  private StatsInfo statsInfo = null;

  public DataDispatcher(String nodelist, StatsInfo stats) {
    statsInfo = stats;
    loadNodes(nodelist);
    setStatsInfo(stats);
    printList();
    openNodes();
    startNodes();
    mssg = new byte[1 + nodes.size() * (statsInfo.getSize() + 1) + 1];
  }

  void loadNodes(String filename) {
    nodes = new ArrayList<ClickNodeInfo>();
    String str;

    try {
      BufferedReader in = new BufferedReader(new FileReader(filename));
      while ((str = in.readLine()) != null) {
        if ( ! str.contains("#") ) {
          ClickNodeInfo cni = new ClickNodeInfo(str, 7777);
          nodes.add(cni);
        }
      }
      in.close();
    } catch (IOException e) {
      throw new IllegalArgumentException("The infofile " + filename + " does not exist.");
    }
  }

  void setStatsInfo(StatsInfo stats) {
    Iterator<ClickNodeInfo> li = nodes.iterator();
    while ( li.hasNext() ) {
      li.next().setStatsInfo(stats);
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

  private byte[] nextSample() {
    byte[] lastmsg = getNewData();
    byte[] mssg = getData();
    return mssg;
  }

  byte[] getData() {
    byte[] result = new byte[1 + nodes.size() * (statsInfo.getSize() + 1) + 1];

    result[0] = (byte)nodes.size();
    for ( int i = 0; i < nodes.size(); i++) {
      ClickNodeInfo cni = nodes.get(i);
      String[] l = cni.getInfo();

      for ( int j = 0; j < statsInfo.getSize(); j++) {
        if (l[j] != null)
          result[1 + ((j * nodes.size()) + i)] = (new Integer(l[j])).byteValue();
        else
          result[1 + ((j * nodes.size()) + i)] = 0;
      }
    }

    for ( int i = 0; i < nodes.size(); i++) {
      ClickNodeInfo cni = nodes.get(i);
      result[1 + nodes.size() * statsInfo.getSize() + i] = cni.ip.getAddress()[3];
    }

    result[1 + nodes.size() * (statsInfo.getSize()+1)] = 127;

    return result;
  }

  public void run() {
    try {
      while (true) {
        setNewData(nextSample());
        Thread.sleep(500); // emulates new data
      }
    } catch (InterruptedException e) {
      e.printStackTrace();
    }
  }

  public synchronized void setNewData(byte[] newmssg) {
    System.arraycopy(newmssg, 0, mssg, 0, newmssg.length);
    long storeLast = lastUpdate;
    lastUpdate = System.currentTimeMillis();

    long diff = lastUpdate - storeLast;
    double fps = 1000.0;
    fps /= (double)diff;
    if (true) {
      //System.out.print("new data: " + lastUpdate + " " + fps + " ");
      for (int j = 0; j < mssg.length; j++) {
        byte b = mssg[j];
        //System.out.print(b + " ");
      }
      //System.out.println();
    }
  }

  public synchronized byte[] getNewData() {
    return mssg;
  }
}

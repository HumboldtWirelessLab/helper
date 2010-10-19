import java.io.*;
import java.net.*;
import java.util.*;

/**
 * Transmits channel load statistics via TCP to Matlab TCP Client.
 */
public class ChanLoadDispatcherTCP {

  class ClickNodeInfo extends Thread {
    String nodeName;
    ClickConnection cc = null;
    InetAddress ip = null;
    int port;
    String lastValue = null;

    ClickNodeInfo(String nodeName, int port) {
      this.nodeName = nodeName;
      this.port = port;
    }

    public void run() {
      while (true) {
        lastValue = readInfo("ate", "busy");
        try {
          sleep(50);
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
      }
    }

    void openConnection() {
      if ( ip == null ) {
        try {
          ip = InetAddress.getByName(nodeName);
        } catch(UnknownHostException e) {
          System.out.println("Unknown Host");
          return;
        }
      }

      if ( cc == null ) {
        System.out.println("New connection to " + nodeName + " IP: " + ip.getHostAddress());
        cc = new ClickConnection(ip, port);
        cc.openClickConnection();
      }
    }

    public String getInfo() {
      return lastValue;
    }

    private String readInfo(String element, String handler) {
      if ( cc != null ) {
        return cc.readHandler(element, handler);
      }

      return null;
    }

    void closeConnection() {
      if ( cc != null ) {
        cc.closeClickConnection();
        cc = null;
      }
    }
  }

  /**
   * Grabs new data from testbed.
   */
  private class DataDispatcher extends Thread {

    private byte[] mssg;
    private long lastUpdate = 0;
    private List nodes;

    private byte[] nextSample() {
      byte[] lastmsg = getNewData();
      byte[] mssg = getData();
      return mssg;
    }

    public DataDispatcher(String nodelist) {
      loadNodes(nodelist);
      printList();
      openNodes();
      mssg = new byte[nodes.size() + 1];
    }

    List loadNodes(String filename) {
      nodes = new ArrayList();
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

      return nodes;
    }

    void openNodes() {
      Iterator li = nodes.iterator();
      while ( li.hasNext() ) {
        ((ClickNodeInfo)li.next()).openConnection();
        ((ClickNodeInfo)li.next()).start();
      }
    }

    void closeNodes() {
      Iterator li = nodes.iterator();
      while ( li.hasNext() ) {
        ((ClickNodeInfo)li.next()).closeConnection();
      }
    }

    void printList() {
      for ( int i = 0; i < nodes.size(); i++) {
        ClickNodeInfo cni = (ClickNodeInfo)nodes.get(i);
        System.out.println(i + " " + cni.nodeName);
      }
    }

    byte[] getData() {
      byte[] result = new byte[nodes.size() + 1/* * 2*/];

      for ( int i = 0; i < nodes.size(); i++) {
        ClickNodeInfo cni = (ClickNodeInfo)nodes.get(i);
        String l = cni.getInfo();
  //      System.out.println("RES: " + l);
  //      result[(i << 1)] = (byte)i;
  //      result[(i << 1) + 1] = (new Integer(l)).byteValue();
        if (l != null)
          result[i] = (new Integer(l)).byteValue();
      }
      result[result.length-1] = 127;

      return result;
    }

    public void run() {
      try {
        while (true) {
          setNewData(nextSample());
          Thread.sleep(50); // emulates new data
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
        System.out.print("new data: " + lastUpdate + " " + fps + " ");
        for (int j = 0; j < mssg.length; j++) {
          byte b = mssg[j];
          System.out.print(b + " ");
        }
        System.out.println();
      }
    }

    public synchronized byte[] getNewData() {
      return mssg;
    }
  }

  private class ClientDispatcher extends Thread {

    private DataDispatcher dataDispatcher;
    private Socket client;
    private OutputStream out = null;
    private InputStream in = null;
    private long lastRead = 0;

    public ClientDispatcher(Socket client, DataDispatcher dataDispatcher) {
      this.client = client;
      this.dataDispatcher = dataDispatcher;
      System.out.println("new client connected: " + client.getInetAddress());
    }

    public void run() {
      while (true) {
        try {
          out = client.getOutputStream();
          in = client.getInputStream();


          // check if new data is available
          if (lastRead < dataDispatcher.lastUpdate) {
            lastRead = dataDispatcher.lastUpdate;
            byte[] mssg = dataDispatcher.getNewData();
            out.write(mssg);
            System.out.println("Send data");
            out.flush();
          } else {
            // no new data available
          }
          sleep(100); // wait for new data to become available
        } catch (Exception e) {
          //e.printStackTrace();
          System.err.println("Network error; close connection");
          try {
            out.close();
            in.close();
            client.close();
          } catch (IOException e1) {
            e1.printStackTrace();
          } finally {
            break; // stop thread
          }
        }
      }
    }
  }

  private Random r = new Random();
  //private List clientLst = new ArrayList();
  private DataDispatcher dataDispatcher;

  public void startDataDispatcher(String nodelist) {
    dataDispatcher = new DataDispatcher(nodelist);
    dataDispatcher.start();    
  }

  public void handleClients() {
    int port = 60001;

    ServerSocket server;
    Socket client = null;
    try {
      server = new ServerSocket(port);
//      server.setTrafficClass(IPTOS_LOWDELAY);
//      server.setTcpNoDelay(true);

      while (true) {
          client = server.accept();
          client.setTrafficClass(0x10);
          client.setTcpNoDelay(true);
          ClientDispatcher cd = new ClientDispatcher(client, dataDispatcher);
          //clientLst.add(cd);
          cd.start();

    }
    } catch(Exception e) {
      e.printStackTrace();
    }
  }

  public static void main(String[] args) {
    ChanLoadDispatcherTCP cdtcp = new ChanLoadDispatcherTCP();
    cdtcp.startDataDispatcher(args[0]);
    cdtcp.handleClients();
  }
}
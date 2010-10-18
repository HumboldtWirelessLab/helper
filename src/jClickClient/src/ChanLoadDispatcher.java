import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.net.*;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Random;

/**
 * Transmits channel load statistics via UDP to Matlab UDP Server.
 */
public class ChanLoadDispatcher {

  class ClickNodeInfo {
    String nodeName;
    ClickConnection cc = null;
    InetAddress ip = null;
    int port;

    ClickNodeInfo(String nodeName, int port) {
      this.nodeName = nodeName;
      this.port = port;
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

      if ( cc == null ) cc = new ClickConnection(ip, port);
    }

    String readInfo(String element, String handler) {
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

  List nodes;

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
    byte[] result = new byte[nodes.size() * 2];

    for ( int i = 0; i < nodes.size(); i++) {
      ClickNodeInfo cni = (ClickNodeInfo)nodes.get(i);
      String l = cni.readInfo("ate", "busy");
      result[(i << 1) + 1] = (byte)i;
      result[(i << 1) + 1] = (new Integer(l)).byteValue();
    }

    return result;
  }


  static Random r = new Random();

  public static void main(String[] args) {
    String host = "localhost";
    int port = 5019;
    DatagramSocket socket = null;

    ChanLoadDispatcher cld = new ChanLoadDispatcher();
    System.out.println("ARG: " + args[0]);
    cld.loadNodes(args[0]);
    cld.printList();

    if ( false ) {
    try {
      InetAddress addr = InetAddress.getByName(host);
      socket = new DatagramSocket();
      socket.setReuseAddress(true);

      byte[] mssg;
      for (;;) {
        mssg = cld.getData();
        System.out.print("tx: ");
        for (int j = 0; j < mssg.length; j++) {
          byte b = mssg[j];
          System.out.print(b + " ");
        }
        System.out.println();
        
        DatagramPacket packet = new DatagramPacket(mssg, mssg.length, addr, port);
        socket.send(packet);
        Thread.sleep(100);
      }

    } catch (Exception e) {
      e.printStackTrace();
    } finally {
      if (socket != null)
        socket.close();

      cld.closeNodes();
    }
    }
  }
}

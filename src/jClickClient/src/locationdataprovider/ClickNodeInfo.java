package locationdataprovider;

import click.ClickConnection;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.HashMap;

class ClickNodeInfo extends Thread {
  Boolean semaphore = Boolean.TRUE;
  String nodeName;

  ClickConnection cc = null;
  public InetAddress ip = null;
  int port;

  NodeInfo statsInfo;
  HashMap<String, Integer> nodeIDs = null;
  public byte[] lastValues = null;
  public int id = -1;

  ClickNodeInfo(String nodeName, int port) {
    this.nodeName = nodeName;
    this.port = port;
  }

  public void run() {
    //System.out.println("Node: " + ip.getHostAddress());
    boolean read_error = false;
    byte[] nextValues = null;


    while (true) {
      if ( read_error) cc.skipIn(10);

      read_error = false;
      //System.out.println("Node: " + ip.getHostAddress());

      String xml_value = readInfo(statsInfo.element, statsInfo.handler);

      //System.out.println(xml_value);

      if (xml_value != null ) {
        int new_id = XmlConverter.getID(xml_value);

        //System.out.println(ip.getHostAddress() + ": " + id + " " + new_id);

        if ( new_id != id ) {
          id = new_id;
          nextValues = XmlConverter.convert(xml_value, nodeIDs);

          /*
          for (int j = 0; j < lastValues.length; j++) {
            byte b = lastValues[j];
            System.out.print(b + " ");
          }
          System.out.println();
          */
        }

      } else {
        try {
          sleep(100);
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
        cc.skipIn(10);
      }

      read_error |= (nextValues == null);

      try {
        if ( read_error ) {
          System.out.println("Read error: " + ip.getHostAddress());
          sleep(1000);
        } else {
          setInfo(nextValues);
          sleep(200);
        }
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    }
  }

  public void setStatsInfo(NodeInfo statsInfo) {
    this.statsInfo = statsInfo;
  }

  public void setNodeIDs(HashMap<String, Integer> nodeIDs) {
    this.nodeIDs = nodeIDs;
  }

  void openConnection() {
    if (ip == null) {
      try {
        ip = InetAddress.getByName(nodeName);
      } catch (UnknownHostException e) {
        System.out.println("Unknown Host");
        return;
      }
    }

    if (cc == null) {
      System.out.println("New connection to " + nodeName + " IP: " + ip.getHostAddress());
      cc = new ClickConnection(ip, port);
      cc.openClickConnection();
    }
  }

  public byte[] getInfo() {
	synchronized(semaphore) {
	    return lastValues;
	}
  }

  public void setInfo(byte[] info) {
    if ( info != null ) {
	    synchronized(semaphore) {
	      lastValues = info;
      }
	  }
  }


  private String readInfo(String element, String handler) {
    if (cc != null) {
      return cc.readHandler(element, handler);
    }
    return null;
  }

  void closeConnection() {
    if (cc != null) {
      cc.closeClickConnection();
      cc = null;
    }
  }
}

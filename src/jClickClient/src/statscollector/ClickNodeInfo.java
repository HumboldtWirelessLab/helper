package statscollector;

import click.ClickConnection;

import java.net.InetAddress;
import java.net.UnknownHostException;

class ClickNodeInfo extends Thread {
  String nodeName;

  ClickConnection cc = null;
  InetAddress ip = null;
  int port;

  StatsInfo statsInfo;
  public String[] lastValues = null;

  ClickNodeInfo(String nodeName, int port) {
    this.nodeName = nodeName;
    this.port = port;
  }

  public void run() {
    while (true) {
      for( int i = 0; i < statsInfo.getSize(); i++) {
        StatsInfo.SingleStat st = statsInfo.getByIndex(i);
        lastValues[i] = readInfo(st.element, st.handler);
      }
      try {
        sleep(50);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    }
  }

  public void setStatsInfo(StatsInfo statsInfo) {
    this.statsInfo = statsInfo;
    lastValues = new String[statsInfo.getSize()];
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

  public String[] getInfo() {
    return lastValues;
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
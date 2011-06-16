package locationdataprovider;

import java.net.*;

/**
 * Transmits channel load statistics via TCP to
 * Matlab TCP Client.
 */
public class LocationDataProvider {

  private DataDispatcher dataDispatcher;

  public void startDataDispatcher(String nodelist, NodeInfo si) {
    dataDispatcher = new DataDispatcher(nodelist, si);
    dataDispatcher.start();    
  }

  public void handleClients(int port) {
    ServerSocket server;
    Socket client = null;
    try {
      server = new ServerSocket(port);

      while (true) {
        client = server.accept();
        client.setTrafficClass(0x10);
        client.setTcpNoDelay(true);

        ClientDispatcher cd = new ClientDispatcher(client, dataDispatcher);
        cd.start();
      }
    } catch(Exception e) {
      e.printStackTrace();
    }
  }

  public void sendDataUDP(String host, int port) {
    DatagramSocket socket = null;

    try {
      InetAddress addr = InetAddress.getByName(host);
      socket = new DatagramSocket();
      socket.setReuseAddress(true);

      byte[] mssg;

      for (;;) {
        mssg = dataDispatcher.getData();
        /*System.out.print("tx: ");
        for (int j = 0; j < mssg.length; j++) {
          byte b = mssg[j];
          System.out.print(b + " ");
        }
        System.out.println();*/

        DatagramPacket packet = new DatagramPacket(mssg, mssg.length, addr, port);
        socket.send(packet);
        Thread.sleep(1000);
      }
    } catch (Exception e) {
      e.printStackTrace();
    } finally {
      if (socket != null) socket.close();
      dataDispatcher.closeNodes();
    }
  }

  public static void main(String[] args) {
    LocationDataProvider cdtcp = new LocationDataProvider();
    NodeInfo si = new NodeInfo("wifidevice/cst", "stats_xml", 1000);
    cdtcp.startDataDispatcher(args[0],si);
    cdtcp.handleClients(60001);
  }
}

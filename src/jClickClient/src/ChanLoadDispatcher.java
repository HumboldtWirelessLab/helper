import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.util.Random;

/**
 * Transmits channel load statistics via UDP to Matlab UDP Server.
 */
public class ChanLoadDispatcher {

  static Random r = new Random();

  public static void main(String[] args) {
    String host = "localhost";
    int port = 5019;
    DatagramSocket socket = null;

    try {
      InetAddress addr = InetAddress.getByName(host);
      socket = new DatagramSocket();
      socket.setReuseAddress(true);

      byte[] mssg = new byte[8];
      for (;;) {
        mssg = nextSample(mssg);
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
    }
  }

  // generate some random data for testing only
  private static byte[] nextSample(byte[] lastmsg) {
    byte[] mssg = new byte[8];
    for (int i = 0; i < mssg.length; i++) {
      mssg[i] = (byte)Math.abs((byte) (lastmsg[i] + 3*r.nextGaussian()));
    }
    return mssg;
  }
}

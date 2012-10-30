import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;

/**
 * Created by IntelliJ IDEA.
 * User: robert
 * Date: 19.01.12
 * Time: 16:11
 * To change this template use File | Settings | File Templates.
 */
public class ClickWatchConnector implements Runnable{

  Thread listener;
  ServerSocket server;

  int interval;

  public ClickWatchConnector (int port, int interval) {
    this.interval = interval;

    try {
      server = new ServerSocket(port);
      listener = new Thread(this);
      listener.start();
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  public void run() {
    try {
      while(true) {
        Socket client = server.accept();
        new ClickInstanceController(client, interval).start();
      }
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  public static void main(String args[]) {
    ClickWatchConnector cwc = new ClickWatchConnector(2000, 500);
    System.out.println("Running");
  }

}

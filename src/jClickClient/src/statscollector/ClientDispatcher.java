package statscollector;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;

/**
 * Created by IntelliJ IDEA.
 * User: robert
 * Date: 19.10.2010
 * Time: 21:00:46
 * To change this template use File | Settings | File Templates.
 */
public class ClientDispatcher extends Thread {
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

package click;

import click.ControlSocket;

import java.net.InetAddress;
import java.io.IOException;

/**
 * Created by IntelliJ IDEA.
 * User: robert
 * Date: 24.10.2009
 * Time: 00:28:02
 * To change this template use File | Settings | File Templates.
 */

public class ClickConnection {

  InetAddress clickipaddr;
  int clickport;
  ControlSocket cliccs;

  int noConnectionCount;

  public ClickConnection(InetAddress clickipaddr, int clickport) {
    this.clickipaddr = clickipaddr;
    this.clickport = clickport;
    this.cliccs = null;
    this.noConnectionCount = 0;
  }

  public void openClickConnection() {
     if ( cliccs != null ) {
       cliccs.close();
       cliccs = null;
     }

     try {
       cliccs = new ControlSocket(clickipaddr, clickport);
     } catch ( IOException e) {
       cliccs = null;
       //System.out.println("Unable to connect to AP (" + clickipaddr + ")");
       //e.printStackTrace();
     }
  }

  public String readHandler(String element, String handler) {
    char[] resultchar;

    try {
      if (cliccs != null)
          resultchar = cliccs.read(element, handler);
      else {
          connectionFailed();
          return null;
      }
    } catch ( Exception e) {
      connectionFailed();
      return null;
    }

    return new String(resultchar);
  }

  public int writeHandler(String element, String handler, String data) {
    try {
      cliccs.write(element,handler,data);
    } catch ( Exception e) {
      e.printStackTrace();
      return -1;
    }

    return 0;
  }

  public int skipIn(int n) {
    if (cliccs == null) return 0;
    return cliccs.skipIn(n);
  }

  public int closeClickConnection() {
    cliccs.close();
    return 0;
  }

  private void connectionFailed() {
    noConnectionCount++;
    if ( noConnectionCount > 10 ) {
      System.out.print("Lost click connection to " + clickipaddr +". Reconnect ... ");
      openClickConnection();
      if ( cliccs == null ) System.out.println("Failed.");
      else System.out.println("OK.");
      noConnectionCount=0;
    }
  }
}

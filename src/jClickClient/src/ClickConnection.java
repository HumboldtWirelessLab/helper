import click.ControlSocket;

import java.net.InetAddress;
import java.io.IOException;
import static java.lang.System.out;

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

  public ClickConnection(InetAddress clickipaddr, int clickport) {
    this.clickipaddr = clickipaddr;
    this.clickport = clickport;
    this.cliccs = null;
  }

  public void openClickConnection() {
     if ( cliccs != null ) {
       cliccs.close();
       cliccs = null;
     }

     try {
       cliccs = new ControlSocket(clickipaddr, clickport);
     } catch ( IOException e) {
       out.println("Unable to connect to AP");
       e.printStackTrace();
     }
  }

  public String readHandler(String element, String handler) {
    char[] resultchar;

    try {
      resultchar = cliccs.read(element, handler);
    } catch ( Exception e) {
      e.printStackTrace();
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

  public int closeClickConnection() {
    cliccs.close();
    return 0;
  }
}

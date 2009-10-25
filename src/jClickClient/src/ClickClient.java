import java.net.InetAddress;
import java.net.UnknownHostException;

/**
 * Created by IntelliJ IDEA.
 * User: robert
 * Date: 20.07.2008
 * Time: 14:34:47
 * To change this template use File | Settings | File Templates.
 */

public class ClickClient {

  private static void printHelp(String[] args) {
    System.out.println("Use: java ClickClient read|write ip port element handler [data]");
    return;
  }

  public static void main(String[] args) {
    if ( args.length < 1 ) {
      printHelp(args);
      return;
    }

    if ( args[0].equalsIgnoreCase("read") ) {
      if ( args.length < 5 ) {
        printHelp(args);
        return;
      }

      InetAddress ip;
      try {
        ip = InetAddress.getByName(args[1]);
      } catch(UnknownHostException e) {
        System.out.println("Unknown Host");
        return;
      }

      Integer p = new Integer(args[2]);
      ClickConnection cc = new ClickConnection(ip, p.intValue());
      cc.openClickConnection();
      String result = cc.readHandler(args[3], args[4]);
      System.out.println(result);
      cc.closeClickConnection();
    }
    else if ( args[0].equalsIgnoreCase("write") ) {
      if ( args.length < 6 ) {
        printHelp(args);
        return;
      }

      InetAddress ip;
      try {
        ip = InetAddress.getByName(args[1]);
      } catch(UnknownHostException e) {
        System.out.println("Unknown Host");
        return;
      }

      Integer p = new Integer(args[2]);
      ClickConnection cc = new ClickConnection(ip, p.intValue());
      cc.openClickConnection();
      int result = cc.writeHandler(args[3], args[4], args[5]);
      cc.closeClickConnection();

    } else {
      System.out.println("Unknown option: " + args[0] + " !");
      printHelp(args);
    }
  }

}

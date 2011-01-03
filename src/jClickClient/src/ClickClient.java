import click.ClickConnection;

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
    System.err.println("Use: java ClickClient read|write ip port element handler [data]");
  }

  public static void main(String[] args) {
    if ( args.length < 1 ) {
      printHelp(args);
      System.exit(1);
    }

    if ( args[0].equalsIgnoreCase("read") ) {
      if ( args.length < 5 ) {
        printHelp(args);
        System.exit(1);
      }

      InetAddress ip = null;
      try {
        ip = InetAddress.getByName(args[1]);
      } catch(UnknownHostException e) {
        System.err.println("Unknown Host");
        System.exit(1);
      }

      Integer p = new Integer(args[2]);
      ClickConnection cc = new ClickConnection(ip, p.intValue());
      cc.openClickConnection();
      String result = cc.readHandler(args[3], args[4]);
      if ( result != null )
        System.out.println(result);
      else {
        cc.closeClickConnection();
//        System.err.println("Error");
        System.exit(1);
      }

      cc.closeClickConnection();
    }
    else if ( args[0].equalsIgnoreCase("write") ) {
      if ( args.length < 6 ) {
        printHelp(args);
        System.exit(1);
      }

      InetAddress ip = null;
      String command;
      command = args[5];
      for ( int i = 6; i < args.length; i++) command = command + " " + args[i];
      //System.out.println("Command: " + command);

      try {
        ip = InetAddress.getByName(args[1]);
      } catch(UnknownHostException e) {
        System.err.println("Unknown Host");
        System.exit(1);
      }

      Integer p = new Integer(args[2]);
      ClickConnection cc = new ClickConnection(ip, p.intValue());
      cc.openClickConnection();
      int result = cc.writeHandler(args[3], args[4], command);
      cc.closeClickConnection();

      if ( result != 0 ) System.exit(1);

    } else {
      System.out.println("Unknown option: " + args[0] + " !");
      printHelp(args);
      System.exit(1);
    }
  }

}

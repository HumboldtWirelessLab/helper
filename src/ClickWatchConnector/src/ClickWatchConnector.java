import DataStorage.TimeSerie;
import DataStorage.TimeSeriesEntry;
import MatlabConnector.MatlabConnector;

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

  ClickWatchNodeDB cwNDb = null;

  String handlerFile = null;

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

    cwNDb = new ClickWatchNodeDB();
  }

  public void setHandlerFile(String handlerFile) {
    this.handlerFile = handlerFile;
  }

  public void run() {
    try {
      while(true) {
        Socket client = server.accept();

        ClickInstanceController cic = new ClickInstanceController(client, interval);
        cic.setClickWatchNodeDB(cwNDb);
        if ( handlerFile != null ) cic.loadHandlerFromFile(handlerFile);

        cic.start();
      }
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  public static void main(String args[]) {
    //PlotConnector.ClickHistPlot.start();
    MatlabConnector mc = new MatlabConnector();
    ClickWatchConnector cwc = new ClickWatchConnector(2000, 1000);

    if ( args.length > 0 ) cwc.setHandlerFile(args[0]);
    System.out.println("Running");

    while (true) {
      try{
        Thread.sleep(10);
      } catch (InterruptedException e) {
        System.out.println("Warten wurde unterbrochen");
        break;
      }
      //System.out.println(cwc.cwNDb.size());
      if ( cwc.cwNDb.size() > 0 ) {
        ClickInstanceController cic = cwc.cwNDb.getId(0);
        TimeSerie ts = cic.readHandlerDbXslt.getTimeSeriesDB().get("lt.links");
        TimeSeriesEntry tse = ts.getLast();
        if ( tse != null ) {
          String lastValue = tse.getValue();
          if ( (lastValue != null) && (mc != null)) {
            mc.toMatlabArray("linkmetrics",lastValue);
            mc.plotHist("linkmetrics",1);
          }
        }
      }
    }
    mc.close();
  }

}

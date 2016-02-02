import DataProcessor.XsltProcessor;
import DataStorage.ReadHandlerDataStorage;

import javax.xml.transform.*;
import javax.xml.transform.stream.StreamSource;
import java.io.File;
import java.io.IOException;

import java.io.*;
import java.net.Socket;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.StringTokenizer;

/**
 * Created by IntelliJ IDEA.
 * User: robert
 * Date: 19.01.12
 * Time: 16:16
 * To change this template use File | Settings | File Templates.
 */
public class ClickInstanceController extends Thread {

  public static final int MODE_INIT = 0;
  public static final int MODE_SCHEDULING = 1;
  public static final int MODE_HANDLER_READ = 2;
  public static final int MODE_HANDLER_WRITE = 3;
  public static final int MODE_FINISHED = 4;

  Socket s;
  OutputStream out;
  InputStream in;

  String nodeName = "n/a";

  int scheduleInterval;

  long current_time = 0;

  int currentMode;

  ClickWatchNodeDB cwNDb = null;

  List<String> writeHandler = new ArrayList<String>();
  List<String> readHandler = new ArrayList<String>();

  HashMap<String,XsltProcessor> readHandlerXslt = new HashMap<String,XsltProcessor>();

  public ReadHandlerDataStorage readHandlerDbXml = null;
  public ReadHandlerDataStorage readHandlerDbXslt = null;

  boolean debug = false;

  public ClickInstanceController(Socket s, int scheduleInterval) throws IOException {
    this.s = s;
    out = s.getOutputStream();
    in = s.getInputStream();
    this.scheduleInterval = scheduleInterval;

    readHandlerDbXml = new ReadHandlerDataStorage();
    readHandlerDbXslt = new ReadHandlerDataStorage();

    currentMode = MODE_INIT;
  }

  public void loadHandlerFromFile(String filename) {
    try {
      BufferedReader f = new BufferedReader(new FileReader(filename));
      String line = null;

      while ( (line = f.readLine() ) != null) {
        if ( !line.contains("#")) {
          String handler;
          String xsltFile = null;

          StringTokenizer configSplitter = new StringTokenizer(line);
          handler = configSplitter.nextToken();

          if ( configSplitter.hasMoreTokens() )
            xsltFile = configSplitter.nextToken();

          readHandler.add(handler);
          if ( readHandlerDbXml != null ) readHandlerDbXml.addTimeSerie(handler);

          if ( xsltFile != null ) {
            readHandlerXslt.put(handler, new XsltProcessor(xsltFile));
            if ( readHandlerDbXslt != null ) readHandlerDbXslt.addTimeSerie(handler);
          }
        }
      }
    } catch(IOException e) {
      System.out.println("File " + filename + " not found!");
    }
  }

  public void setClickWatchNodeDB(ClickWatchNodeDB cwNDb) {
    this.cwNDb = cwNDb;
  }

  public String processXML(String handler, String xml_string) {
    if (readHandlerXslt.containsKey(handler)) {
      return (readHandlerXslt.get(handler).process(xml_string));
    }
    return null;
  }

  public void run() {
    byte[] inBuffer = new byte[1000024];
    String currentReadHandler = null;

    int num = 0;
    int readHandlerIndex = 0;

    try {
      while (true) {

        String inputString = new String("");

        num = 0;
        while (in.available() > 0) {
          int numNext = in.read(inBuffer);
          inputString += new String(inBuffer, 0, numNext);
          num += numNext;
        }

        if ( num > 0 ) {

          if ( debug ) System.out.println("Get something: " + inputString);

          String out_str = null;

          switch ( currentMode ) {
            case MODE_INIT: {
                String initCmd = inputString;
                StringTokenizer cmdStrTok = new StringTokenizer(initCmd);
                String cmd = cmdStrTok.nextToken();
                if ( cmd.equals("init")) {
                  if ( cmdStrTok.hasMoreTokens() ) {
                    String nodeName = cmdStrTok.nextToken();
                    cwNDb.addCIC(nodeName,this);
                    System.out.println("Name: " + nodeName);
                  }
                  out_str = new String("schedule " + scheduleInterval);
                  currentMode = MODE_SCHEDULING;
                } else {
                  System.out.println("Unknown operation in MODE_INIT");
                }
                break;
              }
            case MODE_SCHEDULING: {
                if ( inputString.equals("schedule")) {
                  current_time += scheduleInterval;
                  if ( debug ) System.out.println("CurrentTime: " + current_time);

                  if ( readHandler.size() > 0 ) {
                    currentMode = MODE_HANDLER_READ;
                    currentReadHandler = readHandler.get(readHandlerIndex);
                    out_str = new String("read " + currentReadHandler);
                    if ( debug ) System.out.println("READHANDLER: " + out_str );
                    readHandlerIndex++;
                  } else if ( writeHandler.size() > 0 ) {
                    currentMode = MODE_HANDLER_WRITE;
                  } else {
                    out_str = new String("schedule " + scheduleInterval);
                  }
                } else if ( inputString.equals("finish")) {
                  out_str = new String("finish");
                  currentMode = MODE_FINISHED;
                } else {
                  if ( debug ) System.out.println("Unknown operation in MODE_SCHEDULING");
                }
                break;
              }
            case MODE_HANDLER_READ: {
                assert(currentReadHandler!=null);

                String xml_out = inputString;
                String xslt_out = processXML(currentReadHandler, xml_out);



                if ( readHandlerDbXml != null )
                  readHandlerDbXml.addValue(currentReadHandler,xml_out);

                if (xslt_out != null) {
                  if ( readHandlerDbXslt != null )
                    readHandlerDbXslt.addValue(currentReadHandler,xslt_out);

                  if (readHandlerDbXslt.size() == 1) {
                    System.out.println("L:" + xml_out.length());
                    System.out.println(xml_out);
                  }
                }
                System.out.println("DB size: " + readHandlerDbXml.size() + " " + readHandlerDbXslt.size());

                if ( readHandler.size() > readHandlerIndex) {
                  currentReadHandler = readHandler.get(readHandlerIndex);
                  out_str = new String("read " + currentReadHandler);
                  readHandlerIndex++;
                } else {
                  readHandlerIndex = 0;
                  currentReadHandler = null;
                  out_str = new String("schedule " + scheduleInterval);
                  currentMode = MODE_SCHEDULING;
                }
                break;
              }
            case MODE_HANDLER_WRITE: {
                if ( inputString.equals("schedule")) {
                  if ( readHandler.size() > 0 ) {
                    currentMode = MODE_HANDLER_READ;
                    currentReadHandler = null;
                  } else if ( writeHandler.size() > 0 ) {
                    currentMode = MODE_HANDLER_WRITE;
                  }
                } else {
                  System.out.println("Unknown operation in MODE_SCHEDULING");
                }
                break;
              }
            case MODE_FINISHED: {
                System.out.println("Unknown operation in MODE_FINISHED");
                break;
              }

          }

          /* write next command */
          if ( (out_str != null) && (out_str.length() > 0) ) {
            if ( debug ) System.out.println(out_str);
            out.write(out_str.getBytes("ISO-8859-1"), 0, out_str.getBytes("ISO-8859-1").length);
          }

          /*if ( currentMode == MODE_SCHEDULING ) {
            try{
              Thread.sleep(10);
            } catch (InterruptedException e) {
              System.out.println("Warten wurde unterbrochen");
              break;
            }
          } */

          if ( currentMode == MODE_FINISHED ) break;

        } else {
          try {
            sleep(100);
          } catch (InterruptedException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
          }
        }
      }

      System.out.println("Thread finished");
    }
    catch(IOException e) {
      e.printStackTrace();
    }
  }

}

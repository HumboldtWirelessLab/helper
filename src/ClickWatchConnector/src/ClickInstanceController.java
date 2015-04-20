import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.util.ArrayList;
import java.util.List;

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

  int scheduleInterval;

  long current_time = 0;

  int currentMode;

  List<String> readHandler = new ArrayList<String>();
  List<String> writeHandler = new ArrayList<String>();

  boolean debug = false;

  public ClickInstanceController(Socket s, int scheduleInterval) throws IOException {
    this.s = s;
    out = s.getOutputStream();
    in = s.getInputStream();
    this.scheduleInterval = scheduleInterval;

    currentMode = MODE_INIT;

   // readHandler.add(new String("id.version"));
   // readHandler.add(new String("sys_info.systeminfo"));
   // readHandler.add(new String("version"));
   // readHandler.add(new String("classes"));
   // readHandler.add(new String("config"));
   // readHandler.add(new String("flatconfig"));
  }

  public void run() {
    byte[] inBuffer = new byte[1000024];

    int num;
    int readHandlerIndex = 0;

    try {
      while (true) {

        num = in.read(inBuffer);
        if ( num > 0 ) {

          if ( debug ) System.out.println("Get something: " + new String(inBuffer, 0, num));

          String out_str = null;

          switch ( currentMode ) {
            case MODE_INIT: {
                if ( new String(inBuffer, 0, num).equals("init")) {
                  out_str = new String("schedule " + scheduleInterval);
                  currentMode = MODE_SCHEDULING;
                } else {
                  System.out.println("Unknown operation in MODE_INIT");
                }
                break;
              }
            case MODE_SCHEDULING: {
                if ( new String(inBuffer, 0, num).equals("schedule")) {
                  current_time += scheduleInterval;
                  if ( debug ) System.out.println("CurrentTime: " + current_time);

                  if ( readHandler.size() > 0 ) {
                    currentMode = MODE_HANDLER_READ;
                    out_str = new String("read " + readHandler.get(readHandlerIndex));
                    if ( debug ) System.out.println("READHANDLER: " + out_str );
                    readHandlerIndex++;
                  } else if ( writeHandler.size() > 0 ) {
                    currentMode = MODE_HANDLER_WRITE;
                  } else {
                    out_str = new String("schedule " + scheduleInterval);
                  }
                } else if ( new String(inBuffer, 0, num).equals("finish")) {
                  out_str = new String("finish");
                  currentMode = MODE_FINISHED;
                } else {
                  if ( debug ) System.out.println("Unknown operation in MODE_SCHEDULING");
                }
                break;
              }
            case MODE_HANDLER_READ: {
                System.out.print(new String(inBuffer, 0, num));
                if ( readHandler.size() > readHandlerIndex) {
                  out_str = new String("read " + readHandler.get(readHandlerIndex));
                  readHandlerIndex++;
                } else {
                  readHandlerIndex = 0;
                  out_str = new String("schedule " + scheduleInterval);
                  currentMode = MODE_SCHEDULING;
                }
                break;
              }
            case MODE_HANDLER_WRITE: {
                if ( new String(inBuffer, 0, num).equals("schedule")) {
                  if ( readHandler.size() > 0 ) {
                    currentMode = MODE_HANDLER_READ;
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

          if ( (out_str != null) && (out_str.length() > 0) ) {
            if ( debug ) System.out.println(out_str);
            out.write(out_str.getBytes("ISO-8859-1"), 0, out_str.getBytes("ISO-8859-1").length);
          }

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

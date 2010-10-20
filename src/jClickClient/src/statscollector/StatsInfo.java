package statscollector;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: robert
 * Date: 20.10.2010
 * Time: 09:40:53
 * To change this template use File | Settings | File Templates.
 */
public class StatsInfo {
  class SingleStat {
    String element;
    String handler;

    int type;
    int frequence;

    SingleStat(String element, String handler) {
      this.element = element;
      this.handler = handler;
      this.type = 0;
      this.frequence = 0;
    }
  }

  List<SingleStat> statsList;

  public StatsInfo(String filename) {
    loadStatsInfo(filename);
    printStats();
  }

  void loadStatsInfo(String filename) {
    statsList = new ArrayList<SingleStat>();
    String str;

    try {
      BufferedReader in = new BufferedReader(new FileReader(filename));
      while ((str = in.readLine()) != null) {
        if ( ! str.contains("#") ) {
          String stats[] = str.split(";");
          statsList.add(new SingleStat(stats[0],stats[1]));
        }
      }
      in.close();
    } catch (IOException e) {
      throw new IllegalArgumentException("The statsfile " + filename + " does not exist.");
    }
  }

  int getSize() {
    return statsList.size();
  }

  SingleStat getByIndex(int i) {
    return statsList.get(i);
  }

  void printStats() {
    Iterator<SingleStat> li = statsList.iterator();
    while ( li.hasNext() ) {
      SingleStat st = li.next();
      System.out.println("Element: " + st.element + " Handler: " + st.handler);
    }
  }
}

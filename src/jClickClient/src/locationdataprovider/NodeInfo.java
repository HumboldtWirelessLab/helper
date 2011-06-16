package locationdataprovider;

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
public class NodeInfo {
  String element;
  String handler;

  int type;
  int frequence;


  public NodeInfo(String element, String handler, int frequence) {
    this.element = element;
    this.handler = handler;
    this.frequence = frequence;
  }
}

package locationdataprovider;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.HashMap;
import java.io.File;
import java.io.IOException;
import java.util.List;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;

/**
 * Created by IntelliJ IDEA.
 * User: robert
 * Date: 16.06.11
 * Time: 00:12
 * To change this template use File | Settings | File Templates.
 */
public class XmlConverter {

  static int getID(String xml_string) {
    int result = -1;

    SAXBuilder builder = new SAXBuilder();

    try {

      InputStream is = new ByteArrayInputStream(xml_string.getBytes());

    	Document document = (Document) builder.build(is);
      if ( document == null ) return -1;

      Element rootNode = document.getRootElement();
      if ( rootNode == null ) return -1;

      result = new Integer(rootNode.getAttributeValue("id")).intValue();

    } catch(IOException io) {
       System.out.println(io.getMessage());
    } catch(JDOMException jdomex) {
      System.out.println(jdomex.getMessage());
    }

    return result;
  }

  static byte[] convert(String xml_string, HashMap<String,Integer> nodes) {
    byte[] result = null;

    SAXBuilder builder = new SAXBuilder();

    try {

      InputStream is = new ByteArrayInputStream(xml_string.getBytes());

    	Document document = (Document) builder.build(is);
      if ( document == null ) return null;

      Element rootNode = document.getRootElement();
      if ( rootNode == null ) return null;

      List nb_list = rootNode.getChild("neighbourstats").getChildren("nb");

      if ( nb_list == null ) {
        System.out.println("List null");
      } else {
        //System.out.println("Neighbours: " + nb_list.size());

        int neighbours = 0;

        for (int i=0; i< nb_list.size(); i++) {
          Element node = (Element) nb_list.get(i);

          if ( nodes.containsKey(node.getAttributeValue("addr")) )
            neighbours++;
        }

        result = new byte[2 + neighbours * 6];

        result[0] = nodes.get(rootNode.getAttributeValue("node")).byteValue();
        result[1] = (byte)neighbours;

        int index = 2;

        for (int i=0; i< nb_list.size(); i++) {
          Element node = (Element) nb_list.get(i);

          if ( nodes.containsKey(node.getAttributeValue("addr")) ) {
            result[index] = nodes.get(node.getAttributeValue("addr")).byteValue();
            result[index+1] = new Byte(node.getAttributeValue("rssi")).byteValue();
            Element c = node.getChild("rssi_extended").getChild("ctl");
            result[index+2] = new Byte(c.getAttributeValue("rssi0")).byteValue();
            result[index+3] = new Byte(c.getAttributeValue("rssi1")).byteValue();
            result[index+4] = (byte)(new Integer(node.getAttributeValue("pkt_cnt")).intValue() / 256);
            result[index+5] = (byte)(new Integer(node.getAttributeValue("pkt_cnt")).intValue() % 256);

            index += 6;
          }
        }
      }
    } catch(IOException io) {
       System.out.println(io.getMessage());
    } catch(JDOMException jdomex) {
      System.out.println(jdomex.getMessage());
    }

    return result;
  }
}

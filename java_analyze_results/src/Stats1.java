import com.sun.org.apache.xerces.internal.dom.AttrNSImpl;
import com.sun.org.apache.xerces.internal.dom.DeferredAttrImpl;
import com.sun.org.apache.xml.internal.dtm.DTMIterator;
import com.sun.org.apache.xml.internal.dtm.ref.DTMNodeList;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.*;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import java.io.*;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;

/**
 *
 */
public class Stats1 {

    private DocumentBuilderFactory factory;
    private TransformerFactory transFact;
    private XPath xpath = XPathFactory.newInstance().newXPath();
    private Hashtable nodeMacToName = new Hashtable(101);
    private Hashtable nodeNameToMac = new Hashtable(101);

    private String baseDir;

    public Stats1(String baseDir) {
        this.baseDir = baseDir;
        getNodeNameMapping();

        factory = DocumentBuilderFactory.newInstance();
        // create an instance of TransformerFactory
        transFact = TransformerFactory.newInstance();
    }

    private void getNodeNameMapping() {
        try {
            File nodes = new File("nodes.mac");
            BufferedReader reader = new BufferedReader(new FileReader(nodes));

            String line = null;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(" ");
                nodeMacToName.put(parts[2], parts[0]);
                nodeNameToMac.put(parts[2], parts[0]);
            }
        } catch (Exception fe) {
            fe.printStackTrace();
        }
    }

    // not used
    private Node parse(File xmlFile, String xsl) throws TransformerException {
        File xsltFile = new File(xsl);
        Source xmlSource = new StreamSource(xmlFile);
        Source xsltSource = new StreamSource(xsltFile);
        DOMResult result = new DOMResult();
        Transformer trans = transFact.newTransformer(xsltSource);
        trans.transform(xmlSource, result);
        return ((Document) result.getNode()).getDocumentElement();
    }

    public void eval(File xmlFile) throws TransformerException, XPathExpressionException, ParserConfigurationException, IOException, SAXException {
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document doc = builder.parse(xmlFile);

        DeferredAttrImpl att = (DeferredAttrImpl)xpath.evaluate("//flooding/source[@count > 0]/../@node", doc, XPathConstants.NODE);
        String floodSrcMac = att.getNodeValue();
        String floodSrc = (String)nodeMacToName.get(floodSrcMac);

//        att = (AttrNSImpl)xpath.evaluate("/res/@means_forwards_per_node", root, XPathConstants.NODE);
//        String means_forwards_per_node = att.getNodeValue();
//
        att = (DeferredAttrImpl)xpath.evaluate("//flooding/source[@count > 0]/@count", doc, XPathConstants.NODE);
        String number_of_flooding_reqs = att.getNodeValue();
//
        String totalFwds = (String)xpath.evaluate("sum(//flooding/forward/@count)", doc, XPathConstants.STRING);
        double total_forwards_per_flood = Double.parseDouble(totalFwds) / Double.parseDouble(number_of_flooding_reqs);

        DTMNodeList atts = (DTMNodeList)xpath.evaluate("//rxflow/@packet_count", doc, XPathConstants.NODESET);

        double mean_rx_pnts = 0.0;
        for (int i=0; i<atts.getLength(); i++) {
            Node n = atts.item(i);
            double rx_pnt = 0;
            if (n != null) {
                // divide by total number of floodings
                rx_pnt = Integer.parseInt(n.getNodeValue()) / Double.parseDouble(number_of_flooding_reqs);
            }
            mean_rx_pnts += rx_pnt;
        }
        mean_rx_pnts /= atts.getLength();

        System.out.println(floodSrc + "\t" + number_of_flooding_reqs + "\t" + total_forwards_per_flood + "\t" + mean_rx_pnts);
    }

    public void evalAll() throws TransformerException, IOException, SAXException, XPathExpressionException, ParserConfigurationException {
        System.out.println("FLOODING_SRC\tNUM_FLOODINGS\tTOTAL_FORWARDS_PER_FLOODING\tMEAN_REACHABILITY");
        File dir = new File(baseDir);
        File[] files = dir.listFiles();

        for (File f: files) {
            eval(f);
        }
    }

    public static void main(String[] args) {

        String baseDir = "1MBit" + File.separator;
        Stats1 stats = new Stats1(baseDir);

        try {
            stats.evalAll();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

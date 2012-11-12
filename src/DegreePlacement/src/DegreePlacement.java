import java.util.*;

public class DegreePlacement {

  class Position {
    public int _x;
    public int _y;

    public Position() {
      _x = 0;
      _y = 0;
    }

    public Position(int x,int y) {
      _x = x;
      _y = y;
    }

    public void set(int x,int y) {
      _x = x;
      _y = y;
    }

    public boolean equals(Object n) {
      if ( ! (n instanceof Position) ) return false;
      return ((_x == ((Position)n)._x) && (_y == ((Position)n)._y));
    }

    public int hashCode() {
      return ( (_x << 15) + _y );
    }

    public int dist(Position p) {
      return (int)Math.ceil(Math.sqrt(Math.pow((p._x-_x),2)+Math.pow((p._y-_y),2)));
    }
  }

  class NodeInfo {
    Position pos;
    int radius;
    int degree;

    NodeInfo(Position pos, int radius, int degree) {
      this.pos = pos;
      this.radius = radius;
      this.degree = degree;
    }
  }

  List<NodeInfo> node_infos;
  List<Position> node_pos;

  int nodedegree[][];
  int foreignnodedegree[][];
  int _xSize;
  int _ySize;
  
  int _realXSize;
  int _realYSize;
  
  int _maxDegree;
  int degreeCount[];          //count number of nodes, which have degree of x
  int degreeCountRow[][];     //count number of nodes in line y, which have degree of x

  boolean layout[][] = null;

  private Random rnd;

  public DegreePlacement(int rand_start) {
    rnd = new Random(rand_start);
    node_infos = new ArrayList<NodeInfo>();
    node_pos = new ArrayList<Position>();
    _maxDegree = 5;
  }
  
  void initField(int xSize, int ySize, int prec) {
     _realXSize = xSize;
     _realYSize = xSize;
    
    _xSize = xSize / prec;
    _ySize = ySize / prec;
    
    if ( xSize % prec != 0 ) _xSize++;
    if ( ySize % prec != 0 ) _ySize++;
      
    nodedegree = new int[_xSize][_ySize];
    foreignnodedegree = new int[_xSize][_ySize];

    for ( int x = 0; x < _xSize; x++ )
      for ( int y = 0; y < _ySize; y++ ) {
        nodedegree[x][y] = 0;
        foreignnodedegree[x][y] = 0;
      }
  }
  
  void initDegreeCounter(int maxDegree) {
    _maxDegree = maxDegree;
    degreeCount = new int[_maxDegree];    // number of nodedegree with specific degree (index)
    degreeCountRow = new int[_ySize][_maxDegree]; //number of nodedegree per line with ...
    
    degreeCount[0] = _xSize*_ySize;         //every nodedegree has degree 0
    for ( int j = 0; j < _ySize; j++) degreeCountRow[j][0] = _xSize; ///every nodedegree per line has degree 0

    //rest is zero
    for ( int i = 1; i < ( _maxDegree); i++ ) {
      degreeCount[i] = 0;
      for ( int j = 0; j < _ySize; j++) degreeCountRow[j][i] = 0;
    }
  }

  void initLayout(int radius) {
    if ( (layout == null) || ( layout[0].length != ((2*radius)+1)) ) layout = new boolean[(2*radius)+1][(2*radius)+1];
    for ( int i = 0; i < (2*radius)+1; i++ ) {
      for ( int j = 0; j < (2*radius)+1; j++ ) {
        layout[i][j] = false;
      }
    }

    int radius_sq = radius * radius;
    for (int start_y = 0;start_y <= (2*radius); start_y++ ) {
      int x_len = (int)Math.ceil(Math.sqrt(radius_sq - Math.pow(radius-start_y,2)));
      int start_x = Math.max(0,radius-x_len);
      int end_x = Math.min((2*radius),radius+x_len);
      for(; start_x <= end_x; start_x++) {
        System.out.println("x: " + start_x + "y: " + start_y);

        layout[start_x][start_y] = true;
      }
    }
  }

  void setNodeInField(int x, int y, int radius) {
    node_infos.add(new NodeInfo(new Position(x,y),radius,-1));
    node_pos.add(new Position(x,y));

    update_degree();

    degreeCount[0] = _xSize*_ySize;         //every nodedegree has degree 0
    for ( int j = 0; j < _ySize; j++) degreeCountRow[j][0] = _xSize; ///every nodedegree per line has degree 0

    //rest is zero
    for ( int i = 1; i < ( _maxDegree); i++ ) {
      degreeCount[i] = 0;
      for ( int j = 0; j < _ySize; j++) degreeCountRow[j][i] = 0;
    }

    for ( int xi = 0; xi < _xSize; xi++ )
      for ( int yi = 0; yi < _ySize; yi++ )
        nodedegree[xi][yi] = 0;


    for ( int r = 0; r < _maxDegree; r++ ) {

      for ( int n = 0; n < node_infos.size(); n++ ) {

        NodeInfo ni = node_infos.get(n);

        if ( ni.degree == r ) {
          initLayout(ni.radius);

          int start_x = x-radius;
          int start_y = y-radius;

          for ( int layout_x = 0; layout_x < layout.length; layout_x++, start_x++ ) {
            if ( start_x >= 0 ) {
              for ( int layout_y = 0; layout_y < layout[0].length; layout_y++, start_y++ ) {
                if ( start_y >= 0 ) {
                  if (layout[layout_x][layout_y]) {
                    degreeCount[nodedegree[start_x][start_y]]--;
                    degreeCountRow[start_y][nodedegree[start_x][start_y]]--;

                    nodedegree[start_x][start_y]++;

                    degreeCount[nodedegree[start_x][start_y]]++;
                    degreeCountRow[start_y][nodedegree[start_x][start_y]]++;

                    if ( foreignnodedegree[start_x][start_y] < ni.degree )
                      foreignnodedegree[start_x][start_y] = ni.degree;
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  void printField() {
    //System.out.println("n: " + node_pos.size());
    for ( int y = 0; y<_ySize; y++ ) {
      for ( int x = 0; x<_xSize; x++ ) {
        if ( nodedegree[x][y] > 0 ) {
          if ( node_pos.contains(new Position(x,y)) ) {
            System.out.print(nodedegree[x][y] - 1 + "<");
          } else {
            System.out.print(/*nodedegree[x][y]+ */". ");
          }
        } else {
         System.out.print("  ");
        }
      }
      System.out.println("");
    }
    for ( int y = 0; y<_ySize; y++ ) {
      for ( int x = 0; x<_xSize; x++ ) {
        if ( foreignnodedegree[x][y] > 0 ) {
          if ( node_pos.contains(new Position(x,y)) ) {
            System.out.print(nodedegree[x][y] - 1 + "<");
          } else {
            System.out.print(/*nodedegree[x][y]+ */". ");
          }
        } else {
         System.out.print("  ");
        }
      }
      System.out.println("");
    }
  }

  Position getRandPositionWithDegree(int degree) {
    if ( degreeCount[degree] == 0 ) return null;

    int ac_y, ac_x;
    do {

      int n = rnd.nextInt(degreeCount[degree]);  //choose rand field with degree
    
      //System.out.println("n: " + n);
      int no_of_degpos = 0;
      ac_y = 0;
      while (((no_of_degpos + degreeCountRow[ac_y][degree]) < n) && ( ac_y < _ySize)) {
        System.out.println("y: " + ac_y + " d: " + degree + " dr: " + degreeCountRow[ac_y][degree]);
        no_of_degpos += degreeCountRow[ac_y][degree];
        ac_y++;
      }
    
      for ( ac_x = 0; ac_x < _xSize; ac_x++) {
        if ( nodedegree[ac_x][ac_y] == degree ) {
          no_of_degpos++;
          if ( no_of_degpos == n ) break;
        }
      }
    } while ( foreignnodedegree[ac_x][ac_y] <= _maxDegree );

    return (new Position(ac_x,ac_y));
  }
  
  public int getMaxDegree() { return _maxDegree; }

  public int getCurrentMaxDegree() {
    for ( int i = degreeCount.length - 1; i >= 0; i-- ) {
      if ( degreeCount[i] > 0 ) return i;
    }
    return -1;
  }

  private void update_degree() {
    for ( int y = 0; y< node_infos.size(); y++ ) {
      NodeInfo ni = node_infos.get(y);
      ni.degree = 1;
      for ( int x = 0; x< node_infos.size(); x++ ) {
        if (( x != y ) && ( ni.pos.dist(node_infos.get(x).pos) <= ni.radius)) ni.degree++;
      }
    }
  }

  public static void main(String[] args) {
    Random rnd;

    int count_node = new Integer(args[0]).intValue();
    int max_degree = new Integer(args[1]).intValue();
    int rand_start = new Integer(args[2]).intValue();
    DegreePlacement dp = new DegreePlacement(rand_start);
    rnd = new Random(rand_start);

    dp.initField(150, 150, 1);
    dp.initDegreeCounter(max_degree); 

    Position p = dp.getRandPositionWithDegree(0);
    dp.setNodeInField(p._x, p._y, 15);

    for ( int i = 1; i < count_node; i++) {
     // System.out.println("N: " + max_degree + " h: " + dp.getMaxDegree());
      int d = rnd.nextInt(Math.min(max_degree,dp.getMaxDegree())) + 1;
      p = dp.getRandPositionWithDegree(d);
      dp.setNodeInField(p._x, p._y, 15);
    }
    
    dp.printField();
  }

}

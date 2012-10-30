import java.util.*;

import jargs.gnu.CmdLineParser;

public class DegreePlacement {

  int field[][];
  int _xSize;
  int _ySize;
  
  int _realXSize;
  int _realYSize;
  
  int _maxDegree;
  int degreeCount[];          //count number of nodes, which have degree of x
  int degreeCountRow[][];     //count number of nodes in line y, which have degree of x
  
  int max_degree; 
   
  private Random rnd;
    
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
  }
  
  List<Position> node_pos;
  
  public DegreePlacement(int rand_start) {
    rnd = new Random(rand_start);
    node_pos = new ArrayList<Position>();
    max_degree = 0;
  }
  
  void initField(int xSize, int ySize, int prec) {
     _realXSize = xSize;
     _realYSize = xSize;
    
    _xSize = xSize / prec;
    _ySize = ySize / prec;
    
    if ( xSize % prec != 0 ) _xSize++;
    if ( ySize % prec != 0 ) _ySize++;
      
    field = new int[_xSize][_ySize];
    
    for ( int x = 0; x < _xSize; x++ )
      for ( int y = 0; y < _ySize; y++ )
        field[x][y] = 0;
  }
  
  void initDegreeCounter(int maxDegree) {
    _maxDegree = maxDegree;
    degreeCount = new int[10*_maxDegree];
    degreeCountRow = new int[_ySize][10*_maxDegree];
    
    degreeCount[0] = _xSize*_ySize;
    for ( int j = 0; j < _ySize; j++) degreeCountRow[j][0] = _xSize;
    
    for ( int i = 1; i < ( 10 *_maxDegree); i++ ) {
      degreeCount[i] = 0;
      for ( int j = 0; j < _ySize; j++) degreeCountRow[j][i] = 0;
    }
  }

  void setNodeInField(int x, int y, int radius) {
    int start_y = Math.max(0,y-radius);
    int end_y = Math.min(_ySize-1,y+radius);
    
    node_pos.add(new Position(x,y));
    
    int radius_sq = radius * radius;
    for ( ;start_y <= end_y; start_y++ ) {
      int x_len = (int)Math.ceil(Math.sqrt(radius_sq - Math.pow(y-start_y,2)));
      int start_x = Math.max(0,x-x_len);
      int end_x = Math.min(_xSize-1,x+x_len);
      for(; start_x <= end_x; start_x++) {
      //  System.out.println("x: " + start_x + "y: " + start_y);
        degreeCount[field[start_x][start_y]]--;
        degreeCountRow[start_y][field[start_x][start_y]]--;

        field[start_x][start_y]++;

        degreeCount[field[start_x][start_y]]++;
        degreeCountRow[start_y][field[start_x][start_y]]++;
      }        
    }
    if ( field[x][y] > max_degree ) max_degree = field[x][y];
  }
  
  void printField() {
    //System.out.println("n: " + node_pos.size());
    for ( int y = 0; y<_ySize; y++ ) {
      for ( int x = 0; x<_xSize; x++ ) {
        if ( field[x][y] > 0 ) {
          if ( node_pos.contains(new Position(x,y)) ) {
            System.out.print(field[x][y] - 1 + "<");
          } else {
            System.out.print(/*field[x][y]+ */". ");
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
    
    int n = rnd.nextInt(degreeCount[degree]);
    
    //System.out.println("n: " + n);
    int no_of_degpos = 0;
    int ac_y = 0;
    int ac_x;
    while (((no_of_degpos + degreeCountRow[ac_y][degree]) < n) && ( ac_y < _ySize)) {
      //System.out.println("y: " + ac_y + " d: " + degree + " dr: " + degreeCountRow[ac_y][degree]);      
      no_of_degpos += degreeCountRow[ac_y][degree];
      ac_y++;
    }
    
    for ( ac_x = 0; ac_x < _xSize; ac_x++) {
      if ( field[ac_x][ac_y] == degree ) {
        no_of_degpos++;
        if ( no_of_degpos == n ) break;
      }
    }
     
    return (new Position(ac_x,ac_y));
  }
  
  public int getMaxDegree() { return max_degree; }

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

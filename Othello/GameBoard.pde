
public class GameBoard {
  int unitSize = 80;
  static final int BLACK = 1;
  static final int WHITE = -1;
  ArrayList<ArrayList> units = new ArrayList();

  public GameBoard() {
    for(int i=0; i < 8; i++){
      ArrayList<Unit> rows = new ArrayList();
      for(int j=0; j < 8; j++){
        rows.add(new Unit(j ,i));
      }
      units.add(rows);      
    }
  }

  public void startGame() {
   getUnitAt(3,3).putCounter( this.BLACK);
   getUnitAt(4,4).putCounter( this.BLACK);
   getUnitAt(3,4).putCounter( this.WHITE);
   getUnitAt(4,3).putCounter( this.WHITE);
  }

  public Unit getUnitGeo(int x, int y) {
    int numColumns = floor( x / unitSize);
    int numRows = floor( y / unitSize);
    return this.getUnitAt(numColumns, numRows);
  }

  public Unit getUnitAt(int columns, int rows) {
    if(columns < 0 || columns > 7 || rows < 0 || rows > 7){
      return null;
     }
     return (Unit)units.get(rows).get(columns);
  }

  public ArrayList<Unit> numUnitsToFlip(Unit unit, int counter) {
    ArrayList<Unit> unitsToFlip = new ArrayList<Unit>();
    
    if(unit.hasCounter()){
      return unitsToFlip;
    }

    for(int dirColumn = -1; dirColumn < 2; dirColumn ++){
      for(int dirRows = -1; dirRows < 2; dirRows ++) {
        ArrayList<Unit> dirUnits = this.getDirUnits(unit, dirColumn, dirRows);
        ArrayList<Unit> checked = new ArrayList<Unit>();
        for(Unit u: dirUnits) {
           if(u.counter == 0){
                 break;
            }

            if(u.counter != counter){
                 checked.add(u);
            }

            if(u.counter == counter){
               for(Object toFlip: checked){
                 unitsToFlip.add((Unit) toFlip);
               }
               break;
            }
          }

       }
     }
    
     return unitsToFlip;
  }

  public ArrayList<Unit> getDirUnits(Unit unitsAtStart,int dirColumns, int dirRows ) {
    ArrayList<Unit> returnUnits  = new ArrayList<Unit>();
    if(dirColumns == 0 && dirRows == 0){
      return returnUnits;
    }
    int columns = unitsAtStart.getColumns() + dirColumns;
    int rows = unitsAtStart.getRows() + dirRows;
    Unit nextUnit = getUnitAt(columns,rows);
    
    while(nextUnit != null){
      returnUnits.add(nextUnit);
      columns += dirColumns;
      rows += dirRows;
      nextUnit = getUnitAt(columns ,rows);
    }
    return returnUnits;
  }

  public void display() {
    for(ArrayList row: units){
      for(Object u: row){
        Unit unit = (Unit) u;
        
        unit.display();
        
      }
    }
  }
  
  //int[][] boardCopy = new int[board.length][board.length];
  //   for (int[] row : board) {
  //   System.arrayCopy(board,0,boardCopy,0,board.length);
  //}
  
  
  
  boolean isValid(Unit unit){
    if(unit.hasCounter() & unit.isWhite() & getUnitAt(unit.x + 1, unit.y).isBlack() ||
    unit.hasCounter() & unit.isWhite() & getUnitAt(unit.x -1 , unit.y).isBlack() || 
    unit.hasCounter() & unit.isWhite() & getUnitAt(unit.x, unit.y +1).isBlack() || 
    unit.hasCounter() & unit.isWhite() & getUnitAt(unit.x, unit.y - 1).isBlack()){
        System.out.println("It works!");
        return true;
    }else{
     return false;
        }
  }
  
  public void makeMove(){
   
    Unit unit = this.getUnitGeo(mouseX, mouseY);
    ArrayList<Unit> unitsToFlip = this.numUnitsToFlip(unit, myCounter);
  
    if(unitsToFlip.size() > 0){
      unit.putCounter(myCounter);
   
      for(Unit u: unitsToFlip){
        u.flip();
      }
    
      turnEnd();
    } 
    else {
    }
  }
  
  public void makeMoveAi(){
    Unit unit = enemyAi.predict();

    if (unit ==null) {
      turnEnd(); 
      return;
    }
    ArrayList<Unit> unitsToFlip = gBoard.numUnitsToFlip(unit, currentTurn);
    unit.putCounter(currentTurn);  
    if (gBoard.isValid(unit)) {
      for (Unit u : unitsToFlip) {
         u.flip();
      }
      turnEnd();
    };
  
  }
  public ArrayList<Unit> availableUnits() {
    ArrayList<Unit> availableUnits = new ArrayList<Unit>();
    for(ArrayList<Unit> rows: units){
      for(Unit unit: rows){
        if(!unit.hasCounter()){
          availableUnits.add(unit);
        }
      }
    }
    return availableUnits;
  }
  
  public int allUnits() {
    int black = 0;
    int white = 0;
    for(ArrayList<Unit> rows: units){
      for(Unit unit: rows){
        if(unit.hasCounter() & unit.isBlack()){
          black = black + 1;
        }else if (unit.hasCounter() & unit.isWhite()){
          white = white +1;
        }
      }
    }
    //System.out.println("Num of Black: " + black);
    //System.out.println("Num of White: " + white);
    //System.out.println(white - black);
    return (white - black);
  }

  public int calculateScore() {
    int gameScore = 0;
    for(ArrayList rows: units) {
      for(Object u: rows) {
        Unit unit = (Unit) u;
        gameScore += unit.getCounterValue();
      }
    }
    return gameScore;
  }
  
  boolean isGBlack(Unit unit){
    return (unit.counter == 1);
  }
  
  boolean isGWhite(Unit unit){
    return (unit.counter == -1);
  }
  
  boolean isEmpty(Unit unit){
    return (unit.counter == 0);
  }
  
  public int gameWinner() {
    int gameScore = this.calculateScore();
    if( gameScore > 0 ){
      return this.BLACK;
    } 
    else if( gameScore < 0 ) {
      return this.WHITE;
    } 
    else {
      return 0;
    }
  }
}

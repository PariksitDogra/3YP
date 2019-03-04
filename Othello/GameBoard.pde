
public class GameBoard {
  int unitSize = 80;
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
   getUnitAt(3,3).putCounter( Unit.BLACK);
   getUnitAt(4,4).putCounter( Unit.BLACK);
   getUnitAt(3,4).putCounter( Unit.WHITE);
   getUnitAt(4,3).putCounter( Unit.WHITE);
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
    Unit nextUnit = getUnitAt(columns ,rows);
    
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

  public int calculateScore() {
    int gameScore = 0;
    for(ArrayList rows: units) {
      for(Object u: rows) {
        Unit unit = (Unit) u;
        gameScore += unit.getScore();
      }
    }
    return gameScore;
  }

  public int gameWinner() {
    int gameScore = this.calculateScore();
    if( gameScore > 0 ){
      return Unit.BLACK;
    } 
    else if( gameScore < 0 ) {
      return Unit.WHITE;
    } 
    else {
      return 0;
    }
  }
}

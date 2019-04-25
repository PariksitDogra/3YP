
public class GameBoard{
  int unitSize = 80;
  static final int BLACK = 1;
  static final int WHITE = -1;
  ArrayList<ArrayList> units = new ArrayList();
  
  Double[][] staticValues = new Double[][]{
  { new Double(1000), new Double(-300), new Double(100), new Double(80), new Double(80), new Double(100), new Double(-300), new Double(1000)},
  { new Double(-300), new Double(-500), new Double(-45), new Double(-50), new Double(-50), new Double(-45), new Double(-500), new Double(-300)},
  { new Double(100), new Double(-45), new Double(3), new Double(1), new Double(1), new Double(3), new Double(-45), new Double(100)},
  { new Double(80), new Double(-50), new Double(1), new Double(5), new Double(5), new Double(1), new Double(-50), new Double(80)},
  { new Double(80), new Double(-50), new Double(1), new Double(5), new Double(5), new Double(1), new Double(-50), new Double(80)},
  { new Double(100), new Double(-45), new Double(3), new Double(1), new Double(1), new Double(3), new Double(-45), new Double(100)},
  { new Double(-30), new Double(-50), new Double(-45), new Double(-5), new Double(-5), new Double(-45), new Double(-50), new Double(-30)},
  { new Double(100), new Double(-30.00), new Double(10), new Double(8), new Double(8), new Double(10), new Double(-30), new Double(100)},
  };

  public GameBoard() {
    for(int i=0; i < 8; i++){
      ArrayList<Unit> rows = new ArrayList();
      for(int j=0; j < 8; j++){
        rows.add(new Unit(j ,i));
      }
      units.add(rows);      
    }
  }
  public GameBoard(GameBoard board) {
    for(int i=0; i < 8; i++){
      ArrayList<Unit> rows = new ArrayList();
      for(int j=0; j < 8; j++){
        Unit actual = board.getUnitAt(j, i);
        Unit newUnit = new Unit(j ,i);
        newUnit.setCounterValue(actual.getCounterValue());
        rows.add(newUnit);
      }
      units.add(rows);      
    }    
  }

  public void startGame() {
   getUnitAt(3,3).putCounter( Unit.WHITE);
   getUnitAt(4,4).putCounter( Unit.WHITE);
   getUnitAt(3,4).putCounter( Unit.BLACK);
   getUnitAt(4,3).putCounter( Unit.BLACK);
  
}
  
  public Double evaluate(GameBoard board){
    Double black = new Double(0);
    Double mobilityScore = new Double(0);
    Double white = new Double(0);
    Double coinParity = new Double(0);
    for(ArrayList<Unit> rows: board.units){
      for(Unit unit: rows){
        if(unit.hasCounter() & unit.isBlack()){
          black += staticValues[unit.x][unit.y];
        }else if (unit.hasCounter() & unit.isWhite()){
          white += staticValues[unit.x][unit.y];
        }
      }
    }
    coinParity = allUnits(board);
    mobilityScore = mobility(board);
    Double score = new Double(white-black);
    score = score + mobilityScore + coinParity; 
    return score;

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
  
  
  
  
  public boolean isMoveValid(GameBoard board, Unit unit, int playerColour){
    //Check if Unit has no counter return false;
      
      if(unit.hasCounter()) {
        System.out.println("FALSE: Has a counter");
        return false;
      }
      
    //Search for adjacent Units != white
    /*int unitCol = unit.getColumns();
    int unitRow = unit.getRows();
    int oppositeColour = playerColour * -1;
     for(int dirColumn = -1; dirColumn < 2; dirColumn ++){
      for(int dirRows = -1; dirRows < 2; dirRows ++) {
        //if current unit is equal to opposing colour
        Unit adjUnit = board.getUnitAt(unitCol + dirColumn , unitRow + dirRows);
        if(adjUnit == null) continue;
        if(adjUnit.getCounterValue() == (oppositeColour)) {
          ArrayList<Unit> dirUnits = board.getDirUnits(unit, dirColumn, dirRows);
          for(Unit u: dirUnits){
            if(u.getCounterValue() == playerColour){
              //System.out.println("TRUE");
              return true;
            }
          } 
        }
       }
     }
      
     // System.out.println("FALSE: END OF FUNCTION");
     return false;
     */
     if(numUnitsToFlip(unit, playerColour).size() == 0){
       return false;
     } else {
       return true;
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
  
 public ArrayList<Unit> getState(){
    ArrayList<Unit> getAllUnits = new ArrayList<Unit>();
    for(ArrayList<Unit> rows: units){
      for(Unit unit: rows){
         getAllUnits.add(unit);
      }
    }
    return getAllUnits;
 }
 
  public Double mobilityBlack(GameBoard board){
    Double numberOfLegalMoves = new Double(0);
    ArrayList<Unit> emptySquares = board.availableUnits();
    for(Unit u: emptySquares){
     if(board.isMoveValid(board,u, 1)){
        numberOfLegalMoves = numberOfLegalMoves + 1;
     }
    
    }
   
    return numberOfLegalMoves;
  }
  public Double mobilityWhite(GameBoard board){
    Double numberOfLegalMoves = new Double(0);
    ArrayList<Unit> emptySquares = board.availableUnits();
    for(Unit u: emptySquares){
     if(board.isMoveValid(board,u, -1)){
        numberOfLegalMoves = numberOfLegalMoves + 1;
     }
    
    }
    
    return numberOfLegalMoves;
  }
  public Double mobility(GameBoard board){
  
    Double blackLegalMoves = mobilityBlack(board) * 5;
    Double whiteLegalMoves = mobilityWhite(board) * 5;
    Double difference = whiteLegalMoves - blackLegalMoves;
    
    return difference;
    
  }
  
 
 public HashMap<GameBoard, Unit> getChildren(GameBoard board,int player){
   HashMap<GameBoard, Unit> combinedStateUnit = new HashMap<GameBoard, Unit>();
   ArrayList<Unit> emptySquares = board.availableUnits();
   //ArrayList<GameBoard> possibleStates = new ArrayList<GameBoard>();
   //ArrayList<Unit> addedUnits = new ArrayList<Unit>();
   for(Unit u: emptySquares){
     if(board.isMoveValid(board,u, player)){
       combinedStateUnit.put(simulateMove(board, u, player), u);
       //possibleStates.add(simulateMove(board, u, player));
       //addedUnits.add(u);
     }
   }
   return combinedStateUnit;
 }

 public GameBoard simulateMove(GameBoard board, Unit unit, int player){
    GameBoard boardCopy = new GameBoard(board);
    
    ArrayList<Unit> unitsToFlip = boardCopy.numUnitsToFlip(unit, player);
    // unit.putCounter(player);
    boardCopy.getUnitAt(unit.x, unit.y).setCounterValue(player);
    for (Unit u : unitsToFlip) {
       // remember to verify ref or obj  
       u.flip();         
     }
     return boardCopy;
 }
 
 
 public Unit aiPredict(){
   GameBoard gBoardCopy = new GameBoard(gBoard);
   Pair<Double, Unit> score = minimaxAB(gBoardCopy, 5, Double.NEGATIVE_INFINITY, Double.POSITIVE_INFINITY, gBoardCopy.WHITE);
   System.out.println("Minimax_Val: "+ score.getKey()+ ", Unit_X: " + score.getValue().x + ", Unit_Y: " + score.getValue().y);
   
   return score.getValue();
 }
 
 
 
 public Pair<Double, Unit> minimaxAB(GameBoard node, int depth, Double alpha, Double beta, int maxPlayer){
   ArrayList<Unit> emptySquares = node.availableUnits();
   Unit bestU = new Unit(-1,-1);
   if(depth == 0 || emptySquares.size() == 0){
     Pair<Double, Unit> heur = new Pair<Double, Unit>(evaluate(node), new Unit(-1, -1));
     return heur;
   }
   if(maxPlayer == node.WHITE){ 
      Double maxEval = Double.NEGATIVE_INFINITY;
      HashMap<GameBoard, Unit> children = getChildren(node, node.WHITE);
      for(HashMap.Entry<GameBoard, Unit> entry: children.entrySet()){
        Pair<Double, Unit> eval = minimaxAB(entry.getKey(), depth -1, alpha, beta, node.BLACK);
        // System.out.println("Num Valid Moves" + entry.getKey().isMoveValid(u, player));
        maxEval = Math.max(maxEval, eval.getKey());
        if(eval.getKey() > alpha){
          alpha = eval.getKey();
          bestU.x = entry.getValue().x;
          bestU.y = entry.getValue().y;
        }
        if (beta <= alpha){
          break;
        }
      }
      return new Pair<Double, Unit>(maxEval, bestU);
   } else {
     Double minEval = Double.POSITIVE_INFINITY;
     HashMap<GameBoard, Unit> children = getChildren(node, node.BLACK);
     for(HashMap.Entry<GameBoard, Unit> entry: children.entrySet()){
        Pair<Double, Unit> eval = minimaxAB(entry.getKey(), depth -1, alpha, beta, node.WHITE);
        minEval = Math.min(minEval, eval.getKey());
       if(eval.getKey() < beta){
          beta = eval.getKey();
          bestU.x = entry.getValue().x;
          bestU.y = entry.getValue().y;
        }
        if (beta <= alpha){
          break;
        }
     }
     return new Pair<Double, Unit>(minEval, bestU);
   }

  }
  
  
 
  public void makeMoveAi(){
    Unit unit = aiPredict();
    if(gBoard.mobilityBlack(gBoard) == 0 && gBoard.mobilityWhite(gBoard) == 0){
      gameOver();
      return;
    }
    if(unit.x == -1 & unit.y == -1){
      turnEnd();
      return;
    }
    if(isMoveValid(this,unit, this.WHITE))  {
      System.out.println("Successful AI Position");
    }else{
      System.out.println("BAD AI Position");
    
    }
    ArrayList<Unit> unitsToFlip = gBoard.numUnitsToFlip(unit, currentTurn);
    gBoard.getUnitAt(unit.x, unit.y).setCounterValue(currentTurn);  
     for (Unit u : unitsToFlip) {
         u.flip();
     }
     turnEnd();
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
  
  
  public Double allUnits(GameBoard board) {
    int black = 0;
    int white = 0;
    for(ArrayList<Unit> rows: board.units){
      for(Unit unit: rows){
        if(unit.hasCounter() & unit.isBlack()){
          black = black + 1;
        }else if (unit.hasCounter() & unit.isWhite()){
          white = white +1;
        }
      }
    }
    
    Double score = new Double(white - black) * 25;
    return score;
  }
  
  public int returnWhite(GameBoard board){
    int white = 0;
    for(ArrayList<Unit> rows: board.units){
      for(Unit unit: rows){
        if(unit.hasCounter() & unit.isWhite()){
          white = white +1;
        }
      }
    }
    
    return white;
  }
  
  public int returnBlack(GameBoard board){
    int black = 0;
    for(ArrayList<Unit> rows: board.units){
      for(Unit unit: rows){
        if(unit.hasCounter() & unit.isBlack()){
          black = black +1;
        }
      }
    }
    
    return black;
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

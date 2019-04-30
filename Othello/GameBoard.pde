
public class GameBoard{
  int unitSize = 80;
  static final int BLACK = 1;
  static final int WHITE = -1;
  ArrayList<ArrayList> units = new ArrayList();
  //Static values that represent the board of weights
  Double[][] staticValues = new Double[][]{
  { new Double(1000), new Double(-300), new Double(100), new Double(80), new Double(80), new Double(100), new Double(-300), new Double(1000)},
  { new Double(-300), new Double(-500), new Double(-45), new Double(-50), new Double(-50), new Double(-45), new Double(-500), new Double(-300)},
  { new Double(100), new Double(-45), new Double(3), new Double(1), new Double(1), new Double(3), new Double(-45), new Double(100)},
  { new Double(80), new Double(-50), new Double(1), new Double(5), new Double(5), new Double(1), new Double(-50), new Double(80)},
  { new Double(80), new Double(-50), new Double(1), new Double(5), new Double(5), new Double(1), new Double(-50), new Double(80)},
  { new Double(100), new Double(-45), new Double(3), new Double(1), new Double(1), new Double(3), new Double(-45), new Double(100)},
  { new Double(-300), new Double(-500), new Double(-45), new Double(-50), new Double(-50), new Double(-45), new Double(-500), new Double(-300)},
  { new Double(1000), new Double(-300), new Double(100), new Double(80), new Double(80), new Double(100), new Double(-300), new Double(1000)},
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
  //Constructor for board simulation without interfering with game on-screen
  public GameBoard(GameBoard board) {
    for(int i=0; i < 8; i++){
      ArrayList<Unit> rows = new ArrayList();
      for(int j=0; j < 8; j++){
        Unit actual = board.getUnit(j, i);
        Unit newUnit = new Unit(j ,i);
        newUnit.setCounterValue(actual.getCounterValue());
        rows.add(newUnit);
      }
      units.add(rows);      
    }    
  }
  
  
  
  
  //Gets the unit with it's position on the board as the parameter.
  public Unit getUnit(int columns, int rows) {
    if(columns < 0 || columns > 7 || rows < 0 || rows > 7){
      return null;
     }
     return (Unit)units.get(rows).get(columns);
  }

  //Returns the list of units that need to be flipped once the move has been played.
  public ArrayList<Unit> numUnitsToFlip(Unit unit, int counter) {
    ArrayList<Unit> unitsToFlip = new ArrayList<Unit>();
    //If the grid is occupied, return
    if(unit.hasCounter()){
      return unitsToFlip;
    }
    
    //For every x, y and diagonal direction check if there lies pieces of the same colour along that direction.
    for(int dirColumn = -1; dirColumn < 2; dirColumn ++){
      for(int dirRows = -1; dirRows < 2; dirRows ++) {
        ArrayList<Unit> dirUnits = this.getDirUnits(unit, dirColumn, dirRows);
        ArrayList<Unit> evaluated = new ArrayList<Unit>();
        
        for(Unit u: dirUnits) {
          //if the unit is empty, break
           if(u.counter == 0){
                 break;
            }
            //if the unit is not the same colour as the player, add it to evaluated
            if(u.counter != counter){
                 evaluated.add(u);
            }
            //if it is the same, simulate the move and add the ones that need to be flipped in between
            if(u.counter == counter){
               for(Object toFlip: evaluated){
                 unitsToFlip.add((Unit) toFlip);
               }
               break;
            }
          }

       }
     }
     return unitsToFlip;
  }
  
  //Returns the unit where the mouse is
  public Unit getUnitGeo(int x, int y) {
    int numColumns = floor( x / unitSize);
    int numRows = floor( y / unitSize);
    return this.getUnit(numColumns, numRows);
  }
    
  //Returns all the units in the directions a move can be placed.  
  public ArrayList<Unit> getDirUnits(Unit unitsAtStart,int dirColumns, int dirRows ) {
    ArrayList<Unit> returnUnits  = new ArrayList<Unit>();
    if(dirColumns == 0 && dirRows == 0){
      return returnUnits;
    }
    int columns = unitsAtStart.getColumns() + dirColumns;
    int rows = unitsAtStart.getRows() + dirRows;
    Unit nextUnit = getUnit(columns,rows);
    
    while(nextUnit != null){
      returnUnits.add(nextUnit);
      columns += dirColumns;
      rows += dirRows;
      nextUnit = getUnit(columns ,rows);
    }
    return returnUnits;
  }
  
  //Displays all the units on the board
  public void display() {
    for(ArrayList row: units){
      for(Object u: row){
        Unit unit = (Unit) u;
        
        unit.display();
        
      }
    }
  }
  
  //Initialises the game with the starting pieces remaining at the starting position
  public void startGame() {
   getUnit(3,3).putCounter( Unit.WHITE);
   getUnit(4,4).putCounter( Unit.WHITE);
   getUnit(3,4).putCounter( Unit.BLACK);
   getUnit(4,3).putCounter( Unit.BLACK);
  
}
  //Checks if the move is valid
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
         
         //checks if the number of units the move can flip is 0, if so, invalid
       if(numUnitsToFlip(unit, playerColour).size() == 0){
         return false;
       } else {
         return true;
       }
       
    } 
 
  
  
  //Makes the player's move
  public void makeMove(){
   
    //Get's the unit the player is hovering over with the mouse
    Unit unit = this.getUnitGeo(mouseX, mouseY);
    if(unit == null){
      return;
    }
    ArrayList<Unit> unitsToFlip = this.numUnitsToFlip(unit, myCounter);
    
    //If there are units that can be flipped, place the counter
    if(unitsToFlip.size() > 0){
      unit.putCounter(myCounter);
     
      //Flip those units
      for(Unit u: unitsToFlip){
        u.flip();
      }
    
      turnEnd();
    } 
    else {
    }
    
  }
 
 //Return all the units on the board
 public ArrayList<Unit> getState(){
    ArrayList<Unit> getAllUnits = new ArrayList<Unit>();
    for(ArrayList<Unit> rows: units){
      for(Unit unit: rows){
         getAllUnits.add(unit);
      }
    }
    return getAllUnits;
 }
 
  //Returns the possible moves the black piece can make
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
  //Returns the possible moves the white piece can make
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
  //Returns the difference multiplied by its weighting.
  public Double mobility(GameBoard board){
  
    Double blackLegalMoves = mobilityBlack(board) * 5;
    Double whiteLegalMoves = mobilityWhite(board) * 5;
    Double difference = (whiteLegalMoves - blackLegalMoves);
    return difference;
    
  }
  
 //Returns all the children of a unit, if the move was to be played.
 //By returning a hashmap of gameboard, unit -> the unit and the gameboard it generates is saved
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

//The move is simulated on a copy of the gameboard, which is then returned back
 public GameBoard simulateMove(GameBoard board, Unit unit, int player){
    GameBoard boardCopy = new GameBoard(board);
    
    ArrayList<Unit> unitsToFlip = boardCopy.numUnitsToFlip(unit, player);
    // unit.putCounter(player);
    boardCopy.getUnit(unit.x, unit.y).setCounterValue(player);
    for (Unit u : unitsToFlip) {
       // remember to verify ref or obj  
       u.flip();         
     }
     return boardCopy;
 }

  //The minimax algorithm
 public Pair<Double, Unit> minimaxAB(GameBoard node, int depth, Double alpha, Double beta, int maxPlayer){
   ArrayList<Unit> emptySquares = node.availableUnits();
   Unit bestU = new Unit(-1,-1);
   //Break if game over or no more moves
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
      //Return the best evaluation for max player, and the unit associated with it
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
     //Return the best evaluation for min player, and the unit associated with it
     return new Pair<Double, Unit>(minEval, bestU);
   }

  }
  //Allows the user to tweak the parameters of minimax, also returns a Unit which can be used to play the move on the board for the AI.
  public Unit aiPredict(){
   GameBoard gBoardCopy = new GameBoard(gBoard);
   Pair<Double, Unit> score = minimaxAB(gBoardCopy, 5, Double.NEGATIVE_INFINITY, Double.POSITIVE_INFINITY, gBoardCopy.WHITE);
   System.out.println("Minimax_Val: "+ score.getKey()+ ", Unit_X: " + score.getValue().x + ", Unit_Y: " + score.getValue().y);
   
   return score.getValue();
 }
 
  
  //Uses the Unit generated by minimax to play on the gameboard.
  public void makeMoveAi(){
    Unit unit = aiPredict();
    //If no possible moves for either player, end the game.
    if(gBoard.mobilityBlack(gBoard) == 0 && gBoard.mobilityWhite(gBoard) == 0){
      gameOver();
      return;
    }
    //if unit is invalid, end the turn.
    if(unit.x == -1 & unit.y == -1){
      turnEnd();
      return;
    }
    if(isMoveValid(this,unit, this.WHITE))  {
      System.out.println("Successful AI Position");
    }else if (unit.x  == -1 && unit. y == -1){
      System.out.println("-1 AI Position");
    }else{
      System.out.println("BAD AI Position");
    }
    ArrayList<Unit> unitsToFlip = gBoard.numUnitsToFlip(unit, currentTurn);
    gBoard.getUnit(unit.x, unit.y).setCounterValue(currentTurn);  
     for (Unit u : unitsToFlip) {
         u.flip();
     }
     turnEnd();
  }
  
  
  //Returns all units with no counter on them
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
  
  //Returns the coin parity of the game board
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
    //Weight multiplied by 25
    Double score = new Double(white - black) * 25;
    return score;
  }
  
  //Returns the number of white counters on the board
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
  //Returns the number of black counters on the board
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
  //Combines the heuristic evaluators, producing an evaluation of the board state.
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
  //Calculates the score of the game relevant to how many counters are on the board.
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
  
  //Returns the winner of the game.
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

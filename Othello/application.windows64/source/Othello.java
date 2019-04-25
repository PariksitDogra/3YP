import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.awt.MenuBar; 
import java.awt.Menu; 
import java.awt.MenuItem; 
import processing.awt.PSurfaceAWT; 
import java.awt.*; 
import java.awt.event.*; 
import java.io.*; 
import java.lang.Math; 
import java.io.Serializable; 
import java.util.HashMap; 
import javafx.util.Pair; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Othello extends PApplet {













GameBoard gBoard; 
EnemyAI enemyAi; 
Interface ui; 

int myCounter = Unit.BLACK; 
int aiCounter = Unit.WHITE; 
int currentTurn = Unit.BLACK; 
int aiTurnStartTime; 

class EnemyAI {
  GameBoard board;
  int counter;

  EnemyAI(GameBoard board, int counter) {
    this.board = board;
    this.counter = counter;
  }

  public Unit predict() {
    int max = 0;
    Unit unitToPut = null;
    ArrayList<Unit> candidates = board.availableUnits(); //empty squares
    for (Unit unit : candidates) {
      ArrayList<Unit> unitsToFlip = board.numUnitsToFlip(unit, aiCounter);
      if (max < unitsToFlip.size()) {
        max = unitsToFlip.size();
        unitToPut = unit;
      }
    }
    return unitToPut;
  }
}

public void setup() {
  
  gBoard = new GameBoard();
  gBoard.startGame();
  enemyAi = new EnemyAI(gBoard, aiCounter);
  ui = new Interface();
  MenuBar myMenu = new MenuBar();
  Menu optionsMenu = new Menu("Options");
  myMenu.add(optionsMenu);
  MenuItem newGameOption = new MenuItem("New Game");
  optionsMenu.add(newGameOption);
  PSurfaceAWT awtSurface = (PSurfaceAWT)surface;
  PSurfaceAWT.SmoothCanvas smoothCanvas = (PSurfaceAWT.SmoothCanvas)awtSurface.getNative();
  smoothCanvas.getFrame().setMenuBar(myMenu);
  newGameOption.addActionListener(new ActionListener() {
    public void actionPerformed(ActionEvent arg0) {
      setup();
    }
  }
  );
}




public void draw() {

  background(255);
  gBoard.display();


  if (gBoard.availableUnits().size() == 0) { 
    gameOver();
    return;
  }  

  ui.display();

  if (isMyTurn()) {
    textSize(20);
    fill(0);
    text("Your turn", 20, 640 + 30);
    showGhost();
  }


  if (!isMyTurn()) {
    if ( aiTurnStartTime == 0) {
      aiTurnStartTime = millis();
    }

    if (millis() - aiTurnStartTime > 2000) {
    turnForAi();
      aiTurnStartTime = 0;
    }
    textSize(20);
    fill(0);
    text("Enemy's Turn", 20, 640 + 30);
  }
}

public void showGhost() {
  Unit unit = gBoard.getUnitGeo(mouseX, mouseY);
  if (unit != null) {
    unit.showGhost(myCounter);
  }
}


public boolean isMyTurn() {
  return (myCounter == currentTurn);
}


public void turnEnd() {
  currentTurn = (myCounter == currentTurn) ? aiCounter : myCounter;
}


public void mouseClicked() {
  if (!isMyTurn()) {
    return;
  }  
  if (ui.clickButton(mouseX, mouseY) == ui.PASS) {
    turnEnd();
    return;
  }
  gBoard.makeMove();
}

public void turnForAi() {
  gBoard.makeMoveAi();
}

public void gameOver() {    
  String message;
  if ( gBoard.gameWinner() == myCounter ) {
    message = "The player has won! ( " + gBoard.returnBlack(gBoard) + " - " + gBoard.returnWhite(gBoard) + " )";
  } else if ( gBoard.gameWinner() == aiCounter ) {
    message = "The player has lost! ( " + gBoard.returnBlack(gBoard) + " - " + gBoard.returnWhite(gBoard) + " )";
  } else {
    message = "Draw!";
  }
  ui.showWinnerMessage(message);
  noLoop();
}

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
  { new Double(100), new Double(-30.00f), new Double(10), new Double(8), new Double(8), new Double(10), new Double(-30), new Double(100)},
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
    Double white = new Double(0);
    for(ArrayList<Unit> rows: board.units){
      for(Unit unit: rows){
        if(unit.hasCounter() & unit.isBlack()){
          black += staticValues[unit.x][unit.y];
        }else if (unit.hasCounter() & unit.isWhite()){
          white += staticValues[unit.x][unit.y];
        }
      }
    }
    Double score = new Double(white-black);
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
   Pair<Double, Unit> score = minimaxAB(gBoardCopy, 3, Double.NEGATIVE_INFINITY, Double.POSITIVE_INFINITY, gBoardCopy.WHITE);
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
    Double score = new Double(white - black);
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
  
  public boolean isGBlack(Unit unit){
    return (unit.counter == 1);
  }
  
  public boolean isGWhite(Unit unit){
    return (unit.counter == -1);
  }
  
  public boolean isEmpty(Unit unit){
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

class Interface {

  static final int PASS = 1; 
  static final int NEWGAME = -1;

  private int passButtonX = 640 - 80;
  private int passButtonY = 640 + 5;
  private int passButtonWidth = 70;
  private int passButtonHeight = 30;
  

public void display() {
    showPassButton();
  }
  
  public void showPassButton() {
    stroke(100);
    fill(100,100,100);
    rect(passButtonX, passButtonY, passButtonWidth, passButtonHeight);
    textSize(18);
    fill(0);
    text("Pass", passButtonX + 14, passButtonY + 23);
  }
  
  //public void showNewGameButton(){
  //  stroke(100);
  //  fill(125, 23, 209);
  //  rect(passButtonX - 200, passButtonY, passButtonWidth +35, passButtonHeight);
  //  textSize(18);
  //  fill(0);
  //  text("New Game", passButtonX - 200 , passButtonY + 23);
  //  if(mousePressed){
  //    if(mouseX> passButtonX - 200  && mouseX < passButtonX - 200 + passButtonWidth && mouseY> passButtonY && mouseY <passButtonY+ passButtonHeight){
  //    System.out.println("YEET");
  //  }  
  
  

  public void showWinnerMessage(String message) {
    textSize(20);
    fill(0);
    text(message, 20 , 640 + 30);
  }
  

  public int clickButton(int x, int y) {
    if(x > passButtonX && x < passButtonX + passButtonWidth && y > passButtonY && y < passButtonY + passButtonHeight ){
      return PASS;
    }
    else{
    return 0;
    }  
  }
  }

class Unit {
  static final int SIZE = 80;
  static final int BLACK = 1;
  static final int WHITE = -1;
  
  int x;
  int y;
  int counter = 0;
  int size = SIZE;
  
  Unit(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  public int getColumns(){
    return this.x; 
  }
  
  public int getRows() {
    return this.y; 
  }
  
  public boolean hasCounter() {
    return (this.counter != 0);
  }
  
  public boolean isBlack(){
    return (this.counter == 1);
  }
  
  public boolean isWhite(){
    return (this.counter == -1);
  }
  
  public boolean isEmpty(){
    return (this.counter == 0);
  }
  
  public int getCounterValue() {
    return this.counter; 
  }
  
  public void setCounterValue(int counter) {
    this.counter = counter;
  }
  
  
  
  //GUI
  public void showGhost(int showCounter) {
    if(this.hasCounter()){
     return; 
    }
    noStroke();
    if(showCounter == this.BLACK){
      fill(0, 255 * 0.3f);  
    } else {
      fill(255, 255 * 0.3f);
    }
    ellipse(this.x * size + (size/2),  this.y * size + (size/2), size * 0.9f,size * 0.9f);   
  }
  
  //GUI
  public void display() {
    stroke(0);
    fill(0,0.6f * 100,0);
    rect(x * size, y * size, size, size);
    if(this.counter != 0){
      if( this.counter == this.BLACK){        
        fill(0);
      } else {
        fill(255); 
      }
      noStroke();
      ellipse(x * size + (size/2), y * size + (size/2),size * 0.9f,size * 0.9f);
    }
  }
  
  //Useful
  public boolean putCounter(int counterColor) {
    if(counterColor == 0 || counterColor == -1 || counterColor == 1){
      this.counter = counterColor;
      return true;
    }else{
      System.out.println("WRONG COUNTER NUMBER");
      return false;
    }
    
  }
  
  
  public void flip() {
    this.counter *= -1; 
  }
}
  public void settings() {  size(640, 700); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Othello" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

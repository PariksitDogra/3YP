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
}
//Initialises the entire sketch, instances are initiated here as well as window parameters.
public void setup() {

  size(640, 700);
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
      loop();
      if(!isMyTurn()){
        turnEnd();
      }
    }
  }
  );
}



//This method allows for any checks every second
public void draw() {

  background(255);
  gBoard.display();

  //If no more empty space on the board, end the game
  if (gBoard.availableUnits().size() == 0) { 
    gameOver();
    return;
  }  
  //Show the pass button
  ui.display();
  //If it is my turn, show me the possible moves
  if (isMyTurn()) {
    textSize(20);
    fill(0);
    text("Your turn", 20, 640 + 30);
    showCounters();
  }
  
  //Artificial Timer to prevent the AI from being too fast
  if (!isMyTurn()) {
    if ( aiTurnStartTime == 0) {
      aiTurnStartTime = millis();
    }

    if (millis() - aiTurnStartTime > 1000) {
    turnForAi();
    aiTurnStartTime = 0;
    }
    textSize(20);
    fill(0);
    text("Enemy's Turn", 20, 640 + 30);
  }
}
//Shows the transluscent counter following the mouse
public void showCounters() {
  Unit unit = gBoard.getUnitGeo(mouseX, mouseY);
  if(unit != null) {
    unit.showCounters(myCounter);
  }
}


public boolean isMyTurn() {
  return (myCounter == currentTurn);
}


public void turnEnd() {
  currentTurn = (myCounter == currentTurn) ? aiCounter : myCounter;
}

//If it is not my turn, stop, if I click on pass, end the turn otherwise make the move
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
//Ai makes its move now
public void turnForAi() {
  
   gBoard.makeMoveAi();
  
}
//Outputs winner message on gameover also prevents any more drawing to happen on the sketch
public void gameOver() {    
  String message;
  if ( gBoard.gameWinner() == myCounter ) {
    message = "The player has won! ( " + gBoard.returnBlack(gBoard) + " - " + gBoard.returnWhite(gBoard) + " )";
  } else if ( gBoard.gameWinner() == aiCounter ) {
    message = "The player has lost! ( " + gBoard.returnBlack(gBoard) + " - " + gBoard.returnWhite(gBoard) + " )";
  } else {
    message = "Draw!";
  }
  ui.declareWinner(message);
  noLoop();
}

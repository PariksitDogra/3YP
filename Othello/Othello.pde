import java.awt.MenuBar;
import java.awt.Menu;
import java.awt.MenuItem;
import processing.awt.PSurfaceAWT;
import java.awt.*;
import java.awt.event.*;
import java.io.*;

GameBoard gBoard; 
EnemyAI enemyAi; 
Interface ui; 

int myCounter = gBoard.BLACK; 
int aiCounter = gBoard.WHITE; 
int currentTurn = gBoard.BLACK; 
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
  MenuItem pvpOption = new MenuItem("Player vs. Player");
  optionsMenu.add(pvpOption);
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
    gBoard.allUnits();
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
    message = "The player has won!";
  } else if ( gBoard.gameWinner() == aiCounter ) {
    message = "The player has lost!";
  } else {
    message = "Draw!";
  }
  ui.showWinnerMessage(message);
  noLoop();
}

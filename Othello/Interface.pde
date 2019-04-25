
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
  
  public void showWinnerMessage(String message) {
    textSize(20);
    fill(0);
    text(message, 200 , 640 + 30);
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

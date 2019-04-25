
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

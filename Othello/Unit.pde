
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
  
  int getColumns(){
    return this.x; 
  }
  
  int getRows() {
    return this.y; 
  }
  
  boolean hasCounter() {
    return (this.counter != 0);
  }
  
  int getScore() {
    return this.counter; 
  }

  void showGhost(int showCounter) {
    if(this.hasCounter()){
     return; 
    }
    noStroke();
    if(showCounter == BLACK){
      fill(0, 255 * 0.3);  
    } else {
      fill(255, 255 * 0.3);
    }
    ellipse(this.x * size + (size/2),  this.y * size + (size/2), size * 0.9,size * 0.9);   
  }
  
  void display() {
    stroke(0);
    fill(0,0.6 * 255,0);
    rect(x * size, y * size, size, size);
    if(this.counter != 0){
      if( this.counter == BLACK){        
        fill(0);
      } else {
        fill(255); 
      }
      noStroke();
      ellipse(x * size + (size/2), y * size + (size/2),size * 0.9,size * 0.9);
    }
  }
  
  public boolean putCounter(int counterColor) {
    this.counter = counterColor;
    return true;
  }
  
  void flip() {
    this.counter *= -1; 
  }
}

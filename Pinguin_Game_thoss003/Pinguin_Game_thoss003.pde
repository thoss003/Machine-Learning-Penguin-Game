/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/17115*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
/* Modified by Rebecca Fiebrink to work with Wekinator */
/* Receives DTW commands /output_1, /output_2, /output_3 (the default messages for 1st 3 gestures) on port 12000 */

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;

final int WIDTH = 30;
final int HEIGHT = 23;
int[][] level = new int[HEIGHT][WIDTH];

int rightCount = 0;
int leftCount = 0;
int scrollPos =0;
//////
//game
int score = 0;
//int lives = 3;
boolean isLost = false;
boolean isWon = false;
int realPos;

//////


Player p1;
Clouds cl;
Mountains m1;
Enamy e1;
Fish f1;
//booleans for key presses to get a simple yes or no press and 
//to not have to worry about the thing
boolean right = false, left = false, up = false;

void setup() {
  oscP5 = new OscP5(this,12000); //listen for OSC messages on port 12000 (Wekinator default)
  dest = new NetAddress("127.0.0.1",6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  size(480,368);
  p1 = new Player(WIDTH*8,HEIGHT*8); //put the player in the middle of the window
  cl = new Clouds();
  m1 = new Mountains();
  e1 = new Enamy();
  f1 = new Fish();
}
void draw() {
  background(135,206,235);
 
    
  cl.drawCloud();
  text("lives="+p1.lives/10,(width/2)/10,(height/2)/2);
  m1.drawMountain();
  drawLevel();
  p1.update();
  p1.show();
  f1.drawFish(); 
  // Enemy
    push();
    //translate(30,100);
    e1.drawEnamy();
    e1.move();
    pop();
  //Fish
    push();
    f1.drawFish();
    f1.move();
    pop();
   //game
   e1.checkCharCollision();
   f1.checkCharCollision();
   
    if (p1.lives/10==0){
    background(255);
    fill(255,0,0);
    rect(width/3,height/2,200,10);
    text( "GAME OVER",width/3,height/2);
    redraw();
  }
  else if(p1.lives/10==5){
    background(255);
    fill(0,155,155);
    rect(width/3,height/2,200,10);
    text( "YOU WIN",width/3,height/2);
    redraw();
  }
 //  f1.checkFish();
   realPos = p1.pinguin_x - scrollPos;
   
  // m1.liveBar();
  if (rightCount > 0) {
     rightCount--;
    if (rightCount == 0)  {
       right = false;
    }
  }
  
  if (leftCount > 0) {
     leftCount--;
    if (leftCount == 0)  {
       left = false;
    }
  }
  up = false;
  
  drawText();
  
  
}

void drawLevel() {
  fill(0);
  noStroke();
  for ( int ix = 0; ix < WIDTH; ix++ ) {
    for ( int iy = 0; iy < HEIGHT; iy++ ) {
      switch(level[iy][ix]) {
        case 1: rect(ix*16,iy*16,16,16);
      }
    }
  }
}

boolean place_free(int xx,int yy) {
//checks if a given point (xx,yy) is free (no block at that point) or not
  yy = int(floor(yy/16.0));
  xx = int(floor(xx/16.0));
  if ( xx > -1 && xx < level[0].length && yy > -1 && yy < level.length ) {
    if ( level[yy][xx] == 0 ) {
      return true;
    }
  }
  return false;
}

void keyPressed() {
  switch(keyCode) {
    case RIGHT: right = true; break;
    case LEFT: left = true; break;
    case UP: up = true; break;
  }
}
void keyReleased() {
  switch(keyCode) {
    case RIGHT: right = false; break;
    case LEFT: left = false; break;
    case UP: up = false; break;
  }
}
//void mousePressed() {
////Left click creates/destroys a block
//  if ( mouseButton == LEFT ) {
//    level[int(floor(mouseY/16.0))][int(floor(mouseX/16.0))] ^= 1;
//  }
//}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/output_1")==true) {
        goLeft();
        println("left");
 } else if (theOscMessage.checkAddrPattern("/output_2")==true) {
     goRight();
     println("right");
 } else if (theOscMessage.checkAddrPattern("/output_3") == true) {
     jump();
     println("jump");
 } else {
    println("Unknown OSC message received");
 }
}

void drawText() {
  text( "Receives /output_1 /output_2 and /output_3 (default messages) from Wekinator", 5, 15 );
  text( "Receives on port 12000", 5, 30 ); 
}

private void goLeft() {
   left = true;
   leftCount = 10;
}

private void goRight() {
   right = true;
   rightCount = 10;
}

private void jump() {
  up = true;
}

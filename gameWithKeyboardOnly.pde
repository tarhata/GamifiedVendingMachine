//Press 'e' for easy mode
//Press 'm' for medium mode
//Press 'h' for hard mode

//'r' = red
//'g' = green
//'b' = blue
//'y' = yellow

import org.firmata.*;
import cc.arduino.*;

import processing.serial.*;  
import ddf.minim.*;

Minim minim;
AudioPlayer player;

Arduino arduino;
  
PFont f;

int EASY = 3;  // Number of colors for easy mode
int MED =  5;  // Number of colors for medium mode
int HARD = 7;  // Number of colors for hard mode

color[] colorFill = new color[4];
int currentColor = 0;
String colorOrder = "";
String playerOrder = "";

int count = 0; 
int colorLoop =0;
int pos = 0;


boolean easy = false;
boolean med = false;
boolean hard = false;
boolean intro = true;
boolean ready = false;
boolean inputScreen = false;
boolean locked = true;


void setup() {
  
  //setup arduino servos to pins on board
  println(Arduino.list());
  arduino = new Arduino(this, "COM3", 57600);  
  
  arduino.pinMode(7, Arduino.SERVO);
  arduino.pinMode(8, Arduino.SERVO);
  arduino.pinMode(9, Arduino.SERVO);
  
  size(1280, 800 );
  background(255);
  
  // Create the font
  printArray(PFont.list());
  f = createFont("Trebuchet MS Bold", 25);
  textFont(f);
  
  // Create the wordColor array
  colorFill[0] = color(255, 0, 0); // Colored RED
  colorFill[1] = color(0, 255, 0); // Colored GREEN
  colorFill[2] = color(0, 0, 255); //Colored BLUE
  colorFill[3] = color(255, 255, 0); // Colored YELLOW
  
  // Create audio player
  minim = new Minim(this);
  
}


void draw() {
  
  if (intro) {
    introScreen(width * 0.5);
    intro = false;
  }
  
  else if (ready) {
    readyScreen(width * 0.5);
    ready = false;
  }
       
  else if (easy && count < EASY && intro == false) { 
       randColor();
       drawColorBoard(currentColor);    
       count++; 
       redraw();
       delay(1000);
       
   } else if (med && count < MED && intro == false) { 
       randColor();
       drawColorBoard(currentColor); 
       count++; 
       redraw();
       delay(1000);
       
  } else if (hard && count < HARD && intro == false) {
       randColor();
       drawColorBoard(currentColor); 
       count++; 
       redraw();
       delay(1000);
       
  } else if (count == EASY || count == MED || count == HARD) {
    noLoop();
    delay(1000);
    inputScreen(width*0.5);
 
  } else if (colorOrder.length() > 0 && colorOrder.equals(playerOrder)) {
    unlockedScreen(width*0.5);
    resetSetup();
    redraw();    
    
  } else if (colorOrder.length() > 0 && colorOrder.equals(playerOrder) == false) {
    failedScreen(width*0.5);
    resetSetup();
    redraw();
    
  } else {
    loop();
    if (colorLoop == 4) {
      colorLoop = 0;
    }
    drawColorBoard(colorLoop);
    colorLoop++;
    delay(250);
  }
}

void resetSetup() {
    currentColor = 0;
    colorOrder = "";
    playerOrder = "";
    count = 0; 
    easy = false;
    med = false;
    hard = false;
    inputScreen = false;
}

//void testBoard() {
//  background(255);
//    fill(colorFill[0]);
//    rect(490, 0, 265, 265);
//
//    fill(colorFill[1]);
//    rect(490, 531, 265, 265);
//
//    fill(colorFill[2]);
//    rect(224, 265, 265, 265);
//
//    fill(colorFill[3]);
//    rect(756, 265, 265, 265);    
//}

void drawColorBoard(int currentColor) {
  background(255);
  if (currentColor == 0) {        //RED
    fill(colorFill[currentColor]);
    rect(490, 0, 265, 265);
  }
  
  else if (currentColor == 1) {         //BLUE
    fill(colorFill[currentColor]);
    rect(224, 265, 265, 265);
  }
  
  else if (currentColor == 2) {         //GREEN
    fill(colorFill[currentColor]);
    rect(490, 531, 265, 265);

  }
  else if (currentColor == 3) {       //YELLOW
    fill(colorFill[currentColor]);
    rect(744, 265, 265, 265);    
  }
}
    
    
// Randomize color  
void randColor() {
  int index = int(random(colorFill.length));  // Same as int(random(4))
  if (index  == currentColor) {
    randColor();
  } else {
  currentColor = index;
  colorOrder = colorOrder + currentColor;
  }
}

void introScreen(float x){
    background(255);
    fill (0, 0, 0);
    textAlign(LEFT);
    text(" 1. Choose your snack\n 2. Wait for colors to finish flashing\n 3. Use foot pad to input color sequence.\n 4. Grab your snack!", x , height * 0.4);
}

void readyScreen(float x) {
    player = minim.loadFile("start.wav");
    player.play(); 
    delay(2900); 
    background (255);
    fill (0, 0, 0);
    textSize(80);
    textAlign(CENTER);
    text("PAY ATTENTION!" , x, height * 0.5);    
}    

void inputScreen(float x) {
    background (255);
    fill (100, 100, 100);
    textSize(50);
    text("Please input color code", x, height * 0.5);    
    inputScreen = true;
    count++; 
    redraw();
}

void unlockedScreen(float x) {
    unlockDoor();
    player = minim.loadFile("right.wav");
    player.play();
    background (255);
    fill (0);
    text("Success! Enjoy your snack", x, height * 0.5);
}

void failedScreen(float x) {
    player = minim.loadFile("wrong.wav");
    player.play();   
    background (0);
    fill (255);
    text("Unlock failed. Please try again.", x, height * 0.5);
}

void unlockDoor() {
  if (easy) {  
    for(pos=90; pos < 180; pos += 5) {                                  
      arduino.servoWrite(7, pos);          
      delay(15);                       
    }

  } else if (med) {
    for (pos = 90; pos < 180; pos += 5) {
      arduino.servoWrite(8, pos); 
      delay (15);
    }
    
  } else if (hard) {
    for (pos = 90; pos < 180; pos += 5) {  
      arduino.servoWrite(9, pos);
      delay (15);
    }   
  }
} 

void lockDoor (){
    for(pos = 180; pos>=90; pos-=5) {                         
      arduino.servoWrite(7, pos);     
      arduino.servoWrite(8, pos);
      arduino.servoWrite(9, pos);     
      delay(15);         
    }
}    
 

void keyPressed() {
  if (key == ENTER) { // move to to next screen during non-color screens
    println ("code is " + colorOrder);
    println("user input is " + playerOrder);
    println ("Successful unlock? " + colorOrder.equals(playerOrder));
    redraw();
    
  } else if (key =='i') {
    introScreen(width * 0.5);
    noLoop();
  
    //EASY MODE entered
  } else if (key == 'e') {
    loop();
    ready = true;
    easy = true;
    redraw();

    //MED MODE entered
  } else if (key == 'm') {
    loop();
    ready = true;
    med = true;
    redraw();
    
    //HARD MODE entered
  } else if (key == 'h') {
    loop();
    ready = true;
    hard = true;
    redraw();
    
    //Restart game
  } else if (key == 'q') {  
    background(0);
    textSize(25);
    currentColor = 0;
    colorOrder = "";
    playerOrder = "";
    count = 0; 
    easy = false;
    med = false;
    hard = false;
    redraw();
    locked = true;

  } else if (key == 'p') {
      lockDoor();
      
    //Give feedback of which color each button corersponds to
  } else if (key == 'r'){  //RED
    player = minim.loadFile("RED.wav");
    player.play();
    if (inputScreen) {
    playerOrder = playerOrder + 0; }
  } else if (key == 'g') {  //GREEN
    player = minim.loadFile("GREEN.wav");
    player.play();
    if (inputScreen) {
    playerOrder = playerOrder + 1;   }
  } else if (key == 'b') {    //BLUE
    player = minim.loadFile("BLUE.wav");
    player.play(); 
    if (inputScreen) {
    playerOrder = playerOrder + 2;     }
  } else if (key == 'y') {   //YELLOW
    player = minim.loadFile("YELLOW.wav");
    player.play();    
   if (inputScreen) {
    playerOrder = playerOrder + 3;  }
   }
 
}

void delay(int delay) {
  int time = millis();
  while(millis() - time <= delay);
}

// g

import org.firmata.*;
import cc.arduino.*;

import processing.serial.*;  
import ddf.minim.*;

Minim minim;
AudioPlayer player;
Arduino arduino;
  
PFont f;

color[] colorFill = new color[4];
String colorOrder = "";
String playerOrder = "";
boolean intro = false;
boolean ready = false;
boolean inputScreen = false;
boolean showIntro = false;
int count = 0; 
int colorLoop =0;
int pos = 0;
int door = 0;
int currentColor = 0;

int EASY = 4;  // Number of colors for easy mode
int MED = 5;  // Number of colors for medium mode
int HARD = 7; // Number of colors for hard mode

// type of door chosen by user
boolean easy = false;
boolean med = false;
boolean hard = false;

//type of door & button connected to arduino pins  
int easyPin = 12;
int medPin = 4;
int hardPin = 2;

void setup() {
  
  //setup arduino servos to pins on board
  println(Arduino.list());
  arduino = new Arduino(this, "COM3", 57600);  
  
  arduino.pinMode(7, Arduino.SERVO);  //EASY servo
  arduino.pinMode(8, Arduino.SERVO);  //MED servo
  arduino.pinMode(9, Arduino.SERVO);  //HARD servo
  
  arduino.pinMode(12, Arduino.INPUT);  //EASY button
  arduino.pinMode(4, Arduino.INPUT);  //MED button
  arduino.pinMode(2, Arduino.INPUT);  //HARD button
  
  arduino.pinMode(13, Arduino.INPUT);  //EASY LED
  
  size(1280, 800 );
  background(255);
  
  // Create the font
  printArray(PFont.list());
  f = createFont("Trebuchet MS Bold", 25);
  textFont(f);
  
  // Create the wordColor array
  colorFill[0] = color(0, 0, 255); // Colored BLUE
  colorFill[1] = color(0, 255, 0); // Colored GREEN
  colorFill[2] = color(255, 0, 0); //Colored RED
  colorFill[3] = color(255, 255, 0); // Colored YELLOW
  
  // Create audio player
  minim = new Minim(this);
  
}


void draw() {
  
  if (arduino.digitalRead(easyPin) == Arduino.HIGH) {
      easy = true;
      ready = true;
      intro = true;
      showIntro = false;
      door = 7;
      arduino.digitalWrite(easyPin, Arduino.HIGH);
      println("easyPin = " + easyPin);
      
  } else if (arduino.digitalRead(medPin) == Arduino.HIGH) {
      med = true;
      ready = true;
      intro = true;
      showIntro = false;
      door = 8;
      println("medPin = " + medPin);
      
  } else if (arduino.digitalRead(hardPin) == Arduino.HIGH) {
      hard = true;
      ready = true;
      intro = true;
      showIntro = false;
      door = 9;
      println("hardPin = " + hardPin);      

  } else if ((keyPressed & intro == false) || showIntro == true) {
    introScreen(width * 0.5);
    showIntro = true;
   
  } else if (ready) {
    readyScreen(width * 0.5);
    ready = false;
    
  } else if (easy && count < EASY && intro == true) { 
       randColor();
       drawColorBoard(currentColor);    
       count++; 
       redraw();
       delay(1000);
       
   } else if (med && count < MED && intro == true) { 
       randColor();
       drawColorBoard(currentColor); 
       count++; 
       redraw();
       delay(1000);
       
  } else if (hard && count < HARD && intro == true) {
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
    intro = false;
    showIntro = false;
}

void testBoard() {
  background(255);
    fill(colorFill[0]);
    rect(490, 0, 265, 265);

    fill(colorFill[1]);
    rect(490, 531, 265, 265);

    fill(colorFill[2]);
    rect(224, 265, 265, 265);

    fill(colorFill[3]);
    rect(756, 265, 265, 265);    
}

void drawColorBoard(int currentColor) {
  background(255);
  if (currentColor == 0) {        //BLUE
    fill(colorFill[currentColor]);
    rect(490, 0, 265, 265);
  }
  
  else if (currentColor == 1) {         //YELLOW
    fill(colorFill[currentColor]);
    rect(224, 265, 265, 265);
  }
  
  else if (currentColor == 2) {         //RED
    fill(colorFill[currentColor]);
    rect(490, 531, 265, 265);

  }
  else if (currentColor == 3) {       //GREEN
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
    textSize(25);
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
}

void unlockedScreen(float x) {
    unlockDoor(door);
    player = minim.loadFile("right.wav");
    player.play();
    background (255);
    fill (0);
    text("Success! Enjoy your snack", x, height * 0.5);
    loop();
}

void failedScreen(float x) {
    player = minim.loadFile("wrong.wav");
    player.play();   
    background (0);
    fill (255);
    text("Unlock failed. Please try again.", x, height * 0.5);
    loop();
}

void unlockDoor(int door) {
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

void lockDoor (int door){
    for(pos = 180; pos>=90; pos-=5) {                         
      arduino.servoWrite(door, pos);          
      delay(15);         
    }
}    
 
void openDoor(int door) {
    for(pos = 90; pos<=180; pos+=5) {                         
      arduino.servoWrite(door, pos);       
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
  } else if (key == 'e' && showIntro) {
    loop();
    ready = true;
    easy = true;
    redraw();

    //MED MODE entered
  } else if (key == 'm' && showIntro) {
    loop();
    ready = true;
    med = true;
    redraw();
    
    //HARD MODE entered
  } else if (key == 'h' && showIntro) {
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
    intro = false;
    showIntro = false;

  } else if (key == 'p') {
      lockDoor(door);
      
  } else if (key == 'o') {
      openDoor(door);
      
    //Give feedback of which color each button corersponds to
  } else if (key == 'r'){  //RED
    player = minim.loadFile("RED.wav");
    player.play();
    if (inputScreen) {
    playerOrder = playerOrder + 2; }
  } else if (key == 'g') {  //GREEN
    player = minim.loadFile("GREEN.wav");
    player.play();
    if (inputScreen) {
    playerOrder = playerOrder + 1;   }
  } else if (key == 'b') {    //BLUE
    player = minim.loadFile("BLUE.wav");
    player.play(); 
    if (inputScreen) {
    playerOrder = playerOrder + 0;     }
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

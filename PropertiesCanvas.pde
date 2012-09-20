class PropertiesCanvas extends Canvas {
 int scaleFactor = 2;
 public void setup(PApplet theApplet) {  
 } 
 public void draw(PApplet p) {
  PFont plotFont = createFont("SansSerif", 20*scaleFactor);
  textFont(plotFont);
  p.text("Created by Siddharth Sathyam\nCS 424 Project 1\nLibraries Used: Controlp5, OMicronLibrary", 25 , 50);
 }
}

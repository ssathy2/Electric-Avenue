class HelpCanvas extends Canvas {
 int scaleFactor = 2;
 public void setup(PApplet theApplet) {  
 } 
 public void draw(PApplet p) {
  PFont plotFont = createFont("SansSerif", 20*scaleFactor);
  textFont(plotFont);
  p.text("Use the searchbox to search for the country you want to look at data for\nThe searchbox autocompletes so typing the country/region and clicking the button will allow data to be displayed\n", 25 , 50);
 }
}

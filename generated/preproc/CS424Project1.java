import processing.core.*; 
import processing.xml.*; 

import controlP5.*; 
import omicronAPI.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class CS424Project1 extends PApplet {

//////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////// 

////////////////////////////////////////////////////////////////////////// 

// declare some variables.
FloatTable data;
FloatTable totalPrimaryEnergyConsumption;
FloatTable totalPrimaryEnergyConsumptionPerCapita;
FloatTable totalCarbonDioxideConsumption;
FloatTable totalCarbonDioxideConsumptionPerCapita;
FloatTable totalPrimaryEnergyProduction;
FloatTable totalRenewableElectricityGeneration;

float dataMin, dataMax; 

float plotX1, plotY1; 
float plotX2, plotY2; 
float labelX, labelY;

float labelDataMin = 0;
float labelDataMax;

int yearMin, yearMax; 
int[] years; 
String[] countries;
int placeIndex = -1;

int yearInterval = 5;
float unitInterval;
int unitIntervalMinor = 1;

// text input and display options
ControlP5 controlP5;
ListBox autoCompleteBox;
ListBox dataSelectionBox;
Textfield inputBox;
//ListBoxControlListener myListener;

String text;
String currentPlace;

String[] dataText = { 
"Total Primary Energy Consumption", 
"Total Primary Energy Consumption Per Capita", 
"Total Carbon Dioxide Consumption",
"Total Carbon Dioxide Consumption Per Capita",
"Total Primary Energy Production",
"Total Renewable Electricity Generation" };

int scaleFactor = 2;
// 5 for cyber-commons
// 2 for full screen macbook

PFont plotFont;

public void setup() {
  //size(1280, 650);
  size(1000, 500);
 
  // load in all our data
  loadData();

  // start off by showing users totalPrimaryEnergyconsumption table by setting this data field
  data = totalPrimaryEnergyConsumption;
  
  PFont font = createFont("arial", 20);
  
  controlP5 = new ControlP5(this); 
  inputBox = controlP5.addTextfield("input")
    .setPosition(20,100)
    .setSize(200,40)
    .setFont(font)
    .setFocus(true)
    .setColor(color(255,0,0))
    ;
 
  countries = data.getRowNames();
  currentPlace = countries[0];
  years = PApplet.parseInt(data.getColumnNames()); 
  
  yearMin = years[0]; 
  yearMax = years[years.length - 1]; 
  
  // Corners of the plotted time series
  plotX1 = 120;
  plotX2 = width - 80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 70;
  labelY = height - 25;
 
  plotFont = createFont("SansSerif", 20);
  textFont(plotFont);

  smooth();
  
  initAutoCompleteBox();
  initDataSelectionBox();
  
  //myListener = new ListBoxControlListener();
  
  //controlP5.getGroup("myList").addListener(myListener);
}

public void displayGraph(int row) {
   // Show the plot area as a white box 
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);

  stroke(0xff5679C1);
  strokeWeight(2);
  drawDataLine(row); 
}

public void displayTable(int row) {
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);

  stroke(0xff5679C1);
  strokeWeight(2);
  drawTable(row);
}

public void drawTable(int row) {
  
  
}

public void draw() {
  background(224);
 
  drawTitle();
  drawAxisLabels();
  drawYearLabels();
  
  stroke(0xff5679C1);
  strokeWeight(2);
  noFill();
  
  if(placeIndex >= 0) {
    currentPlace = countries[placeIndex];
  }
  
  if(currentPlace != "") {
    int row = rowCorrespondingToPlace(currentPlace);
    unitInterval = data.calculateStandardDeviation(row);
    dataMin = data.getRowMin(row); 
    dataMax = data.getRowMax(row); 
    displayGraph(row);
  }
  drawUnitLabels();
}


public void drawTitle() {
  fill(0);
  textSize(20);
  textAlign(LEFT);
  String title = data.tableTitle + ": " + currentPlace;
  text(title, plotX1, plotY1 - 10);
}


public void drawAxisLabels() {
  fill(0);
  textSize(13);
  textLeading(15);
 
  textAlign(CENTER, CENTER);
  text(data.tableUnits, labelX, (plotY1+plotY2)/2);
  textAlign(CENTER);
  text("Year", (plotX1+plotX2)/2, labelY);
}


public void drawYearLabels() {
  fill(0);
  textSize(10);
  textAlign(CENTER, TOP);
 
  // Use thin, gray lines to draw the grid
  stroke(224);
  strokeWeight(1);
 
  for (int row = 0; row < years.length; row++) {
    if (years[row] % yearInterval == 0) {
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row], x, plotY2 + 10);
      line(x, plotY1, x, plotY2);
    }
  }
}

public void drawUnitLabels() {
  fill(0);
  textSize(10);
  textAlign(RIGHT);
  
  stroke(128);
  strokeWeight(1);

  for (float v = 0; v <= dataMax; v += unitInterval) {
      float y = map(v, labelDataMin, dataMax, plotY2, plotY1);  
        if (v == labelDataMin) {
          textAlign(RIGHT);                 // Align by the bottom
          text(floor(v), plotX1 - 10, y+4);
  
        } else if (v == dataMax) {
          if(!(v < 1)) {
            textAlign(RIGHT, TOP);            // Align by the top
            text(floor(v), plotX1 - 10, y); 
          }
          else {
            String dis = nf(v, 1, 4);
            text(dis, plotX1 -10, y);
          }
        } else {
          if(!(v < 1)) {
            textAlign(RIGHT, CENTER);            // Align by the top
            text(floor(v), plotX1 - 10, y); 
          }
          else {
            String dis = nf(v, 1, 4);
            text(dis, plotX1 -10, y);
          }
        }
        
        line(plotX1 - 4, y, plotX1, y);     // Draw major tick
  }
}

public void loadData() {
  totalPrimaryEnergyConsumption = new FloatTable("Total_Primary_Energy_Consumption_(Quadrillion_Btu).csv", "Quadrillion Btu", "Total Primary Energy Consumption"); 
  totalPrimaryEnergyConsumptionPerCapita = new FloatTable("Total_Primary_Energy_Consumption_per_Capita_(Million_Btu_per_Person).csv", "Million Btu\nper person", "Total Primary Energy Consumption per Person");
  totalCarbonDioxideConsumption = new FloatTable("Total_Carbon_Dioxide_Emissions_from_the_Consumption_of_Energy_(Million_Metric_Tons).csv", "Million\nMetric Tons", "Total Carbon Dioxide Emissions from Consumption of Energy");
  totalCarbonDioxideConsumptionPerCapita = new FloatTable("Per_Capita_Carbon_Dioxide_Emissions_from_the_Consumption_of_Energy_(Metric_Tons_of_Carbon_Dioxide_per_Person).csv", "Metric Tons of\nCarbon Dioxide\nper Person", "Total Carbon Dioxide Emissions from Consumption of Energy per Person");
  totalPrimaryEnergyProduction = new FloatTable("Total_Primary_Energy_Production_(Quadrillion_Btu).csv", "Quadrillion Btu", "Total Primary Energy Production");
  totalRenewableElectricityGeneration = new FloatTable("Total_Renewable_Electricity_Net_Generation_(Billion_Kilowatthours).csv", "BillionKilowatthours", "Total Renewable Electricity Net Generation");
}

// Draw the data as a series of points 
public void drawDataPoints(int row) {
  int colCount = data.getColumnCount();
  for (int col = 0; col < colCount; col++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      float x = map(years[col], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      point(x,y);
    }
  }
}

// Draw the data as a continuous line
public void drawDataLine(int row) {
  int colCount = data.getColumnCount();
  beginShape();
  for (int col = 0; col < colCount; col++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      float x = map(years[col], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, 0, dataMax, plotY2, plotY1);
      vertex(x,y);
    }
  }
  endShape();
}

// method returns the row# corresponding to the index of the place passed in as a param...-1 returned if not found
public int rowCorrespondingToPlace(String place) {
  String[] places = data.getRowNames();
  for(int i = 0; i <  places.length; i++) {
    if(places[i].equals(place)) {
       return i;
    }
  }
  return -1;
}

public void keyPressed() {
  text = ((Textfield)controlP5.get(Textfield.class, "input")).getText();
  autoCompleteBox.clear();
  for(int i = 0; i < countries.length; i++) {
    if(countries[i].toLowerCase().startsWith(text.toLowerCase())) {
            autoCompleteBox.addItem(countries[i], i);
    }
  }   
}

public void controlEvent(ControlEvent theEvent) {
    if(theEvent.isGroup() && theEvent.name().equals("myList")){
      println(theEvent.group() + ": " + theEvent.group().value());
      placeIndex = (int)theEvent.group().value();
      inputBox.setText(countries[placeIndex]);
    }
    else if(theEvent.isGroup() && theEvent.name().equals("dataBox")) {
      println(theEvent.group() + ": " + theEvent.group().value());
      int value = (int)theEvent.group().value();
      switch (value){
        case 0: data = totalPrimaryEnergyConsumption;
                break;
        case 1: data = totalPrimaryEnergyConsumptionPerCapita;
                break;
        case 2: data = totalCarbonDioxideConsumption;
                break;
        case 3: data = totalCarbonDioxideConsumptionPerCapita;
                break;
        case 4: data = totalPrimaryEnergyProduction;
                break;
        case 5: data = totalRenewableElectricityGeneration;
                break;       
      }
    }
  }
  
 
public void initAutoCompleteBox() {
  autoCompleteBox = controlP5.addListBox("myList")
    .setPosition(20, 160)
    .setSize(200, 200)
    .setItemHeight(15)
    .setBarHeight(15)
    .setColorBackground(color(40, 128))
    .setColorActive(color(255, 128));
    
    autoCompleteBox.addItems(countries);
}

public void initDataSelectionBox() {
    dataSelectionBox = controlP5.addListBox("dataBox")
    .setPosition(width - 250, 20)
    .setSize(225, 225)
    .setItemHeight(20)
    .setColorBackground(color(40, 128))
    .setColorActive(color(255, 128));
  
    dataSelectionBox.addItems(dataText);
}

// first line of the file should be the column headers
// first column should be the row titles
// all other values are expected to be floats
// getFloat(0, 0) returns the first data value in the upper lefthand corner
// files should be saved as "text, tab-delimited"
// empty rows are ignored
// extra whitespace is ignored


class FloatTable {
  int rowCount;
  int columnCount;
  float[][] data;
  String[] rowNames;
  String[] columnNames;
  String tableUnits;
  String tableTitle;
  
  FloatTable(String filename, String units, String title) {
    tableUnits = units;
    tableTitle = title;
    
    String[] rows = loadStrings(filename);
    
    String[] columns = split(rows[0], ',');
    
    columnNames = subset(columns, 1); // upper-left corner ignored

    scrubQuotes(columnNames);
    columnCount = columnNames.length;

    rowNames = new String[rows.length-1];
    data = new float[rows.length-1][];
  
    // start reading at row 1, because the first row was only the column headers
    for (int i = 1; i < rows.length; i++) {
      if (trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if (rows[i].startsWith("#")) {
        continue;  // skip comment lines
      }

      // split the row on the tabs
      String[] pieces = split(rows[i], ',');

      // copy row title
      rowNames[rowCount] = pieces[0];
      // copy data into the table starting at pieces[1]
      data[rowCount] = parseFloat(subset(pieces, 1));

      // increment the number of valid rows found so far
      rowCount++;      
    }
  }
  
  
  public void scrubQuotes(String[] array) {
    for (int i = 0; i < array.length; i++) {
      if (array[i].length() > 2) {
        // remove quotes at start and end, if present
        if (array[i].startsWith("\"") && array[i].endsWith("\"")) {
          array[i] = array[i].substring(1, array[i].length() - 1);
        }
      }
      // make double quotes into single quotes
      array[i] = array[i].replaceAll("\"\"", "\"");
    }
  }
  
  
  public int getRowCount() {
    return rowCount;
  }
  
  
  public String getRowName(int rowIndex) {
    return rowNames[rowIndex];
  }
  
  
  public String[] getRowNames() {
    return rowNames;
  }

  
  // Find a row by its name, returns -1 if no row found. 
  // This will return the index of the first row with this name.
  // A more efficient version of this function would put row names
  // into a Hashtable (or HashMap) that would map to an integer for the row.
  public int getRowIndex(String name) {
    for (int i = 0; i < rowCount; i++) {
      if (rowNames[i].equals(name)) {
        return i;
      }
    }
    //println("No row named '" + name + "' was found");
    return -1;
  }
  
  
  // technically, this only returns the number of columns 
  // in the very first row (which will be most accurate)
  public int getColumnCount() {
    return columnCount;
  }
  
  
  public String getColumnName(int colIndex) {
    return columnNames[colIndex];
  }
  
  
  public String[] getColumnNames() {
    return columnNames;
  }


  public float getFloat(int rowIndex, int col) {
    // Remove the 'training wheels' section for greater efficiency
    // It's included here to provide more useful error messages
    
    // begin training wheels
    if ((rowIndex < 0) || (rowIndex >= data.length)) {
      throw new RuntimeException("There is no row " + rowIndex);
    }
    if ((col < 0) || (col >= data[rowIndex].length)) {
      throw new RuntimeException("Row " + rowIndex + " does not have a column " + col);
    }
    // end training wheels
    
    return data[rowIndex][col];
  }
  
  
  public boolean isValid(int row, int col) {
    if (row < 0) return false;
    if (row >= rowCount) return false;
    //if (col >= columnCount) return false;
    if (col >= data[row].length) return false;
    if (col < 0) return false;
    return !Float.isNaN(data[row][col]);
  }


  public float getColumnMin(int col) {
    float m = Float.MAX_VALUE;
    for (int row = 0; row < rowCount; row++) {
      if (isValid(row, col)) {
        if (data[row][col] < m) {
          m = data[row][col];
        }
      }
    }
    return m;
  }


  public float getColumnMax(int col) {
    float m = -Float.MAX_VALUE;
    for (int row = 0; row < rowCount; row++) {
      if (isValid(row, col)) {
        if (data[row][col] > m) {
          m = data[row][col];
        }
      }
    }
    return m;
  }

  
  public float getRowMin(int row) {
    float m = Float.MAX_VALUE;
    for (int col = 0; col < columnCount; col++) {
      if (isValid(row, col)) {
        if (data[row][col] < m) {
          m = data[row][col];
        }
      }
    }
    return m;
  } 


  public float getRowMax(int row) {
    float m = -Float.MAX_VALUE;
    for (int col = 0; col < columnCount; col++) {
      if (isValid(row, col)) {
        if (data[row][col] > m) {
          m = data[row][col];
        }
      }
    }
    return m;
  }


  public float getTableMin() {
    float m = Float.MAX_VALUE;
    for (int row = 0; row < rowCount; row++) {
      for (int col = 0; col < columnCount; col++) {
        if (isValid(row, col)) {
          if (data[row][col] < m) {
            m = data[row][col];
          }
        }
      }
    }
    return m;
  }
  
  public float calculateStandardDeviation(int row) {
   float mean = calculateMeanRow(row);
   float tmpArr[] = new float[columnCount];
   for(int i = 0; i < columnCount; i++) {
     if(isValid(row, i)) {
       tmpArr[i] = pow((getFloat(row, i) - mean), 2); 
     }
   }
   return sqrt(calculateMeanArray(tmpArr));
  }
  
  public float calculateMeanArray(float arr[]){
    float retVal = 0;
    int count = 0;
    for(int i = 0; i < arr.length; i++) {
      //if(arr[i] != 0) {
        count++;
        retVal += arr[i]; 
      //}
    }
    return retVal / count;
  }
  
  public float calculateMeanRow(int row) {
    float tot = 0;
    int count = 0;
    for(int i = 0; i < columnCount; i++) {
      if(isValid(row, i)) {
        count++;
        tot += getFloat(row, i);
      }
    }
    return tot/count;
  }

  public float getTableMax() {
    float m = -Float.MAX_VALUE;
    for (int row = 0; row < rowCount; row++) {
      for (int col = 0; col < columnCount; col++) {
        if (isValid(row, col)) {
          if (data[row][col] > m) {
            m = data[row][col];
          }
        }
      }
    }
    return m;
  }
}

/*class TouchListener implements OmicronTouchListener{
 
  // Called on a touch down event
  // mousePressed events also call this with an ID of -1 and an xWidth and yWidth of 10.
  public void touchDown(int ID, float xPos, float yPos, float xWidth, float yWidth){
    fill(255,0,0);
    noStroke();
    ellipse( xPos, yPos, xWidth, yWidth );
    
    // This is an optional call if you want the function call in the main applet class.
    // 'OmicronExample' should be replaced with the sketch name i.e. ((SketchName)applet).touchDown( ID, xPos, yPos, xWidth, yWidth );
    // Make sure applet is defined as PApplet and that 'applet = this;' is in setup().
    ((proj1)applet).touchDown( ID, xPos, yPos, xWidth, yWidth );
  }// touchDown
  
  // Called on a touch move event
  // mouseDragged events also call this with an ID of -1 and an xWidth and yWidth of 10.
  public void touchMove(int ID, float xPos, float yPos, float xWidth, float yWidth){
    fill(0,255,0);
    noStroke();
    ellipse( xPos, yPos, xWidth, yWidth );
    
    ((proj1)applet).touchMove( ID, xPos, yPos, xWidth, yWidth );
  }// touchMove
  
  // Called on a touch up event
  // mouseReleased events also call this with an ID of -1 and an xWidth and yWidth of 10.
  public void touchUp(int ID, float xPos, float yPos, float xWidth, float yWidth){
    fill(0,0,255);
    noStroke();
    ellipse( xPos, yPos, xWidth, yWidth );
    
    ((proj1)applet).touchUp( ID, xPos, yPos, xWidth, yWidth );
  }// touchUp
  
}// TouchListener
*/

    static public void main(String args[]) {
        PApplet.main(new String[] { "--bgcolor=#ECE9D8", "CS424Project1" });
    }
}

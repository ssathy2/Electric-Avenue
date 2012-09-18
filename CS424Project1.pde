import hypermedia.net.*;
import omicronAPI.*;

import controlP5.*;

OmicronAPI omicronManager;
TouchListener touchListener;
PApplet applet;

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

boolean showAllCountries;
// Control Position and Size vars
// TextField
int placeTextFieldX, placeTextFieldY;
int placeTextFieldHeight, placeTextFieldWidth;
int placeTextFieldTextSize;

// dummy var to force yearsSlider to use Ints
int yearsSlider;

// DataBox
int dataBoxX, dataBoxY;

// AutoCompletBox
int autoCompleteBoxX, autoCompleteBoxY;

// ListBox related
int listBoxHeight, listBoxWidth;
int listBoxItemHeight, listBoxItemWidth;
int listBoxItemTextSize;

// yearsSlider related
int yearsSliderX, yearsSliderY;
int yearsSliderWidth, yearsSliderHeight;
int yearsSliderHandleSize;

// selectPlace related
int selectButtonX, selectButtonY;
int selectButtonWidth, selectButtonHeight;

// selectButton related
float labelDataMin = 0;

int startCol;
int endCol;
boolean colsChanged = false;

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
Range yearRange;
Button selectPlaceButton;
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

public void init() {
  super.init();
  omicronManager = new OmicronAPI(this);
  //omicronManager.setFullscreen(true);
}

public void setup() {
  //size(1280, 650);
  size(1280, 800);
  //size(720, 405);
  touchListener = new TouchListener();
  
  //omicronManager.setTouchListener(touchListener);
 
  showAllCountries = true;
 
  applet = this;
  
  // load in all our data
  loadData();

  // start off by showing users totalPrimaryEnergyconsumption table by setting this data field
  data = totalPrimaryEnergyConsumption;
  
  PFont font = createFont("arial", 20);
  
  countries = data.getRowNames();
  currentPlace = countries[0];

  years = PApplet.parseInt(data.getColumnNames()); 
  
  yearMin = years[0]; 
  yearMax = years[years.length - 1]; 
  startCol = 0;
  endCol = years.length - 1;
  
  // Corners of the plotted time series
  plotX1 = 150+70*scaleFactor;
  plotX2 = width - 80;
  labelX = 20+35*scaleFactor;
  plotY1 = 10+20*scaleFactor;
  plotY2 = height - 100 - 20*scaleFactor;
  labelY = height - 80 - 5*scaleFactor;
  // Control Position and Size vars
  
  // TextField
  placeTextFieldX = 10;
  placeTextFieldY = 10+30*scaleFactor;
  placeTextFieldHeight = 20 * scaleFactor;
  placeTextFieldWidth = 105 * scaleFactor;
  placeTextFieldTextSize = 20 * scaleFactor;
  
  // ListBox related
  listBoxHeight = 150 * scaleFactor;
  listBoxWidth = placeTextFieldWidth;
  listBoxItemHeight = 17 * scaleFactor;
  listBoxItemTextSize = 10 * scaleFactor;

  // AutoCompletBox
  autoCompleteBoxX = placeTextFieldX;
  autoCompleteBoxY = placeTextFieldY + placeTextFieldHeight;

    // DataBox
  dataBoxX = autoCompleteBoxX;
  dataBoxY = autoCompleteBoxY + listBoxHeight;
  
  // yearsSlider related
  yearsSliderX = floor(plotX1);
  yearsSliderY = height - (40 * scaleFactor);
  yearsSliderWidth = floor(plotX2 - plotX1);
  yearsSliderHeight = 25 * scaleFactor;
  yearsSliderHandleSize = 15 * scaleFactor;
  
  // selectPlace related
  selectButtonX = 100;
  selectButtonY = 100;
  selectButtonWidth = 40;
  selectButtonHeight = 40;

  plotFont = createFont("SansSerif", 20*scaleFactor);
  
  textFont(plotFont);

  smooth();
  
  controlP5 = new ControlP5(this); 

  initTextField(font);
  initYearsSlider();
  initAutoCompleteBox();
  initDataSelectionBox();
  initSelectButton();
  
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
  omicronManager.process();
  
  // don't keep looping over an array over and over again
  if (colsChanged) {
    startCol = data.getColumnIndex(String.valueOf(yearMin));
    endCol = data.getColumnIndex(String.valueOf(yearMax));
    if(((yearMax - yearMin) / 5) >= 1) {
      yearInterval = ((yearMax - yearMin) / 5);
    }
    else {
      yearInterval = 1;  
    }
    
    colsChanged = false;
  }
  
  drawTitle();
  drawAxisLabels();
  
  if((yearMax - yearMin) != 0) {
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
      //drawDataPoints(row);
    }
    drawUnitLabels();
  }
}

//Force full screen 
boolean sketchFullScreen() {
    return true;
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
 
  for (int row = startCol; row <= endCol; row++) {
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
          //text(floor(v), plotX1 - 10, y+4);
  
        } else if (v == dataMax) {
          //if(!(v < 1)) {
            textAlign(RIGHT, TOP);            // Align by the top
            //text(floor(v), plotX1 - 10, y); 
          //}
          //else {
            //String dis = nf(v, 1, 5);
            //text(dis, plotX1 -10, y);
         // }
        } else {
          //if(!(v < 1)) {
            textAlign(RIGHT, CENTER);            // Align by the top
          //  text(floor(v), plotX1 - 10, y); 
          //}
          //else {
         //   String dis = nf(v, 1, 5);
          //  text(dis, plotX1 -10, y);
          //}
        }
        String dis = nf(v, 1, 5);
        text(dis, plotX1 -10, y);
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
  for (int col = startCol; col <= endCol; col++) {
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
  beginShape();
  for (int col = startCol; col <= endCol; col++) {
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

public void keyReleased() {
  text = ((Textfield)controlP5.get(Textfield.class, "input")).getText();
  showAllCountries = false;
  autoCompleteBox.clear();
  println(text);
  for(int i = 0; i < countries.length; i++) {
    if(text.length() == 0) {
        autoCompleteBox.addItem(countries[i], i);      
    }
    else {
      if(countries[i].toLowerCase().startsWith(text.toLowerCase())) {
        autoCompleteBox.addItem(countries[i], i);
      }
    }
  }
  autoCompleteBox.update();  
}

public void selectPlaceButton(int theValue) {
    text = ((Textfield)controlP5.get(Textfield.class, "input")).getText();
    if(text != "") {
      int index = containsElement(countries, text);
      if(index > 0) {
        placeIndex = index;
        draw(); 
      } 
    }
}

public int containsElement(String[] arr, String val) {
   for(int i = 0; i < arr.length; i++) {
     if(arr[i].toLowerCase().equals(val.toLowerCase())) {
        return i; 
     }
   } 
   return -1;
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
    else if(theEvent.isFrom("yearsSlider")) {
      yearMin = floor(theEvent.getController().getArrayValue(0));
      yearMax = floor(theEvent.getController().getArrayValue(1));
      println("Slider: New Range Vals-> min: " + yearMin + " max: " + yearMax);
      colsChanged = true;   
    }
  }
  
 
public void initAutoCompleteBox() {
  autoCompleteBox = controlP5.addListBox("myList")
    .setLabel("")
    .setPosition(autoCompleteBoxX, autoCompleteBoxY)
    .setSize(listBoxWidth, listBoxHeight)
    .setItemHeight(listBoxItemHeight)
    .setBarHeight(0)
    .setColorBackground(color(40, 128))
    .setColorActive(color(255, 128));
    
    autoCompleteBox.addItems(countries);
}

public void initDataSelectionBox() {
    dataSelectionBox = controlP5.addListBox("dataBox")
    .setLabel("")
    .setPosition(dataBoxX, dataBoxY)
    .setSize(listBoxWidth, listBoxHeight)
    .setItemHeight(listBoxItemHeight)
    .setBarHeight(0)
    .setColorBackground(color(40, 128))
    .setColorActive(color(255, 128));
  
    dataSelectionBox.addItems(dataText);
}

public void initYearsSlider() {  
  yearRange = controlP5
      .addRange("yearsSlider")
      // disable broadcasting since setRange and setRangeValues will
      // trigger an event
      .setBroadcast(false)
      .setLabel("")
      .setPosition(yearsSliderX, yearsSliderY)
      .setSize(yearsSliderWidth, yearsSliderHeight)
      .setHandleSize(yearsSliderHandleSize)
      .setRange(floor(yearMin), floor(yearMax))
      .setRangeValues(floor(yearMin), floor(yearMax))
      // after the initialization we turn broadcast back on again
      .setBroadcast(true)
      .setColorForeground(color(50,0,255))
      .setColorActive(color(205,205,205))
      .setColorBackground(color(0,0,0)); 
}

public void initTextField(PFont font) {    
  inputBox = controlP5.addTextfield("input")
      .setPosition(placeTextFieldX,placeTextFieldY)
      .setSize(placeTextFieldWidth,placeTextFieldHeight)
      .setFont(font)
      .setFocus(true)
      .setColor(color(255,0,0))
      .setLabel("")
      ;

  inputBox.setText(currentPlace);
}

public void initSelectButton() {
   selectPlaceButton = controlP5.addButton("selectPlaceButton")
                       .setPosition(selectButtonX, selectButtonY)
                       .setSize(selectButtonWidth, selectButtonHeight)
                       ;
}

void touchDown(int ID, float xPos, float yPos, float xWidth, float yWidth){
  //("touchDown(): Called from Proj class");
  println("X: " + xPos + " Y: " + yPos);
  noFill();
  stroke(255,0,0);
  ellipse( xPos, yPos, xWidth * 2, yWidth * 2 );
}// touchDown

void touchMove(int ID, float xPos, float yPos, float xWidth, float yWidth){
  //println("touchMove(): Called from Proj class");
  noFill();
  stroke(0,255,0);
  ellipse( xPos, yPos, xWidth * 2, yWidth * 2 );
}// touchMove

void touchUp(int ID, float xPos, float yPos, float xWidth, float yWidth){
  //println("touchUp(): Called from Proj class");
  noFill();
  stroke(0,0,255);
  ellipse( xPos, yPos, xWidth * 2, yWidth * 2 );
}// touchUp

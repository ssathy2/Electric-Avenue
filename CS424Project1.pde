import processing.net.*;
import controlP5.*;
import hypermedia.net.*;
import omicronAPI.*;

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

float tablePlotX1, tablePlotY1; 
float tablePlotX2, tablePlotY2; 

float labelX, labelY;

color textColor = color(205, 205, 205);

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

// graphTableRadioButton related
int graphTableRadioButtonX, graphTableRadioButtonY;
int graphTableRadioButtonHeight, graphTableRadioButtonWidth;

// helpButton related
int helpButtonX, helpButtonY;
int helpButtonHeight, helpButtonWidth;

// Creditsbutton related
int creditsButtonX, creditsButtonY;
int creditsButtonHeight, creditsButtonWidth;

// showWorldDataButton
int showWorldDataToggleX, showWorldDataToggleY;
int showWorldDataToggleHeight, showWorldDataToggleWidth;

// selectButton related
float labelDataMin = 0;

int startCol;
int endCol;
boolean colsChanged = false;
boolean showGraph = true;
boolean showWorldData = false;

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
RadioButton graphTableRadioButton;
Button helpButton;
Button creditsButton;
Toggle showWorldDataToggle;

//ListBoxControlListener myListener;
// Properties Related

String text;
String currentPlace;

String[] dataText = { 
"Total Primary Energy Consumption", 
"Total Primary Energy Consumption Per Capita", 
"Total Carbon Dioxide Emissions",
"Total Carbon Dioxide Emissions Per Capita",
"Total Primary Energy Production",
"Total Renewable Electricity Generation" };

int scaleFactor;
// 5 for cyber-commons
// 2 for full screen macbook

PFont plotFont;
PFont font;

boolean displayOnWall = true;
boolean displayHelp = false;
boolean displayCredits = false;

public void init() {
  super.init();
  omicronManager = new OmicronAPI(this);
  omicronManager.setFullscreen(true);
}

public void setup() {
  if(displayOnWall) {
    size(8160, 2304, P3D);
    scaleFactor = 5;
  }
  else {
    size(1280, 800);
    scaleFactor = 2;
  }
  touchListener = new TouchListener();
  
  omicronManager.setTouchListener(touchListener);
  //omicronManager.ConnectToTracker(7001, 7340, "131.193.77.104");
  showAllCountries = true;
  font = createFont("SansSerif", 10 * scaleFactor);

  applet = this;
  
  // load in all our data
  loadData();

  // start off by showing users totalPrimaryEnergyconsumption table by setting this data field
  data = totalPrimaryEnergyConsumption;
   
  countries = data.getRowNames();
  currentPlace = countries[0];

  years = PApplet.parseInt(data.getColumnNames()); 
  
  yearMin = years[0]; 
  yearMax = years[years.length - 1]; 
  startCol = 0;
  endCol = years.length - 1;
  
  // Corners of the plotted time series
  plotX1 = 100 + 200*scaleFactor;
  plotX2 = width - 20;
  labelX = 35*scaleFactor;
  plotY1 = 25*scaleFactor;
  plotY2 = height - 20 - 60*scaleFactor;
  labelY = height - 20 - 40*scaleFactor;
  // Control Position and Size vars
  
  tablePlotX1 = plotX1;
  tablePlotY1 = plotY1 + 5*scaleFactor;
  tablePlotX2 = plotX2;
  tablePlotY2 = height - 15*scaleFactor;  
  
  // TextField
  placeTextFieldX = 10;
  placeTextFieldY = displayOnWall?40*scaleFactor:25*scaleFactor;
  placeTextFieldHeight = 20 * scaleFactor;
  placeTextFieldWidth = 180 * scaleFactor;
  placeTextFieldTextSize = 20 * scaleFactor;
  
  // ListBox related
  listBoxHeight = 190 * scaleFactor;
  listBoxWidth = placeTextFieldWidth;
  listBoxItemHeight = 17 * scaleFactor;
  listBoxItemTextSize = 10 * scaleFactor;

  // AutoCompletBox
  autoCompleteBoxX = placeTextFieldX;
  autoCompleteBoxY = placeTextFieldY + placeTextFieldHeight + 1;

    // DataBox
  dataBoxX = autoCompleteBoxX;
  dataBoxY = displayOnWall?autoCompleteBoxY + listBoxHeight + 15 * scaleFactor:autoCompleteBoxY + listBoxHeight;
  
  // yearsSlider related
  yearsSliderX = floor(plotX1);
  yearsSliderY = height - (32 * scaleFactor);
  yearsSliderWidth = floor(plotX2 - plotX1);
  yearsSliderHeight = 25 * scaleFactor;
  yearsSliderHandleSize = 15 * scaleFactor;

  // graphTableRadioButton related
  graphTableRadioButtonX = placeTextFieldX;
  graphTableRadioButtonY = displayOnWall?dataBoxY + listBoxItemHeight*6 + 25 * scaleFactor:dataBoxY + listBoxItemHeight*6 + 15 * scaleFactor;
  graphTableRadioButtonHeight = listBoxItemHeight;
  graphTableRadioButtonWidth = listBoxItemHeight;
  
  // help and credits button related
  helpButtonHeight = listBoxItemHeight;
  helpButtonWidth = listBoxWidth / 2;
  creditsButtonHeight = listBoxItemHeight;
  creditsButtonWidth = listBoxWidth / 2;
  helpButtonX = graphTableRadioButtonX;
  helpButtonY = graphTableRadioButtonY + graphTableRadioButtonHeight + 10 * scaleFactor;
  creditsButtonX = helpButtonX + helpButtonWidth + 10 * scaleFactor;
  creditsButtonY = helpButtonY;
  
  // showWorldDataButton
  showWorldDataToggleX = graphTableRadioButtonX + 85*scaleFactor + graphTableRadioButtonWidth;
  showWorldDataToggleY = graphTableRadioButtonY;
  showWorldDataToggleHeight = graphTableRadioButtonHeight;
  showWorldDataToggleWidth = graphTableRadioButtonWidth;
  
  plotFont = createFont("SansSerif", 20*scaleFactor);
  
  textFont(plotFont);

  smooth();
  
  controlP5 = new ControlP5(this);
  PFont listBoxFont = createFont("SansSerif", 8 * scaleFactor);
  ControlFont listBoxF = new ControlFont(listBoxFont);
  controlP5.setFont(listBoxF);
  
  initTextField();
  initYearsSlider();
  initAutoCompleteBox();
  initDataSelectionBox();
  initGraphTableRadioButton();
  initHelpButton();
  initCreditsButton();
  initShowWorldDataToggle();
}

public void displayGraph(int row) {
   // Show the plot area as a white box 
  fill(#262626);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);

  stroke(#EDFC47);
  strokeWeight(2);
  drawDataLine(row); 
}

public void displayTable(int row) {
  fill(#262626);
  rectMode(CORNERS);
  noStroke();
  rect(tablePlotX1, tablePlotY1, tablePlotX2, tablePlotY2);

  stroke(textColor);
  strokeWeight(1);
  drawTable(row);
}

public void drawTable(int row) {
  int dataDrawOffset = floor(((tablePlotY2 - tablePlotY1)) / 30);
  int lineDrawOffset = dataDrawOffset;
  textSize(10 * scaleFactor);
  
  if(!showWorldData) {
    // draw separator line
    line(tablePlotX1 + ((tablePlotX2 - tablePlotX1) / 2), tablePlotY1 - 15, tablePlotX1 + ((tablePlotX2 - tablePlotX1) / 2), tablePlotY1 + (lineDrawOffset * 30) + 5);
    line(tablePlotX1 + ((tablePlotX2 - tablePlotX1) / 4) - 13*scaleFactor, tablePlotY1 + 5, tablePlotX1 + ((3 *(tablePlotX2 - tablePlotX1)) / 4), tablePlotY1 + 5);
  }
  else{
    // separator lines...prob the stupidest way to do this
    line(tablePlotX1 + (27*(tablePlotX2 - tablePlotX1) / 100)
         ,tablePlotY1 - 15
         ,tablePlotX1 + (27*(tablePlotX2 - tablePlotX1) / 100)
         ,tablePlotY1 + (lineDrawOffset * 30) + 5);

    line(tablePlotX1 + (63*((tablePlotX2 - tablePlotX1) / 100))
         ,tablePlotY1 - 15
         ,tablePlotX1 + (63*((tablePlotX2 - tablePlotX1) / 100))
         ,tablePlotY1 + (lineDrawOffset * 30) + 5 );
       
    line(tablePlotX1 + ((tablePlotX2 - tablePlotX1) / 6) - 13*scaleFactor, tablePlotY1 + 5, tablePlotX1 + ((5 *(tablePlotX2 - tablePlotX1)) / 6), tablePlotY1 + 5);
  }

  for(int col = 0; col < data.columnCount; col++) {
    if(data.isValid(row, col)) {
      if(showWorldData) {
  
        fill(textColor);
        textAlign(CENTER);
        text(years[col], tablePlotX1 + (tablePlotX2 - tablePlotX1) / 6, tablePlotY1 + (dataDrawOffset * (col + 1)));
        fill(#EDFC47);
        textAlign(RIGHT);
        text(data.getFloat(row, col), tablePlotX1 + ((tablePlotX2 - tablePlotX1) / 2) , tablePlotY1 + (dataDrawOffset * (col + 1)));
        fill(#1DB5E5);
        text(data.getFloat(231, col), tablePlotX1 + ((5 * (tablePlotX2 - tablePlotX1)) / 6) , tablePlotY1 + (dataDrawOffset * (col + 1)));
        
        line(tablePlotX1 + ((tablePlotX2 - tablePlotX1) / 6) - 13*scaleFactor, tablePlotY1 + (lineDrawOffset * (col + 1)) + 5, tablePlotX1 + ((5 *(tablePlotX2 - tablePlotX1)) / 6), tablePlotY1 + (lineDrawOffset * (col + 1)) + 5);
      }
      else {       
        fill(textColor);
        textAlign(CENTER);
        text(years[col], tablePlotX1 + ((tablePlotX2 - tablePlotX1) / 4), tablePlotY1 + (dataDrawOffset * (col + 1)));
        fill(#EDFC47);
        textAlign(RIGHT);
        text(data.getFloat(row, col), tablePlotX1 + ((3 *(tablePlotX2 - tablePlotX1)) / 4) , tablePlotY1 + (dataDrawOffset * (col + 1)));
        line(tablePlotX1 + ((tablePlotX2 - tablePlotX1) / 4) - 13*scaleFactor, tablePlotY1 + (lineDrawOffset * (col + 1)) + 5, tablePlotX1 + ((3 *(tablePlotX2 - tablePlotX1)) / 4), tablePlotY1 + (lineDrawOffset * (col + 1)) + 5);
      }
    }
  }  
}

public void drawTableLabels() {
  fill(textColor);
  textSize(8 * scaleFactor);
  
  if(showWorldData) { 
    textAlign(RIGHT);
    text("World",tablePlotX1 + ((5 * (tablePlotX2 - tablePlotX1)) / 6), tablePlotY1);
    textAlign(RIGHT);
    text(currentPlace,tablePlotX1 + ((tablePlotX2 - tablePlotX1) / 2), tablePlotY1);
    textAlign(CENTER);
    text("Year", tablePlotX1 + (tablePlotX2 - tablePlotX1) / 6, tablePlotY1);
  }
  else {
    textAlign(RIGHT);
    text(currentPlace, tablePlotX1 + (3*((tablePlotX2 - tablePlotX1) / 4)) , tablePlotY1);
    textAlign(CENTER);
    text("Year", tablePlotX1 + ((tablePlotX2 - tablePlotX1) / 4), tablePlotY1);
  }
}

public void draw() {
  background(color(#262626));
  omicronManager.process();

  fill(150, 190, 150);

  //geoMap.draw();

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
  
  updateActiveDataBox();
  
  if(!displayCredits && !displayHelp) {
    drawTitle(); 
    if(showGraph) {
      drawAxisLabels();
        if((yearMax - yearMin) != 0) {  
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
        drawYearLabels();
        yearRange.show();
      }
    }
    else {
      if(placeIndex >= 0) {
          currentPlace = countries[placeIndex];
        }
      if(currentPlace != "") {
        int row = rowCorrespondingToPlace(currentPlace);
        unitInterval = data.calculateStandardDeviation(row);
        dataMin = data.getRowMin(row); 
        dataMax = data.getRowMax(row); 
        displayTable(row);
        drawTableLabels();
        yearRange.hide(); 
      }
    }
  }
  else if(displayHelp && !displayCredits) {
    showHelpScreen();
  }
  else if(!displayHelp && displayCredits) {
    showCreditsScreen();
  }
}

public void updateActiveDataBox() {
  for(int i = 0; i < 6; i++) {
    if(dataSelectionBox.getItem(i).getText().equals(data.tableTitle)) {
      dataSelectionBox.getItem(i).setColorBackground(color(#3B76FF));
    }
    else {
      dataSelectionBox.getItem(i).setColorBackground(color(#4C4D46));
    }  
  }
}

//Force full screen 
boolean sketchFullScreen() {
  if(displayOnWall) {
    return false;
  }
  else {
    return true;
  }
}

public void drawTitle() {
  fill(textColor);
  textSize(9 * scaleFactor);
  textAlign(CENTER);
  
  if(showGraph) {
    if(showWorldData) {
      if(data.tableTitle.equals("Total Carbon Dioxide Emissions from Consumption of Energy per Person")) {
        textSize(7*scaleFactor); 
      }
      
      fill(textColor);
      String title = data.tableTitle + ": ";
      text(title, (42*(plotX1+plotX2)/100) , plotY1 - (scaleFactor * 5));
      fill(#EDFC47);
      text(currentPlace, plotX1 + (4*(plotX2 - plotX1)/5), plotY1 - (scaleFactor * 5));
      fill(#1DB5E5);
      text("World", (plotX2 - 10 * scaleFactor), plotY1 - (scaleFactor * 5));
    } 
    else {
      fill(textColor);
      String title = data.tableTitle + ": " + currentPlace;
      text(title, ((plotX1+plotX2)/2) , plotY1 - (scaleFactor * 5));
    }
  }else {
    if(data.tableUnits.equals("Metric Tons of Carbon Dioxide\nper Person")) {
      String title = data.tableTitle + ": Metric Tons of Carbon Dioxide per Person";
      text(title, 9*(tablePlotX1+tablePlotX2)/20, tablePlotY1 - (scaleFactor * 15));
    }
    else if(data.tableUnits.equals("Million Btu\nper person")) {
      String title = data.tableTitle + ": Million Btu per person";
      text(title, (tablePlotX1+tablePlotX2)/2, tablePlotY1 - (scaleFactor * 15));
    }
    else {
      String title = data.tableTitle + ": " + data.tableUnits;
      text(title, (tablePlotX1+tablePlotX2)/2, tablePlotY1 - (scaleFactor * 15));
    }
  }
}

public void drawAxisLabels() {
  fill(textColor);
  textSize(6 * scaleFactor);
 
  textAlign(CENTER, CENTER);
  text(data.tableUnits, plotX1 - 28*scaleFactor, plotY1 - 8 * scaleFactor);
  textAlign(CENTER);
  textSize(8 * scaleFactor);
  text("Year", (plotX1+plotX2)/2, labelY + 15);
}


public void drawYearLabels() {
  fill(textColor);
  textSize(8 * scaleFactor);
  textAlign(CENTER, TOP);
 
  // Use thin, gray lines to draw the grid
  stroke(128);
  strokeWeight(1);
  
  for (int row = startCol; row <= endCol; row++) {
    if (years[row] % yearInterval == 0) {
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row], x, plotY2 + 10);
      line(x, plotY1, x, plotY2 + 5);
    }
  }
}

public void drawUnitLabels() {
  fill(textColor);
  textSize(8 * scaleFactor);
  textAlign(RIGHT);
  
  stroke(128);
  strokeWeight(1);

  float localDataMax = dataMax;
  float localUnitInterval = unitInterval;
  boolean showDecimal = true;
  
  if(showWorldData) {
    localDataMax = max(dataMax, data.getRowMax(231));
    localUnitInterval = max(data.calculateStandardDeviation(231), unitInterval);
  }
  
  float prevVal = 0;
  for (float v = 0; v <= localDataMax; v += localUnitInterval) {  
    float y = map(v, labelDataMin, localDataMax, plotY2, plotY1);  
        if(floor((v - prevVal)) == 0  || v < 1) {
           showDecimal = true; 
        }
        else showDecimal = false;
        
        if (v == labelDataMin) {
          textAlign(RIGHT);                 // Align by the bottom
          text(floor(v), plotX1 - 10, y+4);
  
        } else if (v == localDataMax) {
            textAlign(RIGHT, TOP);            // Align by the top
            if(showDecimal) {
              text(v, plotX1 - 10, y); 
            }
            else {
              text(floor(v), plotX1 - 10, y); 
            }
        } else {
            textAlign(RIGHT, CENTER);            // Align by the top
            if(showDecimal) {
              String dis = nf(v, 1, 5);
              text(dis, plotX1 - 10, y); 
            }
            else {
              text(floor(v), plotX1 - 10, y); 
            }        }
        line(plotX1 - 4, y, plotX2, y);     // Draw major tick
        prevVal = v;
  }
}

public void loadData() {
  totalPrimaryEnergyConsumption = new FloatTable("Total_Primary_Energy_Consumption_(Quadrillion_Btu).csv", "Quadrillion Btu", "Total Primary Energy Consumption"); 
  totalPrimaryEnergyConsumptionPerCapita = new FloatTable("Total_Primary_Energy_Consumption_per_Capita_(Million_Btu_per_Person).csv", "Million Btu\nper person", "Total Primary Energy Consumption Per Capita");
  totalCarbonDioxideConsumption = new FloatTable("Total_Carbon_Dioxide_Emissions_from_the_Consumption_of_Energy_(Million_Metric_Tons).csv", "Million Metric Tons", "Total Carbon Dioxide Emissions");
  totalCarbonDioxideConsumptionPerCapita = new FloatTable("Per_Capita_Carbon_Dioxide_Emissions_from_the_Consumption_of_Energy_(Metric_Tons_of_Carbon_Dioxide_per_Person).csv", "Metric Tons of Carbon Dioxide\nper Person", "Total Carbon Dioxide Emissions Per Capita");
  totalPrimaryEnergyProduction = new FloatTable("Total_Primary_Energy_Production_(Quadrillion_Btu).csv", "Quadrillion Btu", "Total Primary Energy Production");
  totalRenewableElectricityGeneration = new FloatTable("Total_Renewable_Electricity_Net_Generation_(Billion_Kilowatthours).csv", "Billion Kilowatthours", "Total Renewable Electricity Generation");
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
  if(showWorldData) {
    float maxVal = max(data.getRowMax(231), dataMax);
    beginShape();
    for (int col = startCol; col <= endCol; col++) {
      if (data.isValid(row, col)) {
        float value = data.getFloat(row, col);
        float x = map(years[col], yearMin, yearMax, plotX1, plotX2);
        float y = map(value, 0, maxVal, plotY2, plotY1);
        vertex(x,y);
      }
    }
    endShape();
    stroke(#1DB5E5);
    strokeWeight(2);
    beginShape();
    for (int col = startCol; col <= endCol; col++) {
      if (data.isValid(231, col)) {
        float value = data.getFloat(231, col);
        float x = map(years[col], yearMin, yearMax, plotX1, plotX2);
        float y = map(value, 0, maxVal, plotY2, plotY1);
        vertex(x,y);
      }
    }
    endShape();
  }
  else {
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
  for(int i = 0; i < countries.length; i++) {
    if(text.length() == 0) {
        autoCompleteBox.addItem(countries[i], i);      
    }
    else if(text.equals("North America")) {
      if(i >= 0 && i <= 6) {
        autoCompleteBox.addItem(countries[i], i);
      }
    }
    else if(text.equals("Central & South America")) {
      if(i >= 7 && i <= 52) {
        autoCompleteBox.addItem(countries[i], i);
      }
    }
    else if(text.equals("Europe")) {
      if(i >= 53 && i <= 94) {
        autoCompleteBox.addItem(countries[i], i);
      }
    }
    else if(text.equals("Eurasia")) {
      if(i >= 95 && i <= 111) {
        autoCompleteBox.addItem(countries[i], i);
      }
    }
    else if(text.equals("Middle East")) {
      if(i >= 112 && i <= 126) {
        autoCompleteBox.addItem(countries[i], i);
      }      
    }
    else if(text.equals("Africa")) {
      if(i >= 127  && i <= 183) {
        autoCompleteBox.addItem(countries[i], i);
      }
    }
    else if(text.equals("Asia & Oceania")) {
      if(i >= 184 && i <= 230) {
        autoCompleteBox.addItem(countries[i], i);
      }
    }
    else{
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
    .disableCollapse()
    //.setFont(font)
    .setLabel("")
    .setPosition(autoCompleteBoxX, autoCompleteBoxY)
    .setSize(listBoxWidth, listBoxHeight)
    .setItemHeight(listBoxItemHeight)
    .setBarHeight(0)
    .setColorBackground(color(#4C4D46))
    .setColorActive(color(255, 128));
    
    autoCompleteBox.addItems(countries);
    autoCompleteBox.toUpperCase(false);  
}

public void initDataSelectionBox() {
    dataSelectionBox = controlP5.addListBox("dataBox")
    .setLabel("")
    .disableCollapse()
    .setPosition(dataBoxX, dataBoxY)
    .setSize(listBoxWidth, listBoxHeight)
    .setItemHeight(listBoxItemHeight)
    .setBarHeight(0)
    .setColorBackground(color(#4C4D46))
    .setColorActive(color(255, 128));
    
    dataSelectionBox.addItems(dataText);
    dataSelectionBox.toUpperCase(false);
}

public void initYearsSlider() {  
  yearRange = controlP5.addRange("yearsSlider")
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
      .setColorForeground(color(#396591))
      .setColorActive(color(#43F746))
      .setColorBackground(color(#4C4D46)); 
}

public void initTextField() {    
  inputBox = controlP5.addTextfield("input")
      .setPosition(placeTextFieldX,placeTextFieldY)
      .setSize(placeTextFieldWidth,placeTextFieldHeight)
      .setFont(font)
      .setFocus(true)
      .setColorBackground(color(#5E5E5E))
      .setLabel("")
      ;

  inputBox.setText(currentPlace);
}

public void initGraphTableRadioButton() {
  graphTableRadioButton = controlP5.addRadioButton("graphTableRadioButton")
                      .setPosition(graphTableRadioButtonX, graphTableRadioButtonY)
                      .setSize(graphTableRadioButtonWidth, graphTableRadioButtonHeight)
                      .setColorForeground(color(#43F746))
                      .setColorBackground(color(#4C4D46))
                      .setColorActive(color(255))
                      .setColorLabel(color(255))
                      .setItemsPerRow(2)
                      .setSpacingColumn(scaleFactor * 30)
                      .addItem("Graph", 1)
                      .addItem("Table", 2)
                      .setLabel("")
                      ;
   graphTableRadioButton.activate(0);
}

public void creditsButton(int a) {
  if(!displayCredits && !displayHelp) {
    showCreditsScreen();
    creditsButton.setCaptionLabel("Hide Credits");
    displayCredits = true;
  }
  else {
    creditsButton.setCaptionLabel("Show Credits");
    displayCredits = false;
  }
}

public void helpButton(int a) {
 if(!displayCredits && !displayHelp) {
    helpButton.setCaptionLabel("Hide Help");
    displayHelp = true;
  }
  else {
    helpButton.setCaptionLabel("Show Help");
    displayHelp = false;
  }
}

public void showCreditsScreen() {
  float xPos = (plotX1 + plotX2) / 4;
  plotFont = createFont("SansSerif", 10*scaleFactor);
  textFont(plotFont);
  fill(textColor);
  textAlign(LEFT);
  
  text("Credits", xPos , plotY1 + (10 * scaleFactor));
  text("CS 424 Project 1: Electric Avenue", xPos , plotY1 + 20 + (20 * scaleFactor));
  text("Created by Siddharth Sathyam", xPos , plotY1 + 60 + (30 * scaleFactor));
  text("Libraries Used: Controlp5, OMicronLibrary", xPos , plotY1 + 100 + (40 * scaleFactor));
  text("Data from US Energy Information Administration", xPos, plotY1 + 140 + (50 * scaleFactor));
  text("Website: http://www.eia.gov/cfapps/ipdbproject/IEDIndex3.cfm", xPos, plotY1 + 180 + (60 * scaleFactor));
}

public void showHelpScreen() {
  float xPos = (plotX1 + plotX2) / 4;
  plotFont = createFont("SansSerif", 10*scaleFactor);
  textFont(plotFont);
  fill(textColor);
  textAlign(LEFT);
  text("Help", xPos , plotY1 + (10 * scaleFactor));
  text("- Select a country by either typing a country or region in the searchbox on the left", xPos , plotY1 + 20 + (20 * scaleFactor));
  text("  or by selecting a country or region in the dropdown list", xPos , plotY1 + 60 + (30 * scaleFactor));
  text("- Use the second dropdown list on the left side to select ", xPos , plotY1 + 100 + (40 * scaleFactor));
  text("  what data to see for the chosen country or region", xPos , plotY1 + 140 + (50 * scaleFactor));
  text("- The data can be viewed in graphical or tabular form ", xPos, plotY1 + 180 + (60 * scaleFactor));
  text("  by selecting either the graph or table option on the bottom left side ", xPos, plotY1 + 220 + (70 * scaleFactor));
  text("- Data for the world can be compared to the current country or region by", xPos, plotY1 + 260 + (80 * scaleFactor));
  text("  pressing the toggle labeled 'Show World Data'", xPos, plotY1 + 300 + (90 * scaleFactor));
  text("- The slider at the bottom controls the years for which data can be viewed", xPos, plotY1 + 340 + (100 * scaleFactor));
  text("- Adjusting the left handle of the slider changes the start year for the data and", xPos, plotY1 + 380 + (110 * scaleFactor));
  text("  adjusting the right handle of the slider changes the end year for the data", xPos, plotY1 + 420 + (120 * scaleFactor));
}

public void initCreditsButton() {
  creditsButton = controlP5.addButton("creditsButton")
                .setPosition(creditsButtonX, creditsButtonY)                
                .setCaptionLabel("Show Credits")
                .setSize(creditsButtonWidth , creditsButtonHeight)
                ;
}

public void initHelpButton() {
  helpButton = controlP5.addButton("helpButton")
                .setPosition(helpButtonX, helpButtonY)
                .setCaptionLabel("Show Help")
                .setSize(helpButtonWidth, helpButtonHeight)
                ;
}

public void initShowWorldDataToggle() {
  showWorldDataToggle = controlP5.addToggle("showWorldDataToggle")
     .setPosition(showWorldDataToggleX,showWorldDataToggleY)
     .setSize(showWorldDataToggleWidth,showWorldDataToggleHeight)
     .setColorForeground(color(#666666))
     .setColorActive(color(255))
     .setColorLabel(color(255))
     .setValue(false)
     .setMode(ControlP5.SWITCH)
     .setLabel("Show World Data")
     ;
}

void showWorldDataToggle(boolean theFlag) {
  showWorldData = theFlag;
  println("a toggle event.");
}

public void graphTableRadioButton(int a) {
  println(a); 
  if(a == 1) {
     showGraph = true;
   } 
   else if(a == 2){
     showGraph = false;
   }
   else {
     println("0 : "  + graphTableRadioButton.getState(0) + " 1 : " + graphTableRadioButton.getState(1));
     if(graphTableRadioButton.getState(0) && !graphTableRadioButton.getState(1)) {
       graphTableRadioButton.deactivateAll();
       graphTableRadioButton.activate(0);
     }
     else { 
       graphTableRadioButton.deactivateAll();
       graphTableRadioButton.activate(1);
     }
   }
}
  
void touchDown(int ID, float xPos, float yPos, float xWidth, float yWidth){
  println("X: " + xPos + " Y: " + yPos);
  noFill();
  stroke(255,0,0);
  ellipse( xPos, yPos, xWidth * 2, yWidth * 2 );
  controlP5.getPointer().set(floor(xPos), floor(yPos));
  if(displayOnWall) {
    controlP5.getPointer().pressed();
  }
}// touchDown

void touchMove(int ID, float xPos, float yPos, float xWidth, float yWidth){
  //println("touchMove(): Called from Proj class");
  noFill();
  stroke(0,255,0);
  ellipse( xPos, yPos, xWidth * 2, yWidth * 2 );
  controlP5.getPointer().set(floor(xPos), floor(yPos));
}// touchMove

void touchUp(int ID, float xPos, float yPos, float xWidth, float yWidth){
  //println("touchUp(): Called from Proj class");
  noFill();
  stroke(0,0,255);
  ellipse( xPos, yPos, xWidth * 2, yWidth * 2 );
  controlP5.getPointer().set(floor(xPos), floor(yPos));  
  if(displayOnWall) {
    controlP5.getPointer().released();
  }
}// touchUp

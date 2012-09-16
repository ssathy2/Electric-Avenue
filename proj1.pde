//////////////////////////////////////////////////////////////////////////
import controlP5.*;
////////////////////////////////////////////////////////////////////////// 
import omicronAPI.*;
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

void setup() {
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
  years = int(data.getColumnNames()); 
  
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

void displayGraph(int row) {
   // Show the plot area as a white box 
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);

  stroke(#5679C1);
  strokeWeight(2);
  drawDataLine(row); 
}

void displayTable(int row) {
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);

  stroke(#5679C1);
  strokeWeight(2);
  drawTable(row);
}

void drawTable(int row) {
  
  
}

void draw() {
  background(224);
 
  drawTitle();
  drawAxisLabels();
  drawYearLabels();
  
  stroke(#5679C1);
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


void drawTitle() {
  fill(0);
  textSize(20);
  textAlign(LEFT);
  String title = data.tableTitle + ": " + currentPlace;
  text(title, plotX1, plotY1 - 10);
}


void drawAxisLabels() {
  fill(0);
  textSize(13);
  textLeading(15);
 
  textAlign(CENTER, CENTER);
  text(data.tableUnits, labelX, (plotY1+plotY2)/2);
  textAlign(CENTER);
  text("Year", (plotX1+plotX2)/2, labelY);
}


void drawYearLabels() {
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

void drawUnitLabels() {
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

void loadData() {
  totalPrimaryEnergyConsumption = new FloatTable("Total_Primary_Energy_Consumption_(Quadrillion_Btu).csv", "Quadrillion Btu", "Total Primary Energy Consumption"); 
  totalPrimaryEnergyConsumptionPerCapita = new FloatTable("Total_Primary_Energy_Consumption_per_Capita_(Million_Btu_per_Person).csv", "Million Btu\nper person", "Total Primary Energy Consumption per Person");
  totalCarbonDioxideConsumption = new FloatTable("Total_Carbon_Dioxide_Emissions_from_the_Consumption_of_Energy_(Million_Metric_Tons).csv", "Million\nMetric Tons", "Total Carbon Dioxide Emissions from Consumption of Energy");
  totalCarbonDioxideConsumptionPerCapita = new FloatTable("Per_Capita_Carbon_Dioxide_Emissions_from_the_Consumption_of_Energy_(Metric_Tons_of_Carbon_Dioxide_per_Person).csv", "Metric Tons of\nCarbon Dioxide\nper Person", "Total Carbon Dioxide Emissions from Consumption of Energy per Person");
  totalPrimaryEnergyProduction = new FloatTable("Total_Primary_Energy_Production_(Quadrillion_Btu).csv", "Quadrillion Btu", "Total Primary Energy Production");
  totalRenewableElectricityGeneration = new FloatTable("Total_Renewable_Electricity_Net_Generation_(Billion_Kilowatthours).csv", "BillionKilowatthours", "Total Renewable Electricity Net Generation");
}

// Draw the data as a series of points 
void drawDataPoints(int row) {
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
void drawDataLine(int row) {
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
int rowCorrespondingToPlace(String place) {
  String[] places = data.getRowNames();
  for(int i = 0; i <  places.length; i++) {
    if(places[i].equals(place)) {
       return i;
    }
  }
  return -1;
}

void keyPressed() {
  text = controlP5.get(Textfield.class, "input").getText();
  autoCompleteBox.clear();
  for(int i = 0; i < countries.length; i++) {
    if(countries[i].toLowerCase().startsWith(text.toLowerCase())) {
            autoCompleteBox.addItem(countries[i], i);
    }
  }   
}

void controlEvent(ControlEvent theEvent) {
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
  
 
void initAutoCompleteBox() {
  autoCompleteBox = controlP5.addListBox("myList")
    .setPosition(20, 160)
    .setSize(200, 200)
    .setItemHeight(15)
    .setBarHeight(15)
    .setColorBackground(color(40, 128))
    .setColorActive(color(255, 128));
    
    autoCompleteBox.addItems(countries);
}

void initDataSelectionBox() {
    dataSelectionBox = controlP5.addListBox("dataBox")
    .setPosition(width - 250, 20)
    .setSize(225, 225)
    .setItemHeight(20)
    .setColorBackground(color(40, 128))
    .setColorActive(color(255, 128));
  
    dataSelectionBox.addItems(dataText);
}

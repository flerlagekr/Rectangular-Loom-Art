/*
  Processing sketch for "Automate the art"
  Based on the 2016 Hackaday prize entry by shlonkin. 
  Modified in January, 2017 by flerlagekr to use a rectangular shape and to write to csv.
  
  When running the sketch:
   1. Place an image (must be in jpeg format) in the same folder as this code file.
   2. If you are using a Mac, you will need to add the mage to the "sketch". 
      To do this, click the Sketch menu, choose Add File, then select the image.
   3. Set the image name in the setup() procedure.
   4. Set the output path in the draw() routine (line 175 of the code). The format I use here is for a PC.
   5. Run the code.
   6. The image should be loaded. Select a rectangular region.
   7. Click the "set rect" button.
   8. Click the "compute" button and wait a few seconds while paths are generated.
   9. The output window will indicate when the output csv is finished being written.
      The csv will placed in the folder you configured in step 3.
      Note: If you run this process multiple times, it will continuously append to the same file. 
      Thus, it is best to delete the file after each run to prevent this from happenning. 
  10. Clicking the "display" button will change the display. First click will place the original
      Image behind the loom. Second click will display a negative image of the loom. Neither will produce csv output.
  
  NOTE: 
    Resizing and/or cropping your image to a square of width and height of 500 to 800 pixels works well.
    
    Adjusting some parameters requires recalculation, so it may take 
    a while to update the display.
  
  This code is in the public domain
*/

// These parameters can only be set here
int pinCount = 250;
int stepCount = 5000;

// These can be set while running the sketch
int fade = 30;
int opacity = 40;
int ignoreDist = 20;

String fileName;
String outFile;
String artName;
boolean fileSelectedRun;

PImage pic, pic2;
short[] steps = new short[stepCount];
int[][] pinsXY = new int[pinCount][2];

int[][][] paths; // this can get big. You may need to increase allowed memory size
int[][] pathLengths;

int circleX, circleY, circleRadius;
int rectX1, rectX2, rectY1, rectY2, rectWidth, rectHeight, mainX1, mainY1, mainX2, mainY2, rectWidthImg, rectHeightImg;
char circleCentered, circleSet, circlePinned, pinsShifted, stepsDone, withPic, pathsDone;

float picScale, picScale2;
int picX, picY;
int filecounter;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;

public class writer {
    public void writing(String outputFile, String textToWrite) {
        try {
            //Whatever the file path is.
            File statText = new File(outputFile);
            FileOutputStream is = new FileOutputStream(statText, true);
            OutputStreamWriter osw = new OutputStreamWriter(is);    
            Writer w = new BufferedWriter(osw);
            w.write(textToWrite);
            w.write("\r\n");
            w.close();
        } catch (IOException e) {
            System.err.println("Problem writing to the file.");
        }
    }
}

void setup(){
  size(800, 700);
  picX = 80;
  picY = 60;
  filecounter=0;
  
  // select the image file
  fileName = null;
  artName = "Afghan";
  fileName = artName + ".jpg";
  outFile = artName + ".csv";

  while(fileName == null){
    fileSelectedRun = false;
    selectInput("Select an image file", "fileSelected", new File(sketchPath("select an image file")));
    while(!fileSelectedRun);
  }
  
  // load the picture
  pic = loadImage(fileName);
  if(pic.width > pic.height){
    picScale = (width-picX)*1.0/pic.width;
    image(pic, picX, picY, width-picX, pic.height*picScale);
  }else{
    picScale = (height-picY)*1.0/pic.height;
    image(pic, picX, picY, pic.width*picScale, height-picY);
  }
  pic.filter(GRAY);
  
  circleCentered = 0;
  circleSet = 0;
  circlePinned = 0;
  pinsShifted = 0;
  stepsDone = 0;
  withPic = 0;
  pathsDone = 0;
  ellipseMode(RADIUS);
}

void draw(){
  background(255);
  String outputFileName;
  
  //These are the various contols ////////////////////////////////
  fill(150);
  stroke(0);
  // reset button
  rect(0,picY,picX,30);
  
  // set circle button
  // this button computes the pin points and converts the circle to gray
  rect(0, picY+30, picX, 30);
  
  // this button computes the steps
  rect(0, picY+60, picX, 30);
  
  // this button displays the picture in the background
  rect(0, picY+90, picX, 30);
  
  // this is the transparency of the lines
  rect(100 + opacity*(width-100-20)/255, 0, 20, 20);
  
  // this is the amount paths fade the image
  rect(100 + fade*(width-100-20)/255, 20, 20, 20);
  line(0, 20, width, 20);
  
  // this is the ignore distance
  rect(100 + ignoreDist*(width-100-20)/(pinCount/2), 40, 20, 20);
  line(0, 40, width, 40);
  line(100, 0, 100, picY);
  
  // labels
  fill(0);
  textSize(12);
  text("reset", 5, picY+20);
  text("set rect", 5, picY+50);
  text("compute", 5, picY+80);
  text("display", 5, picY+110);
  text("display", 5, picY+110);
  text("darkness", 5, 18);
  text(opacity, 70, 18);
  text("fade ", 5, 38);
  text(fade, 70, 38);
  text("min dist.", 5, 58);
  text(ignoreDist, 70, 58);
  
  if(stepsDone > 0){
    stroke(0, opacity);
    strokeWeight(1);
    
    outputFileName = "C:/Users/Flerlage/Cloud Drive/Documents/Ken/Blog/Loom/CircleStringPicture/Output/" + outFile;
    writer write = new writer();

    filecounter = filecounter + 1;

    if (filecounter==1){
      System.out.println("Writing file...");
      write.writing(outputFileName, "Art, Path, Path Order, Point, X, Y");
    }
    
    if(withPic == 1){
      //HERE!!!!!!!!!!!!!!!!!!!!
      image(pic2, picX, picY, height-picY, height-picY);
      for(int i=1; i<stepCount; i++){
        line(picX + pinsXY[steps[i-1]][0]*picScale2, picY + pinsXY[steps[i-1]][1]*picScale2, picX + pinsXY[steps[i]][0]*picScale2, picY + pinsXY[steps[i]][1]*picScale2);
        if(filecounter==1){
          write.writing(outputFileName, artName + ", Path " + (i-1) + "-" + i + ", 1, " + (i-1) + ", " + (picX + pinsXY[steps[i-1]][0]*picScale2) + ", " +  (picY + pinsXY[steps[i-1]][1]*picScale2));
          write.writing(outputFileName, artName + ", Path " + (i-1) + "-" + i + ", 2, " + (i) + ", " +   (picX + pinsXY[steps[i]][0]*picScale2) +   ", " +  (picY + pinsXY[steps[i]][1]*picScale2));
        }
      }
    }else if(withPic == 0){
      fill(255);
      rect(picX, picY, height-picY, height-picY);
      for(int i=1; i<stepCount; i++){
        line(picX + pinsXY[steps[i-1]][0]*picScale2, picY + pinsXY[steps[i-1]][1]*picScale2, picX + pinsXY[steps[i]][0]*picScale2, picY + pinsXY[steps[i]][1]*picScale2);
        if(filecounter==1){
          write.writing(outputFileName, artName + ", Path " + (i-1) + "-" + i + ", 1, " + (i-1) + ", " + (picX + pinsXY[steps[i-1]][0]*picScale2) + ", " +  (picY + pinsXY[steps[i-1]][1]*picScale2));
          write.writing(outputFileName, artName + ", Path " + (i-1) + "-" + i + ", 2, " + (i) + ", " +   (picX + pinsXY[steps[i]][0]*picScale2) +   ", " +  (picY + pinsXY[steps[i]][1]*picScale2));
        }
      }
    }else{
      image(pic2, picX, picY, height-picY, height-picY);
    }

    //writer.close();
    if (filecounter==1){
      System.out.println("Closing file...");
    }
    
    for(int i=0; i<pinCount; i++){
      rect(picX + pinsXY[i][0]*picScale2, picY + pinsXY[i][1]*picScale2, 1, 1);
    }
    
  }else if(circlePinned > 0){
    if(pic.width > pic.height){
      image(pic, picX, picY, width-picX, pic.height*picScale);
    }else{
      image(pic, picX, picY, pic.width*picScale, height-picY);
    }
    // draw the pin locations
    // note that pins are in pic pixels not display pixels
    stroke(0);
    strokeWeight(1);
    for(int i=0; i<pinCount; i++){
      rect(picX + pinsXY[i][0]*picScale, picY + pinsXY[i][1]*picScale, 1, 1);
    }
  }else if(circleCentered > 0){
    if(pic.width > pic.height){
      image(pic, picX, picY, width-picX, pic.height*picScale);
    }else{
      image(pic, picX, picY, pic.width*picScale, height-picY);
    }
    stroke(0);
    noFill();
    strokeWeight(2);
    //ellipse(circleX*picScale + picX, circleY*picScale + picY, circleRadius*picScale, circleRadius*picScale);
    
    mainX1 = rectX2;
    mainY1 = rectY2;
    
    if (rectX1 < rectX2){
      mainX1 = rectX1;  
      mainX2 = rectX2;
    }
    else{
      mainX1 = rectX2;  
      mainX2 = rectX1;
    }
    if (rectY1 < rectY2){
      mainY1 = rectY1;  
      mainY2 = rectY2;
    }
    else{
      mainY1 = rectY2;  
      mainY2 = rectY1;
    }
    
    rectWidth = mainX2 - mainX1;
    rectHeight = mainY2 - mainY1;

    rectWidthImg = abs(int(rectX1*picScale + picX) - int(rectX2*picScale + picX));
    rectHeightImg = abs(int(rectY1*picScale + picY) - int(rectY2*picScale + picY));
    
    rect(mainX1*picScale + picX, mainY1*picScale + picY, rectWidthImg, rectHeightImg);
    
  }else{
    if(pic.width > pic.height){
      image(pic, picX, picY, width-picX, pic.height*picScale);
    }else{
      image(pic, picX, picY, pic.width*picScale, height-picY);
    }
  }
}

void fileSelected(File f){
  if(f != null){
    fileName = f.getName();
  }
  fileSelectedRun = true;
}

void mousePressed(){
  // first handle buttons
  if(mouseX < picX){
    if(mouseY < picY + 30){
      circleCentered = 0;
      circleSet = 0;
      circlePinned = 0;
      pinsShifted = 0;
      stepsDone = 0;
      withPic = 0;
      pathsDone = 0;
      pic = loadImage(fileName);
      if(pic.width > pic.height){
        image(pic, picX, picY, width-picX, pic.height*picScale);
      }else{
        image(pic, picX, picY, pic.width*picScale, height-picY);
      }
      pic.filter(GRAY);
      return;
    }else if(mouseY < picY + 60){
      if(circlePinned < 1){
        pinCircle();
        circlePinned = 1;
      }
    }else if(mouseY < picY + 90){
      if(stepsDone < 1){
        computeSteps();
        stepsDone = 1;
      }
    }else if(mouseY < picY + 120){
      withPic++;
      if(withPic > 2){
        withPic = 0;
      }
    }
  }else if(mouseX < 100){
    // this is the label area
  }else if(mouseY < 20){
    opacity = (mouseX-100)*255/(width-100-20);
  }else if(mouseY < 40){
    fade = (mouseX-100)*255/(width-100-20);
    // have to recompute
    if(stepsDone > 0){
      computeSteps();
    }
    
  }else if(mouseY < picY){
    ignoreDist = (mouseX-100)*(pinCount/2)/(width-100-20);
    // have to recompute
    if(stepsDone > 0){
      computeSteps();
    }
    
  }else if(circleCentered < 1){
    // set the circle center
    circleX = round((mouseX - picX)*1.0/picScale);
    circleY = round((mouseY - picY)*1.0/picScale);
    rectX1 = round((mouseX - picX)*1.0/picScale);
    rectY1 = round((mouseY - picY)*1.0/picScale);
    circleCentered = 1;
  }
  
}

void mouseDragged(){
  if(circleCentered < 1){
    return;
  }
  if(circleSet < 1){
    circleRadius = max(abs(round((mouseX-picX)*1.0/picScale) - circleX), abs(round((mouseY-picY)*1.0/picScale) - circleY));
    rectX2 = round((mouseX - picX)*1.0/picScale);
    rectY2 = round((mouseY - picY)*1.0/picScale);    
  }
  
}

void mouseReleased(){
  if(circleCentered < 1){
    return;
  }
  if(circleSet < 1){
    circleRadius = max(abs(round((mouseX-picX)*1.0/picScale) - circleX), abs(round((mouseY-picY)*1.0/picScale) - circleY));
    rectX2 = round((mouseX - picX)*1.0/picScale);
    rectY2 = round((mouseY - picY)*1.0/picScale);
    circleSet = 1;
  }
}

void pinCircle(){
  color white = color(255);
  for(int i=0; i<pic.width; i++){
    for(int j=0; j<pic.height; j++){
      //if((((circleX-i)*(circleX-i)) + ((circleY-j)*(circleY-j))) > circleRadius*circleRadius){
      if (i < mainX1 || i> mainX2 || j < mainY1 || j> mainY2) {
        pic.set(i, j, white);
      }
    }
  }
  updatePixels();
  
  // compute the pin locations
  // start at the top left and move clockwise.
  //float angle = PI*2.0/pinCount;
  float perimeter = 2*rectWidth + 2*rectHeight; 
  float spacing = perimeter/pinCount;
  int newX=0;
  int newY=0;
  int currentSide = 1;
  int lasti=0;
  int diff=0;

  for(int i=0; i<pinCount; i++){
    
    if (currentSide == 1){
      newX = round(mainX1 + (spacing * i));
      newY = mainY1;
      if (newX > mainX2){
        // We've gone past the right side of the rectangle. Need to start going down (up in terms of coords).
        currentSide = 2;
        lasti = i;
        diff = newX-mainX2;
      }
    }
    
    if (currentSide == 2){
      newX = mainX2;
      newY = round(mainY1 + (spacing * (i-lasti)) + diff);
      if (newY > mainY2){
        // We've gone past the bottom side of the rectangle. Need to start going left..
        currentSide = 3;
        lasti = i;
        diff = newY-mainY2;
      }
    }
    
    if (currentSide == 3){
      newX = round(mainX2 - (spacing * (i-lasti)) - diff);
      newY = mainY2;
      if (newX < mainX1){
        // We've gone past the left side of the rectangle. Need to start going up (down in terms of coords).
        currentSide = 4;
        lasti = i;
        diff = mainX1-newX;
      }
    }

    if (currentSide == 4){
      newX = mainX1;
      newY = round(mainY2 - (spacing * (i-lasti)) - diff);
      }

    pinsXY[i][0] = newX;
    pinsXY[i][1] = newY;
  }
}

void computeSteps(){
  // work with a copy of the pic
  pic2 = createImage(rectWidth+2, rectHeight+2, RGB);
  pic2.copy(pic, round(mainX1), round(mainY1), round(rectWidth)+2, round(rectHeight)+2, 0, 0, round(rectWidth)+2, round(rectHeight)+2);  
  pic2.filter(INVERT);
  pic2.loadPixels();
  //picScale2 = (height-picY)*1.0/(circleRadius*2+2);
  
  if(pic2.width > pic2.height){
    picScale2 = (width-picX)*1.0/pic2.width;
  }else{
    picScale2 = (height-picY)*1.0/pic2.height;
  }

  //System.out.println("width = " + str(pic2.width));
  //System.out.println("height = " + str(pic2.height));
  //System.out.println("pixels = " + str(pic2.pixels.length));  
  
  long[] sum = new long[pinCount];
  
  // shift all the pin locations
  if(pinsShifted < 1){
    for(int i=0; i<pinCount; i++){
      //pinsXY[i][0] -= circleX - circleRadius;
      //pinsXY[i][1] -= circleY - circleRadius;
      pinsXY[i][0] -= mainX1;
      pinsXY[i][1] -= mainY1;
    }
    pinsShifted = 1;
  }
  
  // compute paths if not done
  if(pathsDone < 1){
    getPaths();
    pathsDone = 1;
  }
  
  // now perform the steps
  // compute average "darkness" along each possible path and choose the darkest
  // then lighten the chosen path a little
  // start at pin 0
  steps[0] = 0;
  for(int i=1; i<stepCount; i++){
    // sum all the gray values over the line to each other pin
    for(int j=0; j<pinCount-1; j++){
      //System.out.println("i=" + str(i) + "; j=" + str(j) + "; length=" + str(pathLengths[j].length));
      sum[j] = 0;
      int d = 0;
      if(steps[i-1] > j){
        for(int k=0; k<pathLengths[j][steps[i-1]-j-1]; k++){
          //System.out.println("1:   " + str(paths[j][steps[i-1]-j-1][k]));
          sum[j] += pic2.pixels[paths[j][steps[i-1]-j-1][k]] & 0xFF;
          d++;
        }
      }
      else if(steps[i-1] < j){
        //System.out.println("2:   " + str(steps[i-1]) + "; " + str(j-steps[i-1]-1));
        for(int k=0; k<pathLengths[steps[i-1]][j-steps[i-1]-1]; k++){
          //System.out.println("2:   " + str(paths[steps[i-1]][j-steps[i-1]-1][k]));
          sum[j] += pic2.pixels[paths[steps[i-1]][j-steps[i-1]-1][k]] & 0xFF;
          d++;
        }
      }
      sum[j] = round(sum[j]*1.0/d);
      // one sum done
    }
    
    // find the pin with max sum
    long maxSum = 0;
    short maxIndex = 100;
    boolean ignore = false;
    for(short j=0; j<pinCount; j++){
      if (j==199){
        j+=1;
        j-=1;
      }
      // ignore pins within some distance
      ignore = false;
      if(j < steps[i-1]){
        if(steps[i-1]-j < ignoreDist){
          ignore = true;
        }
      }else{
        if(j-steps[i-1] < ignoreDist){
          ignore = true;
        }
      }
      if((steps[i-1] < ignoreDist) && (j > pinCount-ignoreDist + steps[i-1])){
        ignore = true;
      }else if((steps[i-1] > pinCount-ignoreDist) && (j < ignoreDist - (pinCount-steps[i-1]))){
        ignore = true;
      }
      
      if((j != steps[i-1]) && (!ignore)){
        if(sum[j] > maxSum){
          maxSum = sum[j];
          maxIndex = j;
        }
      }
    }
    steps[i] = maxIndex;
    
    // now go back and lighten that line
    if(steps[i-1] > steps[i]){
      for(int k=0; k<pathLengths[steps[i]][steps[i-1]-steps[i]-1]; k++){
        pic2.pixels[paths[steps[i]][steps[i-1]-steps[i]-1][k]] = lighten(pic2.pixels[paths[steps[i]][steps[i-1]-steps[i]-1][k]]);
      }
    }else if(steps[i-1] < steps[i]){
      for(int k=0; k<pathLengths[steps[i-1]][steps[i]-steps[i-1]-1]; k++){
        pic2.pixels[paths[steps[i-1]][steps[i]-steps[i-1]-1][k]] = lighten(pic2.pixels[paths[steps[i-1]][steps[i]-steps[i-1]-1][k]]);
      }
    }
    // step done
  }
  // all done
  
  pic2.filter(INVERT);
  pic2.updatePixels();
}

void getPaths(){
  // build all the paths between pins
  paths = new int[pinCount][][];
  pathLengths = new int[pinCount][];
  // don't store redundant paths
  // the one with smaller index is first
  float slope = 0;
  int distance = 0;
  int dest = 0;
  int pathind = 0;
  for(int i=0; i<pinCount-1; i++){
    paths[i] = new int[pinCount-i-1][];
    pathLengths[i] = new int[pinCount-i-1];
    for(int j=i+1; j<pinCount; j++){
      dest = j-i-1;
      // find the distance between points
      if(pinsXY[i][0] == pinsXY[j][0]){
        // this means the line is vertical
        distance = abs(pinsXY[i][1] - pinsXY[j][1]);
      }else if(abs(pinsXY[i][0] - pinsXY[j][0]) > abs(pinsXY[i][1] - pinsXY[j][1])){
        distance = abs(pinsXY[i][0] - pinsXY[j][0]);
      }else{
        distance = abs(pinsXY[i][1] - pinsXY[j][1]);
      }
      paths[i][dest] = new int[distance];
      pathLengths[i][dest] = distance;
      
      // find the slope and fill the path data
      // vertical is handled separately
      pathind = 0;
      if(pinsXY[i][0] == pinsXY[j][0]){
        // vertical
        if(pinsXY[i][1] > pinsXY[j][1]){
          for(int k=pinsXY[i][1]; k>pinsXY[j][1]; k--){
            paths[i][dest][pathind] = pinsXY[i][0] + k*pic2.width;
            pathind++;
          }
        }else{
          for(int k=pinsXY[i][1]; k<pinsXY[j][1]; k++){
            paths[i][dest][pathind] = pinsXY[i][0] + k*pic2.width;
            pathind++;
          }
        }
        // vertical done
      }else{
        slope = (pinsXY[j][1] - pinsXY[i][1])*1.0 / (pinsXY[j][0] - pinsXY[i][0]);
        // if the slope is steep, iterate along Y, if not, X
        if(abs(slope) > 1){
          if(pinsXY[i][1] > pinsXY[j][1]){
            for(int k=pinsXY[i][1]; k>pinsXY[j][1]; k--){
              // going (-,-) slope is + or going (+,-) slope is -
              paths[i][dest][pathind] = pinsXY[i][0] - round(pathind*1.0/slope) + k*pic2.width;
              pathind++;
            }
          }else{
            for(int k=pinsXY[i][1]; k<pinsXY[j][1]; k++){
              // going (-,+) slope is - or going (+,+) slope is +
              paths[i][dest][pathind] = pinsXY[i][0] + round(pathind*1.0/slope) + k*pic2.width;
              pathind++;
            }
          }
        }else{
          // here the slope is shallow
          if(pinsXY[i][0] > pinsXY[j][0]){
            for(int k=pinsXY[i][0]; k>pinsXY[j][0]; k--){
              // going (-,-) slope is + or going (+,-) slope is -
              paths[i][dest][pathind] = k + (pinsXY[i][1] - round(slope*pathind))*pic2.width;
              pathind++;
            }
          }else{
            for(int k=pinsXY[i][0]; k<pinsXY[j][0]; k++){
              // going (-,+) slope is - or going (+,+) slope is +
              paths[i][dest][pathind] = k + (pinsXY[i][1] + round(slope*pathind))*pic2.width;
              pathind++;
            }
          }
        }
      }
      // one path done
    }
    // one pin's paths done
  }
  // all paths done
}
 //<>//
color lighten(color c){
  int b = c & 0xFF;
  if(b < fade){
    b = 0;
  }else{
    b -= fade;
  }
  return color(b);
}
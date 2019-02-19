
/**
 * ImageMapVisualController 
 * by Mike Cj. 
 * TIMEBLUR 2019  
 * ----------
 * Description:
 * This sketch is a visual controller to play an animation in a selected sequence, and the sequence 
 * can also be reconfigured with the interface provided in this software, which is further extended
 * to receive triggers from an extenal hardware.
 * ----------
 * LICENSE: 
 *   Copyright (c) 2019 TIMEBLUR
 *   Permission is hereby granted, free of charge, to any person obtaining a copy of this software
 *   and associated documentation files (the "Software"), to deal in the Software without restriction,
 *   including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *   and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
 *   subject to the following conditions:
 *   
 *   
 *   The above copyright notice and this permission notice shall be included in all copies
 *   or substantial portions of the Software.
 *  
 *   The above exclusively applies to files containing this copyright notice, and does not  
 *   apply for the rest of the software package containing these files.
 *  
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 *   INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
 *   PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 *   FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF  CONTRACT, TORT OR 
 *   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH  THE SOFTWARE OR  THE USE OR OTHER 
 *   DEALINGS IN THE SOFTWARE. 
 */

import processing.serial.*;
import processing.video.*;
import controlP5.*;
import spout.*;
import codeanticode.syphon.*;
//
//
String stencilFileName = "Journey102-A4720.png";
String maskFileName = "journeyMask.001.jpeg";
String maskVideoFileName = "Journey102-A4720.m4v";
//
PGraphics pg;
Spout server_spout = null;
SyphonServer server_syphon = null;
//
Movie loadMovie;
String fileName;
boolean clipPressed = false;
boolean clipPressedAgain = false;
float time_scale = 1000;
boolean playFlag = false;
boolean updateFrame = false;
//
//
Serial triggerInPort;
//
String csvFilename;
int start_clip = 0, end_clip = 0;
boolean active_start = false, active_end = false;
int clipCount = 0;
int displayMode = -1;
int activeServer = -1;
boolean selectActive = false;
int currentlySelected = -1;
IntList startClipValues = new IntList(), endClipValues = new IntList();
boolean editActive = false;
int currentlyEditing = -1;
ArrayList<Textlabel> startLabel = new ArrayList<Textlabel>();
ArrayList<Textlabel> endLabel = new ArrayList<Textlabel>(); 
ControlP5 cp5;
Textlabel clipLabel, startValueLabel, endValueLabel, clipModeLabel, triggerInLabel;
Group allClips;
//
Range clipRange;
Toggle clipToggle;
Bang addBang, saveCSVBang;
//
RadioButton selectClip;
RadioButton playModes;
RadioButton serverModes;
Bang playpauseBang;
ArrayList<Toggle>  cliploopMode = new ArrayList<Toggle>();
ArrayList<Textfield>  triggerIn = new ArrayList<Textfield>();
//
int allClips_posX = 8, allClips_posY = 44;
int clipLabel_posX = 0, clipLabel_posY = 6;
int startValueLabel_posX = 65, startValueLabel_posY = 6;
int endValueLabel_posX = 100, endValueLabel_posY = 6;
int clipModeLabel_posX = 140, clipModeLabel_posY = 6;
int triggerInLabel_posX = 170, triggerInLabel_posY = 6;
//
int selectClip_posX = 10, selectClip_posY = 18;
int playModes_posX = 65, playModes_posY = 7;
int serverModes_posX = 65, serverModes_posY = 20;
int playpauseBang_posX = 205, playpauseBang_posY = 4;
int cliploopMode_posX = 150, cliploopMode_posY = 18;
int triggerIn_posX = 180, triggerIn_posY = 18;
//
PImage loadStencil, loadMask;
//
//
void setup(){
  setupSerial("/dev/cu.usbserial-A9CVR15H");
  //
  setupgui();
  loadStencil = loadImage(stencilFileName);
  loadMask = loadImage(maskFileName);
  loadMovieFile(maskVideoFileName);
  //
  //
  size(842, 595, P3D);
  pg = createGraphics(width, height, P3D);
  //
  smooth();
  frameRate(30);
  //
  //
  imageMode(CORNERS);
  //
  //
}

void setupSerial(String portName){
  try{
    triggerInPort = new Serial(this, portName, 9600);
  }catch(Exception e){
    println("Exception while attempting to open port!");
    //e.printStackTrace();
    exit();
  }  
}

void setupgui(){
  //
  cp5 = new ControlP5(this);
  //
  //
  addBang = new Bang(cp5, "add");
  addBang.setPosition(width - 60 - 60,5);
  addBang.setSize(50,15);
  addBang.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  addBang.hide();
  //
  clipToggle = new Toggle(cp5, "clip");
  clipToggle.setPosition(width - 60 ,5);
  clipToggle.setSize(50,15);
  clipToggle.hide();
  clipToggle.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  //
  clipRange = cp5.addRange("clipRange")
             .setBroadcast(false) 
             .setPosition(0, height - 24)
             .setSize(width,8)
             .setHandleSize(5)
             .setColorActive(color(232, 22, 12)) 
             .setColorForeground(color(231, 76, 60))
             .setColorBackground(color(52, 152, 219)) 
             .setDecimalPrecision(0)
             .hide() 
             ;
  //
  allClips = cp5.addGroup("allClips")
                .setPosition(allClips_posX,allClips_posY)
                .setWidth(240)
                .activateEvent(true)
                .setBackgroundColor(color(0,150))
                .setBackgroundHeight(22)
                .setLabel("Clips")
                .hide()
                ;        
   cp5.addBang("saveCSV")
     .setPosition(10, 5)
     .setSize(45,13)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;
  //
  selectClip = cp5.addRadioButton("selectClip")
                 .setPosition(selectClip_posX,selectClip_posY)
                 .setSize(10, 10)
                 .setItemsPerRow(1)
                 .setSpacingColumn(30)
                 .setSpacingRow(2)
                 .setGroup(allClips)
                 ;
  playpauseBang = new Bang(cp5, "playpause");
  playpauseBang.setPosition(playpauseBang_posX, playpauseBang_posY);
  playpauseBang.setSize(40,15);
  playpauseBang.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  playpauseBang.setLabel("Pause");
  playpauseBang.hide();
  //  
  displayMode = 0;
  playModes = cp5.addRadioButton("playModes")
                 .setPosition(playModes_posX,playModes_posY)
                 .setSize(10, 10)
                 .setItemsPerRow(4)
                 .setSpacingColumn(35)
                 .setSpacingRow(2)
                 .addItem("Stencil", 0)
                 .addItem("Mask", 1)
                 .addItem("Video", 2)
                 .activate(2)
                 .hide()
                 ;
  //
  serverModes = cp5.addRadioButton("serverModes")
                 .setPosition(serverModes_posX,serverModes_posY)
                 .setSize(10, 10)
                 .setItemsPerRow(4)
                 .setSpacingColumn(35)
                 .setSpacingRow(2)
                 .addItem("None", 0)
                 .addItem("Syphon", 1)
                 .addItem("Spout", 2)
                 .activate(0)
                 .hide()
                 ;
  //
  clipLabel = cp5.addTextlabel("clipLabel")
                    .setText("SELECT CLIP")
                    .setPosition(clipLabel_posX,clipLabel_posY)
                    .setColorValue(color(255))
                    .setGroup(allClips)
                    ;   
  startValueLabel = cp5.addTextlabel("startValueLabel")
                    .setText("START")
                    .setPosition(startValueLabel_posX,startValueLabel_posY)
                    .setColorValue(color(255))
                    .setGroup(allClips)
                    ;
  endValueLabel = cp5.addTextlabel("endValueLabel")
                    .setText("END")
                    .setPosition(endValueLabel_posX,endValueLabel_posY)
                    .setColorValue(color(255))
                    .setGroup(allClips)
                    ;
  clipModeLabel = cp5.addTextlabel("clipModeLabel")
                    .setText("LOOP")
                    .setPosition(clipModeLabel_posX,clipModeLabel_posY)
                    .setColorValue(color(255))
                    .setGroup(allClips)
                    ;  
  triggerInLabel = cp5.addTextlabel("triggerInLabel")
                    .setText("I/P TRIGGER")
                    .setPosition(triggerInLabel_posX,triggerInLabel_posY)
                    .setColorValue(color(255))
                    .setGroup(allClips)
                    ;  
}


void playpause(){
  if(playpauseBang.getLabel().equals("Pause")){
    playFlag = false;
    playpauseBang.setLabel("Play");
    loadMovie.pause();
  }else if(playpauseBang.getLabel().equals("Play")){
    playFlag = true;
    playpauseBang.setLabel("Pause");
     loadMovie.play();
  }  
}

void loadMovieFile(String fileName){
  println(fileName);
  //
  loadMovie = new Movie(this, fileName);
  loadMovie.loop();
  playFlag = true;
  //
  csvFilename = "data/" + fileName;
  csvFilename = csvFilename.substring(0, csvFilename.length() - 4) + ".csv";
  //
  boolean entriesPresent = loadCSV();
  clipToggle.show();
  playModes.show();
  serverModes.show();
  cp5.show();
  if(entriesPresent)  allClips.show();
  else                allClips.hide();
}

boolean loadCSV(){
  File csvFile = new File(dataPath("")+"/"+csvFilename.substring(5, csvFilename.length())); 
  println(dataPath("")+"/"+csvFilename.substring(5, csvFilename.length()));
  println("File exists: " + csvFile.exists());
  if (csvFile.exists()){
    Table table = null;
    table = loadTable(csvFilename, "header");
    //
    if(table.getRowCount() <= 0)  
      return false;
    for (TableRow row : table.rows()) {
      clipCount = row.getInt("clip");
      selectClip.addItem("Clip"+nf(clipCount,2), clipCount);
      //Add loop toggle
      Toggle _toggle = cp5.addToggle("loop"+nf(clipCount,2))
                                .setPosition(cliploopMode_posX, cliploopMode_posY + clipCount*12)
                                .setSize(10,10)
                                .setGroup(allClips) 
                                .setValue(boolean(row.getInt("loop")));                   
                                ;
      _toggle.getCaptionLabel().hide();
      cliploopMode.add(_toggle);
      //
      Textfield _field = cp5.addTextfield("trigger_in"+nf(clipCount,2))
                            .setPosition(triggerIn_posX, triggerIn_posY + clipCount*12)
                            .setWidth(30)
                            .setHeight(10)
                            .setAutoClear(false)
                            .setGroup(allClips) 
                            .setValue(row.getString("trigger")); 
                            ;
      _field.getCaptionLabel().hide();
      triggerIn.add(_field);
      //
      if(!boolean(row.getInt("loop")))
        _field.hide();
      //
      startClipValues.append(row.getInt("start"));
      endClipValues.append(row.getInt("end"));
      Textlabel start = cp5.addTextlabel("startLabel"+nf(clipCount,2))
                           .setText(str(row.getInt("start")))
                           .setPosition(65,7 + selectClip.getArrayValue().length*12)
                           .setColorValue(color(255))
                           .setGroup(allClips)
                           ;
      Textlabel end = cp5.addTextlabel("endLabel"+nf(clipCount,2))
                         .setText(str(row.getInt("end")))
                         .setPosition(100,7  + selectClip.getArrayValue().length*12 )
                         .setColorValue(color(255))
                         .setGroup(allClips)
                         ;                 
      startLabel.add(start);
      endLabel.add(end);
      allClips.setBackgroundHeight(12*selectClip.getArrayValue().length + 22);
      clipCount++;
    }
  }else
     return false; 
  return true;
}


void readSerialLooper(){
  while (triggerInPort.available() > 0) {
    String inBuffer = triggerInPort.readString();   
    if (inBuffer != null && currentlySelected != -1) {
      String dataBuffer = trim(inBuffer);
      println(dataBuffer + " **** " + triggerIn.get(currentlySelected).getText());
      if(dataBuffer.equals(triggerIn.get(currentlySelected).getText())){//
        //
        if(currentlySelected < selectClip.getArrayValue().length - 1){  
          selectClip.activate(currentlySelected+1);
          println("Clip-" + currentlySelected + " Activated." );
        }
        else{
          currentlySelected = 0;
          selectClip.activate(currentlySelected); 
          println("Reset to: " + "Clip-" +  currentlySelected + "." );
        }
        //
      }
    }
  }
}


void draw(){
  background(0);
  readSerialLooper();
  //
  pg.beginDraw();
  pg.background(0);
  pg.stroke(255);
  pg.fill(255);
  //
  if(displayMode == 0)
    pg.image(loadStencil, 0, 0, width, height);
  if(displayMode == 1)
    pg.image(loadMask, 0, 0, width, height);
  if(displayMode == 2){
    pg.image(loadMovie, 0, 0, width, height);
  }
  pg.endDraw();
  //
  image(pg, 0, 0, width, height);   
  //
  fill(0, 150);
  noStroke();
  rect(0,0,width, 32);
  rect(0, height - 20*2, width, 20*2);
  
  if(displayMode == 2)
    drawTimeline();  
  //
  // 
  if(selectActive){
    int currentFrame = int(time_scale*loadMovie.time());        
    if(currentFrame >= endClipValues.get(currentlySelected)){
      
      //
      //check current mode and Print
      //
      String gotoMode = "Cont.";
      if(boolean(int(cliploopMode.get(currentlySelected).getValue()))){
        gotoMode = "Loop";
      }
      //modeDropdown.get(currentlySelected).captionLabel().getText();
      println(currentlySelected + " " + gotoMode);
      if(gotoMode.equals("Cont.")){
        if(currentlySelected < selectClip.getArrayValue().length - 1){  
          selectClip.activate(currentlySelected+1);
          println("Clip-" + currentlySelected + " Activated. It's goto-mode is " + gotoMode );
        }
        else{
          currentlySelected = 0;
          selectClip.activate(currentlySelected); 
          println("Reset to: " + "Clip-" +  currentlySelected + ". It's goto-mode is " + gotoMode );
        }
      }else if(gotoMode.equals("Loop")){
        selectClip.activate(currentlySelected); 
        println("Clip-" + currentlySelected + " Active. It's goto-mode is " + gotoMode );
      }else{
        ;  
      }
    }
  }
  //
  //Note: Needed to aviod paying/pausing from within the event
  if(updateFrame){ 
    updateFrame = false;
    if(playFlag)
      loadMovie.play();
    else
      loadMovie.pause();
  }
  
  //
  //
  if(activeServer == 1){
    if(server_syphon != null)
      server_syphon.sendImage(pg);  
  }else if(activeServer == 2){
    if(server_spout != null)
      server_spout.sendTexture(pg);
  }else{
   ;//Nothing to be sent 
  }
  //
  //
}

void drawTimeline()
{
  pushStyle();
  strokeWeight(8);
  stroke(52, 152, 219);
  line(0, height - 20, width ,height - 20);  
  stroke(241, 196, 15);
  float md = time_scale*loadMovie.duration();
  float mt = time_scale*loadMovie.time();
  int pos = (int)((width) * (mt / md));
  line(0, height - 20, pos, height - 20);
  //
  fill(255);
  textSize(9);
  
  int currFrame = int(time_scale*loadMovie.time());  
  text("Selected: " + currentlySelected + ", Frame: " + currFrame, 0, height - 30);
  //
  popStyle();
}

void controlEvent(ControlEvent theControlEvent) {
  //
  if(theControlEvent.isFrom("clipRange")) {
    active_start = false;
    active_end = false;
    playFlag = false;
    if(start_clip != int(theControlEvent.getController().getArrayValue(0)) && end_clip != int(theControlEvent.getController().getArrayValue(1))){
      start_clip = int(theControlEvent.getController().getArrayValue(0));
      end_clip = int(theControlEvent.getController().getArrayValue(1));
      active_start = true;
      loadMovie.jump(start_clip/time_scale);
      updateFrame = true;
    }else if(start_clip != int(theControlEvent.getController().getArrayValue(0))){
      start_clip = int(theControlEvent.getController().getArrayValue(0));
      active_start = true;
      loadMovie.jump(start_clip/time_scale);
      updateFrame = true;
    }else if(end_clip != int(theControlEvent.getController().getArrayValue(1))){
      end_clip = int(theControlEvent.getController().getArrayValue(1));
      active_end = true;
      loadMovie.jump(end_clip/time_scale);
      updateFrame = true;
    }
  }
  //
  if(theControlEvent.getName().contains("loop") && frameCount > 0){
    //
    for(int i=0; i<selectClip.getArrayValue().length;i++){
      if(!boolean(int(cliploopMode.get(i).getValue())))
        triggerIn.get(i).hide();
      else
        triggerIn.get(i).show();
    }
    //
  }
  //
  //
  if(theControlEvent.isFrom("playModes")) {
    int display = -1;
    //
    for(int i=0;i<theControlEvent.getGroup().getArrayValue().length;i++) {
      if(int(theControlEvent.getGroup().getArrayValue()[i]) == 1){
        display = i;
        break;  
      }
    }
    //
    if(display != -1){
      displayMode = display;
    }
    //
    if(display == 2){
      playpauseBang.show();
      allClips.open();
    }
    else{
      playpauseBang.hide();
      allClips.close();
    }
  }
  //
  if(theControlEvent.isFrom("serverModes")){
    int active = -1;
    //
    for(int i=0;i<theControlEvent.getGroup().getArrayValue().length;i++) {
      if(int(theControlEvent.getGroup().getArrayValue()[i]) == 1){
        active = i;
        break;  
      }
    }
    //
    if(active != -1){
      activeServer = active;
    }
    //
    if(activeServer == 0){
      ;// None
    }
    else if(activeServer == 1){
      if(server_syphon == null){
        server_syphon = new SyphonServer(this, "Processing Syphon");
      }
      else
        println("Syphon server already created. Activating mode");
    }else if(activeServer == 2){
      if(server_spout == null){
        server_spout = new Spout(this);
        server_spout.createSender("Processing Syphon");
      }
    }else{
      ;// active is -1
    }
  }
  //  
  if(theControlEvent.isFrom("selectClip") && !clipPressed) {
    int clipNumber = -1;
    for(int i=0;i<theControlEvent.getGroup().getArrayValue().length;i++) {
      if(int(theControlEvent.getGroup().getArrayValue()[i]) == 1){
        clipNumber = i;
        break;  
      }
    }
    if(clipNumber != -1){
      selectActive = true;
      currentlySelected = clipNumber;
      loadMovie.jump(startClipValues.get(clipNumber)/time_scale);
      updateFrame = true;
      if(playFlag == false)
        loadMovie.play();
    }else{
      selectActive = false;
      currentlySelected = -1;
      loadMovie.jump(0);
    }
  }
  
  if(theControlEvent.isFrom("selectClip") && clipPressed){
    int clipNumber = -1;
    for(int i=0;i<theControlEvent.getGroup().getArrayValue().length;i++) {
      if(int(theControlEvent.getGroup().getArrayValue()[i]) == 1){
        clipNumber = i;
        break;  
      }
    }
    if(clipNumber != -1){
      editActive = true;
      currentlyEditing = clipNumber;
      addBang.setLabel("update");
      if(!clipPressed){
        ;
      }
      else
        clipRange.setRangeValues(startClipValues.get(clipNumber)+1,endClipValues.get(clipNumber)+1);
    }else{
      editActive = false;
      currentlyEditing = -1;
      addBang.setLabel("add");
    }  
  }
}



void clip(boolean flag) {
  if(flag){
    clipPressed = true;
    if(!clipPressedAgain){
      clipRange.setRange(0,loadMovie.duration()*time_scale);
      if(!editActive){
        start_clip = int(time_scale*loadMovie.duration()/4);
        end_clip = int(3*time_scale*loadMovie.duration()/4);
      }else{
        start_clip = startClipValues.get(currentlyEditing)+1;
        end_clip   = endClipValues.get(currentlyEditing)+1;
      }
      clipRange.setBroadcast(true);
    }     
    if(editActive){
      start_clip = startClipValues.get(currentlyEditing)+1;
      end_clip = endClipValues.get(currentlyEditing)+1;
    }      
    clipRange.setRangeValues(start_clip,end_clip);
    clipRange.show();
    if(editActive)  addBang.setLabel("update");
    else            addBang.setLabel("add");
    addBang.show();
    clipPressedAgain = true;
  }else{
    clipPressed = false;
    clipRange.hide();
    addBang.hide();
    playFlag = true;
  }
}


void add(){
  if(!editActive){
    selectClip.addItem("Clip"+nf(clipCount,2), clipCount);
    //Add loop toggle
    Toggle _toggle = cp5.addToggle("loop"+nf(clipCount,2))
                              .setPosition(cliploopMode_posX, cliploopMode_posY + clipCount*12)
                              .setSize(10,10)
                              .setGroup(allClips)                       
                              ; 
    _toggle.getCaptionLabel().hide();
    cliploopMode.add(_toggle);
    //
    //
    Textfield _field = cp5.addTextfield("trigger_in"+nf(clipCount,2))
                          .setPosition(triggerIn_posX, triggerIn_posY + clipCount*12)
                          .setWidth(30)
                          .setHeight(10)
                          .setAutoClear(false)
                          .setGroup(allClips) 
                          ;
    _field.getCaptionLabel().hide();
    triggerIn.add(_field);
    _field.hide();
    //
    startClipValues.append(start_clip);
    endClipValues.append(end_clip);
    Textlabel start = cp5.addTextlabel("startLabel"+nf(clipCount,2))
                         .setText(str(start_clip))
                         .setPosition(65,7 + selectClip.getArrayValue().length*12)
                         .setColorValue(color(255))
                         .setGroup(allClips)
                         ;
    Textlabel end = cp5.addTextlabel("endLabel"+nf(clipCount,2))
                       .setText(str(end_clip))
                       .setPosition(100,7  + selectClip.getArrayValue().length*12 )
                       .setColorValue(color(255))
                       .setGroup(allClips)
                       ;                 
    startLabel.add(start);
    endLabel.add(end);
    allClips.setBackgroundHeight(12*selectClip.getArrayValue().length + 22);
    clipCount++;
    if(!allClips.isVisible())  allClips.show();
  }else{
    startClipValues.set(currentlyEditing, start_clip);
    endClipValues.set(currentlyEditing, end_clip);
    startLabel.get(currentlyEditing).setText(str(start_clip));
    endLabel.get(currentlyEditing).setText(str(end_clip));    
  }
}


void saveCSV(){
  println("saving into : " + csvFilename );
  Table table;
  table = new Table();
  
  table.addColumn("clip");
  table.addColumn("start");
  table.addColumn("end");
  table.addColumn("loop");
  table.addColumn("trigger");
  
  for(int i=0; i < startClipValues.size(); i++){
    TableRow newRow = table.addRow();
    newRow.setInt("clip", table.getRowCount() - 1);
    newRow.setInt("start", startClipValues.get(i));
    newRow.setInt("end", endClipValues.get(i));
    newRow.setInt("loop", int(cliploopMode.get(i).getValue()));
    newRow.setString("trigger", triggerIn.get(i).getText());
  }
  saveTable(table, csvFilename);
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  if(updateFrame){
    updateFrame = false;
    m.read();
  }
  //
  if(playFlag)
    m.read();
}

void keyPressed(){
  if(key == CODED){
    if(keyCode == RIGHT){
      println("NEXT - KeyPressed!");
      if(currentlySelected < selectClip.getArrayValue().length - 1){  
        selectClip.activate(currentlySelected+1);
        println("Clip-" + currentlySelected + " Activated." );
      }
      else{
        currentlySelected = 0;
        selectClip.activate(currentlySelected); 
        println("Reset to: " + "Clip-" +  currentlySelected + "." );
      }
    }
  }
}
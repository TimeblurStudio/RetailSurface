/**
 * ImageMapVisualController
 * by Mike Cj. 
 * TIMEBLUR 2019  
 * ----------
 * Description:
 * ----------
 * LICENSE: 
 *   Copyright (c) 2019 TIMEBLUR
 *   Permission is hereby granted by the Licensor(Timeblur) to the Licensee(Kavita Arora), obtaining a
 *   copy of this software and associated documentation files (the "Software"), a perpetual, worldwide,
 *   royalty-free, non-exclusive license, to deal in the Software without  restriction, including without 
 *   limitation the rights to use, copy, modify, merge, publish, distribute, and/or sell copies of the Software,
 *   and to permit persons to whom the Software, is furnished to do so, subject to the following conditions:
 *   
 *   
 *   The above copyright notice and this permission notice shall be included in
 *   all copies or substantial portions of the Software.
 *  
 *   The above exclusively applies to files containing this copyright notice, and
 *   does not apply for the rest of the software package containing these files.
 *  
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *   THE SOFTWARE.
 */

import processing.video.*;
import controlP5.*;

//
//
Movie loadMovie;
String fileName;
boolean clipPressed = false;
boolean clipPressedAgain = false;
int start_clip = 0, end_clip = 0;
boolean active_start = false, active_end = false;
int clipCount = 0;
IntList startClipValues = new IntList(), endClipValues = new IntList();
boolean editActive = false;
int currentlyEditing = -1;
boolean playback = false;
boolean updateFrame = false;
float time_scale = 1000;
//
//
ControlP5 cp5;
//
Group allClips;
Range clipRange;
RadioButton editClip;
Toggle clipToggle;
Bang addBang, saveCSVBang;
ArrayList<Textlabel> startLabel = new ArrayList<Textlabel>(), endLabel = new ArrayList<Textlabel>(); 
String csvFilename;
//
//

void setup(){
  size(842, 595);
  smooth();
  frameRate(30);
  //
  //
  setupgui();
  //
  loadMovieFile("Journey102-A4720.m4v");
  //
  imageMode(CORNERS);
}

void loadMovieFile(String fileName){
  //
  loadMovie = new Movie(this, fileName);
  loadMovie.loop();
  playback = true;
  //
  csvFilename = "data/" + fileName;//selection.getAbsolutePath();
  csvFilename = csvFilename.substring(0, csvFilename.length() - 4) + ".csv";
  //
  boolean entriesPresent = loadCSV();
  clipToggle.show();
  if(entriesPresent)  allClips.show();
  else                allClips.hide();
}

boolean loadCSV(){
  File csvFile = new File(dataPath("")+"/"+csvFilename.substring(5, csvFilename.length()));
  println(dataPath("")+"/"+csvFilename.substring(5, csvFilename.length()));
  println("File exists: " + csvFile.exists());
  if (csvFile.exists()){
    Table table;
    table = loadTable(csvFilename, "header");
    if(table.getRowCount() <= 0)
      return false;
    for (TableRow row : table.rows()) {
      clipCount = row.getInt("clip");
      editClip.addItem("Clip"+nf(clipCount,2), clipCount);
      startClipValues.append(row.getInt("start"));
      endClipValues.append(row.getInt("end"));
      Textlabel start = cp5.addTextlabel("startLabel"+nf(clipCount,2))
                           .setText(str(row.getInt("start")))
                           .setPosition(65,7 + editClip.getArrayValue().length*12)
                           .setColorValue(color(255))
                           .setGroup(allClips)
                           ;
      Textlabel end = cp5.addTextlabel("endLabel"+nf(clipCount,2))
                         .setText(str(row.getInt("end")))
                         .setPosition(100,7  + editClip.getArrayValue().length*12 )
                         .setColorValue(color(255))
                         .setGroup(allClips)
                         ;                 
      startLabel.add(start);
      endLabel.add(end);
      allClips.setBackgroundHeight(12*editClip.getArrayValue().length + 22);
      clipCount++;
    }
  }else
     return false; 
  return true;
}

void setupgui(){
  //
  cp5 = new ControlP5(this);
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
                .setPosition(8,44)
                .setWidth(150)
                .activateEvent(true)
                .setBackgroundColor(color(0,150))
                .setBackgroundHeight(22)
                .setLabel("Clips")
                .hide()
                ;
  //
   editClip = cp5.addRadioButton("editClip")
                 .setPosition(10,18)
                 .setSize(10, 10)
                 .setItemsPerRow(1)
                 .setSpacingColumn(30)
                 .setSpacingRow(2)
                 .setGroup(allClips)
                 ;
  //          
   cp5.addBang("saveCSV")
     .setPosition(allClips.getWidth()-45,3)
     .setSize(40,13)
     .setGroup(allClips)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;
}


void draw(){
  background(0);
  stroke(255);
  image(loadMovie, 0, 0, width, height);
  
  drawTimeline();
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
  popStyle();
}


void controlEvent(ControlEvent theControlEvent) {
  if(theControlEvent.isFrom("clipRange")) {
    active_start = false;
    active_end = false;
    playback = false;
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
  
  if(theControlEvent.isFrom("editClip")) {
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
        //kinect.seekPlayer(startClipValues.get(clipNumber)+1);
      }
      else
        clipRange.setRangeValues(startClipValues.get(clipNumber)+1,endClipValues.get(clipNumber)+1);
    }else{
      editActive = false;
      currentlyEditing = -1;
      addBang.setLabel("add");
      //kinect.seekPlayer(0);
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
    playback = true;
  }

}


void add(){
  if(!editActive){
    editClip.addItem("Clip"+nf(clipCount,2), clipCount);
    startClipValues.append(start_clip);
    endClipValues.append(end_clip);
    Textlabel start = cp5.addTextlabel("startLabel"+nf(clipCount,2))
                         .setText(str(start_clip))
                         .setPosition(65,7 + editClip.getArrayValue().length*12)
                         .setColorValue(color(255))
                         .setGroup(allClips)
                         ;
    Textlabel end = cp5.addTextlabel("endLabel"+nf(clipCount,2))
                       .setText(str(end_clip))
                       .setPosition(100,7  + editClip.getArrayValue().length*12 )
                       .setColorValue(color(255))
                       .setGroup(allClips)
                       ;                 
    startLabel.add(start);
    endLabel.add(end);
    allClips.setBackgroundHeight(12*editClip.getArrayValue().length + 22);
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
  
  for(int i=0; i < startClipValues.size(); i++){
    TableRow newRow = table.addRow();
    newRow.setInt("clip", table.getRowCount() - 1);
    newRow.setInt("start", startClipValues.get(i));
    newRow.setInt("end", endClipValues.get(i));
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
  if(playback)
    m.read();
}

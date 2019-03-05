// [DONE] Input Mode and 
// [DONE] Fix clips - selectable and playing 
// [DONE] Save/Load preferences
// [DONE] Organize
// Load when csv does not exist


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
String maskVideoFileName = "futureOfTravel_animationByNeeraj.mp4";
String EXTportName = "/dev/cu.usbserial-A9CVR15H";
//
PGraphics pg;
Spout server_spout = null;
SyphonServer server_syphon = null;
boolean serialComSetup = false;
boolean serialComEnabled = false;
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
int inMode = -1;
int activeServer = -1;
boolean selectActive = false;
int currentlySelected = -1;
IntList startClipValues = new IntList(), endClipValues = new IntList();
boolean editActive = false;
int currentlyEditing = -1;
//
PImage loadStencil, loadMask;
//
//
void setup(){
  //
  setupgui();
  loadStencil = loadImage(stencilFileName);
  loadMask = loadImage(maskFileName);
  loadMovieFile(maskVideoFileName);
  //
  //
  size(842, 595, P2D);
  pg = createGraphics(width, height, P3D);
  //
  smooth();
  frameRate(30);
  //
  //
  imageMode(CORNERS);
  //
  //
  //
  
}

void draw(){
  background(0);
  if(inMode == 2 && serialComEnabled)
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
  rect(0,0,width, 46);
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
  
  gui();
}

void gui() {
  hint(DISABLE_DEPTH_TEST);
  cp5.draw();
  hint(ENABLE_DEPTH_TEST);
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
  if(playFlag == true)
    text("Selected: " + currentlySelected + ", Frame: " + currFrame, 0, height - 30);
  //
  popStyle();
}




void keyPressed(){
  if(inMode == 1){
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
  
}
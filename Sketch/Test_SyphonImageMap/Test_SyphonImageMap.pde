import codeanticode.syphon.*;
import processing.video.*;

PGraphics pg;
SyphonServer server;

PImage loadPrint, loadMask;
Movie loadMovie;

boolean showActualPrint = true;
boolean showMask = false;
boolean showAnimation = false;

void setup(){
  size(842, 595, P3D);
  pg = createGraphics(width, height, P3D);
  server = new SyphonServer(this, "Processing Syphon");
  //
  loadPrint = loadImage("Journey102-A4720.png");
  loadMask = loadImage("journeyMask.001.jpeg");
  //
  loadMovie = new Movie(this, "Journey102-A4720.m4v");
  loadMovie.loop();
  //
  imageMode(CORNERS);
  //
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}

void draw(){
  //
  //
  pg.beginDraw();
  pg.background(0);
  pg.stroke(255);
  //pg.line(pg.width*0.5, pg.height*0.5, mouseX, mouseY);
  pg.fill(255);
  if(showActualPrint)
    pg.image(loadPrint, 0, 0, width, height);
  if(showMask)
    pg.image(loadMask, 0, 0, width, height);
  if(showAnimation)
    pg.image(loadMovie, 0, 0, width, height);
  pg.endDraw();
  //
  //
  image(pg, 0, 0, width, height);   
  //
  server.sendImage(pg);
}

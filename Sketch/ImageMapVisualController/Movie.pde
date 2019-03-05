
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
  inputModes.show();
  cp5.show();
  if(entriesPresent)  allClips.show();
  else                allClips.hide();
}




// Called every time a new frame is available to read
void movieEvent(Movie m) {
  if(updateFrame){
    println("Frame updated within <updateFrame>");
    updateFrame = false;
    m.read();
  }
  //
  if(playFlag)
    m.read();
}
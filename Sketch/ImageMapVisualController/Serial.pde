void setupSerial(String portName){
  try{
    triggerInPort = new Serial(this, portName, 9600);
  }catch(Exception e){
    println("*********");
    println("Exception while attempting to open port!");
    println("*********");
    println("Unable to connect to port - " + EXTportName);
    println("Make sure you are connnecting to the right port. Also,");
    println("Please make sure the Ext.Device is connected");
    println("Exiting...try again!");
    exit();
  }  
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
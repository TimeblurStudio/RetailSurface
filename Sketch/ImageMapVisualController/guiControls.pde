//
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
RadioButton inputModes;
Bang playpauseBang;
ArrayList<Toggle>  cliploopMode = new ArrayList<Toggle>();
ArrayList<Textfield>  triggerIn = new ArrayList<Textfield>();
//
int allClips_posX = 8, allClips_posY = 57;
int clipLabel_posX = 0, clipLabel_posY = 6;
int startValueLabel_posX = 65, startValueLabel_posY = 6;
int endValueLabel_posX = 100, endValueLabel_posY = 6;
int clipModeLabel_posX = 140, clipModeLabel_posY = 6;
int triggerInLabel_posX = 170, triggerInLabel_posY = 6;
//
int selectClip_posX = 10, selectClip_posY = 18;
int playModes_posX = 65, playModes_posY = 7;
int serverModes_posX = 65, serverModes_posY = 20;
int inputModes_posX = 65, inputModes_posY = 33;
int cliploopMode_posX = 150, cliploopMode_posY = 18;
int triggerIn_posX = 180, triggerIn_posY = 18;
//


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

  cp5.addBang("saveConf")
   .setPosition(10, 20)
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
  playpauseBang.setPosition(width - 50, height - 45);
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
                 .setSpacingColumn(45)
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
                 .setSpacingColumn(45)
                 .setSpacingRow(2)
                 .addItem("None", 0)
                 .addItem("Syphon", 1)
                 .addItem("Spout", 2)
                 .activate(0)
                 .hide()
                 ;
                 
  //
  inputModes= cp5.addRadioButton("inputModes")
                 .setPosition(inputModes_posX,inputModes_posY)
                 .setSize(10, 10)
                 .setItemsPerRow(4)
                 .setSpacingColumn(45)
                 .setSpacingRow(2)
                 .addItem("No In.", 0)
                 .addItem("Keyboard",1)
                 .addItem("Ext.Serial", 2)
                 .activate(1)
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
                    
                    
  cp5.getProperties().setFormat(ControlP5.SERIALIZED);          
  //
  cp5.getProperties().addSet("settings");
  cp5.getProperties().move(cp5.getGroup("playModes"), "default", "settings");
  cp5.getProperties().move(cp5.getGroup("serverModes"), "default", "settings");
  cp5.getProperties().move(cp5.getGroup("inputModes"), "default", "settings");
  //
  try{
    cp5.loadProperties(("data/settings"));
  }catch(Exception e){
    println(e);  
  }
}

void saveConf(){
  println("saving settings: data/settings.ser");
  cp5.saveProperties(("data/settings"), "settings");
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
  //
  if(theControlEvent.isFrom("inputModes")){
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
      inMode= active;
    }
    //
    if(inMode== 0 || inMode == 1){
      serialComEnabled = false;
    }else if(inMode == 2){
      serialComEnabled = true;
      if( serialComSetup == false){
        setupSerial(EXTportName);
        serialComSetup = true;
      }
      else
        println("Serial already connected.");
    }else{
      serialComEnabled = false;
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
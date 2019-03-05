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
String getExtErr()
{
  myPort.clear();
  myPort.write("exterr\n");
  while (myPort.available()==0) {
    delay(5);
  }
  return myPort.readString();
}

String getSettings()
{
  if (myPort==null) return "function disabled";
  myPort.clear();
  myPort.write("getsettings\n");
  while (myPort.available()==0) {
    delay(5);
  }
  String temp = myPort.readStringUntil(lf);
  String[] array = temp.split("\\ ");
  /*  for (int i=0; i<array.length; i++) {
   print(i, ": ");
   println(array[i]);
   }*/
  if (myPort.readString().contains("OK"))
  {
    MotorSpinup_.setText((array[0]));
    MotorSpindown_.setText((array[1]));
    DriveSelect_.setText((array[2]));
    DriveDeselect_.setText((array[3]));
    DirChange_.setText((array[4]));
    SideChange_.setText((array[5]));
    StepPulse_.setText((array[6]));
    StepSettle_.setText((array[7]));
    GotoTrack_.setText((array[8]));
    sdRetries_.setText((array[9]));
    hdRetries_.setText((array[10]));
    if (Integer.parseInt(array[11])==0) mtpMode_.setSelected(false);
    else mtpMode_.setSelected(true);
    drawStatus(status, "Settings read from Drive...");
    return "ok";
  } else {
    drawStatus(status, "Reading Settings failed.");    
    return "failed";
  }
}

String setSettings()
{
  if (myPort==null) return "function disabled";
  myPort.clear();
  String settimingsCmd =  "setsettings " +
    MotorSpinup_.getText() + " " + 
    MotorSpindown_.getText() + " " + 
    DriveSelect_.getText() + " " + 
    DriveDeselect_.getText() + " " + 
    DirChange_.getText() + " " + 
    SideChange_.getText() + " " + 
    StepPulse_.getText() + " " + 
    StepSettle_.getText() + " " + 
    GotoTrack_.getText()+ " " +
    sdRetries_.getText() + " " + 
    hdRetries_.getText() + " ";
  if (mtpMode_.isSelected()) settimingsCmd=settimingsCmd + "1 ";
  else settimingsCmd=settimingsCmd + "0 ";
  settimingsCmd = settimingsCmd +
    0xDEADDA7A + " " +
    0xDEADDA7A + " " +
    0xDEADDA7A + " " +
    0xDEADDA7A + " " +
    0xDEADDA7A + "\n";


  myPort.write(settimingsCmd);
  while (myPort.available()==0) {
    delay(5);
  }
  if (myPort.readString().contains("OK"))
  {
    drawStatus(status, "Settings written to RAM...");
    return "ok";
  } else {
    drawStatus(status, "Saving Settings failed.");    
    return "failed";
  }
}

String storeSettings()
{
  if (myPort==null) return "function disabled";
  myPort.clear();
  myPort.write("storesettings\n");
  while (myPort.available()==0) {
    delay(5);
  }
  if (myPort.readString().contains("OK"))
  {
    drawStatus(status, "Settings written to RAM & EEPROM...");
    return "ok";
  } else {
    drawStatus(status, "Storing Settings failed.");    
    return "failed";
  }
}

String resetSettings()
{
  if (myPort==null) return "function disabled";
  myPort.clear();
  myPort.write("resetsettings\n");
  while (myPort.available()==0) {
    delay(5);
  }
  if (myPort.readString().contains("OK"))
  {
    myPort.clear();
    myPort.write("storesettings\n");
    while (myPort.available()==0) {
      delay(5);
    }
    if (myPort.readString().contains("OK")) {
      drawStatus(status, "default values written to EEPROM ...");
      return "ok";
    } else {
      drawStatus(status, "Storing Settings failed.");    
      return "failed";
    }
  } else {
    drawStatus(status, "Storing Settings failed.");    
    return "failed";
  }
}

void diskInfo(boolean blank)
{
  String temp ="";
  if (!blank) {
    myPort.clear();
    myPort.write("diskinfo\n");
    while (myPort.available()==0) {
      delay(5);
    }
    String buf;
    while (!temp.endsWith("OK\r\n")) {
      buf = myPort.readString();
      if (buf!=null) temp = temp + buf;
      delay(5);
    }
    String [] array = new String[20];
    String [] tempArray = temp.split("\\r?\\n");
    for (int i = 0; i<20; i++) array[i] = "Info: NA";  
    for (int i = 0; i<tempArray.length; i++) array[i] = tempArray[i];  
    array[0] = array[0].substring(array[0].indexOf(": ")+2); // Bootchecksum
    array[1] = array[1].substring(array[1].indexOf(": ")+2); // Rootblock
    array[2] = array[2].substring(array[2].indexOf(": ")+2); // Filesystem
    array[3] = array[3].substring(array[3].indexOf(": ")+2); // RootblockType
    array[4] = array[4].substring(array[4].indexOf(": ")+2); // RootblockChecksum
    array[5] = array[5].substring(array[5].indexOf(": ")+2); // Name
    array[6] = array[6].substring(array[6].indexOf(": ")+2); // Modified
    array[7] = array[7].substring(array[7].indexOf(": ")+2); // Created
    array[8] = array[8].substring(array[8].indexOf(": ")+2); // BM Checksum
    array[9] = array[9].substring(array[9].indexOf(": ")+2); // Blocks free
    filename.setText("\""+array[5]+"\"");
    fileName=array[5].replaceAll("[#<>$+%!´`&*\"|{}?=/:\\@]", "_")+".adf";
    diskinfo.beginDraw();
    diskinfo.background(255);
    diskinfo.textFont(myPFont);
    diskinfo.textSize(12);
    diskinfo.fill(80, 80, 255);
    diskinfo.text("BootBlock", 1, 12);
    diskinfo.fill(0);
    diskinfo.text("FS:", 85, 12);
    diskinfo.text(array[2], 105, 12);
    diskinfo.text("RootPtr:", 1, 26);
    diskinfo.text(array[1], 50, 26);
    diskinfo.text("BBChksum:", 85, 26);
    if (array[0].contains("Valid")) diskinfo.fill(0, 255, 0);
    else diskinfo.fill(255, 0, 0);
    diskinfo.ellipse(155, 21, 10, 10);
    diskinfo.fill(0);
    diskinfo.line(5, 29, 165, 29);

    diskinfo.fill(80, 80, 255);
    diskinfo.text("RootBlock", 1, 42);
    diskinfo.fill(0);
    diskinfo.text("BlkType OK:", 85, 42);
    if (array[3].contains("Valid")) diskinfo.fill(0, 255, 0);
    else diskinfo.fill(255, 0, 0);
    diskinfo.ellipse(155, 37, 10, 10);
    diskinfo.fill(0);
    diskinfo.text("RBChksum:", 1, 56);
    if (array[4].contains("Valid")) diskinfo.fill(0, 255, 0);
    else diskinfo.fill(255, 0, 0);
    diskinfo.ellipse(70, 51, 10, 10);
    diskinfo.fill(0);
    diskinfo.text("BMChksum:", 85, 56);
    if (array[8].contains("Valid")) diskinfo.fill(0, 255, 0);
    else diskinfo.fill(255, 0, 0);
    diskinfo.ellipse(155, 51, 10, 10);
    diskinfo.fill(0);
    diskinfo.text("Created:", 1, 70);
    diskinfo.text(array[7], 62, 70);
    diskinfo.text("Modified:", 1, 84);
    diskinfo.text(array[6], 62, 84);
    diskinfo.text("Blocks Free:", 1, 98);
    diskinfo.text(array[9], 62, 98);

    for (int i = 0; i<tempArray.length-1; i++)
    {
      //    diskinfo.text(array[i], 2, 10*(i+1));
    }
    diskinfo.endDraw();
    getBitmap();
    drawBitmap(bitmap, false);
  } else {
    diskinfo.beginDraw();
    diskinfo.background(255);
    diskinfo.textFont(myPFont);
    diskinfo.textSize(20);
    diskinfo.fill(80, 80, 255);
    diskinfo.text("Insert Disk", 2, 25);
    diskinfo.text("and press", 2, 55);
    diskinfo.text("Diskinfo", 2, 85);
    diskinfo.endDraw();
  }
}
int probeDisk()
{
  myPort.clear();
  myPort.write("probe 1\n");
  while (myPort.available()==0) {
    delay(5);
  }
  String retString = myPort.readString();
  int ret =0;
  if (retString.charAt(0)=='2') ret = 2;
  if (retString.charAt(0)=='1') ret = 1;
  if (retString.charAt(0)=='0') ret = 0;
  if (retString.charAt(0)=='-') ret = -1;
  return ret;
}


int getMode()
{
  myPort.clear();
  myPort.write("getmode\n");
  while (myPort.available()==0) {
    delay(5);
  }
  if (myPort.readString().charAt(0) =='H') {
    mode = 1;
  } else {
    mode = 0;
  }
  return mode;
}
char byte2char(byte c) {
  if ((c < 32) | (c > 126)) {
    return (char) 46;
  } else {
    return (char) c;
  }
}
void getWeak(int track)
{
  myPort.clear();
  myPort.write("weak\n");
  while (myPort.available()==0) {
    delay(5);
  }
  weak[track] = myPort.read();
  if (weak[track] > 2) {
    //    println("Track: "+track+" Retries: "+weak[track]);
    trackmap[track]=#ffff00;
  } else {
    trackmap[track]=#00ff00;
  }
}

void getFlux(int track)
{
  long a, b, c, d;
  long tHist;
  myPort.clear();
  myPort.write("flux\n");
  while (myPort.available()<1024) {
    delay(5);
  }
  for (int i = 0; i<256; i++) {
    a = myPort.read();
    b = myPort.read();
    c = myPort.read();
    d = myPort.read();
    tHist = (d<<24)+(c<<16)+(b<<8)+a;
    hist[track][i]=tHist;
  }
  if (getMode()==1) histResHD = true;
  else histResHD = false;
}

void getIndexes(int revs)
{
  int a, b, c, d;
  int tInt;
  myPort.clear();
  myPort.write("getindex "+revs+"\n");
  while (myPort.available()<12*revs) {
    delay(5);
  }
  for (int i = 0; i<revs; i++) {
    for (int j = 0; j<3; j++) {
      a = myPort.read();
      b = myPort.read();
      c = myPort.read();
      d = myPort.read();
      tInt = (d<<24)+(c<<16)+(b<<8)+a;
      indexes[i][j]=tInt;
    }
  }
}

int getTransferred()
{
  int a, b, c, d;
  int tInt;
  myPort.clear();
  myPort.write("gettrans\n");
  while (myPort.available()<4) {
    delay(5);
  }
  a = myPort.read();
  b = myPort.read();
  c = myPort.read();
  d = myPort.read();
  tInt = (d<<24)+(c<<16)+(b<<8)+a;
  return tInt;
}

int getPacketCount()
{
  int a, b, c, d;
  int tInt;
  myPort.clear();
  myPort.write("getpktcnt\n");
  while (myPort.available()<4) {
    delay(5);
  }
  a = myPort.read();
  b = myPort.read();
  c = myPort.read();
  d = myPort.read();
  tInt = (d<<24)+(c<<16)+(b<<8)+a;
  return tInt;
}

void getBitmap()
{
  if (getMode()==0) bitMapSize = 1760;
  else bitMapSize = 2*1760;

  myPort.clear();
  myPort.write("bitmap\n");
  while (myPort.available()==0) {
    delay(5);
  }
  for (int i= 0; i<bitMapSize; i++) {
    if (myPort.readChar()=='0') bitMapArray[i]=0;
    else bitMapArray[i]=1;
  }
  myPort.clear();
}

void getTracks()
{
  ignoreChksumErr=chkSumChk.isSelected();
  abort = false;
  disableButtons();
  for (int i = 0; i<168; i++)
  {
    weak[i]=0;
    errormap[i]=0;
    trackmap[i]=#ffffff;
    for ( int j=0; j<256; j++) {
      hist[i][j]=0;
    }
  }
  int start = 0;
  int stop = 160;
  int zeit = millis();
  long errors = 0;
  int failed = 0;
  String tempString;
  boolean retry = false;
  int sectors = 11;
  String extError;
  boolean HDImage = false;
  myPort.clear();
  try {
    FileOutputStream fstream = new FileOutputStream(fileName);
    BufferedOutputStream bstream = new BufferedOutputStream(fstream);
    DataOutputStream dstream = new DataOutputStream(bstream);
    drawStatus(status, "Reading Tracks...");

    for (int i = start; i<stop; i++) {
      if (abort==true) {
        //abort = false;
        stop = i;
        drawStatus(status, "Aborting by User request...");
        break;
      }
      drawProgress(progress, i);
      myPort.write("get "+i+"\n");
      //println("error");
      myPort.write("error\n");
      while (myPort.available()==0) {
        delay(5);
      }
      tempString = trim(myPort.readString());
      errormap[i] = Long.parseLong(tempString);
      focusTrack = i;
      if (errormap[i]==-1) {
        extError = getExtErr();
        drawStatus(status, "Fatal Error Track " + i+ ": "+extError);
        if (showConfirmDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Retry?", extError+" at Track "+i, YES_NO_OPTION)==1)
        {
          failed = -1;
          break;
        } else {
          retry = true;
        }
      }       
      //      myPort.clear();
      //println("weak");
      getWeak(i);
      drawStatus(status, "Track: " + i+" Errors: "+errors);
      if (errormap[i]!=0) {
        errors++;
        drawStatus(status, "Track: " + i+" Errors: "+parseError(errormap[i]));
        trackmap[i]=#ff0000;
        grid(upperGrid, 0);
        grid(lowerGrid, 1);
        if (ignoreChksumErr==false) {
          //          int choice = showConfirmDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Retry?", "Checksum or Read error at Track "+i, YES_NO_CANCEL_OPTION);
          Object[] options = {"Retry", "Ignore", "Abort"};
          int choice = JOptionPane.showOptionDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), 
            "Checksum or Read error at Track "+i, 
            "Retry?", 
            JOptionPane.DEFAULT_OPTION, 
            JOptionPane.INFORMATION_MESSAGE, 
            null, options, options[0]);          
          switch (choice) {
          case 0: //yes
            retry = true;
            break;
          case 1: //no
            retry = false;
            break;
          case 2: //cancel
            abort = true;
            break;
          default:
            abort = true;
            break;
          }
        }
      }
      //println("dump");
      grid(upperGrid, 0);
      grid(lowerGrid, 1);
      if (getMode()==1) {
        sectors=22;
        HDImage = true;
      } else {
        sectors=11;
        HDImage = false;
      }
      getFlux(i);
      drawHistgfx(flux, HDImage);
      drawHistwindow(histogram, i);
      myPort.write("download\n");
      while (myPort.available()<512*sectors) {
        delay(10);
      }
      track = myPort.readBytes();

      if (retry==false) dstream.write(track, 0, 512*sectors);
      timeLabel.setText("Time remaining: "+((millis()-zeit)*160/(i+1)-(millis()-zeit))/1000+"s");
      //println("flux");
      if (retry) {
        i--;
        retry = false;
      }
    }
    dstream.close();
    zeit = millis()-zeit;
    if (failed == 0) {
      if (abort)
        drawStatus(status, "Download aborted. "+(stop-start)+" Tracks read in "+(zeit/1000)+" Seconds");
      else
        drawStatus(status, "Download complete. "+(stop-start)+" Tracks read in "+(zeit/1000)+" Seconds");
      PrintWriter logFile;
      logFile = createWriter(removeSuffix(fileName, 3)+".log");
      for (int i = start; i<stop; i++) {
        if ((errormap[i]!=0) || (weak[i]>1)) {
          logFile.print("Cyl: " + floor(i/2) + " Head: " + i%2 + " - ");
        }
        if (errormap[i]!=0) {
          logFile.println("Bad Track #"+i+parseError(errormap[i]));
        }
        if ((weak[i]>1)&&(errormap[i]==0)) {
          logFile.println("possible Weak Track #"+i+", needed "+weak[i]+" retries.");
        }
      }
      logFile.flush();
      logFile.close();
      noLoop();
      redraw();
      flux.save(removeSuffix(fileName, 3)+".jpg");
      loop();
      timeLabel.setText("Done");
    }
  }   
  catch(IOException e) {
    println("IOException");
    e.printStackTrace();
  }
  enableButtons(true, false);
  myPort.write("init\n");
  extError = getExtErr();
  if (!extError.contains("OK")) {
    drawStatus(status, "Drive Status: " + extError);
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
}

void readscp_main()
{
  abort = false;
  disableButtons();
  histResHD = false;
  for (int i = 0; i<168; i++)
  {
    weak[i]=0;
    errormap[i]=0;
    trackmap[i]=#ffffff;
    for ( int j=0; j<256; j++) {
      hist[i][j]=0;
    }
  }
  int start = int(starttrack.getText())*2;
  int stop = (int(endtrack.getText())+1)*2;
  int revs = revsSlider.getValueI();
  revsInBuffer = revs;
  for (int k = 0; k<168; k++)
    for (int j = 0; j<10; j++)
      revpointer[k][j]=0;
  int trackTable[] = new int [168];
  long errors = 0;
  long interval = 0;
  byte buffer[] = new byte [8192+2];
  int cell;
  int cellbuffer[] = new int [500000];
  int cellpointer = 0;
  int outpointer = 0;
  int tCell = 0;
  int tHist = 0;
  int buflen = 0;
  int failed = 0;
  RandomAccessFile fstream = null;
  myPort.clear();
  String scpName = fileName;
  try {
    drawStatus(status, "Reading Tracks...");
    if (!scanonly) {
      fstream = new RandomAccessFile(scpName, "rw");
      fstream.setLength(0);

      //writing scp header
      fstream.writeBytes("SCP"); // 'SCP'
      fstream.writeByte(0x00);   // version
      fstream.writeByte(0x80);   // disk type - 0x80 = other
      fstream.writeByte(revs);   // number of revolutions
      fstream.writeByte(start);  // start track
      fstream.writeByte(stop-1);   // end track
      fstream.writeByte(0x01);   // Flags Bits 01=Index Marks
      fstream.writeByte(0x00);   // Bit Cell Encoding 0=16bit
      fstream.writeByte(0x00);   // Heads -  0x00 = both Heads
      fstream.writeByte(0x00);   // resolution - 0x00 = 25ns
      fstream.writeInt(Integer.reverseBytes(0x00000000));    // checksum (Java Int is 32 bit)
      for (int j=0; j<168; j++) {
        fstream.writeInt(0);
        trackTable[j]= 0;
      }
    }
    int zeit = millis();

    for (int i = start; i<stop; i++) {
      if (abort==true) {
        //abort = false;
        stop = i;
        drawStatus(status, "Aborting by User request...");
        break;
      }
      interval = millis();
      trackmap[i]=#0000ff;
      drawProgress(progress, i);
      drawStatus(status, "Track: " + i+" Errors: "+errors);
      grid(upperGrid, 0);
      grid(lowerGrid, 1);
      drawHistgfx(flux, false);
      for (int j = 0; j<8192+2; j++) buffer[j]=0;
      cellpointer = 0;
      outpointer = 0;
      buffer[0] = 0;
      buffer[1] = 0x10;
      myPort.write("goto "+i+"\n");
      extError = getExtErr();
      if (!extError.contains("OK")) {
        drawStatus(status, "Drive Status: " + extError);
        showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
        enableButtons(false, true);
        if (!scanonly) fstream.close();
        return;
      }
      int tempcells = 0;
      int packetsReceived = 0;
      myPort.write("getcells "+revs+"\n");
      while ((buffer[0] == 0) && (buffer[1] == 0x10)) {
        while (myPort.available()<8192+2) {
          delay(1);
        }
        packetsReceived++;
        myPort.readBytes(buffer);
        //        println("Buf[0]: " + buffer[0] + " Buf[1]: " +buffer[1]);
        buflen = ((buffer[1]<<8)&0x0000ff00) + (buffer[0] & 0x000000ff);
        tempcells += buflen;
                //println(buflen + " cells read.");
        for (int k = 0; k<buflen; k++) {
          cellbuffer[cellpointer]=((buffer[3+k*2]<<8) & 0x0000ff00) + (buffer[2+k*2] & 0x000000ff);
          cellpointer++;
        }
      }
      //println("first cell: " + cellbuffer[0]);
      println("Cells: "+(cellpointer-1) + " readtime: "+ (millis()-interval) + " ms TempCells: " + tempcells);
      //for (int j = 0; j<10; j++) {
      //  print(cellbuffer[j]);
      //  print(" ");
      //}
      getIndexes(revs);
      int transCount = getTransferred();
      int packetsSent = getPacketCount();
      println("Transfered cells: " + transCount + " Packets read: " + packetsReceived + " expected: " + packetsSent + " last buf: " + buflen);
      if (transCount<indexes[revs-1][1]) {
        drawStatus(status, "Transfer Error");
        showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Buffer underflow, maybe your USB port is too slow.", "Information", INFORMATION_MESSAGE);
        enableButtons(false, true);
        if (!scanonly) fstream.close();
        return;
      }
      if (packetsReceived!=packetsSent) {
        drawStatus(status, "Transfer Error");
        showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Packet loss detected, maybe your USB port is too slow.", "Information", INFORMATION_MESSAGE);
        enableButtons(false, true);
        if (!scanonly) fstream.close();
        return;
      }
      for (int l = 0; l<revs; l++) {
        print("rev: " + l + " - ");
        print(indexes[l][0]+"ms ");
        print(indexes[l][1]+" bcells ");
        print(indexes[l][2]+" trans");
        println();
      }
      cellpointer = 1;
      int lastCell = cellbuffer[0];
      //      println("lastcell: "+lastCell);
      int t1, t2, overflow;
      overflow=0;
      for (int r = 0; r<revs; r++) {
        //println("Range: " + cellpointer + " - " + indexes[r][1]);
        for (int k = cellpointer; k<=indexes[r][1]; k++)
        {
          if ((cellbuffer[k]== 0) && (cellbuffer[k-1]<72)) // to compensate for isr latency, 1,5µs worst case assumed
          {
            //for (int p = -3; p<4; p++)
            //  print("[k("+p+")]: " + cellbuffer[k+p]+" ");
            //println(" pre");

            cellbuffer[k]= cellbuffer[k-1];
            cellbuffer[k-1]=0;

            //for (int p = -3; p<4; p++)
            //  print("[k("+p+")]: " + cellbuffer[k+p]+" ");
            //println(" post");
          }
          if ((cellbuffer[k]== 0) && (cellbuffer[k+1]>(65536-72))) // to compensate for isr latency, 1,5µs worst case assumed
          {
            //for (int p = -3; p<4; p++)
            //  print("[k("+p+")]: " + cellbuffer[k+p]+" ");
            //println(" pre_large");

            cellbuffer[k]= cellbuffer[k+1];
            cellbuffer[k+1]=0;

            //for (int p = -3; p<4; p++)
            //  print("[k("+p+")]: " + cellbuffer[k+p]+" ");
            //println(" post_large");
          }
        }
        int trackduration = 0;
        //if (overflow !=0) println("overflow: " + overflow);
        //overflow=0;
        //        println("indexes[" + r +"][1]: " + indexes[r][1]);
        float diff = 0;
        for (int k = cellpointer; k<indexes[r][1]; k++) {

          if (cellbuffer[k] == 0) {
            overflow += 0x10000;
          } else {
            t1 = (cellbuffer[k] & 0xffff)+overflow;
            t2 = lastCell & 0xffff;
            if (t1 <0) println("negative error t1");
            if (t2 <0) println("negative error t2");
            cell = t1-t2;
            lastCell = cellbuffer[k] & 0xffff;
            tCell = int(((cell*(1.0/48.0))/(1.0/40.0)));
            diff +=((double)cell*(1.0f/48.0f))/(1.0f/40.0f)-tCell;
            if (diff>1)
            {
              tCell +=1;
              diff -=1;
            }
            if (tCell<0) {
              for (int u = 0; u<revs; u++)
                print("Borders@ " + indexes[u][1] + " ");
              println();
              println("Track: "+i+" k:" + k + " cellPointer: " + cellpointer + " Negative tCell: " + tCell + " cellbuffer[k]: "+ cellbuffer[k] +
                " t1: " +t1 + " t2: " +t2+ " overflow: " +overflow+ " cell: " +cell + " lastcell: " + lastCell);
              for (int p = -8; p<9; p++)
                print("[k("+p+")]:" + cellbuffer[k+p]+" ");
              println();
              //        showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "negative error", "Information", INFORMATION_MESSAGE);
            }

            if (r==0) {
              tHist =cell/2;
              if (tHist>255) tHist = 255;
              if (tHist<0) tHist = 0;
              hist[i][tHist]++;
            }
            overflow = 0;

            while (tCell>65535)
            {
              bytebuffer[i][outpointer*2] = 0;
              bytebuffer[i][outpointer*2+1] = 0;
              outpointer++;
              tCell -= 65536;
              trackduration += 65536;
            }
            if (tCell == 0) {
              bytebuffer[i][outpointer*2] = 0;
              bytebuffer[i][outpointer*2+1] = 1;
              outpointer++;
              trackduration += 1;
            } else {
              bytebuffer[i][outpointer*2] = (byte)(tCell>>8);
              bytebuffer[i][outpointer*2+1] = (byte)(tCell);
              outpointer++;
              trackduration += tCell;
            }
          }
        }
        //println("diff: "+ diff/40);
        //println("cellpointer " + cellpointer + " indexes["+r+"][1] " + indexes[r][1] + " outpointer " + outpointer);
        //println("trackduration: " + trackduration);
        cellpointer = indexes[r][1];
        indexes[r][1] = outpointer-1;
        indexes[r][3] = trackduration;
      }
      //for (int r = 0; r<revs; r++) {
      //  for (int s = 0; s<3; s++) {
      //    print(indexes[r][s]+" ");
      //  }
      //  println();
      //}
      //      drawHist(histogram, i, false);
      drawHistwindow(histogram, i);
      drawHistgfx(flux, false);
      focusTrack = i;
      //println("cellbuffer convert: "+ (millis()-interval) + " ms");
      //print("Cellpointer: "+cellpointer);
      //print(" Outpointer: "+outpointer);
      //println(" Overflows: "+hist[i][1] + " Longcells: " + hist[i][0] + " Longbits: " + longbits);
      myPort.clear();
      if (!scanonly) {
        fstream.seek(fstream.length());
        trackTable[i] = (int)fstream.getFilePointer();
        interval = millis();
        fstream.writeBytes("TRK");
        fstream.writeByte(i); // Track Number
        //      fstream.writeInt(Integer.reverseBytes(indexes[0][0]*40));    // time from index 2 index in ns/25ns
        fstream.writeInt(Integer.reverseBytes(indexes[0][3]));    // time from index 2 index in ns/25ns
        //      fstream.writeInt(Integer.reverseBytes(8000000));    // time from index 2 index in ns/25ns
        fstream.writeInt(Integer.reverseBytes(indexes[0][1]));    // cellcount of revolution
        fstream.writeInt(Integer.reverseBytes(revs*12+4));    // offset to trackdata starting from "TRK"
      }
      //      println("[0]: "+ indexes[0][3] + " " + indexes[0][1] + " " + revs*12+4);    // time from index 2 index in ns/25ns
      for (int r = 1; r < revs; r++) {
        //        fstream.writeInt(Integer.reverseBytes(indexes[r][0]*40));    // time from index 2 index in ns/25ns
        if (!scanonly) {
          fstream.writeInt(Integer.reverseBytes(indexes[r][3]));    // time from index 2 index in ns/25ns
          fstream.writeInt(Integer.reverseBytes((indexes[r][1])-indexes[r-1][1]));    // cellcount of revolution
          fstream.writeInt(Integer.reverseBytes((revs*12+4)+indexes[r-1][1]*2));    // offset to trackdata starting from "TRK"
        }
        revpointer[i][r]=indexes[r-1][1]*2;
        //        println("[" + r +"]: "+ indexes[r][3] + " " + (indexes[r][1]-indexes[r-1][1]) + " " + ((revs*12+4)+indexes[r-1][1]*2));    // time from index 2 index in ns/25ns
      }
      revpointer[i][0]=2;
      revpointer[i][revs]=outpointer*2-2;
      drawFluxwindow(cellgraph, i, false);
      drawDiskwindow();

      if (!scanonly) {
        fstream.write(bytebuffer[i], 2, outpointer*2-2);
      }
      trackmap[i]=#00ff00;
      grid(upperGrid, 0);
      grid(lowerGrid, 1);
      timeLabel.setText("Time remaining: "+((millis()-zeit)*(stop+1)/(i+1)-(millis()-zeit))/1000+"s");
      //println("Capturetrack: "+ (millis()-interval) + " ms");
    }
    if (!scanonly) {
      fstream.seek(0x10);
      for (int j=0; j<168; j++) {
        fstream.writeInt(Integer.reverseBytes(trackTable[j]));
      }
      fstream.seek(fstream.length());
      String timestamp = LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("M/d/yyyy hh:mm:ss a"));
      //println(timestamp);
      //fstream.writeBytes("7/17/2013 12:45:49 PM"+"\n");
      fstream.writeBytes(timestamp+"\n");
      /*checksumme updaten*/
      fstream.close();
    }    
    zeit = millis()-zeit;
    if (failed == 0) {
      if (abort)
        drawStatus(status, "Download aborted. "+(stop-start)+" Tracks read in "+(zeit/1000)+" Seconds");
      else
        drawStatus(status, "Download complete. "+(stop-start)+" Tracks read in "+(zeit/1000)+" Seconds");
      //noLoop();
      //redraw();
      //loop();
      timeLabel.setText("Done");
    }
  }   
  catch(IOException e) {
    println("IOException");
    e.printStackTrace();
  }
  enableButtons(true, false);
  myPort.write("init\n");
  extError = getExtErr();
  if (!extError.contains("OK")) {
    drawStatus(status, "Drive Status: " + extError);
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
}

void loadSCP(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    return;
  } else {
    println("User selected " + selection.getAbsolutePath());
    fileName=selection.getAbsolutePath();
    filepathandname.setText(fileName);
  }
  for (int i = 0; i<168; i++)
  {
    weak[i]=0;
    errormap[i]=0;
    trackmap[i]=#ffffff;
    for ( int j=0; j<256; j++) {
      hist[i][j]=0;
    }
  }
  int start;
  int stop;
  int revs;
  for (int k = 0; k<168; k++)
    for (int j = 0; j<10; j++)
      revpointer[k][j]=0;
  int trackTable[] = new int [168];
  long errors = 0;
  long interval = 0;
  int outpointer = 0;
  RandomAccessFile fstream = null;
  myPort.clear();
  String scpName = fileName;
  try {
    drawStatus(status, "Reading Tracks...");
    fstream = new RandomAccessFile(scpName, "r");

    //reading scp header
    String scpTag = "";
    for (int i = 0; i<3; i++)
      scpTag+=(char)fstream.readByte(); // 'SCP'
    if (!scpTag.equals("SCP")) {
      println(scpTag);
      println("Not an SCP file.");
      fstream.close();
      return;
    }
    int version = fstream.readUnsignedByte();   // version
    int disk_type = fstream.readUnsignedByte();   // disk type - 0x80 = other
    revs = fstream.readUnsignedByte();   // number of revolutions
    revsInBuffer = revs;
    start = fstream.readUnsignedByte();  // start track
    stop = fstream.readUnsignedByte()+1;   // end track
    int index_marks = fstream.readUnsignedByte();   // Flags Bits 01=Index Marks
    int bit_cell_size  = fstream.readUnsignedByte();   // Bit Cell Encoding 0=16bit
    int heads =  fstream.readUnsignedByte();   // Heads -  0x00 = both Heads
    int resolution  = fstream.readUnsignedByte();   // resolution - 0x00 = 25ns
    int checksum  = Integer.reverseBytes(fstream.readInt());    // checksum (Java Int is 32 bit)
    println("Ver: "+version+" Type: "+disk_type+" Revs: "+revs+" Start: "+start+"Stop: "+stop+
      " IndexMarks: "+index_marks+ " Cell Size: "+bit_cell_size+" Heads: "+heads+" Res: "+resolution+" Checksum: "+checksum);
    for (int j=0; j<168; j++) {
      trackTable[j]=Integer.reverseBytes(fstream.readInt());
    }
    for (int j=0; j<168; j++) {
      trackmap[j]=#0000ff;
      drawProgress(progress, j);
      drawStatus(status, "Track: " + j+" Errors: "+errors);
      grid(upperGrid, 0);
      grid(lowerGrid, 1);
      if (trackTable[j]==0) continue;
      else fstream.seek(trackTable[j]);
      String trkTag = "";
      for (int i = 0; i<3; i++)
        trkTag+=(char)fstream.readByte(); // 'TRK'
      if (!trkTag.equals("TRK")) {
        println("No TRK tag.");
        fstream.close();
        return;
      }
      int tTrack = (int)fstream.readByte()&0xff;
      println("Track: " + tTrack);
      revpointer[j][0]=0;
      outpointer = 0;
      int[] index_time = new int[10];
      int[] track_length = new int[10];
      int[] data_offset = new int[10];
      for (int k = 0; k<revs; k++)
      {
        index_time[k] = Integer.reverseBytes(fstream.readInt());
        track_length[k] = Integer.reverseBytes(fstream.readInt());
        data_offset[k] = Integer.reverseBytes(fstream.readInt());
      }
      for (int k = 0; k<revs; k++)
      {
        fstream.seek(trackTable[j]+data_offset[k]);
        fstream.readFully(bytebuffer[j], outpointer, track_length[k]*2);
        outpointer += track_length[k]*2;
        revpointer[j][k+1]=revpointer[j][k]+track_length[k]*2;
      }
      trackmap[j]=#00ff00;
      focusTrack = j;
      grid(upperGrid, 0);
      grid(lowerGrid, 1);
      //      drawFlux(flux, false);
      //      drawHist(histogram, i, false);
      //      drawFlux(flux, false);
      println("Loadtrack: "+ (millis()-interval) + " ms");
    }
    fstream.close();
    drawDiskwindow();
    drawStatus(status, "Download complete. "+(stop-start)+" Tracks read");
    timeLabel.setText("Done");
  }   
  catch(IOException e) {
    println("IOException");
    e.printStackTrace();
  }
  enableButtons(true, false);
}

int magicfind(long buf, long mark)
{
  long mask = 0x00000000ffffffffl;
  for (int i = 0; i< 5; i++)
  {
    if ((buf & mask) == (mark & mask)) return i;
    buf = buf >>> 1;
  }
  return 0;
}

int sectorCnt = 0;
byte mfmstream[] = new byte [20000];

int decode2mfm(int track, int rev, boolean silent)
{
  sectorCnt = 0;
  int readBuff = 0;
  long readBuff2 = 0;
  long readmask = 0x00000000ffffffffl;
  int bCnt = 0;
  int readPtr = 0;
  int tCell = 0;
  int streampointer = revpointer[track][rev];
  int fluxtime = 0;
  while (streampointer<1000000)
  {
    tCell = (((int)bytebuffer[track][streampointer]<<8) + ((int)bytebuffer[track][streampointer+1] & 0xff) & 0xffff)*25; //tCell in nanoseconds
    streampointer+=2;
    fluxtime+=tCell;
    if (tCell > 9000)
    {
      continue;
    }
    if (tCell < 3500)
    {
      continue;
    }
    // fills buffer according to transition length with 10, 100 or 1000 (4,6,8µs transition)
    readBuff = ((readBuff << 2) | 0x02); //short transition
    readBuff2 = ((readBuff2 << 2) | 0x02); //short transition
    bCnt += 2;
    if (tCell > 5000)
    { // medium transition
      readBuff = readBuff << 1;
      readBuff2 = readBuff2 << 1;
      bCnt++;
    }
    if (tCell > 7000)
    { // long transition
      readBuff = readBuff << 1;
      readBuff2 = readBuff2 << 1;
      bCnt++;
    }
    if (bCnt >= 8) // do we have a complete byte?
    {
      mfmstream[readPtr++] = (byte)((readBuff >> (bCnt - 8)) & 0xff); // store byte in streambuffer
      bCnt = bCnt - 8;                            // decrease bit count by 8
    }
    readBuff2 &= 0x7ffffffffl;
    if ((readBuff2 & readmask) == 0xA4489448l)
      //if ((readBuff2 & readmask) == 0x2244a244l)
      //if (magicfind(readBuff2, 0x44894489) != 0)
    { // look for magic word. usually 44894489, but detecting this way its
      // easier to byte align the received bitstream from floppy
      if (!silent) println("magic at: " + fluxtime + " rb2: " + String.format("0x%016X", readBuff2 & readmask));
      //      println("magic at: " + fluxtime + " " +magicfind(readBuff2, 0x44894489));
      //if (sectorCnt != 0)
      //  if ((readPtr-7)==sectorTable[sectorCnt-1].bytePos) continue;
      sectorTable[sectorCnt].bytePos = readPtr - 7;
      sectorTable[sectorCnt].streamPos = fluxtime;
      sectorCnt++;
      bCnt = 4; // set bit count to 4 to align to byte a4489448
      //bCnt = 7; // set bit count to 4 to align to byte 2244a244
      //bCnt = 8 - magicfind(readBuff2, 0x44894489);
      if (sectorCnt >=maxSectors) break;
    }
    if ((streampointer >= revpointer[track][rev+1])) // stop when buffer is full
      break;
  }
  if (!silent) {
    println("sectors found: " + sectorCnt);
    for (int i = 0; i<sectorCnt; i++)
      print(sectorTable[i].bytePos + " ");
    println();
  }
  return sectorCnt;
}

void scan4Marks(int track, int rev, boolean silent)
{
  int tCell = 0;
  int streampointer = revpointer[track][rev];
  int AM = 0;
  int sync = 0;
  int syncbytes = 0;
  while (true)
  {
    tCell = (((int)bytebuffer[track][streampointer]<<8) + ((int)bytebuffer[track][streampointer+1] & 0xff) & 0xffff)*25; //tCell in nanoseconds
    streampointer+=2;
    if (streampointer >= revpointer[track][rev+1])
      break;
    if ((tCell > 9000) && (tCell < 11000))
    {
      AM++;
      sync= 0;
      continue;
    }
    if ((tCell > 3000) && (tCell < 5000))
    {
      sync++;
      if (sync==12) {
        syncbytes++;
        sync =0;
      }
      continue;
    }
    if (tCell <= 3000)
    {
      sync = 0;
      continue;
    }
    if (tCell >= 5000)
    { // medium or long transition
      sync = 0;
    }
  }
  if (!silent) {
    println("Access Marks found: " + AM);
    println("Sync Marks found: " + syncbytes);
  }
}

/*
   calculates a checksum of <secPtr> at <pos> for <b> bytes length
 returns checksum
 */
int calcChkSum(int secPtr, int pos, int b)
{
  int chkSum = 0;
  int tSum = 0;
  for (int i = 0; i < b / 4; i++)
  {
    tSum = (int)mfmstream[secPtr + (i * 4) + pos + 0] & 0xff;
    tSum = tSum << 8;
    tSum += (int)mfmstream[secPtr + (i * 4) + pos + 1] & 0xff;
    tSum = tSum << 8;
    tSum += (int)mfmstream[secPtr + (i * 4) + pos + 2] & 0xff;
    tSum = tSum << 8;
    tSum += (int)mfmstream[secPtr + (i * 4) + pos + 3] & 0xff;
    chkSum = chkSum ^ tSum;
  }
  chkSum = chkSum & 0x55555555;
  return chkSum;
}

/*
 decodes one MFM encoded Sector into Amiga Sector
 partly based on DecodeSectorData and DecodeLongword from AFR.C, written by
 Marco Veneri Copyright (C) 1997 released as public domain
 */
boolean decodeSector(int secPtr, int index, int track, boolean silent)
{
  secPtr += 8; // skip sync and magic word
  int tmp[] = new int [4];
  int decoded;
  int chkHeader = 0;
  int chkData = 0;
  boolean valid = true;
  tmp[0] = ((((int)mfmstream[secPtr + 0] << 8)&0xff00) + ((int)mfmstream[secPtr + 1]&0xff)) & 0x5555;
  tmp[1] = ((((int)mfmstream[secPtr + 2] << 8)&0xff00) + ((int)mfmstream[secPtr + 3]&0xff)) & 0x5555;
  tmp[2] = ((((int)mfmstream[secPtr + 4] << 8)&0xff00) + ((int)mfmstream[secPtr + 5]&0xff)) & 0x5555;
  tmp[3] = ((((int)mfmstream[secPtr + 6] << 8)&0xff00) + ((int)mfmstream[secPtr + 7]&0xff)) & 0x5555;

  // even bits
  tmp[0] = (tmp[0] << 1);
  tmp[1] = (tmp[1] << 1);

  // or with odd bits
  tmp[0] |= tmp[2];
  tmp[1] |= tmp[3];

  // final longword
  decoded = ((tmp[0] << 16) | tmp[1]);
  sectorTable[index].sector = (decoded >> 8) & 0xff;

  extTrack[index].format_type = (byte)(decoded >> 24); // format type 0xff = amiga
  extTrack[index].track  = (byte)(decoded >> 16); // track
  extTrack[index].sector = (byte)(decoded >> 8);  // sector
  extTrack[index].toGap  = (byte)decoded;       // distance to gap
  if (extTrack[index].format_type != (byte)0xff) valid = false;
  if (extTrack[index].track != track) valid = false;
  if ((extTrack[index].sector >21)|(extTrack[index].sector < 0)) valid = false;
  if ((extTrack[index].toGap >21)|(extTrack[index].toGap < 0)) valid = false;
  //decode checksums
  for (int i = 5; i < 7; i++)
  {
    tmp[0] = ((((int)mfmstream[secPtr + (i * 8) + 0] << 8)&0xff00) + ((int)mfmstream[secPtr + (i * 8) + 1]&0xff)) & 0x5555;
    tmp[1] = ((((int)mfmstream[secPtr + (i * 8) + 2] << 8)&0xff00) + ((int)mfmstream[secPtr + (i * 8) + 3]&0xff)) & 0x5555;
    tmp[2] = ((((int)mfmstream[secPtr + (i * 8) + 4] << 8)&0xff00) + ((int)mfmstream[secPtr + (i * 8) + 5]&0xff)) & 0x5555;
    tmp[3] = ((((int)mfmstream[secPtr + (i * 8) + 6] << 8)&0xff00) + ((int)mfmstream[secPtr + (i * 8) + 7]&0xff)) & 0x5555;
    // even bits
    tmp[0] = (tmp[0] << 1);
    tmp[1] = (tmp[1] << 1);
    // or with odd bits
    tmp[0] |= tmp[2];
    tmp[1] |= tmp[3];
    // final longword
    decoded = ((tmp[0] << 16) | tmp[1]);
    // store checksums for later use
    if (i == 5)
    {
      extTrack[index].header_chksum = decoded;
      chkHeader = decoded;
    } else
    {
      extTrack[index].data_chksum = decoded;
      chkData = decoded;
    }
  }
  // decode all the even data bits
  int data;
  for (int i = 0; i < 256; i++)
  {
    data = ((((int)mfmstream[secPtr + (i * 2) + 56] << 8)&0xff00) + ((int)mfmstream[secPtr + (i * 2) + 57]&0xff)) & 0x5555;
    extTrack[index].data[i*2] = (byte)(data >> 7);
    extTrack[index].data[i*2+1] = (byte)(data << 1);
  }

  // or with odd data bits
  for (int i = 0; i < 256; i++)
  {
    data = ((((int)mfmstream[secPtr + (i * 2) + 56 + 512] << 8)&0xff00) + ((int)mfmstream[secPtr + (i * 2) + 57 + 512]&0xff)) & 0x5555;
    extTrack[index].data[i*2] |= (byte)(data >> 8);
    extTrack[index].data[i*2+1] |= (byte)(data);
  }
  // check für checksum errors and generate error flags
  sectorTable[index].hcs_ok = true;
  if (calcChkSum(secPtr, 0, 40) != chkHeader)
  {
    extError = "HEADERCHKSUM_ERR";
    sectorTable[index].hcs_ok = false;
  }
  sectorTable[index].dcs_ok = true;
  if (calcChkSum(secPtr, 56, 1024) != chkData)
  {
    extError = "DATACHKSUM_ERR";
    sectorTable[index].hcs_ok = false;
  }
  sectorTable[index].sector_valid = valid;
  if (!silent&&valid) {
    println("Format: " + String.format("%02X", extTrack[index].format_type) + " Track: " + extTrack[index].track
      + " Sector: " + extTrack[index].sector + " toGap: " + extTrack[index].toGap);
    for (int i = 0; i < 16; i++)
      print(String.format("%02X ", extTrack[index].os_recovery[i]));
    println();
    print("Header Checksum: " + String.format("0x%08X", extTrack[index].header_chksum));
    if (sectorTable[index].hcs_ok) print(" [OK] "); 
    else print(" [FAIL] ");
    print(" Data Checksum: " + String.format("0x%08X", extTrack[index].data_chksum));
    if (sectorTable[index].dcs_ok) print(" [OK] "); 
    else print(" [FAIL] ");
    println();
    for (int i = 0; i < 16; i++) {
      for (int j = 0; j < 32; j++) {
        System.out.printf("%02x", extTrack[index].data[i*32+j]);
      }
      print(" ");
      for (int j = 0; j < 32; j++) {
        System.out.printf("%c", byte2char(extTrack[index].data[(i*32)+j]));
      }
      println();
    }
  }
  return valid;
}

int decodeTrack(int track, int sectorCnt, boolean silent)
{
  int validsectors = 0;
  if (!silent) println("Decoding Bitstream, expecting "+ sectorCnt + " Sectors.");
  if (!silent) print("Sectors start at: ");
  for (int i = 0; i < sectorCnt; i++)
  {
    if (!silent) println("BytePos: " + sectorTable[i].bytePos);
    if (decodeSector(sectorTable[i].bytePos, i, track, silent)) validsectors++;
  }
  if (!silent) println("Valid Sectors found: " + validsectors);
  return validsectors;
}

void cleanDrive()
{
  abort = false;
  disableButtons();
  myPort.clear();
  for (int i = 0; i<168; i++)
  {
    trackmap[i]=#ffffff;
  }
  String temp = dropList2.getSelectedText();
  temp = temp.replace(" sec", "");
  int tDuration = int(temp);
  int i = 0;
  int secs= 0;
  int zeit = millis();
  drawStatus(status, "Moving Head around...");
  int duration = zeit + tDuration*1000;
  while (duration > millis()) {
    if (abort==true) {
      abort = false;
      drawStatus(status, "Aborting by User request...");
      break;
    }
    trackmap[i*2]=#00ffff;
    trackmap[i*2+1]=#00ffff;
    myPort.write("goto "+i*2+"\n");
    drawStatus(status, "Track: " + i);
    i = (i + 6)%80;
    grid(upperGrid, 0);
    grid(lowerGrid, 1);
    secs = (duration - millis())/1000;
    timeLabel.setText("Time remaining: "+secs+"s");
    drawProgress(progress, int(160-(160/float(tDuration)*secs)));
    delay(1000);
    secs = (duration - millis())/1000;
    timeLabel.setText("Time remaining: "+secs+"s");
    drawProgress(progress, int(160-(160/float(tDuration)*secs)));
    delay(1000);
  }
  enableButtons(false, false);
  myPort.write("init\n");
  extError = getExtErr();
  if (!extError.contains("OK")) {
    drawStatus(status, "Drive Status: " + extError);
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
}

String getName()
{
  myPort.clear();
  myPort.write("name\n");
  while (myPort.available()==0) {
    delay(5);
  }
  return trim(myPort.readString());
}

void autoRip()
{
  disableButtons();
  myPort.clear();
  abort=false;
  diskChange=false;
  while (abort==false)
  {
    while (diskChange==false && abort==false) {
      myPort.write("dskcng\n");
      while (myPort.available()==0) {
        delay(5);
      }
      delay(1000);
      if (Integer.valueOf(trim(myPort.readString()))==0)
      {
        diskChange = false;
        diskPanel.setVisible(true);
      } else {
        diskChange = true;
        diskPanel.setVisible(false);
      }
    }
    if (abort==true) break;
    myPort.write("init\n");
    extError = getExtErr();
    if (!extError.contains("OK")) {
      drawStatus(status, "Drive Status: " + extError);
      showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
      enableButtons(false, true);
      return;
    }
    myPort.clear();
    delay(200);

    fileName = getName();
    if (fnprompt.isSelected()) {
      JLabel flabel = new JLabel("\nExisting Files will be overwritten!\n");
      flabel.setForeground(Color.RED);
      flabel.setFont(new Font("Sans Serif", Font.BOLD, 14));
      JTextField fname = new JTextField(fileName);
      Object[] message = {null, flabel, "Name:", fname};

      JOptionPane pane = new JOptionPane( message, 
        JOptionPane.WARNING_MESSAGE, 
        JOptionPane.OK_CANCEL_OPTION);
      JDialog dialog = pane.createDialog(null, "Chose Imagename");
      dialog.setLocationRelativeTo(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame());
      dialog.setVisible(true);
      Object selectedValue = pane.getValue();
      if (selectedValue == null) break;
      if ((int)selectedValue != 0) break;
      System.out.println("Eingabe: " + fname.getText() + " Value: " + selectedValue);
      fileName = fname.getText();
      filename.setText(fileName);
      fileName = filePath+fileSep+fileName.replaceAll("[#<>$+%!´`&*\"|{}?=/:\\@]", "_")+".adf";
    } else {
      filename.setText(fileName);
      fileName = filePath+fileSep+fileName.replaceAll("[#<>$+%!´`&*\"|{}?=/:\\@]", "_")+"_"+Long.toHexString(System.currentTimeMillis())+".adf";
    }
    filepathandname.setText(fileName);
    myPort.write("init\n");
    extError = getExtErr();
    if (!extError.contains("OK")) {
      drawStatus(status, "Drive Status: " + extError);
      showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
      enableButtons(false, true);
      return;
    }
    myPort.clear();
    delay(200);
    println("Ripping: "+fileName);
    getTracks();
    disableButtons();
    myPort.write("init\n");
    extError = getExtErr();
    if (!extError.contains("OK")) {
      drawStatus(status, "Drive Status: " + extError);
      showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
      enableButtons(false, true);
      return;
    }
    myPort.clear();
    while (diskChange==true && abort==false) {
      delay(1000);
      myPort.write("dskcng\n");
      while (myPort.available()==0) {
        delay(5);
      }
      if (Integer.valueOf(trim(myPort.readString()))==0)
      {
        diskChange = false;
      } else {
        diskChange = true;
        diskPanel.setVisible(true);
      }
    }
  }
  abort = false;
  drawStatus(status, "Aborting by User request...");
  diskPanel.setVisible(false);
  enableButtons(false, false);
}

void setPreErase()
{
  myPort.clear();
  if (preErase) myPort.write("preerase\n");
  else myPort.write("noerase\n");
  while (myPort.available()==0) {
    delay(5);
  }
  myPort.readString();
  myPort.clear();
}

void singleErase(int track, int celltime)
{
  myPort.clear();
  myPort.write("erase " + track + " " + celltime + "\n");
  while (myPort.available()==0) {
    delay(5);
  }
  myPort.readString();
  myPort.clear();
}

void autoFormat()
{
  autoFormatDisks = true;
  String s = (String)showInputDialog(
    ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), 
    "Diskbasename:\n", 
    "Format several Disks", 
    QUESTION_MESSAGE, null, null, diskName);
  if (s == null) return;
  s = s.substring(0, Math.min(s.length(), 20));
  String diskBaseName=s.replaceAll("[#<>$+%!´`&*\"|{}?=/:\\@]", "_");
  disableButtons();
  myPort.clear();
  myPort.write("nomtp\n");
  myPort.clear();
  setPreErase();
  abort=false;
  diskChange=false;
  int count = 1;
  while (abort==false)
  {
    while (diskChange==false && abort==false) {
      myPort.write("dskcng\n");
      while (myPort.available()==0) {
        delay(5);
      }
      delay(1000);
      if (Integer.valueOf(trim(myPort.readString()))==0)
      {
        diskChange = false;
        diskPanel.setVisible(true);
      } else {
        diskChange = true;
        diskPanel.setVisible(false);
      }
    }
    if (abort==true) break;
    myPort.write("init\n");
    extError = getExtErr();
    if (!extError.contains("OK")) {
      drawStatus(status, "Drive Status: " + extError);
      showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
      enableButtons(false, true);
      return;
    }
    myPort.clear();
    delay(200);
    diskName = diskBaseName + String.format("%04d", count++);
    filename.setText(diskName);
    formatTracks();
    disableButtons();

    myPort.write("init\n");
    extError = getExtErr();
    if (!extError.contains("OK")) {
      drawStatus(status, "Drive Status: " + extError);
      showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
      enableButtons(false, true);
      return;
    }
    myPort.clear();
    while (diskChange==true && abort==false) {
      delay(1000);
      myPort.write("dskcng\n");
      while (myPort.available()==0) {
        delay(5);
      }
      if (Integer.valueOf(trim(myPort.readString()))==0)
      {
        diskChange = false;
      } else {
        diskChange = true;
        diskPanel.setVisible(true);
      }
    }
  }
  abort = false;
  drawStatus(status, "Aborting by User request...");
  diskPanel.setVisible(false);
  enableButtons(false, false);
  autoFormatDisks = false;
  myPort.write("mtp\n");
  myPort.clear();
}

int waitForDiskChange()
{
  int diskChange = 0;
  int diskChangeCount = 0;
  myPort.clear();
  while (diskChange==0)
  {
    myPort.write("dskcng\n");
    while (myPort.available()==0) {
      delay(5);
    }
    diskChange = Integer.valueOf(trim(myPort.readString()));
    diskChangeCount++;
    if (diskChangeCount >5) {
      return -1;
    }
  }
  return 1;
}

byte [] generateImage(String diskName, boolean HD)
{
  int imageSize;
  if (HD) imageSize = 1802240;
  else imageSize = 901120;
  byte image[] = new byte [imageSize];
  for (int i = 0; i< imageSize; i++) image[i]=0;
  //Bootblock not bootable
  image[0]='D';
  image[1]='O';
  image[2]='S';
  image[3]=0x00;
  int rootBlockPos = 880;
  if (HD) rootBlockPos = 1760;
  //rootblock
  image[rootBlockPos*512+3] =0x02; // Blocktype 2 = RootBlock
  image[rootBlockPos*512+15]=0x48; // Hashtablesize = 72
  image[rootBlockPos*512+0x138]=(byte)0xff;
  image[rootBlockPos*512+0x139]=(byte)0xff;
  image[rootBlockPos*512+0x13a]=(byte)0xff;
  image[rootBlockPos*512+0x13b]=(byte)0xff;  //bitmap flag = -1 -> Valid

  if (HD) { //Bitmap location HD
    image[rootBlockPos*512+0x13e]=(byte)0x06;
    image[rootBlockPos*512+0x13f]=(byte)0xe1;
  } else { //Bitmap location DD
    image[rootBlockPos*512+0x13e]=(byte)0x03;
    image[rootBlockPos*512+0x13f]=(byte)0x71;
  }
  diskName = diskName.substring(0, Math.min(diskName.length(), 30));
  for (int i = 0; i < diskName.length(); i++) {
    image[rootBlockPos*512+0x1b1+i]=(byte)diskName.charAt(i);
  }
  image[rootBlockPos*512+0x1b0]=(byte)diskName.length();
  image[rootBlockPos*512+0x1ff]= 1; //secType
  amigaTime aTime = makeTime();
  //  println("Days: " + aTime.day + " mins: " + aTime.min + " ticks: " + aTime.ticks);

  //creation date FFS and OFS
  image[rootBlockPos*512+0x1a4]=(byte)(byte) (aTime.day>>24 & 0xff); //cDays
  image[rootBlockPos*512+0x1a5]=(byte) (aTime.day>>16 & 0xff);
  image[rootBlockPos*512+0x1a6]=(byte) (aTime.day>>8 & 0xff);
  image[rootBlockPos*512+0x1a7]=(byte) (aTime.day & 0xff);
  image[rootBlockPos*512+0x1a8]=(byte) (aTime.min>>24 & 0xff); //cMins
  image[rootBlockPos*512+0x1a9]=(byte) (aTime.min>>16 & 0xff);
  image[rootBlockPos*512+0x1aa]=(byte) (aTime.min>>8 & 0xff);
  image[rootBlockPos*512+0x1ab]=(byte) (aTime.min & 0xff);
  image[rootBlockPos*512+0x1ac]=(byte) (aTime.ticks>>24 & 0xff); //cTicks
  image[rootBlockPos*512+0x1ad]=(byte) (aTime.ticks>>16 & 0xff);
  image[rootBlockPos*512+0x1ae]=(byte) (aTime.ticks>>8 & 0xff);
  image[rootBlockPos*512+0x1af]=(byte) (aTime.ticks & 0xff);
  // last access
  image[rootBlockPos*512+0x1d8]=(byte) (aTime.day>>24 & 0xff); //Days
  image[rootBlockPos*512+0x1d9]=(byte) (aTime.day>>16 & 0xff);
  image[rootBlockPos*512+0x1da]=(byte) (aTime.day>>8 & 0xff);
  image[rootBlockPos*512+0x1db]=(byte) (aTime.day & 0xff);
  image[rootBlockPos*512+0x1dc]=(byte) (aTime.min>>24 & 0xff); //Mins
  image[rootBlockPos*512+0x1dd]=(byte) (aTime.min>>16 & 0xff);
  image[rootBlockPos*512+0x1de]=(byte) (aTime.min>>8 & 0xff);
  image[rootBlockPos*512+0x1df]=(byte) (aTime.min & 0xff);
  image[rootBlockPos*512+0x1e0]=(byte) (aTime.ticks>>24 & 0xff); //Ticks
  image[rootBlockPos*512+0x1e1]=(byte) (aTime.ticks>>16 & 0xff);
  image[rootBlockPos*512+0x1e2]=(byte) (aTime.ticks>>8 & 0xff);
  image[rootBlockPos*512+0x1e3]=(byte) (aTime.ticks & 0xff);
  // creation date OFS
  image[rootBlockPos*512+0x1e4]=(byte) (aTime.day>>24 & 0xff); //coDays
  image[rootBlockPos*512+0x1e5]=(byte) (aTime.day>>16 & 0xff);
  image[rootBlockPos*512+0x1e6]=(byte) (aTime.day>>8 & 0xff);
  image[rootBlockPos*512+0x1e7]=(byte) (aTime.day & 0xff);
  image[rootBlockPos*512+0x1e8]=(byte) (aTime.min>>24 & 0xff); //coMins
  image[rootBlockPos*512+0x1e9]=(byte) (aTime.min>>16 & 0xff);
  image[rootBlockPos*512+0x1ea]=(byte) (aTime.min>>8 & 0xff);
  image[rootBlockPos*512+0x1eb]=(byte) (aTime.min & 0xff);
  image[rootBlockPos*512+0x1ec]=(byte) (aTime.ticks>>24 & 0xff); //coticks
  image[rootBlockPos*512+0x1ed]=(byte) (aTime.ticks>>16 & 0xff);
  image[rootBlockPos*512+0x1ee]=(byte) (aTime.ticks>>8 & 0xff);
  image[rootBlockPos*512+0x1ef]=(byte) (aTime.ticks & 0xff);

  long newsum = 0;
  for (int i = 0; i < 128; i++)
    newsum += (image[rootBlockPos*512 + i*4] << 24 & 0xff000000)
      | (image[rootBlockPos*512 + i*4 + 1] << 16 & 0x00ff0000)
      | (image[rootBlockPos*512 + i*4 + 2] << 8 & 0x0000ff00)
      | (image[rootBlockPos*512 + i*4 + 3] & 0x000000ff);
  newsum = (int)-newsum;
  image[rootBlockPos*512+0x14]=(byte) (newsum>>24 & 0xff);
  image[rootBlockPos*512+0x15]=(byte) (newsum>>16 & 0xff);
  image[rootBlockPos*512+0x16]=(byte) (newsum>>8 & 0xff);
  image[rootBlockPos*512+0x17]=(byte) (newsum & 0xff);

  // construction of bitmap block
  for (int i = 4; i < 512; i++) {
    image[(rootBlockPos+1)*512+i]=-1;
  }
  if (HD) {
    image[(rootBlockPos+1)*512+220]=0x3f;
  } else {
    image[(rootBlockPos+1)*512+114]=0x3f;
  }
  newsum = 0;
  int tempSum = 0;
  int blockPtr = (rootBlockPos+1)*512;
  for (int i = 0; i < 128; i++) {
    tempSum =  (image[blockPtr + i*4] << 24 & 0xff000000)
      | (image[blockPtr + i*4 + 1] << 16 & 0x00ff0000)
      | (image[blockPtr + i*4 + 2] <<  8 & 0x0000ff00)
      | (image[blockPtr + i*4 + 3]       & 0x000000ff);
    newsum = newsum + tempSum;
  }
  newsum = (int)-newsum;
  image[(rootBlockPos+1)*512+0x00]=(byte) (newsum>>24 & 0xff);
  image[(rootBlockPos+1)*512+0x01]=(byte) (newsum>>16 & 0xff);
  image[(rootBlockPos+1)*512+0x02]=(byte) (newsum>>8 & 0xff);
  image[(rootBlockPos+1)*512+0x03]=(byte) (newsum & 0xff);
  return image;
}


void formatTracks()
{
  focusTrack = -1;
  boolean quick = quickFormat.isSelected();
  if (!autoFormatDisks) {
    String s = (String)showInputDialog(
      ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), 
      "Diskname:\n", 
      "Format Disk", 
      QUESTION_MESSAGE, null, null, diskName);
    if (s == null) return;
    s = s.substring(0, Math.min(s.length(), 30));
    diskName=s.replaceAll("[#<>$+%!´`&*\"|{}?=/:\\@]", "_");
  }
  int retries= 0;
  indexAligned = indexAlign.isSelected();
  if (indexAligned) myPort.write("indexalign 1\n");
  else myPort.write("indexalign 0\n");
  verify=verifyCheck.isSelected();
  setPreErase();
  abort = false;
  disableButtons();
  myPort.clear();
  int start = int(starttrack.getText())*2;
  int stop = (int(endtrack.getText())+1)*2;
  for (int i = 0; i<168; i++)
  {
    weak[i]=0;
    errormap[i]=0;
    trackmap[i]=#ffffff;
    for ( int j=0; j<256; j++) {
      hist[i][j]=0;
    }
  }
  int zeit = millis();
  long errors = 0;
  int failed = 0;
  String tempString;
  boolean retry = false;
  int trackSize = 5632;
  boolean HDImage = false;
  drawHistgfx(flux, HDImage);
  int pDisk = probeDisk();
  switch (pDisk) {
  case 1: //DD
    HDImage = false;
    break;
  case 2: //HD
    HDImage = true;
    break;
  case -1: //write protected
    drawStatus(status, "Disk is write protected.");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Disk is write protected.", "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  default:
    drawStatus(status, "faulty Disk.");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Magnetic surface of the Disk is faulty.", "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }

  byte image[] = generateImage(diskName, HDImage);
  int imageSize = image.length;
  //imageSize=0;
  switch (imageSize) {
  case 901120:
    HDImage = false;
    trackSize = 5632;
    break;
  case 1802240:
    HDImage = true;
    trackSize = 2*5632;
    if (HD_allowed) break;
    drawStatus(status, "Formatting HD isn't implemented yet.");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Formattting HD Images isn't implemented yet.", "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  default:    
    drawStatus(status, "Wrong Image size");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Wrong Image Size", "Error", ERROR_MESSAGE);
    enableButtons(false, false);
    return;
  }
  byte track[] = new byte[trackSize];
  byte trackComp[] = new byte[trackSize];
  Arrays.fill(track, (byte)0);
  Arrays.fill(trackComp, (byte)0);

  drawStatus(status, "Writing Tracks");
  myPort.write("init\n");
  extError = getExtErr();
  if (!extError.contains("OK")) {
    drawStatus(status, "Drive Status: " + extError);
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
  delay(100);
  waitForDiskChange();
  if (HDImage) {
    myPort.write("setmode hd\n");
  } else {
    myPort.write("setmode dd\n");
  }
  while (myPort.available()<2) {
    delay(5);
  }
  tempString = trim(myPort.readString());
  for (int i = start; i<stop; i++) {
    if (i==1 && quick) i=80;
    if (i==81 && quick) {
      drawProgress(progress, 159);
      break;
    }
    if (abort==true) {
      abort = false;
      drawStatus(status, "Aborting by User request...");
      break;
    }
    waitForDiskChange();
    if (HDImage) {
      if (i >=160) arrayCopy(image, 159*512*22, track, 0, 512*22);
      else arrayCopy(image, i*512*22, track, 0, 512*22);
      myPort.write("upload\n");
      myPort.write(track);
      while (myPort.available()<2) {
        delay(5);
      }
      tempString = trim(myPort.readString());
    } else {
      if (i >=160) arrayCopy(image, 159*512*11, track, 0, 512*11);
      else arrayCopy(image, i*512*11, track, 0, 512*11);
      myPort.write("upload\n");
      myPort.write(track);
      while (myPort.available()<2) {
        delay(5);
      }
      tempString = trim(myPort.readString());
    }
    myPort.write("put "+i+"\n");
    //    delay(250);
    while (myPort.available()==0) {
      delay(5);
    }
    tempString = trim(myPort.readString());
    if (tempString.contains("OK")) {
      trackmap[i]=#0000ff;
      grid(upperGrid, 0);
      grid(lowerGrid, 1);
    }
    drawProgress(progress, i);
    myPort.write("error\n");
    while (myPort.available()==0) {
      delay(5);
    }
    tempString = trim(myPort.readString());
    errors = Long.parseLong(tempString);
    if (errors==-1) {
      drawStatus(status, getExtErr()+" Aborting...");
      failed = -1;
      break;
    }
    if (verify) {
      myPort.write("get "+i+"\n");
      myPort.write("download\n");
      while (myPort.available()<trackSize) {
        delay(10);
      }
      trackComp = myPort.readBytes();
      getWeak(i);
      getFlux(i);
      focusTrack = i;
      drawHistgfx(flux, HDImage);
      drawHistwindow(histogram, i);
      if (!Arrays.equals(track, trackComp)) {
        trackmap[i]=#ff0000;
        retry = true;
        retries++;
      } else {
        //        trackmap[i]=#00ff00;
        retries=0;
      }
      grid(upperGrid, 0);
      grid(lowerGrid, 1);
    }
    drawStatus(status, "Track: " + i + " Retries: " + retries);
    if (retries>=2) {
      if (showConfirmDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Retry?", "Write error at Track "+i, YES_NO_OPTION)==1)
      {
        drawStatus(status, "Track " + i+" is unwritable. Aborting...");
        failed = -1;
        break;
      } else {
        retries = 0;
      }
    }
    timeLabel.setText("Time remaining: "+((millis()-zeit)*160/(i+1)-(millis()-zeit))/1000+"s");
    if (retry) {
      //println("extra erase track: " + i);
      //singleErase(i,200);
      i--;
      retry = false;
    }
  }
  zeit = millis()-zeit;
  if (failed == 0) {
    drawStatus(status, "Format completed in "+(zeit/1000)+" Seconds");
    timeLabel.setText("Done");
  } else {
    timeLabel.setText("Error");
  }   
  if (!autoFormatDisks) diskInfo(false);
  enableButtons(false, false);
  myPort.write("init\n");
  extError = getExtErr();
  if (!extError.contains("OK")) {
    drawStatus(status, "Drive Status: " + extError);
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
  drawActive(active, 3);
}

void eraseTracks()
{
  abort = false;
  disableButtons();
  myPort.clear();
  for (int i = 0; i<168; i++)
  {
    weak[i]=0;
    errormap[i]=0;
    trackmap[i]=#ffffff;
    for ( int j=0; j<256; j++) {
      hist[i][j]=0;
    }
  }
  int start = int(starttrack.getText())*2;
  int stop = (int(endtrack.getText())+1)*2;
  int zeit = millis();
  int failed = 0;
  String tempString;
  boolean HDdisk = false;
  drawHistgfx(flux, HDdisk);
  switch (probeDisk()) {
  case 1: //DD
    HDdisk = false;
    break;
  case 2: //HD
    HDdisk = true;
    break;
  case -1: //write protected
    drawStatus(status, "Disk is write protected.");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Disk is write protected.", "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  default:
    drawStatus(status, "faulty Disk.");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Magnetic surface of the Disk is faulty.", "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }

  drawStatus(status, "Erasing Tracks");
  myPort.write("init\n");
  extError = getExtErr();
  if (!extError.contains("OK")) {
    drawStatus(status, "Drive Status: " + extError);
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
  delay(100);
  for (int i = start; i<stop; i++) {
    if (abort==true) {
      abort = false;
      drawStatus(status, "Aborting by User request...");
      break;
    }
    myPort.clear();
    if (HDdisk) myPort.write("erase " + i + " 200\n");
    else myPort.write("erase " + i + " 400\n");
    while (myPort.available()<2) {
      delay(5);
    }
    tempString = trim(myPort.readString());
    if (tempString.contains("OK")) {
      trackmap[i]=#ff00ff;
      grid(upperGrid, 0);
      grid(lowerGrid, 1);
    }
    drawProgress(progress, i);
    drawStatus(status, "Track: " + i);
    timeLabel.setText("Time remaining: "+((millis()-zeit)*160/(i+1)-(millis()-zeit))/1000+"s");
  }
  zeit = millis()-zeit;
  if (failed == 0) {
    drawStatus(status, "Erase completed in "+(zeit/1000)+" Seconds");
    timeLabel.setText("Done");
  } else {
    timeLabel.setText("Error");
  }   
  enableButtons(false, false);
  myPort.write("init\n");
  extError = getExtErr();
  if (!extError.contains("OK")) {
    drawStatus(status, "Drive Status: " + extError);
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
  drawActive(active, 3);
}

void putTracks()
{
  focusTrack = -1;
  int retries= 0;
  setPreErase();
  indexAligned = indexAlign.isSelected();
  if (indexAligned) myPort.write("indexalign 1\n");
  else myPort.write("indexalign 0\n");
  verify=verifyCheck.isSelected();
  abort = false;
  disableButtons();
  myPort.clear();
  for (int i = 0; i<168; i++)
  {
    weak[i]=0;
    errormap[i]=0;
    trackmap[i]=#ffffff;
    for ( int j=0; j<256; j++) {
      hist[i][j]=0;
    }
  }
  int start = 0;
  int stop = 160;
  int zeit = millis();
  long errors = 0;
  int failed = 0;
  String tempString;
  boolean retry = false;
  int trackSize = 5632;
  byte image[] = loadBytes(fileName);
  if (image==null) {
    drawStatus(status, "Error reading Image");
    enableButtons(false, false);
    return;
  }
  boolean HDImage = false;
  drawHistgfx(flux, HDImage);
  int imageSize = image.length;
  switch (imageSize) {
  case 901120:
    HDImage = false;
    trackSize = 5632;
    break;
  case 1802240:
    HDImage = true;
    trackSize = 2*5632;
    if (HD_allowed) break;
    drawStatus(status, "Writing HD isn't implemented yet.");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Writing HD Images isn't implemented yet.", "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  default:    
    drawStatus(status, "Wrong Image size");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Wrong Image Size", "Error", ERROR_MESSAGE);
    enableButtons(false, false);
    return;
  }
  int pDisk = probeDisk();
  if (pDisk==2 && HDImage == false) {
    trackmap[0]=#ff0000;
    grid(upperGrid, 0);
    grid(lowerGrid, 1);
    drawStatus(status, "Disktype Error.");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Write Error, writing a DD Image to a HD Disk is not permitted, please cover the HD Hole of the Disk.", "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
  if (pDisk==1 && HDImage == true) {
    trackmap[0]=#ff0000;
    grid(upperGrid, 0);
    grid(lowerGrid, 1);
    drawStatus(status, "Disktype Error.");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Write Error, writing a HD Image to a DD Disk is not permitted, please use a HD Disk.", "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
  if (pDisk==-1) {
    trackmap[0]=#ff0000;
    grid(upperGrid, 0);
    grid(lowerGrid, 1);
    drawStatus(status, "Disk is writeprotected.");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Disk is writeprotected.", "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
  if (pDisk==0) {
    trackmap[0]=#ff0000;
    grid(upperGrid, 0);
    grid(lowerGrid, 1);
    drawStatus(status, "Disk faulty.");
    int choice = showConfirmDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Disk might be faulty, continue?", "Information", INFORMATION_MESSAGE);
    println(choice);
    enableButtons(false, true);
    return;
  }

  byte track[] = new byte[trackSize];
  byte trackComp[] = new byte[trackSize];
  Arrays.fill(track, (byte)0);
  Arrays.fill(trackComp, (byte)0);

  drawStatus(status, "Writing Tracks");
  myPort.write("init\n");
  extError = getExtErr();
  if (!extError.contains("OK")) {
    drawStatus(status, "Drive Status: " + extError);
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
  delay(100);
  waitForDiskChange();
  if (HDImage) {
    myPort.write("setmode hd\n");
  } else {
    myPort.write("setmode dd\n");
  }

  while (myPort.available()<2) {
    delay(5);
  }
  tempString = trim(myPort.readString());
  for (int i = start; i<stop; i++) {
    if (abort==true) {
      abort = false;
      drawStatus(status, "Aborting by User request...");
      break;
    }
    waitForDiskChange();
    if (HDImage) {
      arrayCopy(image, i*512*22, track, 0, 512*22);
      myPort.write("upload\n");
      myPort.write(track);
      while (myPort.available()<2) {
        delay(5);
      }
      tempString = trim(myPort.readString());
    } else {
      arrayCopy(image, i*512*11, track, 0, 512*11);
      myPort.write("upload\n");
      myPort.write(track);
      while (myPort.available()<2) {
        delay(5);
      }
      tempString = trim(myPort.readString());
    }
    myPort.write("put "+i+"\n");
    //    delay(250);
    while (myPort.available()==0) {
      delay(5);
    }
    tempString = trim(myPort.readString());
    if (tempString.contains("OK")) {
      trackmap[i]=#0000ff;
      grid(upperGrid, 0);
      grid(lowerGrid, 1);
    }
    drawProgress(progress, i);
    myPort.write("error\n");
    while (myPort.available()==0) {
      delay(5);
    }
    tempString = trim(myPort.readString());
    errors = Long.parseLong(tempString);
    if (errors==-1) {
      drawStatus(status, getExtErr()+" Aborting...");
      failed = -1;
      break;
    }
    if (verify) {
      myPort.write("get "+i+"\n");
      myPort.write("download\n");
      while (myPort.available()<trackSize) {
        delay(10);
      }
      trackComp = myPort.readBytes();
      getWeak(i);
      getFlux(i);
      drawHistgfx(flux, HDImage);
      drawHistwindow(histogram, i);
      focusTrack = i;
      if (!Arrays.equals(track, trackComp)) {
        trackmap[i]=#ff0000;
        retry = true;
        retries++;
      } else {
        trackmap[i]=#00ff00;
        retries=0;
      }
      grid(upperGrid, 0);
      grid(lowerGrid, 1);
    }
    drawStatus(status, "Track: " + i + " Retries: " + retries);
    if (retries>=2) {
      if (showConfirmDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Retry?", "Write error at Track "+i, YES_NO_OPTION)==1)
      {
        drawStatus(status, "Track " + i+" is unwritable. Aborting...");
        failed = -1;
        break;
      } else {
        retries = 0;
      }
    }
    timeLabel.setText("Time remaining: "+((millis()-zeit)*160/(i+1)-(millis()-zeit))/1000+"s");
    if (retry) {
      i--;
      retry = false;
    }
  }
  zeit = millis()-zeit;
  if (failed == 0) {
    drawStatus(status, "Write complete. "+(stop-start)+" Tracks written in "+(zeit/1000)+" Seconds");
    timeLabel.setText("Done");
    diskInfo(false);
  } else {
    timeLabel.setText("Error");
  }
  diskInfo(false);
  enableButtons(false, true);
  myPort.write("init\n");
  extError = getExtErr();
  if (!extError.contains("OK")) {
    drawStatus(status, "Drive Status: " + extError);
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
}

void compareDisk()
{
  abort = false;
  disableButtons();
  myPort.clear();
  for (int i = 0; i<168; i++)
  {
    weak[i]=0;
    errormap[i]=0;
    trackmap[i]=#ffffff;
    for ( int j=0; j<256; j++) {
      hist[i][j]=0;
    }
  }
  int start = 0;
  int stop = 160;
  int zeit = millis();
  long errors = 0;
  int failed = 0;
  String tempString;
  int trackSize = 5632;
  byte image[] = loadBytes(fileName);
  if (image==null) {
    drawStatus(status, "Error reading Image");
    enableButtons(false, false);
    return;
  }
  boolean HDImage = false;
  drawHistgfx(flux, HDImage);
  int imageSize = image.length;
  switch (imageSize) {
  case 901120:
    HDImage = false;
    trackSize = 5632;
    break;
  case 1802240:
    HDImage = true;
    trackSize = 2*5632;
    if (HD_allowed) break;
    drawStatus(status, "Writing HD isn't implemented yet.");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Writing HD Images isn't implemented yet.", "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  default:    
    drawStatus(status, "Wrong Image size");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Wrong Image Size", "Error", ERROR_MESSAGE);
    enableButtons(false, false);
    return;
  }
  byte track[] = new byte[trackSize];
  byte trackComp[] = new byte[trackSize];
  Arrays.fill(track, (byte)0);
  Arrays.fill(trackComp, (byte)0);

  drawStatus(status, "Comparing Tracks");
  myPort.write("init\n");
  extError = getExtErr();
  if (!extError.contains("OK")) {
    drawStatus(status, "Drive Status: " + extError);
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
  delay(100);
  waitForDiskChange();
  if (HDImage) {
    myPort.write("setmode hd\n");
  } else {
    myPort.write("setmode dd\n");
  }
  while (myPort.available()<2) {
    delay(5);
  }

  tempString = trim(myPort.readString());
  for (int i = start; i<stop; i++) {
    if (abort==true) {
      abort = false;
      drawStatus(status, "Aborting by User request...");
      break;
    }
    waitForDiskChange();
    if (HDImage) {
      arrayCopy(image, i*512*22, track, 0, 512*22);
    } else {
      arrayCopy(image, i*512*11, track, 0, 512*11);
    }
    drawProgress(progress, i);
    myPort.write("error\n");
    while (myPort.available()==0) {
      delay(5);
    }
    tempString = trim(myPort.readString());
    errors = Long.parseLong(tempString);
    if (errors==-1) {
      drawStatus(status, getExtErr()+" Aborting...");
      failed = -1;
      break;
    }
    {
      myPort.write("get "+i+"\n");
      myPort.write("download\n");
      while (myPort.available()<trackSize) {
        delay(10);
      }
      trackComp = myPort.readBytes();
      getWeak(i);
      getFlux(i);
      drawHistgfx(flux, HDImage);
      drawHistwindow(histogram, i);
      focusTrack = i;
      if (!Arrays.equals(track, trackComp)) {
        trackmap[i]=#ff0000;
      } else {
        if (weak[i]==0) trackmap[i]=#00ff00;
        else trackmap[i]=#ffff00;
      }
      grid(upperGrid, 0);
      grid(lowerGrid, 1);
    }
    drawStatus(status, "Track: " + i + " Retries: " + weak[i]);
    timeLabel.setText("Time remaining: "+((millis()-zeit)*160/(i+1)-(millis()-zeit))/1000+"s");
  }
  zeit = millis()-zeit;
  if (failed == 0) {
    drawStatus(status, "Compare complete. "+(stop-start)+" Tracks compared in "+(zeit/1000)+" Seconds");
    timeLabel.setText("Done");
  } else {
    timeLabel.setText("Error");
  }    
  enableButtons(false, true);
  myPort.write("init\n");
  extError = getExtErr();
  if (!extError.contains("OK")) {
    drawStatus(status, "Drive Status: " + extError);
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
}

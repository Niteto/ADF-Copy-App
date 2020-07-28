PGraphics upperGrid;
PGraphics lowerGrid;
PGraphics flux;
PGraphics histogram;
PGraphics cellgraph;
PGraphics progress;
PGraphics status;
PGraphics active;
PGraphics logo;
PGraphics diskImage;
PGraphics diskinfo;
PGraphics bitmap; 
PGraphics diskside0; 
PGraphics diskside1; 
void onClose(String foo)
{
  println(foo);
}

void setupGUI()
{
  createGUI();
  histwindow.setVisible(showhist);
  fluxdetail.setVisible(false);
  diskwindow.setVisible(false);
  java.awt.Frame f =  (java.awt.Frame) ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame();
  if (f.getHeight()+histwindow.height < displayHeight)
    histwindow.setLocation(f.getX(), f.getY()+f.getHeight());
  //if (f.getHeight()+fluxdetail.width < displayWidth)
  //  fluxdetail.setLocation(f.getX()+f.getWidth(), f.getY());
  //if (f.getHeight()+diskwindow.width < displayWidth)
  //  diskwindow.setLocation(f.getX()+f.getWidth(), f.getY()+fluxdetail.height+10);
  showhist_.setSelected(showhist);
  showflux_.setSelected(showflux);
  showdisk_.setSelected(showdisk);
  ((processing.awt.PSurfaceAWT.SmoothCanvas)histwindow.getSurface().getNative()).getFrame().setFocusableWindowState(false);
  ((processing.awt.PSurfaceAWT.SmoothCanvas)fluxdetail.getSurface().getNative()).getFrame().setFocusableWindowState(false);
  ((processing.awt.PSurfaceAWT.SmoothCanvas)diskwindow.getSurface().getNative()).getFrame().setFocusableWindowState(false);
  upperGrid = createGraphics(180, 180);
  lowerGrid = createGraphics(180, 180);
  flux = createGraphics(360, 360);
  histogram = createGraphics((int)histPad.getWidth(), (int)histPad.getHeight());
  cellgraph = createGraphics((int)cellPad.getWidth(), (int)cellPad.getHeight());
  diskside0 = createGraphics((int)side0.getWidth(), (int)side0.getHeight());
  diskside1 = createGraphics((int)side1.getWidth(), (int)side1.getHeight());
  //println((int)histPad.getWidth());
  //println((int)histPad.getHeight());

  progress = createGraphics(160, 10);
  active = createGraphics(20, 190);
  status = createGraphics(370, 20);
  logo = createGraphics(170, 127);
  diskinfo = createGraphics(170, 100);
  bitmap = createGraphics(160, 44);
  drawBitmap(bitmap, true);
  diskImage = createGraphics(130, 131);
  diskImage.beginDraw();
  diskImage.image(disk, 0, 0);
  diskImage.endDraw();
  drawLogo(logo);
  drawProgress(progress, -1);
  grid(upperGrid, 0);
  grid(lowerGrid, 1);
  drawFlux(flux, false);
  drawHist(histogram, 0);
  drawCells(cellgraph, 0, false);
  drawDisk();
  //print("Monitor display resolution is ");
  //println(displayWidth + " x " + displayHeight);
  //println(f.getHeight());
  //println(f.getWidth());
  try {
    //myFont = java.awt.Font.createFont(Font.TRUETYPE_FONT, new File(dataPath("")+fileSep+myFontName)).deriveFont(myFontSize);
    GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
    boolean regRes = ge.registerFont(Font.createFont(Font.TRUETYPE_FONT, 
      new File(dataPath("")+fileSep+myFontName)).deriveFont(myFontSize));
    if (regRes == false) {
      println("RegisterFont('Roboto Condensed') failed. Using alternate font.");
      myFont = new Font("SansSerif", Font.PLAIN, 11);
    } else {
      myFont = new Font("Roboto Condensed", Font.PLAIN, 13);
    }
  } 
  catch (IOException e) {
    e.printStackTrace();
  }  
  catch (FontFormatException e) {
    e.printStackTrace();
  }
  myPFont = createFont(myFontName, 14f);
  drawStatus(status, firmware);
  println(firmware);
  filename.setFont(myFont);
  filepathandname.setFont(myFont);
  label3.setFont(myFont);
  label4.setFont(myFont);
  label2.setFont(myFont);
  label5.setFont(myFont);
  label6.setFont(myFont);
  verifyCheck.setFont(myFont);
  timeLabel.setFont(myFont);
  aboutP.setFont(myFont);
  aboutP.moveTo(10, 10);
  closeB.setFont(myFont);
  LoadSettings.setFont(myFont); 
  TestSettings.setFont(myFont); 
  SaveSettings.setFont(myFont); 
  MotorSpinup_.setFont(myFont); 
  MotorSpindown_.setFont(myFont); 
  DriveSelect_.setFont(myFont); 
  DriveDeselect_.setFont(myFont); 
  DirChange_.setFont(myFont); 
  spinup.setFont(myFont); 
  SideChange_.setFont(myFont); 
  StepPulse_.setFont(myFont); 
  StepSettle_.setFont(myFont); 
  GotoTrack_.setFont(myFont); 
  Spindown.setFont(myFont); 
  DriveSelect.setFont(myFont); 
  DriveDeselect.setFont(myFont); 
  DirChange.setFont(myFont); 
  SideChange.setFont(myFont); 
  StepPulse.setFont(myFont); 
  StepSettle.setFont(myFont); 
  gotoTrack.setFont(myFont); 
  MtpOn.setFont(myFont); 
  reset2DefaultSettings.setFont(myFont);
  starttrack.setFont(myFont);
  starttrack.setLocalColor(6, color(255, 255, 255)); //background
  endtrack.setFont(myFont);
  endtrack.setLocalColor(6, color(255, 255, 255)); //background

  ReadPanel.moveTo(120, -20);
  ReadPanel.setVisible(true);
  WritePanel.moveTo(120, -20);
  WritePanel.setVisible(false);
  SCPPanel.moveTo(120, -20);
  SCPPanel.setVisible(false);
  if (!write_SCP) disableButton(WriteSCP);
  UtilityPanel.moveTo(120, -20);
  UtilityPanel.setVisible(false);
  SettingsPanel.moveTo(120, 10);
  SettingsPanel.setVisible(false);
  drawActive(active, 0);

  chkSumChk.setFont(myFont);
  GButton.useRoundCorners(false);
  GCScheme.changePaletteColor(10, 2, color(150));
  GCScheme.changePaletteColor(10, 3, color(230));
  GCScheme.changePaletteColor(10, 4, color(200));
  GCScheme.changePaletteColor(10, 6, color(200));
  GCScheme.changePaletteColor(10, 14, color(200));
  color lightBlue = color(#ccccff);
  color darkBlue = color(#0b0b60);
  GCScheme.changePaletteColor(11, 2, color(50));
  GCScheme.changePaletteColor(11, 3, darkBlue);
  GCScheme.changePaletteColor(11, 4, lightBlue);
  GCScheme.changePaletteColor(11, 6, lightBlue);
  GCScheme.changePaletteColor(11, 14, lightBlue);
  closeB.setLocalColorScheme(11);
  enableButtons(false, false);
  aboutP.setVisible(false);
  diskPanel.setVisible(false);
  filename.setTextEditEnabled(false);
  filepathandname.setTextEditEnabled(false);
  aboutText.setTextEditEnabled(false);
  aboutText.setFont(myFont);
  //  aboutText.textSize(14);  
  aboutText.setText(
    "ADF-Copy App - Frontend to Read and Write Amiga Floppy Disks\n"+
    "Copyright (C) 2020 Dominik Tonn (nick@niteto.de)\n"+
    " \n"+                    
    "visit http://nicklabor.niteto.de for Infos and Updates\n"+
    "send me an e-mail if you want to order a pcb.\n"+
    " \n"+                    
    "This program is free software: you can redistribute it and/or modify "+
    "it under the terms of the GNU General Public License as published by "+
    "the Free Software Foundation, either version 3 of the License, or "+
    "(at your option) any later version.\n"+
    " \n"+
    "This program is distributed in the hope that it will be useful, "+
    "but WITHOUT ANY WARRANTY; without even the implied warranty of "+
    "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the "+
    "GNU General Public License for more details.\n"+
    " \n"+
    "You should have received a copy of the GNU General Public License "+
    "along with this program.  \nIf not, see http://www.gnu.org/licenses/");
  surface.setIcon(checkmark);
  histwindow.getSurface().setIcon(checkmark);
  fluxdetail.getSurface().setIcon(checkmark);
  diskwindow.getSurface().setIcon(checkmark);
  diskInfo(true);
}

void grid(PGraphics thisGrid, int side)
{
  int x = 16;
  int y = 16;
  thisGrid.beginDraw();
  thisGrid.background(230);
  thisGrid.stroke(0);
  thisGrid.textSize(14);
  thisGrid.textAlign(CENTER, CENTER);
  int size = 16;
  for (int i = 0; i<9; i++) {
    for (int j = 0; j<10; j++) {
      if ((j+i*10)*2+side>167) break;
      if (i==0) {
        thisGrid.fill(0, 0, 0);
        thisGrid.text(j, x+size/2+j*size, y-size/2-2);
        thisGrid.fill(255, 255, 255);
      }
      thisGrid.fill(trackmap[(j+i*10)*2+side]);
      //println(j+i*10);
      thisGrid.rect(x+j*size, y+i*size, size, size, 3);
      if (weak[(j+i*10)*2+side]>0) {
        thisGrid.fill(0, 0, 0);
        thisGrid.textSize(10);
        thisGrid.text(""+weak[(j+i*10)*2+side], x+j*size+size/2, y+i*size+size/2-1);
        thisGrid.textSize(14);
      }
      thisGrid.fill(255, 255, 255);
    }
    thisGrid.fill(0, 0, 0);
    thisGrid.text(i, x-size/2, size+y-size/2+i*size);
    thisGrid.fill(255, 255, 255);
  }
  if (focusTrack!=-1 & focusTrack%2==side) {
    int tempx = (focusTrack/2)%10;
    int tempy = (focusTrack/2)/10;
    thisGrid.strokeWeight(focusStroke);
    thisGrid.fill(trackmap[focusTrack]);
    //println(j+i*10);
    thisGrid.rect(x+tempx*size, y+tempy*size, size, size, 3);
    thisGrid.fill(0, 0, 0);
    thisGrid.textSize(10);
    thisGrid.text(""+weak[focusTrack], x+tempx*size+size/2, y+tempy*size+size/2-1);
    thisGrid.fill(255, 255, 255);
  }
  thisGrid.strokeWeight(1);
  thisGrid.textSize(14);
  thisGrid.fill(0, 0, 0);
  if (side==0) {
    thisGrid.text("Upper Side", x+7*size, y+9*size);
  } else {
    thisGrid.text("Lower Side", x+7*size, y+9*size);
  }
  thisGrid.fill(255, 255, 255);
  thisGrid.endDraw();
}

void drawBitmap(PGraphics tP, boolean empty)
{
  tP.beginDraw();
  if (empty) {
    tP.fill(255, 255, 255, 255);
    tP.noStroke();
    tP.rect(0, 0, 159, 44);
    tP.fill(0, 255, 0, 255);
  } else
  {
    tP.noStroke();
    for (int i = 0; i<bitMapSize; i++)
    {
      if (bitMapArray[i] == 0) tP.fill(255, 0, 0);
      else tP.fill(0, 255, 0);
      if (bitMapSize==1760) tP.rect(i/22*2, (i%22)*2, 2, 2);
      else tP.rect(i/44*2, i%44, 2, 1);
    }
  }
  tP.endDraw();
}

void drawProgress(PGraphics tP, int i)
{
  tP.beginDraw();
  tP.fill(255, 255, 255, 255);
  tP.noStroke();
  tP.rect(0, 0, 159, 9);
  tP.fill(0, 255, 0, 255);
  tP.noStroke();
  tP.rect(0, 0, i, 9);
  tP.endDraw();
}

void drawActive(PGraphics tP, int i)
{
  ReadPanel.moveTo(2000, -20);
  WritePanel.moveTo(2000, -20);
  SCPPanel.moveTo(2000, -20);
  startEndPanel.moveTo(2000, 20);
  UtilityPanel.moveTo(2000, -20);
  SettingsPanel.moveTo(2000, 10);
  /*
  ReadPanel.setVisible(false);
   WritePanel.setVisible(false);
   UtilityPanel.setVisible(false);
   SettingsPanel.setVisible(false);
   */
  switch (i) {
  case 0:
    ReadPanel.setVisible(true);
    ReadPanel.moveTo(120, -20);
    break;
  case 1:
    WritePanel.setVisible(true);
    WritePanel.moveTo(120, -20);
    break;
  case 2:
    SCPPanel.setVisible(true);
    SCPPanel.moveTo(120, -20);
    starttrack.setText(""+scpStart);
    endtrack.setText(""+scpEnd);
    starttrack.setTextBold();
    endtrack.setTextBold();
    if (scpEnd>79) endtrack.setLocalColor(6, color(255, 255, 0)); //background
    else endtrack.setLocalColor(6, color(255, 255, 255)); //background
    startEndPanel.moveTo(PlaceholderSCP.getX()+120, PlaceholderSCP.getY()-20);
    break;
  case 3:
    UtilityPanel.setVisible(true);
    UtilityPanel.moveTo(120, -20);
    starttrack.setText(""+utilStart);
    endtrack.setText(""+utilEnd);
    starttrack.setTextBold();
    endtrack.setTextBold();
    if (utilEnd>79) endtrack.setLocalColor(6, color(255, 255, 0)); //background
    else endtrack.setLocalColor(6, color(255, 255, 255)); //background
    startEndPanel.moveTo(PlaceholderU.getX()+120, PlaceholderU.getY()-20);
    break;
  case 4:
    SettingsPanel.setVisible(true);
    SettingsPanel.moveTo(120, 10);
    break;
  default:
  }
  if (i>=0 ) activePanel = i;
  tP.beginDraw();
  tP.clear();
  tP.fill(0, 0, 255, 128);
  tP.noStroke();
  if (i>=0) tP.rect(0, 0+(40*i), 20, 30, 0, 5, 5, 0);
  tP.endDraw();
}

void drawStatus(PGraphics tS, String text)
{
  if (text==null) text="Unknown Error";
  tS.beginDraw();
  tS.background(255);
  tS.textFont(myPFont);
  //  tS.textSize(12);
  tS.fill(0);
  tS.text(text, 2, 15);
  tS.endDraw();
}

void drawLogo(PGraphics tL)
{
  PImage img;
  PImage img2;
  int waitCounter = 0;
  surface.setTitle(version+": Loading Logo");
  img = null;
  while (img == null) {
    img = loadImage("logoblau.jpg");
    waitCounter++;
    if (img == null) delay(1000);
    if (waitCounter==10) {
      showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Unable to load Logo image");
      System.exit(0);
    }
  }
  waitCounter = 0;
  surface.setTitle(version+": Loading GPL-Logo");
  img2 = null;
  while (img2 == null) {
    img2 = loadImage("gplv3.png");
    waitCounter++;
    if (img2 == null) delay(1000);
    if (waitCounter==10) {
      showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Unable to load GPL image");
      System.exit(0);
    }
  }
  tL.beginDraw();
  //tL.background(255);
  tL.image(img, 0, 0);
  tL.image(img2, 70, 97, 100, 30);
  tL.textSize(14);
  tL.textAlign(CENTER, CENTER);
  tL.fill(255);
  tL.text(version, 35, 115);
  tL.fill(0, 0, 0, 0);
  tL.stroke(230);
  tL.strokeWeight(4);
  tL.rect(-1, -1, 172, 129, 10);
  tL.endDraw();
}

void drawFlux(PGraphics tF, boolean HDImage)
{
  int offset = 3*12;
  tF.beginDraw();
  tF.background(230);
  long tHist;
  tF.fill(0, 102, 153);
  tF.stroke(0, 0, 0);
  tF.line(29, 331, 350, 331);
  tF.line(29, 331, 29, 28);
  tF.textSize(20);
  tF.textAlign(RIGHT, CENTER);
  tF.text("µs", 40, 400-2*199);
  tF.line(24, 401-2*192+offset, 34, 401-2*192+offset);
  tF.line(24, 401-2*144+offset, 34, 401-2*144+offset);
  tF.line(24, 401-2*96+offset, 34, 401-2*96+offset);
  if (HDImage) {
    tF.text("4", 20, 400-2*192+offset);
    tF.text("3", 20, 400-2*144+offset);
    tF.text("2", 20, 400-2*96+offset);
  } else {
    tF.text("8", 20, 400-2*192+offset);
    tF.text("6", 20, 400-2*144+offset);
    tF.text("4", 20, 400-2*96+offset);
  }
  tF.textAlign(CENTER, CENTER);
  tF.text("0", 30, 340);
  tF.text("40", 180, 340);
  tF.text("79", 340, 340);
  //rect(40, 360, 320, 280, 7);
  for (int j =0; j<160; j++) {
    if (weak[j]>0) {
      if (weak[j]==25) {
        tF.stroke(255, 0, 0);
      } else {
        tF.stroke(180, 180-weak[j]*30, 180);
      }
      tF.line(30+j*2, 330, 30+j*2, 30);
    }
    for (int i = 50; i<200; i++) {
      tHist=hist[j][i];
      if (tHist>0) {
        tF.stroke(tHist/2, tHist/8, tHist/64);
        tF.rect(30+j*2, 400-i*2+offset, 1, 1);
        //        point(40+j*2, 240+i*2);
        //        point(40+j*2+1, 240+i*2);
      }
    }
  }
  tF.endDraw();
}

void drawCells(PGraphics tF, int track, boolean HDImage)
{
  if (!showflux) return;
  if (track<0 | track>167) return;
  tF.beginDraw();
  tF.background(230);
  int xoff = 15;
  int yoff = 50;
  int ysize = 360;
  int xsize = 800;
  int xfactor = 200000000/xsize;
  int yfactor = 40;
  int ystart = 1;
  tF.noFill();
  tF.stroke(0, 0, 0);
  tF.strokeWeight(1);
  tF.textSize(10);
  tF.textAlign(CENTER, CENTER);
  for (int i = 0; i<=200; i+=10) {
    tF.fill(0, 102, 153);
    tF.text(""+i, i*4+xoff, ysize+yoff+10);
    tF.stroke(0xffbbbbbb);
    tF.line(i*4+xoff, ysize+yoff, i*4+xoff, yoff);
    tF.stroke(0, 0, 0);
    tF.line(i*4+xoff, ysize+yoff, i*4+xoff, ysize+yoff-5);
    tF.stroke(0, 0, 0);
  }
  for (int i = ystart; i<=10; i++) {
    tF.fill(0, 102, 153);
    tF.text(""+i, xoff/2, ysize+yoff+ystart*yfactor-i*yfactor);
    //println(""+ i + ": " + (ysize+yoff+ystart*yfactor-i*yfactor));
    tF.stroke(0xffbbbbbb);
    tF.line(xoff, ysize+yoff+ystart*yfactor-i*yfactor, xsize+xoff, ysize+yoff+ystart*yfactor-i*yfactor);
    if (i!=ystart)
      tF.line(xoff, ysize+yoff+ystart*yfactor+0.5f*yfactor-i*yfactor, xsize+xoff, ysize+yoff+ystart*yfactor+0.5f*yfactor-i*yfactor);
    tF.stroke(0, 0, 0);
    tF.line(xoff, ysize+yoff+ystart*yfactor-i*yfactor, xoff+5, ysize+yoff+ystart*yfactor-i*yfactor);
    tF.stroke(0, 0, 0);
  }
  tF.noFill();
  tF.stroke(0, 0, 0);
  tF.rect(xoff, yoff, xsize, ysize, 1);
  int rev = revcurrent;
  int fluxpos = 0;
  int tCell = 0;
  tF.stroke(0, 0, 200);
  int tZeit = millis();
  tF.textAlign(CENTER, CENTER);
  tF.endDraw();

  final int[] p = tF.pixels;
  if (p == null)
  {
    println("pixels: null");
    return;
  }
  noLoop();
  int minFlux = 10000;
  int maxFlux = 0;
  int fluxcount = 0;
  int t3 = 0;
  //for (int i = 0; i<revsInBuffer; i++)
  //{
  //  print("rp["+i+"]: " + revpointer[track][i]);
  //  println(" len: " + (revpointer[track][i+1]-revpointer[track][i]));
  //}
  for (int i = revpointer[track][rev]; i < revpointer[track][rev+1]; i+=2)
  {
    tCell = (((int)bytebuffer[track][i]<<8) + ((int)bytebuffer[track][i+1] & 0xff) & 0xffff)*25; //tCell in nanoseconds
    if (tCell == 0) {
      t3 += 0x10000*25;
      print(".");
    } else {
      tCell = tCell + t3;
      t3 = 0;
      maxFlux = max(maxFlux, tCell);
      minFlux = min(minFlux, tCell);
      if ((tCell>1000) && (tCell<10000)) {
        int x = xoff + (fluxpos/250000);
        int y = ysize + yoff + yfactor - tCell/25;
        int pixel = x + y * tF.width;
        if ((pixel<p.length) && (pixel >=0))
          p[pixel] = color(0, 0, 200);
        fluxcount++;
      } else
      {
        int x = 15+(fluxpos/250000);
        int y = yoff;
        for (int j = 0; j<10; j++)
          p[x+y*tF.width + j*tF.width]=color(255, 0, 0);
      }
      //      tF.point(xoff+(fluxpos/xfactor), ysize+yoff+ystart*yfactor-((float)(tCell*yfactor)/1000));
      fluxpos = fluxpos + tCell;
    }
  }
  //println(fluxpos);
  tF.updatePixels();
  loop();
  if (revpointer[track][rev+1]>0)
  {
    decode2mfm(track, rev, true);
    //    decodeTrack(track, sectorCnt);
  }
  String fluxrange;
  if (minFlux<maxFlux)
    fluxrange = String.format ("%.2f", (float)minFlux/1000) + " - " + String.format ("%.2f", (float)maxFlux/1000);
  else
    fluxrange = "none";
  tF.beginDraw();
  tF.strokeWeight(1);
  for (int i = 0; i<sectorCnt; i++)
  {
    //tF.strokeWeight(0);
    //tF.noStroke();
    //tF.fill(0,200,0);
    //tF.rect(15+((sectorTable[i].streamPos+28*8*4000)/250000), yoff, (512*8*4000/250000), ysize);
    tF.stroke(200, 0, 0);
    tF.noFill();
    tF.line(15+(sectorTable[i].streamPos/250000), yoff, 15+(sectorTable[i].streamPos/250000), yoff+ysize);
  }
  tF.strokeWeight(1);
  tF.textSize(14);
  tF.fill(0, 50, 200);
  tF.textAlign(LEFT, TOP);
  tF.text("Rev " + (rev+1) + " / " + revsInBuffer + " - Track " + track/2 + "." + track%2 + 
    " - Fluxrange: " + fluxrange + " - Flux count: " + fluxcount + " Sectormarks: " + sectorCnt, 
    xoff+50, 10);

  tF.endDraw();
  //println("drawtime: " + (millis()-tZeit));
  lastTrack = track;
}

void drawDisk()
{
  int magic4489 = 0;
  int amigasectors = 0;
  int xsize = 400;
  int ysize = 400;
  int diameter = 390;
  int rev = revcurrent;
  float scale = 3.0f;
  float stroke = 2.0f;
  int outerTrack = 86;
  int hub = 90;
  PGraphics side; 
  float header, data, end;
  diskside0.beginDraw();
  diskside1.beginDraw();
  diskside0.background(0);
  diskside1.background(0);
  //outside circle of disk
  diskside0.fill(100, 100, 100);
  diskside1.fill(100, 100, 100);
  diskside0.noStroke();
  diskside1.noStroke();
  diskside0.circle(xsize/2, ysize/2, diameter+10); 
  diskside1.circle(xsize/2, ysize/2, diameter+10);
  //magnetic surface
  diskside0.fill(50, 50, 50);
  diskside1.fill(50, 50, 50);
  diskside0.circle(xsize/2, ysize/2, diameter); 
  diskside1.circle(xsize/2, ysize/2, diameter);
  //non magnetic inner ring
  diskside0.stroke(0, 0, 0);
  diskside1.stroke(0, 0, 0);
  diskside0.strokeWeight(2);
  diskside1.strokeWeight(2);
  diskside0.fill(100, 100, 100);
  diskside1.fill(100, 100, 100);
  diskside0.circle(xsize/2, ysize/2, diameter-(outerTrack)*scale);
  diskside1.circle(xsize/2, ysize/2, diameter-(outerTrack)*scale);
  //diskhub
  diskside0.fill(255, 255, 255);
  diskside1.fill(255, 255, 255);
  diskside0.circle(xsize/2, ysize/2, hub);
  diskside1.circle(xsize/2, ysize/2, hub);
  //index hole
  diskside0.circle(xsize/2+((diameter-(outerTrack)*scale)+hub)/4, ysize/2, 10);
  diskside1.circle(xsize/2+((diameter-(outerTrack)*scale)+hub)/4, ysize/2, 10);
  //diskside0.circle(xsize/2+(111/2), ysize/2, 10);
  //diskside1.circle(xsize/2+(111/2), ysize/2, 10);

  diskside0.strokeWeight(2);
  diskside1.strokeWeight(2);
  for (int i = 0; i<168; i++) {
    if (revpointer[i][rev+1]>0)
    {
      magic4489 = decode2mfm(i, rev, true);
      amigasectors = decodeTrack(i, sectorCnt, true);
    } else continue;
    if (i%2==0) side = diskside0;
    else side = diskside1;
    if (magic4489 == 0)
    {
      side.noFill();
      //side.stroke(180, 180, 180);
      //side.strokeWeight(3);
      //side.arc(xsize/2, ysize/2, diameter-(i/2)*scale, diameter-(i/2)*scale, 0, 2*PI);
      side.stroke(255, 0, 0);
      side.strokeWeight(stroke);
      side.arc(xsize/2, ysize/2, diameter-(i/2)*scale, diameter-(i/2)*scale, 0, 2*PI);
    } else
    {
      side.noFill();
      side.stroke(0, 0, 255);
      side.strokeWeight(stroke);
      //side.arc(xsize/2, ysize/2, diameter-(i/2)*scale, diameter-(i/2)*scale, 0, 2*PI);
      for (int j = 0; j<magic4489; j++)
      {
        side.noFill();
        header = ((float)sectorTable[j].streamPos/100000000f)*PI;
        data = header + ((float)(28f*8f*4000f/100000000f))*PI;
        end = data + ((float)(512f*8f*4000f/100000000f))*PI;
        //println("track: " + i + " sect: " + j + " start: "+header+" end: "+end);
        //tF.line(15+(sectorTable[i].streamPos/250000), yoff, 15+(sectorTable[i].streamPos/250000), yoff+ysize);
        //side.strokeWeight(3);
        //side.stroke(180, 180, 180);
        //side.arc(xsize/2, ysize/2, diameter-(i/2)*scale, diameter-(i/2)*scale, 2*PI-end, 2*PI-header);
        side.strokeWeight(stroke);
        if (sectorTable[j].hcs_ok == true)
          side.stroke(255, 255, 0);
        else
          side.stroke(255, 128, 0);
        side.arc(xsize/2, ysize/2, diameter-(i/2)*scale, diameter-(i/2)*scale, 2*PI-data, 2*PI-header);
        if (sectorTable[j].dcs_ok == true)
          side.stroke(0, 255, 0);
        else
          side.stroke(255, 0, 0);
        side.arc(xsize/2, ysize/2, diameter-(i/2)*scale, diameter-(i/2)*scale, 2*PI-end, 2*PI-data);
      }
    }
  }
  diskside0.strokeWeight(2);
  diskside1.strokeWeight(2);
  diskside0.stroke(0, 0, 200);

  diskside0.line(xsize/2+(diameter-(outerTrack)*scale)/2, ysize/2, xsize-6, ysize/2);
  diskside1.stroke(0, 0, 200);
  diskside1.line(xsize/2+(diameter-(outerTrack)*scale)/2, ysize/2, xsize-6, ysize/2);
  diskside0.endDraw();
  diskside1.endDraw();
}

// Calculates the base-10 logarithm of a number
float log10 (float x) {
  return (log(x) / log(10));
}

void drawHist(PGraphics tF, int track)
{
  if (!showhist) return;
  if (track<0 | track>167) return;
  int xoff = 50;
  int yoff = 10;
  int ysize = 110;
  int xsize = 540;
  int xfactor = xsize/9;
  int yfactor = 40;
  int xscale = 1;
  int ystart = 1;
  tF.beginDraw();
  tF.background(230);
  long tHist;
  tF.noFill();
  tF.stroke(#bbbbbb);
  tF.rect(xoff, yoff, xsize, ysize, 1);
  tF.stroke(0, 0, 0);
  tF.line(xoff, yoff+ysize, xoff+xsize, yoff+ysize);
  tF.line(xoff, yoff+ysize, xoff, yoff);
  tF.fill(0, 102, 153);

  tF.textSize(10);
  tF.textAlign(CENTER, TOP);
  if (histResHD) {
    for (int i = 2; i<11; i+=2) {
      tF.text(""+i/2, (i-1)*xfactor+xoff, ysize+yoff-1);
      tF.stroke(#bbbbbb);
      tF.line((i-1)*xfactor+xoff, yoff+ysize, (i-1)*xfactor+xoff, yoff);
      tF.stroke(0, 0, 0);
      tF.line((i-1)*xfactor+xoff, yoff+ysize, (i-1)*xfactor+xoff, ysize+yoff/2);
    }
  } else
  {
    for (int i = 2; i<11; i++) {
      tF.text(""+i, (i-1)*xfactor+xoff, ysize+yoff-1);
      tF.stroke(#bbbbbb);
      tF.line((i-1)*xfactor+xoff, yoff+ysize, (i-1)*xfactor+xoff, yoff);
      tF.stroke(0, 0, 0);
      tF.line((i-1)*xfactor+xoff, yoff+ysize, (i-1)*xfactor+xoff, ysize+yoff/2);
    }
  }
  tF.textAlign(CENTER, CENTER);
  //if (histResHD) tF.text("HD", 20, 60);
  //else tF.text("DD", 20, 60);
  //tF.text("6000", 20, 50);
  //rect(40, 360, 320, 280, 7);
  boolean logScale = logcb.isSelected();
  float scale = 1;
  long tMax = (findMax(track)/1000+1)*1000;
  if (tMax == 0) tMax = 10000;
  if (tMax!=0)
  {
    if (logScale) scale = ysize/(float)log10(tMax);
    else scale = (float)ysize/tMax;
  } else scale = 1;
  if (!logScale) {
    tF.text(""+tMax, xoff/2, yoff);
    tF.line(xoff, yoff, xoff+5, yoff);
    tF.text(""+tMax/2, xoff/2, yoff+ysize/2);
    tF.stroke(#bbbbbb);
    tF.line(xoff, yoff+ysize/2, xoff+xsize, yoff+ysize/2);
    tF.stroke(0, 0, 0);
    tF.line(xoff, yoff+ysize/2, xoff+5, yoff+ysize/2);
  } else {
    tF.text(""+tMax, xoff/2, yoff);
    //tF.text(""+tMax/10, xoff/2, ysize+yoff-log10(tMax/10)*scale);
    tF.text("10", xoff/2, ysize+yoff-log10(10)*scale);
    tF.text("100", xoff/2, ysize+yoff-log10(100)*scale);
    tF.text("1000", xoff/2, ysize+yoff-log10(1000)*scale);
    tF.stroke(#bbbbbb);
    tF.line(xoff, yoff, xoff+5, yoff);
    tF.line(xoff, ysize+yoff-log10(10)*scale, xoff+xsize, ysize+yoff-log10(10)*scale);
    tF.line(xoff, ysize+yoff-log10(100)*scale, xoff+xsize, ysize+yoff-log10(100)*scale);
    tF.line(xoff, ysize+yoff-log10(1000)*scale, xoff+xsize, ysize+yoff-log10(1000)*scale);
    tF.stroke(0, 0, 0);
    tF.line(xoff, ysize+yoff-log10(10)*scale, xoff+5, ysize+yoff-log10(10)*scale);
    tF.line(xoff, ysize+yoff-log10(100)*scale, xoff+5, ysize+yoff-log10(100)*scale);
    tF.line(xoff, ysize+yoff-log10(1000)*scale, xoff+5, ysize+yoff-log10(1000)*scale);
  }
  //println(scale);
  tF.fill(#e86100);
  tF.stroke(#222222);
  tF.beginShape();
  //tF.vertex(24*4-96+50, 170);
  //tF.vertex(24*4-96+50, 170);
  tF.vertex(xoff, ysize+yoff);
  tF.vertex(xoff, ysize+yoff);
  //1µs = 24 ticks
  float ticksize = xfactor/24f;
  for (int i = 24; i<241; i++) {
    tHist=hist[track][i];
    if (tHist<2)
    {
      tF.vertex((i-24)*ticksize+xoff, ysize+yoff);
    } else {
      if (logScale) tF.curveVertex((i-24)*ticksize+xoff, ysize+yoff-log10(tHist)*scale);
      else tF.curveVertex((i-24)*ticksize+xoff, ysize+yoff-tHist*scale);
    }
  }
  tF.vertex((240-24)*ticksize+xoff, ysize+yoff);
  tF.vertex((240-24)*ticksize+xoff, ysize+yoff);
  tF.vertex((24-24)*ticksize+xoff, ysize+yoff);

  tF.endShape();
  tF.endDraw();
  lastTrack = track;
}

void enableButton(GImageButton button)
{
  button.setEnabled(true);
  button.setAlpha(255);
}

void disableButton(GImageButton button)
{
  button.setEnabled(false);
  button.setAlpha(50);
}

void disableButtons()
{
  if (myPort!=null) enableButton(Abort);
  disableButton(ReadButton);
  disableButton(WriteButton);
  disableButton(SCPButton);
  disableButton(UtilityButton);
  disableButton(SettingsButton);
  disableButton(About);
  disableButton(Init);
  disableButton(GetDiskInfo);

  disableButton(ReadDisk);
  disableButton(compareDisk);
  disableButton(AutoRip);
  disableButton(StartRead);

  disableButton(WriteDisk);
  disableButton(AutoWrite);
  disableButton(StartWrite);

  disableButton(ReadSCP);
  disableButton(WriteSCP);
  disableButton(scanDisk);

  disableButton(Format);
  disableButton(AutoFormat);
  disableButton(Erase);
  disableButton(Cleaning);
  dropList2.setEnabled(false);
  dropList2.setAlpha(50);
}

void enableButtons(boolean read, boolean write)
{
  if (myPort==null) {
    enableButton(ReadButton);
    enableButton(WriteButton);
    enableButton(SCPButton);
    enableButton(UtilityButton);
    enableButton(SettingsButton);
    enableButton(About);
    disableButton(Abort);
  } else
  {
    disableButton(Abort);
    enableButton(ReadButton);
    enableButton(WriteButton);
    enableButton(SCPButton);
    enableButton(UtilityButton);
    enableButton(SettingsButton);
    enableButton(About);
    enableButton(GetDiskInfo);
    enableButton(Init);

    enableButton(ReadDisk);
    enableButton(compareDisk);
    enableButton(AutoRip);
    if (read) enableButton(StartRead);
    else disableButton(StartRead);

    enableButton(WriteDisk);
    enableButton(AutoWrite);
    if (write) enableButton(StartWrite);
    else disableButton(StartWrite);

    if (write_SCP) enableButton(WriteSCP);
    if (scpMode) enableButton(ReadSCP);
    if (scpMode) enableButton(scanDisk);

    enableButton(Format);
    enableButton(AutoFormat);
    enableButton(Cleaning);
    enableButton(Erase);
    dropList2.setEnabled(true);
    dropList2.setAlpha(255);
  }
}

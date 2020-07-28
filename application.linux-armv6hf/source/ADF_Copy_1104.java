import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.io.DataOutputStream; 
import java.io.BufferedOutputStream; 
import java.io.FileOutputStream; 
import java.io.RandomAccessFile; 
import java.util.Arrays; 
import java.util.List; 
import java.util.Map; 
import java.util.Date; 
import java.awt.*; 
import java.time.LocalDateTime; 
import java.sql.Timestamp; 
import java.time.Year; 
import javax.swing.*; 
import processing.serial.*; 
import g4p_controls.*; 
import static javax.swing.JOptionPane.*; 
import jssc.*; 
import java.io.File; 
import org.ini4j.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ADF_Copy_1104 extends PApplet {

/*    
 ADF-Copy Frontend - Copyright (C) 2016-2020 Dominik Tonn (nick@niteto.de)
 visit http://nicklabor.niteto.de for Infos and Updates
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/* additional code for OSX Serialport by Christian Vogelgsang */

boolean HD_allowed = true;
boolean write_SCP = false; //at the moment there is no write function
boolean scpMode = true;

String version = "v1.104 Beta";
Float minVer = 1.050f;
String firmware = "unknown";
//import com.fazecast.jSerialComm.*;



//import java.io.IOException;











String fileName = "test.adf"; // fill in
String filePath = "";
String diskName = "ADF-Copy";
String iniFile = "";







int bgcolor;			     // Background color
int fgcolor;			     // Fill color
Serial myPort;                       // The serial port
byte[] readString = new byte[512*11];
long errormap[] = new long[168];
byte bitMapArray[] = new byte[2*1760];
int bitMapSize = 0;
volatile int trackmap[] = new int[168]; 
int weak[] = new int[168];
boolean abort = false;
String extError;
int lf = 10;
byte track[] = new byte[512*22];
//byte stream[] = new byte[23*1088+1482];
byte trackComp[] = new byte[512*22];
long hist[][] = new long [168][256];
int indexes[][] = new int [10][4];
byte bytebuffer[][] = new byte [168][1000001];
int revpointer[][] = new int [168][10];
int revsInBuffer = 0;
int revcurrent = 0;
boolean histResHD = false;

boolean verify = false;

PImage checkmark;
PImage disk;
boolean diskChange = false;
boolean autoFormatDisks = false;
boolean preErase = true;
boolean indexAligned = false;
boolean scanonly = false;
int k = 0;
boolean ignoreChksumErr = true;
int mode = 0; // 0 = DD, 1 = HD
String pName;
String fileSep;
long motorSpinupDelay;
long motorSpindownDelay;
long driveSelectDelay;
long driveDeselectDelay;
long setDirDelay;
long setSideDelay;
long stepDelay;
long stepSettleDelay;
long gotoTrackSettle;

int activePanel = -1;

int focusTrack = -1;
int lastTrack = -1;

Font myFont = null;
String myFontName = "RobotoCondensed-Regular.ttf";
//String myFontName = "IndieFlower.ttf";
Float myFontSize = 13.0f;
PFont myPFont = null;



boolean savelog = true;
boolean savejpg = true;
int posx = 0;
int posy = 0;
boolean showhist = true;
boolean showflux = true;
boolean showdisk = true;
int utilStart = 0;
int utilEnd = 79;
int scpStart = 0;
int scpEnd = 81;
int focusStroke = 2;
int maxSectors = 100;
class SectorTable
{
  public int bytePos;
  public int streamPos;
  public int sector;
  public boolean hcs_ok;
  public boolean dcs_ok;
  public boolean sector_valid;
};
SectorTable sectorTable[] = new SectorTable[maxSectors];

class Sector
{
  public byte format_type; 
  public byte track; 
  public byte sector; 
  public byte toGap;
  public byte[] os_recovery;
  public int header_chksum;
  public int data_chksum;
  public byte[] data;
}
Sector extTrack[] = new Sector[maxSectors];

public boolean loadIni(String iniFile)
{
  try {
    Wini ini = new Wini(new File(iniFile));
    savelog = ini.get("readdisk", "log", boolean.class);
    savejpg = ini.get("readdisk", "jpg", boolean.class);
    posx = ini.get("window", "posx", int.class);
    posy = ini.get("window", "posy", int.class);
    showhist = ini.get("window", "showhist", boolean.class);
    showflux = ini.get("window", "showflux", boolean.class);
    showdisk = ini.get("window", "showdisk", boolean.class);
    fileName = ini.get("file", "fileName", String.class); 
    filePath = ini.get("file", "filePath", String.class); 

    //System.out.print("savelog: " + savelog + "\n");
    //System.out.print("savejpg: " + savejpg + "\n");
    //System.out.print("Windows pos: " + posx + "," + posy + "\n");
    //System.out.print("Show Hist: " + showhist + "\n");
    //System.out.print("Show Flux: " + showflux + "\n");
    //System.out.print("Show Disk: " + showdisk + "\n");
    //System.out.print("fileName: " + fileName + "\n");
    //System.out.print("filePath: " + filePath + "\n");
  }
  catch(Exception e) {
    System.err.println("adf-copy.ini not found, creating default ini file.");
    return false;
  }
  return true;
}

public boolean saveIni(String iniFile)
{
  try {
    File f = new File(iniFile);
    if (!f.exists()) {
      //      f.getParentFile().mkdirs();
      f.createNewFile();
    }    
    Wini ini = new Wini(f);
    ini.put("ADF-Copy", "version", version);
    ini.put("readdisk", "log", savelog);
    ini.put("readdisk", "jpg", savejpg);
    java.awt.Frame myFrame =  (java.awt.Frame) ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame();
    ini.put("window", "posx", myFrame.getX());
    ini.put("window", "posy", myFrame.getY());
    ini.put("window", "showhist", showhist);
    ini.put("window", "showflux", showflux);
    ini.put("window", "showdisk", showdisk);
    ini.put("file", "fileName", fileName); 
    ini.put("file", "filePath", filePath);
    ini.store();
  }
  catch(Exception e) {
    System.err.println(e.getMessage());
    return false;
  }
  return true;
}

public void exit() {
  if (myPort!=null) {
    myPort.write("nobusy\n");
    myPort.write("mtp\n");
    myPort.clear();
  }
  saveIni(iniFile);
  println("exiting program...");
  super.exit();
}

public String iniPath () { 
  String pathName; // path to create new file
  pathName = getClass().getProtectionDomain().getCodeSource().getLocation().getPath(); // get the path of the .jar
  pathName = pathName.substring(1, pathName.lastIndexOf("/") ); //create a new string by removing the garbage
  //  System.out.println(pathName); // this is for debugging - see the results
  return pathName;
}

public void setup() {
    // Stage size
  //size(1200, 720, JAVA2D);  // Stage size
  println("\n------------------------------------------------------------");
  println("ADF-Copy App - Frontend to Read and Write Amiga Floppy Disks");
  println("Copyright (C) 2020 Dominik Tonn (nick@niteto.de)");
  println("visit http://nicklabor.niteto.de for Infos and Updates");
  println("------------------------------------------------------------\n");
  java.awt.Frame f =  (java.awt.Frame) ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame();
  f.setSize(600, 580);
  iniFile = iniPath() + "/adf-copy.ini";
  if (iniFile.contains("temp")) {
    println("running in IDE, using sketchPath as ini file location");
    iniFile = sketchPath("adf-copy.ini");
  }
  //println(iniFile);
  if (!loadIni(iniFile)) {
    f.setLocation(posx, posy);    
    saveIni(iniFile);
  }
  //  saveIni(iniFile);
  f.setLocation(posx, posy);
  int discard, major, minor, update, build;

  println("Java: " + System.getProperty("java.runtime.version"));
  println("Java: " + System.getProperty("java.awt.version"));
  String[] javaVersionElements = System.getProperty("java.runtime.version").split("\\.|_|\\+|-|-b");
  major   = Integer.parseInt(javaVersionElements[1]);
  minor   = Integer.parseInt(javaVersionElements[2]);
  update  = Integer.parseInt(javaVersionElements[3]);
  println(System.getProperty("java.vendor"));
  if (!System.getProperty("java.vendor").contains("Oracle"))
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "This application is tested with Oracle Java, other Vendors may cause Problems\n" +
      "Consider using Oracle Java Version 8 if you experience problems.", 
      "Current Java Version "+System.getProperty("java.runtime.version")+".", INFORMATION_MESSAGE);
  else
  {
    boolean javaWarn = false;
    if (major!=8) javaWarn = true;
    if ((minor==0)&&(update<200))javaWarn = true;
    if (javaWarn) showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "This application requires Java Version 8 Update 2xx or later.\n" +
      "Consider updating your Java to newest Version 8 if you experience problems.", 
      "Current Java Version "+System.getProperty("java.runtime.version")+".", INFORMATION_MESSAGE);
  }
  
  for (int i = 0; i<168; i++) {
    trackmap[i]=0xffffffff;
  }
  for (int i =0; i<maxSectors; i++)
  {
    sectorTable[i] = new SectorTable();
    extTrack[i] = new Sector();
    extTrack[i].data = new byte[512];
    extTrack[i].os_recovery = new byte[16];
  }
  int waitCounter = 0;
  surface.setTitle(version+": Loading Checkmark Image");
  checkmark = null;
  while (checkmark == null) {
    checkmark = loadImage("checkmark.png");
    waitCounter++;
    if (checkmark == null) delay(1000);
    if (waitCounter==10) {
      showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Unable to load checkmark image");
      System.exit(0);
    }
  }
  waitCounter = 0;
  surface.setTitle(version+": Loading InsertDisk Image");
  disk = null;
  while (disk == null) {
    disk = loadImage("InsertDisk.png");
    waitCounter++;
    if (disk == null) delay(1000);
    if (waitCounter==10) {
      showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Unable to load InsertDisk image");
      System.exit(0);
    }
  }
  /*
  com.fazecast.jSerialComm.SerialPort comPort[] = com.fazecast.jSerialComm.SerialPort.getCommPorts();
   for (int i = 0; i<comPort.length; i++) {
   print(comPort[i].getDescriptivePortName());
   print(" - ");
   print(comPort[i].getSystemPortName());
   print("\n");
   }
   */
  firmware = "ADF-Drive/Copy hardware not found";
  float firmwareVersion = (float)9.999f;
  initSerial();
  if (myPort!=null)
  {
    myPort.write("init\n");
    delay(200);
    myPort.clear();
    while (myPort.available()!=0) {
      print(myPort.readChar());
      delay(10);
    }
    surface.setTitle(version+": Connecting to Hardware...");
    myPort.write("ver\n");
    int timeout = 40;
    while (myPort.available()==0) {
      delay(100);
      surface.setTitle(version+": Connecting to Hardware... "+timeout);
      timeout--;
      if (timeout<=0) {
        showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Communication timed out, please try again.", "Timeout", INFORMATION_MESSAGE);
        System.exit(0);
      }
    }
    myPort.clear();
    myPort.write("ver\n");
    while (myPort.available()==0) delay(100);
    firmware = myPort.readString();
    String tempVer = firmware.substring(firmware.lastIndexOf("Firmware v")+10);
    firmwareVersion = Float.valueOf(tempVer.substring(0, tempVer.indexOf(" ")));
    if (firmware.contains("Breadboard")) {
      println("SCP Functions only available with PCB v2 or better");
      showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), 
        "SCPMode only available with PCB v2 or better", "Breadboard detected", INFORMATION_MESSAGE);
      scpMode = false;
    }
  }
  surface.setTitle(version+": Creating GUI");
  setupGUI();
  if (firmwareVersion < minVer) showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "This application requires firmware " + String.format("%.3f", minVer) + " or later.", "Firmware", INFORMATION_MESSAGE);
  if (myPort==null) {
    disableButtons();
    enableButtons(false, false);
    enableButton(About);
  }
  if (scpMode==false) {
    disableButton(ReadSCP);
    disableButton(WriteSCP);
    disableButton(scanDisk);
  }
  sP1.setGraphic(upperGrid);
  sP2.setGraphic(lowerGrid);
  fluxPad.setGraphic(flux);
  histPad.setGraphic(histogram);
  cellPad.setGraphic(cellgraph);
  progressPad.setGraphic(progress);
  activePad.setGraphic(active);
  statusPad.setGraphic(status);
  DiskInfoPad.setGraphic(diskinfo);
  bitmapPad.setGraphic(bitmap);
  logoPad.setGraphic(logo);
  diskPad.setGraphic(diskImage);
  side0.setGraphic(diskside0);
  side1.setGraphic(diskside1);
  surface.setTitle("ADF-Copy "+version);
  background(230);
}

public void draw() {
  background(230);
  //surface.setTitle("ADF-Copy "+version);
  //background(230);
  //sP1.setGraphic(upperGrid);
  //sP2.setGraphic(lowerGrid);
  //fluxPad.setGraphic(flux);
  //histPad.setGraphic(histogram);
  //cellPad.setGraphic(cellgraph);
  //progressPad.setGraphic(progress);
  //activePad.setGraphic(active);
  //statusPad.setGraphic(status);
  //DiskInfoPad.setGraphic(diskinfo);
  //bitmapPad.setGraphic(bitmap);
  //logoPad.setGraphic(logo);
  //diskPad.setGraphic(diskImage);
  //sP1.draw();
  //sP2.draw();
  //fluxPad.draw();
  //progressPad.draw();
  //statusPad.draw();
  //DiskInfoPad.draw();
  //logoPad.draw();
  //histPad.draw();
  //cellPad.draw();
  //showhist = histwindow.isVisible();
  //showflux = fluxdetail.isVisible();
  //showdisk = diskwindow.isVisible();
  //showhist_.setSelected(showhist);
  //showflux_.setSelected(showflux);
  //showdisk_.setSelected(showdisk);
  if (focused) {
    ((processing.awt.PSurfaceAWT.SmoothCanvas)histwindow.getSurface().getNative()).getFrame().toFront();
    ((processing.awt.PSurfaceAWT.SmoothCanvas)fluxdetail.getSurface().getNative()).getFrame().toFront();
    ((processing.awt.PSurfaceAWT.SmoothCanvas)diskwindow.getSurface().getNative()).getFrame().toFront();
  }
}

public int gridClick(int side, int x, int y, int button)
{
  x=x/16;
  y=y/16;
  if (x<1 | x>10) return -1; 
  if (y<1 | y>9) return -1; 
  int trackClick = ((y-1)*10 + (x-1))*2 + side;
  if (trackClick > 167) return -1;
  println("Track: " + trackClick + " @ " + millis());
  return trackClick;
}

public void mouseReleased() {
  int x = mouseX;
  int y = mouseY;
  int button = mouseButton;
  int tempTrack = -1;
  //  println("X: " + x + " Y: " + y + " Button: " + button);
  if (((x > sP1.getX()) && (x < (sP1.getX()+sP1.getWidth()))) &&
    ((y > sP1.getY()) && (y < (sP1.getY()+sP1.getHeight()))))
    tempTrack = gridClick(0, (x-(int)sP1.getX()), (y-(int)sP1.getY()), button);
  //println("sP1x: " + sP1.getX() + " y: " + sP1.getY() + " w: " + sP1.getWidth() + " h: " + sP1.getHeight() + " " + millis());  

  if (((x > sP2.getX()) && (x < (sP2.getX()+sP2.getWidth()))) &&
    ((y > sP2.getY()) && (y < (sP2.getY()+sP2.getHeight()))))
    //println("sP2x: " + sP2.getX() + " y: " + sP2.getY() + " w: " + sP2.getWidth() + " h: " + sP2.getHeight() + " " + millis());
    tempTrack = gridClick(1, (x-(int)sP2.getX()), (y-(int)sP2.getY()), button);
  if (tempTrack == -1) return;
  //  if (tempTrack!=-1) trackmap[tempTrack] = #ffffff - trackmap[tempTrack];
  if (tempTrack == focusTrack) focusTrack = -1;
  else focusTrack = tempTrack;
  if (focusTrack!=-1) {
    drawStatus(status, "Track: " + focusTrack+" Errors: "+parseError(errormap[focusTrack]));
    drawHist(histogram, focusTrack);
    drawCells(cellgraph, focusTrack, false);
    //for (int j = 0; j <= revsInBuffer; j++)
    //  println("revPointer["+ focusTrack +"]["+j+"]: " + revpointer[focusTrack][j]);
  } else drawStatus(status, "");
  grid(upperGrid, 0);
  grid(lowerGrid, 1);
}

public void compareSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    fileName=selection.getAbsolutePath();
    filePath=selection.getParent();
    filepathandname.setText(fileName);
    thread("compareDisk");
  }
}

public void readscp(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    //disableButton(StartRead);
  } else {
    println("User selected " + selection.getAbsolutePath());
    fileName=selection.getAbsolutePath();
    filePath=selection.getParent();
    if (!fileName.contains(".scp")) fileName +=".scp";
    filepathandname.setText(fileName);
    //enableButton(StartRead);
    thread("readscp_main");
  }
}

public void scandisk()
{
  scanonly = true;
  readscp_main();
  scanonly = false;
}

public void readSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    disableButton(StartRead);
  } else {
    println("User selected " + selection.getAbsolutePath());
    fileName=selection.getAbsolutePath();
    filePath=selection.getParent();
    filepathandname.setText(fileName);
    disableButton(StartWrite);
    enableButton(StartRead);
  }
}

public void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    filePath=selection.getAbsolutePath();
    filepathandname.setText(filePath);
    myPort.write("init\n");
    extError = getExtErr();
    if (!extError.contains("OK")) {
      drawStatus(status, "Drive Status: " + extError);
      showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
      enableButtons(false, true);
      return;
    }
    myPort.clear();
    thread("autoRip");
  }
}

public void writeSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    disableButton(StartWrite);
  } else {
    println("User selected " + selection.getAbsolutePath());
    fileName=selection.getAbsolutePath();
    filePath=selection.getParent();
    filepathandname.setText(fileName);
    disableButton(StartRead);
    enableButton(StartWrite);
  }
}
public String getExtErr()
{
  myPort.clear();
  myPort.write("exterr\n");
  while (myPort.available()==0) {
    delay(5);
  }
  return myPort.readString();
}

public String getSettings()
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

public String setSettings()
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

public String storeSettings()
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

public String resetSettings()
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

public void diskInfo(boolean blank)
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
public int probeDisk()
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


public int getMode()
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
public char byte2char(byte c) {
  if ((c < 32) | (c > 126)) {
    return (char) 46;
  } else {
    return (char) c;
  }
}
public void getWeak(int track)
{
  myPort.clear();
  myPort.write("weak\n");
  while (myPort.available()==0) {
    delay(5);
  }
  weak[track] = myPort.read();
  if (weak[track] > 2) {
    //    println("Track: "+track+" Retries: "+weak[track]);
    trackmap[track]=0xffffff00;
  } else {
    trackmap[track]=0xff00ff00;
  }
}

public void getFlux(int track)
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

public void getIndexes(int revs)
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
public void getBitmap()
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

public void getTracks()
{
  ignoreChksumErr=chkSumChk.isSelected();
  abort = false;
  disableButtons();
  for (int i = 0; i<168; i++)
  {
    weak[i]=0;
    errormap[i]=0;
    trackmap[i]=0xffffffff;
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
        trackmap[i]=0xffff0000;
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
      drawFlux(flux, HDImage);
      drawHist(histogram, i);
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

public void readscp_main()
{
  abort = false;
  disableButtons();
  histResHD = false;
  for (int i = 0; i<168; i++)
  {
    weak[i]=0;
    errormap[i]=0;
    trackmap[i]=0xffffffff;
    for ( int j=0; j<256; j++) {
      hist[i][j]=0;
    }
  }
  int start = PApplet.parseInt(starttrack.getText())*2;
  int stop = (PApplet.parseInt(endtrack.getText())+1)*2;
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
      trackmap[i]=0xff0000ff;
      drawProgress(progress, i);
      drawStatus(status, "Track: " + i+" Errors: "+errors);
      grid(upperGrid, 0);
      grid(lowerGrid, 1);
      drawFlux(flux, false);
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
      myPort.write("getcells "+revs+"\n");
      while ((buffer[0] == 0) && (buffer[1] == 0x10)) {
        while (myPort.available()<8192+2) {
          delay(1);
        }
        myPort.readBytes(buffer);
        //        println("Buf[0]: " + buffer[0] + " Buf[1]: " +buffer[1]);
        buflen = ((buffer[1]<<8)&0x0000ff00) + (buffer[0] & 0x000000ff);
        //        println(buflen + " cells read.");
        for (int k = 0; k<buflen; k++) {
          cellbuffer[cellpointer]=((buffer[3+k*2]<<8) & 0x0000ff00) + (buffer[2+k*2] & 0x000000ff);
          cellpointer++;
        }
      }
      //println("first cell: " + cellbuffer[0]);
      //println("Cells: "+(cellpointer-1) + " readtime: "+ (millis()-interval) + " ms");
      //println("Cellpointer= " + (cellpointer-1));
      //for (int j = 0; j<10; j++) {
      //  print(cellbuffer[j]);
      //  print(" ");
      //}
      getIndexes(revs);
      cellpointer = 2;
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
            tCell = PApplet.parseInt(((cell*(1.0f/48.0f))/(1.0f/40.0f)));
            diff +=((double)cell*(1.0f/48.0f))/(1.0f/40.0f)-tCell;
            if (diff>1)
            {
              tCell +=1;
              diff -=1;
            }
            if (tCell<0) {
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
      drawHist(histogram, i);
      drawFlux(flux, false);
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
      drawCells(cellgraph, i, false);
      drawDisk();

      if (!scanonly) {
        fstream.write(bytebuffer[i], 2, outpointer*2-2);
      }
      trackmap[i]=0xff00ff00;
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

public void loadSCP(File selection) {
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
    trackmap[i]=0xffffffff;
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
      trackmap[j]=0xff0000ff;
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
      trackmap[j]=0xff00ff00;
      focusTrack = j;
      grid(upperGrid, 0);
      grid(lowerGrid, 1);
      //      drawFlux(flux, false);
      //      drawHist(histogram, i, false);
      //      drawFlux(flux, false);
      println("Loadtrack: "+ (millis()-interval) + " ms");
    }
    fstream.close();
    drawDisk();
    drawStatus(status, "Download complete. "+(stop-start)+" Tracks read");
    timeLabel.setText("Done");
  }   
  catch(IOException e) {
    println("IOException");
    e.printStackTrace();
  }
  enableButtons(true, false);
}

public int magicfind(long buf, long mark)
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

public int decode2mfm(int track, int rev, boolean silent)
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

public void scan4Marks(int track, int rev, boolean silent)
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
public int calcChkSum(int secPtr, int pos, int b)
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
public boolean decodeSector(int secPtr, int index, int track, boolean silent)
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

public int decodeTrack(int track, int sectorCnt, boolean silent)
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

public void cleanDrive()
{
  abort = false;
  disableButtons();
  myPort.clear();
  for (int i = 0; i<168; i++)
  {
    trackmap[i]=0xffffffff;
  }
  String temp = dropList2.getSelectedText();
  temp = temp.replace(" sec", "");
  int tDuration = PApplet.parseInt(temp);
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
    trackmap[i*2]=0xff00ffff;
    trackmap[i*2+1]=0xff00ffff;
    myPort.write("goto "+i*2+"\n");
    drawStatus(status, "Track: " + i);
    i = (i + 6)%80;
    grid(upperGrid, 0);
    grid(lowerGrid, 1);
    secs = (duration - millis())/1000;
    timeLabel.setText("Time remaining: "+secs+"s");
    drawProgress(progress, PApplet.parseInt(160-(160/PApplet.parseFloat(tDuration)*secs)));
    delay(1000);
    secs = (duration - millis())/1000;
    timeLabel.setText("Time remaining: "+secs+"s");
    drawProgress(progress, PApplet.parseInt(160-(160/PApplet.parseFloat(tDuration)*secs)));
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

public String getName()
{
  myPort.clear();
  myPort.write("name\n");
  while (myPort.available()==0) {
    delay(5);
  }
  return trim(myPort.readString());
}

public void autoRip()
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

public void setPreErase()
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

public void singleErase(int track, int celltime)
{
  myPort.clear();
  myPort.write("erase " + track + " " + celltime + "\n");
  while (myPort.available()==0) {
    delay(5);
  }
  myPort.readString();
  myPort.clear();
}

public void autoFormat()
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

public int waitForDiskChange()
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

public byte [] generateImage(String diskName, boolean HD)
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


public void formatTracks()
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
  int start = PApplet.parseInt(starttrack.getText())*2;
  int stop = (PApplet.parseInt(endtrack.getText())+1)*2;
  for (int i = 0; i<168; i++)
  {
    weak[i]=0;
    errormap[i]=0;
    trackmap[i]=0xffffffff;
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
  drawFlux(flux, HDImage);
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
      trackmap[i]=0xff0000ff;
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
      drawFlux(flux, HDImage);
      drawHist(histogram, i);
      if (!Arrays.equals(track, trackComp)) {
        trackmap[i]=0xffff0000;
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

public void eraseTracks()
{
  abort = false;
  disableButtons();
  myPort.clear();
  for (int i = 0; i<168; i++)
  {
    weak[i]=0;
    errormap[i]=0;
    trackmap[i]=0xffffffff;
    for ( int j=0; j<256; j++) {
      hist[i][j]=0;
    }
  }
  int start = PApplet.parseInt(starttrack.getText())*2;
  int stop = (PApplet.parseInt(endtrack.getText())+1)*2;
  int zeit = millis();
  int failed = 0;
  String tempString;
  boolean HDdisk = false;
  drawFlux(flux, HDdisk);
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
      trackmap[i]=0xffff00ff;
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

public void putTracks()
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
    trackmap[i]=0xffffffff;
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
  drawFlux(flux, HDImage);
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
    trackmap[0]=0xffff0000;
    grid(upperGrid, 0);
    grid(lowerGrid, 1);
    drawStatus(status, "Disktype Error.");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Write Error, writing a DD Image to a HD Disk is not permitted, please cover the HD Hole of the Disk.", "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
  if (pDisk==1 && HDImage == true) {
    trackmap[0]=0xffff0000;
    grid(upperGrid, 0);
    grid(lowerGrid, 1);
    drawStatus(status, "Disktype Error.");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Write Error, writing a HD Image to a DD Disk is not permitted, please use a HD Disk.", "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
  if (pDisk==-1) {
    trackmap[0]=0xffff0000;
    grid(upperGrid, 0);
    grid(lowerGrid, 1);
    drawStatus(status, "Disk is writeprotected.");
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Disk is writeprotected.", "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
  if (pDisk==0) {
    trackmap[0]=0xffff0000;
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
      trackmap[i]=0xff0000ff;
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
      drawFlux(flux, HDImage);
      drawHist(histogram, i);
      focusTrack = i;
      if (!Arrays.equals(track, trackComp)) {
        trackmap[i]=0xffff0000;
        retry = true;
        retries++;
      } else {
        trackmap[i]=0xff00ff00;
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

public void compareDisk()
{
  abort = false;
  disableButtons();
  myPort.clear();
  for (int i = 0; i<168; i++)
  {
    weak[i]=0;
    errormap[i]=0;
    trackmap[i]=0xffffffff;
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
  drawFlux(flux, HDImage);
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
      drawFlux(flux, HDImage);
      drawHist(histogram, i);
      focusTrack = i;
      if (!Arrays.equals(track, trackComp)) {
        trackmap[i]=0xffff0000;
      } else {
        if (weak[i]==0) trackmap[i]=0xff00ff00;
        else trackmap[i]=0xffffff00;
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
public void onClose(String foo)
{
  println(foo);
}

public void setupGUI()
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
  int lightBlue = color(0xffccccff);
  int darkBlue = color(0xff0b0b60);
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

public void grid(PGraphics thisGrid, int side)
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

public void drawBitmap(PGraphics tP, boolean empty)
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

public void drawProgress(PGraphics tP, int i)
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

public void drawActive(PGraphics tP, int i)
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

public void drawStatus(PGraphics tS, String text)
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

public void drawLogo(PGraphics tL)
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

public void drawFlux(PGraphics tF, boolean HDImage)
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

public void drawCells(PGraphics tF, int track, boolean HDImage)
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

public void drawDisk()
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
public float log10 (float x) {
  return (log(x) / log(10));
}

public void drawHist(PGraphics tF, int track)
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
  tF.stroke(0xffbbbbbb);
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
      tF.stroke(0xffbbbbbb);
      tF.line((i-1)*xfactor+xoff, yoff+ysize, (i-1)*xfactor+xoff, yoff);
      tF.stroke(0, 0, 0);
      tF.line((i-1)*xfactor+xoff, yoff+ysize, (i-1)*xfactor+xoff, ysize+yoff/2);
    }
  } else
  {
    for (int i = 2; i<11; i++) {
      tF.text(""+i, (i-1)*xfactor+xoff, ysize+yoff-1);
      tF.stroke(0xffbbbbbb);
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
    tF.stroke(0xffbbbbbb);
    tF.line(xoff, yoff+ysize/2, xoff+xsize, yoff+ysize/2);
    tF.stroke(0, 0, 0);
    tF.line(xoff, yoff+ysize/2, xoff+5, yoff+ysize/2);
  } else {
    tF.text(""+tMax, xoff/2, yoff);
    //tF.text(""+tMax/10, xoff/2, ysize+yoff-log10(tMax/10)*scale);
    tF.text("10", xoff/2, ysize+yoff-log10(10)*scale);
    tF.text("100", xoff/2, ysize+yoff-log10(100)*scale);
    tF.text("1000", xoff/2, ysize+yoff-log10(1000)*scale);
    tF.stroke(0xffbbbbbb);
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
  tF.fill(0xffe86100);
  tF.stroke(0xff222222);
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

public void enableButton(GImageButton button)
{
  button.setEnabled(true);
  button.setAlpha(255);
}

public void disableButton(GImageButton button)
{
  button.setEnabled(false);
  button.setAlpha(50);
}

public void disableButtons()
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

public void enableButtons(boolean read, boolean write)
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
/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
     // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

public void filename_change1(GTextField source, GEvent event) { //_CODE_:filename:547495:
} //_CODE_:filename:547495:

public void textfield1_change1(GTextField source, GEvent event) { //_CODE_:filepathandname:641198:
} //_CODE_:filepathandname:641198:

public void panel1_Click1(GPanel source, GEvent event) { //_CODE_:aboutP:864528:
} //_CODE_:aboutP:864528:

public void closeAbout(GButton source, GEvent event) { //_CODE_:closeB:569758:
  drawActive(active, activePanel);
  aboutP.setVisible(false);
  enableButtons(false, false);
} //_CODE_:closeB:569758:

public void textarea1_change1(GTextArea source, GEvent event) { //_CODE_:aboutText:790044:
} //_CODE_:aboutText:790044:

public void Homepage_(GButton source, GEvent event) { //_CODE_:Homepage:524872:
  link("http://nickslabor.niteto.de");
} //_CODE_:Homepage:524872:

public void orderpcb_(GButton source, GEvent event) { //_CODE_:orderpcb:637496:
  link("mailto:nickslabor@niteto.de?subject=ADF-Copy%20PCB");
} //_CODE_:orderpcb:637496:

public void diskPanelClick(GPanel source, GEvent event) { //_CODE_:diskPanel:773771:
} //_CODE_:diskPanel:773771:

public void GetDiskInfo_(GImageButton source, GEvent event) { //_CODE_:GetDiskInfo:900493:
  diskInfo(false);
  disableButton(StartWrite);
  disableButton(StartRead);
} //_CODE_:GetDiskInfo:900493:

public void Init_(GImageButton source, GEvent event) { //_CODE_:Init:570321:
  myPort.clear();
  myPort.write("init\n");
  extError = getExtErr();
  if (!extError.contains("OK")) {
    drawStatus(status, "Drive Status: " + extError);
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Drive Error: " + extError, "Information", INFORMATION_MESSAGE);
    enableButtons(false, true);
    return;
  }
  myPort.clear();
} //_CODE_:Init:570321:

public void Abort_(GImageButton source, GEvent event) { //_CODE_:Abort:921426:
  // println("Abort >> GEvent." + event + " @ " + millis());
  abort= true;
} //_CODE_:Abort:921426:

public void About_(GImageButton source, GEvent event) { //_CODE_:About:428967:
  if (aboutP.isVisible()==true)
  {
    drawActive(active, activePanel);
    aboutP.setVisible(false);
    enableButtons(false, false);
  } else
  {
    drawActive(active, -1);
    aboutP.setVisible(true);
    disableButtons();
    enableButton(About);
    disableButton(Abort);
  }
} //_CODE_:About:428967:

public void ReadPanel_Click1(GPanel source, GEvent event) { //_CODE_:ReadPanel:579166:
  //println("panel1 - GPanel >> GEvent." + event + " @ " + millis());
} //_CODE_:ReadPanel:579166:

public void Start_Read(GImageButton source, GEvent event) { //_CODE_:StartRead:531633:
  thread("getTracks");
} //_CODE_:StartRead:531633:

public void ReadDisk_(GImageButton source, GEvent event) { //_CODE_:ReadDisk:418930:
  final File foo = new File(removeSuffix(fileName, 3)+".adf");
  selectOutput("Select a file to write to:", "readSelected", foo);
} //_CODE_:ReadDisk:418930:

public void chkSumChk_(GCheckbox source, GEvent event) { //_CODE_:chkSumChk:994191:
  //println("chkSumChk - GCheckbox >> GEvent." + event + " @ " + millis());
} //_CODE_:chkSumChk:994191:

public void AutoRip_(GImageButton source, GEvent event) { //_CODE_:AutoRip:544679:
  final File directory = new File(filePath);
  selectFolder("Select a folder to write to:", "folderSelected", directory);
} //_CODE_:AutoRip:544679:

public void compareDisk_(GImageButton source, GEvent event) { //_CODE_:compareDisk:389306:
  final File file = new File("*.adf");
  selectInput("Select an image to compare with disk:", "compareSelected", file);
  //thread("compareDisk");
} //_CODE_:compareDisk:389306:

public void fnprompt_(GCheckbox source, GEvent event) { //_CODE_:fnprompt:907153:
  //println("fnprompt - GCheckbox >> GEvent." + event + " @ " + millis());
} //_CODE_:fnprompt:907153:

public void WritePanel_Click1(GPanel source, GEvent event) { //_CODE_:WritePanel:293428:
  //println("panel2 - GPanel >> GEvent." + event + " @ " + millis());
} //_CODE_:WritePanel:293428:

public void WriteDisk_(GImageButton source, GEvent event) { //_CODE_:WriteDisk:856031:
  final File file = new File("*.adf");
  selectInput("Select an image to write to disk:", "writeSelected", file);
} //_CODE_:WriteDisk:856031:

public void Start_Write(GImageButton source, GEvent event) { //_CODE_:StartWrite:319973:
  thread("putTracks");
} //_CODE_:StartWrite:319973:

public void verifyCheck_(GCheckbox source, GEvent event) { //_CODE_:verifyCheck:234990:
  verifyFormat.setSelected(verifyCheck.isSelected());
} //_CODE_:verifyCheck:234990:

public void AutoWrite_(GImageButton source, GEvent event) { //_CODE_:AutoWrite:910592:
  showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Not yet implemented!", "42", INFORMATION_MESSAGE);
} //_CODE_:AutoWrite:910592:

public void preerase2_clicked1(GCheckbox source, GEvent event) { //_CODE_:pre_erase2:913906:
  pre_erase.setSelected(pre_erase2.isSelected());
  preErase = pre_erase2.isSelected();
  //println("pre_erase2 - GCheckbox >> GEvent." + event + " @ " + millis());
} //_CODE_:pre_erase2:913906:

public void indexAlignClick(GCheckbox source, GEvent event) { //_CODE_:indexAlign:284801:
  indexAlign2.setSelected(indexAlign.isSelected());
  indexAligned = indexAlign.isSelected();
  //println("indexAlign - GCheckbox >> GEvent." + event + " @ " + millis());
} //_CODE_:indexAlign:284801:

public void UtilityPanel_Click1(GPanel source, GEvent event) { //_CODE_:UtilityPanel:415550:
  //println("panel3 - GPanel >> GEvent." + event + " @ " + millis());
} //_CODE_:UtilityPanel:415550:

public void Format_(GImageButton source, GEvent event) { //_CODE_:Format:400387:
  autoFormatDisks= false;
  thread("formatTracks");
} //_CODE_:Format:400387:

public void Cleaning_(GImageButton source, GEvent event) { //_CODE_:Cleaning:241392:
  thread("cleanDrive");
} //_CODE_:Cleaning:241392:

public void AutoFormat_(GImageButton source, GEvent event) { //_CODE_:AutoFormat:663688:
  autoFormatDisks= true;
  thread("autoFormat");
} //_CODE_:AutoFormat:663688:

public void dropList2_click1(GDropList source, GEvent event) { //_CODE_:dropList2:948465:
  //println("dropList2 - GDropList >> GEvent." + event + " @ " + millis());
} //_CODE_:dropList2:948465:

public void verifyFormat_(GCheckbox source, GEvent event) { //_CODE_:verifyFormat:387892:
  verifyCheck.setSelected(verifyFormat.isSelected());
} //_CODE_:verifyFormat:387892:

public void quickFormat_(GCheckbox source, GEvent event) { //_CODE_:quickFormat:377135:
  //println("quickformat - GCheckbox >> GEvent." + event + " @ " + millis());
} //_CODE_:quickFormat:377135:

public void preerase_clicked1(GCheckbox source, GEvent event) { //_CODE_:pre_erase:542849:
  pre_erase2.setSelected(pre_erase.isSelected());
  preErase = pre_erase.isSelected();
  //println("pre_erase - GCheckbox >> GEvent." + event + " @ " + millis());
} //_CODE_:pre_erase:542849:

public void Erase_(GImageButton source, GEvent event) { //_CODE_:Erase:748841:
  thread("eraseTracks");
  //println("erase - GImageButton >> GEvent." + event + " @ " + millis());
} //_CODE_:Erase:748841:

public void indexAlignClick2(GCheckbox source, GEvent event) { //_CODE_:indexAlign2:501911:
  indexAlign.setSelected(indexAlign2.isSelected());
  indexAligned = indexAlign2.isSelected();
  //println("indexAlign2 - GCheckbox >> GEvent." + event + " @ " + millis());
} //_CODE_:indexAlign2:501911:

public void SettingsPanel_(GPanel source, GEvent event) { //_CODE_:SettingsPanel:218569:
  //println("panel1 - GPanel >> GEvent." + event + " @ " + millis());
} //_CODE_:SettingsPanel:218569:

public void LoadSettings_(GButton source, GEvent event) { //_CODE_:LoadSettings:537279:
  getSettings();
} //_CODE_:LoadSettings:537279:

public void TestSettings_(GButton source, GEvent event) { //_CODE_:TestSettings:863319:
  setSettings();
} //_CODE_:TestSettings:863319:

public void SaveSettings_(GButton source, GEvent event) { //_CODE_:SaveSettings:380775:
  setSettings();
  storeSettings();
} //_CODE_:SaveSettings:380775:

public void textfield1_change2(GTextField source, GEvent event) { //_CODE_:MotorSpinup_:649666:
  //println("textfield1 - GTextField >> GEvent." + event + " @ " + millis());
  if (event==GEvent.LOST_FOCUS) source.setText(source.getText().replaceAll("[^\\d.]", ""));
} //_CODE_:MotorSpinup_:649666:

public void textfield2_change1(GTextField source, GEvent event) { //_CODE_:MotorSpindown_:904960:
  //println("textfield2 - GTextField >> GEvent." + event + " @ " + millis());
  if (event==GEvent.LOST_FOCUS) source.setText(source.getText().replaceAll("[^\\d.]", ""));
} //_CODE_:MotorSpindown_:904960:

public void textfield3_change1(GTextField source, GEvent event) { //_CODE_:DriveSelect_:829799:
  //println("textfield3 - GTextField >> GEvent." + event + " @ " + millis());
  if (event==GEvent.LOST_FOCUS) source.setText(source.getText().replaceAll("[^\\d.]", ""));
} //_CODE_:DriveSelect_:829799:

public void textfield4_change1(GTextField source, GEvent event) { //_CODE_:DriveDeselect_:903112:
  //println("textfield4 - GTextField >> GEvent." + event + " @ " + millis());
  if (event==GEvent.LOST_FOCUS) source.setText(source.getText().replaceAll("[^\\d.]", ""));
} //_CODE_:DriveDeselect_:903112:

public void textfield5_change1(GTextField source, GEvent event) { //_CODE_:DirChange_:615504:
  //println("textfield5 - GTextField >> GEvent." + event + " @ " + millis());
  if (event==GEvent.LOST_FOCUS) source.setText(source.getText().replaceAll("[^\\d.]", ""));
} //_CODE_:DirChange_:615504:

public void textfield6_change1(GTextField source, GEvent event) { //_CODE_:SideChange_:487616:
  //println("textfield6 - GTextField >> GEvent." + event + " @ " + millis());
  if (event==GEvent.LOST_FOCUS) source.setText(source.getText().replaceAll("[^\\d.]", ""));
} //_CODE_:SideChange_:487616:

public void textfield7_change1(GTextField source, GEvent event) { //_CODE_:StepPulse_:895739:
  //println("textfield7 - GTextField >> GEvent." + event + " @ " + millis());
  if (event==GEvent.LOST_FOCUS) source.setText(source.getText().replaceAll("[^\\d.]", ""));
} //_CODE_:StepPulse_:895739:

public void textfield8_change1(GTextField source, GEvent event) { //_CODE_:StepSettle_:986980:
  //println("textfield8 - GTextField >> GEvent." + event + " @ " + millis());
  if (event==GEvent.LOST_FOCUS) source.setText(source.getText().replaceAll("[^\\d.]", ""));
} //_CODE_:StepSettle_:986980:

public void textfield9_change1(GTextField source, GEvent event) { //_CODE_:GotoTrack_:364585:
  //println("textfield9 - GTextField >> GEvent." + event + " @ " + millis());
  if (event==GEvent.LOST_FOCUS) source.setText(source.getText().replaceAll("[^\\d.]", ""));
} //_CODE_:GotoTrack_:364585:

public void checkbox1_clicked2(GCheckbox source, GEvent event) { //_CODE_:mtpMode_:230627:
  //println("checkbox1 - GCheckbox >> GEvent." + event + " @ " + millis());
} //_CODE_:mtpMode_:230627:

public void reset2DefaultSettings_(GButton source, GEvent event) { //_CODE_:reset2DefaultSettings:700755:
  resetSettings();
  getSettings();
} //_CODE_:reset2DefaultSettings:700755:

public void textfield1_change3(GTextField source, GEvent event) { //_CODE_:sdRetries_:566651:
  //println("sdRetries_ - GTextField >> GEvent." + event + " @ " + millis());
  if (event==GEvent.LOST_FOCUS) source.setText(source.getText().replaceAll("[^\\d.]", ""));
} //_CODE_:sdRetries_:566651:

public void textfield1_change4(GTextField source, GEvent event) { //_CODE_:hdRetries_:588146:
  //println("hdRetries - GTextField >> GEvent." + event + " @ " + millis());
  if (event==GEvent.LOST_FOCUS) source.setText(source.getText().replaceAll("[^\\d.]", ""));
} //_CODE_:hdRetries_:588146:

public void ReadButton_(GImageButton source, GEvent event) { //_CODE_:ReadButton:398266:
  drawActive(active, 0);
  fluxdetail.setVisible(false);
  diskwindow.setVisible(false);
} //_CODE_:ReadButton:398266:

public void WriteButton_(GImageButton source, GEvent event) { //_CODE_:WriteButton:795774:
  drawActive(active, 1);
  fluxdetail.setVisible(false);
  diskwindow.setVisible(false);
} //_CODE_:WriteButton:795774:

public void UtilityButton_(GImageButton source, GEvent event) { //_CODE_:UtilityButton:869569:
  drawActive(active, 3);
  fluxdetail.setVisible(false);
  diskwindow.setVisible(false);
} //_CODE_:UtilityButton:869569:

public void SettingsButton_(GImageButton source, GEvent event) { //_CODE_:SettingsButton:641704:
  if (myPort!=null) getSettings();
  drawActive(active, 4);
  fluxdetail.setVisible(false);
  diskwindow.setVisible(false);
} //_CODE_:SettingsButton:641704:

public void panel1_Click2(GPanel source, GEvent event) { //_CODE_:panel1:487390:
  //println("panel1 - GPanel >> GEvent." + event + " @ " + millis());
} //_CODE_:panel1:487390:

public void testbutton_(GImageButton source, GEvent event) { //_CODE_:testbutton:828692:
  //println("fenster2 - GImageButton >> GEvent." + event + " @ " + millis());
  if (revsInBuffer==0) return;
  if (focusTrack!=-1) { 
    decode2mfm(focusTrack, revcurrent,false);
    println("xx"+revpointer[focusTrack][revcurrent+1]);
    scan4Marks(focusTrack, revcurrent, false);
    decodeTrack(focusTrack, sectorCnt, false);
  } else
  {
    decode2mfm(lastTrack, revcurrent,false);
    println("xx"+revpointer[lastTrack][revcurrent+1]);
    scan4Marks(lastTrack, revcurrent, false);
    decodeTrack(lastTrack, sectorCnt,false);
  }
  drawDisk();
} //_CODE_:testbutton:828692:

public void SCPPanel_(GPanel source, GEvent event) { //_CODE_:SCPPanel:571838:
  //println("SCPPanel - GPanel >> GEvent." + event + " @ " + millis());
} //_CODE_:SCPPanel:571838:

public void ReadSCP_(GImageButton source, GEvent event) { //_CODE_:ReadSCP:445295:
  final File foo = new File(removeSuffix(fileName, 3)+".scp");
  selectOutput("Select a file to write to:", "readscp", foo);
  //thread("readscp");
} //_CODE_:ReadSCP:445295:

public void WriteSCP_(GImageButton source, GEvent event) { //_CODE_:WriteSCP:297549:
  final File foo = new File("*.scp");
  selectInput("Select an image to load into memory:", "loadSCP", foo);
  //println("WriteSCP - GImageButton >> GEvent." + event + " @ " + millis());
} //_CODE_:WriteSCP:297549:

public void revsSlider_(GCustomSlider source, GEvent event) { //_CODE_:revsSlider:473321:
  //println("custom_slider2 - GCustomSlider >> GEvent." + event + " @ " + millis());
} //_CODE_:revsSlider:473321:

public void scanDisk_(GImageButton source, GEvent event) { //_CODE_:scanDisk:580493:
  thread("scandisk");
} //_CODE_:scanDisk:580493:

public void showhist_clicked(GCheckbox source, GEvent event) { //_CODE_:showhist_:894426:
  showhist = showhist_.isSelected();
  histwindow.setVisible(showhist);
  if(showhist) drawHist(histogram, 0);
} //_CODE_:showhist_:894426:

public void showflux_clicked(GCheckbox source, GEvent event) { //_CODE_:showflux_:464322:
  showflux = showflux_.isSelected();
  fluxdetail.setVisible(showflux);
  if(showflux) drawFlux(flux, false);
} //_CODE_:showflux_:464322:

public void showdisk_clicked(GCheckbox source, GEvent event) { //_CODE_:showdisk_:455523:
  showdisk = showdisk_.isSelected();
  diskwindow.setVisible(showdisk);
  if(showdisk) drawCells(cellgraph, 0, false);
} //_CODE_:showdisk_:455523:

public void startEndPanel_(GPanel source, GEvent event) { //_CODE_:startEndPanel:577236:
  //println("startEndPanel - GPanel >> GEvent." + event + " @ " + millis());
} //_CODE_:startEndPanel:577236:

public void start_up_event(GImageButton source, GEvent event) { //_CODE_:start_up:647938:
  int temp = 0;
  if (mouseButton == 39) temp = Integer.parseInt(starttrack.getText())+10;
  else temp = Integer.parseInt(starttrack.getText())+1;
  if (temp>84) temp = 83;
  starttrack.setText(""+temp);
  starttrack.setTextBold();
  if (activePanel == 3) utilStart = temp;
  else scpStart = temp;
} //_CODE_:start_up:647938:

public void start_down_event(GImageButton source, GEvent event) { //_CODE_:start_down:526499:
  int temp = 0;
  if (mouseButton == 39) temp = Integer.parseInt(starttrack.getText())-10;
  else temp = Integer.parseInt(starttrack.getText())-1;
  if (temp<0) temp = 0;
  starttrack.setText(""+temp);
  starttrack.setTextBold();
  if (activePanel == 3) utilStart = temp;
  else scpStart = temp;
} //_CODE_:start_down:526499:

public void end_up_event(GImageButton source, GEvent event) { //_CODE_:end_up:989675:
  int temp = 0;
  if (mouseButton == 39) temp = Integer.parseInt(endtrack.getText())+10;
  else temp = Integer.parseInt(endtrack.getText())+1;
  if (temp>83) temp = 83;
  endtrack.setLocalColor(6, color(255, 255, 255)); //background
  if (temp>79) endtrack.setLocalColor(6, color(255, 255, 0)); //background
  if (temp>81) endtrack.setLocalColor(6, color(255, 0, 0)); //background
  endtrack.setText(""+temp);
  endtrack.setTextBold();
  if (activePanel == 3) utilEnd = temp;
  else scpEnd = temp;
} //_CODE_:end_up:989675:

public void end_down_event(GImageButton source, GEvent event) { //_CODE_:end_down:660507:
  int temp = 0;
  if (mouseButton == 39) temp = Integer.parseInt(endtrack.getText())-10;
  else temp = Integer.parseInt(endtrack.getText())-1;
  endtrack.setLocalColor(6, color(255, 255, 255)); //background
  if (temp<0) temp = 0;
  if (temp>79) endtrack.setLocalColor(6, color(255, 255, 0)); //background
  if (temp>81) endtrack.setLocalColor(6, color(255, 0, 0)); //background
  endtrack.setText(""+temp);
  endtrack.setTextBold();
  if (activePanel == 3) utilEnd = temp;
  else scpEnd = temp;
} //_CODE_:end_down:660507:

public void SCPButton_(GImageButton source, GEvent event) { //_CODE_:SCPButton:608300:
  drawActive(active, 2);
  fluxdetail.setVisible(showflux);
  diskwindow.setVisible(showdisk);
  histwindow.setVisible(showhist);
  java.awt.Frame f =  (java.awt.Frame) ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame();
  if (f.getHeight()+histwindow.height < displayHeight)
    histwindow.setLocation(f.getX(), f.getY()+f.getHeight());
  if (f.getHeight()+fluxdetail.width < displayWidth)
    fluxdetail.setLocation(f.getX()+f.getWidth(), f.getY());
  if (f.getHeight()+diskwindow.width < displayWidth)
    diskwindow.setLocation(f.getX()+f.getWidth(), f.getY()+fluxdetail.height+30);
} //_CODE_:SCPButton:608300:

synchronized public void histwin_draw1(PApplet appc, GWinData data) { //_CODE_:histwindow:588696:
  appc.background(230);
} //_CODE_:histwindow:588696:

public void logcb_(GCheckbox source, GEvent event) { //_CODE_:logcb:766328:
  //println("logcb - GCheckbox >> GEvent." + event + " @ " + millis());
  if (focusTrack!=-1) 
    drawHist(histogram, focusTrack);
  else
    drawHist(histogram, lastTrack);
} //_CODE_:logcb:766328:

synchronized public void detailwin_draw1(PApplet appc, GWinData data) { //_CODE_:fluxdetail:466459:
  appc.background(230);
} //_CODE_:fluxdetail:466459:

public void revminus_click(GImageButton source, GEvent event) { //_CODE_:revminus:354151:
  if (revsInBuffer == 0) return;
  revcurrent--;
  if (revcurrent<0) revcurrent = 0;
  if (focusTrack!=-1) 
    drawCells(cellgraph, focusTrack, false);
  else
    drawCells(cellgraph, lastTrack, false);
  drawDisk();
} //_CODE_:revminus:354151:

public void revplus_click(GImageButton source, GEvent event) { //_CODE_:revplus:301771:
  if (revsInBuffer == 0) return;
  revcurrent++;
  if (revcurrent>=revsInBuffer) revcurrent = revsInBuffer-1;
  if (focusTrack!=-1) 
    drawCells(cellgraph, focusTrack, false);
  else
    drawCells(cellgraph, lastTrack, false);
  drawDisk();
} //_CODE_:revplus:301771:

synchronized public void disk_draw1(PApplet appc, GWinData data) { //_CODE_:diskwindow:815811:
  appc.background(230);
} //_CODE_:diskwindow:815811:



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  surface.setTitle("ADF Copy");
  filename = new GTextField(this, 120, 250, 260, 20, G4P.SCROLLBARS_NONE);
  filename.setPromptText("Press 'Diskinfo'");
  filename.setOpaque(true);
  filename.addEventHandler(this, "filename_change1");
  filepathandname = new GTextField(this, 120, 220, 260, 20, G4P.SCROLLBARS_NONE);
  filepathandname.setOpaque(true);
  filepathandname.addEventHandler(this, "textfield1_change1");
  label3 = new GLabel(this, 20, 250, 80, 20);
  label3.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label3.setText("Volumename");
  label3.setOpaque(false);
  label4 = new GLabel(this, 20, 220, 80, 20);
  label4.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label4.setText("Filename");
  label4.setOpaque(false);
  sP1 = new GSketchPad(this, 199, 370, 180, 180);
  sP2 = new GSketchPad(this, 400, 370, 180, 180);
  fluxPad = new GSketchPad(this, 10, 370, 180, 180);
  progressPad = new GSketchPad(this, 400, 300, 180, 20);
  statusPad = new GSketchPad(this, 10, 340, 370, 20);
  logoPad = new GSketchPad(this, 410, 10, 170, 127);
  timeLabel = new GLabel(this, 400, 300, 180, 20);
  timeLabel.setText("Progress");
  timeLabel.setOpaque(false);
  aboutP = new GPanel(this, 379, 655, 390, 400, "About");
  aboutP.setCollapsible(false);
  aboutP.setDraggable(false);
  aboutP.setText("About");
  aboutP.setOpaque(true);
  aboutP.addEventHandler(this, "panel1_Click1");
  closeB = new GButton(this, 300, 360, 80, 30);
  closeB.setText("Close");
  closeB.setTextBold();
  closeB.addEventHandler(this, "closeAbout");
  aboutText = new GTextArea(this, 10, 30, 370, 320, G4P.SCROLLBARS_NONE);
  aboutText.setOpaque(true);
  aboutText.addEventHandler(this, "textarea1_change1");
  Homepage = new GButton(this, 10, 360, 130, 30);
  Homepage.setText("nickslabor.niteto.de");
  Homepage.setTextBold();
  Homepage.addEventHandler(this, "Homepage_");
  orderpcb = new GButton(this, 200, 360, 80, 30);
  orderpcb.setText("Order PCB");
  orderpcb.setTextBold();
  orderpcb.addEventHandler(this, "orderpcb_");
  aboutP.addControl(closeB);
  aboutP.addControl(aboutText);
  aboutP.addControl(Homepage);
  aboutP.addControl(orderpcb);
  diskPanel = new GPanel(this, 30, 390, 130, 131, "");
  diskPanel.setCollapsible(false);
  diskPanel.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  diskPanel.setOpaque(false);
  diskPanel.addEventHandler(this, "diskPanelClick");
  diskPad = new GSketchPad(this, 0, 0, 130, 131);
  diskPanel.addControl(diskPad);
  GetDiskInfo = new GImageButton(this, 10, 280, new String[] { "button_diskinfo.png", "button_diskinfo_o.png", "button_diskinfo_p.png" } );
  GetDiskInfo.addEventHandler(this, "GetDiskInfo_");
  Init = new GImageButton(this, 120, 170, new String[] { "button_init.png", "button_init_o.png", "button_init_p.png" } );
  Init.addEventHandler(this, "Init_");
  Abort = new GImageButton(this, 230, 170, new String[] { "button_abort.png", "button_abort_o.png", "button_abort_p.png" } );
  Abort.addEventHandler(this, "Abort_");
  About = new GImageButton(this, 445, 150, new String[] { "button_about.png", "button_about_o.png", "button_about_p.png" } );
  About.addEventHandler(this, "About_");
  ReadPanel = new GPanel(this, 610, 0, 260, 180, "Read");
  ReadPanel.setCollapsible(false);
  ReadPanel.setDraggable(false);
  ReadPanel.setText("Read");
  ReadPanel.setTextBold();
  ReadPanel.setOpaque(false);
  ReadPanel.addEventHandler(this, "ReadPanel_Click1");
  StartRead = new GImageButton(this, 110, 30, new String[] { "button_start.png", "button_start_o.png", "button_start_p.png" } );
  StartRead.addEventHandler(this, "Start_Read");
  ReadDisk = new GImageButton(this, 0, 30, new String[] { "button_read-disk.png", "button_read-disk_o.png", "button_read-disk_p.png" } );
  ReadDisk.addEventHandler(this, "ReadDisk_");
  chkSumChk = new GCheckbox(this, 0, 110, 200, 20);
  chkSumChk.setText("Ignore Checksum Errors");
  chkSumChk.setOpaque(false);
  chkSumChk.addEventHandler(this, "chkSumChk_");
  AutoRip = new GImageButton(this, 110, 70, new String[] { "button_auto-rip.png", "button_auto-rip_o.png", "button_auto-rip_p.png" } );
  AutoRip.addEventHandler(this, "AutoRip_");
  compareDisk = new GImageButton(this, 0, 70, new String[] { "button_compare.png", "button_compare_o.png", "button_compare_p.png" } );
  compareDisk.addEventHandler(this, "compareDisk_");
  fnprompt = new GCheckbox(this, 0, 130, 200, 20);
  fnprompt.setText("Autorip Name Prompt");
  fnprompt.setOpaque(false);
  fnprompt.addEventHandler(this, "fnprompt_");
  ReadPanel.addControl(StartRead);
  ReadPanel.addControl(ReadDisk);
  ReadPanel.addControl(chkSumChk);
  ReadPanel.addControl(AutoRip);
  ReadPanel.addControl(compareDisk);
  ReadPanel.addControl(fnprompt);
  WritePanel = new GPanel(this, 610, 180, 260, 180, "Write");
  WritePanel.setCollapsible(false);
  WritePanel.setDraggable(false);
  WritePanel.setText("Write");
  WritePanel.setTextBold();
  WritePanel.setOpaque(false);
  WritePanel.addEventHandler(this, "WritePanel_Click1");
  WriteDisk = new GImageButton(this, 0, 30, new String[] { "button_write-disk.png", "button_write-disk_o.png", "button_write-disk_p.png" } );
  WriteDisk.addEventHandler(this, "WriteDisk_");
  StartWrite = new GImageButton(this, 110, 30, new String[] { "button_start.png", "button_start_o.png", "button_start_p.png" } );
  StartWrite.addEventHandler(this, "Start_Write");
  verifyCheck = new GCheckbox(this, 0, 105, 100, 20);
  verifyCheck.setText("Verify");
  verifyCheck.setOpaque(false);
  verifyCheck.addEventHandler(this, "verifyCheck_");
  verifyCheck.setSelected(true);
  AutoWrite = new GImageButton(this, 0, 70, new String[] { "button_auto-write.png", "button_auto-write_o.png", "button_auto-write_p.png" } );
  AutoWrite.addEventHandler(this, "AutoWrite_");
  pre_erase2 = new GCheckbox(this, 0, 125, 100, 20);
  pre_erase2.setText("pre erase");
  pre_erase2.setOpaque(false);
  pre_erase2.addEventHandler(this, "preerase2_clicked1");
  pre_erase2.setSelected(true);
  indexAlign = new GCheckbox(this, 0, 144, 93, 20);
  indexAlign.setText("Index aligned");
  indexAlign.setOpaque(false);
  indexAlign.addEventHandler(this, "indexAlignClick");
  WritePanel.addControl(WriteDisk);
  WritePanel.addControl(StartWrite);
  WritePanel.addControl(verifyCheck);
  WritePanel.addControl(AutoWrite);
  WritePanel.addControl(pre_erase2);
  WritePanel.addControl(indexAlign);
  UtilityPanel = new GPanel(this, 610, 361, 260, 180, "Utility");
  UtilityPanel.setCollapsible(false);
  UtilityPanel.setDraggable(false);
  UtilityPanel.setText("Utility");
  UtilityPanel.setTextBold();
  UtilityPanel.setOpaque(false);
  UtilityPanel.addEventHandler(this, "UtilityPanel_Click1");
  Format = new GImageButton(this, 0, 30, new String[] { "button_format.png", "button_format_o.png", "button_format_p.png" } );
  Format.addEventHandler(this, "Format_");
  Cleaning = new GImageButton(this, 0, 110, new String[] { "button_cleaning.png", "button_cleaning_o.png", "button_cleaning_p.png" } );
  Cleaning.addEventHandler(this, "Cleaning_");
  AutoFormat = new GImageButton(this, 110, 30, new String[] { "button_auto-format.png", "button_auto-format_o.png", "button_auto-format_p.png" } );
  AutoFormat.addEventHandler(this, "AutoFormat_");
  dropList2 = new GDropList(this, 0, 145, 70, 150, 4);
  dropList2.setItems(loadStrings("list_948465"), 0);
  dropList2.addEventHandler(this, "dropList2_click1");
  verifyFormat = new GCheckbox(this, 110, 75, 80, 20);
  verifyFormat.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  verifyFormat.setText("Verify");
  verifyFormat.setOpaque(false);
  verifyFormat.addEventHandler(this, "verifyFormat_");
  verifyFormat.setSelected(true);
  quickFormat = new GCheckbox(this, 110, 60, 90, 20);
  quickFormat.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  quickFormat.setText("Quickformat");
  quickFormat.setOpaque(false);
  quickFormat.addEventHandler(this, "quickFormat_");
  pre_erase = new GCheckbox(this, 110, 90, 70, 20);
  pre_erase.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  pre_erase.setText("pre erase");
  pre_erase.setOpaque(false);
  pre_erase.addEventHandler(this, "preerase_clicked1");
  pre_erase.setSelected(true);
  Erase = new GImageButton(this, 0, 70, new String[] { "button_erase.png", "button_erase_o.png", "button_erase_p.png" } );
  Erase.addEventHandler(this, "Erase_");
  PlaceholderU = new GLabel(this, 110, 140, 80, 40);
  PlaceholderU.setOpaque(false);
  indexAlign2 = new GCheckbox(this, 110, 105, 100, 20);
  indexAlign2.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  indexAlign2.setText("Index aligned");
  indexAlign2.setOpaque(false);
  indexAlign2.addEventHandler(this, "indexAlignClick2");
  UtilityPanel.addControl(Format);
  UtilityPanel.addControl(Cleaning);
  UtilityPanel.addControl(AutoFormat);
  UtilityPanel.addControl(dropList2);
  UtilityPanel.addControl(verifyFormat);
  UtilityPanel.addControl(quickFormat);
  UtilityPanel.addControl(pre_erase);
  UtilityPanel.addControl(Erase);
  UtilityPanel.addControl(PlaceholderU);
  UtilityPanel.addControl(indexAlign2);
  SettingsPanel = new GPanel(this, 870, 360, 260, 270, "Settings");
  SettingsPanel.setCollapsible(false);
  SettingsPanel.setDraggable(false);
  SettingsPanel.setText("Settings");
  SettingsPanel.setTextBold();
  SettingsPanel.setOpaque(true);
  SettingsPanel.addEventHandler(this, "SettingsPanel_");
  LoadSettings = new GButton(this, 0, 230, 70, 20);
  LoadSettings.setText("Load");
  LoadSettings.setTextBold();
  LoadSettings.addEventHandler(this, "LoadSettings_");
  TestSettings = new GButton(this, 70, 230, 70, 20);
  TestSettings.setText("Save");
  TestSettings.setTextBold();
  TestSettings.addEventHandler(this, "TestSettings_");
  SaveSettings = new GButton(this, 140, 230, 120, 20);
  SaveSettings.setText("Save&Store");
  SaveSettings.setTextBold();
  SaveSettings.addEventHandler(this, "SaveSettings_");
  MotorSpinup_ = new GTextField(this, 110, 20, 30, 20, G4P.SCROLLBARS_NONE);
  MotorSpinup_.setOpaque(true);
  MotorSpinup_.addEventHandler(this, "textfield1_change2");
  MotorSpindown_ = new GTextField(this, 110, 40, 30, 20, G4P.SCROLLBARS_NONE);
  MotorSpindown_.setOpaque(true);
  MotorSpindown_.addEventHandler(this, "textfield2_change1");
  DriveSelect_ = new GTextField(this, 110, 60, 30, 20, G4P.SCROLLBARS_NONE);
  DriveSelect_.setOpaque(true);
  DriveSelect_.addEventHandler(this, "textfield3_change1");
  DriveDeselect_ = new GTextField(this, 110, 80, 30, 20, G4P.SCROLLBARS_NONE);
  DriveDeselect_.setOpaque(true);
  DriveDeselect_.addEventHandler(this, "textfield4_change1");
  DirChange_ = new GTextField(this, 110, 100, 30, 20, G4P.SCROLLBARS_NONE);
  DirChange_.setOpaque(true);
  DirChange_.addEventHandler(this, "textfield5_change1");
  spinup = new GLabel(this, 0, 20, 110, 20);
  spinup.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  spinup.setText("Motor Spinup ms:");
  spinup.setOpaque(false);
  SideChange_ = new GTextField(this, 110, 120, 30, 20, G4P.SCROLLBARS_NONE);
  SideChange_.setOpaque(true);
  SideChange_.addEventHandler(this, "textfield6_change1");
  StepPulse_ = new GTextField(this, 110, 140, 30, 20, G4P.SCROLLBARS_NONE);
  StepPulse_.setOpaque(true);
  StepPulse_.addEventHandler(this, "textfield7_change1");
  StepSettle_ = new GTextField(this, 110, 160, 30, 20, G4P.SCROLLBARS_NONE);
  StepSettle_.setOpaque(true);
  StepSettle_.addEventHandler(this, "textfield8_change1");
  GotoTrack_ = new GTextField(this, 110, 180, 30, 20, G4P.SCROLLBARS_NONE);
  GotoTrack_.setOpaque(true);
  GotoTrack_.addEventHandler(this, "textfield9_change1");
  Spindown = new GLabel(this, 0, 40, 110, 20);
  Spindown.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  Spindown.setText("Motor Spindown µs:");
  Spindown.setOpaque(false);
  DriveSelect = new GLabel(this, 0, 60, 110, 20);
  DriveSelect.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  DriveSelect.setText("Drive Select µs:");
  DriveSelect.setOpaque(false);
  DriveDeselect = new GLabel(this, 0, 80, 110, 20);
  DriveDeselect.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  DriveDeselect.setText("Drive Deselect µs:");
  DriveDeselect.setOpaque(false);
  DirChange = new GLabel(this, 0, 100, 110, 20);
  DirChange.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  DirChange.setText("Dir Change µs:");
  DirChange.setOpaque(false);
  SideChange = new GLabel(this, 0, 120, 110, 20);
  SideChange.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  SideChange.setText("Side Change µs:");
  SideChange.setOpaque(false);
  StepPulse = new GLabel(this, 0, 140, 110, 20);
  StepPulse.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  StepPulse.setText("Step Pulse µs:");
  StepPulse.setOpaque(false);
  StepSettle = new GLabel(this, 0, 160, 110, 20);
  StepSettle.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  StepSettle.setText("Step Settle ms:");
  StepSettle.setOpaque(false);
  gotoTrack = new GLabel(this, 0, 180, 110, 20);
  gotoTrack.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  gotoTrack.setText("goto Settle ms:");
  gotoTrack.setOpaque(false);
  MtpOn = new GLabel(this, 0, 200, 110, 20);
  MtpOn.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  MtpOn.setText("Mtp Mode On");
  MtpOn.setOpaque(false);
  mtpMode_ = new GCheckbox(this, 110, 200, 20, 20);
  mtpMode_.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  mtpMode_.setOpaque(false);
  mtpMode_.addEventHandler(this, "checkbox1_clicked2");
  mtpMode_.setSelected(true);
  reset2DefaultSettings = new GButton(this, 0, 250, 260, 20);
  reset2DefaultSettings.setText("reset EEPROM to drive defaults");
  reset2DefaultSettings.addEventHandler(this, "reset2DefaultSettings_");
  sdRet = new GLabel(this, 140, 20, 90, 20);
  sdRet.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  sdRet.setText("DD Retries:");
  sdRet.setOpaque(false);
  hd = new GLabel(this, 140, 40, 90, 20);
  hd.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  hd.setText("HD Retries:");
  hd.setOpaque(false);
  label1 = new GLabel(this, 130, 200, 130, 20);
  label1.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label1.setText("<- requires drive restart");
  label1.setOpaque(false);
  sdRetries_ = new GTextField(this, 230, 20, 30, 20, G4P.SCROLLBARS_NONE);
  sdRetries_.setOpaque(true);
  sdRetries_.addEventHandler(this, "textfield1_change3");
  hdRetries_ = new GTextField(this, 230, 40, 30, 20, G4P.SCROLLBARS_NONE);
  hdRetries_.setOpaque(true);
  hdRetries_.addEventHandler(this, "textfield1_change4");
  SettingsPanel.addControl(LoadSettings);
  SettingsPanel.addControl(TestSettings);
  SettingsPanel.addControl(SaveSettings);
  SettingsPanel.addControl(MotorSpinup_);
  SettingsPanel.addControl(MotorSpindown_);
  SettingsPanel.addControl(DriveSelect_);
  SettingsPanel.addControl(DriveDeselect_);
  SettingsPanel.addControl(DirChange_);
  SettingsPanel.addControl(spinup);
  SettingsPanel.addControl(SideChange_);
  SettingsPanel.addControl(StepPulse_);
  SettingsPanel.addControl(StepSettle_);
  SettingsPanel.addControl(GotoTrack_);
  SettingsPanel.addControl(Spindown);
  SettingsPanel.addControl(DriveSelect);
  SettingsPanel.addControl(DriveDeselect);
  SettingsPanel.addControl(DirChange);
  SettingsPanel.addControl(SideChange);
  SettingsPanel.addControl(StepPulse);
  SettingsPanel.addControl(StepSettle);
  SettingsPanel.addControl(gotoTrack);
  SettingsPanel.addControl(MtpOn);
  SettingsPanel.addControl(mtpMode_);
  SettingsPanel.addControl(reset2DefaultSettings);
  SettingsPanel.addControl(sdRet);
  SettingsPanel.addControl(hd);
  SettingsPanel.addControl(label1);
  SettingsPanel.addControl(sdRetries_);
  SettingsPanel.addControl(hdRetries_);
  ReadButton = new GImageButton(this, 10, 10, new String[] { "button_read.png", "button_read_o.png", "button_read_p.png" } );
  ReadButton.addEventHandler(this, "ReadButton_");
  WriteButton = new GImageButton(this, 10, 50, new String[] { "button_write.png", "button_write_o.png", "button_write_p.png" } );
  WriteButton.addEventHandler(this, "WriteButton_");
  UtilityButton = new GImageButton(this, 10, 130, new String[] { "button_utility.png", "button_utility_o.png", "button_utility_p.png" } );
  UtilityButton.addEventHandler(this, "UtilityButton_");
  SettingsButton = new GImageButton(this, 10, 170, new String[] { "button_settings.png", "button_settings_o.png", "button_settings_p.png" } );
  SettingsButton.addEventHandler(this, "SettingsButton_");
  panel1 = new GPanel(this, 100, 10, 10, 190, "");
  panel1.setCollapsible(false);
  panel1.setDraggable(false);
  panel1.setOpaque(false);
  panel1.addEventHandler(this, "panel1_Click2");
  activePad = new GSketchPad(this, 0, 0, 10, 190);
  panel1.addControl(activePad);
  DiskInfoPad = new GSketchPad(this, 400, 190, 180, 100);
  bitmapPad = new GSketchPad(this, 220, 280, 160, 44);
  label2 = new GLabel(this, 120, 280, 50, 20);
  label2.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label2.setText("Bitmap");
  label2.setTextBold();
  label2.setOpaque(false);
  label5 = new GLabel(this, 160, 280, 50, 20);
  label5.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  label5.setText("Free");
  label5.setTextBold();
  label5.setLocalColorScheme(GCScheme.GREEN_SCHEME);
  label5.setOpaque(false);
  label6 = new GLabel(this, 160, 300, 50, 20);
  label6.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  label6.setText("In Use");
  label6.setTextBold();
  label6.setLocalColorScheme(GCScheme.RED_SCHEME);
  label6.setOpaque(false);
  testbutton = new GImageButton(this, 658, 569, new String[] { "button_start.png", "button_start_o.png", "button_start_p.png" } );
  testbutton.addEventHandler(this, "testbutton_");
  SCPPanel = new GPanel(this, 870, 0, 260, 180, "SCP");
  SCPPanel.setCollapsible(false);
  SCPPanel.setDraggable(false);
  SCPPanel.setText("SCP");
  SCPPanel.setTextBold();
  SCPPanel.setOpaque(false);
  SCPPanel.addEventHandler(this, "SCPPanel_");
  ReadSCP = new GImageButton(this, 0, 30, new String[] { "button_read-scp.png", "button_read-scp_o.png", "button_read-scp_p.png" } );
  ReadSCP.addEventHandler(this, "ReadSCP_");
  WriteSCP = new GImageButton(this, 110, 30, new String[] { "button_write-scp.png", "button_write-scp_o.png", "button_write-scp_p.png" } );
  WriteSCP.addEventHandler(this, "WriteSCP_");
  revsSlider = new GCustomSlider(this, 110, 130, 100, 50, "grey_blue");
  revsSlider.setShowValue(true);
  revsSlider.setShowLimits(true);
  revsSlider.setLimits(3, 2, 5);
  revsSlider.setNbrTicks(4);
  revsSlider.setStickToTicks(true);
  revsSlider.setNumberFormat(G4P.INTEGER, 0);
  revsSlider.setOpaque(false);
  revsSlider.addEventHandler(this, "revsSlider_");
  scanDisk = new GImageButton(this, 1, 71, new String[] { "button_scan-disk.png", "button_scan-disk_o.png", "button_scan-disk_p.png" } );
  scanDisk.addEventHandler(this, "scanDisk_");
  showhist_ = new GCheckbox(this, 6, 110, 100, 20);
  showhist_.setText("Histogram");
  showhist_.setOpaque(false);
  showhist_.addEventHandler(this, "showhist_clicked");
  showhist_.setSelected(true);
  showflux_ = new GCheckbox(this, 6, 130, 100, 20);
  showflux_.setText("Fluxdiagram");
  showflux_.setOpaque(false);
  showflux_.addEventHandler(this, "showflux_clicked");
  showflux_.setSelected(true);
  label7 = new GLabel(this, 110, 115, 80, 20);
  label7.setText("Revolutions");
  label7.setOpaque(false);
  PlaceholderSCP = new GLabel(this, 110, 70, 80, 40);
  PlaceholderSCP.setOpaque(false);
  showdisk_ = new GCheckbox(this, 6, 150, 100, 20);
  showdisk_.setText("Diskview");
  showdisk_.setOpaque(false);
  showdisk_.addEventHandler(this, "showdisk_clicked");
  showdisk_.setSelected(true);
  SCPPanel.addControl(ReadSCP);
  SCPPanel.addControl(WriteSCP);
  SCPPanel.addControl(revsSlider);
  SCPPanel.addControl(scanDisk);
  SCPPanel.addControl(showhist_);
  SCPPanel.addControl(showflux_);
  SCPPanel.addControl(label7);
  SCPPanel.addControl(PlaceholderSCP);
  SCPPanel.addControl(showdisk_);
  startEndPanel = new GPanel(this, 500, 580, 80, 40, "");
  startEndPanel.setCollapsible(false);
  startEndPanel.setDraggable(false);
  startEndPanel.setOpaque(false);
  startEndPanel.addEventHandler(this, "startEndPanel_");
  starttrack = new GLabel(this, 50, 0, 20, 20);
  starttrack.setText("0");
  starttrack.setTextBold();
  starttrack.setOpaque(true);
  endtrack = new GLabel(this, 50, 20, 20, 20);
  endtrack.setText("81");
  endtrack.setTextBold();
  endtrack.setOpaque(true);
  start_up = new GImageButton(this, 70, 0, 10, 10, new String[] { "up.png", "up.png", "up_p.png" } );
  start_up.addEventHandler(this, "start_up_event");
  start_down = new GImageButton(this, 70, 10, 10, 10, new String[] { "down.png", "down.png", "down_p.png" } );
  start_down.addEventHandler(this, "start_down_event");
  end_up = new GImageButton(this, 70, 20, 10, 10, new String[] { "up.png", "up.png", "up_p.png" } );
  end_up.addEventHandler(this, "end_up_event");
  end_down = new GImageButton(this, 70, 30, 10, 10, new String[] { "down.png", "down.png", "down_p.png" } );
  end_down.addEventHandler(this, "end_down_event");
  StartLabel = new GLabel(this, 0, 0, 50, 20);
  StartLabel.setText("Start");
  StartLabel.setTextBold();
  StartLabel.setOpaque(false);
  EndLabel = new GLabel(this, 0, 20, 50, 20);
  EndLabel.setText("End");
  EndLabel.setTextBold();
  EndLabel.setOpaque(false);
  startEndPanel.addControl(starttrack);
  startEndPanel.addControl(endtrack);
  startEndPanel.addControl(start_up);
  startEndPanel.addControl(start_down);
  startEndPanel.addControl(end_up);
  startEndPanel.addControl(end_down);
  startEndPanel.addControl(StartLabel);
  startEndPanel.addControl(EndLabel);
  SCPButton = new GImageButton(this, 10, 90, new String[] { "button_flux-tools.png", "button_flux-tools_o.png", "button_flux-tools_p.png" } );
  SCPButton.addEventHandler(this, "SCPButton_");
  histwindow = GWindow.getWindow(this, "Histogram", 0, 0, 595, 130, JAVA2D);
  histwindow.noLoop();
  histwindow.addDrawHandler(this, "histwin_draw1");
  histPad = new GSketchPad(histwindow, 0, 0, 600, 130);
  logcb = new GCheckbox(histwindow, 0, 105, 50, 20);
  logcb.setText("log10");
  logcb.setOpaque(false);
  logcb.addEventHandler(this, "logcb_");
  logcb.setSelected(true);
  fluxdetail = GWindow.getWindow(this, "Fluxdetail", 0, 0, 830, 430, JAVA2D);
  fluxdetail.noLoop();
  fluxdetail.addDrawHandler(this, "detailwin_draw1");
  cellPad = new GSketchPad(fluxdetail, 0, 0, 830, 430);
  revminus = new GImageButton(fluxdetail, 10, 10, 20, 20, new String[] { "left.png", "left.png", "left.png" } );
  revminus.addEventHandler(this, "revminus_click");
  revplus = new GImageButton(fluxdetail, 35, 10, 20, 20, new String[] { "right.png", "right.png", "right.png" } );
  revplus.addEventHandler(this, "revplus_click");
  diskwindow = GWindow.getWindow(this, "Disk", 0, 0, 800, 400, JAVA2D);
  diskwindow.noLoop();
  diskwindow.addDrawHandler(this, "disk_draw1");
  side0 = new GSketchPad(diskwindow, 0, 0, 400, 400);
  side1 = new GSketchPad(diskwindow, 400, 0, 400, 400);
  histwindow.loop();
  fluxdetail.loop();
  diskwindow.loop();
}

// Variable declarations 
// autogenerated do not edit
GTextField filename; 
GTextField filepathandname; 
GLabel label3; 
GLabel label4; 
GSketchPad sP1; 
GSketchPad sP2; 
GSketchPad fluxPad; 
GSketchPad progressPad; 
GSketchPad statusPad; 
GSketchPad logoPad; 
GLabel timeLabel; 
GPanel aboutP; 
GButton closeB; 
GTextArea aboutText; 
GButton Homepage; 
GButton orderpcb; 
GPanel diskPanel; 
GSketchPad diskPad; 
GImageButton GetDiskInfo; 
GImageButton Init; 
GImageButton Abort; 
GImageButton About; 
GPanel ReadPanel; 
GImageButton StartRead; 
GImageButton ReadDisk; 
GCheckbox chkSumChk; 
GImageButton AutoRip; 
GImageButton compareDisk; 
GCheckbox fnprompt; 
GPanel WritePanel; 
GImageButton WriteDisk; 
GImageButton StartWrite; 
GCheckbox verifyCheck; 
GImageButton AutoWrite; 
GCheckbox pre_erase2; 
GCheckbox indexAlign; 
GPanel UtilityPanel; 
GImageButton Format; 
GImageButton Cleaning; 
GImageButton AutoFormat; 
GDropList dropList2; 
GCheckbox verifyFormat; 
GCheckbox quickFormat; 
GCheckbox pre_erase; 
GImageButton Erase; 
GLabel PlaceholderU; 
GCheckbox indexAlign2; 
GPanel SettingsPanel; 
GButton LoadSettings; 
GButton TestSettings; 
GButton SaveSettings; 
GTextField MotorSpinup_; 
GTextField MotorSpindown_; 
GTextField DriveSelect_; 
GTextField DriveDeselect_; 
GTextField DirChange_; 
GLabel spinup; 
GTextField SideChange_; 
GTextField StepPulse_; 
GTextField StepSettle_; 
GTextField GotoTrack_; 
GLabel Spindown; 
GLabel DriveSelect; 
GLabel DriveDeselect; 
GLabel DirChange; 
GLabel SideChange; 
GLabel StepPulse; 
GLabel StepSettle; 
GLabel gotoTrack; 
GLabel MtpOn; 
GCheckbox mtpMode_; 
GButton reset2DefaultSettings; 
GLabel sdRet; 
GLabel hd; 
GLabel label1; 
GTextField sdRetries_; 
GTextField hdRetries_; 
GImageButton ReadButton; 
GImageButton WriteButton; 
GImageButton UtilityButton; 
GImageButton SettingsButton; 
GPanel panel1; 
GSketchPad activePad; 
GSketchPad DiskInfoPad; 
GSketchPad bitmapPad; 
GLabel label2; 
GLabel label5; 
GLabel label6; 
GImageButton testbutton; 
GPanel SCPPanel; 
GImageButton ReadSCP; 
GImageButton WriteSCP; 
GCustomSlider revsSlider; 
GImageButton scanDisk; 
GCheckbox showhist_; 
GCheckbox showflux_; 
GLabel label7; 
GLabel PlaceholderSCP; 
GCheckbox showdisk_; 
GPanel startEndPanel; 
GLabel starttrack; 
GLabel endtrack; 
GImageButton start_up; 
GImageButton start_down; 
GImageButton end_up; 
GImageButton end_down; 
GLabel StartLabel; 
GLabel EndLabel; 
GImageButton SCPButton; 
GWindow histwindow;
GSketchPad histPad; 
GCheckbox logcb; 
GWindow fluxdetail;
GSketchPad cellPad; 
GImageButton revminus; 
GImageButton revplus; 
GWindow diskwindow;
GSketchPad side0; 
GSketchPad side1; 
public long findMax(int track)
{ 
  long tMax = 0;
  for (int i= 0; i<256; i++)
    if (hist[track][i]>tMax) tMax = hist[track][i];
  return tMax;
}

public class amigaTime {
  private int day, min, ticks;
}


public amigaTime makeTime()
{
  int jm[]={ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
  int dtmon = month();
  int dtmin = minute();
  int dtsec = second();
  int dthour = hour();
  int dtday = day()-1;
  int dtyear = year();
  amigaTime aTime = new amigaTime();
  aTime.min= dthour*60 + dtmin;                /* mins */
  aTime.ticks= dtsec*50;                        /* ticks */

  /*--- days ---*/

  aTime.day= dtday;                         /* current month days */

  /* previous months days downto january */
  if (dtmon>1) {                      /* if previous month exists */
    dtmon--;
    if (dtmon>2 && Year.isLeap(dtyear))    /* months after a leap february */
      jm[2-1]=29;
    while (dtmon>0) {
      aTime.day=aTime.day+jm[dtmon-1];
      dtmon--;
    }
  }

  /* years days before current year downto 1978 */
  if (dtyear>1978) {
    dtyear--;
    while (dtyear>=1978) {
      if (Year.isLeap(dtyear)) {
        aTime.day=aTime.day+366;
      } else
        aTime.day=aTime.day+365;
      dtyear--;
    }
  }
  //    println("days: " + aTime.day + " mins: " + aTime.min + " ticks: " + aTime.ticks);
  return aTime;
  //day*86400+min*60;
}

public void printBuffer() {
  for (int k = 0; k < 11; k++) {
    println("Sector "+k);
    for (int i = 0; i < 16; i++) {
      for (int j = 0; j < 32; j++) {
        System.out.printf("%02x", track[(i*32)+j+k*512]);
      }
      print(" ");
      for (int j = 0; j < 32; j++) {
        System.out.printf("%c", byte2char(track[(i*32)+j+k*512]));
      }
      println();
    }
  }
}

public String parseError(long error)
{
  String tError="None";
  if ((error&0xffffffff)!=0) {
    tError = " HeaderChkSum fail in Sector: ";
  }
  for (int i =0; i<32; i++) {
    if ((error&1)==1)
    {
      tError+=i+" ";
    }
    error=error>>1;
  }
  if ((error)!=0) {
    tError+=" DataChkSum fail in Sector: ";
  }
  for (int i =0; i<32; i++) {
    if ((error&1)==1)
    {
      tError+=i+" ";
    }
    error=error>>1;
  }
  return tError;
}

public void initSerial()
{
  surface.setTitle(version+": Loading Native Serial Library");
  String osName = System.getProperty("os.name");
  String osArch = System.getProperty("os.arch");
  String libName = "";
  String osVersion = System.getProperty("os.version");
  fileSep = System.getProperty("file.separator");
  println(osName + " " + osArch + " " + osVersion);
  if (osName.startsWith("Win")) {
    if (osArch.equals("i386") || osArch.equals("i686") || osArch.equals("x86")) {
      libName=fileSep+"jSSC-2.8_x86.dll";
      version = version +" - "+osName+" 32 bit";
    } else if (osArch.equals("amd64") || osArch.equals("universal")) {
      libName=fileSep+"jSSC-2.8_x86_64.dll";
      version = version +" - "+osName+" 64 bit";
    }
  } else {
    if (osArch.equals("arm")) {
      libName=fileSep+"libjSSC-2.8_arm.so";
      version = version +" - "+ osName + " ARM "+osVersion;
    }
  }
  if (osName.startsWith("Linux")) {
    if (osArch.equals("i386") || osArch.equals("i686") || osArch.equals("x86")) {
      libName=fileSep+"libjSSC-2.8_linux32.so";
      version = version +" - "+osName+" 32 bit";
    } else if (osArch.equals("amd64") || osArch.equals("universal")) {
      libName=fileSep+"libjSSC-2.8_linux64.so";
      version = version +" - "+osName+" 64 bit";
    }
  }
  System.out.println("osName: "+osName + " osArch:" + osArch);
  if (osName.equals("Mac OS X")) {
    if (osArch.equals("x86_64")) {
      libName=fileSep+"libjSSC-2.8_macos64.jnilib";
      version = version + " - "+osName+" 64 bit";
    }
  }

  try {
    System.load(dataPath("")+libName);
  } 
  catch (UnsatisfiedLinkError e) {
    System.err.println("Native code library failed to load.\n" + e);
    version = version +".";
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Unsupported System: "+osName+" "+osArch+" "+osVersion);
    System.exit(0);
  }
  println("Loaded "+dataPath("")+libName);
  surface.setTitle(version+": Searching COM-Port");
  String COMx, COMlist = "";
  try {
    int i = Serial.list().length;
    if (i != 0) {

      if (i >= 2) {

        for (int j = 0; j < i; j++ ) {
          System.out.println(i + ": " + Serial.list()[j]);
          if (osName.startsWith("Win")) {

            COMlist += PApplet.parseChar(j+'a') + " = " + Serial.list()[j];
            //println(Serial.list()[j]);
            if (j < i) COMlist += ",  ";
          } else 
          if (osName.equals("Mac OS X")) {
            if (Serial.list()[j].startsWith("/dev/cu")) {
              COMlist += PApplet.parseChar(j+'a') + " = " + Serial.list()[j];
              //println(Serial.list()[j]);
              if (j < i) COMlist += ",  ";
            }
          } else
          {
            if (Serial.list()[j].startsWith("/dev/ttyACM")) {
              COMlist += PApplet.parseChar(j+'a') + " = " + Serial.list()[j];
              //println(Serial.list()[j]);
              if (j < i) COMlist += ",  ";
            }
          }
        }  // end for (int j = 0; j < i; j++ )

        if (COMlist.endsWith(",  ")) {
          COMlist = COMlist.substring(0, COMlist.length()-3);
        }
        COMx = showInputDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Which COM port is correct? (a,b,..):\n"+COMlist);
        if (COMx == null) exit();
        else if (COMx.isEmpty()) exit(); 
        else
          i = PApplet.parseInt(COMx.toLowerCase().charAt(0) - 'a') + 1;
      } //end if (i >= 2

      String portName = Serial.list()[i-1];
      pName = portName;
      myPort = new Serial(this, portName, 8000000);
    } else {
      showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Device is not connected to the PC,\ndisabling most functions.");
      //System.exit(0);
    }
  }
  catch (Exception e)
  { //Print the type of error
    showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "COM port is not available (may\nbe in use by another program),\ndisabling most functions.");
    println("Error:", e);
    //System.exit(0);
  }
}

public String removeSuffix(String name, int sufflen)
{
  if (name != null && sufflen != 0 && name.charAt(name.length()-(sufflen+1))=='.') {
    return name.substring(0, name.length() - (sufflen+1));
  }
  return name;
}
  public void settings() {  size(600, 580, JAVA2D);  smooth(1); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ADF_Copy_1104" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

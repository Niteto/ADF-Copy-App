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

/* additional code & help for OSX Serialport by Christian Vogelgsang */

boolean HD_allowed = true;
boolean write_SCP = false; //at the moment there is no write function
boolean scpMode = true;
String version = "v1.110";
String versionString = version + " Beta";
Float minVer = 1.110;
String firmware = "unknown";
//import com.fazecast.jSerialComm.*;
import java.io.DataOutputStream;
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
//import java.io.IOException;
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

String fileName = "test.adf"; // fill in
String filePath = "";
String diskName = "ADF-Copy";
String iniFile = "";

import processing.serial.*;
import g4p_controls.*;
import static javax.swing.JOptionPane.*;
import jssc.*;


int bgcolor;			     // Background color
int fgcolor;			     // Fill color
Serial myPort;                       // The serial port
byte[] readString = new byte[512*11];
long errormap[] = new long[168];
byte bitMapArray[] = new byte[2*1760];
int bitMapSize = 0;
volatile color trackmap[] = new color[168]; 
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
Float myFontSize = 13.0;
PFont myPFont = null;

import java.io.File;
import org.ini4j.*;
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

boolean loadIni(String iniName)
{
  try {
    File iniFile = new File(iniName);
    println("iniFile: " + iniFile);
    Wini ini = new Wini(iniFile);
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
    println("exception: " + e);
    System.err.println(iniFile + " not found, creating default ini file.");
    return false;
  }
  return true;
}

boolean saveIni(String iniFile)
{
  try {
    File f = new File(iniFile);
    if (!f.exists()) {
      //      f.getParentFile().mkdirs();
      f.createNewFile();
    }    
    Wini ini = new Wini(f);
    ini.put("ADF-Copy", "version", versionString);
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

void exit() {
  if (myPort!=null) {
    myPort.write("nobusy\n");
    myPort.write("mtp\n");
    myPort.clear();
  }
  saveIni(iniFile);
  println("exiting program...");
  super.exit();
}

String iniPath () { 
  String pathName; // path to create new file
  pathName = getClass().getProtectionDomain().getCodeSource().getLocation().getPath(); // get the path of the .jar
  pathName = pathName.substring(1, pathName.lastIndexOf("/") ); //create a new string by removing the garbage
  //  System.out.println(pathName); // this is for debugging - see the results
  return pathName;
}

void setup() {
  //fullScreen();
  //surface.setSize(600,580);
  size(600, 560, JAVA2D);  // Stage size
  //size(1200, 720, JAVA2D);  // Stage size
  println("\n------------------------------------------------------------");
  println("ADF-Copy App - Frontend to Read and Write Amiga Floppy Disks");
  println("Copyright (C) 2020 Dominik Tonn (nick@niteto.de)");
  println("visit http://nicklabor.niteto.de for Infos and Updates");
  println("------------------------------------------------------------\n");
  java.awt.Frame f =  (java.awt.Frame) ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame();
  //println(height);
  //println(f.size().height);
  //f.setSize(600, 590);
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
  println("user.name: " + System.getProperty("user.name"));
  println("user.home: " + System.getProperty("user.home"));
  println("user.dir: " + System.getProperty("user.dir"));

  println("Java runtime: " + System.getProperty("java.runtime.version"));
  if (System.getProperty("java.awt.version")!=null) println("Java awt: " + System.getProperty("java.awt.version"));
  String[] javaVersionElements = System.getProperty("java.runtime.version").split("\\.|_|\\+|-|-b");
  major   = Integer.parseInt(javaVersionElements[1]);
  minor   = Integer.parseInt(javaVersionElements[2]);
  update  = Integer.parseInt(javaVersionElements[3]);
  println("Java Vendor: " + System.getProperty("java.vendor"));
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
  smooth(1);
  for (int i = 0; i<168; i++) {
    trackmap[i]=#ffffff;
  }
  for (int i =0; i<maxSectors; i++)
  {
    sectorTable[i] = new SectorTable();
    extTrack[i] = new Sector();
    extTrack[i].data = new byte[512];
    extTrack[i].os_recovery = new byte[16];
  }
  int waitCounter = 0;
  surface.setTitle(versionString+": Loading Checkmark Image");
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
  surface.setTitle(versionString+": Loading InsertDisk Image");
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
  float firmwareVersion = (float)9.999;
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
    surface.setTitle(versionString+": Connecting to Hardware...");
    myPort.write("ver\n");
    int timeout = 40;
    while (myPort.available()==0) {
      delay(100);
      surface.setTitle(versionString+": Connecting to Hardware... "+timeout);
      timeout--;
      if (timeout<=0) {
        if (showConfirmDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), "Communication timed out, please try again.", "Timeout", YES_NO_OPTION)==0)
        {
          timeout = 40;
          myPort.clear();
          myPort.write("ver\n");
        } else {
          System.exit(0);
        }
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
  surface.setTitle("ADF-Copy "+versionString);
  background(230);
}

void draw() {
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
  if (focused) {
    ((processing.awt.PSurfaceAWT.SmoothCanvas)histwindow.getSurface().getNative()).getFrame().toFront();
    if (showflux) ((processing.awt.PSurfaceAWT.SmoothCanvas)fluxwindow.getSurface().getNative()).getFrame().toFront();
    if (showdisk) ((processing.awt.PSurfaceAWT.SmoothCanvas)diskwindow.getSurface().getNative()).getFrame().toFront();
  }
}

int gridClick(int side, int x, int y, int button)
{
  x=x/16;
  y=y/16;
  if (x<1 | x>10) return -1; 
  if (y<1 | y>9) return -1; 
  int trackClick = ((y-1)*10 + (x-1))*2 + side;
  if (trackClick > 167) return -1;
  //println("Track: " + trackClick + " @ " + millis());
  return trackClick;
}

void mouseReleased() {
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
    drawHistwindow(histogram, focusTrack);
    drawFluxwindow(cellgraph, focusTrack, false);
    //for (int j = 0; j <= revsInBuffer; j++)
    //  println("revPointer["+ focusTrack +"]["+j+"]: " + revpointer[focusTrack][j]);
  } else drawStatus(status, "");
  grid(upperGrid, 0);
  grid(lowerGrid, 1);
}

void compareSelected(File selection) {
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

void readscp(File selection) {
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

void scandisk()
{
  scanonly = true;
  readscp_main();
  scanonly = false;
}

void readSelected(File selection) {
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

void folderSelected(File selection) {
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

void writeSelected(File selection) {
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

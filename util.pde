long findMax(int track)
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

void printBuffer() {
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

String parseError(long error)
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

void initSerial()
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
          //System.out.println(i + ": " + Serial.list()[j]);
          if (osName.startsWith("Win")) {

            COMlist += char(j+'a') + " = " + Serial.list()[j];
            //println(Serial.list()[j]);
            if (j < i) COMlist += ",  ";
          } else 
          if (osName.equals("Mac OS X")) {
            if (Serial.list()[j].startsWith("/dev/cu")) {
              COMlist += char(j+'a') + " = " + Serial.list()[j];
              //println(Serial.list()[j]);
              if (j < i) COMlist += ",  ";
            }
          } else
          {
            if (Serial.list()[j].startsWith("/dev/ttyACM")) {
              COMlist += char(j+'a') + " = " + Serial.list()[j];
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
          i = int(COMx.toLowerCase().charAt(0) - 'a') + 1;
      } //end if (i >= 2

      String portName = Serial.list()[i-1];
      pName = portName;
      myPort = new Serial(this, portName, 500000);
      myPort.stop(); // workaround for baudrate problems with some linux derivates.
      myPort = new Serial(this, portName, 4608000);
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

String removeSuffix(String name, int sufflen)
{
  if (name != null && sufflen != 0 && name.charAt(name.length()-(sufflen+1))=='.') {
    return name.substring(0, name.length() - (sufflen+1));
  }
  return name;
}

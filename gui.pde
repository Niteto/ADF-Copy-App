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
    println("visible:" + diskwindow.isVisible());
    println((java.awt.Frame) ((processing.awt.PSurfaceAWT.SmoothCanvas)fluxwindow.getSurface().getNative()).getFrame());
    println((java.awt.Frame) ((processing.awt.PSurfaceAWT.SmoothCanvas)diskwindow.getSurface().getNative()).getFrame());
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
  fluxwindow.setVisible(false);
  diskwindow.setVisible(false);
  fluxwindow.draw();
  diskwindow.draw();
} //_CODE_:ReadButton:398266:

public void WriteButton_(GImageButton source, GEvent event) { //_CODE_:WriteButton:795774:
  drawActive(active, 1);
  fluxwindow.setVisible(false);
  diskwindow.setVisible(false);
  fluxwindow.draw();
  diskwindow.draw();
} //_CODE_:WriteButton:795774:

public void UtilityButton_(GImageButton source, GEvent event) { //_CODE_:UtilityButton:869569:
  drawActive(active, 3);
  fluxwindow.setVisible(false);
  diskwindow.setVisible(false);
  fluxwindow.draw();
  diskwindow.draw();
} //_CODE_:UtilityButton:869569:

public void SettingsButton_(GImageButton source, GEvent event) { //_CODE_:SettingsButton:641704:
  if (myPort!=null) getSettings();
  drawActive(active, 4);
  fluxwindow.setVisible(false);
  diskwindow.setVisible(false);
  fluxwindow.draw();
  diskwindow.draw();
} //_CODE_:SettingsButton:641704:

public void panel1_Click2(GPanel source, GEvent event) { //_CODE_:panel1:487390:
  //println("panel1 - GPanel >> GEvent." + event + " @ " + millis());
} //_CODE_:panel1:487390:

public void testbutton_(GImageButton source, GEvent event) { //_CODE_:testbutton:828692:
  //println("fenster2 - GImageButton >> GEvent." + event + " @ " + millis());
  if (revsInBuffer==0) return;
  if (focusTrack!=-1) { 
    decode2mfm(focusTrack, revcurrent, false);
    println("xx"+revpointer[focusTrack][revcurrent+1]);
    scan4Marks(focusTrack, revcurrent, false);
    decodeTrack(focusTrack, sectorCnt, false);
  } else
  {
    decode2mfm(lastTrack, revcurrent, false);
    println("xx"+revpointer[lastTrack][revcurrent+1]);
    scan4Marks(lastTrack, revcurrent, false);
    decodeTrack(lastTrack, sectorCnt, false);
  }
  drawDiskwindow();
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
  if (showhist) drawHistwindow(histogram, 0);
} //_CODE_:showhist_:894426:

public void showflux_clicked(GCheckbox source, GEvent event) { //_CODE_:showflux_:464322:
  showflux = showflux_.isSelected();
  fluxwindow.setVisible(showflux);
  fluxwindow.draw();
  if (showflux) drawFluxwindow(cellgraph, 0, false);
} //_CODE_:showflux_:464322:

public void showdisk_clicked(GCheckbox source, GEvent event) { //_CODE_:showdisk_:455523:
  showdisk = showdisk_.isSelected();
  diskwindow.setVisible(showdisk);
  if (showdisk) drawDiskwindow();
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
  fluxwindow.setVisible(showflux);
  diskwindow.setVisible(showdisk);
  histwindow.setVisible(showhist);
  drawFluxwindow(cellgraph, focusTrack, false);
  drawDiskwindow();
  fluxwindow.draw();
  diskwindow.draw();
  if (myPort!=null) {
    myPort.write("getstream\n");
    int zeit = millis();
    while (myPort.available()<204800)
    {
      delay(1);
    }
    zeit = millis()-zeit;
    int transferrate = round((204800.f/((float)zeit/1000))/1024);
    println("Transfertest took: " + zeit + "ms Transferrate = " + transferrate + " kbyte/s");
    myPort.clear();
    if (transferrate < 800) {
      showMessageDialog(((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame(), 
        "USB connection too slow for SCP mode\nTransferrate = " + transferrate + "kb/s\n800kb/s or more recommended", "Bandwidth problems", INFORMATION_MESSAGE);
      scpMode = false;
      disableButton(ReadSCP);
      disableButton(WriteSCP);
      disableButton(scanDisk);
    }
  }
} //_CODE_:SCPButton:608300:

synchronized public void histwin_draw1(PApplet appc, GWinData data) { //_CODE_:histwindow:588696:
  appc.background(230);
} //_CODE_:histwindow:588696:

public void logcb_(GCheckbox source, GEvent event) { //_CODE_:logcb:766328:
  //println("logcb - GCheckbox >> GEvent." + event + " @ " + millis());
  if (focusTrack!=-1) 
    drawHistwindow(histogram, focusTrack);
  else
    drawHistwindow(histogram, lastTrack);
} //_CODE_:logcb:766328:

synchronized public void fluxwin_draw1(PApplet appc, GWinData data) { //_CODE_:fluxwindow:466459:
  appc.background(230);
} //_CODE_:fluxwindow:466459:

public void revminus_click(GImageButton source, GEvent event) { //_CODE_:revminus:354151:
  if (revsInBuffer == 0) return;
  revcurrent--;
  if (revcurrent<0) revcurrent = 0;
  if (focusTrack!=-1) 
    drawFluxwindow(cellgraph, focusTrack, false);
  else
    drawFluxwindow(cellgraph, lastTrack, false);
  drawDiskwindow();
} //_CODE_:revminus:354151:

public void revplus_click(GImageButton source, GEvent event) { //_CODE_:revplus:301771:
  if (revsInBuffer == 0) return;
  revcurrent++;
  if (revcurrent>=revsInBuffer) revcurrent = revsInBuffer-1;
  if (focusTrack!=-1) 
    drawFluxwindow(cellgraph, focusTrack, false);
  else
    drawFluxwindow(cellgraph, lastTrack, false);
  drawDiskwindow();
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
  hdRet = new GLabel(this, 140, 40, 90, 20);
  hdRet.setTextAlign(GAlign.RIGHT, GAlign.MIDDLE);
  hdRet.setText("HD Retries:");
  hdRet.setOpaque(false);
  drvRestartLabel = new GLabel(this, 130, 200, 130, 20);
  drvRestartLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  drvRestartLabel.setText("<- requires drive restart");
  drvRestartLabel.setOpaque(false);
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
  SettingsPanel.addControl(hdRet);
  SettingsPanel.addControl(drvRestartLabel);
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
  panel1 = new GPanel(this, 10, 10, 100, 190, "");
  panel1.setCollapsible(false);
  panel1.setDraggable(false);
  panel1.setOpaque(false);
  panel1.addEventHandler(this, "panel1_Click2");
  activePad = new GSketchPad(this, 0, 0, 100, 190);
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
  histwindow = GWindow.getWindow(this, "Histogram", 0, 0, 600, 130, JAVA2D);
  histwindow.noLoop();
  histwindow.addDrawHandler(this, "histwin_draw1");
  histPad = new GSketchPad(histwindow, 0, 0, 600, 130);
  logcb = new GCheckbox(histwindow, 0, 105, 50, 20);
  logcb.setText("log10");
  logcb.setOpaque(false);
  logcb.addEventHandler(this, "logcb_");
  logcb.setSelected(true);
  fluxwindow = GWindow.getWindow(this, "Fluxwindow", 0, 0, 830, 430, JAVA2D);
  fluxwindow.noLoop();
  fluxwindow.addDrawHandler(this, "fluxwin_draw1");
  cellPad = new GSketchPad(fluxwindow, 0, 0, 830, 430);
  revminus = new GImageButton(fluxwindow, 10, 10, 20, 20, new String[] { "left.png", "left.png", "left.png" } );
  revminus.addEventHandler(this, "revminus_click");
  revplus = new GImageButton(fluxwindow, 35, 10, 20, 20, new String[] { "right.png", "right.png", "right.png" } );
  revplus.addEventHandler(this, "revplus_click");
  diskwindow = GWindow.getWindow(this, "Disk", 0, 0, 830, 402, JAVA2D);
  diskwindow.noLoop();
  diskwindow.addDrawHandler(this, "disk_draw1");
  side0 = new GSketchPad(diskwindow, 10, 1, 400, 400);
  side1 = new GSketchPad(diskwindow, 420, 1, 400, 400);
  histwindow.loop();
  fluxwindow.loop();
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
GLabel hdRet; 
GLabel drvRestartLabel; 
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
GWindow fluxwindow;
GSketchPad cellPad; 
GImageButton revminus; 
GImageButton revplus; 
GWindow diskwindow;
GSketchPad side0; 
GSketchPad side1; 

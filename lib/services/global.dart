import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

List<File> imagesList = [];
List<File> cameraImages = [];
int cameraClickCount = 0;

String examURL = '';
bool versionCheck = true;
final primaryColor = const Color(0xFF22a3ce);
bool secureMode = false;
Timer timer2;

void checkPinningMode() async{
  const platform = const MethodChannel('com.ucanapply.ravi/flutter_ravi');
  var result = await platform.invokeMethod('isInLockTaskMode');
  print(result);
}

String baseUrl = 'https://devuca.ucanapply.com/onlineexam/public/ucapdfmaker-version';

List appList = [
  'air.MingleViewMobile',
  'appear.in.app',
  'com.anydesk.anydeskandroid',
  'com.apowersoft.mirror',
  'com.callmeet.app',
  'com.cisco.webex.meetings',
  'com.devolutions.remotedesktopmanager',
  'com.embarcadero.LiteManager',
  'com.google.android.apps.meetings',
  'com.google.android.apps.tachyon',
  //'com.google.android.talk',
  'com.google.chromeremotedesktop',
  'com.gotomeeting',
  'com.iiordanov.freeaRDP',
  'com.iiordanov.freebVNC',
  'com.livescreenapp.free',
  'com.microsoft.office.lync15',
  'com.microsoft.rdc.android',
  'com.microsoft.rdc.androidx',
  'com.microsoft.teams',
  'com.mikogo.android',
  'com.mobzapp.screenstream.trial',
  'com.mteducare.roboconnect',
  'com.realvnc.viewer.android',
  'com.remoteutilities.mviewer',
  'com.sa.screensharing.screenshare.screenmirror.miracastscreen',
  'com.screencast',
  'com.showmypc',
  'com.skype.insiders',
  'com.skype.raider',
  'com.startmeeting',
  'com.steppschuh.remotecontrolcollection',
  'com.teamviewer.teamviewer.market.mobile',
  'com.technoplanners.miracastscreen',
  'com.uhssystems.ultraconnect',
  'de.twokit.screen.mirroring.app.pro',
  'de.twokit.screen.mirroring.app.roku',
  'in.meetnow',
  'net.serverdata.newmeeting',
  'net.serverdata.onlinemeeting',
  'nfo.oneassist',
  'org.jitsi.meet',
  'org.toremote.rdpdemo',
  'pl.pcss.myconf',
  'ru.rmansys.mviewer',
  'us.zoom.videomeetings',
  'us.zoom.zrc',
];

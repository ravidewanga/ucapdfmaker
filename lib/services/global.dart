import 'dart:io';
import 'package:flutter/material.dart';

final primaryColor = const Color(0xFF22a3ce);

List<File> imagesList = [];
List<File> cameraImages = [];
int cameraClickCount = 0;

bool versionCheck = true;
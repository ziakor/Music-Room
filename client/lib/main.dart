import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:music_room/src/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(RouterApp());
}

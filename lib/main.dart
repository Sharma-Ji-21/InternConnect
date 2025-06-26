import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intern_connect/company_screen.dart';
import 'package:intern_connect/login_screen.dart';
import 'package:intern_connect/student_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(
          // studentEmail: 'om@gmail.com',
          // email: 'apple@gmail.com',
          ),
    );
  }
}

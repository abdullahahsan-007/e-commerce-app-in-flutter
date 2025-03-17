import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/signin_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyhMmivxw9Kk7mG3uIyXjBX4-NO_e8hghZAI",
        authDomain: "ecommerce-2f775.firebaseapp.com",
        projectId: "ecommerce-2f775",
        storageBucket: "ecommerce-2f775.appspot.com",
        messagingSenderId: "750743806204",
        appId: "1:750743806204:web:629bef4c9888c6240cf779"),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green), // Changed to green
      home: const SignInScreen(),
    );
  }
}

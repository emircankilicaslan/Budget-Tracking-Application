import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/provider/transaction_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCqiuU245LOixiv_Kf2zgVJSGRnksfnCZU',
      authDomain: 'flutterapp-d9fa1.firebaseapp.com',
      projectId: 'flutterapp-d9fa1',
      storageBucket: 'flutterapp-d9fa1.appspot.com',
      messagingSenderId: '669025553213',
      appId: '1:669025553213:web:6ec9c652019f53d7f69354',
      measurementId: 'G-C7XPS73G4Q',
    ),
  );

  // 🔧 Initialize sqflite_ffi for desktop (Windows/macOS/Linux)
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionProvider(),
      child: MaterialApp(
        title: 'Flutter App',
        theme: ThemeData(
          colorSchemeSeed: Colors.purple,
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

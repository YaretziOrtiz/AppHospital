import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/firebase_options.dart';
import 'screens/login/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MedLinkApp());
}

class MedLinkApp extends StatelessWidget {
  const MedLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedLink',
      debugShowCheckedModeBanner: false,

      // ============================================================
      // LOCALIZACIÓN (Para DatePicker en español)
      // ============================================================
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'MX'),
        Locale('en', 'US'),
      ],

      // ============================================================
      // TEMA DE LA APLICACIÓN
      // ============================================================
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xffF5F8FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),

      home: const LoginScreen(),
    );
  }
}

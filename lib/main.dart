import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:namangantoshkent/screens/drivers/account_screen.dart';
import 'package:namangantoshkent/screens/home_screen.dart';
import 'package:namangantoshkent/screens/sign/login_screen.dart';
import 'package:namangantoshkent/screens/drivers/profile_set_up.dart';
import 'package:namangantoshkent/services/firebase_streem.dart';

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
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      routes: {
        '/': (context) => const FirebaseStream(),
        '/home': (context) => const HomeScreen(),
        '/account': (context) => const AccountScreen(),
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => ProfilePage(),
        //'/chat': (context) => ChatPage(),
      },
      initialRoute: '/',
    );
  }
}

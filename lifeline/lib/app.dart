import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'ui/splash/splash_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/search/search_screen.dart';
import 'ui/profile/profile_screen.dart';

class LifeLineApp extends StatelessWidget {
  const LifeLineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeLine',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/search': (context) => SearchScreen(),
        '/profile': (context) => ProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

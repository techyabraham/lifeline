import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Firebase Options (required)
import 'firebase_options.dart';

// Screens
import 'ui/splash/splash_screen.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/search/search_screen.dart';
import 'ui/profile/profile_screen.dart';

// Bloc / Repositories
import 'blocs/theme/theme_bloc.dart';
import 'blocs/contacts/contacts_bloc.dart';
import 'repositories/contacts_repository.dart';
import 'services/api_service.dart';

// Theme
import 'config/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive for offline caching
  await Hive.initFlutter();
  await Hive.openBox('contacts_cache');

  // Initialize Google AdMob
  await MobileAds.instance.initialize();

  final apiService = ApiService();
  final contactsRepo = ContactsRepository(apiService: apiService);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(create: (_) => ContactsBloc(repository: contactsRepo)),
      ],
      child: const LifeLineApp(),
    ),
  );
}

class LifeLineApp extends StatelessWidget {
  const LifeLineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LifeLine',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/splash',
          routes: {
            '/splash': (_) => const SplashScreen(),
            '/onboarding': (_) => const OnboardingScreen(),
            '/home': (_) => const HomeScreen(),
            '/search': (_) => const SearchScreen(),
            '/profile': (_) => const ProfileScreen(),
          },
        );
      },
    );
  }
}

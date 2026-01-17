// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

// Core screens
import 'ui/splash/splash_screen.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/search/search_screen.dart';
import 'ui/profile/profile_screen.dart';
import 'ui/contacts/contacts_screen.dart';

// Emergency flow (Option A)
import 'ui/emergency_flow/flow_controller.dart';
import 'ui/emergency_flow/screens/home_screen.dart' as ef_home;
import 'ui/emergency_flow/screens/location_screen.dart' as ef_loc;
import 'ui/emergency_flow/screens/emergency_selection_screen.dart' as ef_sel;
import 'ui/emergency_flow/screens/results_screen.dart' as ef_res;
import 'ui/emergency_flow/screens/calling_screen.dart' as ef_call;

// Bloc / Repositories
import 'blocs/theme/theme_bloc.dart';
import 'blocs/contacts/contacts_bloc.dart';
import 'repositories/contacts_repository.dart';
import 'services/api_service.dart';

// Theme
import 'config/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  await Hive.openBox('contacts_cache');

  await MobileAds.instance.initialize();

  final apiService = ApiService();
  final contactsRepo = ContactsRepository(apiService: apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmergencyFlowController()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
          BlocProvider<ContactsBloc>(
            create: (_) => ContactsBloc(repository: contactsRepo),
          ),
        ],
        child: const LifeLineApp(),
      ),
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
            // Core
            '/splash': (_) => const SplashScreen(),
            '/onboarding': (_) => const OnboardingScreen(),
            '/home': (_) => const HomeScreen(),
            '/search': (_) => const SearchScreen(),
            '/profile': (_) => const ProfileScreen(),
            '/contacts': (_) => const ContactsScreen(),

            // Emergency Flow (Primary)
            '/emergency/home': (_) => const ef_home.EmergencyHomeScreen(),
            '/emergency/location': (_) =>
                const ef_loc.EmergencyLocationScreen(),
            '/emergency/select': (_) => const ef_sel.EmergencySelectionScreen(),
            '/emergency/results': (_) => const ef_res.EmergencyResultsScreen(),
          },

          /// --------------------------------------------------
          /// Dynamic routes (arguments-based navigation)
          /// --------------------------------------------------
          onGenerateRoute: (settings) {
            if (settings.name == '/emergency/calling') {
              final args = settings.arguments as Map<String, dynamic>?;

              return MaterialPageRoute(
                builder: (_) => ef_call.EmergencyCallingScreen(
                  providerName: args?['providerName'] ?? 'Unknown',
                  phone: args?['phone'] ?? '',
                ),
              );
            }

            // Backward compatibility aliases
            if (settings.name == '/results') {
              return MaterialPageRoute(
                builder: (_) => const ef_res.EmergencyResultsScreen(),
                settings: settings,
              );
            }

            if (settings.name == '/calling') {
              final args = settings.arguments as Map<String, dynamic>?;

              return MaterialPageRoute(
                builder: (_) => ef_call.EmergencyCallingScreen(
                  providerName: args?['providerName'] ?? 'Unknown',
                  phone: args?['phone'] ?? '',
                ),
              );
            }

            return null;
          },
        );
      },
    );
  }
}

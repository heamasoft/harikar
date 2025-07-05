import 'dart:async'; // ← for runZonedGuarded
import 'package:flutter/foundation.dart'; // kReleaseMode & FlutterError
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user_model.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_category_screen.dart';
import 'screens/add_subcategory_screen.dart';
import 'screens/view_users_screen.dart';
import 'screens/work_details_page.dart';
import 'screens/register_screen.dart';
import 'screens/forget_password_screen.dart';
import 'screens/AboutUsPage.dart';
import 'screens/AdsManagementPage.dart';
import 'screens/DetailsPage.dart';
import 'screens/InsertDetailsPage.dart';
import 'screens/UsersPage.dart';

/// ───────────────── Locale provider ─────────────────
class LocaleProvider extends ChangeNotifier {
  Locale _locale;
  LocaleProvider(this._locale);

  Locale get locale => _locale;

  void setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }
}

/// ───────────────────────── main() ─────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details); // shows in debug
    if (kReleaseMode) {
      // In release, at least print to console for CI logs
      print('⚠️  FlutterError: ${details.exceptionAsString()}');
      print(details.stack);
    }
  };

  // Catch any unhandled async errors (Dart side)
  runZonedGuarded(() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language') ?? 'ku';

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => UserModel()..loadUserFromPreferences(),
          ),
          ChangeNotifierProvider(
            create: (_) => LocaleProvider(
                Locale(savedLanguage, savedLanguage == 'ku' ? 'IQ' : '')),
          ),
        ],
        child: const LegaryanKare(),
      ),
    );
  }, (error, stack) {
    // This prints in release, so the crash reason appears in device / Codemagic logs
    print('⚠️  Uncaught Dart error: $error');
    print(stack);
  });
}

/// ──────────────────────── The App ────────────────────────
class LegaryanKare extends StatelessWidget {
  const LegaryanKare({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'ليگريان كارێ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoKufi',
        primarySwatch: Colors.deepPurple,
      ),
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('ku', 'IQ'),
        Locale('ar', ''),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale?.languageCode == 'ku') {
          // Fallback widgets to English, custom strings stay Kurdish
          return const Locale('en', 'US');
        }
        return locale;
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SplashScreen(),
      routes: {
        '/login': (_) => LoginScreen(),
        '/dashboard': (_) => DashboardScreen(),
        '/add_category': (_) => AddCategoryScreen(),
        '/add_subcategory': (_) => AddSubCategoryScreen(),
        '/view_users': (_) => ViewUsersScreen(),
        '/insert_details': (_) => InsertDetailsPage(),
        '/show_details': (_) => DetailsPage(),
        '/show_work': (_) => WorkDetailsPage(),
        '/register': (_) => RegisterScreen(),
        '/forget_password': (_) => ForgetPasswordScreen(),
        '/about': (_) => AboutUsPage(),
        '/user2': (_) => UsersPage(),
        '/ads': (_) => AdsManagementPage(),
      },
    );
  }
}

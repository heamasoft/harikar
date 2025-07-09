import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kReleaseMode
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

/// Global navigator key to show dialogs without explicit BuildContext
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load and clear any saved error from previous run
  final prefs = await SharedPreferences.getInstance();
  final String? lastError = prefs.getString('last_error');
  if (lastError != null) {
    await prefs.remove('last_error');
  }

  // Capture Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) async {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      await prefs.setString('last_error', details.exceptionAsString());
    }
  };

  // Run the app inside a guarded zone to catch async errors
  runZonedGuarded(() async {
    final savedLanguage = prefs.getString('language') ?? 'ku';

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => UserModel()..loadUserFromPreferences(),
          ),
          ChangeNotifierProvider(
            create: (_) => LocaleProvider(
              Locale(
                savedLanguage,
                savedLanguage == 'ku' ? 'IQ' : '',
              ),
            ),
          ),
        ],
        child: LegaryanKare(initialError: lastError),
      ),
    );
  }, (Object error, StackTrace stack) async {
    if (kReleaseMode) {
      await prefs.setString('last_error', error.toString());
    }
  });
}

class LegaryanKare extends StatefulWidget {
  final String? initialError;
  const LegaryanKare({this.initialError, Key? key}) : super(key: key);

  @override
  _LegaryanKareState createState() => _LegaryanKareState();
}

class _LegaryanKareState extends State<LegaryanKare> {
  @override
  void initState() {
    super.initState();
    if (widget.initialError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: navigatorKey.currentState!.overlay!.context,
          builder: (context) => AlertDialog(
            title: const Text('Unexpected Error'),
            content: SingleChildScrollView(
              child: Text(widget.initialError!),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
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

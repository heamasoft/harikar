// lib/main.dart

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

/// A global key so we can show dialogs without needing a BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load any saved error from the previous run
  final prefs = await SharedPreferences.getInstance();
  final String? lastError = prefs.getString('last_error');
  if (lastError != null) {
    await prefs.remove('last_error');
  }

  // Catch Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) async {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      await prefs.setString('last_error', details.exceptionAsString());
    }
  };

  // Catch all other unhandled errors
  runZonedGuarded(
    () {
      runApp(AppRoot(initialError: lastError));
    },
    (error, stack) async {
      if (kReleaseMode) {
        await prefs.setString('last_error', error.toString());
      }
    },
  );
}

/// Wraps the app in all the providers, including our LocaleProvider.
class AppRoot extends StatelessWidget {
  final String? initialError;
  const AppRoot({this.initialError, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserModel()..loadUserFromPreferences(),
        ),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: ErrorHandler(initialError: initialError, child: HarikarApp()),
    );
  }
}

/// Shows an error dialog if we saved one on the last run.
class ErrorHandler extends StatefulWidget {
  final String? initialError;
  final Widget child;
  const ErrorHandler({
    required this.initialError,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  _ErrorHandlerState createState() => _ErrorHandlerState();
}

class _ErrorHandlerState extends State<ErrorHandler> {
  @override
  void initState() {
    super.initState();
    if (widget.initialError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: navigatorKey.currentState!.overlay!.context,
          builder: (_) => AlertDialog(
            title: const Text('Unexpected Error'),
            content: SingleChildScrollView(child: Text(widget.initialError!)),
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
  Widget build(BuildContext context) => widget.child;
}

/// Holds the current locale and persists it across restarts.
class LocaleProvider extends ChangeNotifier {
  Locale _locale;
  LocaleProvider([String code = 'ku'])
      : _locale = Locale(code, code == 'ku' ? 'IQ' : '');

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }
}

/// The root widget of your app.
class HarikarApp extends StatelessWidget {
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
      supportedLocales: const [Locale('ku', 'IQ'), Locale('ar', '')],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale?.languageCode == 'ku') {
          return const Locale('ku', 'IQ');
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
        '/show_work': (_) => WorkDetailsPage(),
        '/register': (_) => RegisterScreen(),
        '/forget_password': (_) => ForgetPasswordScreen(),
        '/show_details': (_) => DetailsPage(),
        '/insert_details': (_) => InsertDetailsPage(),
        '/user2': (_) => UsersPage(),
        '/ads': (_) => AdsManagementPage(),
        '/about': (_) => AboutUsPage(),
      },
    );
  }
}

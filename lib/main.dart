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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      print('Flutter error: ${details.exception}');
      print('Stack trace: ${details.stack}');
    }
  };

  runZonedGuarded(() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language') ?? 'ku';

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => UserModel()..loadUserFromPreferences()),
          ChangeNotifierProvider(
            create: (_) => LocaleProvider(
              Locale(savedLanguage, savedLanguage == 'ku' ? 'IQ' : ''),
            ),
          ),
        ],
        child: LegaryanKare(),
      ),
    );
  }, (error, stack) {
    if (kReleaseMode) {
      print('Uncaught error: $error');
      print('Stack trace: $stack');
    }
  });
}

class LegaryanKare extends StatelessWidget {
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
      supportedLocales: [
        Locale('ku', 'IQ'),
        Locale('ar', ''),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale?.languageCode == 'ku') {
          return Locale('en', 'US');
        }
        return locale;
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/add_category': (context) => AddCategoryScreen(),
        '/add_subcategory': (context) => AddSubCategoryScreen(),
        '/view_users': (context) => ViewUsersScreen(),
        '/insert_details': (context) => InsertDetailsPage(),
        '/show_details': (context) => DetailsPage(),
        '/show_work': (context) => WorkDetailsPage(),
        '/register': (context) => RegisterScreen(),
        '/forget_password': (context) => ForgetPasswordScreen(),
        '/about': (context) => AboutUsPage(),
        '/user2': (context) => UsersPage(),
        '/ads': (context) => AdsManagementPage(),
      },
    );
  }
}

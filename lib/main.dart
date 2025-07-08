import 'dart:async';
import 'package:flutter/foundation.dart'; // kReleaseMode
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/simple_logger.dart';

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

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimpleLogger.init();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    SimpleLogger.log('Flutter error: ${details.exception}\n${details.stack}');
  };

  runZonedGuarded(() async {
    final prefs = await SharedPreferences.getInstance();
    final supported = ['ku', 'ar'];
    var saved = prefs.getString('language') ?? 'ku';
    if (!supported.contains(saved)) saved = 'ku';

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => UserModel()..loadUserFromPreferences()),
          ChangeNotifierProvider(
              create: (_) =>
                  LocaleProvider(Locale(saved, saved == 'ku' ? 'IQ' : ''))),
        ],
        child: HarikarApp(),
      ),
    );
  }, (error, stack) {
    SimpleLogger.log('Uncaught: $error\n$stack');
  });
}

class HarikarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return MaterialApp(
      title: 'ليگريان كارێ',
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(fontFamily: 'NotoKufi', primarySwatch: Colors.deepPurple),
      locale: localeProvider.locale,
      supportedLocales: const [Locale('ku', 'IQ'), Locale('ar', '')],
      localeResolutionCallback: (locale, _) =>
          locale?.languageCode == 'ku' ? const Locale('en', 'US') : locale,
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

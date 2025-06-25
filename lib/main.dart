import 'package:Harikar/screens/AboutUsPage.dart';
import 'package:Harikar/screens/AdsManagementPage.dart';
import 'package:Harikar/screens/DetailsPage.dart';
import 'package:Harikar/screens/InsertDetailsPage.dart';
import 'package:Harikar/screens/UsersPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your other screens and models here
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

/// A simple provider to manage the current locale.
class LocaleProvider extends ChangeNotifier {
  Locale _locale;
  LocaleProvider(this._locale);

  Locale get locale => _locale;

  void setLocale(Locale locale) async {
    _locale = locale;
    // Persist the selected language in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get saved language; default to Kurdish ('ku') if none exists
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
      child: LegaryanKare(),
    ),
  );
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
      // Use the currently selected locale for your app’s UI strings.
      locale: localeProvider.locale,
      supportedLocales: [
        Locale('ku', 'IQ'), // Kurdish (your custom strings)
        Locale('ar', ''), // Arabic
      ],
      // Fallback: if Kurdish is selected, use a supported locale (like English)
      // for Material/Cupertino widgets.
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale?.languageCode == 'ku') {
          // Fallback to English for system widgets. Your custom texts remain Kurdish.
          return Locale('en', 'US');
        }
        return locale;
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SplashScreen(), // Always start with SplashScreen
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

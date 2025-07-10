// lib/widgets/custom_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../screens/AboutUsPage.dart';
import '../screens/FeedbackPage.dart';
import '../screens/feedback_screen.dart';
import '../screens/profile_screen.dart';
// Import LocaleProvider from your main file (adjust path if needed)
import '../main.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    List<Widget> menuItems = [];

    if (user.role == 'admin') {
      menuItems = [
        _buildMenuItem(
          icon: Icons.home,
          title: isArabic ? "الصفحة الرئيسية" : 'پەڕەی سەرەکی',
          onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
        ),
        _buildMenuItem(
          icon: Icons.person,
          title: isArabic ? "الملف الشخصي" : 'پەڕەی کەسی',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  userName: user.name,
                  phoneNumber: user.phoneNumber,
                ),
              ),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.category,
          title: isArabic ? "إضافة وظيفة" : 'زیادکردنی کار',
          onTap: () => Navigator.pushNamed(context, '/add_category'),
        ),
        _buildMenuItem(
          icon: Icons.subdirectory_arrow_right,
          title: isArabic ? "إضافة مركز عمل" : 'زیادکردنی ناوەندی کار',
          onTap: () => Navigator.pushNamed(context, '/add_subcategory'),
        ),
        _buildMenuItem(
          icon: Icons.app_registration,
          title: isArabic ? "التسجيل" : 'خۆتۆمارکردن',
          onTap: () => Navigator.pushReplacementNamed(context, '/register'),
        ),
        Divider(),
        _buildMenuItem(
          icon: Icons.people,
          title: isArabic ? "عرض المستخدمين" : 'بینینی بەکارهێنەرەکان',
          onTap: () => Navigator.pushNamed(context, '/view_users'),
        ),
        _buildMenuItem(
          icon: Icons.add_box,
          title: isArabic ? "إضافة معلومات" : 'زیادکردنی زانیاری',
          onTap: () => Navigator.pushNamed(context, '/insert_details'),
        ),
        _buildMenuItem(
          icon: Icons.list,
          title: isArabic ? "عرض المعلومات" : 'پیشاندانی زانیاریەکان',
          onTap: () => Navigator.pushNamed(context, '/show_details'),
        ),
        _buildMenuItem(
          icon: Icons.list,
          title: isArabic ? "تعديل  مستخدم" : ' ئاپدتکرنا کارهێنەرا',
          onTap: () => Navigator.pushNamed(context, '/user2'),
        ),
        _buildMenuItem(
          icon: Icons.list,
          title: isArabic ? "تعديل  اعلانات" : ' ئاپدتکرنا ریکلام',
          onTap: () => Navigator.pushNamed(context, '/ads'),
        ),
        Divider(),
        _buildMenuItem(
          icon: Icons.settings,
          title: isArabic ? "الإبلاغ" : 'سکالا',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => FeedbackScreen())),
        ),
        _buildMenuItem(
          icon: Icons.settings,
          title: isArabic ? "قسم الإبلاغ" : 'بەشێ سکالا',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => FeedbackPage())),
        ),
        _buildMenuItem(
          icon: Icons.info,
          title: isArabic ? "حول" : 'دەربارە',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => AboutUsPage())),
        ),
        Divider(),
        _buildMenuItem(
          icon: Icons.exit_to_app,
          title: isArabic ? "تسجيل الخروج" : 'دەرچوون',
          onTap: () async {
            Provider.of<UserModel>(context, listen: false).clearUser();
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
      ];
    } else if (user.role == 'user') {
      menuItems = [
        _buildMenuItem(
          icon: Icons.home,
          title: isArabic ? "الصفحة الرئيسية" : 'پەڕەی سەرەکی',
          onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
        ),
        _buildMenuItem(
          icon: Icons.person,
          title: isArabic ? "الملف الشخصي" : 'پەڕەی کەسی',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  userName: user.name,
                  phoneNumber: user.phoneNumber,
                ),
              ),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.settings,
          title: isArabic ? "الإبلاغ" : 'سکالا',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => FeedbackScreen())),
        ),
        _buildMenuItem(
          icon: Icons.info,
          title: isArabic ? "حول" : 'دەربارە',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => AboutUsPage())),
        ),
        Divider(),
        _buildMenuItem(
          icon: Icons.exit_to_app,
          title: isArabic ? "تسجيل الخروج" : 'دەرچوون',
          onTap: () async {
            Provider.of<UserModel>(context, listen: false).clearUser();
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
      ];
    } else {
      menuItems = [
        _buildMenuItem(
          icon: Icons.home,
          title: isArabic ? "الصفحة الرئيسية" : 'پەڕەی سەرەکی',
          onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
        ),
        _buildMenuItem(
          icon: Icons.app_registration,
          title: isArabic ? "التسجيل" : 'خۆتۆمارکردن',
          onTap: () => Navigator.pushReplacementNamed(context, '/register'),
        ),
        _buildMenuItem(
          icon: Icons.settings,
          title: isArabic ? "الإبلاغ" : 'سکالا',
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => FeedbackScreen())),
        ),
        _buildMenuItem(
          icon: Icons.info,
          title: isArabic ? "حول" : 'دەربارە',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => AboutUsPage())),
        ),
        Divider(),
        _buildMenuItem(
          icon: Icons.login,
          title: isArabic ? "تسجيل الدخول" : 'چوونە ژوورەوە',
          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ];
    }

    // Append language selection at end
    menuItems.add(Divider());
    menuItems.add(_buildMenuItem(
      icon: Icons.language,
      title: isArabic ? "تغيير اللغة" : 'گۆڕینی زمان',
      onTap: () => _showLanguageDialog(context),
    ));

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 40,
                child: Icon(Icons.person, size: 50, color: Colors.deepPurple),
              ),
              accountName: Text(
                user.name.isNotEmpty
                    ? user.name
                    : (isArabic ? "مرحبا" : 'خێر هاتی'),
                style: TextStyle(
                  fontFamily: 'NotoKufi',
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                user.phoneNumber.isNotEmpty ? user.phoneNumber : '',
                style: TextStyle(
                  fontFamily: 'NotoKufi',
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ),
            ...menuItems,
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isArabic ? "اختر اللغة" : "زمان هەلبژێرە"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('کوردی'),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('selectedLanguage', 'ku');
                  Provider.of<LocaleProvider>(context, listen: false)
                      .setLocale(Locale('ku', 'IQ'));
                  Navigator.of(context)
                    ..pop() // close dialog
                    ..pop(); // close drawer
                },
              ),
              ListTile(
                title: Text('العربية'),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('selectedLanguage', 'ar');
                  Provider.of<LocaleProvider>(context, listen: false)
                      .setLocale(Locale('ar', ''));
                  Navigator.of(context)
                    ..pop()
                    ..pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'NotoKufi',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }
}

// import 'package:flutter/material.dart';
// import '../screens/dashboard_screen.dart';
// import '../screens/AboutUsPage.dart';
// import '../screens/register_screen.dart';

// class FooterMenu extends StatelessWidget {
//   // make this optional and default to -1
//   final int selectedIndex;

//   const FooterMenu({
//     Key? key,
//     this.selectedIndex = -1,
//   }) : super(key: key);

//   void _onItemTapped(BuildContext context, int index) {
//     if (index == selectedIndex) return;

//     final routes = [
//       DashboardScreen(),
//       RegisterScreen(),
//       AboutUsPage(),
//     ];

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => routes[index]),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // locale & labels as before
//     String locale = Localizations.localeOf(context).languageCode;
//     final labels = {
//       'ar': ['الرئيسية', 'التسجيل', 'حول'],
//       'ku': ['پەڕەی سەرەکی', 'خۆتۆمارکردن', 'دەربارە'],
//     };
//     List<String> localizedLabels = labels[locale] ?? labels['ku']!;

//     const int itemCount = 3;
//     // If selectedIndex is valid, highlight that; otherwise clamp to 0 but
//     // show it in gray so nothing looks “selected.”
//     final bool hasValid = selectedIndex >= 0 && selectedIndex < itemCount;
//     final int current = hasValid ? selectedIndex : 0;
//     final Color selCol = hasValid ? Colors.blueAccent : Colors.grey;
//     final Color unsel = Colors.grey;

//     return BottomNavigationBar(
//       currentIndex: current,
//       onTap: (i) => _onItemTapped(context, i),
//       selectedItemColor: selCol,
//       unselectedItemColor: unsel,
//       showUnselectedLabels: true,
//       items: [
//         BottomNavigationBarItem(
//           icon: const Icon(Icons.home),
//           label: localizedLabels[0],
//         ),
//         BottomNavigationBarItem(
//           icon: const Icon(Icons.app_registration),
//           label: localizedLabels[1],
//         ),
//         BottomNavigationBarItem(
//           icon: const Icon(Icons.info),
//           label: localizedLabels[2],
//         ),
//       ],
//     );
//   }
// }

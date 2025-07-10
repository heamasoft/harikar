// import 'package:flutter/material.dart';
// import 'package:harikar/screens/dashboard_screen.dart';
// import 'package:provider/provider.dart'; // Import Provider

// import '../widgets/custom_drawer.dart'; // Import CustomDrawer
// import '../models/user_model.dart'; // Import UserModel

// class SaveSuccessPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(
//           flexibleSpace: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.deepPurple, Colors.blueAccent],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           title: Text(
//             isArabic
//                 ? "تم حفظ المعلومات بنجاح"
//                 : "زانیاری بە سەرکەوتوویی زیادکرا",
//             style: TextStyle(
//               fontFamily: 'NotoKufi',
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           iconTheme: IconThemeData(color: Colors.white),
//         ),
//         drawer: CustomDrawer(), // Use CustomDrawer
//         body: Container(
//           height: MediaQuery.of(context).size.height,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.white, Colors.blueAccent.withOpacity(0.1)],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.check_circle_outline,
//                     size: 100,
//                     color: Colors.green,
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     isArabic
//                         ? "تم حفظ المعلومات بنجاح!"
//                         : "زانیاری بە سەرکەوتوویی زیادکرا!",
//                     style: TextStyle(
//                       fontFamily: 'NotoKufi',
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.deepPurple,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     isArabic
//                         ? "سنتواصل معك في أقرب وقت لإنهاء العملية."
//                         : "ئێمە پەیوەندی پێوە دەکەین لە نزیکترین کاتدا بۆ تەواوکردنی کارەکەت.",
//                     style: TextStyle(
//                       fontFamily: 'NotoKufi',
//                       fontSize: 18,
//                       color: Colors.black87,
//                       height: 1.6,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 30),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Navigate to the DashboardPage
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => DashboardScreen(),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       padding:
//                           EdgeInsets.symmetric(vertical: 15, horizontal: 30),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                     ),
//                     child: Text(
//                       isArabic
//                           ? "العودة إلى الصفحة الرئيسية"
//                           : "گەڕانەوە بۆ پەری سەرکی",
//                       style: TextStyle(
//                         fontFamily: 'NotoKufi',
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart'; // Import Provider
// import '../widgets/custom_drawer.dart';
// import 'UserInfoPage.dart';
// import '../models/user_model.dart'; // Import UserModel
// import 'dashboard_screen.dart'; // Import DashboardScreen
// import '../widgets/footer_menu.dart'; // Import the FooterMenu widget
// import 'AboutUsPage.dart'; // Import AboutUsPage

// class RegisterScreen extends StatefulWidget {
//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   bool _isPasswordVisible = false;
//   bool _isLoading = false;
//   final _formKey = GlobalKey<FormState>();

//   final List<String> _cities = [
//     'دهۆک',
//     'زاخۆ',
//     'سێمێل',
//     'ئاکرێ',
//     'هەولێر',
//     'سلێمانی'
//   ];
//   List<Map<String, dynamic>> _workTypes = [];
//   String? _selectedCity;
//   String? _selectedWorkTypeId;

//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _phoneNumberController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   int _selectedIndex = 1; // RegisterScreen is the second item

//   @override
//   void initState() {
//     super.initState();
//     _fetchWorkTypes();
//   }

//   Future<void> _fetchWorkTypes() async {
//     final url =
//         Uri.parse('https://legaryan.heama-soft.com/get_categories_active.php');
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         if (jsonResponse['success'] == true) {
//           setState(() {
//             _workTypes = List<Map<String, dynamic>>.from(jsonResponse['data']);
//             _selectedWorkTypeId = null; // Do not auto-select any value
//           });
//         }
//       } else {
//         showMessage(
//             context,
//             Localizations.localeOf(context).languageCode == 'ar'
//                 ? "فشل تحميل أنواع العمل"
//                 : "هەڵە لە وەرگرتنی جۆرەکانی کار",
//             isSuccess: false);
//       }
//     } catch (error) {
//       showMessage(
//           context,
//           Localizations.localeOf(context).languageCode == 'ar'
//               ? "فشل تحميل أنواع العمل"
//               : "هەڵە لە وەرگرتنی جۆرەکانی کار",
//           isSuccess: false);
//     }
//   }

//   Future<void> _registerUser() async {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);
//     final url = Uri.parse('https://legaryan.heama-soft.com/register_user.php');

//     final userData = {
//       "full_name": _fullNameController.text,
//       "phone_number": _phoneNumberController.text,
//       "password": _passwordController.text,
//       "city": _selectedCity ?? "",
//       "type_of_work_id": _selectedWorkTypeId ?? "0",
//     };

//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(userData),
//       );

//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         if (jsonResponse['success']) {
//           // Update UserModel here
//           final userModel = Provider.of<UserModel>(context, listen: false);
//           userModel.setUser(
//             _fullNameController.text,
//             _phoneNumberController.text,
//             'user', // Default role as 'user'
//             city: _selectedCity,
//           );

//           showMessage(context,
//               isArabic ? "تم التسجيل بنجاح!" : "خۆت تۆمار کرا بەرەوپێش!",
//               isSuccess: true);
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => UserInfoPage(),
//             ),
//           );
//         } else {
//           showMessage(
//               context,
//               jsonResponse['message'] ??
//                   (isArabic ? "فشل العملية" : "ئەرکە نادرا"),
//               isSuccess: false);
//         }
//       } else {
//         showMessage(
//             context,
//             isArabic
//                 ? "خطأ: ${response.reasonPhrase}"
//                 : "هەڵە: ${response.reasonPhrase}",
//             isSuccess: false);
//       }
//     } catch (error) {
//       showMessage(context,
//           isArabic ? "خطأ في الإنترنت: $error" : "هەڵەی ئینتەرنێت: $error",
//           isSuccess: false);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void showMessage(BuildContext context, String message,
//       {bool isSuccess = true}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message,
//             style: TextStyle(fontFamily: 'NotoKufi', color: Colors.white)),
//         backgroundColor: isSuccess ? Colors.green : Colors.red,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     return Directionality(
//       textDirection: TextDirection.rtl, // Ensure RTL
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
//             isArabic ? "تسجيل" : 'خۆتۆمارکردن',
//             style: TextStyle(
//                 fontFamily: 'NotoKufi', fontSize: 20, color: Colors.white),
//           ),
//           iconTheme: IconThemeData(color: Colors.white),
//         ),
//         drawer: CustomDrawer(),
//         body: Consumer<UserModel>(
//           builder: (context, userModel, child) {
//             if (userModel.name.isNotEmpty && userModel.phoneNumber.isNotEmpty) {
//               // User is already registered
//               return _buildAlreadyRegistered(context, isArabic);
//             } else {
//               // User is not registered, show the registration form
//               return _buildRegistrationForm(isArabic);
//             }
//           },
//         ),
//         bottomNavigationBar: FooterMenu(selectedIndex: _selectedIndex),
//       ),
//     );
//   }

//   /// Widget to display when user is already registered
//   Widget _buildAlreadyRegistered(BuildContext context, bool isArabic) {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.white, Colors.blueAccent.withOpacity(0.1)],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.check_circle_outline,
//                 color: Colors.green,
//                 size: 100,
//               ),
//               SizedBox(height: 20),
//               Text(
//                 isArabic
//                     ? "أنت مسجل مسبقاً."
//                     : "تۆ پێشتر لە سیستەمەکەدا تۆمار کراویت.",
//                 style: TextStyle(
//                   fontFamily: 'NotoKufi',
//                   fontSize: 20,
//                   color: Colors.black87,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => DashboardScreen()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   padding:
//                       EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                 ),
//                 child: Text(
//                   isArabic
//                       ? "العودة إلى الصفحة الرئيسية"
//                       : 'گەڕاندن بۆ پەڕەی سەرەکی',
//                   style: TextStyle(
//                     fontFamily: 'NotoKufi',
//                     fontSize: 18,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// Widget to display the registration form
//   Widget _buildRegistrationForm(bool isArabic) {
//     return Container(
//       height: MediaQuery.of(context).size.height,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.white, Colors.blueAccent.withOpacity(0.1)],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             _buildHeader(isArabic),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     _buildTextField(_fullNameController,
//                         isArabic ? "الاسم الكامل" : "ناوی تەواو", Icons.person,
//                         isArabic: isArabic),
//                     SizedBox(height: 15),
//                     _buildTextField(
//                       _phoneNumberController,
//                       isArabic ? "رقم الهاتف المحمول" : "ژمارەی مۆبایل",
//                       Icons.phone,
//                       inputType: TextInputType.phone,
//                       formatters: [FilteringTextInputFormatter.digitsOnly],
//                       isArabic: isArabic,
//                     ),
//                     SizedBox(height: 15),
//                     _buildDropdownField(
//                       labelText: isArabic ? "المدينة" : "شار",
//                       icon: Icons.location_city,
//                       items: _cities.map((city) {
//                         return DropdownMenuItem<String>(
//                           value: city,
//                           child: Text(city,
//                               style: TextStyle(fontFamily: 'NotoKufi')),
//                         );
//                       }).toList(),
//                       value: _selectedCity,
//                       onChanged: (value) =>
//                           setState(() => _selectedCity = value),
//                     ),
//                     SizedBox(height: 15),
//                     _buildDropdownField(
//                       labelText: isArabic ? "نوع العمل" : "جۆری کار",
//                       icon: Icons.work,
//                       items: _workTypes.map((item) {
//                         return DropdownMenuItem<String>(
//                           value: item['id'].toString(),
//                           child: Text(item['name'].toString(),
//                               style: TextStyle(fontFamily: 'NotoKufi')),
//                         );
//                       }).toList(),
//                       value: _selectedWorkTypeId,
//                       onChanged: (value) =>
//                           setState(() => _selectedWorkTypeId = value),
//                     ),
//                     SizedBox(height: 15),
//                     _buildPasswordField(isArabic),
//                     SizedBox(height: 30),
//                     ElevatedButton(
//                       onPressed: _isLoading ? null : _registerUser,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.deepPurple,
//                         padding: EdgeInsets.symmetric(vertical: 15),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                       ),
//                       child: _isLoading
//                           ? CircularProgressIndicator(color: Colors.white)
//                           : Text(
//                               isArabic ? "تسجيل" : "خۆت تۆمار بکە",
//                               style: TextStyle(
//                                 fontFamily: 'NotoKufi',
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                     ),
//                     SizedBox(height: 20),
//                     Divider(
//                       color: Colors.grey,
//                       thickness: 1,
//                     ),
//                     SizedBox(height: 20),
//                     Container(
//                       padding: EdgeInsets.all(15),
//                       margin: EdgeInsets.only(top: 20, bottom: 30),
//                       decoration: BoxDecoration(
//                         color: Colors.deepPurple.withOpacity(0.05),
//                         borderRadius: BorderRadius.circular(15),
//                         border: Border.all(
//                             color: Colors.deepPurple.withOpacity(0.2),
//                             width: 1),
//                       ),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.deepPurple.withOpacity(0.2),
//                             ),
//                             child: Icon(
//                               Icons.info_outline,
//                               size: 30,
//                               color: Colors.deepPurple,
//                             ),
//                           ),
//                           SizedBox(width: 15),
//                           Expanded(
//                             child: Text(
//                               isArabic
//                                   ? "بعد التسجيل، سنتواصل معك للحصول على المزيد من المعلومات والتأكيد على نجاح العملية."
//                                   : "دوای تۆمارکردن، ئێمە پەیوەندی پێوە دەکەین بۆ زیاتر زانیاری کەوتن لەگەڵ تۆ و سەرکەوتو بوونەوە.",
//                               style: TextStyle(
//                                 fontFamily: 'NotoKufi',
//                                 fontSize: 16,
//                                 color: Colors.black87,
//                                 height: 1.6,
//                               ),
//                               textAlign: TextAlign.justify,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(bool isArabic) {
//     return Container(
//       width: double.infinity,
//       height: 150,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.deepPurple, Colors.blueAccent],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(20),
//           bottomRight: Radius.circular(20),
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.app_registration, size: 60, color: Colors.white),
//             SizedBox(height: 10),
//             Text(
//               isArabic ? "تسجيل في برنامجنا" : "خۆتۆمارکردن بۆ پڕۆگرامەکەمان",
//               style: TextStyle(
//                 fontFamily: 'NotoKufi',
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdownField({
//     required String labelText,
//     required IconData icon,
//     required List<DropdownMenuItem<String>> items,
//     required String? value,
//     required void Function(String?) onChanged,
//   }) {
//     return DropdownButtonFormField<String>(
//       decoration: InputDecoration(
//         labelText: labelText,
//         prefixIcon: Icon(icon, color: Colors.deepPurple),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
//       ),
//       value: value,
//       items: items,
//       onChanged: onChanged,
//       validator: (value) => value == null ? '$labelText پێویستە.' : null,
//     );
//   }

//   Widget _buildTextField(
//       TextEditingController controller, String label, IconData icon,
//       {TextInputType inputType = TextInputType.text,
//       List<TextInputFormatter>? formatters,
//       bool? isArabic}) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: inputType,
//       inputFormatters: formatters,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.deepPurple),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
//       ),
//       validator: (value) => value!.isEmpty ? '$label پێویستە.' : null,
//     );
//   }

//   Widget _buildPasswordField(bool isArabic) {
//     return TextFormField(
//       controller: _passwordController,
//       obscureText: !_isPasswordVisible,
//       decoration: InputDecoration(
//         labelText: isArabic ? "كلمة المرور" : 'وشەی نهێنی',
//         prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
//         suffixIcon: IconButton(
//           icon: Icon(
//             _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//             color: Colors.deepPurple,
//           ),
//           onPressed: () =>
//               setState(() => _isPasswordVisible = !_isPasswordVisible),
//         ),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
//       ),
//       validator: (value) => value!.isEmpty
//           ? (isArabic ? "هذا الحقل مطلوب" : 'وشەی نهێنی پێویستە.')
//           : null,
//     );
//   }
// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'view_users_screen.dart';

// class UserDetailsPage extends StatefulWidget {
//   final int userId;

//   UserDetailsPage({required this.userId});

//   @override
//   _UserDetailsPageState createState() => _UserDetailsPageState();
// }

// class _UserDetailsPageState extends State<UserDetailsPage> {
//   bool _isLoading = true;
//   bool _isUpdating = false;

//   final List<String> _cities = [
//     'دهۆک',
//     'زاخۆ',
//     'سێمێل',
//     'ئاکرێ',
//     'هەولێر',
//     'سلێمانی'
//   ];
//   List<Map<String, dynamic>> _workTypes = [];
//   int? _isApproved; // 1 = Approved, 0 = Not Approved

//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _paymentController = TextEditingController();
//   final TextEditingController _subscriptionController = TextEditingController();
//   String? _selectedCity;
//   String? _selectedWorkTypeId;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserDetails();
//     _fetchWorkTypes();
//   }

//   Future<void> _fetchUserDetails() async {
//     final url = Uri.parse(
//         'https://legaryan.heama-soft.com/get_user_details.php?id=${widget.userId}');
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'success') {
//           final user = data['data'];
//           setState(() {
//             _fullNameController.text = user['full_name'] ?? '';
//             _phoneController.text = user['phone_number'] ?? '';
//             _paymentController.text = user['payment_amount']?.toString() ?? '0';
//             _subscriptionController.text = user['subscription_expiry'] ?? '';
//             _selectedCity = user['city'];
//             _selectedWorkTypeId = user['type_of_work_id']?.toString();
//             _isApproved = int.tryParse(user['is_approved'].toString()) ?? 0;
//             _isLoading = false;
//           });
//         } else {
//           _showError(data['message']);
//         }
//       } else {
//         _showError("Server error: ${response.statusCode}");
//       }
//     } catch (e) {
//       _showError("Failed to load data: $e");
//     }
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
//           });
//         }
//       }
//     } catch (e) {
//       _showError("Error fetching work types.");
//     }
//   }

//   Future<void> _updateUserDetails() async {
//     setState(() => _isUpdating = true);

//     final url = Uri.parse('https://legaryan.heama-soft.com/update_user.php');
//     final updatedData = {
//       "id": widget.userId,
//       "full_name": _fullNameController.text,
//       "phone_number": _phoneController.text,
//       "city": _selectedCity ?? "",
//       "type_of_work_id": _selectedWorkTypeId ?? "0",
//       "payment_amount": _paymentController.text,
//       "subscription_expiry": _subscriptionController.text,
//       "is_approved": _isApproved.toString(),
//     };

//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(updatedData),
//       );

//       final jsonResponse = json.decode(response.body);
//       final bool isArabic =
//           Localizations.localeOf(context).languageCode == 'ar';
//       if (jsonResponse['status'] == 'success') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               isArabic
//                   ? "تم تحديث المعلومات بنجاح!"
//                   : "زانیاری بە سەرکەوتوویی نوێکرایەوە!",
//               style: TextStyle(fontFamily: 'NotoKufi'),
//             ),
//             backgroundColor: Colors.green,
//           ),
//         );

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => ViewUsersScreen()),
//         );
//       } else {
//         _showError(isArabic
//             ? "فشل التحديث: ${jsonResponse['message']}"
//             : "Update failed: ${jsonResponse['message']}");
//       }
//     } catch (e) {
//       _showError(Localizations.localeOf(context).languageCode == 'ar'
//           ? "خطأ في تحديث المستخدم: $e"
//           : "Error updating user: $e");
//     } finally {
//       setState(() => _isUpdating = false);
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: TextStyle(fontFamily: 'NotoKufi')),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   Future<void> _pickDate() async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (pickedDate != null) {
//       setState(() {
//         _subscriptionController.text = "${pickedDate.toLocal()}".split(' ')[0];
//       });
//     }
//   }

//   Widget _buildRadioButton() {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           isArabic ? "موافقة:" : "پەسندکراو:",
//           style: TextStyle(fontFamily: 'NotoKufi', fontWeight: FontWeight.bold),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Radio<int>(
//                   value: 1,
//                   groupValue: _isApproved,
//                   onChanged: (value) => setState(() => _isApproved = value),
//                   activeColor: Colors.deepPurple,
//                 ),
//                 Text(isArabic ? "نعم" : "بەڵێ",
//                     style: TextStyle(fontFamily: 'NotoKufi')),
//               ],
//             ),
//             SizedBox(width: 20),
//             Row(
//               children: [
//                 Radio<int>(
//                   value: 0,
//                   groupValue: _isApproved,
//                   onChanged: (value) => setState(() => _isApproved = value),
//                   activeColor: Colors.deepPurple,
//                 ),
//                 Text(isArabic ? "لا" : "نەخێر",
//                     style: TextStyle(fontFamily: 'NotoKufi')),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller,
//       {bool isNumber = false}) {
//     return TextField(
//       controller: controller,
//       keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       style: TextStyle(fontFamily: 'NotoKufi'),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.deepPurple,
//           iconTheme: IconThemeData(color: Colors.white),
//           title: Text(
//             isArabic ? "تفاصيل المستخدم" : "پەڕەی کەسی",
//             style: TextStyle(
//               fontFamily: 'NotoKufi',
//               color: Colors.white,
//             ),
//           ),
//         ),
//         body: _isLoading
//             ? Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//                 padding: EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     _buildTextField(isArabic ? "الاسم الكامل" : "ناوی تەواو",
//                         _fullNameController),
//                     SizedBox(height: 20),
//                     _buildTextField(isArabic ? "رقم الهاتف" : "ژمارەی مۆبایل",
//                         _phoneController),
//                     SizedBox(height: 20),
//                     DropdownButtonFormField<String>(
//                       value: _selectedCity,
//                       decoration: InputDecoration(
//                         labelText: isArabic ? "المدينة" : "شار",
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                       items: _cities.map((city) {
//                         return DropdownMenuItem(value: city, child: Text(city));
//                       }).toList(),
//                       onChanged: (value) =>
//                           setState(() => _selectedCity = value),
//                     ),
//                     SizedBox(height: 20),
//                     DropdownButtonFormField<String>(
//                       value: _selectedWorkTypeId,
//                       decoration: InputDecoration(
//                         labelText: isArabic ? "نوع العمل" : "جۆری کار",
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                       items: _workTypes.map((type) {
//                         return DropdownMenuItem(
//                           value: type['id'].toString(),
//                           child: Text(type['name']),
//                         );
//                       }).toList(),
//                       onChanged: (value) =>
//                           setState(() => _selectedWorkTypeId = value),
//                     ),
//                     SizedBox(height: 20),
//                     _buildRadioButton(),
//                     SizedBox(height: 20),
//                     _buildTextField(isArabic ? "مبلغ الدفع" : "بڕی پارە",
//                         _paymentController,
//                         isNumber: true),
//                     SizedBox(height: 20),
//                     InkWell(
//                       onTap: _pickDate,
//                       child: InputDecorator(
//                         decoration: InputDecoration(
//                           labelText: isArabic ? "تاريخ الاشتراك" : "بەسەرچوونی",
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12)),
//                         ),
//                         child: Text(_subscriptionController.text.isEmpty
//                             ? (isArabic ? "اختر التاريخ" : "بەروار هەڵبژێرە")
//                             : _subscriptionController.text),
//                       ),
//                     ),
//                     SizedBox(height: 30),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.deepPurple,
//                         padding: EdgeInsets.symmetric(vertical: 15),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                       onPressed: _isUpdating ? null : _updateUserDetails,
//                       child: _isUpdating
//                           ? CircularProgressIndicator(color: Colors.white)
//                           : Text(
//                               isArabic ? "تحديث" : "نوێکردنەوە",
//                               style: TextStyle(
//                                   fontFamily: 'NotoKufi', color: Colors.white),
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }

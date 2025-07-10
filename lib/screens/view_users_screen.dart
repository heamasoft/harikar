// // lib/screens/view_users_screen.dart

// import 'dart:convert';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// import '../widgets/custom_drawer.dart';
// import '../models/user_model.dart';
// import 'user_details_page.dart';

// class ViewUsersScreen extends StatefulWidget {
//   @override
//   _ViewUsersScreenState createState() => _ViewUsersScreenState();
// }

// class _ViewUsersScreenState extends State<ViewUsersScreen>
//     with SingleTickerProviderStateMixin {
//   List<dynamic> _allUsers = [];
//   List<dynamic> _approvedUsers = [];
//   List<dynamic> _notApprovedUsers = [];
//   List<dynamic> _newUsers = [];

//   bool _isLoading = true;
//   String _searchQuery = "";

//   late TabController _tabController;

//   // Pagination variables
//   int _currentPageApproved = 1;
//   int _rowsPerPageApproved = 10;
//   int _totalApproved = 0;

//   int _currentPageNotApproved = 1;
//   int _rowsPerPageNotApproved = 10;
//   int _totalNotApproved = 0;

//   int _currentPageNew = 1;
//   int _rowsPerPageNew = 10;
//   int _totalNew = 0;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _fetchUsers();
//   }

//   Future<void> _fetchUsers() async {
//     setState(() => _isLoading = true);

//     final url = Uri.parse(
//       'https://legaryan.heama-soft.com/get_users.php?search=${Uri.encodeComponent(_searchQuery)}',
//     );

//     try {
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);

//         if (responseData['status'] == 'success') {
//           final users = responseData['data'] as List<dynamic>;

//           setState(() {
//             _allUsers = users;
//             _approvedUsers = users.where((u) => u['is_approved'] == 1).toList();
//             _notApprovedUsers = users
//                 .where((u) =>
//                     u['is_approved'] == 0 && u['subscription_expiry'] != null)
//                 .toList();
//             _newUsers =
//                 users.where((u) => u['subscription_expiry'] == null).toList();

//             _totalApproved = _approvedUsers.length;
//             _totalNotApproved = _notApprovedUsers.length;
//             _totalNew = _newUsers.length;

//             _isLoading = false;
//           });
//         } else {
//           _showMessage("Error: ${responseData['message']}");
//         }
//       } else {
//         _showMessage("HTTP Error: ${response.statusCode}");
//       }
//     } catch (e) {
//       _showMessage("Exception: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: TextStyle(fontFamily: 'NotoKufi', color: Colors.white),
//         ),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   Widget _buildUserCard(user) {
//     final formatter = NumberFormat('#,###', 'en_US');

//     String formatDate(String? date) {
//       if (date == null || date.isEmpty) return 'نوێ';
//       return date.split(' ')[0];
//     }

//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       padding: EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Top Row: User Name with Icon
//           Row(
//             children: [
//               CircleAvatar(
//                 backgroundColor: Colors.deepPurple.shade100,
//                 radius: 22,
//                 child: Icon(Icons.person, color: Colors.deepPurple, size: 26),
//               ),
//               SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   user['full_name'] ??
//                       (isArabic ? 'اسم غير معروف' : 'ناو نەدۆزرایەوە'),
//                   style: TextStyle(
//                     fontFamily: 'NotoKufi',
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.deepPurple,
//                   ),
//                 ),
//               ),
//               Icon(
//                 Icons.check_circle,
//                 color: (int.tryParse(user['is_approved'].toString()) ?? 0) == 1
//                     ? Colors.green
//                     : Colors.red,
//                 size: 22,
//               ),
//             ],
//           ),
//           SizedBox(height: 10),
//           Divider(height: 1, color: Colors.grey.shade300),
//           SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildColumnItem(
//                 icon: Icons.phone,
//                 title: isArabic ? "رقم الهاتف" : "ژمارەی مۆبایل",
//                 value: user['phone_number'] ?? '---',
//               ),
//               _buildColumnItem(
//                 icon: Icons.location_city,
//                 title: isArabic ? "المدينة" : "شار",
//                 value: user['city'] ?? '---',
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildColumnItem(
//                 icon: Icons.account_balance_wallet,
//                 title: isArabic ? "مبلغ الدفع" : "بڕی پارە",
//                 value: formatter.format(
//                   double.tryParse(user['payment_amount'].toString()) ?? 0,
//                 ),
//               ),
//               _buildColumnItem(
//                 icon: Icons.date_range,
//                 title: isArabic ? "تاريخ الانتهاء" : "بەسەرچوونی",
//                 value: formatDate(user['subscription_expiry']),
//               ),
//             ],
//           ),
//           SizedBox(height: 10),
//           Divider(height: 1, color: Colors.grey.shade300),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.info_outline, color: Colors.blueAccent),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => UserDetailsPage(
//                         userId: int.tryParse(user['id'].toString()) ?? 0,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.delete, color: Colors.redAccent),
//                 onPressed: () => _confirmDelete(user['id']),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildColumnItem({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 18, color: Colors.deepPurple),
//         SizedBox(width: 5),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontFamily: 'NotoKufi',
//                 fontSize: 12,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             SizedBox(height: 2),
//             Text(
//               value,
//               style: TextStyle(
//                 fontFamily: 'NotoKufi',
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   void _confirmDelete(int userId) {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Directionality(
//           textDirection: ui.TextDirection.rtl,
//           child: AlertDialog(
//             title: Text(
//               isArabic ? "حذف المستخدم" : "سڕینەوەی بەکارهێنەر",
//               style: TextStyle(fontFamily: 'NotoKufi'),
//             ),
//             content: Text(
//               isArabic
//                   ? "هل أنت متأكد من حذف هذا المستخدم؟"
//                   : "دڵنیای کە دەیتە سڕینەوەی ئەم بەکارهێنەرە؟",
//               style: TextStyle(fontFamily: 'NotoKufi'),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: Text(
//                   isArabic ? "لا" : "نەخێر",
//                   style: TextStyle(fontFamily: 'NotoKufi'),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   _deleteUser(userId);
//                 },
//                 child: Text(
//                   isArabic ? "نعم" : "بەڵێ",
//                   style: TextStyle(fontFamily: 'NotoKufi'),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _deleteUser(int userId) async {
//     final url = Uri.parse('https://legaryan.heama-soft.com/delete_user.php');

//     try {
//       final response = await http.post(
//         url,
//         body: {'id': userId.toString()},
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);

//         if (responseData['status'] == 'success') {
//           _showMessage(
//             Localizations.localeOf(context).languageCode == 'ar'
//                 ? "تم حذف المستخدم"
//                 : "بەکارهێنەر سڕاوە",
//           );
//           _fetchUsers();
//         } else {
//           _showMessage("Error: ${responseData['message']}");
//         }
//       } else {
//         _showMessage("HTTP Error: ${response.statusCode}");
//       }
//     } catch (e) {
//       _showMessage("Exception: $e");
//     }
//   }

//   List<dynamic> _approvedCurrentPage() {
//     final startIndex = (_currentPageApproved - 1) * _rowsPerPageApproved;
//     final endIndex = startIndex + _rowsPerPageApproved;
//     if (startIndex >= _approvedUsers.length) {
//       return [];
//     }
//     return _approvedUsers.sublist(
//       startIndex,
//       endIndex > _approvedUsers.length ? _approvedUsers.length : endIndex,
//     );
//   }

//   List<dynamic> _notApprovedCurrentPage() {
//     final startIndex = (_currentPageNotApproved - 1) * _rowsPerPageNotApproved;
//     final endIndex = startIndex + _rowsPerPageNotApproved;
//     if (startIndex >= _notApprovedUsers.length) {
//       return [];
//     }
//     return _notApprovedUsers.sublist(
//       startIndex,
//       endIndex > _notApprovedUsers.length ? _notApprovedUsers.length : endIndex,
//     );
//   }

//   List<dynamic> _newCurrentPage() {
//     final startIndex = (_currentPageNew - 1) * _rowsPerPageNew;
//     final endIndex = startIndex + _rowsPerPageNew;
//     if (startIndex >= _newUsers.length) {
//       return [];
//     }
//     return _newUsers.sublist(
//       startIndex,
//       endIndex > _newUsers.length ? _newUsers.length : endIndex,
//     );
//   }

//   Widget _buildUserList(List<dynamic> users, String emptyMessage) {
//     if (users.isEmpty) {
//       return Center(
//         child: Text(
//           emptyMessage,
//           style: TextStyle(fontFamily: 'NotoKufi'),
//         ),
//       );
//     }

//     return ListView.builder(
//       itemCount: users.length,
//       itemBuilder: (context, index) {
//         return _buildUserCard(users[index]);
//       },
//     );
//   }

//   Widget _buildPaginationControls() {
//     final currentTabIndex = _tabController.index;
//     int currentPage = 1;
//     int rowsPerPage = 10;
//     int totalItems = 0;

//     switch (currentTabIndex) {
//       case 0:
//         currentPage = _currentPageApproved;
//         rowsPerPage = _rowsPerPageApproved;
//         totalItems = _totalApproved;
//         break;
//       case 1:
//         currentPage = _currentPageNotApproved;
//         rowsPerPage = _rowsPerPageNotApproved;
//         totalItems = _totalNotApproved;
//         break;
//       case 2:
//         currentPage = _currentPageNew;
//         rowsPerPage = _rowsPerPageNew;
//         totalItems = _totalNew;
//         break;
//     }

//     int totalPages = (totalItems / rowsPerPage).ceil();
//     if (totalPages == 0) {
//       totalPages = 1;
//     }

//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

//     return Container(
//       margin: EdgeInsets.all(10),
//       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Text(
//                 isArabic ? "عدد الصفوف لكل صفحة: " : "ڕیز بەپێی پەڕە: ",
//                 style: TextStyle(fontFamily: 'NotoKufi', fontSize: 14),
//               ),
//               SizedBox(width: 10),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.deepPurple.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.deepPurple, width: 1),
//                 ),
//                 child: DropdownButton<int>(
//                   value: rowsPerPage,
//                   dropdownColor: Colors.white,
//                   underline: SizedBox(),
//                   style: TextStyle(
//                     fontFamily: 'NotoKufi',
//                     color: Colors.deepPurple,
//                   ),
//                   items: [10, 20, 50].map((rows) {
//                     return DropdownMenuItem<int>(
//                       value: rows,
//                       child: Text(
//                         "$rows",
//                         style: TextStyle(fontFamily: 'NotoKufi'),
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     if (value == null) return;
//                     setState(() {
//                       switch (currentTabIndex) {
//                         case 0:
//                           _rowsPerPageApproved = value;
//                           _currentPageApproved = 1;
//                           break;
//                         case 1:
//                           _rowsPerPageNotApproved = value;
//                           _currentPageNotApproved = 1;
//                           break;
//                         case 2:
//                           _rowsPerPageNew = value;
//                           _currentPageNew = 1;
//                           break;
//                       }
//                     });
//                   },
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               Text(
//                 isArabic
//                     ? "الصفحة $currentPage من $totalPages"
//                     : "پەڕە $currentPage لە $totalPages",
//                 style: TextStyle(fontFamily: 'NotoKufi', fontSize: 14),
//               ),
//               SizedBox(width: 10),
//               IconButton(
//                 icon: Icon(Icons.chevron_left, color: Colors.deepPurple),
//                 onPressed: currentPage > 1
//                     ? () {
//                         setState(() {
//                           switch (currentTabIndex) {
//                             case 0:
//                               _currentPageApproved--;
//                               break;
//                             case 1:
//                               _currentPageNotApproved--;
//                               break;
//                             case 2:
//                               _currentPageNew--;
//                               break;
//                           }
//                         });
//                       }
//                     : null,
//                 splashRadius: 20,
//                 tooltip: isArabic ? "الصفحة السابقة" : "پەڕەی پێشوو",
//               ),
//               IconButton(
//                 icon: Icon(Icons.chevron_right, color: Colors.deepPurple),
//                 onPressed: currentPage < totalPages
//                     ? () {
//                         setState(() {
//                           switch (currentTabIndex) {
//                             case 0:
//                               _currentPageApproved++;
//                               break;
//                             case 1:
//                               _currentPageNotApproved++;
//                               break;
//                             case 2:
//                               _currentPageNew++;
//                               break;
//                           }
//                         });
//                       }
//                     : null,
//                 splashRadius: 20,
//                 tooltip: isArabic ? "الصفحة التالية" : "پەڕەی دواتر",
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     return DefaultTabController(
//       length: 3,
//       child: Directionality(
//         textDirection: ui.TextDirection.rtl,
//         child: Scaffold(
//           appBar: AppBar(
//             backgroundColor: Colors.deepPurple,
//             iconTheme: IconThemeData(color: Colors.white),
//             title: TextField(
//               style: TextStyle(color: Colors.white, fontFamily: 'NotoKufi'),
//               cursorColor: Colors.white,
//               decoration: InputDecoration(
//                 hintText: isArabic ? "ابحث حسب الاسم..." : "گەڕان بەپێی ناو...",
//                 hintStyle: TextStyle(color: Colors.white60),
//                 border: InputBorder.none,
//                 icon: Icon(Icons.search, color: Colors.white),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value;
//                   _currentPageApproved = 1;
//                   _currentPageNotApproved = 1;
//                   _currentPageNew = 1;
//                 });
//                 _fetchUsers();
//               },
//             ),
//             bottom: TabBar(
//               controller: _tabController,
//               indicatorColor: Colors.white,
//               labelColor: Colors.white,
//               unselectedLabelColor: Colors.white60,
//               tabs: [
//                 Tab(
//                   text: isArabic
//                       ? "الموافق عليهم ($_totalApproved)"
//                       : 'پەسندکراوەکان ($_totalApproved)',
//                 ),
//                 Tab(
//                   text: isArabic
//                       ? "غير الموافق عليهم ($_totalNotApproved)"
//                       : 'پەسندنەکراوەکان ($_totalNotApproved)',
//                 ),
//                 Tab(
//                   text: isArabic
//                       ? "المستخدمين الجدد ($_totalNew)"
//                       : 'بەکارهێنەری نوێ ($_totalNew)',
//                 ),
//               ],
//             ),
//           ),
//           drawer: CustomDrawer(),
//           body: _isLoading
//               ? Center(child: CircularProgressIndicator())
//               : Column(
//                   children: [
//                     Expanded(
//                       child: TabBarView(
//                         controller: _tabController,
//                         children: [
//                           _buildUserList(
//                             _approvedCurrentPage(),
//                             isArabic
//                                 ? "لا يوجد مستخدمون موافق عليهم"
//                                 : "هیچ بەکارهێنەر پەسندکراو نیە",
//                           ),
//                           _buildUserList(
//                             _notApprovedCurrentPage(),
//                             isArabic
//                                 ? "لا يوجد مستخدمون غير موافق عليهم"
//                                 : "هیچ بەکارهێنەر پەسندنەکراو نیە",
//                           ),
//                           _buildUserList(
//                             _newCurrentPage(),
//                             isArabic
//                                 ? "لا يوجد مستخدمون جدد"
//                                 : "هیچ بەکارهێنەری نوێ نیە",
//                           ),
//                         ],
//                       ),
//                     ),
//                     _buildPaginationControls(),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }

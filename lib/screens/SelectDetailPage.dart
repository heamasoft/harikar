// // lib/screens/SelectDetailPage.dart

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class SelectDetailPage extends StatefulWidget {
//   @override
//   _SelectDetailPageState createState() => _SelectDetailPageState();
// }

// class _SelectDetailPageState extends State<SelectDetailPage> {
//   final String _fetchUrl =
//       'https://legaryan.heama-soft.com/fetch_available_details.php';
//   List<Map<String, dynamic>> _allDetails = [];
//   List<Map<String, dynamic>> _filtered = [];
//   bool _isLoading = true;
//   final TextEditingController _searchCtrl = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchDetails();
//     _searchCtrl.addListener(_onSearch);
//   }

//   @override
//   void dispose() {
//     _searchCtrl.removeListener(_onSearch);
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   void _onSearch() {
//     final q = _searchCtrl.text.trim().toLowerCase();
//     if (q.isEmpty) {
//       setState(() => _filtered = List.from(_allDetails));
//     } else {
//       setState(() {
//         _filtered = _allDetails.where((d) {
//           final name = (d['name'] as String).toLowerCase();
//           final phone = (d['contact_number'] as String).toLowerCase();
//           return name.contains(q) || phone.contains(q);
//         }).toList();
//       });
//     }
//   }

//   Future<void> _fetchDetails() async {
//     setState(() => _isLoading = true);
//     try {
//       final resp = await http.get(Uri.parse(_fetchUrl));
//       final body = json.decode(resp.body);
//       if (body['status'] == 'success') {
//         final list = (body['data'] as List).cast<Map<String, dynamic>>();
//         setState(() {
//           _allDetails = list.map((item) {
//             return {
//               'id': item['id'].toString(),
//               'name': item['name'] ?? '',
//               'contact_number': item['phone_number'] ?? '',
//               'photo_url': item['photo_url'] ?? '',
//               'description': item['description'] ?? '',
//             };
//           }).toList();
//           _filtered = List.from(_allDetails);
//         });
//       } else {
//         setState(() {
//           _allDetails = [];
//           _filtered = [];
//         });
//       }
//     } catch (e) {
//       print("Error fetching details: $e");
//       setState(() {
//         _allDetails = [];
//         _filtered = [];
//       });
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isArabic = Localizations.localeOf(context).languageCode == 'ar';

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.deepPurple,
//           iconTheme: IconThemeData(color: Colors.white),
//           title: Container(
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             padding: EdgeInsets.symmetric(horizontal: 8),
//             child: TextField(
//               controller: _searchCtrl,
//               decoration: InputDecoration(
//                 hintText: isArabic
//                     ? 'ابحث بالاسم أو رقم الهاتف'
//                     : 'گەران بە ناو یان ژمارە',
//                 border: InputBorder.none,
//                 hintStyle: TextStyle(
//                   color: Colors.black45,
//                   fontFamily: 'NotoKufi',
//                 ),
//                 contentPadding: EdgeInsets.symmetric(vertical: 8),
//               ),
//               style: TextStyle(
//                 color: Colors.black87,
//                 fontFamily: 'NotoKufi',
//               ),
//             ),
//           ),
//         ),
//         body: _isLoading
//             ? Center(child: CircularProgressIndicator())
//             : _filtered.isEmpty
//                 ? Center(
//                     child: Text(
//                       isArabic ? 'لا توجد نتائج' : 'هیچ دۆخێک نیە',
//                       style: TextStyle(fontFamily: 'NotoKufi', fontSize: 16),
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: EdgeInsets.only(top: 8),
//                     itemCount: _filtered.length,
//                     itemBuilder: (ctx, i) {
//                       final d = _filtered[i];
//                       return Card(
//                         margin: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                         child: ListTile(
//                           leading: ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: Image.network(
//                               d['photo_url'],
//                               width: 50,
//                               height: 50,
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) => Container(
//                                   color: Colors.grey[300],
//                                   width: 50,
//                                   height: 50),
//                             ),
//                           ),
//                           title: Text(
//                             d['name'],
//                             style: TextStyle(
//                                 fontFamily: 'NotoKufi',
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Text(
//                             d['contact_number'],
//                             style: TextStyle(fontFamily: 'NotoKufi'),
//                           ),
//                           onTap: () => Navigator.pop(context, d),
//                         ),
//                       );
//                     },
//                   ),
//       ),
//     );
//   }
// }

// // lib/screens/form_search_work.dart

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart'; // ← new
// import '../widgets/custom_drawer.dart';
// import 'work_details_page.dart';
// import '../models/user_model.dart';
// import '../widgets/footer_menu.dart';

// class FormSearchWork extends StatefulWidget {
//   final int? initialCategoryId;
//   FormSearchWork({this.initialCategoryId});

//   @override
//   _FormSearchWorkState createState() => _FormSearchWorkState();
// }

// class _FormSearchWorkState extends State<FormSearchWork> {
//   List<Map<String, dynamic>> _categories = [];
//   Map<int, List<Map<String, dynamic>>> _subcategories = {};
//   String? _selectedCategoryName;
//   bool _isLoading = true;
//   bool _showDropdown = true;

//   final String baseUrl = "https://legaryan.heama-soft.com/uploads/";
//   final String categoriesApi =
//       "https://legaryan.heama-soft.com/get_categories.php";
//   final String subcategoriesApi =
//       "https://legaryan.heama-soft.com/get_subcategories.php";

//   final List<Color> _categoryColors = [
//     Colors.white,
//     Colors.white,
//     Colors.white,
//     Colors.white,
//     Colors.white,
//   ];

//   bool _didFetchData = false;
//   Locale? _currentLocale;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     Locale newLocale = Localizations.localeOf(context);
//     if (_currentLocale == null || _currentLocale != newLocale) {
//       _currentLocale = newLocale;
//       _didFetchData = false;
//     }
//     if (!_didFetchData) {
//       _fetchCategoriesAndSubcategories().then((_) {
//         if (widget.initialCategoryId != null) {
//           _setInitialCategory(widget.initialCategoryId!);
//           setState(() => _showDropdown = false);
//         }
//       });
//       _didFetchData = true;
//     }
//   }

//   Future<void> _fetchCategoriesAndSubcategories() async {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     setState(() => _isLoading = true);

//     try {
//       final responses = await Future.wait([
//         http.get(Uri.parse(categoriesApi)),
//         http.get(Uri.parse(subcategoriesApi)),
//       ]);

//       final categoriesJson = json.decode(responses[0].body);
//       final subcategoriesJson = json.decode(responses[1].body);

//       if (categoriesJson['status'] == 'success' &&
//           subcategoriesJson['status'] == 'success') {
//         // --- Categories ---
//         List cats = categoriesJson['data'];
//         _categories = cats
//             .where((c) => c['is_active'] == "1")
//             .toList()
//             .asMap()
//             .entries
//             .map((entry) {
//           int idx = entry.key;
//           var c = entry.value;
//           return {
//             "id": int.parse(c['id']),
//             "name": c['name'],
//             "original_name": c['name'],
//             "color": _categoryColors[idx % _categoryColors.length],
//           };
//         }).toList();
//         _applyCategoryTranslation();

//         // --- Subcategories ---
//         List subs = subcategoriesJson['data'];
//         _subcategories = {};
//         for (var s in subs) {
//           int catId = int.parse(s['category_id']);
//           _subcategories.putIfAbsent(catId, () => []);
//           _subcategories[catId]!.add({
//             "id": s['id'],
//             "name": s['name'],
//             "original_name": s['name'],
//             "image_url": "$baseUrl${s['image_url']}",
//             "is_active": s['is_active'] == "1",
//           });
//         }
//         _applySubcategoryTranslation();

//         // --- Prefetch all subcategory images ---
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _subcategories.values.expand((list) => list).forEach((sub) {
//             precacheImage(
//               NetworkImage(sub['image_url']),
//               context,
//             );
//           });
//         });
//       } else {
//         throw Exception("Failed to load data");
//       }
//     } catch (e) {
//       print("Error fetching data: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             isArabic
//                 ? "فشل تحميل البيانات. حاول مرة أخرى لاحقاً."
//                 : "Error fetching data. Please try again later.",
//             style: TextStyle(fontFamily: 'NotoKufi'),
//           ),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _applyCategoryTranslation() {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     final Map<String, String> translations = {
//       "ئەندازیار": "مهندس",
//       "مەساح": "مساح",
//       "ئامیرە": "أدوات",
//       "هوستا": "وستا",
//       "کرێکار": "عامل",
//     };
//     setState(() {
//       _categories = _categories.map((cat) {
//         final orig = cat['original_name'].toString().trim();
//         cat['name'] = isArabic && translations.containsKey(orig)
//             ? translations[orig]!
//             : orig;
//         return cat;
//       }).toList();
//     });
//   }

//   void _applySubcategoryTranslation() {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     final Map<String, String> translations = {
//       "شەڤەر": "شفل",
//       "کرێکار": "عمال",
//       "نەجار": "نجار",
//       // … add your mappings …
//     };
//     setState(() {
//       _subcategories.forEach((catId, list) {
//         for (var sub in list) {
//           final orig = sub['original_name'].toString().trim();
//           sub['name'] = (isArabic && translations.containsKey(orig))
//               ? translations[orig]!
//               : orig;
//         }
//       });
//     });
//   }

//   void _setInitialCategory(int categoryId) {
//     final cat = _categories.firstWhere(
//       (c) => c['id'] == categoryId,
//       orElse: () => {},
//     );
//     if (cat.isNotEmpty) {
//       setState(() => _selectedCategoryName = cat['name']);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     final user = Provider.of<UserModel>(context, listen: false);

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             isArabic ? "البحث عن عمل" : 'گەڕانی کار',
//             style: TextStyle(
//               fontFamily: 'NotoKufi',
//               fontWeight: FontWeight.bold,
//               fontSize: 20,
//               color: Colors.white,
//             ),
//           ),
//           flexibleSpace: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.deepPurple, Colors.blueAccent],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           iconTheme: IconThemeData(color: Colors.white),
//         ),
//         drawer: CustomDrawer(),
//         body: _isLoading
//             ? _buildLoadingState(isArabic)
//             : Container(
//                 width: double.infinity,
//                 height: double.infinity,
//                 color: Color.fromARGB(255, 245, 244, 244),
//                 child: Column(
//                   children: [
//                     if (_showDropdown)
//                       Padding(
//                         padding: EdgeInsets.all(12),
//                         child: _buildDropdownFilter(isArabic),
//                       ),
//                     Expanded(child: _buildCategoryList(isArabic)),
//                   ],
//                 ),
//               ),
//         bottomNavigationBar:
//             FooterMenu(), // no args → selectedIndex defaults to –1
//       ),
//     );
//   }

//   Widget _buildLoadingState(bool isArabic) => Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Colors.white,
//               Colors.blueAccent.withOpacity(0.1),
//               Colors.deepPurple.withOpacity(0.05),
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 16),
//               Text(
//                 isArabic
//                     ? "جاري تحميل البيانات..."
//                     : 'جارى باركردنى زانیاریەکان...',
//                 style: TextStyle(
//                   fontFamily: 'NotoKufi',
//                   fontSize: 16,
//                   color: Colors.black54,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );

//   Widget _buildDropdownFilter(bool isArabic) => DropdownButtonFormField<String>(
//         value: _selectedCategoryName,
//         hint: Text(isArabic ? "جميع الأقسام" : 'هەموو بەشەکان',
//             style: TextStyle(fontFamily: 'NotoKufi')),
//         decoration: InputDecoration(
//           contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//         ),
//         items: [
//           DropdownMenuItem<String>(
//             value: null,
//             child: Text(isArabic ? "جميع الأقسام" : 'هەموو بەشەکان',
//                 style: TextStyle(fontFamily: 'NotoKufi')),
//           ),
//           ..._categories.map((cat) {
//             return DropdownMenuItem<String>(
//               value: cat['name'],
//               child:
//                   Text(cat['name'], style: TextStyle(fontFamily: 'NotoKufi')),
//             );
//           }).toList(),
//         ],
//         onChanged: (v) => setState(() => _selectedCategoryName = v),
//       );

//   Widget _buildCategoryList(bool isArabic) {
//     final filtered = _selectedCategoryName == null
//         ? _categories
//         : _categories.where((c) => c['name'] == _selectedCategoryName).toList();
//     if (filtered.isEmpty) {
//       return Center(
//         child: Text(
//           isArabic ? "لا توجد أقسام متاحة." : 'هیچ بەشی بەردەست نیە.',
//           style: TextStyle(fontFamily: 'NotoKufi', fontSize: 16),
//         ),
//       );
//     }
//     return RefreshIndicator(
//       onRefresh: _fetchCategoriesAndSubcategories,
//       child: ListView.builder(
//         itemCount: filtered.length,
//         itemBuilder: (_, i) => _buildCategoryCard(filtered[i], isArabic),
//       ),
//     );
//   }

//   Widget _buildCategoryCard(Map<String, dynamic> category, bool isArabic) {
//     final subs = _subcategories[category['id']] ?? [];
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       padding: EdgeInsets.only(left: 12, right: 12, bottom: 8),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             category['color']!.withOpacity(0.7),
//             category['color']!.withOpacity(0.9),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: Text(
//               category['name'],
//               style: TextStyle(
//                 fontFamily: 'NotoKufi',
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blueAccent,
//               ),
//             ),
//           ),
//           Divider(color: Colors.blueAccent),
//           Padding(
//             padding: EdgeInsets.all(8),
//             child: subs.isEmpty
//                 ? Center(
//                     child: Text(
//                       isArabic
//                           ? "لا توجد بيانات متاحة."
//                           : 'هیچ زانیاریەکی بەردەست نیە.',
//                       style: TextStyle(
//                         fontFamily: 'NotoKufi',
//                         fontSize: 14,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   )
//                 : GridView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: subs.length,
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 3,
//                       crossAxisSpacing: 10,
//                       mainAxisSpacing: 10,
//                       childAspectRatio: 0.8,
//                     ),
//                     itemBuilder: (_, idx) => _buildSubcategoryCard(subs[idx]),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubcategoryCard(Map<String, dynamic> sub) {
//     bool isActive = sub['is_active'] ?? true;
//     double imageSize = MediaQuery.of(context).size.width * 0.2;

//     return GestureDetector(
//       onTap: !isActive
//           ? null
//           : () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => WorkDetailsPage(
//                     subcategoryId: sub['id'].toString(),
//                   ),
//                 ),
//               );
//             },
//       child: Container(
//         decoration: BoxDecoration(
//           color: isActive ? Colors.white : Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: isActive ? Colors.grey.shade300 : Colors.transparent,
//               blurRadius: 8,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // ← using CachedNetworkImage now
//                   CachedNetworkImage(
//                     imageUrl: sub['image_url'],
//                     height: imageSize,
//                     width: imageSize,
//                     fit: BoxFit.cover,
//                     placeholder: (ctx, url) => SizedBox(
//                       height: imageSize,
//                       width: imageSize,
//                       child: Center(
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       ),
//                     ),
//                     errorWidget: (ctx, url, err) => Icon(
//                       Icons.broken_image,
//                       size: imageSize,
//                       color: Colors.grey,
//                     ),
//                     fadeInDuration: Duration(milliseconds: 200),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     sub['name'],
//                     style: TextStyle(
//                       fontFamily: 'NotoKufi',
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: isActive ? Colors.black87 : Colors.black45,
//                     ),
//                     textAlign: TextAlign.center,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//             if (!isActive)
//               Positioned(
//                 top: 4,
//                 right: 4,
//                 child: Icon(
//                   Icons.lock,
//                   color: Colors.redAccent,
//                   size: 16,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

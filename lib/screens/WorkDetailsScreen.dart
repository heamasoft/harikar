// // lib/screens/WorkDetailsScreen.dart

// import 'dart:convert';
// import 'dart:math'; // For min function
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';
// import 'package:provider/provider.dart';
// import '../widgets/custom_drawer.dart';
// import '../widgets/footer_menu.dart';
// import 'WorkDetailsScreen.dart'; // May be recursive? Ensure correct import if needed.
// import '../models/user_model.dart';

// class WorkDetailsScreen extends StatefulWidget {
//   final String detailId; // The ID of the detail to fetch
//   final Map<String, dynamic> user; // Optional: Pass the entire user map

//   WorkDetailsScreen({required this.detailId, required this.user});

//   @override
//   _WorkDetailsScreenState createState() => _WorkDetailsScreenState();
// }

// class _WorkDetailsScreenState extends State<WorkDetailsScreen> {
//   Map<String, dynamic>? _details; // Stores the fetched details
//   List<String> _images = []; // List of image URLs
//   List<Map<String, dynamic>> _relatedDetails = []; // Related entries
//   bool _isLoading = true; // Indicates if details are being loaded
//   bool _isRelatedLoading = false; // Indicates if related details are loading
//   String? _errorMessage; // Error message for main details
//   String? _relatedErrorMessage; // Error message for related details

//   @override
//   void initState() {
//     super.initState();
//     _fetchDetails(); // Fetch main details on initialization
//   }

//   /// Fetches the main details based on detailId
//   Future<void> _fetchDetails() async {
//     final String url =
//         'https://legaryan.heama-soft.com/get_details_by_id.php?detail_id=${widget.detailId}';
//     debugPrint("Fetching details from: $url");

//     try {
//       final response = await http.get(Uri.parse(url));
//       debugPrint("API Response: ${response.body}");

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         debugPrint("Decoded JSON Data: $data");

//         if (data['status'] == 'success') {
//           if (data['data'] is List && data['data'].isNotEmpty) {
//             debugPrint("Details fetched successfully: ${data['data'][0]}");

//             setState(() {
//               _details = data['data'][0];
//               _images = List<String>.from(data['data'][0]['images']);
//               _isLoading = false;
//             });

//             debugPrint("Fetched Images: $_images");

//             if (_details != null && _details!['subcategory_id'] != null) {
//               _fetchRelatedDetails(_details!['subcategory_id'].toString(),
//                   currentDetailId: widget.detailId);
//             }
//           } else {
//             setState(() {
//               _errorMessage =
//                   Localizations.localeOf(context).languageCode == 'ar'
//                       ? 'لا توجد بيانات للمعرّف المُقدم.'
//                       : 'No data found for the provided ID.';
//               _isLoading = false;
//             });
//             debugPrint("No data found for the provided ID.");
//           }
//         } else {
//           debugPrint("Error in API response: ${data['message']}");
//           setState(() {
//             _errorMessage = data['message'] ??
//                 (Localizations.localeOf(context).languageCode == 'ar'
//                     ? 'فشل في تحميل التفاصيل.'
//                     : 'Failed to load details.');
//             _isLoading = false;
//           });
//         }
//       } else {
//         debugPrint("Server error: ${response.statusCode}");
//         setState(() {
//           _errorMessage = Localizations.localeOf(context).languageCode == 'ar'
//               ? 'خطأ بالخادم: ${response.statusCode}'
//               : 'Server error: ${response.statusCode}';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching details: $e");
//       setState(() {
//         _errorMessage = Localizations.localeOf(context).languageCode == 'ar'
//             ? 'حدث خطأ أثناء تحميل التفاصيل.'
//             : 'An error occurred while fetching details.';
//         _isLoading = false;
//       });
//     }
//   }

//   /// Fetches related details based on subCategoryId
//   Future<void> _fetchRelatedDetails(String subCategoryId,
//       {String? currentDetailId}) async {
//     setState(() {
//       _isRelatedLoading = true;
//       _relatedErrorMessage = null;
//     });

//     String url =
//         'https://legaryan.heama-soft.com/get_related_details.php?sub_category_id=$subCategoryId';
//     if (currentDetailId != null && currentDetailId.isNotEmpty) {
//       url += '&current_detail_id=$currentDetailId';
//     }

//     debugPrint("Fetching related details from: $url");

//     try {
//       final response = await http.get(Uri.parse(url));
//       debugPrint("API Response for related details: ${response.body}");

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'success') {
//           List<Map<String, dynamic>> related = [];
//           if (data['data'] is List && data['data'].isNotEmpty) {
//             related = List<Map<String, dynamic>>.from(data['data']);
//           }
//           setState(() {
//             _relatedDetails = related;
//             _isRelatedLoading = false;
//           });
//         } else {
//           debugPrint("Error in related API response: ${data['message']}");
//           setState(() {
//             _relatedErrorMessage = data['message'] ??
//                 (Localizations.localeOf(context).languageCode == 'ar'
//                     ? 'فشل في تحميل التفاصيل ذات الصلة.'
//                     : 'Failed to load related details.');
//             _isRelatedLoading = false;
//           });
//         }
//       } else {
//         debugPrint("Server error for related details: ${response.statusCode}");
//         setState(() {
//           _relatedErrorMessage =
//               Localizations.localeOf(context).languageCode == 'ar'
//                   ? 'خطأ بالخادم: ${response.statusCode}'
//                   : 'Server error: ${response.statusCode}';
//           _isRelatedLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching related details: $e");
//       setState(() {
//         _relatedErrorMessage =
//             Localizations.localeOf(context).languageCode == 'ar'
//                 ? 'حدث خطأ أثناء تحميل التفاصيل ذات الصلة.'
//                 : 'An error occurred while fetching related details.';
//         _isRelatedLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     final Gradient appBarGradient = LinearGradient(
//       colors: [Colors.deepPurple, Colors.blueAccent],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     );

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             isArabic ? "صفحة التفاصيل" : 'پەڕەی زانیاری',
//             style: TextStyle(
//               fontFamily: 'NotoKufi',
//               fontWeight: FontWeight.bold,
//               fontSize: 20,
//               color: Colors.white,
//             ),
//           ),
//           flexibleSpace: Container(
//             decoration: BoxDecoration(gradient: appBarGradient),
//           ),
//           iconTheme: IconThemeData(color: Colors.white),
//         ),
//         endDrawer: CustomDrawer(),
//         body: _isLoading
//             ? Center(child: CircularProgressIndicator())
//             : _errorMessage != null
//                 ? Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Text(
//                         _errorMessage!,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontFamily: 'NotoKufi',
//                           fontSize: 16,
//                           color: Colors.red,
//                         ),
//                       ),
//                     ),
//                   )
//                 : SingleChildScrollView(
//                     child: Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildHeaderSection(appBarGradient, isArabic),
//                           SizedBox(height: 24),
//                           _buildInfoCard(
//                             icon: Icons.description,
//                             title: isArabic
//                                 ? "وصف المستخدم"
//                                 : 'پەسنی دەربارەی بەکارهێنەر',
//                             content: _details?['description'] ??
//                                 (isArabic
//                                     ? "لا يوجد وصف"
//                                     : 'بەسەر دەربارەی نادیارە'),
//                           ),
//                           SizedBox(height: 16),
//                           _buildInfoCard(
//                             icon: Icons.info,
//                             title:
//                                 isArabic ? "معلومات إضافية" : 'زانیاری زۆرتر',
//                             content: _details?['additional_info'] ??
//                                 (isArabic
//                                     ? "لا توجد معلومات"
//                                     : 'زانیاری نادیارە'),
//                           ),
//                           SizedBox(height: 24),
//                           _buildImageSection(isArabic),
//                           SizedBox(height: 24),
//                           _buildRelatedDetailsSection(isArabic),
//                         ],
//                       ),
//                     ),
//                   ),
//         bottomNavigationBar:
//             FooterMenu(), // no args → selectedIndex defaults to –1
//       ),
//     );
//   }

//   /// Builds the header section displaying main details
//   Widget _buildHeaderSection(Gradient appBarGradient, bool isArabic) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 6,
//       margin: EdgeInsets.zero,
//       child: Container(
//         padding: EdgeInsets.all(20.0),
//         decoration: BoxDecoration(
//           gradient: appBarGradient,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     isArabic ? "الاسم:" : 'ناو:',
//                     style: TextStyle(
//                       fontFamily: 'NotoKufi',
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     _details?['name'] ??
//                         (isArabic ? "اسم المستخدم" : 'ناوی بەکارهێنەر'),
//                     style: TextStyle(
//                       fontFamily: 'NotoKufi',
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white70,
//                     ),
//                     textAlign: TextAlign.right,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     isArabic ? "فئة الأقسام:" : 'بابەتی ناو پۆلەکان:',
//                     style: TextStyle(
//                       fontFamily: 'NotoKufi',
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     _details?['subcategory'] ??
//                         (isArabic
//                             ? "الفئة غير متوفرة"
//                             : 'بابەتی ناو پۆلەکان نادیارە'),
//                     style: TextStyle(
//                       fontFamily: 'NotoKufi',
//                       fontSize: 18,
//                       color: Colors.white70,
//                     ),
//                     textAlign: TextAlign.right,
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(width: 20),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     isArabic ? "المكان:" : 'شوێن:',
//                     style: TextStyle(
//                       fontFamily: 'NotoKufi',
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.location_on,
//                         color: Colors.white70,
//                         size: 20,
//                       ),
//                       SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           _details?['location'] ??
//                               (isArabic ? "المكان غير محدد" : 'شوێن: نادیار'),
//                           style: TextStyle(
//                             fontFamily: 'NotoKufi',
//                             fontSize: 18,
//                             color: Colors.white70,
//                           ),
//                           textAlign: TextAlign.right,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     isArabic ? "رقم الهاتف:" : 'ژمارەی مۆبایل:',
//                     style: TextStyle(
//                       fontFamily: 'NotoKufi',
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.phone,
//                         color: Colors.white70,
//                         size: 20,
//                       ),
//                       SizedBox(width: 8),
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () => _onPhoneNumberClicked(
//                               _details?['phone_number'] ?? ''),
//                           child: Text(
//                             _details?['phone_number'] ??
//                                 (isArabic
//                                     ? "رقم الهاتف غير متوفر"
//                                     : 'ژمارەی مۆبایل نادیارە'),
//                             style: TextStyle(
//                               fontFamily: 'NotoKufi',
//                               fontSize: 14,
//                               color: Colors.white70,
//                               decoration: TextDecoration.underline,
//                             ),
//                             textAlign: TextAlign.right,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       GestureDetector(
//                         onTap: () =>
//                             _onWhatsAppClicked(_details?['phone_number'] ?? ''),
//                         child: Icon(
//                           FontAwesomeIcons.whatsapp,
//                           color: Colors.white,
//                           size: 24,
//                           semanticLabel: isArabic
//                               ? 'أرسل رسالة واتساب'
//                               : 'Send a WhatsApp message',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Builds information cards displaying descriptions and additional info
//   Widget _buildInfoCard({
//     required IconData icon,
//     required String title,
//     required String content,
//   }) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 3,
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: Colors.deepPurple,
//               size: 30,
//             ),
//             SizedBox(width: 20),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontFamily: 'NotoKufi',
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                     textAlign: TextAlign.right,
//                   ),
//                   SizedBox(height: 6),
//                   Text(
//                     content,
//                     style: TextStyle(
//                       fontFamily: 'NotoKufi',
//                       fontSize: 14,
//                       color: Colors.black54,
//                     ),
//                     textAlign: TextAlign.right,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Builds the image section displaying fetched images
//   Widget _buildImageSection(bool isArabic) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           isArabic ? "الصور" : 'وێنەکان',
//           style: TextStyle(
//             fontFamily: 'NotoKufi',
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         SizedBox(height: 12),
//         _images.isNotEmpty
//             ? Container(
//                 height: 100,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: _images.length,
//                   itemBuilder: (context, index) {
//                     String imageUrl = _images[index];
//                     debugPrint("Loading Image $index: $imageUrl");
//                     return _buildImageCard(imageUrl, index);
//                   },
//                 ),
//               )
//             : SizedBox.shrink(),
//       ],
//     );
//   }

//   /// Builds individual image cards with tap functionality to open in lightbox
//   Widget _buildImageCard(String imageUrl, int index) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 6.0),
//       child: GestureDetector(
//         onTap: () {
//           _openImageLightbox(index);
//         },
//         child: Hero(
//           tag: imageUrl,
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Image.network(
//                 imageUrl,
//                 fit: BoxFit.cover,
//                 loadingBuilder: (context, child, progress) {
//                   if (progress == null) return child;
//                   return Center(
//                       child: CircularProgressIndicator(strokeWidth: 2));
//                 },
//                 errorBuilder: (context, error, stackTrace) {
//                   print('Error loading image: $error');
//                   return Container(
//                     color: Colors.grey[300],
//                     child: Icon(
//                       Icons.broken_image,
//                       size: 30,
//                       color: Colors.grey,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   /// Opens the tapped image in a lightbox using PhotoView
//   void _openImageLightbox(int initialIndex) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ImageLightbox(
//           images: _images,
//           initialIndex: initialIndex,
//         ),
//       ),
//     );
//   }

//   /// Builds the related details section displaying related entries
//   Widget _buildRelatedDetailsSection(bool isArabic) {
//     if (_relatedDetails.isEmpty) {
//       return SizedBox.shrink();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           isArabic ? "تفاصيل ذات صلة" : 'پاشەکەوتەکان',
//           style: TextStyle(
//             fontFamily: 'NotoKufi',
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         SizedBox(height: 12),
//         _isRelatedLoading
//             ? Center(child: CircularProgressIndicator())
//             : _relatedErrorMessage != null
//                 ? SizedBox.shrink()
//                 : ListView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: min(3, _relatedDetails.length),
//                     itemBuilder: (context, index) {
//                       return _buildRelatedDetailCard(
//                           _relatedDetails[index], isArabic);
//                     },
//                   ),
//       ],
//     );
//   }

//   /// Builds individual related detail cards with a gradient background
//   Widget _buildRelatedDetailCard(Map<String, dynamic> detail, bool isArabic) {
//     String imageUrl = detail['images'] != null && detail['images'].isNotEmpty
//         ? detail['images'][0]
//         : 'https://via.placeholder.com/150';
//     String name =
//         detail['name'] ?? (isArabic ? "اسم غير متوفر" : 'ناوی بەکارهێنەر');
//     String phoneNumber = detail['phone_number'] ??
//         (isArabic ? "غير متوفر" : 'ژمارەی مۆبایل نادیارە');
//     String location =
//         detail['location'] ?? (isArabic ? "المكان غير محدد" : 'شوێن: نادیار');
//     String subcategoryName = detail['subcategory'] ??
//         (isArabic ? "فئة غير متوفرة" : 'بابەتی ناو پۆلەکان');
//     String mainCategoryName = detail['main_category'] ??
//         (isArabic ? "فئة رئيسية غير متوفرة" : 'بەش سەرەکی');

//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8.0),
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: GestureDetector(
//         onTap: () {
//           String? detailId = detail['id']?.toString();
//           if (detailId != null && detailId.isNotEmpty) {
//             debugPrint("Card clicked with id: $detailId");
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => WorkDetailsScreen(
//                   detailId: detailId,
//                   user: detail,
//                 ),
//               ),
//             );
//           } else {
//             debugPrint("Invalid detail_id: $detailId");
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                   content: Text(isArabic
//                       ? 'معرّف التفاصيل غير صالح'
//                       : 'Invalid detail ID.')),
//             );
//           }
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.deepPurple, Colors.blueAccent],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Container(
//                 height: 60,
//                 width: 60,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 1),
//                 ),
//                 child: ClipOval(
//                   child: Image.network(
//                     imageUrl,
//                     fit: BoxFit.cover,
//                     loadingBuilder: (context, child, progress) {
//                       if (progress == null) return child;
//                       return Center(
//                           child: CircularProgressIndicator(strokeWidth: 2));
//                     },
//                     errorBuilder: (context, error, stackTrace) {
//                       print('Error loading image: $error');
//                       return Icon(
//                         Icons.broken_image,
//                         size: 30,
//                         color: Colors.grey,
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Flexible(
//                           child: Text(
//                             name,
//                             style: TextStyle(
//                               fontFamily: 'NotoKufi',
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 6, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: Colors.redAccent,
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Text(
//                                 subcategoryName,
//                                 style: TextStyle(
//                                   fontFamily: 'NotoKufi',
//                                   fontSize: 10,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 6),
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 6, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: Colors.green,
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Text(
//                                 mainCategoryName,
//                                 style: TextStyle(
//                                   fontFamily: 'NotoKufi',
//                                   fontSize: 10,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 6),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Row(
//                             children: [
//                               Icon(Icons.location_on,
//                                   size: 14, color: Colors.white70),
//                               SizedBox(width: 4),
//                               Flexible(
//                                 child: Text(
//                                   location,
//                                   style: TextStyle(
//                                     fontFamily: 'NotoKufi',
//                                     fontSize: 12,
//                                     color: Colors.white70,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               SizedBox(width: 8),
//                               Icon(Icons.phone,
//                                   size: 14, color: Colors.white70),
//                               SizedBox(width: 4),
//                               Flexible(
//                                 child: GestureDetector(
//                                   onTap: () =>
//                                       _onPhoneNumberClicked(phoneNumber),
//                                   child: Text(
//                                     phoneNumber,
//                                     style: TextStyle(
//                                       fontFamily: 'NotoKufi',
//                                       fontSize: 12,
//                                       color: Colors.white70,
//                                       decoration: TextDecoration.underline,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             GestureDetector(
//                               onTap: () => _onWhatsAppClicked(phoneNumber),
//                               child: Icon(
//                                 FontAwesomeIcons.whatsapp,
//                                 size: 20,
//                                 color: Colors.green,
//                                 semanticLabel: isArabic
//                                     ? 'أرسل رسالة واتساب'
//                                     : 'Send a WhatsApp message',
//                               ),
//                             ),
//                             SizedBox(width: 8),
//                             GestureDetector(
//                               onTap: () {
//                                 String? detailId = detail['id']?.toString();
//                                 if (detailId != null && detailId.isNotEmpty) {
//                                   debugPrint("Card clicked with id: $detailId");
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => WorkDetailsScreen(
//                                         detailId: detailId,
//                                         user: detail,
//                                       ),
//                                     ),
//                                   );
//                                 } else {
//                                   debugPrint("Invalid detail_id: $detailId");
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                         content: Text(isArabic
//                                             ? 'معرّف التفاصيل غير صالح'
//                                             : 'Invalid detail ID.')),
//                                   );
//                                 }
//                               },
//                               child: Icon(Icons.info_outline,
//                                   size: 20, color: Colors.blue),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// Handles phone number tap by incrementing view count then launching dialer
//   Future<void> _onPhoneNumberClicked(String phoneNumber) async {
//     await _incrementViewCountAndPerformAction(
//       action: () => _launchPhoneDialer(phoneNumber),
//       phoneNumber: phoneNumber,
//     );
//   }

//   /// Handles WhatsApp icon click by incrementing view count then launching WhatsApp
//   Future<void> _onWhatsAppClicked(String phoneNumber) async {
//     await _incrementViewCountAndPerformAction(
//       action: () => _launchWhatsApp(
//         phoneNumber,
//         message: Localizations.localeOf(context).languageCode == 'ar'
//             ? "مرحبا، لقد وجدتك في تطبيق هاريكار. أود التواصل معك لمزيد من التفاصيل عن عملك."
//             : "سلاڤ، من دڤێت پەیوەندی تە بکەم . من پێزانین تە دیتینە رێکا پرۆگرامێ هاریکار.",
//       ),
//       phoneNumber: phoneNumber,
//     );
//   }

//   /// Common method to increment view count and then perform the desired action
//   Future<void> _incrementViewCountAndPerformAction({
//     required VoidCallback action,
//     required String phoneNumber,
//   }) async {
//     if (_details == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(Localizations.localeOf(context).languageCode == 'ar'
//                 ? 'معلومات التفاصيل غير متوفرة.'
//                 : 'Detail information is not available.')),
//       );
//       return;
//     }

//     String detailId = widget.detailId;
//     if (detailId.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(Localizations.localeOf(context).languageCode == 'ar'
//                 ? 'معرّف التفاصيل غير صالح.'
//                 : 'Invalid detail ID.')),
//       );
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse("https://legaryan.heama-soft.com/increment_view_count.php"),
//         body: {'detail_id': detailId},
//       );
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == 'success') {
//           debugPrint("View count incremented for detail ID: $detailId");
//           setState(() {
//             int currentCount = _details!['view_count'] != null
//                 ? int.tryParse(_details!['view_count'].toString()) ?? 0
//                 : 0;
//             _details!['view_count'] = currentCount + 1;
//           });
//         } else {
//           debugPrint("Failed to increment view count: ${data['message']}");
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text(
//                     Localizations.localeOf(context).languageCode == 'ar'
//                         ? 'فشل في زيادة عدد المشاهدات.'
//                         : 'Failed to increment view count.')),
//           );
//         }
//       } else {
//         debugPrint(
//             "Server error incrementing view count: ${response.statusCode}");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(Localizations.localeOf(context).languageCode == 'ar'
//                   ? 'خطأ بالخادم أثناء زيادة عدد المشاهدات.'
//                   : 'Server error while incrementing view count.')),
//         );
//       }
//     } catch (e) {
//       debugPrint("Error incrementing view count: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(Localizations.localeOf(context).languageCode == 'ar'
//                 ? 'حدث خطأ أثناء زيادة عدد المشاهدات.'
//                 : 'Error incrementing view count.')),
//       );
//     }
//     action();
//   }

//   /// Launches the phone dialer with the provided phone number
//   Future<void> _launchPhoneDialer(String phoneNumber) async {
//     String sanitizedNumber = sanitizePhoneNumber(phoneNumber);
//     debugPrint('Dialer - Sanitized phone number: $sanitizedNumber');
//     final Uri phoneUri = Uri(scheme: 'tel', path: sanitizedNumber);
//     if (await canLaunchUrl(phoneUri)) {
//       await launchUrl(phoneUri);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(Localizations.localeOf(context).languageCode == 'ar'
//                 ? 'لا يمكن فتح برنامج الاتصال.'
//                 : 'Cannot launch the phone dialer.')),
//       );
//     }
//   }

//   /// Launches WhatsApp with the provided phone number and message
//   Future<void> _launchWhatsApp(String phoneNumber,
//       {String message = ''}) async {
//     String sanitizedNumber = sanitizePhoneNumber(phoneNumber);
//     if (!sanitizedNumber.startsWith('964')) {
//       sanitizedNumber = '964' + sanitizedNumber;
//     }
//     sanitizedNumber = sanitizedNumber.replaceAll('+', '');
//     String encodedMessage = Uri.encodeComponent(message);
//     final String url = "https://wa.me/$sanitizedNumber?text=$encodedMessage";
//     debugPrint('WhatsApp URL: $url');

//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(Localizations.localeOf(context).languageCode == 'ar'
//                 ? 'لا يمكن فتح WhatsApp. تأكد من تثبيته على جهازك.'
//                 : 'Could not launch WhatsApp. Please ensure it is installed on your device.')),
//       );
//     }
//   }

//   /// Helper method to sanitize phone numbers
//   String sanitizePhoneNumber(String phoneNumber) {
//     String sanitized = phoneNumber.replaceAll(RegExp(r'\D'), '');
//     sanitized = sanitized.replaceAll(RegExp(r'^0+'), '');
//     return sanitized;
//   }
// }

// /// ImageLightbox Widget to display images in a lightbox with navigation arrows
// class ImageLightbox extends StatefulWidget {
//   final List<String> images;
//   final int initialIndex;

//   ImageLightbox({required this.images, required this.initialIndex});

//   @override
//   _ImageLightboxState createState() => _ImageLightboxState();
// }

// class _ImageLightboxState extends State<ImageLightbox> {
//   late PageController _pageController;
//   late int _currentIndex;

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: _currentIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _previousImage() {
//     if (_currentIndex > 0) {
//       setState(() {
//         _currentIndex--;
//         _pageController.animateToPage(
//           _currentIndex,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       });
//     }
//   }

//   void _nextImage() {
//     if (_currentIndex < widget.images.length - 1) {
//       setState(() {
//         _currentIndex++;
//         _pageController.animateToPage(
//           _currentIndex,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           PhotoViewGallery.builder(
//             itemCount: widget.images.length,
//             pageController: _pageController,
//             onPageChanged: (index) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//             builder: (context, index) {
//               return PhotoViewGalleryPageOptions(
//                 imageProvider: NetworkImage(widget.images[index]),
//                 initialScale: PhotoViewComputedScale.contained,
//                 heroAttributes:
//                     PhotoViewHeroAttributes(tag: widget.images[index]),
//               );
//             },
//             loadingBuilder: (context, event) => Center(
//               child: CircularProgressIndicator(),
//             ),
//           ),
//           Positioned(
//             top: 40,
//             left: 20,
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.of(context).pop();
//               },
//               child: Icon(
//                 Icons.close,
//                 color: Colors.white,
//                 size: 30,
//                 semanticLabel: 'Close Lightbox',
//               ),
//             ),
//           ),
//           if (_currentIndex > 0)
//             Positioned(
//               left: 20,
//               top: MediaQuery.of(context).size.height * 0.5 - 30,
//               child: GestureDetector(
//                 onTap: _previousImage,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.black45,
//                     shape: BoxShape.circle,
//                   ),
//                   padding: EdgeInsets.all(8),
//                   child: Icon(
//                     Icons.arrow_back_ios,
//                     color: Colors.white,
//                     size: 24,
//                     semanticLabel: 'Previous Image',
//                   ),
//                 ),
//               ),
//             ),
//           if (_currentIndex < widget.images.length - 1)
//             Positioned(
//               right: 20,
//               top: MediaQuery.of(context).size.height * 0.5 - 30,
//               child: GestureDetector(
//                 onTap: _nextImage,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.black45,
//                     shape: BoxShape.circle,
//                   ),
//                   padding: EdgeInsets.all(8),
//                   child: Icon(
//                     Icons.arrow_forward_ios,
//                     color: Colors.white,
//                     size: 24,
//                     semanticLabel: 'Next Image',
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

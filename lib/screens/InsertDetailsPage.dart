// // lib/screens/InsertDetailsPage.dart

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart'; // For kIsWeb
// import 'package:flutter/services.dart';

// import '../widgets/custom_drawer.dart';

// class InsertDetailsPage extends StatefulWidget {
//   @override
//   _InsertDetailsPageState createState() => _InsertDetailsPageState();
// }

// class _InsertDetailsPageState extends State<InsertDetailsPage> {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _contactController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _additionalInfoController =
//       TextEditingController();

//   // Dropdown Data
//   List<dynamic> _subCategories = [];
//   List<dynamic> _users = [];
//   List<String> _cities = ['دهۆک', 'زاخۆ', 'سلێمانی', 'هەولێر'];

//   // Selected Values
//   String? _selectedSubCategory;
//   String? _selectedUser;
//   String? _selectedCity;
//   bool _isActive = true; // Default value for is_active

//   // Image Picker
//   final ImagePicker _picker = ImagePicker();
//   List<dynamic> _selectedImages = []; // Accept both File and Uint8List
//   bool _isSubmitting = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSubCategories();
//     _fetchUsers();
//   }

//   Future<void> _fetchSubCategories() async {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     final url =
//         Uri.parse('https://legaryan.heama-soft.com/get_subcategories.php');
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         if (responseData['status'] == 'success') {
//           setState(() {
//             _subCategories = responseData['data'];
//           });
//         } else {
//           _showMessage(isArabic
//               ? "فشل في تحميل الفئات الفرعية."
//               : "Failed to load subcategories.");
//         }
//       }
//     } catch (e) {
//       _showMessage(isArabic
//           ? "فشل في تحميل الفئات الفرعية."
//           : "Failed to load subcategories.");
//     }
//   }

//   Future<void> _fetchUsers() async {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     final url =
//         Uri.parse('https://legaryan.heama-soft.com/get_users.php?limit=0');
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         if (responseData['status'] == 'success') {
//           setState(() {
//             _users = responseData['data'];
//           });
//         } else {
//           _showMessage(
//               isArabic ? "فشل في تحميل المستخدمين." : "Failed to load users.");
//         }
//       } else {
//         _showMessage(
//             isArabic ? "فشل في تحميل المستخدمين." : "Failed to load users.");
//       }
//     } catch (e) {
//       _showMessage(
//           isArabic ? "فشل في تحميل المستخدمين." : "Failed to load users.");
//     }
//   }

//   Future<void> _insertData() async {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     if (!_formKey.currentState!.validate()) return;

//     if (_selectedImages.isEmpty) {
//       _showMessage(isArabic
//           ? "يجب اختيار صورة واحدة على الأقل"
//           : "پێویستە بەلایەنی کەم یەک وێنە هەڵبژێردرێت");
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     final url = Uri.parse('https://legaryan.heama-soft.com/insert_details.php');
//     final request = http.MultipartRequest('POST', url);

//     // Add form fields
//     request.fields['sub_category_id'] = _selectedSubCategory ?? '';
//     request.fields['user_id'] = _selectedUser ?? '';
//     request.fields['name'] = _nameController.text.trim();
//     request.fields['contact_number'] = _contactController.text.trim();
//     request.fields['location'] = _selectedCity ?? '';
//     request.fields['description'] = _descriptionController.text.trim();
//     request.fields['is_active'] = _isActive ? '1' : '0';
//     request.fields['additional_info'] = _additionalInfoController.text.trim();

//     try {
//       // Add images
//       for (var image in _selectedImages) {
//         if (kIsWeb && image is Uint8List) {
//           request.files.add(
//             http.MultipartFile.fromBytes(
//               'images[]',
//               image,
//               filename:
//                   DateTime.now().millisecondsSinceEpoch.toString() + '.jpg',
//             ),
//           );
//         } else if (image is File) {
//           request.files.add(
//             await http.MultipartFile.fromPath('images[]', image.path),
//           );
//         }
//       }

//       print("Request Fields: ${request.fields}");
//       print("Sending data to server...");
//       final response = await request.send();
//       final responseString = await response.stream.bytesToString();

//       print("Response Status: ${response.statusCode}");
//       print("Response Body: $responseString");

//       final responseData = jsonDecode(responseString);
//       if (response.statusCode == 200 && responseData['status'] == 'success') {
//         _showMessage(
//             isArabic
//                 ? "تم إضافة المعلومات بنجاح"
//                 : "زانیاری بە سەرکەوتوویی زیادکرا",
//             success: true);

//         // Reset all form fields and clear selections
//         _formKey.currentState!.reset();
//         setState(() {
//           _selectedImages = [];
//           _selectedSubCategory = null;
//           _selectedUser = null;
//           _selectedCity = null;
//           _isActive = true;
//         });

//         _nameController.clear();
//         _contactController.clear();
//         _descriptionController.clear();
//         _additionalInfoController.clear();
//       } else {
//         String errorMessage = isArabic
//             ? "خطأ: ${responseData['message']}"
//             : "هەڵە: ${responseData['message']}";
//         if (responseData['image_errors'] != null) {
//           errorMessage +=
//               "\n" + (responseData['image_errors'] as List).join(', ');
//         }
//         _showMessage(errorMessage);
//       }
//     } catch (e, stackTrace) {
//       print("Error: $e");
//       print("Stack Trace: $stackTrace");
//       _showMessage(
//           isArabic ? "حدث خطأ أثناء الإرسال: $e" : "هەڵەیەک ڕوویدا: $e");
//     } finally {
//       setState(() => _isSubmitting = false);
//     }
//   }

//   Future<void> _pickImages() async {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     final List<XFile>? images = await _picker.pickMultiImage();

//     if (images != null) {
//       if (images.length + _selectedImages.length > 3) {
//         _showMessage(isArabic
//             ? "الرجاء عدم اختيار أكثر من 3 صور"
//             : "تکایە زیاتر لە ٣ وێنە نەهەڵبژێرە");
//       } else {
//         for (var xFile in images) {
//           if (kIsWeb) {
//             final bytes = await xFile.readAsBytes();
//             setState(() {
//               _selectedImages.add(bytes);
//             });
//           } else {
//             setState(() {
//               _selectedImages.add(File(xFile.path));
//             });
//           }
//         }
//       }
//     }
//   }

//   void _showMessage(String message, {bool success = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: TextStyle(fontFamily: 'NotoKufi', color: Colors.white),
//         ),
//         backgroundColor: success ? Colors.green : Colors.red,
//       ),
//     );
//   }

//   Widget _buildImagePreview() {
//     return Wrap(
//       spacing: 10,
//       children: _selectedImages.isEmpty
//           ? [
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Center(
//                   child: Icon(Icons.image, color: Colors.grey),
//                 ),
//               ),
//             ]
//           : _selectedImages.asMap().entries.map((entry) {
//               int index = entry.key;
//               var imageFile = entry.value;

//               return Stack(
//                 alignment: Alignment.topRight,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: kIsWeb
//                         ? Image.memory(
//                             imageFile,
//                             width: 100,
//                             height: 100,
//                             fit: BoxFit.cover,
//                           )
//                         : Image.file(
//                             imageFile,
//                             width: 100,
//                             height: 100,
//                             fit: BoxFit.cover,
//                           ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedImages.removeAt(index);
//                       });
//                     },
//                     child: CircleAvatar(
//                       radius: 12,
//                       backgroundColor: Colors.red,
//                       child: Icon(Icons.close, size: 16, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               );
//             }).toList(),
//     );
//   }

//   Widget _buildUploadSection() {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Text(
//           isArabic
//               ? "اختر الصور (حد أقصى 3 صور)"
//               : "وێنەکان هەڵبژێرە (ماکسیمە ٣ وێنە)",
//           style: TextStyle(fontFamily: 'NotoKufi', fontSize: 16),
//         ),
//         SizedBox(height: 10),
//         ElevatedButton.icon(
//           onPressed: _pickImages,
//           icon: Icon(Icons.add_a_photo, color: Colors.white),
//           label: Text(
//             isArabic ? "اختر الصور" : "وێنە هەڵبژێرە",
//             style: TextStyle(fontFamily: 'NotoKufi', color: Colors.white),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.deepPurple,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//         ),
//         SizedBox(height: 10),
//         _buildImagePreview(),
//         if (_selectedImages.isEmpty)
//           Padding(
//             padding: const EdgeInsets.only(top: 10.0),
//             child: Text(
//               isArabic
//                   ? "يجب اختيار صورة واحدة على الأقل"
//                   : "پێویستە بەلایەنی کەم یەک وێنە هەڵبژێردرێت",
//               style: TextStyle(color: Colors.red, fontFamily: 'NotoKufi'),
//             ),
//           ),
//         SizedBox(height: 20),
//       ],
//     );
//   }

//   Widget _buildDropdown(String label, List<dynamic> items, String? value,
//       Function(String?) onChanged) {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     return Scrollbar(
//       thumbVisibility: true,
//       child: DropdownButtonFormField<String>(
//         value: value,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//         items: items
//             .map((item) => DropdownMenuItem<String>(
//                   value: item['id'].toString(),
//                   child: Text(item['name'] ?? item['full_name'],
//                       style: TextStyle(fontFamily: 'NotoKufi')),
//                 ))
//             .toList(),
//         onChanged: onChanged,
//         validator: (value) => value == null
//             ? (isArabic ? "مطلوب اختيار $label" : "پێویستە $label هەڵبژێردرێت")
//             : null,
//         dropdownColor: Colors.white,
//         isExpanded: true,
//         menuMaxHeight: 300,
//         itemHeight: 50,
//         selectedItemBuilder: (BuildContext context) {
//           return items.map<Widget>((item) {
//             return Container(
//               alignment: Alignment.centerRight,
//               child: Text(
//                 item['name'] ?? item['full_name'],
//                 style: TextStyle(fontFamily: 'NotoKufi'),
//               ),
//             );
//           }).toList();
//         },
//       ),
//     );
//   }

//   Widget _buildRadioButtons() {
//     final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
//     return Row(
//       children: [
//         Text(
//           isArabic ? "هل هو نشط؟" : "ئایا چالاکە؟",
//           style: TextStyle(fontFamily: 'NotoKufi'),
//         ),
//         SizedBox(width: 20),
//         Radio<bool>(
//           value: true,
//           groupValue: _isActive,
//           onChanged: (value) => setState(() => _isActive = value!),
//         ),
//         Text(isArabic ? "نعم" : "بەڵێ",
//             style: TextStyle(fontFamily: 'NotoKufi')),
//         Radio<bool>(
//           value: false,
//           groupValue: _isActive,
//           onChanged: (value) => setState(() => _isActive = value!),
//         ),
//         Text(isArabic ? "لا" : "نەخێر",
//             style: TextStyle(fontFamily: 'NotoKufi')),
//       ],
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
//           title: Text(
//             isArabic ? "إضافة معلومات جديدة" : 'زیادکردنی زانیاری نوێ',
//             style: TextStyle(
//               color: Colors.white,
//               fontFamily: 'NotoKufi',
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           iconTheme: IconThemeData(color: Colors.white),
//         ),
//         drawer: CustomDrawer(),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _buildDropdown(isArabic ? "نوع الفئة الفرعية" : "جۆری ژێرپۆل",
//                       _subCategories, _selectedSubCategory, (value) {
//                     setState(() => _selectedSubCategory = value);
//                   }),
//                   SizedBox(height: 15),
//                   _buildDropdown(isArabic ? "المستخدم" : "بەکارهێنەر", _users,
//                       _selectedUser, (value) {
//                     setState(() => _selectedUser = value);
//                   }),
//                   SizedBox(height: 15),
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                       labelText: isArabic ? "اسم المعلومات" : "ناوی زانیاری",
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     validator: (value) => value == null || value.isEmpty
//                         ? (isArabic
//                             ? "مطلوب إدخال الحقل"
//                             : "پێویستە پر بکرێتەوە")
//                         : null,
//                   ),
//                   SizedBox(height: 15),
//                   TextFormField(
//                     controller: _contactController,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                     ],
//                     decoration: InputDecoration(
//                       labelText:
//                           isArabic ? "رقم الاتصال" : "ژمارەی پەیوەندیدان",
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return isArabic
//                             ? "يجب كتابة الرقم"
//                             : "پێویستە ژمارەکە بنووسرێت";
//                       } else if (value.length < 10 || value.length > 15) {
//                         return isArabic
//                             ? "يجب أن يكون الرقم بين 10 و 15 رقماً"
//                             : "ژمارەکە دەبێت لانی کەم ١٠ ڕەقەم بێت و زۆرتر نەبێت لە ١٥";
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 15),
//                   _buildDropdown(
//                     isArabic ? "الموقع" : "شوێن",
//                     _cities.map((city) {
//                       return {"id": city, "name": city};
//                     }).toList(),
//                     _selectedCity,
//                     (value) {
//                       setState(() => _selectedCity = value);
//                     },
//                   ),
//                   SizedBox(height: 15),
//                   _buildRadioButtons(),
//                   SizedBox(height: 15),
//                   TextFormField(
//                     controller: _descriptionController,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       labelText: isArabic ? "الوصف" : "وەسف",
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return isArabic
//                             ? "يجب كتابة الوصف"
//                             : "پێویستە وەسف بنووسرێت";
//                       } else if (value.length < 10) {
//                         return isArabic
//                             ? "يجب أن يكون الوصف 10 حروف على الأقل"
//                             : "پێویستە وەسف لانی کەم ١٠ پیت بێت";
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 15),
//                   TextFormField(
//                     controller: _additionalInfoController,
//                     maxLines: 2,
//                     decoration: InputDecoration(
//                       labelText: isArabic
//                           ? "معلومات إضافية (اختياري)"
//                           : "زانیاری زیاتر (اختیاری)",
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   _buildUploadSection(),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       padding: EdgeInsets.symmetric(vertical: 15),
//                     ),
//                     onPressed: _isSubmitting ? null : _insertData,
//                     child: _isSubmitting
//                         ? CircularProgressIndicator(color: Colors.white)
//                         : Text(
//                             isArabic ? "إضافة" : "زیادکردن",
//                             style: TextStyle(
//                                 fontFamily: 'NotoKufi',
//                                 color: Colors.white,
//                                 fontSize: 18),
//                           ),
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

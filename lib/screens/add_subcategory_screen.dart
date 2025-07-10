// lib/screens/add_subcategory_screen.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // For Uint8List

import 'package:flutter/foundation.dart'; // To detect platform
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; // Import Provider
import '../widgets/custom_drawer.dart';
import '../models/user_model.dart'; // Import UserModel

class AddSubCategoryScreen extends StatefulWidget {
  @override
  _AddSubCategoryScreenState createState() => _AddSubCategoryScreenState();
}

class _AddSubCategoryScreenState extends State<AddSubCategoryScreen> {
  final TextEditingController _subCategoryController = TextEditingController();
  List<dynamic> _categories = [];
  List<dynamic> _subCategories = [];
  String? _selectedCategoryId;
  XFile? _selectedImage;
  Uint8List? _webImageBytes; // Image bytes for web compatibility
  bool _isLoading = false;
  Map<String, List<dynamic>> _groupedSubCategories =
      {}; // Group subcategories by category ID

  // Flag to ensure fetching is done only once in didChangeDependencies
  bool _didFetchData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetchData) {
      _fetchCategories();
      _fetchSubCategories();
      _didFetchData = true;
    }
  }

  Future<void> _fetchCategories() async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final url = Uri.parse('https://legaryan.heama-soft.com/get_categories.php');
    try {
      final response = await http.get(url);
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        setState(() => _categories = responseData['data']);
      }
    } catch (e) {
      _showMessage(
          isArabic ? "خطأ في جلب الفئات: $e" : "هەڵە لە هەڵگرتنی پۆلەکان: $e");
    }
  }

  // Fetch subcategories and group them by category ID
  Future<void> _fetchSubCategories() async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final url =
        Uri.parse('https://legaryan.heama-soft.com/get_subcategories.php');
    try {
      final response = await http.get(url);
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          _subCategories = responseData['data'];
          _groupSubCategoriesByCategory();
        });
      }
    } catch (e) {
      _showMessage(isArabic
          ? "خطأ في جلب الفئات الفرعية: $e"
          : "هەڵە لە هەڵگرتنی نێوپۆلەکان: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
        });
      }
    }
  }

  Future<void> _addSubCategory() async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String subCategoryName = _subCategoryController.text.trim();
    if (subCategoryName.isEmpty || _selectedCategoryId == null) {
      _showMessage(isArabic
          ? "يجب اختيار الفئة واسم الفئة الفرعية."
          : "پۆل و ناوی نێوپۆل پێویستە.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url =
        Uri.parse('https://legaryan.heama-soft.com/add_subcategory.php');
    var request = http.MultipartRequest('POST', url);

    // Add text fields
    request.fields['category_id'] = _selectedCategoryId!;
    request.fields['name'] = subCategoryName;

    try {
      // Handle image for Web
      if (kIsWeb && _webImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image', // Field name
            _webImageBytes!,
            filename: 'upload.png', // Placeholder name
          ),
        );
      }
      // Handle image for Mobile
      else if (!kIsWeb && _selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _selectedImage!.path,
          ),
        );
      }

      // Send the request
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decodedResponse = jsonDecode(responseBody);

      if (decodedResponse['status'] == 'success') {
        _showMessage(decodedResponse['message'], success: true);
        _fetchSubCategories();
        _subCategoryController.clear();
        setState(() {
          _selectedImage = null;
          _webImageBytes = null;
        });
      } else {
        _showMessage(decodedResponse['message']);
      }
    } catch (e) {
      _showMessage(isArabic ? "حدث خطأ: $e" : "هەڵە ڕویدا: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: 'NotoKufi', color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool confirmed = await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            isArabic ? "تأكيد" : 'پشتڕاستکردنەوە',
            style:
                TextStyle(fontFamily: 'NotoKufi', fontWeight: FontWeight.bold),
          ),
          content: Text(
            isArabic
                ? "هل أنت متأكد من حذف الفئة الفرعية؟"
                : 'دڵنیایت کە نێوپۆلەکە بسڕیتەوە؟',
            style: TextStyle(fontFamily: 'NotoKufi'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                isArabic ? "لا" : 'نەخێر',
                style:
                    TextStyle(color: Colors.deepPurple, fontFamily: 'NotoKufi'),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                isArabic ? "نعم" : 'بەڵێ',
                style: TextStyle(color: Colors.white, fontFamily: 'NotoKufi'),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      _deleteSubCategory(id);
    }
  }

  Future<void> _deleteSubCategory(String id) async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final url =
        Uri.parse('https://legaryan.heama-soft.com/delete_subcategory.php');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );

      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        _showMessage(responseData['message'], success: true);
        _fetchSubCategories();
      } else {
        _showMessage(responseData['message']);
      }
    } catch (e) {
      _showMessage(isArabic ? "خطأ في الحذف: $e" : "هەڵە لە سڕینەوەی: $e");
    }
  }

  Future<void> _toggleSubCategoryStatus(String id) async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final url = Uri.parse(
        'https://legaryan.heama-soft.com/toggle_subcategory_status.php');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"id": id},
      );
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        _showMessage(responseData['message']);
        _fetchSubCategories();
      } else {
        _showMessage(responseData['message']);
      }
    } catch (e) {
      _showMessage(
          isArabic ? "خطأ في تحديث الحالة: $e" : "هەڵە لە نوێکردنەوەی دۆخ: $e");
    }
  }

  void _groupSubCategoriesByCategory() {
    final Map<String, List<dynamic>> groupedData = {};
    for (var subCategory in _subCategories) {
      String categoryId = subCategory['category_id'].toString();
      if (!groupedData.containsKey(categoryId)) {
        groupedData[categoryId] = [];
      }
      groupedData[categoryId]!.add(subCategory);
    }
    setState(() {
      _groupedSubCategories = groupedData;
    });
  }

  Widget _buildSubCategoryCard(Map<String, dynamic> subCategory) {
    bool isActive = int.tryParse(subCategory['is_active'].toString()) == 1;
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    String imageUrl = subCategory['image_url'] != null
        ? 'https://legaryan.heama-soft.com/uploads/${subCategory['image_url']}'
        : '';

    return Container(
      margin: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl,
                      height: 80, width: 80, fit: BoxFit.cover)
                  : Container(
                      height: 80,
                      width: 80,
                      color: Colors.grey[200],
                      child: Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic
                      ? "الفئة: ${subCategory['category_name'] ?? '---'}"
                      : "پۆل: ${subCategory['category_name'] ?? '---'}",
                  style: TextStyle(
                    fontFamily: 'NotoKufi',
                    fontSize: 12,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subCategory['name'] ?? '---',
                  style: TextStyle(
                    fontFamily: 'NotoKufi',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade300, height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 30,
                  width: 30,
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.blueAccent, size: 18),
                    onPressed: () => _showEditDialog(subCategory),
                    padding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 30,
                  child: IconButton(
                    icon: Icon(
                      isActive ? Icons.check_circle : Icons.cancel,
                      color: isActive ? Colors.green : Colors.redAccent,
                      size: 18,
                    ),
                    onPressed: () =>
                        _toggleSubCategoryStatus(subCategory['id'].toString()),
                    padding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 30,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent, size: 18),
                    onPressed: () =>
                        _confirmDelete(subCategory['id'].toString()),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> subCategory) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final TextEditingController _editNameController =
        TextEditingController(text: subCategory['name']);
    Uint8List? _imageBytes; // For Web
    XFile? _newImage; // For Mobile

    Future<void> _pickNewImage(StateSetter setDialogState) async {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          Uint8List bytes = await pickedFile.readAsBytes();
          setDialogState(() {
            _imageBytes = bytes;
            _newImage = null;
          });
        } else {
          setDialogState(() {
            _newImage = pickedFile;
            _imageBytes = null;
          });
        }
      }
    }

    Future<void> _updateSubCategory() async {
      final bool isArabic =
          Localizations.localeOf(context).languageCode == 'ar';
      final updatedName = _editNameController.text.trim();
      if (updatedName.isEmpty) {
        _showMessage(
            isArabic ? "يجب إدخال اسم الفئة الفرعية." : "ناوی نێوپۆل پێویستە.",
            success: false);
        return;
      }

      final url =
          Uri.parse('https://legaryan.heama-soft.com/update_subcategory.php');
      var request = http.MultipartRequest('POST', url);
      request.fields['id'] = subCategory['id'].toString();
      request.fields['name'] = updatedName;

      if (_newImage != null && !kIsWeb) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _newImage!.path),
        );
      } else if (_imageBytes != null && kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            _imageBytes!,
            filename: 'uploaded_image.png',
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decodedResponse = jsonDecode(responseBody);

      if (decodedResponse['status'] == 'success') {
        _showMessage(decodedResponse['message'], success: true);
        _fetchSubCategories();
        Navigator.of(context).pop();
      } else {
        _showMessage(decodedResponse['message'], success: false);
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title:
                Text(isArabic ? "تحديث الفئة الفرعية" : 'نوێکردنەوەی نێوپۆل'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _editNameController,
                    decoration: InputDecoration(
                      labelText: isArabic ? "اسم الفئة الفرعية" : 'ناوی نێوپۆل',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      await _pickNewImage(setDialogState);
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        image: _imageBytes != null
                            ? DecorationImage(
                                image: MemoryImage(_imageBytes!),
                                fit: BoxFit.cover,
                              )
                            : _newImage != null
                                ? DecorationImage(
                                    image: FileImage(File(_newImage!.path)),
                                    fit: BoxFit.cover,
                                  )
                                : subCategory['image_url'] != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          'https://legaryan.heama-soft.com/uploads/${subCategory['image_url']}',
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                      ),
                      child: (_imageBytes == null && _newImage == null)
                          ? Center(
                              child: Icon(Icons.add_a_photo,
                                  size: 40, color: Colors.grey),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(isArabic ? "إلغاء" : 'پەشیمان بوون'),
              ),
              ElevatedButton(
                onPressed: _updateSubCategory,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
                child: Text(
                  isArabic ? "تحديث" : 'نوێکردنەوە',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final user = Provider.of<UserModel>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            isArabic ? "إضافة فئة فرعية جديدة" : 'زیادکردنی نێوپۆلەکان',
            style: TextStyle(color: Colors.white, fontFamily: 'NotoKufi'),
          ),
        ),
        drawer: CustomDrawer(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    hint: Text(
                      isArabic ? "اختر الفئة" : 'پۆل هەڵبژێرە',
                      style: TextStyle(fontFamily: 'NotoKufi'),
                    ),
                    items:
                        _categories.map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem(
                        value: category['id'].toString(),
                        child: Text(category['name'],
                            style: TextStyle(fontFamily: 'NotoKufi')),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() {
                      _selectedCategoryId = value;
                    }),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon:
                          Icon(Icons.category, color: Colors.deepPurple),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _subCategoryController,
                    decoration: InputDecoration(
                      labelText: isArabic ? "اسم الفئة الفرعية" : 'ناوی نێوپۆل',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label, color: Colors.deepPurple),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        image: (_selectedImage != null &&
                                kIsWeb &&
                                _webImageBytes != null)
                            ? DecorationImage(
                                image: MemoryImage(_webImageBytes!),
                                fit: BoxFit.cover,
                              )
                            : (_selectedImage != null && !kIsWeb)
                                ? DecorationImage(
                                    image:
                                        FileImage(File(_selectedImage!.path)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: (_selectedImage == null)
                          ? Center(
                              child: Icon(Icons.add_a_photo,
                                  size: 40, color: Colors.grey),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple),
                    onPressed: _isLoading ? null : _addSubCategory,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isArabic ? "إضافة" : 'زیادکردن',
                            style: TextStyle(
                                fontFamily: 'NotoKufi', color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
            Divider(),
            SizedBox(height: 10),
            Expanded(
              child: _categories.isEmpty
                  ? Center(
                      child: Text(
                        isArabic
                            ? "لم يتم العثور على فئة."
                            : 'هیچ پۆلەکان نەدۆزرایەوە.',
                        style: TextStyle(fontFamily: 'NotoKufi', fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final categoryId = category['id'].toString();

                        if (_groupedSubCategories.containsKey(categoryId)) {
                          List<dynamic> subCategoryList =
                              _groupedSubCategories[categoryId]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  isArabic
                                      ? "الفئة ${category['name']}"
                                      : "پۆلی ${category['name']}",
                                  style: TextStyle(
                                      fontFamily: 'NotoKufi',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              SizedBox(height: 10),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  int crossAxisCount = 3;
                                  double screenWidth = constraints.maxWidth;
                                  if (screenWidth < 300) {
                                    crossAxisCount = 1;
                                  } else if (screenWidth < 600) {
                                    crossAxisCount = 2;
                                  } else {
                                    crossAxisCount = 3;
                                  }
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.all(10),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 0.75,
                                    ),
                                    itemCount: subCategoryList.length,
                                    itemBuilder: (context, subIndex) {
                                      return _buildSubCategoryCard(
                                          subCategoryList[subIndex]);
                                    },
                                  );
                                },
                              ),
                            ],
                          );
                        }
                        return SizedBox();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
